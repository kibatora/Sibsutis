% Параметры системы
x = 5;          % Среднее время обслуживания
ro = 0.1:0.05:0.95;  % Коэффициент загрузки
Cb2 = [0, 1, 10, 20, 30:10:100]; % Нормированная дисперсия

% Инициализация результатов
[Nq_MG1, N_MG1, W_MG1, T_MG1] = deal(zeros(length(Cb2), length(ro)));
[Nq_MD1, N_MD1, W_MD1, T_MD1] = deal(zeros(1, length(ro)));
[Nq_MM1, N_MM1, W_MM1, T_MM1] = deal(zeros(1, length(ro)));

% --- Расчет характеристик M/G/1 ---
for i = 1:length(Cb2)
    Nq_MG1(i,:) = (ro.^2 .* (1 + Cb2(i))) ./ (2 * (1 - ro));
    N_MG1(i,:) = ro + Nq_MG1(i,:);
    W_MG1(i,:) = (ro .* x .* (1 + Cb2(i))) ./ (2 * (1 - ro));
    T_MG1(i,:) = x + W_MG1(i,:);
end

% --- Расчет характеристик M/D/1 ---
Nq_MD1 = ro.^2 ./ (2 * (1 - ro));
N_MD1 = ro + Nq_MD1;
W_MD1 = (ro .* x) ./ (2 * (1 - ro));
T_MD1 = (x .* (2 - ro)) ./ (2 * (1 - ro));

% --- Расчет характеристик M/M/1 ---
Nq_MM1 = ro.^2 ./ (1 - ro);
N_MM1 = ro ./ (1 - ro);
W_MM1 = (ro .* x) ./ (1 - ro);
T_MM1 = x ./ (1 - ro);

% --- Построение графиков ---
plotCharacteristics(ro, Nq_MG1, Nq_MD1, Nq_MM1, Cb2, 'Средняя длина очереди (Nq)');
plotCharacteristics(ro, N_MG1, N_MD1, N_MM1, Cb2, 'Среднее число заявок в СМО (N)');
plotCharacteristics(ro, W_MG1, W_MD1, W_MM1, Cb2, 'Среднее время ожидания (W)');
plotCharacteristics(ro, T_MG1, T_MD1, T_MM1, Cb2, 'Среднее время пребывания (T)');



% --- Функция для построения графиков ---
function plotCharacteristics(ro, data_MG1, data_MD1, data_MM1, Cb2, ylabel_text)
    figure;
    hold on;

    for i = 1:length(Cb2)
        plot(ro, data_MG1(i,:), 'DisplayName', ['M/G/1, Cb2 = ', num2str(Cb2(i))]);
    end
    plot(ro, data_MD1, 'DisplayName', 'M/D/1');
    plot(ro, data_MM1, 'DisplayName', 'M/M/1');

    xlabel('Коэффициент загрузки (ро)');
    ylabel(ylabel_text);
    legend('show', 'Location', 'northwest');  % Улучшенное расположение легенды
    title(['Зависимость ', ylabel_text, ' от коэффициента загрузки']);

    hold off;
end