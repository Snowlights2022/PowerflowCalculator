% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/15

function [S_balance,U_ij,S_ij] = CalculateBranchPowers(Y,Balance,U1,SB,Line,kGij,kBij,n,Ga1,Ba1,Ba2,Ga2)
%% 计算平衡节点功率
Y_balance = Y(Balance,:);                                        %获取系统的平衡节点号
S_balance = U1(Balance)*conj(Y_balance)*conj(U1)*SB;             %计算平衡节点功率
%% 计算线路传输功率

%拿出用于计算线路之间的导纳参数y_ij（即对角线上的数值为0)
y_ij = sparse(Line(:,1),Line(:,2),kGij+1i*kBij,n,n);
y_ij = y_ij+sparse(Line(:,2),Line(:,1),kGij+1i*kBij,n,n);
%y_i0
y_i0 = sparse(Line(:,1),Line(:,2),Ga1+1i.*(Line(:,5)+Ba1),n,n);        
%y_j0
y_j0 = sparse(Line(:,2),Line(:,1),Ga2+1i.*(Line(:,5)+Ba2),n,n);        
%S_ij = Ui[conj(Ui)*conj(yi0)+conj(Uij)*conj(yij)]

%计算线路功率
U_ij = sparse (diag(U1)*ones(n,n)-ones(n,n)*diag(U1));
S_ij = sparse (diag(U1)*conj(y_ij).*conj(U_ij));
S_ij = S_ij + diag(U1)*(repmat(conj(U1),1,n).*conj(y_i0));
S_ij = S_ij + diag(U1)*(repmat(conj(U1),1,n).*conj(y_j0));
S_ij = sparse(S_ij);
