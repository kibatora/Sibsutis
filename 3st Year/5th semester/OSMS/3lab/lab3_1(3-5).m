% Задание частот
f1 = 4; % частота s1
f2 = 8; % частота s2
f3 = 9; % частота s3

% Временной вектор
t = 0:0.01:1; % шаг 0.01 сек

% Определение сигналов s1, s2, s3
s1 = cos(2 * pi * f1 * t);
s2 = cos(2 * pi * f2 * t);
s3 = cos(2 * pi * f3 * t);

% Определение функций a(t) и b(t)
a = 3 * s1 + 3 * s2 + s3;
b = s1 + 0.5 * s2;

% Корреляция между s1 и a
corr_s1_a = sum(s1 .* a);
norm_corr_s1_a = sum(s1 .* a) / (sqrt(sum(s1.^2)) * sqrt(sum(a.^2)));

% Корреляция между s1 и b
corr_s1_b = sum(s1 .* b);
norm_corr_s1_b = sum(s1 .* b) / (sqrt(sum(s1.^2)) * sqrt(sum(b.^2)));

% Вывод результатов
disp(['Correlation between s1 and a: ', num2str(corr_s1_a)]);
disp(['Normalized Correlation between s1 and a: ', num2str(norm_corr_s1_a)]);
disp(['Correlation between s1 and b: ', num2str(corr_s1_b)]);
disp(['Normalized Correlation between s1 and b: ', num2str(norm_corr_s1_b)]);
