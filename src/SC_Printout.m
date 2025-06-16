% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/9

function  SC_Printout(ScNode,U_T3,I_T3,U_P3,I_P3,ScnodeCon3,...
                    U_T1,I_T1,U_P1,I_P1,ScnodeCon1,...
                    U_T2,I_T2,U_P2,I_P2,ScnodeCon2,...
                    U_T2G,I_T2G,U_P2G,I_P2G,ScnodeCon2G,...
                    StartTime,TimeMessage,outputFile)

    NodeNumbers = size(U_T3, 2);%%size(A,2)返回A的列数，刚好是需要的节点数量
    BranchNumbers = size(ScnodeCon3, 1);%%短路网络的支路数
    %将稀疏矩阵转换为全矩阵(错误使用 fprintf ,函数没有定义为支持稀疏输入。)
    U_T3 = full(U_T3);I_T3 = full(I_T3);U_P3 = full(U_P3);I_P3 = full(I_P3);
    U_T1 = full(U_T1);I_T1 = full(I_T1);U_P1 = full(U_P1);I_P1 = full(I_P1);
    U_T2 = full(U_T2);I_T2 = full(I_T2);U_P2 = full(U_P2);I_P2 = full(I_P2);
    U_T2G = full(U_T2G);I_T2G = full(I_T2G);U_P2G = full(U_P2G);I_P2G = full(I_P2G);
    ScnodeCon3 = full(ScnodeCon3);ScnodeCon1 = full(ScnodeCon1);
    ScnodeCon2 = full(ScnodeCon2);ScnodeCon2G = full(ScnodeCon2G);

    %%命令行输出
    %三相短路
    disp('三相短路ABC相电压（p.u）'); 
    disp(U_P3);
    disp('三相短路120序电压（p.u）');
    disp(U_T3);
    disp('三相短路ABC相电流（p.u）'); 
    disp(I_P3);
    disp('三相短路120序电流（p.u）');
    disp(I_T3);

    %单相短路
    disp('单相短路ABC相电压（p.u）');
    disp(U_P1);
    disp('单相短路120序电压（p.u）');
    disp(U_T1);
    disp('单相短路ABC相电流（p.u）');
    disp(I_P1);
    disp('单相短路120序电流（p.u）');
    disp(I_T1);

    %两相短路
    disp('两相短路ABC相电压（p.u）');
    disp(U_P2);
    disp('两相短路120序电压（p.u）');
    disp(U_T2);
    disp('两相短路ABC相电流（p.u）');
    disp(I_P2);
    disp('两相短路120序电流（p.u）');
    disp(I_T2);

    %两相短路接地
    disp('两相短路接地ABC相电压（p.u）');
    disp(U_P2G);
    disp('两相短路接地120序电压（p.u）');
    disp(U_T2G);
    disp('两相短路接地ABC相电流（p.u）');
    disp(I_P2G);
    disp('两相短路接地120序电流（p.u）');
    disp(I_T2G);

    %计算环境说明
    disp('短路网络计算完毕');
    disp(['计算始于:', char(StartTime)]);   
    disp(['短路节点为:', num2str(ScNode)]);
    disp(['计算的节点数为：', num2str(NodeNumbers), '个']);
    disp(['系统支路数为：', num2str(BranchNumbers), '条']);
    disp(TimeMessage);

    %输出短路点情况
    %三相短路
    If_P3 = ScnodeCon3(1:3, 1);
    Uf_P3 = ScnodeCon3(1:3, 2);
    If_T3 = ScnodeCon3(4:6, 1);
    Uf_T3 = ScnodeCon3(4:6, 2);
    disp('f(3)短路节点三序电压（p.u）');
    disp(Uf_T3);
    disp('f(3)短路节点三序电流（p.u）');
    disp(If_T3);
    disp('f(3)短路节点ABC相电压（p.u）');
    disp(Uf_P3);
    disp('f(3)短路节点ABC相电流（p.u）');
    disp(If_P3);
    %单相短路
    If_P1 = ScnodeCon1(1:3, 1);
    Uf_P1 = ScnodeCon1(1:3, 2);
    If_T1 = ScnodeCon1(4:6, 1);
    Uf_T1 = ScnodeCon1(4:6, 2);
    disp('f(1)短路节点三序电压（p.u）');
    disp(Uf_T1);
    disp('f(1)短路节点三序电流（p.u）');
    disp(If_T1);
    disp('f(1)短路节点ABC相电压（p.u）');
    disp(Uf_P1);
    disp('f(1)短路节点ABC相电流（p.u）');
    disp(If_P1);
    %两相短路
    If_P2 = ScnodeCon2(1:3, 1);
    Uf_P2 = ScnodeCon2(1:3, 2);
    If_T2 = ScnodeCon2(4:6, 1);
    Uf_T2 = ScnodeCon2(4:6, 2);
    disp('f(2)短路节点三序电压（p.u）');
    disp(Uf_T2);
    disp('f(2)短路节点三序电流（p.u）');
    disp(If_T2);
    disp('f(2)短路节点ABC相电压（p.u）');
    disp(Uf_P2);
    disp('f(2)短路节点ABC相电流（p.u）');
    disp(If_P2);
    %两相短路接地
    If_P2G = ScnodeCon2G(1:3, 1);
    Uf_P2G = ScnodeCon2G(1:3, 2);
    If_T2G = ScnodeCon2G(4:6, 1);
    Uf_T2G = ScnodeCon2G(4:6, 2);
    disp('f(1.1)短路节点三序电压（p.u）');
    disp(Uf_T2G);
    disp('f(1.1)短路节点三序电流（p.u）');
    disp(If_T2G);
    disp('f(1.1)短路节点ABC相电压（p.u）');
    disp(Uf_P2G);
    disp('f(1.1)短路节点ABC相电流（p.u）');
    disp(If_P2G);

    %%文件输出
    %计算环境说明
    fileID = fopen(outputFile, 'a');
    fprintf(fileID, ['\n', '计算类型为短路计算','\n']);
    fprintf(fileID, ['计算始于', char(StartTime), '\n']);
    fprintf(fileID, '短路节点为: %d\n', ScNode);
    fprintf(fileID, '计算的节点数为：%d 个\n', NodeNumbers);
    fprintf(fileID, '系统支路数为：%d 条\n', BranchNumbers);
    fprintf(fileID, '%s\n', TimeMessage);
    %三相短路
    fprintf(fileID, '三相短路ABC相电压（p.u）\n');%三相短路ABC相电压按列输出，每列一行
    for j = 1:size(U_P3,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(U_P3(1,j)), imag(U_P3(1,j)), real(U_P3(2,j)), imag(U_P3(2,j)), real(U_P3(3,j)), imag(U_P3(3,j)));
    end
    fprintf(fileID, '三相短路120序电压（p.u）\n');
    for j = 1:size(U_T3,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(U_T3(1,j)), imag(U_T3(1,j)), real(U_T3(2,j)), imag(U_T3(2,j)), real(U_T3(3,j)), imag(U_T3(3,j)));
    end
    fprintf(fileID, '三相短路ABC相电流（p.u）\n');
    for j = 1:size(I_P3,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(I_P3(1,j)), imag(I_P3(1,j)), real(I_P3(2,j)), imag(I_P3(2,j)), real(I_P3(3,j)), imag(I_P3(3,j)));
    end
    fprintf(fileID, '三相短路120序电流（p.u）\n');
    for j = 1:size(I_T3,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(I_T3(1,j)), imag(I_T3(1,j)), real(I_T3(2,j)), imag(I_T3(2,j)), real(I_T3(3,j)), imag(I_T3(3,j)));
    end
    fprintf(fileID, 'f(3)短路节点ABC相电压 ');
    for k = 1:length(Uf_P3)
        fprintf(fileID, '%f %+fi ', real(Uf_P3(k)), imag(Uf_P3(k)));
    end
    fprintf(fileID, '\n'); 
    fprintf(fileID, 'f(3)短路节点ABC相电流 ');
    for k = 1:length(If_P3)
        fprintf(fileID, '%f %+fi ', real(If_P3(k)), imag(If_P3(k)));
    end
    fprintf(fileID, '\n');
    fprintf(fileID, 'f(3)短路节点120序电压 ');
    for k = 1:length(Uf_T3)
        fprintf(fileID, '%f %+fi ', real(Uf_T3(k)), imag(Uf_T3(k)));
    end
    fprintf(fileID, '\n');
    fprintf(fileID, 'f(3)短路节点120序电流 ');
    for k = 1:length(If_T3)
        fprintf(fileID, '%f %+fi ', real(If_T3(k)), imag(If_T3(k)));
    end
    fprintf(fileID, '\n');

    %单相短路
    fprintf(fileID, '单相短路ABC相电压（p.u）\n');
    for j = 1:size(U_P1,2)
        fprintf(fileID, '%f %+fi    %f %+fi     %f %+fi\n', real(U_P1(1,j)), imag(U_P1(1,j)), real(U_P1(2,j)), imag(U_P1(2,j)), real(U_P1(3,j)), imag(U_P1(3,j)));
    end
    fprintf(fileID, '单相短路120序电压（p.u）\n');
    for j = 1:size(U_T1,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(U_T1(1,j)), imag(U_T1(1,j)), real(U_T1(2,j)), imag(U_T1(2,j)), real(U_T1(3,j)), imag(U_T1(3,j)));
    end
    fprintf(fileID, '单相短路ABC相电流（p.u）\n');
    for j = 1:size(I_P1,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(I_P1(1,j)), imag(I_P1(1,j)), real(I_P1(2,j)), imag(I_P1(2,j)), real(I_P1(3,j)), imag(I_P1(3,j)));
    end
    fprintf(fileID, '单相短路120序电流（p.u）\n');
    for j = 1:size(I_T1,2)
        fprintf(fileID, '%f %+fi    %f %+fi     %f %+fi\n', real(I_T1(1,j)), imag(I_T1(1,j)), real(I_T1(2,j)), imag(I_T1(2,j)), real(I_T1(3,j)), imag(I_T1(3,j)));
    end
    fprintf(fileID, 'f(1)短路节点ABC相电压 ');
    for k = 1:length(Uf_P1)
        fprintf(fileID, '%f %+fi ', real(Uf_P1(k)), imag(Uf_P1(k)));
    end
    fprintf(fileID, '\n'); 
    fprintf(fileID, 'f(1)短路节点ABC相电流 ');
    for k = 1:length(If_P1)
        fprintf(fileID, '%f %+fi ', real(If_P1(k)), imag(If_P1(k)));
    end
    fprintf(fileID, '\n');
    fprintf(fileID, 'f(1)短路节点120序电压 ');
    for k = 1:length(Uf_T1)
        fprintf(fileID, '%f %+fi ', real(Uf_T1(k)), imag(Uf_T1(k)));
    end
    fprintf(fileID, '\n');
    fprintf(fileID, 'f(1)短路节点120序电流 ');
    for k = 1:length(If_T1)
        fprintf(fileID, '%f %+fi ', real(If_T1(k)), imag(If_T1(k)));
    end
    fprintf(fileID, '\n');

    %两相短路
    fprintf(fileID, '两相短路ABC相电压（p.u）\n');
    for j = 1:size(U_P2,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(U_P2(1,j)), imag(U_P2(1,j)), real(U_P2(2,j)), imag(U_P2(2,j)), real(U_P2(3,j)), imag(U_P2(3,j)));
    end
    fprintf(fileID, '两相短路120序电压（p.u）\n');
    for j = 1:size(U_T2,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(U_T2(1,j)), imag(U_T2(1,j)), real(U_T2(2,j)), imag(U_T2(2,j)), real(U_T2(3,j)), imag(U_T2(3,j)));
    end
    fprintf(fileID, '两相短路ABC相电流（p.u）\n');
    for j = 1:size(I_P2,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(I_P2(1,j)), imag(I_P2(1,j)), real(I_P2(2,j)), imag(I_P2(2,j)), real(I_P2(3,j)), imag(I_P2(3,j)));
    end
    fprintf(fileID, '两相短路120序电流（p.u）\n');
    for j = 1:size(I_T2,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(I_T2(1,j)), imag(I_T2(1,j)), real(I_T2(2,j)), imag(I_T2(2,j)), real(I_T2(3,j)), imag(I_T2(3,j)));
    end
    fprintf(fileID, 'f(2)短路节点ABC相电压 ');
    for k = 1:length(Uf_P2)
        fprintf(fileID, '%f %+fi ', real(Uf_P2(k)), imag(Uf_P2(k)));
    end
    fprintf(fileID, '\n'); 
    fprintf(fileID, 'f(2)短路节点ABC相电流 ');
    for k = 1:length(If_P2)
        fprintf(fileID, '%f %+fi ', real(If_P2(k)), imag(If_P2(k)));
    end
    fprintf(fileID, '\n');
    fprintf(fileID, 'f(2)短路节点120序电压 ');
    for k = 1:length(Uf_T2)
        fprintf(fileID, '%f %+fi ', real(Uf_T2(k)), imag(Uf_T2(k)));
    end
    fprintf(fileID, '\n');
    fprintf(fileID, 'f(2)短路节点120序电流 ');
    for k = 1:length(If_T2)
        fprintf(fileID, '%f %+fi ', real(If_T2(k)), imag(If_T2(k)));
    end
    fprintf(fileID, '\n');

    %两相短路接地
    fprintf(fileID, '两相短路接地ABC相电压（p.u）\n');
    for j = 1:size(U_P2G,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(U_P2G(1,j)), imag(U_P2G(1,j)), real(U_P2G(2,j)), imag(U_P2G(2,j)), real(U_P2G(3,j)), imag(U_P2G(3,j)));
    end
    fprintf(fileID, '两相短路接地120序电压（p.u）\n');
    for j = 1:size(U_T2G,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(U_T2G(1,j)), imag(U_T2G(1,j)), real(U_T2G(2,j)), imag(U_T2G(2,j)), real(U_T2G(3,j)), imag(U_T2G(3,j)));
    end
    fprintf(fileID, '两相短路接地ABC相电流（p.u）\n');
    for j = 1:size(I_P2G,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(I_P2G(1,j)), imag(I_P2G(1,j)), real(I_P2G(2,j)), imag(I_P2G(2,j)), real(I_P2G(3,j)), imag(I_P2G(3,j)));
    end
    fprintf(fileID, '两相短路接地120序电流（p.u）\n');
    for j = 1:size(I_T2G,2)
        fprintf(fileID, '%f %+fi    %f %+fi    %f %+fi\n', real(I_T2G(1,j)), imag(I_T2G(1,j)), real(I_T2G(2,j)), imag(I_T2G(2,j)), real(I_T2G(3,j)), imag(I_T2G(3,j)));
    end
    fprintf(fileID, 'f(1.1)短路节点ABC相电压 ');
    for k = 1:length(Uf_P2G)
        fprintf(fileID, '%f %+fi ', real(Uf_P2G(k)), imag(Uf_P2G(k)));
    end
    fprintf(fileID, '\n'); 
    fprintf(fileID, 'f(1.1)短路节点ABC相电流 ');
    for k = 1:length(If_P2G)
        fprintf(fileID, '%f %+fi ', real(If_P2G(k)), imag(If_P2G(k)));
    end
    fprintf(fileID, '\n');
    fprintf(fileID, 'f(1.1)短路节点120序电压 ');
    for k = 1:length(Uf_T2G)
        fprintf(fileID, '%f %+fi ', real(Uf_T2G(k)), imag(Uf_T2G(k)));
    end
    fprintf(fileID, '\n');
    fprintf(fileID, 'f(1.1)短路节点120序电流 ');
    for k = 1:length(If_T2G)
        fprintf(fileID, '%f %+fi ', real(If_T2G(k)), imag(If_T2G(k)));
    end
    fprintf(fileID, '\n');

    fclose(fileID);
    disp(['计算结果已保存到main.m路径下的文件：', outputFile]);
    
end