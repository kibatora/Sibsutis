function [qpsk_symbols_rx_eq, H_est_on_pilots, H_interpolated_full, C_rx_active_subcarriers_debug, H_for_division_debug] = ofdm_demodulator_equalizer(ofdm_signal_rx, N_IFFT, Tcp_samples, N_Z, N_active, pilot_indices_freq_global, data_indices_freq_global, pilot_value_tx, ARS_pilot_step)

if Tcp_samples > 0
    ofdm_signal_no_cp = ofdm_signal_rx(Tcp_samples + 1 : end);
else
    ofdm_signal_no_cp = ofdm_signal_rx;
end
ofdm_freq_domain_rx = fft(ofdm_signal_no_cp, N_IFFT);
C_rx_active_subcarriers = ofdm_freq_domain_rx(N_Z + 1 : N_Z + N_active);
C_rx_active_subcarriers_debug = C_rx_active_subcarriers;

pilot_indices_in_active_band = pilot_indices_freq_global - N_Z;
data_indices_in_active_band  = data_indices_freq_global - N_Z;

R_rx_pilots = C_rx_active_subcarriers(pilot_indices_in_active_band);
N_RS = length(R_rx_pilots);

R_tx_pilots = repmat(pilot_value_tx, 1, N_RS);
H_est_on_pilots = R_rx_pilots ./ R_tx_pilots;

x_known_pilots = pilot_indices_in_active_band;
v_known_H_pilots = H_est_on_pilots;
x_query_all_active = 1:N_active;

H_interpolated_full = interp1(x_known_pilots, v_known_H_pilots, x_query_all_active, 'spline', 'extrap'); 

if any(isnan(H_interpolated_full))
    H_interpolated_full = fillmissing(H_interpolated_full, 'nearest', 'EndValues','nearest');
    if any(isnan(H_interpolated_full))
        H_interpolated_full(isnan(H_interpolated_full)) = 1 + 0j;
    end
end

H_for_division = H_interpolated_full;
mean_H_abs = mean(abs(H_interpolated_full(H_interpolated_full~=0)));
if isnan(mean_H_abs) || mean_H_abs == 0, mean_H_abs = 1e-3; end
relative_epsilon_factor = 0.05;
actual_epsilon = mean_H_abs * relative_epsilon_factor;
min_absolute_epsilon = 1e-6; 
actual_epsilon = max(actual_epsilon, min_absolute_epsilon);

mask_small_H_amplitude = abs(H_interpolated_full) < actual_epsilon;
H_phase_small = angle(H_interpolated_full(mask_small_H_amplitude));
H_for_division(mask_small_H_amplitude) = actual_epsilon * exp(1j * H_phase_small);
zero_H_indices = (H_interpolated_full == 0);
H_for_division(zero_H_indices) = actual_epsilon;
H_for_division_debug = H_for_division;

C_eq_active_subcarriers = C_rx_active_subcarriers ./ H_for_division;

qpsk_symbols_rx_eq = C_eq_active_subcarriers(data_indices_in_active_band);

end