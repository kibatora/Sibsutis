clc;
clear;
close all;

fprintf('===== ЗАПУСК ПОШАГОВОЙ ПРОВЕРКИ БЛОКОВ =====\n\n');

% =========================================================================
% ОБЩИЕ ПАРАМЕТРЫ (Для Теста 1)
% =========================================================================
message_text_t1 = 'Hello_World_123-'; % Тестовое сообщение
bits_per_char_sign = 6;          % 6 бит на символ для нашего алфавита


K_conv = 7;         
G1_oct_conv = 171;  
G2_oct_conv = 133;
tblen_viterbi = 5 * K_conv;

ARS_pilot_step_ofdm = 4;         
Tcp_fraction_of_NFFT_ofdm = 1/4; 
C_guard_fraction_ofdm = 1/4;    
pilot_value_ofdm = (1 + 1j) / sqrt(2); 


NB_rays_channel = 9;            
B_signal_Hz_channel = 9e6;      
f0_carrier_Hz_channel = 2.4e9; 
N0_dB_power_channel = -80;      

% =========================================================================
% ТЕСТ 1: Знаковый кодер <-> Знаковый декодер
% =========================================================================
fprintf('--- ТЕСТ 1: Знаковый кодер <-> Знаковый декодер ---\n');

% --- Этап кодирования ---
fprintf(' Исходное текстовое сообщение: "%s"\n', message_text_t1);
[symbol_table_sign_t1, alphabet_sign_t1] = create_symbol_table(); % Создаем алфавит и таблицу
fprintf(' Используется алфавит: %s... (всего %d символов)\n', alphabet_sign_t1(1:min(10,length(alphabet_sign_t1))), length(alphabet_sign_t1));

encoded_bits_t1 = sign_encoder(message_text_t1, alphabet_sign_t1, symbol_table_sign_t1);
expected_bit_len_t1 = length(message_text_t1) * bits_per_char_sign;
fprintf(' Выход знакового кодера: %d бит.\n', length(encoded_bits_t1));
if length(encoded_bits_t1) ~= expected_bit_len_t1
    fprintf(' ПРЕДУПРЕЖДЕНИЕ ТЕСТ 1: Ожидаемая длина бит %d, получено %d!\n', expected_bit_len_t1, length(encoded_bits_t1));
end
fprintf('  Пример бит (первые 24): %s...\n', num2str(encoded_bits_t1(1:min(24, length(encoded_bits_t1)))));

% --- Этап декодирования ---
decoded_message_t1 = sign_decoder(encoded_bits_t1, alphabet_sign_t1, symbol_table_sign_t1);
fprintf(' Выход знакового декодера (восстановленное сообщение): "%s"\n', decoded_message_t1);

% --- Проверка результата Теста 1 ---
if strcmp(message_text_t1, decoded_message_t1)
    fprintf(' ТЕСТ 1 УСПЕШЕН: Исходное и декодированное сообщения совпадают.\n');
else
    fprintf(' ТЕСТ 1 ОШИБКА: Исходное и декодированное сообщения НЕ совпадают!\n');
    % Дополнительно можно вывести, где именно не совпало, если нужно
    for k=1:min(length(message_text_t1), length(decoded_message_t1))
        if message_text_t1(k) ~= decoded_message_t1(k)
            fprintf('  Первое несовпадение на символе %d: Ожидалось ''%c'', получено ''%c''\n', k, message_text_t1(k), decoded_message_t1(k));
            break;
        end
    end
    if length(message_text_t1) ~= length(decoded_message_t1)
        fprintf('  Также не совпадают длины сообщений: Исходная %d, Декодированная %d\n', length(message_text_t1), length(decoded_message_t1));
    end
end

fprintf('\n===== Тест 1 завершен =====\n');

% =========================================================================
% ТЕСТ 2: Знаковый кодер -> Сверточный кодер <-> Декодер Витерби -> Знаковый декодер
% (Сверточный кодер без явного терминирования, Витерби с 'trunc')
% =========================================================================
fprintf('\n--- ТЕСТ 2: Сверт. кодер <-> Декодер Витерби (с знак. обрамлением, без терм.) ---\n');

% --- Параметры для этого теста (некоторые уже есть в общих) ---
message_text_t2 = 'Hello_World_123-'; % Можно использовать то же сообщение
% K_conv, G1_oct_conv, G2_oct_conv, tblen_viterbi - уже заданы в общих параметрах

% --- Передатчик ---
% 1. Знаковое кодирование
fprintf(' Исходное сообщение для Теста 2: "%s"\n', message_text_t2);
[symbol_table_sign_t2, alphabet_sign_t2] = create_symbol_table();
info_bits_t2_tx = sign_encoder(message_text_t2, alphabet_sign_t2, symbol_table_sign_t2);
fprintf('  Выход знакового кодера (info_bits_t2_tx): %d бит.\n', length(info_bits_t2_tx));

% 2. Сверточное кодирование (без явного терминирования)
trellis_conv_t2 = poly2trellis(K_conv, [G1_oct_conv G2_oct_conv]);
input_for_convolutional_encoder_t2 = info_bits_t2_tx; % Прямая передача информационных бит
encoded_bits_t2_tx = convolutional_encoder(input_for_convolutional_encoder_t2, trellis_conv_t2);
expected_encoded_len_t2 = length(input_for_convolutional_encoder_t2) * 2;
fprintf('  Выход сверточного кодера (encoded_bits_t2_tx): %d бит (Ожидалось: %d).\n', length(encoded_bits_t2_tx), expected_encoded_len_t2);
if length(encoded_bits_t2_tx) ~= expected_encoded_len_t2
     fprintf('  ПРЕДУПРЕЖДЕНИЕ ТЕСТ 2: Длина выхода сверточного кодера не соответствует 2*N_info!\n');
end

% --- ИДЕАЛЬНЫЙ КАНАЛ (на данном этапе нет искажений) ---
received_bits_for_viterbi_t2 = encoded_bits_t2_tx;
fprintf('  Сигнал передан по идеальному каналу (без изменений).\n');

% --- Приемник ---
% 3. Декодирование Витерби
% Используем 'trunc' (или 'truncoct'), так как кодер не терминировался
% tblen_viterbi уже определен
fprintf('  Вход декодера Витерби: %d бит.\n', length(received_bits_for_viterbi_t2));
decoded_bits_after_viterbi_t2 = vitdec(received_bits_for_viterbi_t2, trellis_conv_t2, tblen_viterbi, 'trunc', 'hard');
fprintf('  Выход декодера Витерби (decoded_bits_after_viterbi_t2): %d бит.\n', length(decoded_bits_after_viterbi_t2));
if length(decoded_bits_after_viterbi_t2) ~= length(info_bits_t2_tx)
    fprintf('  ПРЕДУПРЕЖДЕНИЕ ТЕСТ 2: Длина выхода Витерби (%d) не равна длине исходных инф. бит (%d)!\n', ...
            length(decoded_bits_after_viterbi_t2), length(info_bits_t2_tx));
    % Если длины не совпадают, дальнейшее знаковое декодирование может быть некорректным
    % или выдать ошибку, если не кратно 6.
    % Можно либо остановить тест, либо попытаться обрезать/дополнить, но лучше разобраться.
    % Для 'trunc' длина выхода vitdec ДОЛЖНА совпадать с info_bits_t2_tx.
end

% 4. Знаковое декодирование
decoded_message_t2_rx = sign_decoder(decoded_bits_after_viterbi_t2, alphabet_sign_t2, symbol_table_sign_t2);
fprintf(' Восстановленное текстовое сообщение (после Витерби и знакового декодера): "%s"\n', decoded_message_t2_rx);

% --- Проверка результата Теста 2 ---
if strcmp(message_text_t2, decoded_message_t2_rx)
    fprintf(' ТЕСТ 2 УСПЕШЕН: Исходное и декодированное сообщения совпадают.\n');
else
    fprintf(' ТЕСТ 2 ОШИБКА: Исходное и декодированное сообщения НЕ совпадают!\n');
     % Дополнительный вывод ошибок, если нужно
    bit_errors_t2 = sum(info_bits_t2_tx ~= decoded_bits_after_viterbi_t2(1:min(length(info_bits_t2_tx), length(decoded_bits_after_viterbi_t2))));
    fprintf('  Количество битовых ошибок между info_bits_tx и выходом Витерби: %d\n', bit_errors_t2);
end

% =========================================================================
% ТЕСТ 3: Добавляем Перемежитель и Деперемежитель
% Цепочка: Знак.код. -> Сверт.код. -> Перемежитель <-> Деперемежитель -> Витерби -> Знак.декод.
% (Канал идеальный)
% =========================================================================
fprintf('\n--- ТЕСТ 3: Сверт.код + Перемежитель <-> Деперемеж. + Витерби (с знак. обрамлением) ---\n');

% --- Параметры для этого теста (некоторые уже есть в общих) ---
message_text_t3 = 'Hello_World_123-'; % Можно использовать то же сообщение
% K_conv, G1_oct_conv, G2_oct_conv, tblen_viterbi - уже заданы

% --- Передатчик ---
% 1. Знаковое кодирование
fprintf(' Исходное сообщение для Теста 3: "%s"\n', message_text_t3);
[symbol_table_sign_t3, alphabet_sign_t3] = create_symbol_table();
info_bits_t3_tx = sign_encoder(message_text_t3, alphabet_sign_t3, symbol_table_sign_t3);
fprintf('  1. Выход знакового кодера (info_bits_t3_tx): %d бит.\n', length(info_bits_t3_tx));

% 2. Сверточное кодирование (без явного терминирования)
trellis_conv_t3 = poly2trellis(K_conv, [G1_oct_conv G2_oct_conv]);
input_for_convolutional_encoder_t3 = info_bits_t3_tx;
encoded_bits_t3_tx = convolutional_encoder(input_for_convolutional_encoder_t3, trellis_conv_t3);
fprintf('  2. Выход сверточного кодера (encoded_bits_t3_tx): %d бит.\n', length(encoded_bits_t3_tx));

% 3. Перемежение
sequence_length_interleaver_t3 = length(encoded_bits_t3_tx);
permutation_vector_t3 = generate_permutation(sequence_length_interleaver_t3); % Генерируем и ЗАПОМИНАЕМ
interleaved_bits_t3_tx = interleaver(encoded_bits_t3_tx, permutation_vector_t3);
fprintf('  3. Выход перемежителя (interleaved_bits_t3_tx): %d бит.\n', length(interleaved_bits_t3_tx));

% --- ИДЕАЛЬНЫЙ КАНАЛ ---
received_bits_for_deinterleaver_t3 = interleaved_bits_t3_tx;
fprintf('  Сигнал передан по идеальному каналу (без изменений).\n');

% --- Приемник ---
% 4. Деперемежение
% Используем тот же permutation_vector_t3
bits_after_deinterleaving_t3_rx = deinterleaver(received_bits_for_deinterleaver_t3, permutation_vector_t3);
fprintf('  4. Выход деперемежителя (bits_after_deinterleaving_t3_rx): %d бит.\n', length(bits_after_deinterleaving_t3_rx));
if ~isequal(encoded_bits_t3_tx, bits_after_deinterleaving_t3_rx)
    fprintf('  ПРЕДУПРЕЖДЕНИЕ ТЕСТ 3: Выход деперемежителя не совпадает с выходом сверточного кодера TX!\n');
end


% 5. Декодирование Витерби
fprintf('  5. Вход декодера Витерби: %d бит.\n', length(bits_after_deinterleaving_t3_rx));
decoded_bits_after_viterbi_t3_rx = vitdec(bits_after_deinterleaving_t3_rx, trellis_conv_t3, tblen_viterbi, 'trunc', 'hard');
fprintf('     Выход декодера Витерби (decoded_bits_after_viterbi_t3_rx): %d бит.\n', length(decoded_bits_after_viterbi_t3_rx));
if length(decoded_bits_after_viterbi_t3_rx) ~= length(info_bits_t3_tx)
    fprintf('     ПРЕДУПРЕЖДЕНИЕ ТЕСТ 3: Длина выхода Витерби (%d) не равна длине исходных инф. бит (%d)!\n', ...
            length(decoded_bits_after_viterbi_t3_rx), length(info_bits_t3_tx));
end

% 6. Знаковое декодирование
decoded_message_t3_rx = sign_decoder(decoded_bits_after_viterbi_t3_rx, alphabet_sign_t3, symbol_table_sign_t3);
fprintf('  6. Восстановленное текстовое сообщение: "%s"\n', decoded_message_t3_rx);

% --- Проверка результата Теста 3 ---
if strcmp(message_text_t3, decoded_message_t3_rx)
    fprintf(' ТЕСТ 3 УСПЕШЕН: Исходное и декодированное сообщения совпадают.\n');
else
    fprintf(' ТЕСТ 3 ОШИБКА: Исходное и декодированное сообщения НЕ совпадают!\n');
    bit_errors_t3 = sum(info_bits_t3_tx ~= decoded_bits_after_viterbi_t3_rx(1:min(length(info_bits_t3_tx), length(decoded_bits_after_viterbi_t3_rx))));
    fprintf('  Количество битовых ошибок между info_bits_tx и выходом Витерби: %d\n', bit_errors_t3);
end

fprintf('\n===== Тест 3 завершен =====\n');

% =========================================================================
% ТЕСТ 4: Добавляем QPSK Модулятор и Демодулятор
% Цепочка: ... -> Перемежитель -> QPSK Мод. <-> QPSK Демод. -> Деперемежитель -> ...
% (Канал идеальный)
% =========================================================================
fprintf('\n--- ТЕСТ 4: ... Перемежитель -> QPSK Мод. <-> QPSK Демод. -> Деперемежитель ... ---\n');

% --- Параметры для этого теста (в основном из общих) ---
message_text_t4 = 'Hello_World_123-';
% K_conv, G1_oct_conv, G2_oct_conv, tblen_viterbi - уже заданы

% --- Передатчик ---
fprintf(' Исходное сообщение для Теста 4: "%s"\n', message_text_t4);
[symbol_table_sign_t4, alphabet_sign_t4] = create_symbol_table();
info_bits_t4_tx = sign_encoder(message_text_t4, alphabet_sign_t4, symbol_table_sign_t4);
fprintf('  1. Выход знакового кодера: %d бит.\n', length(info_bits_t4_tx));

trellis_conv_t4 = poly2trellis(K_conv, [G1_oct_conv G2_oct_conv]);
encoded_bits_t4_tx = convolutional_encoder(info_bits_t4_tx, trellis_conv_t4);
fprintf('  2. Выход сверточного кодера: %d бит.\n', length(encoded_bits_t4_tx));

sequence_length_interleaver_t4 = length(encoded_bits_t4_tx);
permutation_vector_t4 = generate_permutation(sequence_length_interleaver_t4);
interleaved_bits_t4_tx = interleaver(encoded_bits_t4_tx, permutation_vector_t4);
fprintf('  3. Выход перемежителя: %d бит.\n', length(interleaved_bits_t4_tx));

% 4. QPSK Модуляция
input_bits_for_qpsk_t4_tx = interleaved_bits_t4_tx;
if mod(length(input_bits_for_qpsk_t4_tx), 2) ~= 0 % Проверка четности
    input_bits_for_qpsk_t4_tx = [input_bits_for_qpsk_t4_tx, 0];
end
qpsk_symbols_t4_tx = qpsk_modulator(input_bits_for_qpsk_t4_tx);
fprintf('  4. Выход QPSK модулятора: %d символов.\n', length(qpsk_symbols_t4_tx));

% --- ИДЕАЛЬНЫЙ КАНАЛ (для QPSK символов) ---
received_qpsk_symbols_t4_rx = qpsk_symbols_t4_tx;
fprintf('  QPSK символы переданы по идеальному каналу.\n');

% --- Приемник ---
% 5. QPSK Демодуляция
bits_after_qpsk_demod_t4_rx = qpsk_demodulator(received_qpsk_symbols_t4_rx);
fprintf('  5. Выход QPSK демодулятора: %d бит.\n', length(bits_after_qpsk_demod_t4_rx));
if ~isequal(interleaved_bits_t4_tx, bits_after_qpsk_demod_t4_rx)
     fprintf('  ПРЕДУПРЕЖДЕНИЕ ТЕСТ 4: Выход QPSK демодулятора не совпадает с выходом перемежителя TX!\n');
end

% 6. Деперемежение
bits_after_deinterleaving_t4_rx = deinterleaver(bits_after_qpsk_demod_t4_rx, permutation_vector_t4);
fprintf('  6. Выход деперемежителя: %d бит.\n', length(bits_after_deinterleaving_t4_rx));

% 7. Декодирование Витерби
decoded_bits_after_viterbi_t4_rx = vitdec(bits_after_deinterleaving_t4_rx, trellis_conv_t4, tblen_viterbi, 'trunc', 'hard');
fprintf('  7. Выход декодера Витерби: %d бит.\n', length(decoded_bits_after_viterbi_t4_rx));

% 8. Знаковое декодирование
decoded_message_t4_rx = sign_decoder(decoded_bits_after_viterbi_t4_rx, alphabet_sign_t4, symbol_table_sign_t4);
fprintf('  8. Восстановленное текстовое сообщение: "%s"\n', decoded_message_t4_rx);

% --- Проверка результата Теста 4 ---
if strcmp(message_text_t4, decoded_message_t4_rx)
    fprintf(' ТЕСТ 4 УСПЕШЕН: Исходное и декодированное сообщения совпадают.\n');
else
    fprintf(' ТЕСТ 4 ОШИБКА: Исходное и декодированное сообщения НЕ совпадают!\n');
    bit_errors_t4 = sum(info_bits_t4_tx ~= decoded_bits_after_viterbi_t4_rx(1:min(length(info_bits_t4_tx), length(decoded_bits_after_viterbi_t4_rx))));
    fprintf('  Количество битовых ошибок между info_bits_tx и выходом Витерби: %d\n', bit_errors_t4);
end
fprintf('\n===== Тест 4 завершен =====\n');



% =========================================================================
% ТЕСТ 6: Полная цепочка с моделью канала и детальной отладкой
% =========================================================================
N0_test6 = -120; % dBW (ОЧЕНЬ слабый шум для начала)
% N0_test6 = -60; % dBW
% N0_test6 = -40; % dBW

fprintf('\n--- ТЕСТ 6: Полная цепочка с моделью канала (шум %.1f dBW) ---\n', N0_test6);
message_text_t6 = 'Hello_World_123-';

% === ДОБАВЬ ИЛИ ПРОВЕРЬ ЭТОТ БЛОК ===
A_qpsk_vis_t6 = 1/sqrt(2);
% Карта из методички (00, 01, 10, 11)
% 00 -> A+Aj; 01 -> A-Aj; 10 -> -A+Aj; 11 -> -A-Aj;
ideal_map_points_t6 = [A_qpsk_vis_t6 + 1j*A_qpsk_vis_t6, A_qpsk_vis_t6 - 1j*A_qpsk_vis_t6, -A_qpsk_vis_t6 + 1j*A_qpsk_vis_t6, -A_qpsk_vis_t6 - 1j*A_qpsk_vis_t6];
% =====================================

% --- Передатчик ---
fprintf(' Исходное сообщение для Теста 6: "%s"\n', message_text_t6);
[symbol_table_sign_t6, alphabet_sign_t6] = create_symbol_table();
info_bits_t6_tx = sign_encoder(message_text_t6, alphabet_sign_t6, symbol_table_sign_t6);
fprintf('  1. Выход знакового кодера (info_bits_t6_tx): %d бит.\n', length(info_bits_t6_tx));

trellis_conv_t6 = poly2trellis(K_conv, [G1_oct_conv G2_oct_conv]);
encoded_bits_t6_tx = convolutional_encoder(info_bits_t6_tx, trellis_conv_t6);
fprintf('  2. Выход сверточного кодера (encoded_bits_t6_tx): %d бит.\n', length(encoded_bits_t6_tx));

sequence_length_interleaver_t6 = length(encoded_bits_t6_tx);
permutation_vector_t6 = generate_permutation(sequence_length_interleaver_t6);
interleaved_bits_t6_tx = interleaver(encoded_bits_t6_tx, permutation_vector_t6);
fprintf('  3. Выход перемежителя (interleaved_bits_t6_tx): %d бит.\n', length(interleaved_bits_t6_tx));

input_bits_for_qpsk_t6_tx = interleaved_bits_t6_tx;
if mod(length(input_bits_for_qpsk_t6_tx), 2) ~= 0, input_bits_for_qpsk_t6_tx = [input_bits_for_qpsk_t6_tx, 0]; end
qpsk_symbols_t6_tx = qpsk_modulator(input_bits_for_qpsk_t6_tx);
N_QPSK_data_for_ofdm_t6 = length(qpsk_symbols_t6_tx);
fprintf('  4. Выход QPSK модулятора (qpsk_symbols_t6_tx): %d символов.\n', N_QPSK_data_for_ofdm_t6);
fprintf('     Пример TX QPSK символов (первые 3): %s\n', sprintf('%.2f+%.2fi  ', [real(qpsk_symbols_t6_tx(1:min(3,end))); imag(qpsk_symbols_t6_tx(1:min(3,end)))]));


% 5. OFDM Модуляция
[ofdm_signal_t6_tx_cp, N_IFFT_ofdm_t6, Tcp_samples_ofdm_t6, N_Z_ofdm_t6, N_active_ofdm_t6, ...
 pilot_indices_freq_ofdm_t6, data_indices_freq_ofdm_t6] = ...
    ofdm_modulator(qpsk_symbols_t6_tx, N_QPSK_data_for_ofdm_t6, ARS_pilot_step_ofdm, ...
                   C_guard_fraction_ofdm, Tcp_fraction_of_NFFT_ofdm, pilot_value_ofdm);
fprintf('  5. Выход OFDM модулятора: %d отсчетов.\n', length(ofdm_signal_t6_tx_cp));
fprintf('     Пример TX OFDM сигнала (первые 3): %s\n', sprintf('%.2e+%.2ei  ', [real(ofdm_signal_t6_tx_cp(1:min(3,end))); imag(ofdm_signal_t6_tx_cp(1:min(3,end)))]));


% --- МОДЕЛЬ КАНАЛА ---
fprintf('  --- Моделирование Канала Передачи (Этап 6) ---\n');
L_original_ofdm_for_channel_t6 = length(ofdm_signal_t6_tx_cp);
received_ofdm_signal_t6_rx = channel_model(ofdm_signal_t6_tx_cp, L_original_ofdm_for_channel_t6, ...
                               NB_rays_channel, B_signal_Hz_channel, f0_carrier_Hz_channel, N0_test6);
fprintf('  --- Канал пройден. Выход (received_ofdm_signal_t6_rx): %d отсчетов. ---\n', length(received_ofdm_signal_t6_rx));
fprintf('     Пример RX OFDM сигнала (первые 3): %s\n', sprintf('%.2e+%.2ei  ', [real(received_ofdm_signal_t6_rx(1:min(3,end))); imag(received_ofdm_signal_t6_rx(1:min(3,end)))]));


% --- Приемник ---
% 6. OFDM Демодуляция и Эквалайзинг
fprintf('  6. Вход OFDM демодулятора: %d отсчетов.\n', length(received_ofdm_signal_t6_rx));
[qpsk_symbols_t6_rx_eq, H_est_t6_pilots, H_interp_t6, C_rx_debug, H_div_debug] = ... % Получаем отладочные выходы
    ofdm_demodulator_equalizer(received_ofdm_signal_t6_rx, ...
                               N_IFFT_ofdm_t6, Tcp_samples_ofdm_t6, N_Z_ofdm_t6, N_active_ofdm_t6, ...
                               pilot_indices_freq_ofdm_t6, data_indices_freq_ofdm_t6, ...
                               pilot_value_ofdm, ARS_pilot_step_ofdm);
fprintf('     Выход OFDM демодулятора/эквалайзера (qpsk_symbols_t6_rx_eq): %d QPSK-символов.\n', length(qpsk_symbols_t6_rx_eq));
fprintf('     Пример RX_EQ QPSK символов (первые 3): %s\n', sprintf('%.2f+%.2fi  ', [real(qpsk_symbols_t6_rx_eq(1:min(3,end))); imag(qpsk_symbols_t6_rx_eq(1:min(3,end)))]));

% --- Детальный ОТЛАДОЧНЫЙ ВЫВОД для Этапа 6 (OFDM Демод/Экв) ---
fprintf('  ОТЛАДКА OFDM Демодулятора/Эквалайзера:\n');
fprintf('    Амплитуды принятого сигнала на активных поднесущих ДО эквалайзера C_rx_debug(1:5): %s\n', num2str(abs(C_rx_debug(1:min(5,end)))'));
fprintf('    Амплитуды оценки АЧХ на пилотах H_est_t6_pilots(1:5): %s\n', num2str(abs(H_est_t6_pilots(1:min(5,end)))'));
fprintf('    Амплитуды интерполированной АЧХ H_interp_t6(1:5): %s\n', num2str(abs(H_interp_t6(1:min(5,end)))'));
fprintf('    Амплитуды ЗНАМЕНАТЕЛЯ для эквалайзера H_div_debug(1:5): %s\n', num2str(abs(H_div_debug(1:min(5,end)))'));
fprintf('    Амплитуды QPSK символов ПОСЛЕ эквалайзера qpsk_symbols_t6_rx_eq(1:5): %s\n', num2str(abs(qpsk_symbols_t6_rx_eq(1:min(5,length(qpsk_symbols_t6_rx_eq))))'));


% --- Дополнительная проверка QPSK символов ---
fprintf('  --- Дополнительная проверка QPSK символов (при N0=%.1f dBW) ---\n', N0_test6);
if length(qpsk_symbols_t6_tx) == length(qpsk_symbols_t6_rx_eq)
    mse_qpsk_t6 = mean(abs(qpsk_symbols_t6_tx - qpsk_symbols_t6_rx_eq).^2);
    fprintf('     MSE между QPSK TX и QPSK RX_EQ: %e\n', mse_qpsk_t6);
    num_qpsk_errors_t6 = 0;
    for sym_idx = 1:length(qpsk_symbols_t6_tx)
        tx_sym = qpsk_symbols_t6_tx(sym_idx);
        rx_sym_eq = qpsk_symbols_t6_rx_eq(sym_idx);
        [~, tx_ideal_idx] = min(abs(ideal_map_points_t6 - tx_sym));
        [~, rx_ideal_idx] = min(abs(ideal_map_points_t6 - rx_sym_eq));
        if tx_ideal_idx ~= rx_ideal_idx, num_qpsk_errors_t6 = num_qpsk_errors_t6 + 1; end
    end
    ser_qpsk_eq_t6 = num_qpsk_errors_t6 / length(qpsk_symbols_t6_tx);
    fprintf('     Приблизительный SER для QPSK символов после эквалайзера: %f (%d ошибок из %d)\n', ser_qpsk_eq_t6, num_qpsk_errors_t6, length(qpsk_symbols_t6_tx));
else
    fprintf('     ОШИБКА: Несовпадение длин QPSK символов TX и RX_EQ для анализа.\n');
end

% 7. QPSK Демодуляция
bits_after_qpsk_demod_t6_rx = qpsk_demodulator(qpsk_symbols_t6_rx_eq);
fprintf('  7. Выход QPSK демодулятора (bits_after_qpsk_demod_t6_rx): %d бит.\n', length(bits_after_qpsk_demod_t6_rx));

% --- Дополнительная проверка бит после QPSK демодулятора ---
fprintf('  --- Дополнительная проверка бит после QPSK демодулятора (при N0=%.1f dBW) ---\n', N0_test6);
if length(interleaved_bits_t6_tx) == length(bits_after_qpsk_demod_t6_rx)
    bit_errors_after_qpsk_demod_t6 = sum(interleaved_bits_t6_tx ~= bits_after_qpsk_demod_t6_rx);
    fprintf('     Количество битовых ошибок между TX_interleaved и RX_after_QPSK_demod: %d из %d\n', bit_errors_after_qpsk_demod_t6, length(interleaved_bits_t6_tx));
else
    fprintf('     ОШИБКА: Несовпадение длин бит для сравнения после QPSK демодулятора.\n');
end

% 8. Деперемежение
bits_after_deinterleaving_t6_rx = deinterleaver(bits_after_qpsk_demod_t6_rx, permutation_vector_t6);
fprintf('  8. Выход деперемежителя: %d бит.\n', length(bits_after_deinterleaving_t6_rx));

% 9. Декодирование Витерби
decoded_bits_after_viterbi_t6_rx = vitdec(bits_after_deinterleaving_t6_rx, trellis_conv_t6, tblen_viterbi, 'trunc', 'hard');
fprintf('  9. Выход декодера Витерби (decoded_bits_after_viterbi_t6_rx): %d бит.\n', length(decoded_bits_after_viterbi_t6_rx));

% 10. Знаковое декодирование
decoded_message_t6_rx = sign_decoder(decoded_bits_after_viterbi_t6_rx, alphabet_sign_t6, symbol_table_sign_t6);
fprintf('  10. Восстановленное текстовое сообщение: "%s"\n', decoded_message_t6_rx);

% --- Проверка результата Теста 6 ---
final_ber_t6 = NaN;
if strcmp(message_text_t6, decoded_message_t6_rx)
    fprintf(' ТЕСТ 6 УСПЕШЕН: Исходное и декодированное сообщения совпадают (при N0=%.1f dBW).\n', N0_test6);
    bit_errors_final_t6 = 0; final_ber_t6 = 0;
else
    fprintf(' ТЕСТ 6: Исходное и декодированное сообщения НЕ совпадают (при N0=%.1f dBW).\n', N0_test6);
    if length(info_bits_t6_tx) == length(decoded_bits_after_viterbi_t6_rx)
        bit_errors_final_t6 = sum(info_bits_t6_tx ~= decoded_bits_after_viterbi_t6_rx);
        fprintf('  Количество итоговых битовых ошибок (между info_bits_tx и выходом Витерби): %d из %d\n', bit_errors_final_t6, length(info_bits_t6_tx));
        final_ber_t6 = bit_errors_final_t6 / length(info_bits_t6_tx);
        fprintf('  Итоговый BER для Теста 6: %e\n', final_ber_t6);
    else
        fprintf('  ОШИБКА: Невозможно рассчитать итоговый BER из-за несовпадения длин бит после Витерби.\n');
    end
end

% Замени строки отладочного вывода в ТЕСТЕ 6 на эти:
fprintf('  ОТЛАДКА OFDM Демодулятора/Эквалайзера:\n');
fprintf('    abs(C_rx_debug(1:3)): [%.2e, %.2e, %.2e]\n', abs(C_rx_debug(1:min(3,end))));
fprintf('    abs(H_est_t6_pilots(1:3)): [%.2e, %.2e, %.2e]\n', abs(H_est_t6_pilots(1:min(3,end))));
fprintf('    abs(H_interp_t6(1:3)): [%.2e, %.2e, %.2e]\n', abs(H_interp_t6(1:min(3,end))));
fprintf('    abs(H_div_debug(1:3)): [%.2e, %.2e, %.2e]\n', abs(H_div_debug(1:min(3,end))));
fprintf('    abs(qpsk_symbols_t6_rx_eq(1:3)): [%.2f, %.2f, %.2f]\n', abs(qpsk_symbols_t6_rx_eq(1:min(3,end))));
fprintf('    angle(qpsk_symbols_t6_tx(1:3)): [%.2f, %.2f, %.2f]\n', angle(qpsk_symbols_t6_tx(1:min(3,end))));
fprintf('    angle(qpsk_symbols_t6_rx_eq(1:3)): [%.2f, %.2f, %.2f]\n', angle(qpsk_symbols_t6_rx_eq(1:min(3,end))));
fprintf('\n===== Тест 6 завершен =====\n');

% Визуализация для Теста 6
figure('Name', sprintf('Тест 6: Канал N0=%.1fdBW', N0_test6));
subplot(1,2,1); plot(real(qpsk_symbols_t6_rx_eq), imag(qpsk_symbols_t6_rx_eq), 'g.'); hold on;
plot(real(ideal_map_points_t6), imag(ideal_map_points_t6), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
axis equal; grid on; xlim([-2 2]); ylim([-2 2]); title('Созвездие QPSK после эквалайзера (Канал)');
xlabel('In-Phase'); ylabel('Quadrature');
subplot(1,2,2); plot(0:N_active_ofdm_t6-1, abs(H_interp_t6), 'b-');
title('Оценка |АЧХ| канала (H_{interp})'); xlabel('Индекс активной поднесущей'); ylabel('|H_{est}|');
grid on; xlim([-1 N_active_ofdm_t6]);


