% Параметры системы массового обслуживания
lambda = 2;      % Интенсивность входного потока
mu = 3;          % Интенсивность обслуживания
N = 10000;      % Размер выборки

% Проверка на стационарность
if lambda >= mu
    error('Система нестационарна (λ < μ).');
end

% --- Генерация выборок ---
[tau_exp, nu_exp, tau_logn, nu_logn] = generateDistributions(lambda, mu, N);

fprintf('--- Теоретические характеристики ---\n');
fprintf('Показательное распределение:\n');
fprintf('  Входной поток (tau): E = %.4f, D = %.4f\n', E_tau, D_tau);
fprintf('  Время обслуживания (nu): E = %.4f, D = %.4f\n\n', E_nu, D_nu);

% --- Моделирование СМО ---
models = {
    {tau_exp, nu_exp, 'M/M/1'}
    {tau_exp, nu_logn, 'M/G/1'}
    {tau_logn, nu_exp, 'G/M/1'}
    {tau_logn, nu_logn, 'G/G/1'}
};

for i = 1:length(models)
    [tau, nu, name] = models{i}{:};
    [arrivals, departures, queue_length, queue_dist, ro, L, Wq, W] = simulate_queue(tau, nu);
    
    % --- Вывод результатов ---
    fprintf('\n--- %s ---\n', name);
    printStats(arrivals, departures, queue_length, queue_dist, ro, L, Wq, W);
    plotResults(arrivals, departures, queue_length, queue_dist, name);
end



% --- Функции для генерации распределений ---
function [tau_exp, nu_exp, tau_logn, nu_logn] = generateDistributions(lambda, mu, N)
    % Показательное распределение
    E_tau = 1 / lambda;
    E_nu = 1 / mu;
    tau_exp = exprnd(E_tau, 1, N);
    nu_exp = exprnd(E_nu, 1, N);

    % Логнормальное распределение (параметры подобраны по показательному)
    D_tau = 1 / lambda^2;
    D_nu = 1 / mu^2;
    mu_log_tau = log(E_tau^2 / sqrt(D_tau + E_tau^2));
    sigma_log_tau = sqrt(log(D_tau / E_tau^2 + 1));
    mu_log_nu = log(E_nu^2 / sqrt(D_nu + E_nu^2));
    sigma_log_nu = sqrt(log(D_nu / E_nu^2 + 1));

    tau_logn = lognrnd(mu_log_tau, sigma_log_tau, 1, N);
    nu_logn = lognrnd(mu_log_nu, sigma_log_nu, 1, N);
end



function [arrivals, departures, queue_length, queue_dist, ro, L, Wq, W] = ...
    simulate_queue(tau, nu)
    
    N = length(tau);
    arrivals = cumsum(tau);            % Моменты поступления заявок
    departures = zeros(1, N);          % Моменты ухода заявок
    queue_length = zeros(1, N);       % Длина очереди
    
    departures(1) = arrivals(1) + nu(1);
    
    for i = 2:N
        if arrivals(i) < departures(i-1)
            queue_length(i) = queue_length(i-1) + 1; 
        else
            queue_length(i) = max(0, queue_length(i-1) - 1);
        end
        departures(i) = max(arrivals(i), departures(i-1)) + nu(i);
    end
    
    queue_dist = hist(queue_length, 0:max(queue_length)); 
    
    ro = sum(nu) / departures(end);              % Коэффициент загрузки
    L = sum(queue_length) / N;                   % Среднее число заявок в СМО
    Wq = sum(queue_length .* tau) / sum(tau);   % Среднее время пребывания в очереди
    W = sum((departures - arrivals)) / N;          % Среднее время пребывания в СМО
end

% --- Функция для вывода результатов ---
function printStats(arrivals, departures, queue_length, queue_dist, ro, L, Wq, W)
     fprintf('ρ = %.4f, L = %.4f, Wq = %.4f, W = %.4f\n', ro, L, Wq, W);
end

% --- Функция для построения графиков ---
function plotResults(arrivals, departures, queue_length, queue_dist, name)
    figure;
    subplot(2,2,1);
    plot(arrivals, 1:length(arrivals), 'b-', departures, 1:length(departures), 'r-');
    xlabel('Время');  ylabel('Число заявок');  title([name ': Поступление/Уход']); legend('Поступление', 'Уход');

    subplot(2,2,2); plot(queue_length);
    xlabel('Время'); ylabel('Длина очереди'); title([name ': Длина очереди']);

    subplot(2,2,3); bar(0:length(queue_dist)-1, queue_dist);
    xlabel('Длина очереди'); ylabel('Частота'); title([name ': Распределение длины']);
end