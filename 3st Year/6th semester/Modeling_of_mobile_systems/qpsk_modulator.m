function qpsk_symbols = qpsk_modulator(input_bits)

N = length(input_bits);

if mod(N, 2) ~= 0
    warning('Длина входной битовой последовательности нечетная (%d). Добавлен 0 в конец.', N);
    input_bits = [input_bits, 0];
    N = N + 1;
end

num_symbols = N / 2;
qpsk_symbols = zeros(1, num_symbols); 
A = 1/sqrt(2);

bit_index = 1; 
for i = 1:num_symbols
    bit1 = input_bits(bit_index);  
    bit2 = input_bits(bit_index + 1); 

    if bit1 == 0 && bit2 == 0       
        qpsk_symbols(i) = A + 1j*A; 
    elseif bit1 == 0 && bit2 == 1   
        qpsk_symbols(i) = A - 1j*A; 
    elseif bit1 == 1 && bit2 == 0  
        qpsk_symbols(i) = -A + 1j*A; 
    elseif bit1 == 1 && bit2 == 1   
        qpsk_symbols(i) = -A - 1j*A; 
    end

    bit_index = bit_index + 2; 
end

end