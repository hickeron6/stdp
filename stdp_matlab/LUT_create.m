dt = -32:1:32; % post-pre
aLTP = 1;
aLTD = -1;
tauLTP = 16; % ms
tauLTD = 16; % ms
eta = 1; 
time_window = 32;
multiple = 8; 

% deltaW ct
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




figure;
plot(dt, deltaW, 'LineWidth', 2);
xlabel('Spike Timing Difference \Delta t (ms) [post-pre]');
ylabel('Change in Synaptic Weight \Delta w');
title('STDP Curve');
grid on;

disp('Array from 0 to -time_window, multiplied and rounded:');
index_neg = dt >= -time_window & dt < 0;
multiplied_neg = -round(deltaW(index_neg) * multiple); 
disp(['(', strjoin(arrayfun(@num2str, multiplied_neg, 'UniformOutput', false), ', '), ');']);


disp('Array from 0 to time_window, multiplied and rounded:');
index_pos = dt <= time_window & dt > 0;
multiplied_pos = round(deltaW(index_pos) * multiple); 
disp(['(', strjoin(arrayfun(@num2str, multiplied_pos, 'UniformOutput', false), ', '), ');']);
