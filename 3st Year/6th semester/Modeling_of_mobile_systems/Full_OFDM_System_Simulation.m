clc;
clear;
close all;

fprintf('===== ЗАПУСК ПРАКТИКИ 8: РАСЧЕТ BER vs SNR =====\n\n');

rng_seed = 12345; 
rng(rng_seed);
fprintf('Генератор случайных чисел инициализирован значением: %d\n\n', rng_seed);


message_text_base = 'Hello_World_123-';
num_repetitions_message = 20; 
message_text = repmat(message_text_base, 1, num_repetitions_message);
fprintf('Используемое сообщение: (Базовое: "%s") x %d раз. Общая длина: %d символов\n', ...
        message_text_base, num_repetitions_message, length(message_text));

K_conv = 7; G1_oct_conv = 171; G2_oct_conv = 133;
tblen_viterbi = 5 * K_conv;

ARS_pilot_step_ofdm = 4;
fprintf('Установлен ARS (шаг пилотов) = %d\n', ARS_pilot_step_ofdm);

Tcp_fraction_of_NFFT_ofdm = 1/4; C_guard_fraction_ofdm = 1/4;
pilot_value_ofdm = (1 + 1j) / sqrt(2);
NB_rays_channel = 9; B_signal_Hz_channel = 9e6; f0_carrier_Hz_channel = 2.4e9;

N0_dB_values = -125:5:-70; 

num_N0_points = length(N0_dB_values);
results_BER = zeros(1, num_N0_points);
results_SER = zeros(1, num_N0_points);
results_SNR_dB = zeros(1, num_N0_points);

fprintf('\nНачинается цикл по %d значениям N0 (от %.1f dBW до %.1f dBW)...\n', num_N0_points, N0_dB_values(1), N0_dB_values(end));
fprintf('ВАЖНО: Убедитесь, что в channel_model.m установлен подобранный channel_gain_factor (например, 13 или 20)!\n');


for i_n0 = 1:num_N0_points
    current_N0_dB = N0_dB_values(i_n0);
    
    % --- ЭТАП 1 (Передатчик): Знаковое кодирование ---
    [symbol_table_sign, alphabet_sign] = create_symbol_table();
    info_bits_tx = sign_encoder(message_text, alphabet_sign, symbol_table_sign);

    % --- ЭТАП 2 (Передатчик): Сверточное кодирование ---
    trellis_conv = poly2trellis(K_conv, [G1_oct_conv G2_oct_conv]);
    input_bits_for_conv = info_bits_tx;
    encoded_bits_conv_tx = convolutional_encoder(input_bits_for_conv, trellis_conv);
    
    % --- ЭТАП 3 (Передатчик): Перемежение ---
    sequence_length_interleaver = length(encoded_bits_conv_tx);
    permutation_vector_interleaver = generate_permutation(sequence_length_interleaver);
    interleaved_bits_tx = interleaver(encoded_bits_conv_tx, permutation_vector_interleaver);
    
    % --- ЭТАП 4 (Передатчик): QPSK-модуляция ---
    input_bits_for_qpsk_tx = interleaved_bits_tx;
    if mod(length(input_bits_for_qpsk_tx), 2) ~= 0, input_bits_for_qpsk_tx = [input_bits_for_qpsk_tx, 0]; end
    qpsk_symbols_tx = qpsk_modulator(input_bits_for_qpsk_tx);
    N_QPSK_data_for_ofdm = length(qpsk_symbols_tx);
    
    % --- ЭТАП 5 (Передатчик): OFDM-модуляция ---
    [ofdm_signal_tx_cp, N_IFFT_ofdm, Tcp_samples_ofdm, N_Z_ofdm, N_active_ofdm, pilot_indices_freq_ofdm, data_indices_freq_ofdm] = ...
        ofdm_modulator(qpsk_symbols_tx, N_QPSK_data_for_ofdm, ARS_pilot_step_ofdm, C_guard_fraction_ofdm, Tcp_fraction_of_NFFT_ofdm, pilot_value_ofdm);
    
    % --- ЭТАП 6: Модель канала передачи ---
    L_original_ofdm_for_channel = length(ofdm_signal_tx_cp);
    % Теперь channel_model возвращает и Smpy_out
    [ofdm_signal_rx, Smpy_signal_from_channel] = channel_model(ofdm_signal_tx_cp, L_original_ofdm_for_channel, NB_rays_channel, B_signal_Hz_channel, f0_carrier_Hz_channel, current_N0_dB);
    
    % --- Расчет SNR для текущего N0 ---
    P_Smpy_avg_linear = mean(abs(Smpy_signal_from_channel).^2);
    P_noise_linear = 10^(current_N0_dB / 10);
    
    SNR_linear_current = P_Smpy_avg_linear / P_noise_linear;
    SNR_dB_current = 10*log10(SNR_linear_current);
    results_SNR_dB(i_n0) = SNR_dB_current;
    % ------------------------------------

    % --- ЭТАП 7 (Приемник): OFDM-демодуляция и Эквалайзинг ---
    [qpsk_symbols_rx_eq, ~, ~, ~, ~] = ... 
        ofdm_demodulator_equalizer(ofdm_signal_rx, N_IFFT_ofdm, Tcp_samples_ofdm, N_Z_ofdm, N_active_ofdm, pilot_indices_freq_ofdm, data_indices_freq_ofdm, pilot_value_ofdm, ARS_pilot_step_ofdm);
    
    % --- ЭТАП 8 (Приемник): QPSK-демодуляция ---
    bits_rx_after_qpsk_demod = qpsk_demodulator(qpsk_symbols_rx_eq);
    
    % --- ЭТАП 9 (Приемник): Деперемежение ---
    if length(bits_rx_after_qpsk_demod) ~= length(permutation_vector_interleaver)
         error('Критическая ошибка: Несоответствие длин для деперемежителя. RX: %d, PermVec: %d на N0=%.1f dBW', length(bits_rx_after_qpsk_demod), length(permutation_vector_interleaver), current_N0_dB);
    end
    bits_rx_after_deinterleaving = deinterleaver(bits_rx_after_qpsk_demod, permutation_vector_interleaver);
    
    % --- ЭТАП 10 (Приемник): Декодирование Витерби ---
    decoded_info_bits_rx = vitdec(bits_rx_after_deinterleaving, trellis_conv, tblen_viterbi, 'trunc', 'hard');
    
    % --- ЭТАП 11 (Приемник): Знаковое декодирование ---
    decoded_message_text = sign_decoder(decoded_info_bits_rx, alphabet_sign, symbol_table_sign);
        
    % --- ЭТАП 12: Расчет BER и SER для текущего N0 ---
    N_info_bits_total = length(info_bits_tx);
    if length(decoded_info_bits_rx) ~= N_info_bits_total
        num_bit_errors_current = N_info_bits_total; 
    else
        num_bit_errors_current = sum(info_bits_tx ~= decoded_info_bits_rx);
    end
    BER_current = num_bit_errors_current / N_info_bits_total;
    
    original_message_length_chars = length(message_text);
    decoded_message_text_for_ser = decoded_message_text;
    if length(decoded_message_text) > original_message_length_chars
        decoded_message_text_for_ser = decoded_message_text(1:original_message_length_chars);
    elseif length(decoded_message_text) < original_message_length_chars && original_message_length_chars > 0
        decoded_message_text_for_ser = [decoded_message_text, repmat(alphabet_sign(1), 1, original_message_length_chars - length(decoded_message_text))];
    end
    num_symbol_errors_current = sum(message_text ~= decoded_message_text_for_ser);
    if original_message_length_chars > 0, SER_current = num_symbol_errors_current / original_message_length_chars; else SER_current = 0; end
    
    fprintf('  N0=%.1f dBW (SNR=%.2f dB): BER = %e (%6d/%6d err), SER = %.4f (%3d/%3d err)\n', ...
            current_N0_dB, SNR_dB_current, BER_current, num_bit_errors_current, N_info_bits_total, ...
            SER_current, num_symbol_errors_current, original_message_length_chars);
            
    results_BER(i_n0) = BER_current;
    results_SER(i_n0) = SER_current;
end
fprintf('Цикл по N0 завершен.\n');


fprintf('\n\n--- Построение графика BER от SNR ---\n');


[sorted_SNR_dB, sort_indices] = sort(results_SNR_dB);
sorted_BER = results_BER(sort_indices);


figure('Name', 'BER vs SNR', 'NumberTitle', 'off', 'Position', [50, 50, 800, 600]);
semilogy(sorted_SNR_dB, sorted_BER, 'o-', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', 'BER симуляции');
grid on;
xlabel('SNR (dB) на входе OFDM демодулятора');
ylabel('BER (Bit Error Rate)');
title(sprintf('Зависимость BER от SNR для OFDM системы (Сообщение: %d инф. бит, ARS=%d)', N_info_bits_total, ARS_pilot_step_ofdm));
legend('show', 'Location', 'southwest');
min_ber_plot = 1e-5; 
if any(results_BER > 0)
    min_ber_plot = max(min_ber_plot, min(results_BER(results_BER > 0)) / 10);
end
if all(results_BER == 0) 
    min_ber_plot = 1e-6; 
end
ylim([min_ber_plot 1]);


interesting_idx_candidates = find(results_BER > 0 & results_BER < 0.1); 
if ~isempty(interesting_idx_candidates)
    interesting_idx = interesting_idx_candidates(floor(length(interesting_idx_candidates)/2)+1); 
else
    [~, interesting_idx_fallback] = min(abs(results_SNR_dB - 10)); 
    if ~isempty(interesting_idx_fallback)
         interesting_idx = interesting_idx_fallback;
    else
       interesting_idx = floor(num_N0_points / 2) + 1;
       if isempty(interesting_idx) || interesting_idx == 0 || interesting_idx > num_N0_points, interesting_idx = 1; end
    end
end
N0_for_detailed_plots = N0_dB_values(interesting_idx);
SNR_for_detailed_plots_title = results_SNR_dB(interesting_idx);
BER_for_detailed_plots_title = results_BER(interesting_idx);

fprintf('\n--- Вывод детальных графиков для N0 = %.1f dBW (SNR ~ %.2f dB, BER ~ %e) ---\n', N0_for_detailed_plots, SNR_for_detailed_plots_title, BER_for_detailed_plots_title);

current_N0_dB_detailed = N0_for_detailed_plots;
[symbol_table_sign_det, alphabet_sign_det] = create_symbol_table();
info_bits_tx_det = sign_encoder(message_text, alphabet_sign_det, symbol_table_sign_det);
trellis_conv_det = poly2trellis(K_conv, [G1_oct_conv G2_oct_conv]);
input_bits_for_conv_det = info_bits_tx_det;
encoded_bits_conv_tx_det = convolutional_encoder(input_bits_for_conv_det, trellis_conv_det);
sequence_length_interleaver_det = length(encoded_bits_conv_tx_det);
permutation_vector_interleaver_det = generate_permutation(sequence_length_interleaver_det);
interleaved_bits_tx_det = interleaver(encoded_bits_conv_tx_det, permutation_vector_interleaver_det);
input_bits_for_qpsk_tx_det = interleaved_bits_tx_det;
if mod(length(input_bits_for_qpsk_tx_det), 2) ~= 0, input_bits_for_qpsk_tx_det = [input_bits_for_qpsk_tx_det, 0]; end
qpsk_symbols_tx_det = qpsk_modulator(input_bits_for_qpsk_tx_det);
N_QPSK_data_for_ofdm_det = length(qpsk_symbols_tx_det);
[ofdm_signal_tx_cp_det, N_IFFT_ofdm_det, Tcp_samples_ofdm_det, N_Z_ofdm_det, N_active_ofdm_det, pilot_indices_freq_ofdm_det, data_indices_freq_ofdm_det] = ...
    ofdm_modulator(qpsk_symbols_tx_det, N_QPSK_data_for_ofdm_det, ARS_pilot_step_ofdm, C_guard_fraction_ofdm, Tcp_fraction_of_NFFT_ofdm, pilot_value_ofdm);
L_original_ofdm_for_channel_det = length(ofdm_signal_tx_cp_det);
[ofdm_signal_rx_det, Smpy_detailed_plot] = channel_model(ofdm_signal_tx_cp_det, L_original_ofdm_for_channel_det, NB_rays_channel, B_signal_Hz_channel, f0_carrier_Hz_channel, current_N0_dB_detailed); % Получаем Smpy
[qpsk_symbols_rx_eq_det, H_est_pilots_det, H_interp_det, C_rx_active_det, ~] = ...
    ofdm_demodulator_equalizer(ofdm_signal_rx_det, N_IFFT_ofdm_det, Tcp_samples_ofdm_det, N_Z_ofdm_det, N_active_ofdm_det, pilot_indices_freq_ofdm_det, data_indices_freq_ofdm_det, pilot_value_ofdm, ARS_pilot_step_ofdm);

freq_vector_for_plot_tx_final_det = zeros(1, N_IFFT_ofdm_det);
freq_vector_for_plot_tx_final_det(pilot_indices_freq_ofdm_det) = pilot_value_ofdm;
freq_vector_for_plot_tx_final_det(data_indices_freq_ofdm_det) = qpsk_symbols_tx_det;

figure('Name', ['Итоговые Графики для N0=' num2str(current_N0_dB_detailed) 'dBW (SNR~' num2str(SNR_for_detailed_plots_title,'%.1f') 'dB)'], 'NumberTitle', 'off', 'Position', [150, 150, 1200, 900]);

subplot(3,2,1); stem(0:N_IFFT_ofdm_det-1, abs(freq_vector_for_plot_tx_final_det), 'MarkerFaceColor', 'b', 'BaseValue', 0);
title(sprintf('1. Спектр TX OFDM (N_{FFT}=%d)', N_IFFT_ofdm_det)); xlabel('Индекс поднесущей'); ylabel('|Амплитуда|'); grid on; axis tight; ylim([-0.1 1.2]);
subplot(3,2,2); plot(0:N_active_ofdm_det-1, abs(C_rx_active_det), 'm-');
title('2. Спектр RX OFDM ДО эквалайзера (активные)'); xlabel('Индекс активной поднесущей'); ylabel('|C_{rx}|'); grid on; axis tight;
subplot(3,2,4); stem(0:length(qpsk_symbols_rx_eq_det)-1, abs(qpsk_symbols_rx_eq_det), 'c.', 'MarkerSize', 8, 'BaseValue', 0);
title('3. Амплитуды QPSK данных ПОСЛЕ эквалайзера'); xlabel('Индекс символа данных'); ylabel('|Амплитуда|'); grid on; axis tight; 
subplot(3,2,3); plot(real(qpsk_symbols_tx_det), imag(qpsk_symbols_tx_det), 'b.', 'MarkerSize', 10);
axis equal; grid on; xlim([-1.5 1.5]); ylim([-1.5 1.5]); title('4. Созвездие QPSK на передатчике (TX)'); xlabel('In-Phase'); ylabel('Quadrature');
hold on; A_qpsk_vis_det = 1/sqrt(2); qpsk_map_vis_det = [A_qpsk_vis_det + 1j*A_qpsk_vis_det, A_qpsk_vis_det - 1j*A_qpsk_vis_det, -A_qpsk_vis_det + 1j*A_qpsk_vis_det, -A_qpsk_vis_det - 1j*A_qpsk_vis_det];
plot(real(qpsk_map_vis_det), imag(qpsk_map_vis_det), 'k+', 'MarkerSize', 12, 'LineWidth', 2); hold off;
subplot(3,2,5); plot(real(qpsk_symbols_rx_eq_det), imag(qpsk_symbols_rx_eq_det), 'g.', 'MarkerSize', 10);
hold on; plot(real(qpsk_map_vis_det), imag(qpsk_map_vis_det), 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, 'MarkerFaceColor','r');
axis equal; grid on; xlim([-1.5 1.5]); ylim([-1.5 1.5]); title('5. Созвездие QPSK на приемнике ПОСЛЕ эквалайзера (RX)');  xlabel('In-Phase'); ylabel('Quadrature'); hold off;
subplot(3,2,6); stem(pilot_indices_freq_ofdm_det - N_Z_ofdm_det, abs(H_est_pilots_det), 'rx', 'DisplayName', 'Оценка АЧХ по пилотам'); hold on;
plot(0:N_active_ofdm_det-1, abs(H_interp_det), 'b-', 'DisplayName', 'Интерполированная АЧХ');
title('6. Оценка |АЧХ| канала'); xlabel('Индекс активной поднесущей'); ylabel('|H_{est}|'); legend('show','Location','northeast'); grid on; axis tight;
sgtitle(sprintf('Детальные Графики для N0 = %.1f dBW (SNR ~ %.1f dB, BER из цикла = %e)', current_N0_dB_detailed, SNR_for_detailed_plots_title, BER_for_detailed_plots_title), 'FontSize', 14, 'FontWeight', 'bold');
fprintf('Детальные графики для N0=%.1f dBW (SNR ~ %.1f dB) выведены.\n', current_N0_dB_detailed, SNR_for_detailed_plots_title);

fprintf('\n===== ЗАВЕРШЕНИЕ ПРАКТИКИ 8 =====\n');