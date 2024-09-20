function [ bit ] = ConstellationDemap( sym, modulation )
	bit = zeros(2 * size(sym, 1), size(sym, 2));
	for j = 1 : size(sym, 2) 
		for i = 1 : size(sym, 1) 

			k = 2 * i;
			if real( sym(i, j) ) > 0
				if imag( sym(i, j) ) > 0
					bit([k - 1, k], j) = [1 1];
				else
					bit([k - 1, k], j) = [1 0];
				end
			else
				if imag( sym(i, j) ) > 0
					bit([k - 1, k], j) = [0 1];
				else
					bit([k - 1, k], j) = [0 0];
				end
			end

		end
	end

	
end

