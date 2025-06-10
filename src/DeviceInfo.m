% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/18

function DeviceInfo()
    % 打开文件
    outputFile = 'DeviceInfo.txt';
    fileID = fopen(outputFile, 'a');%以追加模式打开文件

    % 记录时间
    StartTime = datetime('now','Format','yyyy-MM-dd HH:mm:ss');
    fprintf(fileID, '\n设备信息记录时间: %s\n', StartTime);

    % 获取MATLAB版本信息
    matlabVersion = version;
    fprintf(fileID, 'MATLAB版本: %s\n', matlabVersion);
    
    % 获取计算机类型和操作系统
    [comp, maxsize] = computer;
    fprintf(fileID, '计算机类型: %s\n', comp);
    fprintf(fileID, '最大数组大小: %d\n', maxsize);
    
    % 获取CPU信息
    cpuInfo = feature('numcores');
    fprintf(fileID, 'CPU核心数: %d\n', cpuInfo);
    cpuThreads = feature('numthreads');
    fprintf(fileID, 'CPU线程数: %d\n', cpuThreads);
    
    % 获取GPU信息
    gpuInfo = gpuDevice;
    fprintf(fileID, 'GPU名称: %s\n', gpuInfo.Name);
    fprintf(fileID, 'GPU计算能力: %s\n', gpuInfo.ComputeCapability);
    fprintf(fileID, 'GPU内存大小: %.4f GiB\n', gpuInfo.TotalMemory / (1024 ^3));
    
    % 获取内存信息
    memoryInfo = memory;
    fprintf(fileID, '可用内存: %.4f GiB\n', memoryInfo.MemAvailableAllArrays / (1024^3));
    fprintf(fileID, '最大可用内存: %.4f GiB\n', memoryInfo.MaxPossibleArrayBytes / (1024^3));
    fprintf(fileID, 'MATLAB使用的内存: %.4f GiB\n', memoryInfo.MemUsedMATLAB / (1024^3));

    % 关闭文件
    fclose(fileID);
end