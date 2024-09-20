function [ modulation_sym ] = sefdm_allocate_subcarriers( modulation_sym, mode )
% Extract or put data 
	
	
	global sefdm_N_right_inf_subcarr;
	global sefdm_N_left_inf_subcarr;
	global sefdm_right_GI_len;
	global sefdm_left_GI_len;

	W = size(modulation_sym, 2); 

	if strcmp(mode, 'tx')


		modulation_sym = [ ...
			modulation_sym(sefdm_N_right_inf_subcarr + 1 : end, 1 : W); ... % 右侧
			zeros(1, W); ...                                             % DC
			modulation_sym(1 : sefdm_N_right_inf_subcarr, 1 : W); ... % 左侧
			zeros(sefdm_right_GI_len, W); ...
			zeros(sefdm_left_GI_len,  W); ...
		];

	elseif strcmp(mode, 'rx')


		index_2 = 1                            : sefdm_N_left_inf_subcarr;
		index_1 = sefdm_N_left_inf_subcarr + 2 : sefdm_N_left_inf_subcarr + 2 + sefdm_N_right_inf_subcarr - 1;

		modulation_sym = ...
			modulation_sym([index_1, index_2], 1 : W);

	else
		error('Bad @mode');
	end
	
end

