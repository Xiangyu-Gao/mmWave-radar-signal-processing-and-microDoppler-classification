% reshape function in C order (similar to python reshape)
function [A_C_order] = reshape_C_order(A, new_shape)
% Permute the dimensions to reverse the order (to simulate row-major)
A_permuted = permute(A, ndims(A):-1:1);

% Reshape the permuted matrix
A_reshaped = reshape(A_permuted, fliplr(new_shape));

% Permute back to original order
A_C_order = permute(A_reshaped, ndims(A_reshaped):-1:1);
end