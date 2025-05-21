clc;
clear;
close all;

fprintf('===== ЗАПУСК МОДЕЛИРОВАНИЯ: ПЕРЕДАТЧИК OFDM И КАНАЛ (ЭТАПЫ 1-6) =====\n\n');

message_text = 'Hello_World_123-';

fprintf('ВАЖНО: Исходное сообщение для примера: "%s" (длина %d)\n', message_text, length(message_text));

K_conv = 7;         
G1_oct_conv = 171;  
G2_oct_conv = 133;
tblen_viterbi = 5 * K_conv;

ARS_pilot_step_ofdm = 6;         
Tcp_fraction_of_NFFT_ofdm = 1/4; 
C_guard_fraction_ofdm = 1/4;    
pilot_value_ofdm = (1 + 1j) / sqrt(2); 


NB_rays_channel = 9;            
B_signal_Hz_channel = 9e6;      
f0_carrier_Hz_channel = 2.4e9; 
N0_dB_power_channel = -100;      


fprintf('--- ЭТАП 1 (Передатчик): Знаковое кодирование ---\n');
[symbol_table_sign, alphabet_sign] = create_symbol_table();
fprintf(' Алфавит для знакового кодера (%d символов): %s\n', length(alphabet_sign), alphabet_sign(1:min(10, length(alphabet_sign)))+"...");
fprintf(' Исходное текстовое сообщение: "%s"\n', message_text);


info_bits_tx = sign_encoder(message_text, alphabet_sign, symbol_table_sign);
fprintf(' Выход знакового кодера (информационные биты): %d бит.\n', length(info_bits_tx));
fprintf('  Пример бит (первые 24): %s...\n', num2str(info_bits_tx(1:min(24, length(info_bits_tx)))));


fprintf('\n--- ЭТАП 2 (Передатчик): Сверточное кодирование (без явного терминирования) ---\n');
trellis_conv = poly2trellis(K_conv, [G1_oct_conv G2_oct_conv]);
fprintf(' Создана решетка для сверточного кодера (K=%d, G1=%o, G2=%o).\n', K_conv, G1_oct_conv, G2_oct_conv);

input_bits_for_conv = info_bits_tx; 
fprintf(' На вход кодера R=1/2 подается %d информационных бит.\n', length(input_bits_for_conv));

encoded_bits_conv_tx = convolutional_encoder(input_bits_for_conv, trellis_conv); 
fprintf(' Выход сверточного кодера (каждый из %d бит удвоен): %d бит.\n', length(input_bits_for_conv), length(encoded_bits_conv_tx));


fprintf('\n--- ЭТАП 3 (Передатчик): Перемежение ---\n');
sequence_length_interleaver = length(encoded_bits_conv_tx);
fprintf(' Длина последовательности для перемежителя: %d бит.\n', sequence_length_interleaver);

permutation_vector_interleaver = generate_permutation(sequence_length_interleaver);
interleaved_bits_tx = interleaver(encoded_bits_conv_tx, permutation_vector_interleaver);
fprintf(' Выход перемежителя: %d бит.\n', length(interleaved_bits_tx));
fprintf('  Пример бит (первые 24): %s...\n', num2str(interleaved_bits_tx(1:min(24, length(interleaved_bits_tx)))));


fprintf('\n--- ЭТАП 4 (Передатчик): QPSK-модуляция ---\n');
input_bits_for_qpsk_tx = interleaved_bits_tx;
if mod(length(input_bits_for_qpsk_tx), 2) ~= 0
    input_bits_for_qpsk_tx = [input_bits_for_qpsk_tx, 0];
    warning('Длина бит для QPSK была нечетной, добавлен 0.');
end
fprintf(' Длина последовательности для QPSK модулятора: %d бит.\n', length(input_bits_for_qpsk_tx));

qpsk_symbols_tx = qpsk_modulator(input_bits_for_qpsk_tx);
N_QPSK_data_for_ofdm = length(qpsk_symbols_tx);
fprintf(' Выход QPSK модулятора: %d QPSK-символов.\n', N_QPSK_data_for_ofdm);
fprintf('  Пример символов (первые 5): \n');
disp(qpsk_symbols_tx(1:min(5, N_QPSK_data_for_ofdm)));


fprintf('\n--- ЭТАП 5 (Передатчик): OFDM-модуляция ---\n');
fprintf(' Вход для OFDM модулятора: %d QPSK-символов.\n', N_QPSK_data_for_ofdm);
fprintf(' Параметры OFDM: ARS=%d, Tcp_frac=%f, C_guard_frac=%f\n', ...
        ARS_pilot_step_ofdm, Tcp_fraction_of_NFFT_ofdm, C_guard_fraction_ofdm);

[ofdm_signal_tx_cp, N_IFFT_ofdm, Tcp_samples_ofdm, N_Z_ofdm, N_active_ofdm, ...
 pilot_indices_freq_ofdm, data_indices_freq_ofdm] = ...
    ofdm_modulator(qpsk_symbols_tx, N_QPSK_data_for_ofdm, ARS_pilot_step_ofdm, ...
                   C_guard_fraction_ofdm, Tcp_fraction_of_NFFT_ofdm, pilot_value_ofdm);

fprintf(' Выход OFDM модулятора (OFDM-символ во времени с CP): %d отсчетов.\n', length(ofdm_signal_tx_cp));
fprintf('  Рассчитанные параметры OFDM: N_active=%d, N_RS=%d, N_Z=%d, N_IFFT=%d, Tcp_samples=%d.\n', ...
        N_active_ofdm, N_active_ofdm - N_QPSK_data_for_ofdm, N_Z_ofdm, N_IFFT_ofdm, Tcp_samples_ofdm);
fprintf('  Пример отсчетов (первые 10):\n');
disp(ofdm_signal_tx_cp(1:min(10, length(ofdm_signal_tx_cp))));


freq_vector_for_plot_tx = zeros(1, N_IFFT_ofdm);
freq_vector_for_plot_tx(pilot_indices_freq_ofdm) = pilot_value_ofdm;
freq_vector_for_plot_tx(data_indices_freq_ofdm) = qpsk_symbols_tx;


fprintf('\n--- ЭТАП 6: Модель канала передачи ---\n');
L_original_ofdm_for_channel = length(ofdm_signal_tx_cp);
fprintf(' Вход для модели канала: %d отсчетов OFDM-символа.\n', L_original_ofdm_for_channel);
fprintf(' Параметры канала: NB_rays=%d, B_signal=%.1e Hz, f0_carrier=%.1e Hz, N0_power=%.1f dBW\n', ...
        NB_rays_channel, B_signal_Hz_channel, f0_carrier_Hz_channel, N0_dB_power_channel);

ofdm_signal_rx = channel_model(ofdm_signal_tx_cp, L_original_ofdm_for_channel, ...
                               NB_rays_channel, B_signal_Hz_channel, f0_carrier_Hz_channel, N0_dB_power_channel);

fprintf(' Выход модели канала (принятый сигнал): %d отсчетов.\n', length(ofdm_signal_rx));
fprintf('  Пример отсчетов (первые 10):\n');
disp(ofdm_signal_rx(1:min(10, length(ofdm_signal_rx))));


fprintf('\n--- ЭТАП 7 (Приемник): OFDM-демодуляция и Эквалайзинг ---\n');

[qpsk_symbols_rx_eq, H_estimated_on_pilots, H_interpolated] = ...
    ofdm_demodulator_equalizer(ofdm_signal_rx, ...
                               N_IFFT_ofdm, ...
                               Tcp_samples_ofdm, ...
                               N_Z_ofdm, ...
                               N_active_ofdm, ...
                               pilot_indices_freq_ofdm, ... 
                               data_indices_freq_ofdm,  ... 
                               pilot_value_ofdm, ...
                               ARS_pilot_step_ofdm);

fprintf(' Выход OFDM демодулятора/эквалайзера: %d QPSK-символов.\n', length(qpsk_symbols_rx_eq));
fprintf('  Пример восстановленных QPSK-символов (первые 5):\n');
disp(qpsk_symbols_rx_eq(1:min(5, length(qpsk_symbols_rx_eq))));


ofdm_signal_no_cp_vis = ofdm_signal_rx(Tcp_samples_ofdm + 1 : end);
ofdm_freq_domain_rx_vis = fft(ofdm_signal_no_cp_vis, N_IFFT_ofdm);
C_rx_active_vis = ofdm_freq_domain_rx_vis(N_Z_ofdm + 1 : N_Z_ofdm + N_active_ofdm);



fprintf('\n--- ЭТАП 8 (Приемник): QPSK-демодуляция ---\n');
fprintf(' Вход для QPSK демодулятора: %d QPSK-символов.\n', length(qpsk_symbols_rx_eq));

bits_rx_after_qpsk_demod = qpsk_demodulator(qpsk_symbols_rx_eq);

fprintf(' Выход QPSK демодулятора: %d бит.\n', length(bits_rx_after_qpsk_demod));
fprintf('  Пример бит (первые 24): %s...\n', num2str(bits_rx_after_qpsk_demod(1:min(24, length(bits_rx_after_qpsk_demod)))));


fprintf('\n--- ЭТАП 9 (Приемник): Деперемежение ---\n');
fprintf(' Вход для деперемежителя: %d бит.\n', length(bits_rx_after_qpsk_demod));

if ~exist('permutation_vector_interleaver', 'var')
    error('Вектор перестановок permutation_vector_interleaver не найден! Он должен был быть создан на Этапе 3.');
end
if length(bits_rx_after_qpsk_demod) ~= length(permutation_vector_interleaver)
    error('Длина битовой последовательности (%d) не совпадает с длиной вектора перестановок (%d) для деперемежения!', ...
          length(bits_rx_after_qpsk_demod), length(permutation_vector_interleaver));
end

bits_rx_after_deinterleaving = deinterleaver(bits_rx_after_qpsk_demod, permutation_vector_interleaver);

fprintf(' Выход деперемежителя: %d бит.\n', length(bits_rx_after_deinterleaving));
fprintf('  Пример бит (первые 24): %s...\n', num2str(bits_rx_after_deinterleaving(1:min(24, length(bits_rx_after_deinterleaving)))));



fprintf('\n--- ЭТАП 10 (Приемник): Декодирование Витерби ---\n');
fprintf(' Вход для декодера Витерби: %d бит.\n', length(bits_rx_after_deinterleaving));
fprintf(' Используется режим декодирования: ''trunc'' (для нетерминированного кодера).\n');
fprintf(' Используется глубина обратного просмотра (tblen): %d.\n', tblen_viterbi);

decoded_info_bits_rx = vitdec(bits_rx_after_deinterleaving, trellis_conv, tblen_viterbi, 'trunc', 'hard');

fprintf(' Выход декодера Витерби (восстановленные информационные биты): %d бит.\n', length(decoded_info_bits_rx));

fprintf('  Ожидаемая длина (исходные информационные биты с Этапа 1): %d бит.\n', length(info_bits_tx)); 
fprintf('  Пример бит (первые 24): %s...\n', num2str(decoded_info_bits_rx(1:min(24, length(decoded_info_bits_rx)))));


if length(decoded_info_bits_rx) ~= length(info_bits_tx)
    warning('Длина выхода декодера Витерби (%d) не совпадает с длиной исходных информационных бит (%d)!', ...
            length(decoded_info_bits_rx), length(info_bits_tx));

end


fprintf('\n--- ЭТАП 11 (Приемник): Знаковое декодирование ---\n');
fprintf(' Вход для знакового декодера: %d бит.\n', length(decoded_info_bits_rx));

if ~exist('symbol_table_sign', 'var') || ~exist('alphabet_sign', 'var')
    error('Таблица символов (symbol_table_sign) или алфавит (alphabet_sign) не найдены! Они должны были быть созданы на Этапе 1.');
end

decoded_message_text = sign_decoder(decoded_info_bits_rx, alphabet_sign, symbol_table_sign);

fprintf(' Выход знакового декодера (восстановленное текстовое сообщение):\n "%s"\n', decoded_message_text);


fprintf('\n--- ЭТАП 12: Расчет Коэффициента Ошибок ---\n');

N_info_bits_total = length(info_bits_tx); 

if length(decoded_info_bits_rx) ~= N_info_bits_total
    fprintf(' ПРЕДУПРЕЖДЕНИЕ: Длина восстановленных информационных бит (%d) не совпадает с исходной (%d)!\n', ...
            length(decoded_info_bits_rx), N_info_bits_total);
    fprintf(' BER не может быть точно рассчитан.\n');
    num_bit_errors = NaN;
    BER = NaN;
else
    num_bit_errors = sum(info_bits_tx ~= decoded_info_bits_rx);
    if N_info_bits_total > 0
        BER = num_bit_errors / N_info_bits_total;
    else
        BER = 0; 
    end
    fprintf(' Количество битовых ошибок (после декодера Витерби): %d из %d\n', num_bit_errors, N_info_bits_total);
    fprintf(' Итоговый BER (Bit Error Rate): %e\n', BER);
end

original_message_length_chars = length(message_text); % Исходная длина в символах (до знакового кодирования)


if length(decoded_message_text) > original_message_length_chars
    decoded_message_text_for_ser = decoded_message_text(1:original_message_length_chars);
    fprintf(' ПРЕДУПРЕЖДЕНИЕ: Декодированное сообщение длиннее исходного, обрезано для расчета SER.\n');
elseif length(decoded_message_text) < original_message_length_chars
    decoded_message_text_for_ser = [decoded_message_text, repmat('?', 1, original_message_length_chars - length(decoded_message_text))];
    fprintf(' ПРЕДУПРЕЖДЕНИЕ: Декодированное сообщение короче исходного, дополнено "?" для расчета SER.\n');
else
    decoded_message_text_for_ser = decoded_message_text;
end

num_symbol_errors = sum(message_text ~= decoded_message_text_for_ser);
if original_message_length_chars > 0
    SER = num_symbol_errors / original_message_length_chars;
else
    SER = 0; 
end

fprintf(' Исходное сообщение: "%s"\n', message_text);
fprintf(' Восстановленное сообщение: "%s"\n', decoded_message_text); % Выводим полное декодированное
fprintf(' Количество символьных ошибок (текст): %d из %d\n', num_symbol_errors, original_message_length_chars);
fprintf(' Итоговый SER (Symbol Error Rate): %f\n', SER);

if num_bit_errors == 0 && num_symbol_errors == 0
    fprintf(' ПОЛНЫЙ УСПЕХ: Сообщение передано и восстановлено без ошибок!\n');
else
    fprintf(' При передаче сообщения возникли ошибки.\n');
end

fprintf('\n===== ВСЕ ЭТАПЫ МОДЕЛИРОВАНИЯ (1-12) ЗАВЕРШЕНЫ =====\n');


fprintf('\n--- Построение итоговых графиков ---\n');

figure('Name', 'Итоговые Графики Системы OFDM', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 800]);

subplot(3,2,1);
stem(0:N_IFFT_ofdm-1, abs(freq_vector_for_plot_tx), 'MarkerFaceColor', 'b', 'BaseValue', -0.1); 
title(sprintf('1. Спектр TX OFDM (N_{FFT}=%d)', N_IFFT_ofdm));
xlabel('Индекс поднесущей');
ylabel('|Амплитуда|');
grid on; axis tight;
ylim([-0.1 1.2]); 

subplot(3,2,2);
plot(0:N_active_ofdm-1, abs(C_rx_active_vis), 'm-');
title('2. Спектр RX OFDM ДО эквалайзера (активные)');
xlabel('Индекс активной поднесущей');
ylabel('|C_{rx}|');
grid on; axis tight;

subplot(3,2,4); 
stem(0:length(qpsk_symbols_rx_eq)-1, abs(qpsk_symbols_rx_eq), 'c.', 'MarkerSize', 8, 'BaseValue', -0.1);
title('3. Амплитуды QPSK данных ПОСЛЕ эквалайзера');
xlabel('Индекс символа данных');
ylabel('|Амплитуда|');
grid on; axis tight;
ylim([-0.1 1.5]);

subplot(3,2,3);
plot(real(qpsk_symbols_tx), imag(qpsk_symbols_tx), 'bo', 'MarkerSize', 4);
axis equal; grid on;
xlim([-1.5 1.5]); ylim([-1.5 1.5]);
title('4. Созвездие QPSK на передатчике (TX)');
xlabel('In-Phase'); ylabel('Quadrature');
hold on;
A_qpsk_vis = 1/sqrt(2);
qpsk_map_vis = [A_qpsk_vis + 1j*A_qpsk_vis, A_qpsk_vis - 1j*A_qpsk_vis, -A_qpsk_vis + 1j*A_qpsk_vis, -A_qpsk_vis - 1j*A_qpsk_vis];
plot(real(qpsk_map_vis), imag(qpsk_map_vis), 'k+', 'MarkerSize', 10, 'LineWidth', 1.5);
hold off;

subplot(3,2,5);
plot(real(qpsk_symbols_rx_eq), imag(qpsk_symbols_rx_eq), 'g.', 'MarkerSize', 10);
hold on;
plot(real(qpsk_map_vis), imag(qpsk_map_vis), 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, 'MarkerFaceColor','r');
axis equal; grid on;
xlim([-1.5 1.5]); ylim([-1.5 1.5]);
title('5. Созвездие QPSK на приемнике ПОСЛЕ эквалайзера (RX)');
xlabel('In-Phase'); ylabel('Quadrature');
hold off;

sgtitle(sprintf('Итоговые графики для N0 = %.1f dBW, BER = %e', N0_dB_power_channel, BER), 'FontSize', 14, 'FontWeight', 'bold');

fprintf('Итоговые графики выведены в новое окно Figure.\n');