% SEFDM Generate 

clear;
close all;
path(path, './functions/');
path(path, '../f_init_model/functions/');

% initialize params
alpha = 15/16;
IFFT_size = 32 ; 
right_GI_len = 1;
left_GI_len = 1;
EbNo = 0 : 0.5 : 15; % snr
N_iter = 1e2; % Iteration Times
W = 48; % Number of symbols processed per iteration

Nbps = 2; % QPSk 
itera_d = 5;%detector itera times


N = IFFT_size ; % Useful SEFDM subcarriers
N_inf = N - right_GI_len - left_GI_len - 1; % modulation_symbol
detectors = struct('name', {}, 'function', {});

detectors(1).name = 'ZF';
detectors(1).function = @ZF;
detectors(2).name = 'MMSE';
detectors(2).function = @MMSE;
detectors(3).name = 'TSVD';
detectors(3).function = @TSVD;
detectors(4).name = 'IC';
detectors(4).function = @IC;
detectors(5).name = 'ID';
detectors(5).function = @ID;

t = 15;

%%
% Initialize global params
sefdm_init(IFFT_size, alpha, right_GI_len, left_GI_len, Nbps,itera_d,t)

% Generate random bits
tx_bit = randi([0 1], Nbps * N_inf * W, 1);
tx_bit = reshape(tx_bit, Nbps * N_inf, W);

% Modulation (equals to qammod)
tx_modulation_sym = ConstellationMap(tx_bit, Nbps);

% Tx and IFFT and add cp (to time domain)
tx_sefdm_sym = sefdm_IFFT(sefdm_allocate_subcarriers(tx_modulation_sym, 'tx'),alpha);
% soectrum
tx_sefdm_stream = reshape(tx_sefdm_sym, 1, []);
signal_length = length(tx_sefdm_stream);
win_len = min(500, signal_length);
noverlap = floor(win_len / 2);     
[p_sefdm, f] = pwelch(tx_sefdm_stream, 500, 300, 500, 10e6);
figure;
plot(f, 10*log10(p_sefdm));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;
clear tx_sefdm_stream p_sefdm f


%  AWGN, SEFDM Rx, Demodulation, Detection
Eb = sum(sum(abs(tx_sefdm_sym) .^ 2)) / (Nbps * N_inf * W);

BER_results = zeros(length(EbNo), length(detectors));


for d = 1:length(detectors)
    detector = detectors(d).function;
    detector_name = detectors(d).name;
    N_err_bit = zeros(1, length(EbNo));
    
    for i = 1 : length(EbNo)
        
        No = Eb / (10^(EbNo(i) / 10));
        
        for j = 1 : N_iter
            % AWGN
            noise = sqrt(No / 2) * (randn(N * W, 1) + 1i * randn(N * W, 1));
            noise = reshape(noise, N, W);
            rx_sefdm_sym = tx_sefdm_sym + noise;

            % SEFDM Rx
            R = sefdm_FFT(rx_sefdm_sym,alpha);
            
       
            if detector_name == "MMSE"
                rx_modulation_sym = detector(R,No,N);
           
            else
                rx_modulation_sym = detector(R);
            end

          
            rx_modulation_sym = sefdm_allocate_subcarriers(rx_modulation_sym, 'rx');

            % demodulation
            rx_bit = ConstellationDemap(rx_modulation_sym, Nbps);

       
            N_err_bit(i) = N_err_bit(i) + biterr(tx_bit, rx_bit);
        end
    end
    
    % BER
    BER_results(:, d) = N_err_bit / (Nbps * N_inf * W * N_iter);
end

BER_ofdm = berawgn(EbNo, 'psk', 2, 'nondiff');

% plot
figure;
graph = semilogy(EbNo, BER_ofdm,EbNo,BER_results(:, 1),EbNo,BER_results(:,2),EbNo,BER_results(:,3),EbNo,BER_results(:,4),EbNo,BER_results(:,5));
graph(1).Marker = '*';
graph(2).Marker = '^';
graph(3).Marker = 'o';
graph(4).Marker = 'd';
graph(5).Marker = 's';
graph(6).Marker = 'x';
graph(1).Color = 'k';
graph(2).Color = 'c';
graph(3).Color = 'r';
graph(4).Color = 'm';
graph(5).Color = 'b';

xlabel('Eb/No (dB)');
ylabel('BER');
legend show;
ylim([1e-3, 1]);
% Initialize the legend names array with 'ofdm'
legendNames = {'ofdm'};
% Add the names of detectors from the structure
for i = 1:length(detectors)
    legendNames{end+1} = detectors(i).name;
end
% Now pass the legendNames array to the legend function
legend(legendNames{:});
grid on;
title(sprintf('BER vs Eb/No for detector in Alpha = %.2f', alpha));

