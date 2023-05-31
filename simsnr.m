%% Calculating SNR on simulated time-series data
% Author: Will Decker
% Note: code adapted from Michael X. Cohen

%% Generate "raw" signal parameters

% baseline
samplerate = 1000; % measured in Hz
time = -3:1/samplerate:0;
n = length(time);
p = 15;
noiselevel = 1; % measured in standard deviations
noise = noiselevel * randn(size(time)); % randomly generate minimal noise along signal
ampl = interp1(randn(p,1)*2, linspace(1,p,n));
baseline = ampl + noise;

% plot baseline
figure(1), clf
plot(time, baseline, 'r');
xlabel('Time (s)'), ylabel('amp. (a.u.)')
zoom on

% signal
% samplerate is the same
time2 = 0:1/samplerate:3; % 1 sample point over 3 seconds
n2 = length(time2);
p2 = 15; % time points
noiselevel2 = 3; % measured in standard deviations
noise2 = noiselevel2 * randn(size(time2)); % randomly generate noise along signal
ampl2 = interp1(randn(p2,1)*25, linspace(1,p2,n2)); % ampl modulator
signal = ampl2 + noise2;

% plot signal
figure(2), clf
plot(time2, signal, 'g');
xlabel('Time (s)'), ylabel('amp. (a.u.)')
zoom on

% entire signal
final = [baseline, signal];
time3 = linspace(-3, 3, length(final));

% find peak amplitude of signal
[~,peak] = max(abs(signal));
newsig = abs(signal);
tp = find(newsig== signal(peak));


% random timept from baseline
r = randi(numel(baseline)); % random index from baseline
r2 = time(r); % timepoint
r3 = baseline(r); % value of timepoint

% plot entire signal
figure(3), clf
plot(time3, final, 'b')
hold on
plot(r2, baseline(r), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r') % plot r2
plot(time3(peak+length(baseline)), final(peak+length(baseline)), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g') % plot peak
hold off
xlabel('Time (s)'), ylabel('amp. (a.u.)')

%% Calculate SNR of "raw" data

timepoint = r2;
baseline_time = [-3 0];
erp = mean(final, 3);

snr_num = erp(:, dsearchn(time3', timepoint));
snr_den = std( erp(:,dsearchn(time3',baseline_time(1)):dsearchn(time3',baseline_time(2))) ,[],2); 

snr = snr_num./snr_den;

disp(["The signal to noise ratio of this simulated data is " num2str(snr)])

%% Filter data

% filtered signal vector
filtsig = final; % or filtsig = signal (hint: edge effects)

% implement the mean-smooth in the *time* domain
k = 100; % filter window
for i = k+1:length(final)-k-1
    filtsig(i) = mean(final(i-k:i+k)); % each point along the filtered signal is the average of 'k' surrounding points
end

% plot
figure(4), clf, hold on
plot(time3, final, time3, filtsig, 'linew', 2)
xlabel('Time (sec.)'), ylabel('Amplitude')
title("Mean smooth filter")
legend({'Signal';'Filtered'})

%% Recalculate SNR

erp2 = mean(filtsig, 3);

snr_num2 = erp2(:, dsearchn(time3', timepoint));
snr_den2 = std( erp2(:,dsearchn(time3',baseline_time(1)):dsearchn(time3',baseline_time(2))) ,[],2); 

snr2 = snr_num2./snr_den2;

disp(["The signal to noise ratio is " num2str(snr2)])
disp(["Raw SNR = " num2str(snr) newline "The filtered SNR = " num2str(snr2)])



