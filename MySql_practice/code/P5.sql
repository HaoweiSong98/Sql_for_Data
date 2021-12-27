USE sakila;
-- ex1
-- TIMESTAMPDIFF(DAY,DATE(rental_date),DATE(return_date))
SELECT rental_date,
		title,
        return_date,
        CASE WHEN TIMESTAMPDIFF(DAY,DATE(rental_date),DATE(return_date)) <= rental_duration THEN 'Ontime'
			WHEN TIMESTAMPDIFF(DAY,DATE(rental_date),DATE(return_date)) > rental_duration THEN 'Late'
            WHEN return_date IS NULL THEN 'Never'
            END AS 'LateOrNot'
FROM rental
JOIN (SELECT inventory_id, title, rental_duration 
FROM ((SELECT * FROM inventory JOIN (SELECT film_id, rental_duration, title FROM film) as f1 USING(film_id))) as f2) as f3 USING(inventory_id)
where customer_id = 236;

-- ex2
SELECT inventory.store_id,customer_id,first_name,last_name,
RANK() OVER (PARTITION BY inventory.store_id ORDER BY count(return_date) DESC) AS rent_rank
from rental
LEFT JOIN inventory USING(inventory_id)
LEFT JOIN customer USING(customer_id)
GROUP BY inventory.store_id,store_id, customer_id,first_name,last_name
HAVING count(return_date) >= 15;

-- ex3
SELECT film_text.title, rating,
		CASE WHEN Avaliable = 'Avaliable' THEN 'Yes'
        ELSE 'NO'
        END AS Avaliable
FROM sakila.film
LEFT JOIN film_category USING(film_id)
LEFT JOIN film_text USING(film_id)
LEFT JOIN inventory USING(film_id)
LEFT JOIN (SELECT inventory_id, 'Avaliable' FROM sakila.rental WHERE rental_date > 2005-08-20 or 2005-08-20 > return_date group by inventory_id) as j1 USING(inventory_id)
where category_id = 11 and store_id = 1
group by title, rating, Avaliable;

-- ex4
SELECT film.title,
	store_id,
	RANK() OVER (PARTITION BY film_id ORDER BY inventory_id DESC) AS copy_num,
    case WHEN rent0801 = 'rent0801' THEN email
    else 'Not rented'
    end as 'email address'
FROM film 
LEFT JOIN (SELECT film_id, title FROM film_text) as filmt USING(film_id)
LEFT JOIN (SELECT film_id, inventory_id, store_id FROM inventory) as inven USING(film_id)
LEFT JOIN (SELECT inventory_id, 'rent0801',customer_id from rental where date(rental_date) <= '2005-08-01' and '2005-08-01' <= date(return_date)) as rt08 USING(inventory_id)
LEFT JOIN (SELECT customer_id, email FROM customer) as cusemil USING(customer_id)
WHERE film_id in (SELECT film_id FROM sakila.film_category WHERE category_id = 12);

-- ex5
DROP VIEW IF EXISTS v_rent;
CREATE VIEW v_rent AS
SELECT rental_date AS trans_date,
	'Rental' AS trans_desc,
	rental_id,
	title,
	rental_rate as amt
FROM rental
LEFT JOIN inventory using (inventory_id)
LEFT JOIN film using (film_id)
WHERE customer_id = 318
UNION ALL
SELECT
	rental_date as trans_date,
	'Payment' as trans_desc,
	rental_id,
	title,
	amount as amt
FROM rental
LEFT JOIN inventory USING (inventory_id)
LEFT JOIN film USING (film_id)
LEFT JOIN payment USING(rental_id)
WHERE rental.customer_id = 318;

SELECT * FROM v_rent;



-- ex6
DROP VIEW IF EXISTS v_customer_ranks;
CREATE VIEW v_customer_ranks AS
SELECT customer_id,
	film_id, 
	count(film_id) as rent_times,
	RANK() OVER (PARTITION BY customer_id ORDER BY count(film_id) DESC) AS like_rank,
    title,
    email
FROM rental
LEFT JOIN (SELECT inventory_id,film_id FROM inventory) as inve USING(inventory_id)
LEFT JOIN (SELECT title, film_id FROM film_text) as filtitle USING (film_id)
LEFT JOIN (SELECT email, customer_id FROM customer) as cusem USING(customer_id)
GROUP BY customer_id, film_id
HAVING rent_times >= 2
;
SELECT email,title,rent_times FROM v_customer_ranks WHERE customer_id in (SELECT customer_id from v_customer_ranks group by customer_id having count(customer_id) > 1);


-- ex7

WITH RECURSIVE cte_semester AS
(
  SELECT course_id, course_desc, 1 AS semester
    FROM Course
    LEFT JOIN Prerequisite USING(course_id)
   WHERE prereq_course_id IS NULL
   UNION ALL
  SELECT E.course_id, E.course_desc, C.semester + 1 AS semester
    FROM cte_semester AS C
    JOIN (SELECT * FROM Course LEFT JOIN Prerequisite AS P1 USING(course_id)) AS E ON E.prereq_course_id = C.course_id
)
SELECT course_id, course_desc, max(semester) FROM cte_semester group by course_id, course_desc;

-- ex8
USE ClassicModels;
SELECT orderNumber,
		productCode,
        priceEach,
        CASE WHEN priceEach < MSRP THEN 'Yes'
        ELSE 'NO'
        END AS 'discount'
FROM ClassicModels.Orders
LEFT JOIN OrderDetails USING(orderNumber)
LEFT JOIN (SELECT productCode,MSRP FROM Products) as MS USING(productCode)
WHERE customerNumber = 131;

-- ex9
DROP VIEW IF EXISTS v_cus;
CREATE VIEW v_cus AS
SELECT 'Payment' AS trans_type,
	customerNumber,
	checkNumber AS trans_num,
	paymentDate AS trans_date,
	amount AS total
FROM payments
WHERE customerNumber IN (381,198)
UNION ALL
SELECT 'Order' AS trans_type,
	customerNumber,
	orderNumber AS trans_type,
	orderDate AS trans_date,
	sum(priceEach * quantityOrdered) AS total
FROM orders
LEFT JOIN orderdetails USING(orderNumber)
WHERE customerNumber IN (381,198)
GROUP BY orderNumber;
SELECT * FROM v_cus;

-- ex5
with pmt as (
select
r.rental_date as trans_date,
'Rental' as trans_desc,
r.rental_id,
f.title,
f.rental_rate as amt
from rental as r
left join inventory as i using (inventory_id)
left join film as f using (film_id)
where customer_id = 318
union all
select
r.rental_date as trans_date,
'Payment' as trans_desc,
r.rental_id,
f.title,
p.amount * -1 as amt
from rental as r
left join inventory as i using (inventory_id)
left join film as f using (film_id)
left join payment as p using(rental_id)
where r.customer_id = 318)
select
*,
sum(amt) over (partition by rental_id rows between unbounded preceding and current row) as balance
from pmt;

-- ex9
with pmt as(select 
'Payment' as trans_type,
customerNumber,
checkNumber as trans_num,
paymentDate as trans_date,
amount * -1 as total
from payments
where customerNumber in (381,198)
union all
select
'Order' as trans_type,
customerNumber,
orderNumber as trans_type,
orderDate as trans_date,
round(sum(d.quantityOrdered * d.priceEach),2) as total
from orders as o 
left join orderdetails as d using(orderNumber)
where o.customerNumber in (381,198)
group by orderNumber)
select 
*,
round(sum(total) over (order by trans_date, customerNumber rows between unbounded preceding and current row),2) as balance
from pmt;


SET SQL_SAFE_UPDATES = 0;

# your code SQL here

SET SQL_SAFE_UPDATES = 1;