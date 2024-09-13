--1
/*Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом 
(поле special_features) равным “Behind the Scenes”.*/
select * from film f 
where 'Behind the Scenes'= any(special_features) 

--2
/*Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, 
используя другие функции или операторы языка SQL для поиска значения в массиве.*/
select * from film f 
where 'Behind the Scenes' in (select unnest(special_features))

select * from film f 
where special_features @> array['Behind the Scenes']

--3
/*Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным 
атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, 
помещённый в CTE.*/
with behind as (
	select * from film f 
	where 'Behind the Scenes'= any(special_features) 
)
select c.customer_id, count(r.rental_id)
from customer c 
join rental r on c.customer_id = r.customer_id 
join inventory i on r.inventory_id = i.inventory_id 
join behind b on i.film_id  = b.film_id
group by c.customer_id 

--4
/*Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным 
атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, 
помещённый в подзапрос, который необходимо использовать для решения задания.*/
select c.customer_id, count(r.rental_id)
from customer c 
join rental r on c.customer_id = r.customer_id 
join inventory i on r.inventory_id = i.inventory_id 
join (select * from film f 
	where 'Behind the Scenes'= any(special_features)) b  on i.film_id  = b.film_id
group by c.customer_id 

--5
/*Создайте материализованное представление с запросом из предыдущего задания и 
напишите запрос для обновления материализованного представления.*/
create materialized view behind as
select c.customer_id, count(r.rental_id)
from customer c 
join rental r on c.customer_id = r.customer_id 
join inventory i on r.inventory_id = i.inventory_id 
join (select * from film f 
	where 'Behind the Scenes'= any(special_features)) b  on i.film_id  = b.film_id
group by c.customer_id 

--6
/*С помощью explain analyze проведите анализ скорости выполнения запросов из 
предыдущих заданий и ответьте на вопросы:
с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, 
поиск значения в массиве происходит быстрее;
какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса.*/
explain analyze
select * from film f 
where 'Behind the Scenes'= any(special_features) 
--Planning Time: 0.095 ms
--Execution Time: 0.209 ms
explain analyze
select * from film f 
where 'Behind the Scenes' in (select unnest(special_features))
--Planning Time: 0.104 ms
--Execution Time: 0.566 ms
explain analyze
select * from film f 
where special_features @> array['Behind the Scenes']
--Planning Time: 0.100 ms
--Execution Time: 0.345 ms
explain analyze
with behind as (
	select * from film f 
	where 'Behind the Scenes'= any(special_features) 
)
select c.customer_id, count(r.rental_id)
from customer c 
join rental r on c.customer_id = r.customer_id 
join inventory i on r.inventory_id = i.inventory_id 
join behind b on i.film_id  = b.film_id
group by c.customer_id */
--Planning Time: 0.355 ms
--Execution Time: 5.779 ms
explain analyze
select c.customer_id, count(r.rental_id)
from customer c 
join rental r on c.customer_id = r.customer_id 
join inventory i on r.inventory_id = i.inventory_id 
join (select * from film f 
	where 'Behind the Scenes'= any(special_features)) b  on i.film_id  = b.film_id
group by c.customer_id 
--Planning Time: 0.346 ms
--Execution Time: 5.739 ms

--7
--Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
with first_sell as (
	select s.staff_id, p.payment_id,
	row_number () over (partition by s.staff_id order by p.payment_date) as rn
	from staff s 
	join payment p on s.staff_id = p.staff_id
)
select staff_id, payment_id
from first_sell
where rn = 1

--8
/*Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
•	день, в который арендовали больше всего фильмов (в формате год-месяц-день);
•	количество фильмов, взятых в аренду в этот день;
•	день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
•	сумму продажи в этот день.*/
with rent_in_day as (
	select s.store_id, date(r.rental_date) as rent_date,count(r.rental_id) as count_rent
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id
	join store s on i.store_id = s.store_id
	group by s.store_id, rent_date
), sell_in_day as (
	select s.store_id, date(p.payment_date) as sell_date, sum(p.amount) as sum_amount
	from payment p 
	join rental r on p.rental_id = r.rental_id
	join inventory i on r.inventory_id = i.inventory_id
	join store s on i.store_id = s.store_id
	group by s.store_id, sell_date
)
select mrid.store_id, mrid.rent_date, mrid.count_rent, msd.sell_date, msd.sum_amount
from (select store_id, rent_date, count_rent,
row_number () over (partition by store_id order by count_rent desc) as max_rent_in_day
from rent_in_day) mrid
join (select store_id, sell_date, sum_amount,
row_number () over (partition by store_id order by sum_amount) as min_sum_day
from sell_in_day) msd
on mrid.store_id = msd.store_id and mrid.max_rent_in_day=1 and msd.min_sum_day=1

