% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/9

function [U_T,I_T,U_P,I_P,ScnodeCon] = SC_TwoPhase(Z1,Z2,Z0,S,ScNode,UfBase,Transfrom120ToABC,NodeNumbers,BranchNumber,BranchStartNode,BranchEndNode)
    %电压序分量U_T=[U1;U2;U0];%每列为一个节点的三序分量
    %电流序分量I_T=[I1;I2;I0];%每列为一个节点的三序分量
    %电压相分量（A特殊相）U_P=[UA;UB;UC];%节点按列排列，每列为一个节点的三相分量，U_P(i, j) 表示第j个节点的第i相（A/B/C）电压
    %电流相分量（A特殊相）I_P=[IA;IB;IC];%每列为一个节点的三相分量

 %% 短路节点计算（根据边界条件）
    %电流
    If1 = UfBase/(Z1(ScNode, ScNode) + Z2(ScNode, ScNode)); %正序电流计算
    If2 = -If1; %两相短路电流的边界条件
    If0 = 0;
    If_T = [If1; If2; If0];%将正序、负序、零序电流组合成序分量，三行一列
    If_P = Transfrom120ToABC * If_T;

    %电压
    Uf1 = UfBase - If1 * Z1(ScNode, ScNode); %正序电压
    Uf2 = -If2 * Z2(ScNode, ScNode);
    Uf0 = 0;
    Uf_T = [Uf1; Uf2; Uf0];
    Uf_P = Transfrom120ToABC * Uf_T;

    ScnodeCon = [If_P Uf_P; If_T Uf_T];%短路节点的电流和电压相分量，6行2列分块

%% 各节点支路计算
    U1 = zeros(NodeNumbers, 1);
    U2 = zeros(NodeNumbers, 1);
    U0 = zeros(NodeNumbers, 1);
    for k = 1:NodeNumbers
        U1(k) = UfBase - If1 * Z1(k, ScNode); % 正序
        U2(k) = -If2 * Z2(k, ScNode);         % 负序
        U0(k) = -If0 * Z0(k, ScNode);         % 零序
    end
    U_T = [U1.'; U2.'; U0.'];%每列为一个节点的三序分量
    U_P = Transfrom120ToABC * U_T;

        %电流
    I_T = zeros(3, BranchNumber);%每列为一条支路的三序分量
    for i = 1:BranchNumber
        StartNode = BranchStartNode(i);%起始节点
        EndNode = BranchEndNode(i);%终止节点
        Z1_Branch = Z1(StartNode, EndNode);%支路阻抗
        Z2_Branch = Z2(StartNode, EndNode);
        Z0_Branch = Z0(StartNode, EndNode);
        
        I1 = (U1(StartNode) - U1(EndNode)) / Z1_Branch;%正序电流
        I2 = (U2(StartNode) - U2(EndNode)) / Z2_Branch;%负序电流
        I0 = (U0(StartNode) - U0(EndNode)) / Z0_Branch;%零序电流
        
        I_T(:, i) = [I1; I2; I0]; %存入第i列
    end
    for i=1:BranchNumber
        if S(i) == 3%Ynd变压器认为一定是BranchStartNode接Yn，BranchEndNode接d，据此修正Ynd变压器零序电流
            I_T(3,i)=0;%零序电流不流通
        end
    end
    I_P = Transfrom120ToABC * I_T;%将正序、负序、零序电流转换为相分量

end
