function bit_stream = sign_encoder(message, alphabet, symbol_table)

  bit_stream = '';
  for i = 1:length(message)
    symbol = message(i);

    index = find(alphabet == symbol);

    if isempty(index)
      error(['Символ "' symbol '" отсутствует в алфавите.']);
    end

    binary_code = symbol_table(index, :); 

    bit_stream = [bit_stream, binary_code];
  end

  bit_stream = char(bit_stream); 
  bit_stream = double(bit_stream - '0');  
  bit_stream = uint8(bit_stream); 
  
end