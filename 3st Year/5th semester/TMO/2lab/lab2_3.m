% Параметры
N = 400;     
K = 800;      
mu = 0;       
sigma = 1;    

% Создание матрицы случайных блужданий с затуханием
E_damped = zeros(N, K);
for j = 1:K
    for n = 2:N
        E_damped(n, j) = 0.9 * E_damped(n-1, j) + mu + sigma * randn(); 
    end
end

% График всех реализаций
figure;
plot(E_damped);
xlabel('n');
ylabel('ξ[n]');
title('Реализации случайного блуждания с затуханием');

% Scatter-диаграммы
pairs1 = [1, 9; 50, 49; 100, 99; 200, 199];
pairs2 = [50, 40; 100, 90; 200, 190];

figure;
subplot(1, 2, 1);
hold on;
for i = 1:size(pairs1, 1)
    n_i = pairs1(i, 1);
    n_j = pairs1(i, 2);
    scatter(E_damped(n_i, :), E_damped(n_j, :), '.', 'DisplayName', ['n_i=' num2str(n_i) ', n_j=' num2str(n_j)]);
end
xlabel('ξ[n_i]');
ylabel('ξ[n_j]');
title('Scatter-диаграммы (l = 1, 10) с затуханием');
legend('show');

subplot(1, 2, 2);
hold on;
for i = 1:size(pairs2, 1)
    n_i = pairs2(i, 1);
    n_j = pairs2(i, 2);
    scatter(E_damped(n_i, :), E_damped(n_j, :), '.', 'DisplayName', ['n_i=' num2str(n_i) ', n_j=' num2str(n_j)]);
end
xlabel('ξ[n_i]');
ylabel('ξ[n_j]');
title('Scatter-диаграммы (l = 10, 20, 30) с затуханием');
legend('show');

% Задание 10

% 1. Выборочная автокорреляция для процесса с затуханием
r_hat_damped = zeros(N-1, 1);
for l = 1:N-1
    r_hat_damped(l) = mean(mean(E_damped(l+1:end, :) .* E_damped(1:end-l, :)));  % Добавили mean()
end

% 2. График автокорреляции (с затуханием)
figure;
plot(1:N-1, r_hat_damped, 'b', 'DisplayName', 'Выборочная (с затуханием)');
hold on;
plot(1:N-1, (sigma^2 / (1 - 0.9^2)) * 0.9.^(0:N-2), 'r--', 'DisplayName', 'Теоретическая (с затуханием)');
xlabel('n');
ylabel('r(n, n-1)');
title('Автокорреляция случайного блуждания с затуханием');
legend('show');

% 3. Сравнение результатов пунктов 6 и 9
%    (см. описание ниже)

% 4. Гипотеза о равенстве средних
l1 = 4;
l2 = 40;

% Выбираем две реализации (два столбца)
realization1 = E_damped(:, 1);
realization2 = E_damped(:, 2);

% Средние по времени
mean_time1_l1 = mean(realization1(1+l1:end) .* realization1(1:end-l1));
mean_time1_l2 = mean(realization1(1+l2:end) .* realization1(1:end-l2));
mean_time2_l1 = mean(realization2(1+l1:end) .* realization2(1:end-l1));
mean_time2_l2 = mean(realization2(1+l2:end) .* realization2(1:end-l2));

% Сравнение
fprintf('Среднее по времени (реализация 1, l1 = %d): %f\n', l1, mean_time1_l1);
fprintf('Среднее по времени (реализация 1, l2 = %d): %f\n', l2, mean_time1_l2);
fprintf('Среднее по времени (реализация 2, l1 = %d): %f\n', l1, mean_time2_l1);
fprintf('Среднее по времени (реализация 2, l2 = %d): %f\n', l2, mean_time2_l2);
fprintf('Теоретическая автокорреляция (l1 = %d): %f\n', l1, 0.9^l1);
fprintf('Теоретическая автокорреляция (l2 = %d): %f\n', l2, 0.9^l2);
fprintf('Выборочная автокорреляция по ансамблю (l1 = %d): %f\n', l1, r_hat_damped(l1));
fprintf('Выборочная автокорреляция по ансамблю (l2 = %d): %f\n', l2, r_hat_damped(l2));

% 5. Графики АКФ
figure;
% Белый шум (для сравнения)
subplot(3, 1, 1);
stem(0:N-2, [1; zeros(N-2, 1)]);
xlabel('l');
ylabel('r(l)');
title('АКФ белого шума');

% Случайное блуждание (из задания 6)
subplot(3, 1, 2);
hold on;  % Добавляем hold on для рисования нескольких линий
stem(0:N-2, r_hat, 'b', 'DisplayName', 'Выборочная');
plot(0:N-2, r_theoretical, 'r--', 'DisplayName', 'Теоретическая'); 
xlabel('l');
ylabel('r(l)');
title('АКФ случайного блуждания');
legend('show'); 

% Случайное блуждание с затуханием
subplot(3, 1, 3);
hold on;
stem(0:N-2, r_hat_damped, 'b', 'DisplayName', 'Выборочная');
plot(0:N-2, (sigma^2 / (1 - 0.9^2)) * 0.9.^(0:N-2), 'r--', 'DisplayName', 'Теоретическая');
xlabel('l');
ylabel('r(l)');
title('АКФ случайного блуждания с затуханием');
legend('show'); 