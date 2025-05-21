function interleaved_bits = interleaver(input_bits, permutation_vector)

L = length(input_bits); 
L_perm = length(permutation_vector); 

if L ~= L_perm
    error('Длина входной последовательности (%d) не совпадает с длиной вектора перестановок (%d)!', L, L_perm);
end

interleaved_bits = zeros(1, L);

for i = 1:L
    interleaved_bits(i) = input_bits(permutation_vector(i));
end

end