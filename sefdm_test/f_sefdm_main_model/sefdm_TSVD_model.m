% SEFDM Generate 

clear;
close all;
path(path, './functions/');
path(path, '../f_init_model/functions/');

%
% initialize params
alpha = 14/16;
IFFT_size = 16 ; 
right_GI_len = 1;
left_GI_len = 1;
EbNo = 0 : 0.5 : 15; % snr
N_iter = 1e2; % Iteration Times
W = 48; % Number of symbols processed per iteration

Nbps = 2; % QPSk 
itera_d = 5;%detector itera times


N = IFFT_size ; % Useful SEFDM subcarriers
N_inf = N - right_GI_len - left_GI_len - 1; % modulation_symbol
detector = @TSVD;

t_list = [5,10,15,20];
BER_results = zeros(length(EbNo), length(t_list));
%%
for d = 1:length(t_list)
    N_err_bit = zeros(1, length(EbNo));
    % Initialize global params
    sefdm_init(IFFT_size, alpha, right_GI_len, left_GI_len, Nbps,itera_d,t_list(d))
    
    % Generate random bits
    tx_bit = randi([0 1], Nbps * N_inf * W, 1);
    tx_bit = reshape(tx_bit, Nbps * N_inf, W);
    
    % Modulation (equals to qammod)
    tx_modulation_sym = ConstellationMap(tx_bit, Nbps);
    
    % Tx and IFFT and add cp (to time domain)
    tx_sefdm_sym = sefdm_IFFT(sefdm_allocate_subcarriers(tx_modulation_sym, 'tx'),alpha);
    
    
    
    %  AWGN, SEFDM Rx, Demodulation, Detection
    
    Eb = sum(sum(abs(tx_sefdm_sym) .^ 2)) / (Nbps * N_inf * W);
    
    for i = 1 : length(EbNo)
        
        No = Eb / (10^(EbNo(i) / 10));
        
        for j = 1 : N_iter
            % AWGN
            noise = sqrt(No / 2) * (randn(N * W, 1) + 1i * randn(N * W, 1));
            noise = reshape(noise, N, W);
            rx_sefdm_sym = tx_sefdm_sym + noise;

            % SEFDM Rx
            R = sefdm_FFT(rx_sefdm_sym,alpha);
            
            % 使用选择的检测器进行信号检测
            
            rx_modulation_sym = detector(R);
            

            % 提取信息子载波，考虑保护间隔
            rx_modulation_sym = sefdm_allocate_subcarriers(rx_modulation_sym, 'rx');

            % 解调
            rx_bit = ConstellationDemap(rx_modulation_sym, Nbps);

            % 累积错误
            N_err_bit(i) = N_err_bit(i) + biterr(tx_bit, rx_bit);
        end
    end
    
    % 计算BER
    BER_results(:, d) = N_err_bit / (Nbps * N_inf * W * N_iter);
end

BER_ofdm = berawgn(EbNo, 'psk', 2, 'nondiff');

% 绘制BER曲线
figure;
graph = semilogy(EbNo, BER_ofdm,EbNo,BER_results(:, 1),EbNo,BER_results(:,2),EbNo,BER_results(:,3),EbNo,BER_results(:,4));
graph(1).Marker = '*';
graph(2).Marker = '^';
graph(3).Marker = 'o';
graph(4).Marker = 'd';
graph(5).Marker = 's';

graph(1).Color = 'k';
graph(2).Color = 'c';
graph(3).Color = 'r';
graph(4).Color = 'm';


xlabel('Eb/No (dB)');
ylabel('BER');
legend show;
ylim([1e-3, 1]);
% Initialize the legend names array with 'ofdm'
legendNames = {'ofdm','t=5','t=10','t=15','t=20'};
% Add the names of detectors from the structure
% Now pass the legendNames array to the legend function
legend(legendNames{:});
grid on;
title(sprintf('BER vs Eb/No for TSVD in Alpha = %.2f  in different threshold)', alpha));

