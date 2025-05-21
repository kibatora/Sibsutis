clc;
clear;
close all;

fprintf('Лабораторная работа №7: Эквалайзирование, OFDM демодуляция\n');
fprintf('Вариант 4\n\n');

% --- ЗАГРУЗКА/ГЕНЕРАЦИЯ ПАРАМЕТРОВ И СИГНАЛОВ ИЗ ПРЕДЫДУЩИХ ЛР ---
% === Параметры OFDM модулятора (Лаб. 5) ===
N_QPSK_data_lab5 = 390;
ARS_pilot_step_lab5 = 6;
Tcp_fraction_of_NFFT_lab5 = 1/4;
C_guard_fraction_lab5 = 1/4;
pilot_value_tx_lab5 = (1 + 1j) / sqrt(2);

% Генерируем исходные QPSK символы (как в Main_Lab5)
A_qpsk_lab5 = 1/sqrt(2);
qpsk_map_lab5 = [A_qpsk_lab5 + 1j*A_qpsk_lab5, A_qpsk_lab5 - 1j*A_qpsk_lab5, -A_qpsk_lab5 + 1j*A_qpsk_lab5, -A_qpsk_lab5 - 1j*A_qpsk_lab5];
rand_indices_for_map_lab5 = randi([1 4], 1, N_QPSK_data_lab5);
original_qpsk_symbols = qpsk_map_lab5(rand_indices_for_map_lab5); % ЭТИ СИМВОЛЫ МЫ ХОТИМ ВОССТАНОВИТЬ

% Вызов OFDM модулятора для получения параметров и S_tx_ofdm
fprintf('1. Запуск OFDM модулятора (для генерации S_tx и параметров)...\n');
[S_tx_ofdm, N_IFFT, Tcp_samples, N_Z, N_active, pilot_indices_freq_global, data_indices_freq_global] = ...
    ofdm_modulator(original_qpsk_symbols, N_QPSK_data_lab5, ARS_pilot_step_lab5, ...
                   C_guard_fraction_lab5, Tcp_fraction_of_NFFT_lab5, pilot_value_tx_lab5);
L_tx_original_length = length(S_tx_ofdm);
fprintf('S_tx_ofdm сгенерирован. Длина: %d\n', L_tx_original_length);

% Получаем индексы пилотов и данных ВНУТРИ АКТИВНОЙ ЗОНЫ (1..N_active)
pilot_indices_active_band = [];
data_indices_active_band = [];
if ~isempty(pilot_indices_freq_global) % Если ofdm_modulator вернул глобальные индексы
    first_active_idx_fft_known = N_Z + 1;
    pilot_indices_active_band = pilot_indices_freq_global - first_active_idx_fft_known + 1;
    data_indices_active_band  = data_indices_freq_global - first_active_idx_fft_known + 1;
else % Если ofdm_modulator НЕ вернул, рассчитываем как в нем
    temp_pilot_indices_active = 1:ARS_pilot_step_lab5:N_active;
    pilot_indices_active_band = temp_pilot_indices_active;
    data_indices_active_band = setdiff(1:N_active, temp_pilot_indices_active);
end
fprintf('Индексы пилотов в активной зоне (1..%d): %d шт.\n',N_active, length(pilot_indices_active_band));
fprintf('Индексы данных в активной зоне (1..%d): %d шт.\n\n', N_active, length(data_indices_active_band));


% === Параметры Канала (Лаб. 6) ===
NB_rays_lab6 = 9;
B_signal_Hz_lab6 = 9e6;
f0_carrier_Hz_lab6 = 2.4e9;
N0_dB_power_per_sample_lab6 = -70; % Используем то же значение для теста
% N0_dB_power_per_sample_lab6 = -120; % Попробуйте с меньшим шумом для лучшей работы эквалайзера

% Вызов Модели Канала
fprintf('2. Запуск Модели Канала...\n');
S_channel_out = channel_model(S_tx_ofdm, NB_rays_lab6, B_signal_Hz_lab6, f0_carrier_Hz_lab6, N0_dB_power_per_sample_lab6, L_tx_original_length);
fprintf('Сигнал с выхода канала (S_channel_out) получен. Длина: %d\n\n', length(S_channel_out));

% --- OFDM Демодуляция и Эквалайзирование ---
fprintf('3. Запуск OFDM Демодулятора и Эквалайзера...\n');
[qpsk_symbols_demod_eq, H_est_active, C_active_received, C_equalized_active] = ...
    ofdm_demodulator_equalizer(S_channel_out, N_IFFT, Tcp_samples, N_Z, ...
                               pilot_indices_active_band, data_indices_active_band, pilot_value_tx_lab5);

fprintf('\n--- Результаты Демодуляции и Эквалайзирования ---\n');
fprintf('Количество извлеченных QPSK символов: %d (ожидалось %d)\n', length(qpsk_symbols_demod_eq), N_QPSK_data_lab5);
fprintf('Извлеченные QPSK символы (первые 5):\n');
disp(qpsk_symbols_demod_eq(1:min(5, length(qpsk_symbols_demod_eq))));
fprintf('Исходные QPSK символы (первые 5 для сравнения):\n');
disp(original_qpsk_symbols(1:min(5, length(original_qpsk_symbols))));

% --- Визуализация ---
figure;

% 1. Созвездие: Исходные QPSK символы (переданные данные)
subplot(2,2,1);
plot(real(original_qpsk_symbols), imag(original_qpsk_symbols), 'bo', 'MarkerFaceColor', 'b');
grid on; axis equal; xlim([-1.5 1.5]); ylim([-1.5 1.5]);
title('1. Исходные QPSK символы (данные)');
xlabel('In-Phase'); ylabel('Quadrature');

% 2. Созвездие: Принятые QPSK символы ПОСЛЕ эквалайзера
subplot(2,2,2);
plot(real(qpsk_symbols_demod_eq), imag(qpsk_symbols_demod_eq), 'r.', 'MarkerSize', 8);
grid on; axis equal; xlim([-2 2]); ylim([-2 2]); % Увеличим лимиты, т.к. шум может расширить
title('2. QPSK символы ПОСЛЕ эквалайзера');
xlabel('In-Phase'); ylabel('Quadrature');

% 3. АЧХ канала (оцененная) и принятый спектр до эквалайзера
subplot(2,2,3);
plot(1:N_active, abs(C_active_received), 'b.-', 'DisplayName', 'Принятый спектр |C_{active}|');
hold on;
plot(1:N_active, abs(H_est_active), 'r.-', 'DisplayName', 'Оценка АЧХ |H_{est}|');
grid on;
title('3. Амплитуды: Принятый спектр и Оценка АЧХ');
xlabel('Индекс активной поднесущей');
ylabel('Амплитуда');
legend show;
xlim([1 N_active]);

% 4. Спектр ПОСЛЕ эквалайзера
subplot(2,2,4);
plot(1:N_active, abs(C_equalized_active), 'g.-');
grid on;
title('4. Амплитудный спектр ПОСЛЕ эквалайзера |C_{eq}|');
xlabel('Индекс активной поднесущей');
ylabel('Амплитуда');
xlim([1 N_active]);
ylim([0 2]); % Ожидаем амплитуды около 1 после эквалайзера

fprintf('\nРабота скрипта Main_Lab7 завершена.\n');