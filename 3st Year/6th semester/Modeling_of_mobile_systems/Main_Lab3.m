clc;
clear;
close all;

% --- Параметры ---
message_length_symbols = 65;  % Длина сообщения в символах (из варианта)
bits_per_symbol = 6;        % Бит на символ (из Лаб. 1)
coding_rate = 1/2;          % Скорость кодирования (из Лаб. 2)

% Рассчитываем длину битовой последовательности после кодера
sequence_length = message_length_symbols * bits_per_symbol / coding_rate;
fprintf('Расчетная длина битовой последовательности: %d бит\n', sequence_length);

% --- Генерация входных данных ---
% Создаем случайную битовую последовательность нужной длины
% (имитируем выход сверточного кодера)
input_bits = randi([0 1], 1, sequence_length);
fprintf('Сгенерирована входная битовая последовательность (первые 20 бит): %s...\n', num2str(input_bits(1:min(20, sequence_length))));

% --- Генерация вектора перестановки ---
permutation_vector = generate_permutation(sequence_length);
fprintf('Сгенерирован вектор перестановок (первые 20 элементов): %s...\n', num2str(permutation_vector(1:min(20, sequence_length))));

% --- Прямое перемежение ---
fprintf('\nВыполняется прямое перемежение...\n');
interleaved_bits = interleaver(input_bits, permutation_vector);
fprintf('Перемежение завершено.\n');
fprintf('Перемешанная последовательность (первые 20 бит): %s...\n', num2str(interleaved_bits(1:min(20, sequence_length))));

% --- Обратное перемежение ---
fprintf('\nВыполняется обратное перемежение...\n');
% используем тот же самый permutation_vector
deinterleaved_bits = deinterleaver(interleaved_bits, permutation_vector);
fprintf('Обратное перемежение завершено.\n');
fprintf('Восстановленная последовательность (первые 20 бит): %s...\n', num2str(deinterleaved_bits(1:min(20, sequence_length))));

% --- Проверка ---
fprintf('\nПроверка результата...\n');
if isequal(input_bits, deinterleaved_bits)
    fprintf('УСПЕХ: Восстановленная последовательность совпадает с исходной!\n');
else
    fprintf('ОШИБКА: Восстановленная последовательность НЕ совпадает с исходной!\n');
    % Нахождение место расхождения
    diff_indices = find(input_bits ~= deinterleaved_bits);
    fprintf('Первое расхождение в позиции: %d\n', diff_indices(1));
end
