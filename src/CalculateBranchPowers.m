% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/16

function [S_balance,U_ij,S_ij] = CalculateBranchPowers(Y,Balance,U1,SB,Line,kGij,kBij,n,Ga1,Ba1,Ba2,Ga2)
%% 计算平衡节点功率
Y_balance = Y(Balance,:);                                        %获取系统的平衡节点号
S_balance = U1(Balance)*conj(Y_balance)*conj(U1)*SB;             %计算平衡节点功率
%% 计算线路传输功率

y_ij = sparse(Line(:,1),Line(:,2),kGij+1i*kBij,n,n);%拿出用于计算线路之间的导纳参数y_ij（即对角线上的数值为0)
y_ij = y_ij+sparse(Line(:,2),Line(:,1),kGij+1i*kBij,n,n);

y_i0 = sparse(Line(:,1),Line(:,2),Ga1+1i.*(Line(:,5)+Ba1),n,n);%对地导纳y_i0       

y_j0 = sparse(Line(:,2),Line(:,1),Ga2+1i.*(Line(:,5)+Ba2),n,n);%对地导纳y_j0

%% 计算线路功率

% 计算 U_ij
U_diag = diag(U1); % 提取 U1 的对角线元素
U1_conj = conj(U1); %计算U1的共轭
U_ij = sparse(U_diag * ones(n, n) - ones(n, n) * U_diag); % 计算 U_ij

% 计算 S_ij
S_ij = (U_diag * conj(y_ij) .* conj(U_ij)) .* SB; % 计算S_ij的第一部分
S_ij = S_ij + U_diag * (repmat(U1_conj, 1, n) .* conj(y_i0)) .* SB; % 计算 S_ij 的第二部分
S_ij = S_ij + U_diag * (repmat(U1_conj, 1, n) .* conj(y_j0)) .* SB; % 计算 S_ij 的第三部分

S_ij = sparse(S_ij);%将 S_ij 转换为稀疏矩阵