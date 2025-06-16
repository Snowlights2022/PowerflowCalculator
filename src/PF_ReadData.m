% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/8

%%导入原始数据
function [SB,NodeNumber,Line,Node,Gen,g,b,Balance,PVdata,PQdata] = PF_ReadData(mpc)
 
%% 获取基准功率
SB=mpc.baseMVA; 

%% 获取母线数据
Node = sparse(mpc.bus);    

%% 获取节点数据
NodeNumber = size(mpc.bus,1);%获取母线数据矩阵的行数，即节点数    
%PVNumber = sum(Node(:, 2) == 2); %PV节点数(计算Node中第2列等于2的元素数量，即PV节点的数量)
%PQNumber = sum(Node(:, 2) == 1); %PQ节点数(计算Node中第2列等于1的元素数量，即PV节点的数量)

%% 获取支路数据，并建立稀疏矩阵
Line = sparse(mpc.branch);  
                  
%% 获取发电机数据
Gen = sparse(mpc.gen);                        
g = size(Gen,1);                              %发电机数g
b = size(Line,1);                             %支路数b

%% 把投入运行的发电机所发出的功率加入计算
if NodeNumber>1000
    %逻辑索引算法查找(使用矢量化操作来更新节点的有功功率和无功功率)，2383wp样例0.078285s
    GeneratorRunningindex = Gen(:,8) > 0;  %筛选出运行中的发电机，第八列大于零即为正在运行
    RunningGenerator = Gen(GeneratorRunningindex, :);  %获取运行中的发电机数据
    %使用sub2ind函数将二维索引转换为按列优先排序的(单一)线性索引，从而直接对Node进行批量更新，避免逐元素更新
    Node(sub2ind(size(Node), RunningGenerator(:,1), repmat(3, size(RunningGenerator, 1), 1))) = ... %Node(sub2mid(size(Node),i,j)，i=RunningGenerator，j=repmat(3, size(RunningGenerator, 1), 1)
        Node(sub2ind(size(Node), RunningGenerator(:,1), repmat(3, size(RunningGenerator, 1), 1))) - RunningGenerator(:,2);%线性索引更新有功功率

    Node(sub2ind(size(Node), RunningGenerator(:,1), repmat(4, size(RunningGenerator, 1), 1))) = ...%创建一个与RunningGenerator的行数相同的列向量，所有元素为4，表示节点数据矩阵Node的第4列(无功功率)
        Node(sub2ind(size(Node), RunningGenerator(:,1), repmat(4, size(RunningGenerator, 1), 1))) - RunningGenerator(:,3);
else 
    %节点数较少时使用for循环
    %算法for循环，2383wp样例-0.02s
    Node=full(Node);%提高索引循环速度
    for i=1:g
        if (Gen(i,8)>0)
            Node(Gen(i,1),3) = Node(Gen(i,1),3)-Gen(i,2);
            Node(Gen(i,1),4) = Node(Gen(i,1),4)-Gen(i,3);
        end
    end
    Node = sparse(Node);%节点矩阵还原稀疏化
end

%% 将没有变压器的线路变比由0调整为1(也就是Line矩阵/数组中第九列元素为0时进行调整，替换为1)
Line(Line(:, 9) == 0, 9) = 1;

%% 获取平衡节点
%Balance = 1;                           
%for i=1:NodeNumber
%    if (Node(i,2) == 3)
%        Balance = Node(i,1);
%    end
%end
Balance = find(Node(:, 2) == 3, 1);

%% 获取PV节点的初始数据矩阵
%PVdata = zeros(PVNumber, size(Node, 2));%初始化PVdata矩阵，预分配大小
%j = 1;                                
%for i=1:NodeNumber
%    if (Node(i,2) == 2)
%        PVdata(j,:) = Node(i,:); 
%        j=j+1;
%   end
%end
%PVdata = sparse(PVdata);
PVdata = sparse(Node(Node(:, 2) == 2, :));


%% 获取PQ节点的初始数据矩阵
%PQdata = zeros(PQNumber, size(Node, 2));%初始化PQdata矩阵，预分配大小
%j = 1;                                 
%for i=1:NodeNumber
%    if (Node(i,2) == 1)
%        PQdata(j,:) = Node(i,:); 
%        j=j+1;
%    end
%end
%PQdata = sparse(PQdata);                        
PQdata = sparse(Node(Node(:, 2) == 1, :));