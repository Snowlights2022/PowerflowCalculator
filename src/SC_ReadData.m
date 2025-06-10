% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/9

function [X1,X0,Xd2,GeneratorX2,BranchNumber,...
        GeneratorIndex,S,...
        BranchStartNode,BranchEndNode,Line,Generator] = SC_ReadData(ScData)
% X1,X0,Xd2,GeneratorX2 支路正序电抗、支路零序电抗、发电机直轴次暂态电抗、发电机负序电抗
% BranchNumber 支路数量
% GeneratorIndex 发电机连接的节点编号
% S 支路类型
% BranchStartNode 支路起点节点编号
% BranchEndNode 支路终点节点编号
% Line 支路数据矩阵
% Generator 发电机参数矩阵

Line = ScData.line; % 从输入结构体ScData中提取支路数据

%% 支路数据
BranchNumber = size(Line, 1);   % 支路数量
S = Line(:,2);                  % 支路类型，取Line矩阵的第2列（如线路、变压器类型等）
BranchStartNode = Line(:,3);    % 支路起点节点编号，取Line矩阵的第3列
BranchEndNode = Line(:,4);      % 支路终点节点编号，取Line矩阵的第4列
X1 = Line(:,5);                 % 支路正序电抗，取Line矩阵的第5列
X0 = Line(:,6);                 % 支路零序电抗，取Line矩阵的第6列
%% 发电机参数
Generator = ScData.gen;         % 从输入结构体ScData中提取发电机参数
GeneratorIndex = Generator(:,1);% 发电机连接的节点编号，取Generator矩阵的第1列
Xd2 = Generator(:,2);           % 发电机直轴次暂态电抗，取Generator矩阵的第2列
GeneratorX2 = Generator(:,3);   % 发电机负序电抗，取Generator矩阵的第3列

end