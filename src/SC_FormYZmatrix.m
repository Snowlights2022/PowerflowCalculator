% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/16

function [Z1,Z2,Z0,Y1,Y2,Y0] = SC_FormYZmatrix(X1,Line,GeneratorIndex,S,BranchStartNode,BranchEndNode,Xd2,GeneratorX2)
    NodeNumbers = max(max(BranchStartNode), max(BranchEndNode));%获取节点数
%% 计算正序网络
    % 计算每条支路的正序导纳
    Branch_y1 = 1./(X1*1i); 
    Y1 = sparse(BranchStartNode, BranchEndNode, -Branch_y1, NodeNumbers, NodeNumbers) + sparse(BranchEndNode, BranchStartNode, -Branch_y1, NodeNumbers, NodeNumbers); % 非对角元
    Y1 = Y1 + sparse(BranchStartNode, BranchStartNode, Branch_y1, NodeNumbers, NodeNumbers) + sparse(BranchEndNode, BranchEndNode, Branch_y1, NodeNumbers, NodeNumbers); % 对角元
    % 计算发电机正序导纳
    Generator_y1 = 1./(Xd2*1i); 
    Y1 = Y1 + sparse(GeneratorIndex, GeneratorIndex, Generator_y1, NodeNumbers, NodeNumbers);%将发电机正序导纳加到对应节点的对角元
    Z1 = Y1 \ speye(NodeNumbers);%稀疏矩阵求逆的推荐方法
%% 计算负序网络
    % 计算每条支路的负序导纳
    Branch_y2 = Branch_y1; % 认为线路负序导纳与正序导纳相同
    Y2 = sparse(BranchStartNode, BranchEndNode, -Branch_y2, NodeNumbers, NodeNumbers) + sparse(BranchEndNode, BranchStartNode, -Branch_y2, NodeNumbers, NodeNumbers); % 非对角元
    Y2 = Y2 + sparse(BranchStartNode, BranchStartNode, Branch_y2, NodeNumbers, NodeNumbers) + sparse(BranchEndNode, BranchEndNode, Branch_y2, NodeNumbers, NodeNumbers); % 对角元
    % 计算发电机负序导纳
    Generator_y2 = 1./(GeneratorX2*1i); 
    Y2 = Y2 + sparse(GeneratorIndex, GeneratorIndex, Generator_y2, NodeNumbers, NodeNumbers);%将发电机负序导纳加到对应节点的对角元
    Z2 = Y2 \ speye(NodeNumbers);
%% 计算零序网络
    % 零序支路分类
    Line0 = Line(S==1, :); % 选取类型为1的支路（零序支路）
    Ynyn = Line(S==2, :);  % 选取类型为2的支路（Ynyn变压器）
    Ynd = Line(S==3, :);   % 选取类型为3的支路（Ynd变压器）

    % 零序支路导纳
    Branch_y0 = 1./(Line0(:,6)*1i); % 零序支路导纳
    Y0 = sparse(Line0(:,3), Line0(:,4), -Branch_y0, NodeNumbers, NodeNumbers) + sparse(Line0(:,4), Line0(:,3), -Branch_y0, NodeNumbers, NodeNumbers); % 非对角元
    Y0 = Y0 + sparse(Line0(:,3), Line0(:,3), Branch_y0, NodeNumbers, NodeNumbers) + sparse(Line0(:,4), Line0(:,4), Branch_y0, NodeNumbers, NodeNumbers); % 对角元

    % Ynyn变压器零序参数
    Ynyn_y0 = 1./(Ynyn(:,6)*1i); % Ynyn变压器零序导纳
    Y0 = Y0 + sparse(Ynyn(:,3), Ynyn(:,4), -Ynyn_y0, NodeNumbers, NodeNumbers) + sparse(Ynyn(:,4), Ynyn(:,3), -Ynyn_y0, NodeNumbers, NodeNumbers); % 非对角元
    Y0 = Y0 + sparse(Ynyn(:,3), Ynyn(:,3), Ynyn_y0, NodeNumbers, NodeNumbers) + sparse(Ynyn(:,4), Ynyn(:,4), Ynyn_y0, NodeNumbers, NodeNumbers); % 对角元

    % Ynd变压器（只考虑高压侧零序阻抗，低压侧不接地）
    Ynd_y0 = 1./(Ynd(:,6)*1i); % Ynd变压器零序导纳
    Y0 = Y0 + sparse(Ynd(:,3), Ynd(:,3), Ynd_y0, NodeNumbers, NodeNumbers); % 只加到高压侧节点的对角元

    % 发电机零序导纳
    % 发电机零序阻抗一般取无穷大，导纳为零，不再加入
    Z0 = sparse(pinv(full(Y0)));% 求零序阻抗矩阵
end 