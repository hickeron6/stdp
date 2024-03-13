dt = -100:1:100; % post-pre
aLTP = 1;
aLTD = -1;
tauLTP = 20; % ms
tauLTD = 20; % ms
eta = 1; 
time_window = 100; % 更新时间窗口为100
multiple = 8; 

% deltaW 计算
deltaW = zeros(size(dt));
for i = 1:length(dt)
    if dt(i) > 0
        % LTP: Δt > 0
        deltaW(i) = eta * aLTP * exp(-dt(i)/tauLTP);
    elseif dt(i) < 0
        % LTD: Δt < 0
        deltaW(i) = eta * aLTD * exp(dt(i)/tauLTD);
    else
        % Δt = 0
        deltaW(i) = 0;
    end
end

% 处理后的分段值
multiplied_neg = -round(deltaW(dt >= -time_window & dt < 0) * multiple); 
multiplied_pos = round(deltaW(dt <= time_window & dt > 0) * multiple); 

% 显示处理后的分段值
disp('Array from 0 to -time_window, multiplied and rounded:');
disp(['(', strjoin(arrayfun(@num2str, multiplied_neg, 'UniformOutput', false), ', '), ');']);

disp('Array from 0 to time_window, multiplied and rounded:');
disp(['(', strjoin(arrayfun(@num2str, multiplied_pos, 'UniformOutput', false), ', '), ');']);

% 绘制处理后的STDP分段折线图
figure;
subplot(2,1,1); % 负时间窗口
plot(-time_window:-1, multiplied_neg, 'b-o', 'LineWidth', 2);
xlabel('Delta t (ms) [pre-post]');
ylabel('Synaptic Weight');
title('STDP Curve for Negative \Delta t');
grid on;

subplot(2,1,2); % 正时间窗口
plot(1:time_window, multiplied_pos, 'r-o', 'LineWidth', 2);
xlabel('Delta t (ms) [post-pre]');
ylabel('Synaptic Weight');
title('STDP Curve for Positive \Delta t');
grid on;
