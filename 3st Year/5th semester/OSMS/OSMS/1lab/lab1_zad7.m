% Параметры сигнала
A = 7;
f = 7;
phi = pi/12;

% Частота дискретизации (увеличена в 4 раза)
fs = 56;

% Время
t = 0:1/fs:1;
N = length(t); % Количество отсчетов

% Генерация исходного сигнала
y = A * sin(2 * pi * f * t + phi);

% Оцифровка сигнала 
y_discrete = A * sin(2 * pi * f * t + phi);

% ДПФ и спектр амплитуд
Y = fft(y_discrete);
amplitude_spectrum = abs(Y);
frequencies = fs * (0:(N/2))/N;

% Ширина спектра (по уровню -3 дБ)
threshold = max(amplitude_spectrum) / sqrt(2);
above_threshold = amplitude_spectrum > threshold;

% Ограничиваем индексы
above_threshold = above_threshold(1:length(frequencies));

spectrum_width = max(frequencies(above_threshold));

% Объем памяти
memory_size = whos('y_discrete');
memory_size = memory_size.bytes;

% Вывод результатов ДПФ и объема памяти
disp('Ширина спектра (по уровню -3 дБ):');
disp(spectrum_width);
disp('Объем памяти для массива:');
disp(memory_size);

% Восстановление сигнала
t_reconstructed = linspace(0, 1, N);
y_reconstructed = interp1(t, y_discrete, t_reconstructed, 'linear');

% Визуализация
figure;
hold on;
plot(t, y, 'b-', 'LineWidth', 1.5);
plot(t_reconstructed, y_reconstructed, 'r--', 'LineWidth', 1.5);
hold off;
xlabel('Время, с');
ylabel('Амплитуда');
title('Оригинальный и восстановленный сигналы (fs увеличена в 4 раза)');
legend('Оригинальный', 'Восстановленный');
grid on;