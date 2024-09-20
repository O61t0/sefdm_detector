% SEFDM_TSVD

clear;

EbN0 = [0:5:30];          %Eb/N0
N_iter = 1e2;
W = 64;
N_inf = 16;
Nbps = 2; M = 2^Nbps;     %调制阶数 = 2/4/6; QPSK/16-QAM/64-QAM
norms = [1 sqrt(2) 0 sqrt(10) 0 sqrt(42)];  %BPSK 4-QAM 16-QAM
Target_neb = 100000;    %积累了一定的错误自动停止循环
sigPow = 0;
Nfft = 16;

alpha = 0.81;
X_shift = zeros(16,1);
x_GI = zeros(N_inf*W,1);
Xmod_r = zeros(N_inf*W,1);
rho = 1;
[phi,c_ifft_fft] = phi_c_ifft_fft(N_inf,rho,alpha);
xi = 15;

for i = 0:length(EbN0)
    randn('state',0);rand('state',0);
    %     初始化错误比特数和总比特数
    Neb = 0;
    Ntb = 0;
    %     迭代设计
    for m = 1:N_iter
        X = randi([0,1],1,N_inf*W*Nbps);   %bit:整数向量
        X = X';
        Xmod = qammod(X,M,'gray',"InputType","bit")/norms(Nbps);

        kk1 = [1:N_inf];          %有效载波序号
        kk16 = 1:N_inf;
        for k = 1:W
           X_shift(kk16) = Xmod(kk1);
           x = phi * X_shift/rho/N_inf;
           x_GI(kk1) = x;
           
           kk1 = kk1 + N_inf;
           
        end
        if i==1 && m ==1
            signal_length = length(x_GI);
            win_len = min(500, signal_length);  % 窗口长度不能超过信号长度
            noverlap = floor(win_len / 2);      % 重叠长度设置为窗口长度的一半
            
            % 使用调整后的窗口长度进行频谱分析
            [p_sefdm, f] = pwelch(x_GI, win_len, noverlap, win_len, 10e6, 'centered');
            figure;
            plot(f, 10*log10(p_sefdm));
            xlabel('Frequency (Hz)');
            ylabel('Magnitude (dB)');
            grid on;
            clear tx_sefdm_stream p_sefdm f
%         信道
        end
        y = x_GI;
        if i == 0     %只测量信号功率
            y1 = y(1:W*N_inf);
            sigPow = sigPow + y1'*y1;
            continue;
        end
        snr = EbN0(i) + 10*log10(Nbps);  %式(4.28)SNR vs.Eb/N0
        noise_mag = sqrt((10.^(-snr/10))*sigPow/2);
        y_GI = y + noise_mag * (randn(size(y))+1j*randn(size(y)));

        %RX_____________________________
        kk1 = 1:N_inf;
        
        for k = 1:W
            [U,S,V] = svd(c_ifft_fft);
            S_xi = S;
            for i_xi = 1:length(S)
                if i_xi >xi
                    S_xi(i_xi,i_xi) = 0; 
                else
                    S_xi(i_xi,i_xi) = inv(S_xi(i_xi,i_xi));
                end
            end
            C_xi = V * S_xi * U';
            Y(kk1) = C_xi * phi'* y_GI(kk1);
            Y_shift = Y(kk1);
            Xmod_r(kk1) = Y_shift;
            
            kk1 = kk1 + N_inf;
        end
%         Xmod_r = y_GI;
        X_r = qamdemod(Xmod_r*norms(Nbps),M,'gray',"OutputType","bit");
        Neb = Neb + sum(sum( X_r ~= X )); %计算误比特数
        Ntb = Ntb + N_inf*W * Nbps;
        if Neb > Target_neb,break;end
    end
    if i == 0
        sigPow = sigPow/N_inf/W/N_iter;
    else
        Ber = Neb/Ntb;
        fprintf('EbN0=%3d[dB],BER=%4d/%8d=%11.3e\n',EbN0(i),Neb,Ntb,Ber);
        Ber_buf(i) = Ber;
        if Ber < 1e-6 , break;end
    end
end

disp('Simulation finished')
EbN0dB = [0:1:30];
M = 2^Nbps;
figure;
% ber_AWGN = ber_QAM(EbN0dB,M,'AWGN');
ber_Theory = berawgn(EbN0dB, 'psk',M, 'nondiff');
semilogy(EbN0dB,ber_Theory,'r:'),hold on
semilogy(EbN0(1:i),Ber_buf,'b--s');
grid on;
axis([EbN0(1) EbN0(end) 1e-6 1])
legend('AWGN analytic','Simulation')
xlabel('EbN0[dB]'),ylabel('BER')

function [phi,c_ifft_fft] = phi_c_ifft_fft(N,rho,alpha)
    phi_row = zeros(1,N);
    phi = zeros(rho*N,N);
    for i = 1:N
       phi_row(i) =  exp(1j*2*pi*alpha*(i-1)/(rho*N));
       
    end
    for i = 1:N*rho
       phi(i,:) = phi_row.^(i-1); 
    end
    c_ifft_fft = phi'*phi/rho/N;
end

function ber = ber_QAM(EbN0dB,M,AWGN_or_Rayleigh)
N = length(EbN0dB);
sqM = sqrt(M);
a = 2*(1-power(sqM,-1))/log2(sqM);
b = 6*log2(sqM)/(M-1);
if nargin<3
   AWGN_or_Rayleigh = 'AWGN';
   
end

ber = a * Q(sqrt(b*10.^(EbN0dB/10)));

end
function y = Q(x)
    y = erfc(x/sqrt(2))/2;
end



