clc;
clear;
close all;

fprintf('Лабораторная работа №6: Модель канала передачи\n');
fprintf('Вариант 4\n\n');

% --- Загрузка данных из Лабораторной работы №5 ---
input_filename_lab5 = 'lab5_ofdm_output.mat';
if exist(input_filename_lab5, 'file')
    % Загружаем все нужные переменные из файла Лаб. 5
    load(input_filename_lab5, 'ofdm_symbol_time_cp', 'N_IFFT', 'Tcp_samples', 'N_Z', 'N_active', 'pilot_indices_freq', 'data_indices_freq', 'pilot_value', 'N_QPSK_data', 'ARS_pilot_step'); % Добавили еще переменные
    fprintf('Данные из Лабораторной работы №5 (%s) успешно загружены.\n', input_filename_lab5);
else
    error('Файл с результатами Лабораторной работы №5 (%s) не найден! Сначала запустите Main_Lab5.m', input_filename_lab5);
end
% ---------------------------------------------------
L_original_ofdm_symbol = length(ofdm_symbol_time_cp); % Длина входа для канала
fprintf(' Длина входного OFDM символа (с CP): %d отсчетов\n', L_original_ofdm_symbol);

% --- Параметры Канала для Варианта 4 (из таблицы PDF стр. 26) ---
NB_rays = 9;            % Количество лучей
B_signal_Hz = 9e6;      % Полоса сигнала (9 МГц)
f0_carrier_Hz = 2.4e9;  % Несущая частота (2.4 ГГц)

N0_dB_power = -10; % dBW - средний уровень шума


fprintf('\nПараметры канала:\n NB_rays = %d\n B_signal_Hz = %.1e Гц\n f0_carrier_Hz = %.1e Гц\n N0_dB_power (для wgn) = %.1f dBW\n', ...
        NB_rays, B_signal_Hz, f0_carrier_Hz, N0_dB_power);

% --- Моделирование Канала ---
S_rx_output = channel_model(ofdm_symbol_time_cp, L_original_ofdm_symbol, NB_rays, B_signal_Hz, f0_carrier_Hz, N0_dB_power);

fprintf('\n--- Результаты Модели Канала ---\n');
fprintf('Длина сигнала на выходе канала: %d отсчетов\n', length(S_rx_output));
fprintf('Сигнал на выходе канала (первые 10 отсчетов):\n');
disp(S_rx_output(1:min(10, length(S_rx_output))));

output_filename_lab6 = 'lab6_channel_output.mat';
save(output_filename_lab6, 'S_rx_output', ...
     'N_IFFT', 'Tcp_samples', 'N_Z', 'N_active', ...
     'pilot_indices_freq', 'data_indices_freq', 'pilot_value', 'ARS_pilot_step', ...
     'L_original_ofdm_symbol'); % Сохраняем и длину
fprintf('\nРезультаты модели канала сохранены в файл: %s\n', output_filename_lab6);


figure;
subplot(2,1,1);
plot(0:L_original_ofdm_symbol-1, abs(ofdm_symbol_time_cp).^2, 'b-', 'DisplayName', 'До канала');
hold on;
plot(0:length(S_rx_output)-1, abs(S_rx_output).^2, 'r-', 'DisplayName', 'После канала');
title('Мощность OFDM-символа до и после канала');
xlabel('Отсчет времени');
ylabel('Мощность |s(t)|^2');
legend show;
grid on;
xlim([-1 L_original_ofdm_symbol]);

fprintf('\nРабота скрипта Main_Lab6 завершена.\n');