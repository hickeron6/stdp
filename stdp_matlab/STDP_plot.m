dt = -100:1:100;    % post-pre

aLTP = 1;
aLTD = -0.5;
tauLTP = 17; % ms
tauLTD = 34; % ms
eta = 1; 

% aLTP = 0.001;
% aLTD = -0.001;
% tauLTP = 200; % ms
% tauLTD = 200; % ms
% eta = 1;

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
