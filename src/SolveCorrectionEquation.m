function [U1] = SolveCorrectionEquation(Jb,unbalance,n,U1)
%% 求解修正方程
correction = Jb\unbalance;                  %求逆矩阵和不平衡量的乘法，得到电压幅值相角的修正矩阵                      
        %根据课本130页4-44，写成△x=J/△f的形式
        U0 = abs(U1)-correction(n+1:2*n,1).*abs(U1);  
        %对电压幅值进行修正，由于采用极坐标形式，故修正量应为△U/U的形式，在这里还要乘回U
        Angle = angle(U1)-correction(1:n,1);        %对电压相角进行修正
 %% 更新节点电压 
        U1 = U0.*exp(1i.*Angle);                    %再将电压写成向量形式，用于雅克比矩阵和线路功率的计算

