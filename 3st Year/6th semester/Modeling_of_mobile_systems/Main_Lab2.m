clc;
clear;
close all;

%   Параметры  
message_length_symbols = 65;
bits_per_symbol = 6;
input_seq_length = message_length_symbols * bits_per_symbol; % N = 390
fprintf('Длина исходной битовой последовательности: %d бит\n', input_seq_length);

K = 7; % Длина кодового ограничения
G1_oct = 171;
G2_oct = 133;

fprintf('Полином G1 (oct): %o\n', G1_oct);
fprintf('Полином G2 (oct): %o\n', G2_oct);

tblen = 5 * K;
fprintf('Глубина обратного просмотра для Витерби (tblen): %d\n', tblen);

% Создаем решетку 
trellis = poly2trellis(K, [G1_oct G2_oct]);
fprintf('Структура решетки для кодера/декодера создана.\n\n');

%   Генерация входных данных  
input_bits = randi([0 1], 1, input_seq_length);
fprintf('Сгенерирована входная последовательность (первые 20 бит): %s...\n', num2str(input_bits(1:min(20, input_seq_length))));

%   Подготовка к кодированию (Терминирование)  
num_memory_bits = K - 1;
% Добавляем K-1 нулей перед вызовом кодера
input_bits_terminated = [input_bits, zeros(1, num_memory_bits)];
fprintf('Добавлено %d терминирующих нулей. Общая длина для кодера: %d бит\n', num_memory_bits, length(input_bits_terminated));

%   Сверточное кодирование -
fprintf('Выполняется сверточное кодирование...\n');
% Передаем терминированную последовательность и решетку
encoded_bits = convolutional_encoder(input_bits_terminated, trellis);
fprintf('Кодирование завершено.\n');
% Длина должна быть 2 * (N + K - 1)
expected_encoded_len = 2 * (input_seq_length + K - 1);
fprintf('Длина закодированной последовательности: %d бит (ожидалось %d)\n', length(encoded_bits), expected_encoded_len);
fprintf('Закодированная последовательность (первые 40 бит): %s...\n', num2str(encoded_bits(1:min(40, length(encoded_bits)))));

%   Имитация канала (без шума)  
received_bits = encoded_bits;
fprintf('\nКанал без шума: принятая последовательность = закодированная.\n\n');

%   Декодирование Витерби 
fprintf('Выполняется декодирование Витерби...\n');
% Декодеру нужна та же решетка и tblen
decoded_bits_full = viterbi_decoder(received_bits, trellis, tblen);
fprintf('Декодирование завершено.\n');
fprintf('Полная длина декодированной последовательности (включая хвост): %d бит\n', length(decoded_bits_full));

%   Извлечение полезных данных 
decoded_bits = decoded_bits_full(1:input_seq_length);
fprintf('Длина извлеченной полезной декодированной последовательности: %d бит (ожидалось %d)\n', length(decoded_bits), input_seq_length);
fprintf('Извлеченная декодированная последовательность (первые 20 бит): %s...\n', num2str(decoded_bits(1:min(20, length(decoded_bits)))));

%   Проверка 
fprintf('\nПроверка результата...\n');
if length(input_bits) ~= length(decoded_bits)
    fprintf('ОШИБКА: Длина исходной (%d) и извлеченной декодированной (%d) последовательностей не совпадают!\n', length(input_bits), length(decoded_bits));
else
    num_errors = sum(input_bits ~= decoded_bits);
    if num_errors == 0
        fprintf('УСПЕХ: Декодированная последовательность (полезная часть) полностью совпадает с исходной!\n');
    else
        fprintf('ОШИБКА: Найдено %d ошибок в декодированной последовательности (полезной части).\n', num_errors);
        error_indices = find(input_bits ~= decoded_bits);
        fprintf('Первые несколько позиций ошибок: %s...\n', num2str(error_indices(1:min(10, length(error_indices)))));
    end
    BER = num_errors / length(input_bits);
    fprintf('Bit Error Rate (BER): %e\n', BER);
end

fprintf('\nРабота скрипта Main_Lab2 завершена.\n');