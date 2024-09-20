% SEFDM Generate 

clear;
% close all;
path(path, './functions/');
path(path, '../f_init_model/functions/');

%
% initialize params
alpha_list = [15/16,14/16,13/16,12/16,10/16];
IFFT_size = 16; 
right_GI_len = 1;
left_GI_len = 1;
EbN0 = 0 : 1 : 20; % snr
N_iter = 1e2; % Iteration Times
W = 16; % Number of symbols processed per iteration
itera_d = 100;%detector itera times

Nbps = 2; %
detector = @TSVD;
detector_name = 'TSVD';


t = 15;
Eb_to_select = [2,5,8,11,14];
row_to_select = [3,6,9,12,15];

BER_results = zeros(length(row_to_select), length(alpha_list));

% diff alpha loop
for al = 1:length(alpha_list)
    alpha = alpha_list(al);
    N = IFFT_size; %subcarriers
    N_inf = N - right_GI_len - left_GI_len - 1; % useful subcarriers
    

    % Initialize global params
    sefdm_init(IFFT_size, alpha, right_GI_len, left_GI_len, Nbps, itera_d,t);
    
    % Generate random bits
    tx_bit = randi([0 1], Nbps * N_inf * W, 1);
    tx_bit = reshape(tx_bit, Nbps * N_inf, W);
    
    % Modulation (equals to qammod)
    tx_modulation_sym = ConstellationMap(tx_bit, Nbps);
    
    % Tx and IFFT and add cp (to time domain)
    tx_sefdm_sym = sefdm_IFFT(sefdm_allocate_subcarriers(tx_modulation_sym, 'tx'),alpha);

    N_err_bit = zeros(1, length(EbN0));
    Eb = sum(sum(abs(tx_sefdm_sym) .^ 2)) / (Nbps * N_inf * W);
    
        N_err_bit = zeros(1, length(EbN0));
        
        for i = 1 : length(EbN0)
            
            No = Eb / (10^(EbN0(i) / 10));
            
            for j = 1 : N_iter
                % AWGN
                noise = sqrt(No / 2) * (randn(N * W, 1) + 1i * randn(N * W, 1));
                noise = reshape(noise, N, W);
                rx_sefdm_sym = tx_sefdm_sym + noise;
    
                % SEFDM Rx
                R = sefdm_FFT(rx_sefdm_sym,alpha);
    
                % detect
                if detector_name == "MMSE"
                   rx_modulation_sym = detector(R,No,N);
           
                else
                   rx_modulation_sym = detector(R);
                end
    

                rx_modulation_sym = sefdm_allocate_subcarriers(rx_modulation_sym, 'rx');
    
                % demodulation
                rx_bit = ConstellationDemap(rx_modulation_sym, Nbps);
    
                % ber
                N_err_bit(i) = N_err_bit(i) + biterr(tx_bit, rx_bit);
            end
        end
        
        % BER in diff alpha
        BER_results(:, al) = N_err_bit(row_to_select) / (Nbps * N_inf * W * N_iter);
        
end
BER_ofdm = berawgn(EbN0, 'qam', 4, 'nondiff');

% plot
figure;
markers = {'-*', '-o', '-s', '-d', '-^'};
graph = plot(Eb_to_select,BER_results(:, 1),Eb_to_select,BER_results(:, 2),Eb_to_select,BER_results(:, 3),Eb_to_select,BER_results(:, 4),Eb_to_select,BER_results(:, 5));
graph(1).Marker = '*';
graph(2).Marker = '^';
graph(3).Marker = 'o';
graph(4).Marker = 'd';
graph(5).Marker = 's';

graph(1).Color = 'k';
graph(2).Color = 'b';
graph(3).Color = 'r';
graph(4).Color = 'm';
graph(5).Color = 'c';

xlabel('EbN0');
ylabel('BER');
legend show;
ylim([0,0.2]);
legend_entries = arrayfun(@(x) sprintf('Alpha = %.2f', x), alpha_list, 'UniformOutput', false);

legend(legend_entries);
grid on;
title(sprintf('BER vs Alpha for detector = %s', detector_name));

