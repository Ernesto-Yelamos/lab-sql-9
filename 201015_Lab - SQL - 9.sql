use sakila;

/*
1 customer_id -
2 city -
3 most rented film category
4 total films rented -
5 total money spent -
6 amount of films rented last month
7 rent or not?
7. time lapsed from last 2 rentals or mean of lapsed time between rentals, e.g.
*/

-- 1 customer_id
select customer_id from sakila.customer;

-- 2 city
select city from sakila.city;

-- Join 1 and 2
SELECT a.customer_id, c.city FROM sakila.customer AS a
JOIN sakila.address AS b ON a.address_id = b.address_id 
JOIN sakila.city AS c ON b.city_id = c.city_id
group by customer_id
ORDER BY customer_id DESC;

-- 3 most rented film category
SELECT customer as 'customer_id', category_name FROM
(SELECT rental.customer_id as customer, count(rental.rental_id) as total_rentals, film_category.category_id, category.name as category_name,
row_number() over (partition by rental.customer_id order by count(rental.rental_id) desc) as ranking_max_rented_category
FROM rental
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
INNER JOIN film_category ON inventory.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
GROUP BY rental.customer_id, film_category.category_id, category.name) AS table_popular_category
WHERE ranking_max_rented_category = 1
ORDER BY customer;

SELECT customer as 'customer_id', category_name FROM
(SELECT a.customer_id as customer, count(a.rental_id) as 'total rentals', c.category_id, d.name as 'category_name',
row_number() over (partition by a.customer_id order by count(a.rental_id) desc) as ranking_max_rented_category
FROM rental as a
INNER JOIN inventory as b ON a.inventory_id = b.inventory_id
INNER JOIN film_category as c ON b.film_id = c.film_id
INNER JOIN category as d ON c.category_id = d.category_id
GROUP BY a.customer_id, c.category_id, d.name) AS table_popular_category
WHERE ranking_max_rented_category = 1
ORDER BY customer;

-- 4 total films rented
/*
SELECT count(a.rental_id) AS 'Total films rented', a.customer_id, b.first_name, b.last_name FROM sakila.payment AS a
join sakila.customer AS b ON a.customer_id = b.customer_id
group by customer_id
order by customer_id;
*/
SELECT count(rental_id) AS 'Total films rented', customer_id FROM sakila.payment
group by customer_id;

-- Join 1, 2 and 4
SELECT a.customer_id, c.city, count(d.rental_id) AS 'Total films rented' FROM sakila.customer AS a
JOIN sakila.address AS b ON a.address_id = b.address_id 
JOIN sakila.city AS c ON b.city_id = c.city_id
JOIN sakila.payment AS d ON a.customer_id = d.customer_id
group by a.customer_id
ORDER BY a.customer_id DESC;

-- 5 total money spent
select sum(amount) AS 'Total money spent', customer_id from sakila.payment
group by customer_id
order by sum(amount) DESC; 

-- Join 1, 2, 4 and 5
SELECT a.customer_id, c.city, count(d.rental_id) AS 'Total films rented', sum(amount) AS 'Total money spent' FROM sakila.customer AS a
JOIN sakila.address AS b ON a.address_id = b.address_id 
JOIN sakila.city AS c ON b.city_id = c.city_id
JOIN sakila.payment AS d ON a.customer_id = d.customer_id
group by a.customer_id
ORDER BY a.customer_id DESC;

-- Join 1, 2, 4, 5 and rental_date (date conditions will be added with python)
SELECT a.customer_id, c.city as 'City', count(d.rental_id) AS 'Total films rented', sum(amount) AS 'Total money spent' FROM sakila.customer AS a
JOIN sakila.address AS b ON a.address_id = b.address_id 
JOIN sakila.city AS c ON b.city_id = c.city_id
JOIN sakila.payment AS d ON a.customer_id = d.customer_id
JOIN sakila.rental AS e ON d.rental_id = e.rental_id
group by a.customer_id
ORDER BY a.customer_id DESC;


-- 6 amount of films rented last month
select count(rental_date) from sakila.rental
where rental.rental_date >= 20050516 and rental.rental_date <= 20050530;

SELECT customer.customer_id, count(rental_id) as 'films_rented' from sakila.rental
RIGHT OUTER JOIN sakila.customer ON rental.customer_id = customer.customer_id 
where rental.rental_date >= 20050516 and rental.rental_date <= 20050530
GROUP BY customer_id
ORDER BY customer_id;


SELECT a.customer_id, c.city, count(d.rental_id) AS 'Total films rented', sum(amount) AS 'Total money spent', e.rental_date FROM sakila.customer AS a
JOIN sakila.address AS b ON a.address_id = b.address_id 
JOIN sakila.city AS c ON b.city_id = c.city_id
JOIN sakila.payment AS d ON a.customer_id = d.customer_id
JOIN sakila.rental AS e ON d.rental_id = e.rental_id
where e.rental_date >= 20050516 and e.rental_date <= 20050530
group by a.customer_id
ORDER BY a.customer_id;


-- 7 amount of films rented current month
select count(rental_date) from sakila.rental
where rental.rental_date >= 20050601 and rental.rental_date <= 20050615;

SELECT customer.customer_id, count(rental_id) as 'films_rented' from sakila.rental
RIGHT OUTER JOIN sakila.customer ON rental.customer_id = customer.customer_id 
where rental.rental_date >= 20050601 and rental.rental_date <= 20050615
GROUP BY customer_id
ORDER BY customer_id;

SELECT a.customer_id, c.city, count(d.rental_id) AS 'Total films rented', sum(amount) AS 'Total money spent', e.rental_date FROM sakila.customer AS a
JOIN sakila.address AS b ON a.address_id = b.address_id 
JOIN sakila.city AS c ON b.city_id = c.city_id
JOIN sakila.payment AS d ON a.customer_id = d.customer_id
JOIN sakila.rental AS e ON d.rental_id = e.rental_id
where e.rental_date >= 20050601 and e.rental_date <= 20050615
group by a.customer_id
ORDER BY a.customer_id;


-- 8 Y/N rented May?
SELECT customer_id, 
case
	when count(rental_id) > 0 then "Y"
    else "N"
end as "Rented May"
FROM sakila.rental 
where rental_date >= 20050515 and rental_date <= 20050530
group by customer_id
ORDER BY customer_id;

/*
SELECT a.customer_id, c.city, count(d.rental_id) AS 'Total films rented', sum(amount) AS 'Total money spent', CAST(e.rental_date AS DATE) AS 'Rental Date', 
case
	when count(d.rental_id) > 0 then "Y"
    else "N"
end as "Rented May"
FROM sakila.customer AS a
JOIN sakila.address AS b ON a.address_id = b.address_id 
JOIN sakila.city AS c ON b.city_id = c.city_id
JOIN sakila.payment AS d ON a.customer_id = d.customer_id
JOIN sakila.rental AS e ON d.rental_id = e.rental_id
where e.rental_date >= 20050515 and e.rental_date <= 20050530
group by a.customer_id
ORDER BY a.customer_id DESC;
*/ 

-- 9 Y/N rented June?
SELECT customer_id, 
case
	when count(rental_id) > 0 then "Y"
    else "N"
end as "Rented June"
FROM sakila.rental 
where rental_date >= 20050601 and rental_date <= 20050615
group by customer_id
ORDER BY customer_id;


/*
select c.customer_id , a.city_id , ct.category_id, ct.name AS 'category_name', COUNT(r.rental_id) AS 'No_of_films_rented', sum(p.amount) AS 'total_money_spent'
from address a
JOIN
customer c ON c.address_id = a.address_id
JOIN
payment p ON p.customer_id = c.customer_id
JOIN
rental r ON r.rental_id = p.rental_id
JOIN
inventory i ON r.inventory_id = i.inventory_id
JOIN
film_category fc ON fc.film_id = i.film_id
JOIN
category ct ON ct.category_id = fc.category_id
group by ct.category_id , c.customer_id
order by COUNT(r.rental_id) desc;
*/