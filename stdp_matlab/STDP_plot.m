dt = -100:1:100;    % post-pre

aLTP = 1;
aLTD = -0.5;
tauLTP = 17; % ms
tauLTD = 34; % ms
eta = 1; 

deltaW = zeros(size(dt));
for i = 1:length(dt)
    if dt(i) > 0
        % LTP: Δt > 0
        deltaW(i) = eta * aLTP * exp(-dt(i)/tauLTP); % 注意：应用负号调整
    elseif dt(i) < 0
        % LTD: Δt < 0
        deltaW(i) = eta * aLTD * exp(dt(i)/tauLTD); % 注意：应用负号调整
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
