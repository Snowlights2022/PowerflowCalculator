% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/16

%% 0.计算参数准备(算例选择)
clc;clear;
[file, path] = uigetfile('*.*', '选择一个数据文件');
if isequal(file, 0)
    disp('取消了文件选择');
else
    [~, name, ~] = fileparts(file);%获取文件名

    addpath(path);%为调用函数准备路径
    mpc = feval(name); %调用函数并获取 mpc 结构体
    rmpath(path);

    disp(['选择了文件:', fullfile(path, file)]);
    if isfield(mpc,'baseMVA')%检查mpc变量是否包含基本属性
        disp('mpc变量已成功加载');
    else
        error('mpc变量有误，请重新运行以重新选择数据文件');
    end
end

% 使用 inputdlg 函数创建输入对话框
Prompt = {'允许最大迭代次数:', '目标迭代精度:'};
DialogTitle = '输入参数';
DPI = [1 10];
DefaultInput = {'30', '1e-10'};
Answer = inputdlg(Prompt, DialogTitle, DPI, DefaultInput);

% 将用户输入转换为数值
k_max = uint32(str2double(Answer{1}));
Tolrance = str2double(Answer{2});

tic;%运行计时开始

%% 1.读取数据
[SB,NodeNumbers,Line,Node,Gen,g,b,Balance,PVdata,PQdata] = ReadData(mpc);

%% 2.形成导纳矩阵
[Gij,Bij,kGij,kBij,Ga1,Ga2,Ba1,Ba2,G,B,Y] = FormYmatrix(Line,NodeNumbers,Node,SB);

%% 3.初始化
PVnode = PVdata(:,1);                                %提取系统的PV节点标号
gen_node = Gen(:,1);                                 %获取GenData中的PV和平衡节点号
U0 = ones(NodeNumbers,1);                                      %除了PV和平衡外平启动电压幅值取1
U0(gen_node) = Gen(:,6);                             %将平衡节点与PV节点的电压赋值
Angle = sparse(zeros(NodeNumbers,1));                          %启动电压相角取0
Angle(Balance,1) = deg2rad(Node(Balance,9));
P = sparse(PQdata(:,1),1,-PQdata(:,3)/SB,NodeNumbers,1);       %公式P = Pg - Pd
P = P+sparse(PVdata(:,1),1,-PVdata(:,3)/SB,NodeNumbers,1);     %公式Q = Qg -Qd
Q = sparse(PQdata(:,1),1,-PQdata(:,4)/SB,NodeNumbers,1);
U1 = U0.*exp(1i.*Angle);

%% 4.计算不平衡量
for k = 1:k_max
    [unbalance_P,unbalance_Q,maxunb,unbalance] = CalculateDeltaPQ(Y,U1,Balance,P,Q,PVnode);
    if maxunb<Tolrance                                                       
        %判断最大不平衡量是否小于精确度，小于即可结束迭代
       disp('此次计算收敛');
       disp(['计算的节点数为：',num2str(NodeNumbers),'  个']);
       disp(['潮流迭代的次数为：',num2str(k),'  次']);
       disp('最大不平衡量为: ');disp(maxunb)
       break;
    else%否则继续迭代

%% 5.计算和修正雅可比矩阵
      [Jb] = FormJacobi(U1,PVnode,Balance,Y,NodeNumbers);

%% 6、求解潮流修正量  
      [U1] = SolveCorrectionEquation(Jb,unbalance,NodeNumbers,U1);
    end
end
if k>k_max                                                        
    %如果迭代次数达到最大迭代次数，则在规定的条件下无法收敛
    disp('此次潮流计算不收敛');
    disp(['潮流迭代的次数为：',num2str(k),'次']);
end

UsedTime = toc;%运行计时结束
TimeMessage = ['运行时长为',num2str(UsedTime),'秒'];

%% 7、计算支路功率
 [S_balance,U_ij,S_ij] = CalculateBranchPowers(Y,Balance,U1,SB,Line,kGij,kBij,NodeNumbers,Ga1,Ba1,Ba2,Ga2);

%% 8、输出结果

 %计算平衡节点、线路功率、线路损耗
 volts=([full(abs(U1))      full(convert2deg(angle(U1)))]);
 slack_power=S_balance;
 trans_powers=S_ij;
 S_lose = sparse(S_ij + S_ij.');

 %输出
 disp('节点电压幅值       节点电压角度');disp(volts);
 disp('平衡节点功率');disp(slack_power); 
 disp('线路功率');disp(trans_powers);
 disp('线路损耗');disp(S_lose);
 disp(['计算的节点数为：',num2str(NodeNumbers),'个']);
 disp(['潮流迭代的次数为：',num2str(k),'次']);
 disp(TimeMessage);