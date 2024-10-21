% --- Основной код скрипта ---
[result_matrix, mean_result, variance_result] = process_vectors(14, 21);

% Вывод результатов в консоль
disp('Результирующая матрица:');
disp(result_matrix);
disp(['Среднее значение: ', num2str(mean_result)]);
disp(['Дисперсия: ', num2str(variance_result)]);

% --- Определение функции ---
function [result, mean_val, variance_val] = process_vectors(I, J)
    vec_col = rand(I, 1);  % I элементов
    vec_row = rand(1, J);  % J элементов
    result = vec_col * vec_row;
    mean_val = mean(result(:)); 
    variance_val = var(result(:)); 
end
