function [sefdm_sym] = sefdm_IFFT(modulation_sym, alpha)
    % IFFT function

    global sefdm_FFT_size;
    global sefdm_N_subcarr;
    global sefdm_N_left_inf_subcarr;
    global F

    N = sefdm_N_subcarr;
    W = size(modulation_sym, 2); % number of sefdm symbols

    sefdm_sym = modulation_sym;
   
    
    for m = 1:W
        sefdm_sym(:,m) = F * sefdm_sym(:,m) / sefdm_N_subcarr;
    end

    shift_val = sefdm_N_left_inf_subcarr;
    exp_val = exp(-1i * 2 * pi * (1 : N).' * shift_val / sefdm_FFT_size);
    sefdm_sym = sefdm_sym .* repmat(exp_val, 1, W);

end
