% --- Параметры непрерывного распределения ---
a = 1; % Левая граница интервала
b = 10; % Правая граница интервала

% --- Параметры дискретного распределения ---
p = [0.05, 0.1, 0.2, 0.3, 0.2, 0.1, 0.05]; % Вероятности
k = 4:10;                                  % Значения случайной величины

% --- Проверка дискретного распределения ---
if length(p) ~= length(k) || sum(p) ~= 1
    error('Ошибка: Дискретное распределение задано некорректно!');
end

% --- Параметры для выборок и оценок ---
N_values = [50, 200, 1000];
alpha_values = [0.1, 0.05, 0.01];
header_point = {'N', 'Оценка среднего', 'Оценка дисперсии', 'Оценка СКО'};
header_interval = {'N', 'alpha', 'Интервал для среднего', 'Интервал для дисперсии'};

% --- Графики теоретических функций ---
figure; 

% --- Непрерывное распределение ---
subplot(1,2,1);
x_range = linspace(a, b, 100);
f_x = 1 ./ (x_range .* log(10));
plot(x_range, f_x, 'r', 'LineWidth', 2);
hold on; 
F_x = log10(x_range);
plot(x_range, F_x, 'b', 'LineWidth', 2);
xlabel('x');
ylabel('Значение функции');
title('Непрерывное распределение');
legend('Плотность', 'Функция распределения');

% --- Дискретное распределение ---
subplot(1,2,2);
stem(k, p, 'b', 'LineWidth', 2); 
hold on; 
F_x = cumsum(p);  
stairs(k, F_x, 'r', 'LineWidth', 2);
xlabel('x');
ylabel('Значение');
title('Дискретное распределение');
legend('Вероятности', 'Функция распределения');

% --- Теоретические мат. ожидание и дисперсия (дискретное) ---
expected_value_theoretical = sum(k .* p);  
variance_theoretical = sum((k - expected_value_theoretical).^2 .* p);

% --- Основной цикл ---
for i = 1:length(N_values)
    N = N_values(i);
    
    % --- Генерация выборок ---
    u = rand(N, 1);
    x_cont = 10.^(u);                     % Непрерывная выборка
    x_discr = randsample(k, N, true, p);    % Дискретная выборка

    % --- Вычисление и вывод оценок ---
    for distribution_type = 1:2 
        if distribution_type == 1
            x = x_cont;
            dist_name = 'непрерывного';
        else
            x = x_discr;
            dist_name = 'дискретного';
        end

        % --- Вычисление точечных оценок ---
        mean_estimate = mean(x);        
        var_estimate = var(x);          
        std_estimate = std(x);          

        % --- Вывод точечных оценок ---
        point_estimates = [N, mean_estimate, var_estimate, std_estimate];
        disp(' '); 
        disp(['Точечные оценки для N = ', num2str(N), ' (', dist_name, ' распр.)']);
        disp(header_point)
        disp(num2cell(point_estimates));

        % --- Вычисление и вывод интервальных оценок ---
        interval_estimates = cell(length(alpha_values), 4); 
        for j = 1:length(alpha_values)
            alpha = alpha_values(j);
            t_mean = tinv(1 - alpha/2, N-1); 
            mean_conf_int = mean_estimate + t_mean * std_estimate / sqrt(N) * [-1, 1];
            chi2_lower = chi2inv(alpha/2, N-1); 
            chi2_upper = chi2inv(1 - alpha/2, N-1);
            var_conf_int = [(N-1)*var_estimate/chi2_upper, (N-1)*var_estimate/chi2_lower];
            interval_estimates(j,:) = {N, alpha, sprintf('[%.4f, %.4f]', mean_conf_int(1), mean_conf_int(2)), ...
                                           sprintf('[%.4f, %.4f]', var_conf_int(1), var_conf_int(2))}; 
        end
        disp(' '); 
        disp(['Интервальные оценки для N = ', num2str(N), ' (', dist_name, ' распр.)']);
        disp(header_interval)
        disp(interval_estimates)
    end
    
    % --- Построение гистограмм ---
    figure;  
    
    % --- Непрерывная гистограмма ---
    subplot(1,2,1);
    k_cont = ceil(1 + 3.2 * log(N)); 
    histogram(x_cont, k_cont); 
    hold on;
    x_range = linspace(a, b, 100);
    f_x = 1 ./ (x_range .* log(10));
    plot(x_range, f_x * N * (b-a)/k_cont, 'r', 'LineWidth', 2); 
    xlabel('x');
    ylabel('Частота');
    title(['Непрерывная, N = ', num2str(N)]);
    legend('Гистограмма', 'Теоретическая плотность');

    % --- Дискретная гистограмма ---
    subplot(1,2,2);
    histogram(x_discr, 'Normalization', 'probability'); 
    hold on;
    bar(k, p, 'r', 'FaceAlpha', 0.5); 
    xlabel('x');
    ylabel('Вероятность');
    title(['Дискретная, N = ', num2str(N)]);
    legend('Гистограмма', 'Теоретическое распределение'); 
end

% --- 1. Теоретические мат. ожидание и дисперсия ---
disp('--- Теоретические моменты ---');

% --- Непрерывное распределение ---
E_theoretical_cont = (b-a)/(log(b)-log(a)); 
D_theoretical_cont = ((b^2-a^2)/(2*(log(b)-log(a))))-(E_theoretical_cont)^2;

fprintf('Непрерывное распределение:\n');
fprintf('  Теоретическое мат. ожидание: %.4f\n', E_theoretical_cont);
fprintf('  Теоретическая дисперсия: %.4f\n\n', D_theoretical_cont);

% --- Дискретное распределение ---
E_theoretical_discr = sum(k .* p);
D_theoretical_discr = sum(((k - E_theoretical_discr).^2) .* p); 

fprintf('Дискретное распределение:\n');
fprintf('  Теоретическое мат. ожидание: %.4f\n', E_theoretical_discr);
fprintf('  Теоретическая дисперсия: %.4f\n\n', D_theoretical_discr);

% --- 2. Асимметрия и эксцесс ---
disp('--- Асимметрия и эксцесс (для выборок) ---');
for i = 1:length(N_values)
    N = N_values(i);

    % --- Генерация выборок ---
    u = rand(N, 1);
    x_cont = 10.^(u);                     
    x_discr = randsample(k, N, true, p);   

    % --- Вычисление коэффициентов ---
    skewness_cont = skewness(x_cont);
    kurtosis_cont = kurtosis(x_cont);
    skewness_discr = skewness(x_discr);
    kurtosis_discr = kurtosis(x_discr);

    % --- Вывод результатов ---
    fprintf('N = %d:\n', N);
    fprintf('  Непрерывное распределение:\n');
    fprintf('    Асимметрия: %.4f\n', skewness_cont);
    fprintf('    Эксцесс: %.4f\n', kurtosis_cont);
    fprintf('  Дискретное распределение:\n');
    fprintf('    Асимметрия: %.4f\n', skewness_discr);
    fprintf('    Эксцесс: %.4f\n\n', kurtosis_discr);
end