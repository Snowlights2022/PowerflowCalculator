% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/17

function [P_Unbalance,Q_Unbalance,MaxUnbalance,Unbalance] = CalculateDeltaPQ(Y,U1,Balance,P,Q,PVnode)

    S = sparse(diag(U1)*conj(Y*U1));
    
    P_Unbalance = P-real(S);                        %取复功率实部计算有功不平衡量
    P_Unbalance(Balance,1) = 0;                     %将平衡节点的有功不平衡量置为零
    P_Unbalance = sparse(P_Unbalance);

    Q_Unbalance = Q-imag(S);                        %取复功率虚部计算无功不平衡量
    Q_Unbalance(Balance,1)=0;                       %将平衡节点的无功不平衡量置为零
    Q_Unbalance(PVnode) = 0;                        %将PV节点的无功不平衡量置为零
    Q_Unbalance = sparse(Q_Unbalance);
%% 计算潮流方程不平衡量
    Unbalance = sparse([P_Unbalance;Q_Unbalance]);  %将有功无功不平衡量合为一个矩阵,为后面求取修正量做准备
    MaxUnbalance = max(abs(Unbalance));             %判断最大不平衡量，作为停止迭代的条件
    


