% Главный скрипт для запуска знакового кодирования и декодирования

% 1. Создание таблицы символов
[symbol_table, alphabet] = create_symbol_table();
disp(alphabet)

% 2. Задание сообщения
message = 'Hello_World_123-';  % Пример сообщения (пробелы заменены на "_", точка на "-")

% 3. Дополняем сообщение до нужной длины
message_len = length(message);
padding_len = mod(message_len, 6);

if (padding_len ~= 0)
  message = [message, repmat(alphabet(1), 1, 6 - padding_len)];
end

% 4. Кодирование сообщения
bit_stream = sign_encoder(message, alphabet, symbol_table);

% 5. Вывод закодированного сообщения (для отладки)
disp('Закодированное сообщение:'); 
disp(bit_stream); 

% 6. Проверка, что закодированное сообщение отличается от исходного
message_numeric = double(message); % Преобразуем символы в числа
if isequal(message_numeric, bit_stream)
    disp('Ошибка: Закодированное сообщение совпадает с исходным!');
    return; % Останавливаем выполнение, так как кодирование не работает
else
    disp('Закодированное сообщение успешно изменено.');
end

% 7. Декодирование сообщения
decoded_message = sign_decoder(bit_stream, alphabet, symbol_table);

% 8. Обрезаем сообщение до нужной длины
decoded_message = decoded_message(1:message_len);

% 9. Вывод декодированного сообщения
disp(['Декодированное сообщение: ' decoded_message]);

% 10. Проверка на ошибки
if strcmp(message(1:message_len), decoded_message)
  disp('Кодирование и декодирование прошли успешно.');
else
  disp('Ошибка: Декодированное сообщение не совпадает с исходным!');
end