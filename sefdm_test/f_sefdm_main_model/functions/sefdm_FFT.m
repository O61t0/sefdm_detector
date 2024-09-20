% Yunsheng
% 2024-8-5

function [R] = sefdm_FFT(sefdm_sym,alpha)
% Perform FFT to obtain statistics (MF Demodulator)
% See sefdm_IFFT.m + // Ahmed, p. 115+; Grammenos, p. 125+

    global sefdm_FFT_size;
    global sefdm_N_subcarr;
    global sefdm_N_add_zero;
    global sefdm_N_left_inf_subcarr;
    global F
    N = sefdm_N_subcarr;
    N_add_zero = sefdm_N_add_zero;
    index = 1 : sefdm_N_subcarr;
    

    W = size(sefdm_sym, 2); % number of sefdm symbols

    % Shift the spectrum
    shift_val = sefdm_N_left_inf_subcarr;
    exp_val = exp(1i * 2 * pi * (1 : N).' * shift_val / sefdm_FFT_size);
    sefdm_sym = sefdm_sym .* repmat(exp_val, 1, W);
    for m = 1:W
        sefdm_sym(:,m) = F' * sefdm_sym(:,m);
    end
    R = sefdm_sym;
    % sefdm_sym = [sefdm_sym; zeros(N_add_zero, W)]; % Add zeros
    % R = fft(sefdm_sym, sefdm_FFT_size);
    % R = R(index, 1 : W); % Trim

   
    
end
