--1
--Выведите уникальные названия городов из таблицы городов
select distinct city from city c 

--2
/*Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.*/
select distinct city from city c 
where city like 'L%a' and city not like '% %'

--3
select * from payment p 
where payment_date between '2005-06-17' and '2005-06-19' and amount <= 1
order by payment_date

--4
--Выведите информацию о 10-ти последних платежах за прокат фильмов.
select * from payment p 
order by payment_date desc limit 10

--5
/*Выведите следующую информацию по покупателям:
•	Фамилия и имя (в одной колонке через пробел)
•	Электронная почта
•	Длину значения поля email
•	Дату последнего обновления записи о покупателе (без времени)

 Каждой колонке задайте наименование на русском языке.*/
select last_name ||' '|| first_name as "ФИО", email as "почта", 
length(email) as "длина адреса", date(last_update) as "дата последнего обновления" from customer c 

--6
/*Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE. 
Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.*/
select lower(first_name) as first_name_lower,
lower(last_name) as last_name_lower from customer c
where active = 1 and first_name in ('KELLY', 'WILLIE')

--7
/*Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и 
стоимость аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и 
стоимостью аренды больше или равной 4.00.*/
select * from film f
where rating = 'PG-13' and (rental_rate between 0 and 3 or rental_rate >= 4)

--8
--Получите информацию о трёх фильмах с самым длинным описанием фильма.
select * from film f 
order by length(description) desc limit 3

--9
/*Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
•	в первой колонке должно быть значение, указанное до @,
•	во второй колонке должно быть значение, указанное после @.*/
select split_part(email, '@', 1) AS "1 part", split_part(email, '@', 2) AS "2 part" 
from customer c

--10
/*Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
первая буква должна быть заглавной, остальные строчными.*/
select upper(substring(split_part(email, '@', 1),1,1))||lower(substring(split_part(email, '@', 1),2)) AS "1 part",
upper(substring(split_part(email, '@', 2),1,1))||lower(substring(split_part(email, '@', 2),2)) AS "2 part" 
from customer c



