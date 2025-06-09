% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/9

function  PF_Printout(volts,trans_powers,S_lose,U1,slack_power,NodeNumbers,CurrentIteration,MaxUnbalance,StartTime,TimeMessage,outputFile)
    %命令行输出
    disp('节点电压幅值                             节点电压角度');disp(volts);
    disp('线路功率(MVA)');disp(trans_powers);
    disp('线路损耗(MVA)');disp(S_lose);

    %此处设置考虑到命令行显示不全，重复输出便于对照
    disp(['计算的节点数为：',num2str(NodeNumbers),'个']);
    disp(['潮流迭代的次数为：',num2str(CurrentIteration),'次']);
    disp(TimeMessage);
    disp(['最大不平衡量为:',num2str(MaxUnbalance)]);
    disp('平衡节点功率(MVA)');disp(slack_power); 
    
    %文件输出
    fileID = fopen(outputFile, 'a');
    fprintf(fileID, ['\n','计算类型为潮流计算' , '\n']);
    fprintf(fileID, ['\n','计算始于',char(StartTime),'\n']);
    fprintf(fileID, '计算的节点数为：%d 个\n', NodeNumbers);
    fprintf(fileID, '潮流迭代的次数为：%d 次\n', CurrentIteration);
    fprintf(fileID, '%s\n', TimeMessage);%计算用时信息
    fprintf(fileID, ['最大不平衡量为: ', num2str(MaxUnbalance), '\n']);
    fprintf(fileID, '平衡节点功率(MVA):');
    fprintf(fileID, [num2str(slack_power),'\n']);
    fprintf(fileID, '节点编号\t节点电压幅值\t节点电压角度\n');
    U1 = full(U1);
    for i = 1:NodeNumbers
        fprintf(fileID, '%d                 %f           %f\n',i, abs(U1(i)), rad2deg(angle(U1(i))));
    end
    fclose(fileID);

    disp(['计算结果已保存到main.m路径下的文件：', outputFile]);
    DeviceInfo();%额外输出设备信息

end
