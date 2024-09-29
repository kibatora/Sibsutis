% Параметры
N = 400;     
K = 800;      
mu = 0;       
sigma = 1;    

% Создание матрицы случайных блужданий
E = zeros(N, K);
for j = 1:K
    for n = 2:N
        E(n, j) = E(n-1, j) + mu + sigma * randn(); 
    end
end

% График всех реализаций
figure;
plot(E);
xlabel('n');
ylabel('ξ[n]');
title('Реализации случайного блуждания');

% Scatter-диаграммы
pairs1 = [1, 9; 50, 49; 100, 99; 200, 199];
pairs2 = [50, 40; 100, 90; 200, 190];

figure;
subplot(1, 2, 1);
hold on;
for i = 1:size(pairs1, 1)
    n_i = pairs1(i, 1);
    n_j = pairs1(i, 2);
    scatter(E(n_i, :), E(n_j, :), '.', 'DisplayName', ['n_i=' num2str(n_i) ', n_j=' num2str(n_j)]);
end
xlabel('ξ[n_i]');
ylabel('ξ[n_j]');
title('Scatter-диаграммы (l = 1, 10)');
legend('show');

subplot(1, 2, 2);
hold on;
for i = 1:size(pairs2, 1)
    n_i = pairs2(i, 1);
    n_j = pairs2(i, 2);
    scatter(E(n_i, :), E(n_j, :), '.', 'DisplayName', ['n_i=' num2str(n_i) ', n_j=' num2str(n_j)]);
end
xlabel('ξ[n_i]');
ylabel('ξ[n_j]');
title('Scatter-диаграммы (l = 10, 20, 30)');
legend('show');

% Задание 7
% Выборочная автокорреляция по ансамблю
r_hat = zeros(N-1, 1);
for n = 2:N
    r_hat(n-1) = mean(E(n, :) .* E(n-1, :)); 
end

% Теоретическая автокорреляция
r_theoretical = (1:N-1)'; % Так как σ²ω = 1

% График
figure;
plot(1:N-1, r_hat, 'b', 'DisplayName', 'Выборочная');
hold on;
plot(1:N-1, r_theoretical, 'r--', 'DisplayName', 'Теоретическая');
xlabel('n');
ylabel('r(n, n-1)');
title('Автокорреляция случайного блуждания');
legend('show');