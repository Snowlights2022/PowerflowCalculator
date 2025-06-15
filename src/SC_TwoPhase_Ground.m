% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/16

function [U_T,I_T,U_P,I_P,ScnodeCon] = SC_TwoPhase_Ground(Z1,Z2,Z0,...
                                        S,ScNode,UfBase,Transform120ToAbc,...
                                        NodeNumbers,BranchStartNode,BranchEndNode)
    %电压序分量U_T=[U1;U2;U0];
    %电流序分量I_T=[I1;I2;I0];
    %电压相分量（A特殊相）U_P=[UA;UB;UC];
    %电流相分量（A特殊相）I_P=[IA;IB;IC];

%% 短路节点计算（根据边界条件）
    %电流
    %视为金属性接地，Zg为零
    Ymid= (Z2(ScNode, ScNode) + Z0(ScNode, ScNode))^-1;%中间变量
    If1 = UfBase / (Z1(ScNode, ScNode) + Ymid * Z2(ScNode, ScNode) * Z0(ScNode, ScNode));%正序电流计算
    If2 = -If1 * Z0(ScNode,ScNode) * Ymid;%两相短路电流的边界条件
    If0 = -If1 * Z2(ScNode,ScNode) * Ymid;
    If_T = [If1; If2; If0];%将正序、负序、零序电流组合成序分量，三行一列
    If_P = Transform120ToAbc * If_T;

    %电压
    Uf1 = UfBase - If1 * Z1(ScNode, ScNode);%正序电压
    Uf2 = -If2 * Z2(ScNode, ScNode);
    Uf0 = -If0 * Z0(ScNode, ScNode);
    Uf_T = [Uf1; Uf2; Uf0];%将正序、负序、零序电压组合成序分量，三行一列
    Uf_P = Transform120ToAbc * Uf_T;

    ScnodeCon = [If_P Uf_P; If_T Uf_T];%短路节点的电流和电压相分量，6行2列分块

%% 各节点支路计算
    %电压
    U1 = zeros(NodeNumbers, 1);
    U2 = zeros(NodeNumbers, 1);
    U0 = zeros(NodeNumbers, 1);
    for k = 1:NodeNumbers
        U1(k) = UfBase - If1 * Z1(k, ScNode);
        U2(k) = -If2 * Z2(k, ScNode);
        U0(k) = -If0 * Z0(k, ScNode);
    end
    U_T = [U1.'; U2.'; U0.'];%每列为一个节点的三序分量
    U_P = Transform120ToAbc * U_T;

    %电流
    % 矢量化实现
    % 取出每条支路的起止节点电压
    U1_start = U1(BranchStartNode);%支路起点正序电压列向量
    U1_end = U1(BranchEndNode);%支路终点正序电压列向量
    U2_start = U2(BranchStartNode); U2_end = U2(BranchEndNode);
    U0_start = U0(BranchStartNode); U0_end = U0(BranchEndNode);
    %使用sub2ind函数将二维索引转换为按列优先排序的(单一)线性索引，从而直接进行批量更新
    Z1_branch = Z1(sub2ind(size(Z1), BranchStartNode, BranchEndNode));
    Z2_branch = Z2(sub2ind(size(Z2), BranchStartNode, BranchEndNode));
    Z0_branch = Z0(sub2ind(size(Z0), BranchStartNode, BranchEndNode));
    %计算每条支路的三序电流
    I1 = (U1_start - U1_end) ./ Z1_branch;%正序电流
    I2 = (U2_start - U2_end) ./ Z2_branch;%负序电流
    I0 = (U0_start - U0_end) ./ Z0_branch;%零序电流
    I0(S==3) = 0;%对Ynd变压器支路（S==3）零序电流置零
    I_T = [I1.'; I2.'; I0.'];%汇总支路三序电流
    I_P = Transform120ToAbc * I_T;

end