% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/10

%% 1.计算准备
clc;clear;
format longG;%设置输出格式，保留输出更多有效数字

outputFile = '计算结果.txt';%输出计算结果到指定文件
ModeList = {'潮流计算', '近似短路计算'};%, '基于潮流分布的短路计算'
%% 2.选择计算模式与算例
WaitTime = 0;%计算模式选择计数
while true
    %使用listdlg进行模式选择
    [CalculatMode, IsChosed] = listdlg('PromptString', '请选择计算模式：', ...
                                        'SelectionMode', 'single', ...
                                        'ListString', ModeList, ...
                                        'Name', '计算模式选择',...
                                        'ListSize', [300, 150]);
    if IsChosed == 0%如果未选择，弹出警告对话框并继续循环
        WaitTime = WaitTime + 1;
        if WaitTime == 3%如果等待3次，结束运行
            error('未选择计算模式，程序终止。');
        else
            uiwait(warndlg('未选择计算模式，请重新选择。'));
            continue;
        end
    end
    break;
end 
%% 3.计算选择
switch CalculatMode
%% 潮流计算
    case 1
    %% 1.选择数据文件与计算目标精度  
    [file, path] = uigetfile('*.*', '选择一个数据文件');
    if isequal(file, 0)
        error('取消了文件选择');
    else
        [~, name, ~] = fileparts(file);%获取文件名
        addpath(path);%为调用函数准备路径
        mpc = feval(name);%调用函数并获取mpc结构体
        rmpath(path);
        disp(['选择了文件:', fullfile(path, file)]);
        if isfield(mpc,'baseMVA')%检查mpc变量是否包含基本属性
            disp('mpc变量已成功加载');
        else
        error('mpc变量有误，请重新运行以重新选择数据文件');
        end
    end
    %使用inputdlg创建输入对话框
    Prompt = {'允许最大迭代次数:', '目标迭代精度:'};
    DialogTitle = '输入参数';
    DPI = [1 10];
    DefaultInput = {'20', '1e-10'};
    Answer = inputdlg(Prompt, DialogTitle, DPI, DefaultInput);
    %将输入转换为数值
    MaxIterations = uint32(str2double(Answer{1}));
    Tolrance = str2double(Answer{2});
    %% 2.读取数据
    StartTime = datetime('now','Format','yyyy-MM-dd HH:mm:ss');
    tic;%运行计时开始
    [SB,NodeNumbers,Line,Node,Gen,g,b,Balance,PVdata,PQdata] = PF_ReadData(mpc);
    %% 3.形成导纳矩阵
    [Gij,Bij,kGij,kBij,Ga1,Ga2,Ba1,Ba2,G,B,Y] = PF_FormYmatrix(Line,NodeNumbers,Node,SB);
    %% 4.初始化
    PVNode = PVdata(:,1);                                          %提取系统的PV节点标号(第一列所有行的元素)
    GenNode = Gen(:,1);                                            %获取GenData中的PV和平衡节点号
    U0 = ones(NodeNumbers,1);                                      %除了PV和平衡外平启动电压幅值取1
    U0(GenNode) = Gen(:,6);                                        %将平衡节点与PV节点的电压赋值
    Angle = sparse(zeros(NodeNumbers,1));                          %启动电压相角取0
    Angle(Balance,1) = deg2rad(Node(Balance,9));
    P = sparse(PQdata(:,1),1,-PQdata(:,3)/SB,NodeNumbers,1);       %公式P = Pg - Pd
    P = P+sparse(PVdata(:,1),1,-PVdata(:,3)/SB,NodeNumbers,1);     
    Q = sparse(PQdata(:,1),1,-PQdata(:,4)/SB,NodeNumbers,1);       %公式Q = Qg - Qd
    U1 = U0.*exp(1i.*Angle);
    %% 5.计算不平衡量
    for CurrentIteration = 1: MaxIterations
        [P_Unbalance,Q_Unbalance,MaxUnbalance,Unbalance] = PF_CalculateDeltaPQ(Y,U1,Balance,P,Q,PVNode);
        if MaxUnbalance<Tolrance
        %判断最大不平衡量是否小于精确度，小于即可结束迭代
        disp('此次计算收敛');
        disp(['计算的节点数为：',num2str(NodeNumbers),'个']);
        disp(['潮流迭代的次数为：',num2str(CurrentIteration),'次']);
        disp('最大不平衡量为: ');disp(MaxUnbalance)
        break;
        else%否则继续迭代
    %% 6.计算和修正雅可比矩阵
        [Jb] = PF_FormJacobi(U1,PVNode,Balance,Y,NodeNumbers);
    %% 7、求解潮流修正量  
        [U1] = PF_SolveCorrectionEquation(Jb,Unbalance,NodeNumbers,U1);
        end
    end
    if CurrentIteration> MaxIterations                                                        
        %如果迭代次数达到最大迭代次数，则在规定的条件下无法收敛
        disp('此次潮流计算不收敛');
        disp(['潮流迭代的次数为：',num2str(CurrentIteration),'次']);
        UsedTime = toc;%运行计时结束
        disp(['运行时长为',num2str(UsedTime),'秒']);
    end
    %% 8.计算数据
    %计算支路功率
    [S_balance,U_ij,S_ij] = PF_CalculateBranchPowers(Y,Balance,U1,SB,Line,kGij,kBij,NodeNumbers,Ga1,Ba1,Ba2,Ga2);
    %计算平衡节点、线路功率、线路损耗
    volts=sparse([full(abs(U1)),full(rad2deg(angle(U1)))]);
    slack_power=S_balance;%命名要求
    trans_powers=S_ij;%命名要求
    S_lose = sparse(S_ij + S_ij.');

    UsedTime = toc;%运行计时结束
    TimeMessage = ['运行时长为',num2str(UsedTime),'秒'];
    
    %% 9.输出成功计算结果
    PF_Printout(volts,trans_powers,S_lose,U1,slack_power,...
                NodeNumbers,CurrentIteration,MaxUnbalance,...
                StartTime,TimeMessage,outputFile);
    DeviceInfo();%额外输出设备信息
%% 短路计算
    case 2
    %% 1.选择数据文件与短路具体参数
    Trans_a = -0.5+0.5i*sqrt(3);%相序变换矩阵元素a; 
    Transfrom120ToABC = [1 1 1;Trans_a^2 Trans_a 1;Trans_a Trans_a^2 1];%序转相矩阵
    UfBase = 1; %近似计算，设故障点电压为1

    [file, path] = uigetfile('*.*', '选择一个数据文件');
    if isequal(file, 0)
        error('取消了文件选择');
    else
        [~, name, ~] = fileparts(file);%获取文件名
        addpath(path);%为调用函数准备路径
        ScData = feval(name); %调用函数并获取数据结构体
        rmpath(path);
        disp(['选择了文件:', fullfile(path, file)]);
        if isfield(ScData,'line')%检查ScData变量是否包含基本属性
            disp('短路计算数据已成功加载');
            NodeNumbers = max(max(ScData.line(:,3)), max(ScData.line(:,4)));%获取节点数
            WarnTime = 0;
            while true
                %使用inputdlg创建输入对话框
                Prompt = {'短路节点序号:'};
                DialogTitle = '输入短路节点';
                DPI = [1 10];
                DefaultInput = {'1'};%默认短路节点为1号节点
                
                Answer = inputdlg(Prompt, DialogTitle, DPI, DefaultInput);
                ScNode = str2double(Answer{1});%将输入转换为数值
                if ScNode > 0 && ScNode <= NodeNumbers %检查输入的短路节点是否有效
                    disp(['选择的短路节点为:', num2str(ScNode)]);
                else
                    WarnTime = WarnTime + 1;
                    if WarnTime == 3%如果连续三次输入无效，弹出错误对话框并结束运行
                        error('输入的短路节点无效，程序终止。');
                    end
                    uiwait(warndlg('输入的短路节点无效,请重新选择'));
                    continue;%如果无效，继续循环重新输入
                end
                break;
            end 
        else
            error('短路计算数据有误，请重新运行以重新选择数据文件');
        end
    end
    %% 2.读取数据
    StartTime = datetime('now','Format','yyyy-MM-dd HH:mm:ss');
    tic;%运行计时开始
    [X1,X0,Xd2,GeneratorX2,...
    BranchNumber,GeneratorIndex,S,...
    BranchStartNode,BranchEndNode,Line,Generator] = SC_ReadData(ScData);
    %% 3.形成导纳矩阵
    [Z1,Z2,Z0,Y1,Y2,Y0] = SC_FormYZmatrix(X1,Line,GeneratorIndex,S,BranchStartNode,BranchEndNode,Xd2,GeneratorX2);
    %% 4.计算短路网络电压电流
    %三相
    [U_T3,I_T3,U_P3,I_P3,ScnodeCon3] = SC_ThreePhase(Z1,ScNode,UfBase,Transfrom120ToABC,...
                                                    BranchNumber,BranchStartNode,BranchEndNode);
    %单相
    [U_T1,I_T1,U_P1,I_P1,ScnodeCon1] = SC_SinglePhase(Z1,Z2,Z0,S,ScNode,UfBase,Transfrom120ToABC,...
                                                    NodeNumbers,BranchNumber,BranchStartNode,BranchEndNode);
    %两相
    [U_T2,I_T2,U_P2,I_P2,ScnodeCon2] = SC_TwoPhase(Z1,Z2,Z0,S,ScNode,UfBase,Transfrom120ToABC,...
                                                    NodeNumbers,BranchNumber,BranchStartNode,BranchEndNode);   
    %两相短路接地
    [U_T2G,I_T2G,U_P2G,I_P2G,ScnodeCon2G] = SC_TwoPhase_Ground(Z1,Z2,Z0,S,ScNode,UfBase,Transfrom120ToABC,...
                                                    NodeNumbers,BranchNumber,BranchStartNode,BranchEndNode);
    %% 5.输出成功计算结果
    UsedTime = toc;%运行计时结束
    TimeMessage = ['运行时长为',num2str(UsedTime),'秒'];
    disp(TimeMessage);
    SC_Printout(ScNode,U_T3,I_T3,U_P3,I_P3,ScnodeCon3,...
                U_T1,I_T1,U_P1,I_P1,ScnodeCon1,...
                U_T2,I_T2,U_P2,I_P2,ScnodeCon2,...
                U_T2G,I_T2G,U_P2G,I_P2G,ScnodeCon2G,...
                StartTime,TimeMessage,outputFile);
    DeviceInfo();%额外输出设备信息

end