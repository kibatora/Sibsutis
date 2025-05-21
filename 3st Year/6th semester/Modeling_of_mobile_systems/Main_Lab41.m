clc;
clear;
close all;

% --- Параметры ---
input_seq_length = 390; % Длина входной битовой последовательности
fprintf('Длина входной битовой последовательности: %d бит\n', input_seq_length);

if mod(input_seq_length, 2) ~= 0
    error('Длина входной последовательности должна быть четной!');
end
output_symbol_length = input_seq_length / 2;
fprintf('Ожидаемая длина последовательности символов: %d\n', output_symbol_length);

% --- Генерация входных данных ---
input_bits = randi([0 1], 1, input_seq_length);
fprintf('Сгенерирована входная последовательность (первые 20 бит): %s...\n', num2str(input_bits(1:min(20, input_seq_length))));

% --- QPSK Модуляция ---
fprintf('Выполняется QPSK модуляция...\n');
qpsk_symbols = qpsk_modulator(input_bits);
fprintf('Модуляция завершена.\n');
fprintf('Длина последовательности символов: %d (ожидалось %d)\n', length(qpsk_symbols), output_symbol_length);
fprintf('Модулированные символы (первые 10): \n');
disp(qpsk_symbols(1:min(10, length(qpsk_symbols))));

% --- Имитация канала (без шума) ---
received_symbols = qpsk_symbols;
fprintf('\nКанал без шума: принятые символы = переданные символы.\n\n');

% --- QPSK Демодуляция ---
fprintf('Выполняется QPSK демодуляция...\n');
demodulated_bits = qpsk_demodulator(received_symbols);
fprintf('Демодуляция завершена.\n');
fprintf('Длина демодулированной последовательности: %d бит (ожидалось %d)\n', length(demodulated_bits), input_seq_length);
fprintf('Демодулированная последовательность (первые 20 бит): %s...\n', num2str(demodulated_bits(1:min(20, length(demodulated_bits)))));

% --- Проверка ---
fprintf('\nПроверка результата...\n');
if length(input_bits) ~= length(demodulated_bits)
    fprintf('ОШИБКА: Длина исходной (%d) и демодулированной (%d) последовательностей не совпадают!\n', length(input_bits), length(demodulated_bits));
else
    num_errors = sum(input_bits ~= demodulated_bits);
    if num_errors == 0
        fprintf('УСПЕХ: Демодулированная последовательность полностью совпадает с исходной!\n');
    else
        fprintf('ОШИБКА: Найдено %d ошибок в демодулированной последовательности.\n', num_errors);
        error_indices = find(input_bits ~= demodulated_bits);
        fprintf('Первые несколько позиций ошибок: %s...\n', num2str(error_indices(1:min(10, length(error_indices)))));
    end
    BER = num_errors / length(input_bits);
    fprintf('Bit Error Rate (BER): %e\n', BER);
end

% --- Визуализация созвездия ---
figure;
plot(real(received_symbols), imag(received_symbols), 'b*'); % Принятые символы
hold on;
A = 1/sqrt(2);
ideal_constellation = [A+1j*A, -A+1j*A, -A-1j*A, A-1j*A];
plot(real(ideal_constellation), imag(ideal_constellation), 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Идеальные точки
grid on;
axis equal;
xlim([-1.5*A 1.5*A]);
ylim([-1.5*A 1.5*A]);
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
title('Созвездие QPSK (принятые и идеальные символы)');
legend('Принятые символы', 'Идеальные точки');

N_QPSK_for_lab5 = output_symbol_length; % Это количество QPSK символов
output_filename_lab4 = 'lab4_qpsk_output.mat';
save(output_filename_lab4, 'qpsk_symbols', 'N_QPSK_for_lab5');
fprintf('\nQPSK символы и их количество сохранены в файл: %s\n', output_filename_lab4);


fprintf('\nРабота скрипта Main_Lab4 завершена.\n');

