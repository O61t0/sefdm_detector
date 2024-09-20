function init_detector_const(Q, N, alpha, modulation,itera,t)
% detector算法所需的全局常量

	global modulation_method;

	global inv_C;  % for ZF
	global triu_C;  % for IC
	global trunc_C trunc_index; % for TSVD
    
	% for ML:
	global CS;
	global inv_herm_F;
	global S;

	% for ID
	global eyelamda_C;
	global lamda; % convergence factor (from 1 to 2)
	global itera_num; % number of iteration
    global F
    global C
    % for Monte Carlo Detector
    global monte_carlo_samples; % Number of Monte Carlo samples
    global random_signals;       % Random signals generated for Monte Carlo detection
    global constellation_points;
	modulation_method = modulation;
	
    if N <= 12
			S = fullfact(repmat(4, 1, N));
    else
        S = 1;
    end
	
	
	S(S == 1) = +1 + 1i;
	S(S == 2) = -1 + 1i;
	S(S == 3) = -1 - 1i;
	S(S == 4) = +1 - 1i;
	S = S.';
    
	trunc_index = ceil(N) ;
    


	F = generate_idft_matrix( N, alpha );
	C = F' * F/N;

	inv_C = inv(C);
	triu_C = triu(C);

    inv_herm_F = inv(F');
	CS = C * S;

	[U,E,V] = svd(C);
	% for i = 1 : trunc_index
	%     trunc_C = V(i) * U(i)' ./ E(i, i);
    % end
    S_xi = E;
    xi = t;
    for i_xi = 1:length(E)
         if i_xi >xi
             S_xi(i_xi,i_xi) = 0; 
         else
             S_xi(i_xi,i_xi) = inv(S_xi(i_xi,i_xi));
         end
     end
     trunc_C = V * S_xi * U';

	lamda = 1;
	itera_num = itera; % 迭代次数
	eyelamda_C = eye(N) - lamda * C;
    
    % Initialize Monte Carlo Detector parameters
    monte_carlo_samples = 1000; % 设置蒙特卡洛样本数量
    random_signals = randn(N, monte_carlo_samples) + 1i * randn(N, monte_carlo_samples); % 生成随机信号
    
end