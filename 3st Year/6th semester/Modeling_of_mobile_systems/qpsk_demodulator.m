function output_bits = qpsk_demodulator(received_symbols)

num_symbols = length(received_symbols);
output_bits = zeros(1, 2 * num_symbols); 
bit_index = 1; 

for i = 1:num_symbols
    symbol = received_symbols(i);
    real_part = real(symbol);
    imag_part = imag(symbol);

    if real_part >= 0 && imag_part >= 0     
        output_bits(bit_index) = 0;
        output_bits(bit_index + 1) = 0;
    elseif real_part < 0 && imag_part >= 0  
        output_bits(bit_index) = 1;       
        output_bits(bit_index + 1) = 0;       
    elseif real_part < 0 && imag_part < 0   
        output_bits(bit_index) = 1;
        output_bits(bit_index + 1) = 1;
    elseif real_part >= 0 && imag_part < 0  
        output_bits(bit_index) = 0;     
        output_bits(bit_index + 1) = 1;   

    end

    bit_index = bit_index + 2; 
end

end