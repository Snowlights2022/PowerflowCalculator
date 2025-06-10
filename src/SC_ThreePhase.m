% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/11

function [U_T,I_T,U_P,I_P,ScnodeCon] = SC_ThreePhase(Z1,ScNode,UfBase,...
                                                    Transfrom120ToABC,BranchNumber,...
                                                    BranchStartNode,BranchEndNode)
    %电压序分量U_T=[U1;U2;U0];%每列为一个节点的三序分量
    %电流序分量I_T=[I1;I2;I0];%每列为一个节点的三序分量
    %电压相分量（A特殊相）U_P=[UA;UB;UC];%节点按列排列，每列为一个节点的三相分量，U_P(i, j) 表示第j个节点的第i相（A/B/C）电压
    %电流相分量（A特殊相）I_P=[IA;IB;IC];%每列为一个节点的三相分量

%% 短路节点计算（根据边界条件）
    %电流
    If1 = UfBase/Z1(ScNode,ScNode);%正序电流
    If2 = 0;
    If0 = 0;
    If_T= [If1; If2; If0];%将正序、负序、零序电流组合成序分量，三行一列
    If_P = Transfrom120ToABC * If_T;%将正序、负序、零序电流转换为相分量，三行一列

    %电压
    Uf1 = UfBase-If1*Z1(ScNode,ScNode);%正序电压
    Uf2 = 0;
    Uf0 = 0;
    Uf_T = [Uf1; Uf2; Uf0];%将正序、负序、零序电压组合成序分量，三行一列
    Uf_P= Transfrom120ToABC * Uf_T;%将正序、负序、零序电压转换为相分量，三行一列

    ScnodeCon = [If_P Uf_P;If_T Uf_T];%短路节点的电流和电压相分量，6行2列分块

%%各节点支路计算
    %电压
    Znf = Z1(ScNode,:);%提取Z1的Znf元素列向量
    U1 = UfBase*ones(size(Znf,1),1) - If1 * Znf;%正序电压=1-Z(节点-短路点)*正序电流，结果是
    U2 = zeros(1,length(Znf));%负序零序均为零
    U0 = zeros(1,length(Znf));
    U_T = [U1; U2; U0]; %每列为一个节点的三序分量

    U_P= Transfrom120ToABC * U_T;%将正序、负序、零序电压转换为相分量，每列为一个节点的三相分量
    %UA = U_P(1, :); %取行时，第一行为所有节点的A相电压行向量
    %UB = U_P(2, :); 
    %UC = U_P(3, :); 

    %电流
    I_T = zeros(3, BranchNumber);%每列为一条支路的三序分量
    for i = 1:BranchNumber
        StartNode = BranchStartNode(i);%起始节点
        EndNode = BranchEndNode(i);%终止节点
        Z1_Branch = Z1(StartNode, EndNode);%支路阻抗
        I1 = (U1(StartNode) - U1(EndNode)) / Z1_Branch;%正序电流
        I_T(:, i) = [I1; 0; 0];%I2和I0都是零，存入第i列
    end
    I_P = Transfrom120ToABC * I_T; % 将正序、负序、零序电流转换为相分量

end