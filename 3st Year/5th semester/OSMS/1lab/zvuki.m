% Параметры сигналов
fs = 44100;             % Частота дискретизации (Гц)
duration = 2;            % Длительность сигнала (секунды)
t = (0:1/fs:duration-1/fs); % Массив времени

% Низкочастотный сигнал (например, 200 Гц)
frequency_low = 100; 
amplitude_low = 0.5;
signal_low = amplitude_low * sin(2*pi*frequency_low*t);

% Высокочастотный сигнал (например, 5000 Гц)
frequency_high = 9000;
amplitude_high = 0.3;
signal_high = amplitude_high * sin(2*pi*frequency_high*t);

% Сохранение звуковых файлов (WAV)
audiowrite('low_frequency1.wav', signal_low, fs);
audiowrite('high_frequency1.wav', signal_high, fs);