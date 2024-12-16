% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/16

%% 修正方程求解
function [U1] = SolveCorrectionEquation(Jb, Unbalance, NodeNumber, U1)

%% 将数据传输到 GPU
JbGPU = gpuArray(Jb); % 将雅克比矩阵转换为GPU数组
UnbalanceGPU = gpuArray(full(Unbalance)); % 将不平衡量转换为全向量并传输到GPU
       
%% 求解修正方程
CorrectionvalueGPU = JbGPU \ UnbalanceGPU; % 求逆矩阵和不平衡量的乘法，得到电压幅值相角的修正矩阵
       
%% 提取修正量
ValueAngleGPU = CorrectionvalueGPU(1:NodeNumber, 1); % 电压相角的修正量
ValueMagnitudeGPU = CorrectionvalueGPU(NodeNumber+1:2*NodeNumber, 1); % 电压幅值的修正量
       
%% 计算当前电压的幅值和相角
U1MagnitudeGPU = abs(U1); % 当前电压的幅值
U1AngleGPU = angle(U1); % 当前电压的相角
       
U0GPU = U1MagnitudeGPU .* (1 - ValueMagnitudeGPU); % 对电压幅值进行修正
AngleGPU = U1AngleGPU - ValueAngleGPU; % 对电压相角进行修正
       
%% 更新节点电压 
U1GPU = U0GPU .* exp(1i .* AngleGPU); % 再将电压写成向量形式，用于雅克比矩阵和线路功率的计算
       
%% 将结果传回 CPU
U1 = gather(U1GPU); % 将GPU数组转换为CPU数组