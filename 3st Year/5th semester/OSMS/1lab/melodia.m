% Параметры мелодии
Fs = 8000;        % Частота дискретизации (сэмплы в секунду)

% Ритмические параметры для нот (в секундах)
note_durations = [0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, ...
                  0.25, 0.25, 0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.5, ...
                  0.25, 0.25, 0.5];

% Частоты нот (в герцах)
E = 659.25; % Нота E (ми)
D = 587.33; % Нота D (ре)
C = 523.25; % Нота C (до)
G = 392.00; % Нота G (соль)
A = 440.00; % Нота A (ля)
F = 349.23; % Нота F (фа)

% Генерация нот с использованием различных типов волн
melody = [];
notes = [E, E, E, E, E, E, E, G, C, D, E, F, F, F, F, F, E, E, D, D, G];

for i = 1:length(notes)
    % Сложный тембр
    waveform = 'complex'; 
    note = generate_note(notes(i), note_durations(i), Fs, waveform);
    
    % Применение огибающей
    envelope = linspace(0, 1, round(0.05 * Fs)); % Плавное нарастание
    envelope = [envelope, ones(1, length(note) - length(envelope) * 2), fliplr(envelope)];
    if length(envelope) > length(note)
        envelope = envelope(1:length(note)); % Обрезаем огибающую, если она длиннее ноты
    end
    note = note .* envelope; % Применяем огибающую к ноте
    
    % Уменьшаем вариации в амплитуде
    variation = 0.01 * randn(1, length(note)); % Меньшие изменения
    note = note + variation; % Применяем вариацию к ноте
    
    % Применяем фильтр низких частот
    note = lowpass_filter(note, 1000, Fs); % Фильтруем частоты выше 1000 Гц

    % Увеличиваем громкость
    volume_multiplier = 2; % Коэффициент увеличения громкости
    note = note * volume_multiplier; 
    note = min(note, 1); % Убеждаемся, что амплитуда не превышает 1

    melody = [melody, note, zeros(1, round(0.1 * Fs))]; % Добавляем паузы между нотами
end

% Воспроизведение мелодии
sound(melody, Fs);

% Графическое отображение мелодии
plot(melody);
title('Увеличенная громкость мелодии Jingle Bells');
xlabel('Время (сэмплы)');
ylabel('Амплитуда');

% Сохранение мелодии в файл
filename = 'louder_jingle_bells_melody.wav';
audiowrite(filename, melody, Fs);
disp(['Мелодия сохранена в файл: ' filename]);

% Функция для генерации звуковой волны с различными тембрами
function note = generate_note(frequency, duration, Fs, waveform_type)
    t = 0:1/Fs:duration;
    switch waveform_type
        case 'sine'
            note = sin(2 * pi * frequency * t); % Синусоидальная волна
        case 'square'
            note = square(2 * pi * frequency * t); % Квадратная волна
        case 'sawtooth'
            note = sawtooth(2 * pi * frequency * t); % Пиловидная волна
        case 'complex'
            % Комбинированная волна с гармониками
            harmonics = [0.3, 0.1, 0.05]; % Соотношения для гармоник
            note = harmonics(1) * sin(2 * pi * frequency * t);
            for k = 2:length(harmonics)
                note = note + harmonics(k) * sin(2 * pi * frequency * k * t); % Добавляем гармоники
            end
        otherwise
            note = sin(2 * pi * frequency * t); % По умолчанию синусоидальная
    end
end

% Функция для фильтрации низких частот
function output = lowpass_filter(input, cutoff_freq, Fs)
    [b, a] = butter(6, cutoff_freq/(Fs/2), 'low'); % 6-й порядок фильтра Баттерворта
    output = filter(b, a, input); % Применяем фильтр
end
