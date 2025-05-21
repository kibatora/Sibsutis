function [ofdm_symbol_time_cp, N_IFFT, Tcp_samples, N_Z, N_active, pilot_indices_freq, data_indices_freq] = ofdm_modulator(qpsk_symbols_input, N_QPSK_data, ARS_pilot_step, C_guard_fraction, Tcp_fraction_of_NFFT, pilot_value)


N_active = N_QPSK_data; 
N_RS = 0;
while true
    pilot_indices_in_active_band = 1:ARS_pilot_step:N_active;
    N_RS_calculated = length(pilot_indices_in_active_band);
    N_data_calculated = N_active - N_RS_calculated;

    if N_data_calculated == N_QPSK_data
        N_RS = N_RS_calculated;
        break;
    elseif N_data_calculated < N_QPSK_data
        N_active = N_active + 1; 
    else 
        N_active = N_active - 1; 

        pilot_indices_in_active_band = 1:ARS_pilot_step:N_active;
        N_RS_calculated = length(pilot_indices_in_active_band);
        N_data_calculated = N_active - N_RS_calculated;
        if N_data_calculated == N_QPSK_data 
            N_RS = N_RS_calculated;
            break;
        else 
            N_active = N_active + 1;
            pilot_indices_in_active_band = 1:ARS_pilot_step:N_active;
            N_RS = length(pilot_indices_in_active_band);
            if (N_active - N_RS) ~= N_QPSK_data
                 warning('Не удалось точно подобрать N_active для %d данных с ARS=%d. Активных: %d, Пилотов: %d, Данных: %d', N_QPSK_data, ARS_pilot_step, N_active, N_RS, N_active - N_RS);
                 error('Критическая ошибка в расчете N_active. Проверьте логику или входные N_QPSK/ARS.');
            end
            break;
        end
    end
    if N_active > 2 * N_QPSK_data + N_QPSK_data / (ARS_pilot_step -1) + 5 % Предохранитель
        error('Не удалось определить N_active. Возможно, некорректные N_QPSK или ARS.');
    end
end
data_indices_in_active_band = setdiff(1:N_active, pilot_indices_in_active_band);
if length(data_indices_in_active_band) ~= N_QPSK_data
   error('Ошибка в количестве индексов данных: %d, ожидалось %d', length(data_indices_in_active_band), N_QPSK_data);
end

N_Z = round(C_guard_fraction * N_active);


N_IFFT = N_active + 2 * N_Z;


ofdm_freq_domain_vector = zeros(1, N_IFFT);


first_active_subcarrier_index = N_Z + 1;
pilot_indices_freq = first_active_subcarrier_index + pilot_indices_in_active_band - 1;
data_indices_freq  = first_active_subcarrier_index + data_indices_in_active_band - 1;


ofdm_freq_domain_vector(pilot_indices_freq) = pilot_value;

ofdm_freq_domain_vector(data_indices_freq) = qpsk_symbols_input;

ofdm_symbol_time = ifft(ofdm_freq_domain_vector, N_IFFT);

Tcp_samples = round(Tcp_fraction_of_NFFT * N_IFFT);


if Tcp_samples > 0
    cyclic_prefix_to_add = ofdm_symbol_time(end - Tcp_samples + 1 : end);
    ofdm_symbol_time_cp = [cyclic_prefix_to_add, ofdm_symbol_time];
else
    ofdm_symbol_time_cp = ofdm_symbol_time; 
end

end