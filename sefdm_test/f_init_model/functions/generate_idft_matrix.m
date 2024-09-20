function [ idft_matrix ] = generate_idft_matrix( N, alpha )
% Q = rho *N = N
	phi_row = zeros(1,N);
    idft_matrix = zeros(N,N);
    for i = 1:N
       phi_row(i) =  exp(1j*2*pi*alpha*(i-1)/(N));
       
    end
    for i = 1:N
       idft_matrix(i,:) = phi_row.^(i-1); 
    end

end

