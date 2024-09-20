function [ S_est ] = ML( R )
% 最大似然
%
	global CS;
	global inv_herm_F;
	global S;

	W = size(R, 2);

	metric = zeros(size(CS, 2), W);
	for k = 1 : size(CS, 2) % 遍历所有模板
		
		CS_ = repmat(CS(:, k), 1, W);
		metric(k, :) = sum( abs(inv_herm_F * (R - CS_)).^2 );

	end

	[~, min_index] = min(metric);
	S_est = S(:, min_index);


end
