--1 
--Выведите для каждого покупателя его адрес, город и страну проживания.
select c.first_name, c.last_name, c2.city, c3.country from customer c 
join address a on c.address_id = a.address_id
join city c2 on c2.city_id = a.city_id 
join country c3 on c2.country_id = c3.country_id 

--2
/*С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
•	Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. 
Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. 
•	Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, 
который работает в нём. 
*/
select s.store_id, count(c.customer_id), city.city, s2.first_name, s2.last_name
from store s
join customer c ON s.store_id = c.store_id
join address a ON s.address_id = a.address_id
join city ON a.city_id = city.city_id
join staff s2 ON s.manager_staff_id = s2.staff_id
group by s.store_id, city.city, s2.first_name, s2.last_name
having count(c.customer_id) > 300;

--3
--Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.
select c.first_name, c.last_name, count(p.payment_id) 
from customer c 
join payment p on c.customer_id = p.customer_id 
group by c.first_name, c.last_name 
order by count(p.payment_id) desc limit 5

--4
/*Посчитайте для каждого покупателя 4 аналитических показателя:
•	количество взятых в аренду фильмов;
•	общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
•	минимальное значение платежа за аренду фильма;
•	максимальное значение платежа за аренду фильма.*/
select c.first_name, c.last_name, count(p.payment_id), round(sum(p.amount)), min(p.amount), max(p.amount)
from customer c 
join payment p on c.customer_id = p.customer_id 
group by c.first_name, c.last_name 

--5
/*Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так, 
чтобы в результате не было пар с одинаковыми названиями городов. 
Для решения необходимо использовать декартово произведение.*/
select c.city, c2.city
from city c 
cross join city c2 
where c.city <> c2.city 
order by c.city, c2.city

--6
/*Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и 
дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, 
за которые он возвращает фильмы.*/
select c.first_name, c.last_name, extract(day from avg(r.return_date-r.rental_date))
from customer c 
join rental r on r.customer_id = c.customer_id 
group by c.first_name, c.last_name

--7
/*Посчитайте для каждого фильма, сколько раз его брали в аренду, 
а также общую стоимость аренды фильма за всё время.*/
select f.title, count(r.rental_id), sum(p.amount) 
from film f 
join inventory i on i.film_id = f.film_id 
join rental r on r.inventory_id = i.inventory_id 
join payment p on r.rental_id = p.rental_id 
group by f.title

--8
/*Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, 
которые ни разу не брали в аренду.*/
select f.title
from film f 
left join inventory i on i.film_id = f.film_id 
left join rental r on r.inventory_id = i.inventory_id 
where r.rental_id is null
group by f.title

--9
/*Посчитайте количество продаж, выполненных каждым продавцом. 
 * Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, 
 * то значение в колонке будет «Да», иначе должно быть значение «Нет».*/
select s.first_name, s.last_name, count(r.rental_id), 
case 
	when count(r.rental_id)>7300 then 'да'
	else 'нет' 
end as "премия"
from staff s 
join rental r on s.staff_id = r.staff_id
group by s.first_name, s.last_name 


