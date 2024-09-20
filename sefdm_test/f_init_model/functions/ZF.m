function [ S_est ] = ZF(R)

	global inv_C;

	S_est = inv_C * R;

end

