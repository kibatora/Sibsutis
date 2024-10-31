% Входные данные
TxPowerUE = 24; % дБм
TxPowerBS = 46; % дБм
AntGainBS = 21; % дБи
PenetrationM = 15; % дБ
IM = 1; % дБ
NoiseFigureBS = 2.4; % дБ
NoiseFigureUE = 6; % дБ
SINR_UL = 4; % дБ
SINR_DL = 2; % дБ
BW_UL = 10e6; % Полоса частот UL в Гц
BW_DL = 20e6; % Полоса частот DL в Гц

% Расчет теплового шума для UL и DL
ThermalNoise_UL = -174 + 10 * log10(BW_UL);
ThermalNoise_DL = -174 + 10 * log10(BW_DL);

% Чувствительность приемников BS и UE
RxSensBS = NoiseFigureBS + ThermalNoise_UL + SINR_UL;
RxSensUE = NoiseFigureUE + ThermalNoise_DL + SINR_DL;

% Расчет MAPL для UL и DL
MAPL_UL = TxPowerUE + AntGainBS - RxSensBS - IM - PenetrationM;
MAPL_DL = TxPowerBS + AntGainBS - RxSensUE - IM - PenetrationM;

% Вывод результатов заданий 1 и 2
fprintf('Тепловой шум для UL: %.2f дБм\n', ThermalNoise_UL);
fprintf('Чувствительность приемника BS: %.2f дБм\n', RxSensBS);
fprintf('MAPL для восходящего канала: %.2f дБ\n', MAPL_UL);

fprintf('Тепловой шум для DL: %.2f дБм\n', ThermalNoise_DL);
fprintf('Чувствительность приемника UE: %.2f дБм\n', RxSensUE);
fprintf('MAPL для нисходящего канала: %.2f дБ\n', MAPL_DL);

% Исходные данные для задания 3
f = 1.8e9; % Частота в Гц
c = 3e8; % Скорость света в м/с
d = linspace(1, 10000, 1000); % Расстояние в метрах

% FSP
PL_FSP = 20 * log10((4 * pi * d * f) / c);

% 1. Модель UMiNLOS
f_GHz = f / 1e9; % Частота в ГГц
PL_UMiNLOS = 26 * log10(f_GHz) + 22.7 + 36.7 * log10(d);

% 2. Модель COST231 Hata (используем значения A и B для частоты 1800 МГц)
A = 46.3;
B = 33.9;
h_BS = 30; % Высота антенны BS, м
h_ms = 1.5; % Высота антенны UE, м
a_hms = (1.1 * log10(f) - 0.7) * h_ms - (1.56 * log10(f) - 0.8); % для городской местности
s = 44.9 - 6.55 * log10(f / 1e6); % для макросот
PL_COST231 = A + B * log10(f / 1e6) - 13.82 * log10(h_BS) - a_hms + s * log10(d / 1000);

% 3. Модель Walfish-Ikegami (для макросот)
h = 20; % Средняя высота зданий, м
w = 20; % Средняя ширина улиц, м
PL_LOS = 42.6 + 20 * log10(f / 1e6) + 26 * log10(d / 1000); % LOS (Прямая видимость)
PL_NLOS = 32.44 + 20 * log10(f / 1e6) + 20 * log10(d / 1000) + ...
          (-16.9 - 10 * log10(w) + 10 * log10(f / 1e6) + 20 * log10(h - h_ms)); % NLOS

% Модель FSP
PL_FSP = 20 * log10((4 * pi * d * f) / c); % Зависимость потерь от расстояния

% Построение графиков
figure;
plot(d, PL_FSP, '--k', 'LineWidth', 2); hold on; % Линия для FSP
plot(d, PL_UMiNLOS, 'g', 'LineWidth', 2); % UMiNLOS
plot(d, PL_COST231, 'b', 'LineWidth', 2); % COST231 Hata
plot(d, PL_LOS, 'r', 'LineWidth', 2); % Walfish-Ikegami (LOS)
plot(d, PL_NLOS, 'm', 'LineWidth', 2); % Walfish-Ikegami (NLOS)

% Добавление линий MAPL_UL и MAPL_DL
yline(MAPL_UL, '--r', 'MAPL UL', 'LineWidth', 2); % MAPL_UL
yline(MAPL_DL, '--b', 'MAPL DL', 'LineWidth', 2); % MAPL_DL

xlabel('Расстояние (м)');
ylabel('Потери сигнала (дБ)');
legend('FSP', 'UMiNLOS', 'COST231 Hata', 'Walfish-Ikegami LOS', 'Walfish-Ikegami NLOS', 'MAPL UL', 'MAPL DL');
title('Зависимость потерь сигнала от расстояния');
grid on;


% 4зд - Входные данные для покрытия
total_area = 100; % Площадь территории в кв. км
business_area = 4; % Площадь торговых и бизнес центров, кв. км
sectors_per_BS = 3; % Число секторов на одной базовой станции

% 1. Найти радиусы для каждой модели

% Для модели UMiNLOS
radius_UL_UMiNLOS = interp1(PL_UMiNLOS, d, MAPL_UL); % Радиус для восходящего канала
radius_DL_UMiNLOS = interp1(PL_UMiNLOS, d, MAPL_DL); % Радиус для нисходящего канала
radius_UMiNLOS = min(radius_UL_UMiNLOS, radius_DL_UMiNLOS); % Меньший радиус

% Для модели Walfish-Ikegami (LOS)
radius_UL_WI_LOS = interp1(PL_LOS, d, MAPL_UL); % Радиус для восходящего канала
radius_DL_WI_LOS = interp1(PL_LOS, d, MAPL_DL); % Радиус для нисходящего канала
radius_WI_LOS = min(radius_UL_WI_LOS, radius_DL_WI_LOS); % Меньший радиус

% Для модели Walfish-Ikegami (NLOS)
radius_UL_WI_NLOS = interp1(PL_NLOS, d, MAPL_UL); % Радиус для восходящего канала
radius_DL_WI_NLOS = interp1(PL_NLOS, d, MAPL_DL); % Радиус для нисходящего канала
radius_WI_NLOS = min(radius_UL_WI_NLOS, radius_DL_WI_NLOS); % Меньший радиус

% Для модели COST231 Hata
radius_UL_COST231 = interp1(PL_COST231, d, MAPL_UL); % Радиус для восходящего канала
radius_DL_COST231 = interp1(PL_COST231, d, MAPL_DL); % Радиус для нисходящего канала
radius_COST231 = min(radius_UL_COST231, radius_DL_COST231); % Меньший радиус

% 2. Рассчитываем площадь одной базовой станции для каждой модели
sector_area_UMiNLOS = 1.95 * (radius_UMiNLOS / 1000)^2; % Площадь для UMiNLOS
sector_area_WI_LOS = 1.95 * (radius_WI_LOS / 1000)^2; % Площадь для Walfish-Ikegami LOS
sector_area_WI_NLOS = 1.95 * (radius_WI_NLOS / 1000)^2; % Площадь для Walfish-Ikegami NLOS
sector_area_COST231 = 1.95 * (radius_COST231 / 1000)^2; % Площадь для COST231 Hata

% 3. Рассчитываем количество базовых станций для общей площади
num_BS_UMiNLOS = total_area / sector_area_UMiNLOS;
num_BS_WI_LOS = total_area / sector_area_WI_LOS;
num_BS_WI_NLOS = total_area / sector_area_WI_NLOS;
num_BS_COST231 = total_area / sector_area_COST231;

% 4. Рассчитываем количество микро- и фемтосот для торговых и бизнес центров (UMiNLOS)
num_micro_femto_BS = business_area / sector_area_UMiNLOS;

% Вывод результатов
fprintf('Модель UMiNLOS:\n');
fprintf('Радиус для UL: %.2f м, DL: %.2f м, Используемый радиус: %.2f м\n', radius_UL_UMiNLOS, radius_DL_UMiNLOS, radius_UMiNLOS);
fprintf('Площадь покрытия одной базовой станции: %.2f кв. км\n', sector_area_UMiNLOS);
fprintf('Количество базовых станций: %.2f\n\n', num_BS_UMiNLOS);

fprintf('Модель Walfish-Ikegami (LOS):\n');
fprintf('Радиус для UL: %.2f м, DL: %.2f м, Используемый радиус: %.2f м\n', radius_UL_WI_LOS, radius_DL_WI_LOS, radius_WI_LOS);
fprintf('Площадь покрытия одной базовой станции: %.2f кв. км\n', sector_area_WI_LOS);
fprintf('Количество базовых станций: %.2f\n\n', num_BS_WI_LOS);

fprintf('Модель Walfish-Ikegami (NLOS):\n');
fprintf('Радиус для UL: %.2f м, DL: %.2f м, Используемый радиус: %.2f м\n', radius_UL_WI_NLOS, radius_DL_WI_NLOS, radius_WI_NLOS);
fprintf('Площадь покрытия одной базовой станции: %.2f кв. км\n', sector_area_WI_NLOS);
fprintf('Количество базовых станций: %.2f\n\n', num_BS_WI_NLOS);

fprintf('Модель COST231 Hata:\n');
fprintf('Радиус для UL: %.2f м, DL: %.2f м, Используемый радиус: %.2f м\n', radius_UL_COST231, radius_DL_COST231, radius_COST231);
fprintf('Площадь покрытия одной базовой станции: %.2f кв. км\n', sector_area_COST231);
fprintf('Количество базовых станций: %.2f\n\n', num_BS_COST231);

fprintf('Для торговых и бизнес центров (UMiNLOS):\n');
fprintf('Площадь покрытия одной микро- или фемтосоты: %.2f кв. км\n', sector_area_UMiNLOS);
fprintf('Количество микро- и фемтосот: %.2f\n', num_micro_femto_BS);

% Дополнительное задание: расчет радиуса соты для модели COST231 Hata при различных температурах
% Температуры в градусах Цельсия
temps_C = [-40, 40];
% Перевод в Кельвины
temps_K = temps_C + 273.15;
k = 1.380649e-23; % Постоянная Больцмана

% Пересчет радиуса соты для каждого значения температуры
for i = 1:length(temps_K)
    % Вычисление уровня шума при заданной температуре
    Noise_Level = 10 * log10(k * temps_K(i) * 1000);
    
    % Пересчет теплового шума для UL и DL с учетом температуры
    ThermalNoise_UL_Temp = Noise_Level + 10 * log10(BW_UL);
    ThermalNoise_DL_Temp = Noise_Level + 10 * log10(BW_DL);
    
    % Чувствительность приемников BS и UE с учетом температуры
    RxSensBS_Temp = NoiseFigureBS + ThermalNoise_UL_Temp + SINR_UL;
    RxSensUE_Temp = NoiseFigureUE + ThermalNoise_DL_Temp + SINR_DL;
    
    % Расчет MAPL для UL и DL при данной температуре
    MAPL_UL_Temp = TxPowerUE + AntGainBS - RxSensBS_Temp - IM - PenetrationM;
    MAPL_DL_Temp = TxPowerBS + AntGainBS - RxSensUE_Temp - IM - PenetrationM;
    
    % Пересчет радиуса соты для модели COST231 Hata
    radius_UL_COST231_Temp = interp1(PL_COST231, d, MAPL_UL_Temp); % Радиус для UL
    radius_DL_COST231_Temp = interp1(PL_COST231, d, MAPL_DL_Temp); % Радиус для DL
    radius_COST231_Temp = min(radius_UL_COST231_Temp, radius_DL_COST231_Temp); % Меньший радиус

    % Вывод результатов
    fprintf('\nТемпература: %d°C\n', temps_C(i));
    fprintf('Радиус соты для UL: %.2f м, для DL: %.2f м, Используемый радиус: %.2f м\n', radius_UL_COST231_Temp, radius_DL_COST231_Temp, radius_COST231_Temp);
end

