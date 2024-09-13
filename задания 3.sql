--1
/*Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
•	Пронумеруйте все платежи от 1 до N по дате
•	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
•	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
•	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.
*/
select p.payment_id, p.customer_id, p.amount, p.payment_date,
row_number () over (order by p.payment_date) as num_date,
row_number () over (partition by p.customer_id order by p.payment_date) as num_customer,
sum(amount) over (partition by p.customer_id order by payment_date, amount) as upper_sum,
rank() over (partition by customer_id order by amount) as num_amount_rank
from payment p 

--2
/*С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа
из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.*/
select p.payment_id, p.customer_id, p.amount,
lag (amount,1,0) over (partition by customer_id order by payment_date) as amoun_before 
from payment p 

--3
/*С помощью оконной функции определите, 
на сколько каждый следующий платеж покупателя больше или меньше текущего.*/
select p.payment_id, p.customer_id, p.amount,
(p.amount - lead (amount,1,0) over (partition by customer_id order by payment_date)) as diff
from payment p 

--4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
select customer_id,
last_value (payment_id) over (partition by customer_id order by payment_date rows between unbounded preceding and unbounded following),
last_value (amount) over (partition by customer_id order by payment_date rows between unbounded preceding and unbounded following),
last_value (payment_date) over (partition by customer_id order by payment_date rows between unbounded preceding and unbounded following)
from payment p 

--5
/*С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
с сортировкой по дате.*/
select s.staff_id,
date(p.payment_date),
sum(p.amount) over (partition by s.staff_id order by date(p.payment_date))
from staff s 
join payment p on p.staff_id = s.staff_id 
where p.payment_date between '2005-08-01' and '2005-8-31'

--6
/*20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал 
дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, 
которые в день проведения акции получили скидку.*/
with subq as (select customer_id, 
	lead(payment_id,100) over (partition by customer_id order by payment_id) as payment_num
	from payment p 
	where date(payment_date) = '2005-08-20')
select customer_id, payment_num
from subq
where payment_num % 100 = 0

--7
/*Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
•	покупатель, арендовавший наибольшее количество фильмов;
•	покупатель, арендовавший фильмов на самую большую сумму;
•	покупатель, который последним арендовал фильм.*/
with stat as (
	select c.customer_id, c3.country,
	row_number () over (partition by c3.country order by count(r.rental_id) desc) as most_rent,
	row_number () over (partition by c3.country order by sum(p.amount) desc) as most_amount,
	row_number () over (partition by c3.country order by max(r.rental_date) desc) as last_date
	from customer c 
	join address a on c.address_id = a.address_id
	join city c2 on c2.city_id = a.city_id
	join country c3 on c2.country_id = c3.country_id
	join rental r on c.customer_id = r.customer_id
	join payment p on r.rental_id = p.rental_id
	group by c.customer_id, c3.country
)
select country,customer_id
from stat
where most_rent = 1 or most_amount = 1 or last_date = 1







