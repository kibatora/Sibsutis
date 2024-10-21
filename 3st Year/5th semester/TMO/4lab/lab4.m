f = @(x) (exp(-cos(x))) ./ x;

x = linspace(0.1, 10, 100); % Определяем диапазон значений x

% График f(x)
subplot(3,1,1); 
plot(x, f(x));
title('f(x) = (e^{-cos(x)}) / x');

% График производной f'(x)
df = @(x) (exp(-cos(x)).*(sin(x).*x + 1))./(x.^2); % Вычисляем производную
subplot(3,1,2);
plot(x, df(x));
title('Производная f''(x)');

% График интеграла f(x)
integral_f = zeros(size(x)); % Создаем вектор для хранения результатов
for i = 1:length(x)
    integral_f(i) = integral(f, 0, x(i)); % Вычисляем интеграл для каждого x(i)
end
subplot(3,1,3);
plot(x, integral_f);
title('Интеграл f(x)');

xlabel('x'); % Добавляем подпись оси x для всех графиков

% Определяем коэффициенты уравнения
a = 1;
b = 2;

% Определяем левую часть уравнения
g = @(x) a*x + b;

% Построение графиков
figure;
plot(x, f(x), 'b', 'DisplayName', 'f(x)');
hold on;
plot(x, g(x), 'r', 'DisplayName', 'a*x + b');
xlabel('x');
ylabel('y');
title('Графическое решение уравнения');
legend;

% Определяем функцию для поиска нуля
h = @(x) g(x) - f(x); 

% Находим численное решение
x_sol = fzero(h, 2.2); 

disp(['Численное решение: x = ', num2str(x_sol)]);

F = @(x,y) sin(exp(x)) + cos(exp(y));

% Создаем сетку значений x и y
[X,Y] = meshgrid(-2:0.1:2, -2:0.1:2);

% Вычисляем значения функции F(x,y)
Z = F(X, Y);

% Построение графика
figure;
surf(X, Y, Z);
xlabel('x');
ylabel('y');
zlabel('F(x,y)');
title('График функции F(x,y) = sin(e^x) + cos(e^y)');

% Добавляем подписи к осям и заголовок
xlabel('x');
ylabel('y');
zlabel('F(x,y)');
title('График функции F(x,y) = sin(e^x) + cos(e^y)');

% Изменяем цветовую схему
colormap('jet'); 

% Добавляем цветовую шкалу
colorbar;

