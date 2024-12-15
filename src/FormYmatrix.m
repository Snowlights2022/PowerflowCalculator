% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/15

%% 形成节点导纳矩阵
function [Gij,Bij,kGij,kBij,Ga1,Ga2,Ba1,Ba2,G,B,Y] = FormYmatrix(Line,n,Node,SB) 

%% 处理传输线路
%选择Line的第3列表示传输线路的电阻r,x同理
r = Line(:, 3); % 传输线路的电阻
x = Line(:, 4); % 传输线路的电抗
Mid = r .* r + x .* x; % 分母：电阻平方和电抗平方的和
Gij = r ./ Mid; % 电导 Gij = r / (r^2 + x^2)
Bij = -x ./ Mid; % 电纳 Bij = -x / (r^2 + x^2)

%% 处理变压器支路
kGij = Line(:,9).\Gij;                                              %计算变压器等效电路对应节点的互导纳
kBij = Line(:,9).\Bij;  
Ga1 =  Gij.*(1-Line(:,9))./(Line(:,9).*Line(:,9));                  %计算变压器等效电路对应节点的自导纳
Ga2 =  Gij.*(Line(:,9)-1)./Line(:,9);
Ba1 =  Bij.*(1-Line(:,9))./(Line(:,9).*Line(:,9));
Ba2 =  Bij.*(Line(:,9)-1)./Line(:,9);

%% 计算电导矩阵
G = sparse(Line(:,1),Line(:,2),-kGij,n,n);          %形成节点电导矩阵的上三角
G = G+sparse(Line(:,2),Line(:,1),-kGij,n,n);        %下三角(导纳阵对称Gij = Gji)
G = G+sparse(Line(:,1),Line(:,1),kGij+Ga1,n,n);     %计算G(i,i)
G = G+sparse(Line(:,2),Line(:,2),kGij+Ga2,n,n);     %计算G(j,j)

%% 计算电纳矩阵
B = sparse(Line(:,1),Line(:,2),-kBij,n,n);          %形成节点电纳矩阵的上三角
B = B+sparse(Line(:,2),Line(:,1),-kBij,n,n);        %下三角(导纳阵对称Bij = Bji)
B = B+sparse(Line(:,1),Line(:,1),Ba1+kBij+Line(:,5)./2,n,n);%计算B(i,i)
B = B+sparse(Line(:,2),Line(:,2),Ba2+kBij+Line(:,5)./2,n,n);%计算B(j,j)

%% 加上节点的对地支路导纳
G = G+diag(Node(:,5)./SB);
B = B+diag(Node(:,6)./SB);

%% 得到导纳矩阵
Y = G + 1i*B;

