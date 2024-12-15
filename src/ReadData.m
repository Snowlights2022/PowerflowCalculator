% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/16

%%导入原始数据
function [SB,NodeNumber,Line,Node,Gen,g,b,Balance,PVdata,PQdata] = ReadData(mpc)
 
%% 获取基准功率
SB=mpc.baseMVA; 

%% 获取母线数据
Node = full(mpc.bus); %潜在的效率问题暂时由满矩阵解决    

%% 获取节点数据，各类节点数量，便于计算分配堆栈
NodeNumber = size(mpc.bus,1);     
numPVNodes = sum(Node(:, 2) == 2); %PV节点数(计算Node中第2列等于2的元素数量，即PV节点的数量)
numPQNodes = sum(Node(:, 2) == 1); %PQ节点数(计算Node中第2列等于1的元素数量，即PV节点的数量)

%% 获取支路数据，并建立稀疏矩阵
Line = sparse(mpc.branch);  
                  
%% 获取发电机数据
Gen = sparse(mpc.gen);                        
g = size(Gen,1);                              %发电机数g
b = size(Line,1);                             %支路数b

%% 把投入运行的发电机所发出的功率加入计算
for i=1:g
    if (Gen(i,8)>0)
        Node(Gen(i,1),3) = Node(Gen(i,1),3)-Gen(i,2);
        Node(Gen(i,1),4) = Node(Gen(i,1),4)-Gen(i,3);
    end
end
Node = sparse(Node);%节点矩阵稀疏化

%% 将没有变压器的线路变比由0调整为1(也就是Line矩阵/数组中第九列元素为0时进行调整，替换为1)
Line=full(Line);
if NodeNumber<50 %节点数较少时使用数值索引
    for i=1:b
        if (Line(i,9)==0)
            Line(i,9) = 1;
        end
    end
elseif NodeNumber<100 %节点数较多时时并行处理
    parfor i=1:b
        if (Line(i,9)==0)
            Line(i,9) = 1;
        end
    end
else %节点数很多时利用向量化逻辑索引方式查找并替换Line中第9列的值为0的元素为1(类似于REGEX正则表达式) P.S.我好想念LINQ
    Line(Line(:, 9) == 0, 9) = 1;
end
Line=sparse(Line);%稀疏化

%% 获取平衡节点
Balance = 1;                           
for i=1:NodeNumber
    if (Node(i,2) == 3)
        Balance = Node(i,1);
    end
end

%% 获取PV节点的初始数据矩阵
PVdata = zeros(numPVNodes, size(Node, 2));%初始化PVdata矩阵，预分配大小
j = 1;                                
for i=1:NodeNumber
    if (Node(i,2) == 2)
        PVdata(j,:) = Node(i,:); 
        j=j+1;
    end
end
PVdata = sparse(PVdata);

%% 获取PQ节点的初始数据矩阵
PQdata = zeros(numPQNodes, size(Node, 2));%初始化PQdata矩阵，预分配大小
j = 1;                                 
for i=1:NodeNumber
    if (Node(i,2) == 1)
        PQdata(j,:) = Node(i,:); 
        j=j+1;
    end
end
PQdata = sparse(PQdata);                        


