function [S_rx_final, Smpy_out] = channel_model(ofdm_symbol_time_cp_input, L_original, NB_rays, B_signal_Hz, f0_carrier_Hz, N0_dB_power)

c = 3e8; 
Ts = 1 / B_signal_Hz;
Stx = ofdm_symbol_time_cp_input;


D_meters = 10 + (500-10) * rand(1, NB_rays); 
D_min = min(D_meters);


Smpy_components = zeros(NB_rays, L_original + ceil(max(D_meters)/ (c*Ts)) ); 
max_total_len = 0; 

for i = 1:NB_rays
    tau_i_samples = round((D_meters(i) - D_min) / (c * Ts));
    S_i = [zeros(1, tau_i_samples), Stx];

    if D_meters(i) < 1e-6 
        G_i = 0;
    else
        G_i = c / (4 * pi * D_meters(i) * f0_carrier_Hz);
    end
    
    channel_gain_factor = 9; 
    G_i = G_i * channel_gain_factor;


    S_i_attenuated = G_i * S_i;
    
    current_len = length(S_i_attenuated);
    if current_len > size(Smpy_components, 2)
        Smpy_components = [Smpy_components, zeros(NB_rays, current_len - size(Smpy_components, 2))];
    end
    Smpy_components(i, 1:current_len) = S_i_attenuated;
    
    if current_len > max_total_len
        max_total_len = current_len;
    end
end


if max_total_len < size(Smpy_components, 2)
    Smpy_components = Smpy_components(:, 1:max_total_len);
end

Smpy = sum(Smpy_components, 1);

Smpy_out = Smpy;


M_noise = length(Smpy); 
noise_vector = wgn(1, M_noise, N0_dB_power, 1, 'dBW', 'complex'); 

S_rx_noisy = Smpy + noise_vector;

if length(S_rx_noisy) >= L_original
    S_rx_final = S_rx_noisy(1:L_original);
else
    S_rx_final = [S_rx_noisy, zeros(1, L_original - length(S_rx_noisy))];
   
end


end