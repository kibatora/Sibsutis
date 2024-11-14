% Задание векторов (из задания 6)
a = [0.3 0.2 -0.1 4.2 -2 1.5 0];
b = [0.3 4 -2.2 1.6 0.1 0.1 0.2];

% Инициализация переменных
correlations = zeros(1, length(b)); % Вектор для хранения значений корреляции
max_correlation = -Inf; % Начальное значение максимальной корреляции
max_correlation_shift = 0; % Начальное значение сдвига с максимальной корреляцией

% Цикл по сдвигам
for shift = 1:length(b)
    % Циклический сдвиг вектора b
    shifted_b = circshift(b, [0, shift - 1]); 

    % Вычисление корреляции
    correlations(shift) = sum(a .* shifted_b);

    % Обновление максимальной корреляции и сдвига
    if correlations(shift) > max_correlation
        max_correlation = correlations(shift);
        max_correlation_shift = shift - 1;
    end
end

% Вывод результатов
disp(['Максимальная корреляция: ', num2str(max_correlation)]);
disp(['Сдвиг с максимальной корреляцией: ', num2str(max_correlation_shift)]);

% Построение графиков
t = 1:length(a); % Ось времени (индексы элементов)
shifted_b_max = circshift(b, [0, max_correlation_shift]); % Сдвигаем b на оптимальное значение

subplot(2,1,1);
plot(t, a, 'b-', 'LineWidth', 2);
hold on;
plot(t, shifted_b_max, 'r-', 'LineWidth', 2);
title('Графики a и b (сдвинутый) с максимальной корреляцией');
legend('a', 'b (сдвинутый)');
xlabel('Индекс элемента');
ylabel('Значение');

subplot(2,1,2);
plot(1:length(b), correlations, 'g-', 'LineWidth', 2);
title('Зависимость корреляции от сдвига');
xlabel('Сдвиг');
ylabel('Корреляция');
