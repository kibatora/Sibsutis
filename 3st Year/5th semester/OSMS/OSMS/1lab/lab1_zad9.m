% Чтение аудиофайла
[y, Fs] = audioread('voice.wav');

% Вывод информации о файле
info = audioinfo('voice.wav');
disp(info);

% Длительность сигнала
signal_duration = length(y) / Fs;

% Временной вектор
t = linspace(0, signal_duration, length(y));

% Построение графика сигнала
figure;
plot(t, y);
xlabel('Время, с');
ylabel('Амплитуда');
title('Осциллограмма сигнала');

% Спектральный анализ
N = length(y);
frequencies = Fs * (0:(N/2))/N;
Y = fft(y, N);
amplitude_spectrum = abs(Y/N); 

% Построение спектра амплитуд
figure;
plot(frequencies, 2*amplitude_spectrum(1:N/2+1));
xlabel('Частота, Гц');
ylabel('Амплитуда');
title('Спектр амплитуд');
xlim([0, 10000]); % Ограничиваем диапазон частот для наглядности

% Расчет частоты дискретизации
Fs_calculated = info.TotalSamples / info.Duration;

% Сравнение 
disp(['Рассчитанная частота дискретизации: ', num2str(Fs_calculated), ' Гц']);
disp(['Частота дискретизации из audioinfo: ', num2str(Fs), ' Гц']);

% Прореживание сигнала
downsample_factor = 10; 
y1 = downsample(y, downsample_factor);

% Новая частота дискретизации
Fs1 = Fs / downsample_factor; 

% Воспроизведение прореженного сигнала
zvuk = audioplayer(y1, Fs1);
play(zvuk); 

% Спектр амплитуд прореженного сигнала
N1 = length(y1);
frequencies1 = Fs1 * (0:(N1/2))/N1;
Y1 = fft(y1, N1);
amplitude_spectrum1 = abs(Y1/N1);

% Построение спектра амплитуд
figure;
plot(frequencies1, 2*amplitude_spectrum1(1:N1/2+1));
xlabel('Частота, Гц');
ylabel('Амплитуда');
title('Спектр амплитуд прореженного сигнала');


% Создание графика
figure;
hold on; 
plot(frequencies, 2*amplitude_spectrum(1:N/2+1)); 
plot(frequencies1, 2*amplitude_spectrum1(1:N1/2+1));
hold off;
xlabel('Frequency, Hz');
ylabel('Magnitude');
title('Magnitude Spectrum');
xlim([0, Fs/2]); % Ограничиваем диапазон до Fs/2
legend('Original Signal', 'Downsampled Signal');

% Порог -3 дБ
threshold_dB = -3;

% --- Оригинальный сигнал ---
threshold = max(2*amplitude_spectrum) * 10^(threshold_dB/20);
above_threshold = 2*amplitude_spectrum > threshold;
f_start = frequencies(find(above_threshold, 1, 'first'));
last_index = min(length(frequencies), find(above_threshold, 1, 'last')); 
f_end = frequencies(last_index);
spectrum_width = f_end - f_start;
disp(['Оригинальный сигнал - Ширина спектра (порог -3 дБ): ', num2str(spectrum_width), ' Гц'])

% --- Прореженный сигнал ---
threshold1 = max(2*amplitude_spectrum1) * 10^(threshold_dB/20);
above_threshold1 = 2*amplitude_spectrum1 > threshold1;
f_start1 = frequencies1(find(above_threshold1, 1, 'first'));
last_index1 = min(length(frequencies1), find(above_threshold1, 1, 'last'));
f_end1 = frequencies1(last_index1);
spectrum_width1 = f_end1 - f_start1;
disp(['Прореженный сигнал - Ширина спектра (порог -3 дБ): ', num2str(spectrum_width1), ' Гц'])



% --- Квантование сигнала ---
bits_to_test = [3, 4, 5, 6];
quantization_errors = zeros(size(bits_to_test)); 

for i = 1:length(bits_to_test)
    num_bits = bits_to_test(i);
    
    % Квантование
    quantized_y = quantize_signal(y, num_bits);  

    % Ошибка квантования
    quantization_errors(i) = mean(abs(y - quantized_y));

    % --- ДПФ и спектр квантованного сигнала ---
    quantized_Y = fft(quantized_y, N);
    quantized_amplitude_spectrum = abs(quantized_Y/N);

    % --- Построение графика ---
    figure; 
    hold on;
    plot(frequencies, 2*amplitude_spectrum(1:N/2+1)); 
    plot(frequencies, 2*quantized_amplitude_spectrum(1:N/2+1)); 
    hold off;
    xlabel('Frequency, Hz');
    ylabel('Magnitude');
    title(['Magnitude Spectrum (', num2str(num_bits), ' bits)']);
    xlim([0, Fs/2]);
    legend('Original Signal', 'Quantized Signal');
end

% --- Вывод ошибок квантования ---
disp('Средние ошибки квантования:');
for i = 1:length(bits_to_test)
    disp(['Разрядность АЦП: ', num2str(bits_to_test(i)), ...
          ', Ошибка: ', num2str(quantization_errors(i))]);
end

function quantized_signal = quantize_signal(signal, num_bits)
  % Квантует сигнал, используя заданное количество бит.
  
  max_level = 2^num_bits - 1;
  quantization_step = 1 / max_level;
  
  % Квантование и масштабирование
  quantized_signal = round(signal / quantization_step) * quantization_step;
  
  % Ограничение значений в диапазоне [0, 1]
  quantized_signal(quantized_signal > 1) = 1; 
  quantized_signal(quantized_signal < 0) = 0;
end