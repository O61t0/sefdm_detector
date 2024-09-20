function [ R_unsm_est, R_sm_est ] = ID(R)

% ID

	global eyelamda_C;
	global lamda;
	global itera_num;
    
	R_sm_est = R;
	
	for iter = 1 : itera_num
		R_unsm_est = lamda * R + eyelamda_C * R_sm_est;
		de_s = 1 - iter / itera_num;
		R_sm_est = SoftMapping(R_unsm_est, de_s);
	end
	
end


function R_sm_est = SoftMapping(R_unsm_est, de_s)

	R_sm_est = R_unsm_est;
	re = real(R_unsm_est);
	im = imag(R_unsm_est);


	index1 = and(re > de_s, im > de_s);
	index2 = and(re <= -1 * de_s, im > de_s);
	index3 = and(re <= -1 * de_s, im <= -1 * de_s);
	index4 = and(re  > de_s, im <= -1 * de_s);

	R_sm_est(index1) = +1 + 1i;
	R_sm_est(index2) = -1 + 1i;
	R_sm_est(index3) = -1 - 1i;
	R_sm_est(index4) = +1 - 1i;

end



