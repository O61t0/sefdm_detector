function [ S_est ] = TSVD(R)
%TSVD
	global trunc_C;

	S_est = trunc_C * R;

end


