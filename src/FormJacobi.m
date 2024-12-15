% Copyright 2024 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2024/12/15

function [Jb] = FormJacobi(U1,PVnode,Balance,Y,n)
        % 计算 H 矩阵
        H = sparse(imag(sparse(diag(U1)) * sparse(diag(conj(Y * U1)))) - ...
                   imag(sparse(diag(U1)) * conj(Y * sparse(diag(U1)))));
        % Hij—有功功率增量对相角增量的偏导数
        % Hii—有功功率增量对相角增量的偏导数

        % 计算 N 矩阵
        N = sparse(-real(sparse(diag(U1)) * sparse(diag(conj(Y * U1)))) - ...
                    real(sparse(diag(U1)) * conj(Y * sparse(diag(U1)))));
        % Nij—有功功率增量对电压增量的偏导数
        % Nii—有功功率增量对电压增量的偏导数

        % 计算 J 矩阵
        J = sparse(-real(sparse(diag(U1)) * sparse(diag(conj(Y * U1)))) + ...
                    real(sparse(diag(U1)) * conj(Y * sparse(diag(U1)))));
        % Jij—无功功率增量对相角增量的偏导数
        % Jii—无功功率增量对相角增量的偏导数

        % 计算 L 矩阵
        L = sparse(-imag(sparse(diag(U1)) * sparse(diag(conj(Y * U1)))) - ...
                   imag(sparse(diag(U1)) * conj(Y * sparse(diag(U1)))));
        % Lij—无功功率增量对电压增量的偏导数
        % Lii—无功功率增量对电压增量的偏导数

%% 修正H
        H(Balance,:) = 0;                              %对H中的平衡节点进行修正，将H中平衡节点对应的行置零 
        H = sparse(H);
        H(:,Balance) = 0;                              %对H中的平衡节点进行修正，将H中平衡节点对应的列置零 
        H = sparse(H);
        H = H+sparse(Balance,Balance,1,n,n);           %H主对角元素不能为0，需要对H的对角线元素进行修改
%% 修正N  
        N(:,PVnode) = 0;                               %对N中的pv节点进行修正置零             
        N = sparse(N);
        N(Balance,:) = 0;                              %对N中的平衡节点进行修正，将N中平衡节点对应的行置零                                                                 
        N = sparse(N);
        N(:,Balance) = 0;                              %对N中的平衡节点进行修正，将N中平衡节点对应的列置零  
        N = sparse(N);
               
%% 修正J        
        J(PVnode,:) = 0;                            %对J中的pv节点进行修正，因为PV节点只有H和N,将L、J置零，但是J的主对角元素不能为0
        J = sparse(J);
        J(Balance,:) = 0;                             %对J中的平衡节点进行修正，将J中平衡节点对应的行置零
        J = sparse(J);
        J(:,Balance) = 0;                             %对J中的平衡节点进行修正，将J中平衡节点对应的列置零
        J = sparse(J);
        
%% 修正L  
        L(PVnode,:) = 0;                            %对L中的pv节点进行修正，因为PV节点只有H和N,将L、J置零，但是L的主对角元素不能为0
        L = sparse(L);
        L(:,PVnode) = 0;  
        L = sparse(L);
        L = L+sparse(PVnode,PVnode,1,n,n);
        L(Balance,:) = 0;                              %对L中的平衡节点进行修正，将L中平衡节点对应的行置零
        L = sparse(L);
        L(:,Balance) = 0;                              %对L中的平衡节点进行修正，将L中平衡节点对应的列置零
        L = sparse(L);
        L = L+sparse(Balance,Balance,1,n,n);           %L主对角元素不能为0，需要对L的对角线元素进行修改
     
%% 形成雅克比矩阵并进行修正
        Jb = [H,N;J,L];                                %形成雅克比矩阵
        Jb = sparse(Jb);                               %形成稀疏雅克比矩阵
        

