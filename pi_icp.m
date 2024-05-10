%-------------------------- ѵ��actor_init ----------------------------
clear; close all; clc;

load state_data.mat

% [K, P] = dlqr(A,B,Q,100*R);
len = length(x_train);
steps = 10;
x_train_data = zeros(2,len*steps);
actor_target = zeros(1,len*steps);
T = 0.001;
% [K, P] = dlqr(A*T+eye(4),B*T,Q,10*R);
[K, P] = dlqr(A, B, Q, R);
h = waitbar(0,'Please wait');
for j = 1:len
    x = x_train(:,j);
    for i = 1:steps
        x_train_data(:,(j-1)*steps+i) = x;
        u = -K*x;
        actor_target(:,(j-1)*steps+i) = u;
%         x = (A*T+eye(state_dim))*x + B*T*u;
        x = A * x + B * u;
        waitbar(((j-1)*steps+i)/(len*steps),h,['Running...',num2str(((j-1)*steps+i)/(len*steps)*100),'%']);
    end
end

% actor_target = -K*x_train;
%%
cover = 1;
if isempty(dir('actor_init.mat')) == 1 || cover == 1
    actor_init_middle_num = 20;
    actor_init_epoch = 10000;
    actor_init_err_goal = 1e-9;
    actor_init_lr = 1;% lm��ѧϰ�ʿ������õ�1��gdѧϰ�ʵ�1ֱ�ӱ����������ó�С����̫����
    actor_init = newff(minmax(x_train_data), [actor_init_middle_num control_dim], {'tansig' 'purelin'},'trainlm');
    actor_init.trainParam.epochs = actor_init_epoch;
    actor_init.trainParam.goal = actor_init_err_goal;
    actor_init.trainParam.show = 10;
    actor_init.trainParam.lr = actor_init_lr;
    actor_init.biasConnect = [1;0];
    
    actor_init = train(actor_init, x_train_data, actor_target);
    
    save actor_init actor_init
else
    load training_data/actor_init
end

%%

%   ������֤����ѧϰ�ĳ�ʼActor�Ƿ��ܹ�ʹ��ϵͳ�ȶ�

load actor_init
load state_data

K = dlqr(A, B, Q, R);
x = [0.5;-1];
steps = 100;
xx = zeros(2,steps);
tic;
for i=1:steps
   xx(:,i) = x;
   u = actor_init(x);
   x_next = A * x + B * u;
   x = x_next;
end
toc;
figure(1)
plot(xx(1,:), 'r');
hold on;
plot(xx(2,:), 'g');




