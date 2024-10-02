% Параметры сигнала
A = 7;  % Амплитуда
f = 7;  % Частота, Гц
phi = pi/12;  % Фазовый сдвиг, рад

% Временной интервал
fs = 1000;  % Частота дискретизации, Гц
t = 0:1/fs:1;  % Временной вектор от 0 до 1 секунды

% Генерация сигнала
y = A * sin(2 * pi * f * t + phi);

% Визуализация сигнала
plot(t, y);
xlabel('Время, с');
ylabel('Амплитуда');
title('График непрерывного периодического сигнала');
grid on;

% Частота дискретизации по Котельникову
fs_kotelnikov = 14;  % Гц

% Число отсчетов на 1 секунду
N = fs_kotelnikov * 1; 

% Новый вектор времени с частотой дискретизации по Котельникову
t_discrete = linspace(0, 1, N); 

% Оцифровка сигнала
y_discrete = A * sin(2 * pi * f * t_discrete + phi); 

disp(y_discrete); 

% Дискретное преобразование Фурье
Y = fft(y_discrete);

% Спектр амплитуд
amplitude_spectrum = abs(Y);

% Частоты спектра
frequencies = fs_kotelnikov * (0:(N/2))/N;

% Поиск ширины спектра (по уровню -3 дБ)
threshold = max(amplitude_spectrum) / sqrt(2);
above_threshold = amplitude_spectrum > threshold;
spectrum_width = max(frequencies(above_threshold));

% Оценка объема памяти
memory_size = whos('y_discrete');
memory_size = memory_size.bytes;

% Вывод результатов
disp('Ширина спектра (по уровню -3 дБ):');
disp(spectrum_width);
disp('Объем памяти для массива:');
disp(memory_size);

% Визуализация спектра (необязательно)
figure;
plot(frequencies, amplitude_spectrum(1:N/2+1));
xlabel('Частота, Гц');
ylabel('Амплитуда');
title('Спектр амплитуд');

% Временной вектор для восстановленного сигнала
t_reconstructed = linspace(0, 1, N); 

% Восстановление сигнала
y_reconstructed = interp1(t_discrete, y_discrete, t_reconstructed, 'linear');

% Визуализация оригинального и восстановленного сигналов
figure;
hold on; 
plot(t, y, 'b-', 'LineWidth', 1.5);
plot(t_reconstructed, y_reconstructed, 'r--', 'LineWidth', 1.5); 
hold off;
xlabel('Время, с');
ylabel('Амплитуда');
title('Оригинальный и восстановленный сигналы');
legend('Оригинальный', 'Восстановленный');
grid on;
