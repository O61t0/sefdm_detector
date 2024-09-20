% Yunsheng
% 2024-8-5
function sefdm_init(FFT_size, alpha, right_GI_len, left_GI_len, modulation,itera,t)
% 初始化全局变量  包括生成SEFDM信号的全局变量、检测器变量
%
% FFT_size - 16、32、64、128

	
    path(path, '../f_init_model/functions/');

	global sefdm_FFT_size;            % FFT size
	global sefdm_alpha;               % compressed factor
	global sefdm_N_subcarr;           % numbers of subcarriers
	global sefdm_N_add_zero;          % numbers of adding padding 0
	global sefdm_N_inf_sub_carr;      % Number of subcarriers for information (for modulation symbols)
	global sefdm_N_right_inf_subcarr; % Number of information subcarriers to the right of the zero frequency
	global sefdm_N_left_inf_subcarr;  % 
	global sefdm_right_GI_len;        % 
	global sefdm_left_GI_len;         % 按零频率左侧频率计算的保护间隔长度

	
	N = FFT_size ;  % effective carriers
	N_inf = N - right_GI_len - left_GI_len - 1; % 信息（调制符号）子载波数

	N_add_zero = FFT_size - N; % Padding 0 number

	if mod(N_inf, 2) == 0
		N_right_inf_subcarr = N_inf / 2;
		N_left_inf_subcarr  = N_inf / 2;
	else
		if right_GI_len < left_GI_len
			N_right_inf_subcarr = ceil(N_inf / 2);% 右多故右大 右向上取整
		else
			N_right_inf_subcarr = floor(N_inf / 2);% 左多故左大 右向下取整
		end
			N_left_inf_subcarr  = N_inf - N_right_inf_subcarr;
	end
	
    % Initialize detector parames

    init_detector_const(N, N, alpha, modulation,itera,t);

	%% Initialze Global parames	
    sefdm_FFT_size            = FFT_size;
	sefdm_alpha                = alpha;
	sefdm_N_subcarr           = N;  % effective carriers
	sefdm_N_inf_sub_carr      = N_inf; % carriers without Guard Interval
	sefdm_N_add_zero          = N_add_zero;
	sefdm_N_right_inf_subcarr = N_right_inf_subcarr;
	sefdm_N_left_inf_subcarr  = N_left_inf_subcarr;
	sefdm_right_GI_len        = right_GI_len;
	sefdm_left_GI_len         = left_GI_len;
	
end

