function decoded_bits = viterbi_decoder(received_bits, trellis, tblen)

% Используем встроенную функцию MATLAB vitdec
decoded_bits = vitdec(received_bits, trellis, tblen, 'term', 'hard');

end