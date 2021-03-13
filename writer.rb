
require 'rexml/document'
require 'date'

puts "На что тратим деньги?"
e_text = STDIN.gets.chomp

puts "Сколько было потрачено?"
e_amount = STDIN.gets.chomp.to_i

puts "Когда была трата (например, 12.05.2021)\nЕсли оставить поле пустым, то сегодня"
d_input = STDIN.gets.chomp

e_date = nil
if d_input == ''
	e_date = Date.today
else
	e_date = Date.parse(d_input)
end

puts "Какая была категория траты?"
e_category = STDIN.gets.chomp

=begin

	Получаем данных для записи:

	1) e_text 	  = что купили
	2) e_amount   = за сколько купили
	3) e_date 	  = когда купили
	4) e_category = категория траты

=end

current_path = File.dirname(__FILE__)
file_name = current_path + "/my_expenses.xml"
file = File.new(file_name, "r:UTF-8")

# doc = REXML::Document.new(file)

begin
  doc = REXML::Document.new(file)
rescue REXML::ParseException => e
	puts "XML-файл имеет битую структуру"
	abort e.message
end


file.close

# Вытащим корневой тег массива (вернется коллекция, нам надо первый элемент)
expenses = doc.elements.find('expenses').first
# Добавим в корневой тег новый элемент (expense) с атрибутами
expense = expenses.add_element 'expense', {
																	'amount' 		=> e_amount,
																	'category' 	=> e_category,
																	'date' 			=> e_date.to_s
}

expense.text = e_text

file = File.new(file_name, "w:UTF-8")
doc.write(file, 2) 														# записать с отступом в два пробела
file.close

puts "Success!"