function [ S_est ] = MMSE(R,N0,N)
%TSVD
    global C
    W_mmse = inv(C'*C+eye(N)./N0)*C';

	S_est = W_mmse * R;

end


