function message = sign_decoder(bit_stream, alphabet, symbol_table)

  code_length = 6; 
  message = '';
  num_bits = length(bit_stream);
  num_symbols = length(alphabet);

  for i = 1:code_length:num_bits
    binary_code = char(bit_stream(i:i+code_length-1) + '0');
    
    index = -1; 
    for j = 1:size(symbol_table, 1)
        if strcmp(symbol_table(j,:), binary_code)
            index = j;
            break; 
        end
    end

    if index == -1
        error(['Неизвестный бинарный код: ' binary_code]);
    end

    symbol = alphabet(index);

    message = [message, symbol];
  end
end