clc;
clear;
close all;

fprintf('Лабораторная работа №5: OFDM-модуляция\n');
fprintf('Вариант 4\n\n');

% --- Загрузка данных из Лабораторной работы №4 ---
input_filename_lab4 = 'lab4_qpsk_output.mat';
if exist(input_filename_lab4, 'file')
    load(input_filename_lab4, 'qpsk_symbols', 'N_QPSK_for_lab5');
    fprintf('Данные из Лабораторной работы №4 (%s) успешно загружены.\n', input_filename_lab4);
    input_qpsk_symbols = qpsk_symbols; 
    N_QPSK_data = N_QPSK_for_lab5;   
    clear qpsk_symbols N_QPSK_for_lab5;
else
    error('Файл с результатами Лабораторной работы №4 (%s) не найден! Сначала запустите Main_Lab41.m', input_filename_lab4);
end

% --- Параметры Варианта 4 для OFDM ---
ARS_pilot_step = 6;
Tcp_fraction_of_NFFT = 1/4;
C_guard_fraction = 1/4;


fprintf('\nПараметры для OFDM:\n N_QPSK_data (из Лаб.4) = %d\n ARS = %d\n Tcp_fraction = %f\n C_guard = %f\n', ...
        N_QPSK_data, ARS_pilot_step, Tcp_fraction_of_NFFT, C_guard_fraction);
fprintf('\nИспользуются QPSK символы, полученные из Лаб. 4.\n');
fprintf('Входные QPSK символы (первые 5): \n');
disp(input_qpsk_symbols(1:min(5, N_QPSK_data)));

% Значение для опорных сигналов (пилотов)
pilot_value = (1 + 1j) / sqrt(2);
fprintf('Значение пилота: %f + %fj\n\n', real(pilot_value), imag(pilot_value));

% --- OFDM Модуляция
fprintf('Запуск OFDM модулятора...\n');
[ofdm_symbol_time_cp, N_IFFT, Tcp_samples, N_Z, N_active, pilot_indices_freq, data_indices_freq] = ...
    ofdm_modulator(input_qpsk_symbols, N_QPSK_data, ARS_pilot_step, C_guard_fraction, Tcp_fraction_of_NFFT, pilot_value);

fprintf('\n--- Результаты Модуляции ---\n');
fprintf('Количество активных поднесущих (N_active): %d\n', N_active);
fprintf('Количество пилотов (N_RS): %d\n', N_active - N_QPSK_data);
fprintf('Количество защитных нулей с каждой стороны (N_Z): %d\n', N_Z);
fprintf('Размер ОБПФ (N_IFFT): %d\n', N_IFFT);
fprintf('Длина циклического префикса (Tcp_samples): %d отсчетов\n', Tcp_samples);
fprintf('Итоговая длина OFDM символа во временной области (с CP): %d отсчетов\n', length(ofdm_symbol_time_cp));
fprintf('OFDM символ (первые 10 отсчетов):\n');
disp(ofdm_symbol_time_cp(1:min(10, length(ofdm_symbol_time_cp))));

% --- Визуализация ---
% Спектр OFDM-символа (до ОБПФ)
freq_vector_for_plot = zeros(1, N_IFFT);
freq_vector_for_plot(pilot_indices_freq) = pilot_value;
freq_vector_for_plot(data_indices_freq) = input_qpsk_symbols;

figure;
subplot(2,1,1);
stem(0:N_IFFT-1, abs(freq_vector_for_plot), 'MarkerFaceColor', 'b');
title(sprintf('Амплитудный спектр OFDM-символа (N_{FFT}=%d, N_{active}=%d, N_Z=%d)', N_IFFT, N_active, N_Z));
xlabel('Индекс поднесущей');
ylabel('|Амплитуда|');
grid on;
xlim([-1 N_IFFT]);

% Мощность OFDM-символа во времени
subplot(2,1,2);
plot(0:length(ofdm_symbol_time_cp)-1, abs(ofdm_symbol_time_cp).^2);
title(sprintf('Мощность OFDM-символа во времени (с CP, Tcp=%d)', Tcp_samples));
xlabel('Отсчет времени');
ylabel('Мощность |s(t)|^2');
grid on;
xlim([-1 length(ofdm_symbol_time_cp)]);

output_filename_lab5 = 'lab5_ofdm_output.mat';
save(output_filename_lab5, 'ofdm_symbol_time_cp', ...
     'N_IFFT', 'Tcp_samples', 'N_Z', 'N_active', ...
     'pilot_indices_freq', 'data_indices_freq', 'pilot_value', 'N_QPSK_data', 'ARS_pilot_step'); 
fprintf('\nРезультаты OFDM модуляции сохранены в файл: %s\n', output_filename_lab5);

fprintf('\nРабота скрипта Main_Lab5 завершена.\n');