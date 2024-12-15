% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/15

function [unbalance_P,unbalance_Q,maxunb,unbalance] = CalculateDeltaPQ(Y,U1,Balance,P,Q,PVnode)

    S = sparse(diag(U1)*conj(Y*U1));
    unbalance_P = P-real(S);                        %取复功率实部计算有功不平衡量
    unbalance_Q = Q-imag(S);                        %取复功率虚部计算无功不平衡量
    unbalance_P(Balance,1) = 0;                     %将平衡节点的有功不平衡量置为零
    unbalance_P = sparse(unbalance_P);
    unbalance_Q(Balance,1)=0;                       %将平衡节点的无功不平衡量置为零
    unbalance_Q = sparse(unbalance_Q);
    unbalance_Q(PVnode) = 0;                        %将PV节点的无功不平衡量置为零
    unbalance_Q = sparse(unbalance_Q);
%% 计算潮流方程不平衡量
    unbalance = sparse([unbalance_P;unbalance_Q]);  
    %将有功无功不平衡量合为一个矩阵,为后面求取修正量做准备
    maxunb = max(abs(unbalance));                   %判断最大不平衡量，作为停止迭代的条件
    


