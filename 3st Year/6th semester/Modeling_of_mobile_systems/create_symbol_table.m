function [symbol_table, alphabet] = create_symbol_table()
  alphabet = char(['A':'Z', 'a':'z', '0':'9', '_', '-']); 
  num_symbols = length(alphabet);

  if num_symbols ~= 64
       error('Алфавит должен содержать 64 символа.');
  end

  symbol_table = char(zeros(num_symbols, 6));
  for i = 1:num_symbols
    binary_code = dec2bin(i-1, 6); 
    for j=1:6
        symbol_table(i,j) = binary_code(j);
    end
  end
end