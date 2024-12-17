% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/17

%% 计算雅可比矩阵
function [Jb] = FormJacobi(U1,PVnode,Balance,Y,n)

        %公共部分计算
        U1Diag = sparse(diag(U1));                      %计算电压幅值稀疏对角矩阵，对角化使得循环运算只需要一次即可得到全部结果，只需要考虑移位提取数据，不需要循环
        Y_U1Conj_Diag = sparse(diag(conj(Y * U1)));     %计算Y*U1的共扼稀疏对角矩阵
        Y_U1Diag_Conj = conj(Y * U1Diag);               %计算Y*U1Diag的共轭

        % 计算 H 矩阵
        H = sparse( imag(U1Diag * Y_U1Conj_Diag) - imag(U1Diag * Y_U1Diag_Conj));%用ij计算全部，随后修正ii元，N，J，L同理
        % H—有功功率增量对相角增量的偏导数

        % 计算 N 矩阵
        N = sparse( -real(U1Diag * Y_U1Conj_Diag) - real(U1Diag * Y_U1Diag_Conj));
        % N—有功功率增量对电压增量的偏导数

        % 计算 J 矩阵
        J = sparse( -real(U1Diag * Y_U1Conj_Diag) + real(U1Diag * Y_U1Diag_Conj));
        % J—无功功率增量对相角增量的偏导数

        % 计算 L 矩阵
        L = sparse( -imag(U1Diag * Y_U1Conj_Diag) - imag(U1Diag * Y_U1Diag_Conj));
        % L—无功功率增量对电压增量的偏导数

%% 修正H
        H(Balance,:) = 0;                              %对H中的平衡节点进行修正，将H中平衡节点对应的行置零 
        H(:,Balance) = 0;                              %对H中的平衡节点进行修正，将H中平衡节点对应的列置零 
        H = sparse(H);
        H = H+sparse(Balance,Balance,1,n,n);           %H主对角元素不能为0，需要对H的对角线元素进行修改
%% 修正N  
        N(:,PVnode) = 0;                               %对N中的pv节点进行修正置零             
        N(Balance,:) = 0;                              %对N中的平衡节点进行修正，将N中平衡节点对应的行置零                                                                 
        N(:,Balance) = 0;                              %对N中的平衡节点进行修正，将N中平衡节点对应的列置零  
        N = sparse(N);
               
%% 修正J        
        J(PVnode,:) = 0;                               %对J中的pv节点进行修正，因为PV节点只有H和N,将L、J置零，但是J的主对角元素不能为0
        J(Balance,:) = 0;                              %对J中的平衡节点进行修正，将J中平衡节点对应的行置零
        J(:,Balance) = 0;                              %对J中的平衡节点进行修正，将J中平衡节点对应的列置零
        J = sparse(J);
        
%% 修正L  
        L(PVnode,:) = 0;                               %对L中的pv节点进行修正，因为PV节点只有H和N,将L、J置零，但是L的主对角元素不能为0
        L(:,PVnode) = 0;  
        L = L+sparse(PVnode,PVnode,1,n,n);
        L(Balance,:) = 0;                              %对L中的平衡节点进行修正，将L中平衡节点对应的行置零
        L(:,Balance) = 0;                              %对L中的平衡节点进行修正，将L中平衡节点对应的列置零
        L = L+sparse(Balance,Balance,1,n,n);           %L主对角元素不能为0，需要对L的对角线元素进行修改
        L = sparse(L);
     
%% 形成修正雅克比矩阵
        Jb = [H,N;J,L];                                %形成雅克比矩阵
        Jb = sparse(Jb);                               %形成稀疏雅克比矩阵
        

