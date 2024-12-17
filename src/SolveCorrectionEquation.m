% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/17

%% 修正方程求解
function [U1] = SolveCorrectionEquation(Jb,Unbalance,NodeNumber,U1)
%% 求解修正方程
CorrectionValue = Jb\Unbalance;%求逆矩阵和不平衡量的乘法，得到电压幅值相角的修正矩阵

ValueAngle = CorrectionValue(1:NodeNumber, 1);%电压相角的修正量
ValueMagnitude = CorrectionValue(NodeNumber+1:2*NodeNumber, 1);%电压幅值的修正量

U1Magnitude = abs(U1); % 当前电压的幅值
U1Angle = angle(U1); % 当前电压的相角 

U0 = U1Magnitude .* (1 - ValueMagnitude);%更新电压幅值
Angle = U1Angle - ValueAngle;%更新电压相角 

%% 更新节点电压 
U1 = U0.*exp(1i.*Angle);                    %再将电压写成指数形式，用于雅克比矩阵和线路功率的计算

