% 定义参数
dt = -32:1:32; % post-pre
aLTP = 1;
aLTD = -1;
tauLTP = 16; % ms
tauLTD = 16; % ms
eta = 1; 
time_window = 32;
multiple = 8; % 定义倍数值

% 计算deltaW
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



% 绘图
figure;
plot(dt, deltaW, 'LineWidth', 2);
xlabel('Spike Timing Difference \Delta t (ms) [post-pre]');
ylabel('Change in Synaptic Weight \Delta w');
title('STDP Curve');
grid on;

% 应用倍数值，四舍五入到整数，然后输出0到-time_window部分
disp('Array from 0 to -time_window, multiplied and rounded:');
index_neg = dt >= -time_window & dt < 0;
multiplied_neg = -round(deltaW(index_neg) * multiple); % 应用倍数并四舍五入
disp(['(', strjoin(arrayfun(@num2str, multiplied_neg, 'UniformOutput', false), ', '), ');']);

% 应用倍数值，四舍五入到整数，然后输出0到time_window部分
disp('Array from 0 to time_window, multiplied and rounded:');
index_pos = dt <= time_window & dt > 0;
multiplied_pos = round(deltaW(index_pos) * multiple); % 应用倍数并四舍五入
disp(['(', strjoin(arrayfun(@num2str, multiplied_pos, 'UniformOutput', false), ', '), ');']);
