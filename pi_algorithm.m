

clear; close all; clc;

global A; global B; global Q; global R;

load state_data.mat;
load actor_init.mat;

Q = 10*eye(state_dim);
R = 1*eye(control_dim);

% action network
%   
actor = actor_init;

actor_epoch = 10000;
actor_err_goal = 1e-9;
actor_lr = 0.01;
actor.trainParam.epochs = actor_epoch; 
actor.trainParam.goal = actor_err_goal; 
actor.trainParam.show = 10; 
actor.trainParam.lr = actor_lr; 

% critic network
critic_middle_num = 15;
critic_epoch = 10000;
critic_err_goal = 1e-9;
critic_lr = 0.01;
critic = newff(minmax(x_train), [critic_middle_num 1], {'tansig' 'purelin'},'trainlm');
critic.trainParam.epochs = critic_epoch;
critic.trainParam.goal = critic_err_goal; 
critic.trainParam.show = 10;  
critic.trainParam.lr = critic_lr; 
critic.biasConnect = [1;0];

epoch = 2;
eval_step = 100;
% performance_index = ones(1,epoch + 1);

figure(1),hold on;
h = waitbar(0,'Please wait');
for i = 1:epoch
    % update critic
    %   critic_target就是在以201组不同的状态为初态时，采取Actor作为控制策略，运行100步之后，得到的201个性能指标函数
    critic_target = evaluate_policy(actor, x_train, eval_step);
    %   以上面得到的201个性能指标函数作为critic网络的target，来训练critic网络，critic网络的输入为初始状态
    critic = train(critic,x_train,critic_target); 
    
%     performance_index(i) = critic(x0);
    
    waitbar(i/epoch,h,['Training controller...',num2str(i/epoch*100),'%']);
    if i == epoch
        break;
    end
    
    % update actor
    %   更新actor网络的目标值，原来的目标值是在最优控制律K基础之上计算出来的
    actor_target = zeros(control_dim,size(x_train,2));
    for j = 1:size(x_train,2)
        x = x_train(:,j);
        if x == zeros(state_dim,1)
            ud = zeros(control_dim,1);
        else
            objective = @(u) cost_function(x,u) + critic(controlled_system(x,u));
            u0 = actor(x);
            %   寻找使得 代价函数（性能指标函数） 以及critic网络打分最小的值，以u0为初始值
            ud = fminunc(objective, u0);
        end
        actor_target(:,j) = ud;
    end
    
    actor = train(actor, x_train, actor_target);
end
close(h)

save actor_critic actor critic


%%
%   测试更新后的actor是否能够使得系统稳定

load actor_critic;
load state_data;

K = dlqr(A, B, Q, R);
x = [0.5;-1];
steps = 100;
xx = zeros(2,steps);
tic;
for i=1:steps
   xx(:,i) = x;
   u = actor(x);
   x_next = A * x + B * u;
   x = x_next;
end
toc;
figure(1)
plot(xx(1,:), 'r');
hold on;
plot(xx(2,:), 'g');





%%
%---------------------------- 策略评估 -----------------------------
function y = evaluate_policy(actor,x,eval_step)
critic_target = zeros(1,size(x,2));
%   在这个actor的作用下，作用400步，计算出性能指标函数
for k = 1:eval_step
    uep = actor(x);
    critic_target = critic_target +  cost_function(x,uep);
    x = controlled_system(x,uep);
end
y = critic_target;
end
%%
%--------------------------- 控制系统 ----------------------------
function y = controlled_system(x,u)
% system matrices
global A; global B;
y = A*x + B*u;  
end
%%
%----------------------------- cost function ------------------------------
function y = cost_function(x,u)
global Q; global R;
y = (diag(x'*Q*x) + diag(u'*R*u))';
end

