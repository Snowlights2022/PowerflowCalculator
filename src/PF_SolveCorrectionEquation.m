% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/16

%% 修正方程求解
function [U1] = PF_SolveCorrectionEquation(Jb, Unbalance, NodeNumber, U1)

%% 将数据传输到 GPU
JbGPU = gpuArray(Jb); % 将雅克比矩阵转换为GPU数组
UnbalanceGPU = gpuArray(full(Unbalance)); % 将不平衡量转换为全向量并传输到GPU
       
%% 求解修正方程
CorrectionValue = Jb\Unbalance;%求逆矩阵和不平衡量的乘法，得到电压幅值相角的修正矩阵

ValueAngle = CorrectionValue(1:NodeNumber, 1);%电压相角的修正量
ValueMagnitude = CorrectionValue(NodeNumber+1:2*NodeNumber, 1);%电压幅值的修正量

U1Magnitude = abs(U1); % 当前电压的幅值
U1Angle = angle(U1); % 当前电压的相角 

U0 = U1Magnitude .* (1 - ValueMagnitude);%更新电压幅值
Angle = U1Angle - ValueAngle;%更新电压相角 

 %% 更新节点电压 
U1 = U0.*exp(1i.*Angle);                    %再将电压写成向量形式，用于雅克比矩阵和线路功率的计算

