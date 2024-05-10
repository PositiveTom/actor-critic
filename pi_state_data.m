%------------------------- generate training data & system information ----------------------------
clear; close all; clc;

% system matrices
A = [  0,      0.1;...
       0.3,    -1   ];
B = [  0;...
       0.5  ];
% cf = -110000;%侧边刚度
% cr = cf;%这里左右轮的侧边刚度近似相等
% m = 1412; %1270+71+71 kg
% Iz = 1536.7;% kg m^2
% a = 1.015;%m
% b = 2.91 - a;%m
% vx = 10;
% A=[0,1,0,0;
%     0,(cf+cr)/(m*vx),-(cf+cr)/m,(a*cf-b*cr)/(m*vx);
%     0,0,0,1;
%     0,(a*cf-b*cr)/(Iz*vx),-(a*cf-b*cr)/Iz,(a*a*cf+b*b*cr)/(Iz*vx)];
% B=[0;
%     -cf/m;
%     0;
%     -a*cf/Iz];

state_dim = size(A,1);
control_dim = size(B,2);

% cost function parameters
Q = 1*eye(state_dim);
R = 1*eye(control_dim);

% training data
x_train = zeros(state_dim,1);
% x0 = [0.5;0.5;-0.5;-0.5];
x0 = [1;-1];

for i = 1:50
%     x_train = [x_train, zeros(state_dim,1)];  
    x_train = [x_train,4*(rand(state_dim,1) - 0.5)]; 
    x_train = [x_train,2*(rand(state_dim,1) - 0.5)]; 
    x_train = [x_train,1*(rand(state_dim,1) - 0.5)];
    x_train = [x_train,0.5*(rand(state_dim,1) - 0.5)];
end

r = randperm(size(x_train,2));   % randomization according to column
x_train = x_train(:, r);         % reorder

save state_data x_train state_dim control_dim A B Q R x0;




