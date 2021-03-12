
# Подключаем xml-парсер и обработку дат
require 'rexml/document'
require 'date'

# Текущий каталог
current_path = File.dirname(__FILE__)
# Файл с данными
file_name = current_path + "/my_expenses.xml"
# Закрыть программу, если файл не найден
abort "File not found" unless File.exist?(file_name)
# Открыть файл с данными
file = File.new(file_name)

# Создаем объект класса REXML из содержимого файла
doc = REXML::Document.new(file)

=begin

	Основная идея:

	1) Создадим ассоциативный массив трат по принципу:
		дата => сумма всех трат, которые были сделаны в этот день
	
		1 мая => 100
		2 января => 200
		3 июня => 300

	2) Отсортируем массив по возростанию даты

=end

# Новый ассоциативный массив
amount_by_day = Hash.new

# Встроенынй метод "пробегания" по всем элементам дерева
# 1) doc = название объекта-дерева
# 2) elements пробегаем по его элементам
# 3) each в цикле
# 4) ("expenses/expense") = тег/подтег куда мы заходим (XPath формат адреса)
# 5) items = куда кладется значение тега
doc.elements.each('expenses/expense') do |item|
	# Сумма денег
	loss_sum = item.attributes["amount"].to_i
	# Дата, конвертированная из строки в дату
	loss_date = Date.parse(item.attributes["date"])
	# Достать значение данного дня из массива 
	# Если оно пустое, то 0; если не пустое, то ничего не делать
	amount_by_day[loss_date] ||= 0
	# Добавить в значение данного дня еще одну сумму (первую или очередную)
	amount_by_day[loss_date] += loss_sum
end

file.close

=begin

	Еще идея:

	1) создадим отдельный ассоциативнй массив
	2) в нему будем хранить даныне формата

		январь = 1000
		февраль = 2000
		...

=end

# Новый ассоциативный массив
sum_by_month = Hash.new
# Текущий месяц = первый месяц (январь) как 0-ой из отсортированных
current_month = amount_by_day.keys.sort[0].strftime("%B %Y")

# Пробегаем по массиву
amount_by_day.keys.sort.each do |key|
	# Инициализируем ячейку 0 (если пуста) или ее значением (если оно есть)
	sum_by_month[key.strftime("%B %Y")] ||= 0
	# Добавить в ячейку сумму за этот месяц
	sum_by_month[key.strftime("%B %Y")] += amount_by_day[key]
end

# Готова статистика по месяцам
# Готова статистика по дням

# Заголовок для статистики первого месяца
puts "------[ #{ current_month }, потрачено #{ sum_by_month[current_month] } рублей ]------"

# Пробегаем по массиву
amount_by_day.keys.sort.each do |key|
	if key.strftime("%B %Y") != current_month
		current_month = key.strftime("%B %Y")
		puts "------[ #{ current_month }, потрачено #{ sum_by_month[current_month] } рублей ]------"
	end
	puts "\t #{ key.day }: #{ amount_by_day[key] } рублей"
end
