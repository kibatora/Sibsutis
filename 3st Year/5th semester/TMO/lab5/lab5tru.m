% --- Задание 3: Матрица переходов ---
L = 15;
T = zeros(L, L);

% Заполняем ненулевые элементы матрицы T, соблюдая условия:
% Минимум 3 исходящих и 1 входящий маршрут для каждого узла
T(1, [2 5 8]) = 1/3;   % Из узла 1 переходы в 2, 5, 8 с равной вероятностью
T(2, [1 7 12]) = 1/3;  % Из узла 2 переходы в 1, 7, 12
T(3, [2 9 14]) = 1/3;  % Из узла 3 переходы в 2, 9, 14
T(4, [3 10 15]) = 1/3; % Из узла 4 переходы в 3, 10, 15
T(5, [1 6 11]) = 1/3;  % Из узла 5 переходы в 1, 6, 11
T(6, [5 12 2]) = 1/3;  % Из узла 6 переходы в 5, 12, 2
T(7, [2 8 13]) = 1/3;  % Из узла 7 переходы в 2, 8, 13
T(8, [1 7 9]) = 1/3;   % Из узла 8 переходы в 1, 7, 9
T(9, [3 8 10]) = 1/3;  % Из узла 9 переходы в 3, 8, 10
T(10, [4 9 11]) = 1/3; % Из узла 10 переходы в 4, 9, 11
T(11, [5 10 12]) = 1/3;% Из узла 11 переходы в 5, 10, 12
T(12, [2 6 13]) = 1/3; % Из узла 12 переходы в 2, 6, 13
T(13, [7 12 14]) = 1/3;% Из узла 13 переходы в 7, 12, 14
T(14, [3 13 15]) = 1/3;% Из узла 14 переходы в 3, 13, 15
T(15, [4 11 1]) = 1/3; % Из узла 15 переходы в 4, 11, 1

N = 100;   % Длина траектории
s = 1;      % Начальное состояние
epsilon = 1e-6; % Точность

trajectory = MarkovTrajectory(T, N, s);

figure;
plot(0:N, trajectory);
xlabel('Шаг времени');
ylabel('Номер узла');
title('Траектория движения пакета');

L = size(T, 1);
P_stay = zeros(L, L);
P_first = zeros(L, L);
M_shortest = zeros(L, L);
M_expected = zeros(L, L);
D = zeros(L, L);

for i = 1:L
  for j = 1:L
    m = 1;
    P_first(i, j) = T(i, j);
    while P_first(i, j) < epsilon && m < 1000
      m = m + 1;
      temp = 1;
      for q = 1:m-1
        temp = temp * (1 - T(i, j));
      end
      P_first(i, j) = T(i, j) * temp;
    end
    M_shortest(i, j) = m;
    
    m = 1;
    P_stay(i, j, m) = T(i, j);
    M_expected(i, j) = m * P_first(i, j);
    D(i, j) = m^2 * P_first(i, j) - M_expected(i, j)^2;
    while m < 1000
      m = m + 1;
      temp = T^m;
      P_stay(i, j, m) = temp(i, j);
      M_expected(i, j) = M_expected(i, j) + m * P_first(i, j);
      D(i, j) = D(i, j) + m^2 * P_first(i, j) - M_expected(i, j)^2;
    end
  end
end

% Вероятности пребывания пакета в узлах
figure;
hold on;
for i = 1:L
  plot(1:L, P_stay(i, :, 10), '-o');
end
xlabel('Номер узла');
ylabel('Вероятность пребывания');
title('Вероятности пребывания пакета в узлах');
legend(cellstr(num2str((1:L)', 'Узел %d')), 'Location', 'eastoutside');

% Вероятности первого перехода
figure;
hold on;
for i = 1:L
  plot(1:L, P_first(i, :), '-o');
end
xlabel('Номер узла');
ylabel('Вероятность первого перехода');
title('Вероятности первого перехода пакета');
legend(cellstr(num2str((1:L)', 'Из узла %d')), 'Location', 'eastoutside');

% Длины кратчайших путей
figure;
imagesc(M_shortest);
colorbar;
xlabel('Номер узла');
ylabel('Номер узла');
title('Длины кратчайших путей');

% Математические ожидания длин путей
figure;
imagesc(M_expected);
colorbar;
xlabel('Номер узла');
ylabel('Номер узла');
title('Математические ожидания длин путей');

figure;
imagesc(D);
colorbar;
xlabel('Номер узла');
ylabel('Номер узла');
title('Дисперсии длин путей');

hold off;

% Расчет траектории движения пакета
function E = MarkovTrajectory(P, N, s)
  E = zeros(1, N+1);
  E(1) = s;
  S = size(P, 1) - 1;
  
  for i = 0:S
    for j = 1:S
      P(i+1, j+1) = P(i+1, j+1) + P(i+1, j);
    end
  end
  
  for i = 2:N+1
    r = rand();
    E(i) = S+1; 
    for j = 1:S
      if r < P(E(i-1), j)
        E(i) = j;
        break;
      end
    end
  end
end