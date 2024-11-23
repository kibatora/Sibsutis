% Параметры системы массового обслуживания
lambda = 2;      % Интенсивность входного потока
mu = 3;          % Интенсивность обслуживания
N = 10000;      % Размер выборки

% Проверка на стационарность
if lambda >= mu
    error('Система нестационарна (λ < μ).');
end

% --- Теоретические характеристики (показательное распределение) ---
E_tau = 1 / lambda;   % Мат. ожидание времени между поступлениями
D_tau = 1 / lambda^2; % Дисперсия времени между поступлениями
E_nu = 1 / mu;       % Мат. ожидание времени обслуживания
D_nu = 1 / mu^2;      % Дисперсия времени обслуживания

% Вывод теоретических характеристик
fprintf('--- Теоретические характеристики ---\n');
fprintf('Показательное распределение:\n');
fprintf('  Входной поток (tau): E = %.4f, D = %.4f\n', E_tau, D_tau);
fprintf('  Время обслуживания (nu): E = %.4f, D = %.4f\n\n', E_nu, D_nu);


% --- Параметры логнормального распределения ---
mu_log_tau = log(E_tau^2 / sqrt(D_tau + E_tau^2));
sigma_log_tau = sqrt(log(D_tau / E_tau^2 + 1));
mu_log_nu = log(E_nu^2 / sqrt(D_nu + E_nu^2));
sigma_log_nu = sqrt(log(D_nu / E_nu^2 + 1));


% --- Генерация выборок ---
tau_exp = exprnd(E_tau, 1, N);    % Показательное распределение (tau)
nu_exp = exprnd(E_nu, 1, N);      % Показательное распределение (nu)
tau_logn = lognrnd(mu_log_tau, sigma_log_tau, 1, N); % Логнормальное (tau)
nu_logn = lognrnd(mu_log_nu, sigma_log_nu, 1, N);   % Логнормальное (nu)


% --- Статистические характеристики выборок ---
% Вместо анонимной функции используем отдельные вызовы mean и var
M_tau_exp = mean(tau_exp);
D_tau_exp = var(tau_exp);
M_nu_exp = mean(nu_exp);
D_nu_exp = var(nu_exp);
M_tau_logn = mean(tau_logn);
D_tau_logn = var(tau_logn);
M_nu_logn = mean(nu_logn);
D_nu_logn = var(nu_logn);


% --- Вывод статистических характеристик ---
fprintf('--- Статистические характеристики выборок ---\n');
printStats('Показательное (tau)', M_tau_exp, D_tau_exp, E_tau, D_tau);
printStats('Показательное (nu)', M_nu_exp, D_nu_exp, E_nu, D_nu);
printStats('Логнормальное (tau)', M_tau_logn, D_tau_logn, E_tau, D_tau); % Сравнение с показательным!
printStats('Логнормальное (nu)', M_nu_logn, D_nu_logn, E_nu, D_nu);   % Сравнение с показательным!

% --- Построение графиков (для визуального сравнения) ---
figure;

subplot(2,2,1); histogram(tau_exp); title('tau (Показательное)');
subplot(2,2,2); histogram(nu_exp);  title('nu (Показательное)');
subplot(2,2,3); histogram(tau_logn); title('tau (Логнормальное)');
subplot(2,2,4); histogram(nu_logn);  title('nu (Логнормальное)');

% --- Вспомогательная функция для вывода статистики ---
function printStats(name, M, D, E_theory, D_theory)
    fprintf('%s:\n', name);
    fprintf('  Статистическое: E = %.4f, D = %.4f\n', M, D);
    fprintf('  Теоретическое: E = %.4f, D = %.4f\n\n', E_theory, D_theory);
end