function output_bits = deinterleaver(interleaved_bits, permutation_vector)

L = length(interleaved_bits); 
L_perm = length(permutation_vector);

if L ~= L_perm
    error('Длина перемешанной последовательности (%d) не совпадает с длиной вектора перестановок (%d)!', L, L_perm);
end

output_bits = zeros(1, L);

for i = 1:L
    output_bits(permutation_vector(i)) = interleaved_bits(i);
end

end