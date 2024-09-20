function [ S_est ] = IC(R)

	global triu_C;

	N_subcarrier = size(R, 1);
	W  = size(R, 2);

	S_est = zeros(N_subcarrier, W);

	m = N_subcarrier;
	S_est(m, :) = R(m, :) / triu_C(m, m);

	% Slicing
	S_est(m, :) = slicing( S_est(m, :) );

	for m = N_subcarrier - 1 : -1 : 1

		summation = triu_C(m, m + 1 : N_subcarrier) * S_est(m + 1 : N_subcarrier, :);

		S_est(m, :) = 1 / triu_C(m, m) * (R(m, :) - summation);

		S_est(m, :) = slicing( S_est(m, :) );

	end



end

