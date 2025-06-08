% Copyright 2025 ZhongyuXie 
% Licensed Under Apache-2.0 License
% Last updated: 2025/6/9

function [U_T,I_T,U_P,I_P] = SC_TwoPhase_Ground(Z1,Z2,Z0,ScNode,Uf0,Transfrom120ToABC,NodeNumbers,BranchNumber,BranchStartNode,BranchEndNode)
    %电压序分量U_T=[U1;U2;U0];
    %电流序分量I_T=[I1;I2;I0];
    %电压相分量（A特殊相）U_P=[UA;UB;UC];
    %电流相分量（A特殊相）I_P=[IA;IB;IC];