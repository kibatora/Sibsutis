% Задание 1
P = [0 3 3 3; 3 0 2 1; 3 2 0 1; 3 2 1 0];

% Задание 2
MC = dtmc(P, 'StateNames', ["Healthy", "Unwell", "Sick", "Very sick"]);

% Задание 3
disp("Матрица переходов:")
disp(MC.P)

disp("Суммы строк матрицы переходов:")
disp(sum(MC.P, 2)) % Суммируем по строкам (второй аргумент = 2)

% Задание 4
G = digraph(MC.P, MC.StateNames); % Создаем ориентированный граф

% Определяем координаты вершин для графика
nodeCoordinates = [0, 1; 1, 1; 1, 0; 0, 0]; 

figure;
plot(G, 'XData', nodeCoordinates(:,1), 'YData', nodeCoordinates(:,2),...
    'NodeLabel', MC.StateNames); 

% Добавляем отображение вероятностей на ребрах
edgeWeights = G.Edges.Weight;
for i = 1:numedges(G)
    if edgeWeights(i) > 0
        % Получаем ИМЕНА начальной и конечной вершин ребра
        startNode = G.Edges.EndNodes(i, 1);
        endNode = G.Edges.EndNodes(i, 2);

        % Находим ИНДЕКСЫ этих вершин в списке имен состояний
        startIndex = find(strcmp(MC.StateNames, startNode));
        endIndex = find(strcmp(MC.StateNames, endNode));

        % Используем ИНДЕКСЫ для получения координат вершин
        midPoint = (nodeCoordinates(startIndex,:) + nodeCoordinates(endIndex,:)) / 2;

        text(midPoint(1), midPoint(2), sprintf('%.1f', edgeWeights(i)),...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
end
title('Граф цепи Маркова');

% Задание 5 
P_cum = zeros(size(MC.P)); % Инициализируем P_cum
numStates = size(MC.P, 1);

for i = 1:numStates
    for j = 1:numStates
        P_cum(i, j) = sum(MC.P(i, 1:j));
    end
end

% Задание 6 
numIterations = 200;
states = zeros(1, numIterations);
states(1) = 1;

for t = 2:numIterations
    r = rand();
    k = 1;
    while r > P_cum(states(t-1), k) && k < numStates
        k = k + 1;
    end
    states(t) = k;
end

% Вывод результатов
disp("Состояния цепи Маркова:");
disp(states)

% Задание 7
figure;
plot(states, 'o-');
xlabel('Номер наблюдения');
ylabel('Состояние');
title('Изменение состояния цепи Маркова (200 наблюдений)');
ylim([0 numStates+1]); % Установка пределов оси Y для лучшей визуализации

% Задание 8
iterations = [1000, 10000];

for i = 1:length(iterations)
    numIterations = iterations(i);
    states = zeros(1, numIterations);
    states(1) = 1;

    for t = 2:numIterations
        r = rand();
        k = 1;
        % Используем P_cum для определения следующего состояния
        while r > P_cum(states(t-1), k) && k < numStates 
            k = k + 1;
        end
        states(t) = k;
    end

    % Вывод результатов
    figure;
    plot(states, 'o-');
    xlabel('Номер наблюдения');
    ylabel('Состояние');
    title(['Изменение состояния цепи Маркова (', num2str(numIterations), ' наблюдений)']);
    ylim([0 numStates+1]); 
end

% Задание 9
for numIterations = [200, 1000, 10000]

    % Выполняем симуляцию цепи Маркова (код из задания 8)
    states = zeros(1, numIterations);
    states(1) = 1;
    for t = 2:numIterations
        r = rand();
        k = 1;
        while r > P_cum(states(t-1), k) && k < numStates
            k = k + 1;
        end
        states(t) = k;
    end

    % --- Оценка цепи Маркова ---
    P_obs = zeros(numStates, numStates);  % Инициализируем матрицу переходов

    % Считаем количество переходов из i в j
    for i = 1:numStates
        for j = 1:numStates
            P_obs(i,j) = sum((states(1:end-1) == i) & (states(2:end) == j));
        end
    end
    
    % Нормализуем матрицу P_obs
    P_obs = P_obs ./ sum(P_obs, 2);

    % --- Вывод результатов ---

    % Задание 3 (для оцененной матрицы)
    disp(['Матрица переходов (', num2str(numIterations), ' итераций):'])
    disp(P_obs)
    disp('Суммы строк:')
    disp(sum(P_obs, 2))

     % Задание 4 (для оцененной матрицы)
    G = digraph(P_obs, MC.StateNames);

    % Определяем координаты вершин для графика
    nodeCoordinates = [0, 1; 1, 1; 1, 0; 0, 0]; 

    figure;
    plot(G, 'XData', nodeCoordinates(:,1), 'YData', nodeCoordinates(:,2),...
        'NodeLabel', MC.StateNames); 

    % Добавляем отображение вероятностей на ребрах
    edgeWeights = G.Edges.Weight;
    for i = 1:numedges(G)
        if edgeWeights(i) > 0
            % Получаем ИМЕНА начальной и конечной вершин ребра
            startNode = G.Edges.EndNodes(i, 1);
            endNode = G.Edges.EndNodes(i, 2);

            % Находим ИНДЕКСЫ этих вершин в списке имен состояний
            startIndex = find(strcmp(MC.StateNames, startNode));
            endIndex = find(strcmp(MC.StateNames, endNode));

            % Используем ИНДЕКСЫ для получения координат вершин
            midPoint = (nodeCoordinates(startIndex,:) + nodeCoordinates(endIndex,:)) / 2;

            % --- Улучшение отображения подписей ---
            % 1. Сдвигаем подписи и добавляем больший случайный сдвиг
            offset = 0.15;  % Увеличиваем смещение от центра
            randOffset = (rand(1,2) - 0.5) * 0.1; % Увеличиваем случайный сдвиг
            midPoint = midPoint + offset * (midPoint - mean(nodeCoordinates)) + randOffset; 

            % 2. Округляем вероятность до одного знака после запятой
            label = sprintf('%.1f', edgeWeights(i));

            % Отображаем текст 
            text(midPoint(1), midPoint(2), label,...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom'); 
        end
    end
    title(['Граф цепи Маркова (', num2str(numIterations), ' наблюдений)']);
    axis equal; % Делаем оси равными для сохранения пропорций графа
end

% --- Задание 11 ---

% Берем оцененную матрицу переходов для 200 наблюдений
P_obs_200 = P_obs;  % Предполагаем, что P_obs сохранена из задания 9 

% --- Повторяем пункт 6 (симуляция) ---
numIterations = 200; 
states = zeros(1, numIterations);
states(1) = 1;

% !!! Используем P_obs_200 для симуляции !!!
P_cum_200 = cumsum(P_obs_200, 2); 
for t = 2:numIterations
    r = rand();
    k = 1;
    while r > P_cum_200(states(t-1), k) && k < numStates
        k = k + 1;
    end
    states(t) = k;
end

% --- Повторяем пункт 7 (построение графика) ---
figure;
plot(states, 'o-');
xlabel('Номер наблюдения');
ylabel('Состояние');
title('Изменение состояния цепи Маркова (200 наблюдений, P\_obs\_200)');
ylim([0 numStates+1]);