
-- Q1: The total number of order place

SELECT
	COUNT(order_id)
FROM
	orders;


-- Q2: The total revenue generated from pizza sales

SELECT
	SUM(p.price * od.quantity) AS total_revenue
FROM
	order_details od
JOIN
	pizzas p
ON
	od.pizza_id = p.pizza_id;


-- Q3: The highest priced pizza.

SELECT
	pizza_id,
	price
FROM
	pizzas 
ORDER BY
	price DESC
LIMIT 1;


-- Q4: The most common pizza size ordered.

SELECT
	p.size,
	SUM(od.quantity) total_orders
FROM
	order_details od
JOIN
	pizzas p
ON
	p.pizza_id = od.pizza_id
GROUP BY
	p.size
ORDER BY
	total_orders DESC;


-- Q5: The top 5 most ordered pizza types along their quantities.

SELECT
	pt.name,
	SUM(od.quantity) total_orders
FROM
	order_details od
JOIN
	pizzas p
ON
	p.pizza_id = od.pizza_id
JOIN
	pizza_types pt
ON
	pt.pizza_type_id = p.pizza_type_id
GROUP BY
	pt.name
ORDER BY
	total_orders DESC
LIMIT 5;


-- Q6: The quantity of each pizza categories ordered.

SELECT
	pt.category,
	SUM(od.quantity) AS total_quantity
FROM
	pizza_types pt
JOIN
	pizzas p
ON
	p.pizza_type_id = pt.pizza_type_id
JOIN
	order_details od
ON
	od.pizza_id = p.pizza_id
GROUP BY
	pt.category
ORDER BY
	total_quantity DESC;


-- Q7: The distribution of orders by hours of the day.

SELECT
	EXTRACT (HOUR FROM time) AS hours_of_the_day,
	COUNT(*) AS count_of_orders
FROM
	orders
GROUP BY
	EXTRACT (HOUR FROM time)
ORDER BY
	count_of_orders DESC;


-- Q8: The category-wise distribution of pizzas.

SELECT
	pt.category,
	COUNT(o.order_id) AS orders
FROM
	orders o
JOIN
	order_details od
ON
	o.order_id = od.order_id
JOIN
	pizzas p
ON
	od.pizza_id = p.pizza_id
JOIN
	pizza_types pt
ON
	pt.pizza_type_id = p.pizza_type_id
GROUP BY
	pt.category
ORDER BY
	orders DESC;


-- Q9: The average number of pizzas ordered per day.

SELECT
	ROUND(SUM(od.quantity) / COUNT(DISTINCT o.date)) AS average_pizza_ordered_per_day
FROM
	order_details od
JOIN
	orders o
ON
	o.order_id = od.order_id;
	

-- Q10: Top 3 most ordered pizza type base on revenue.

SELECT
	pt.name,
	ROUND(SUM(p.price * od.quantity)) AS total_revenue
FROM
	pizza_types pt
JOIN
	pizzas p
ON
	p.pizza_type_id = pt.pizza_type_id
JOIN
	order_details od
ON
	od.pizza_id = p.pizza_id
GROUP BY
	pt.name
ORDER BY
	total_revenue DESC
LIMIT 3;


-- Q11: The percentage contribution of each pizza type to revenue.

 -- we need to first find total_revenue
SELECT
	SUM(p.price * od.quantity) AS total_revenue
FROM
	pizzas p
JOIN
	order_details od
ON
	od.pizza_id = p.pizza_id;
 
 -- Then we can find the percentage contribution of each pizza type
 SELECT
	pt.category,
	ROUND((((SUM(p.price * od.quantity))) / (SELECT
	SUM(p.price * od.quantity) AS total_revenue
FROM
	pizzas p
JOIN
	order_details od
ON
	od.pizza_id = p.pizza_id)) * 100) AS percentage_revenue
FROM
	pizza_types pt
JOIN
	pizzas p
ON
	p.pizza_type_id = pt.pizza_type_id
JOIN
	order_details od
ON
	od.pizza_id = p.pizza_id
GROUP BY
	pt.category
ORDER BY
	percentage_revenue DESC;
	

-- Q12: The cumulative revenue generated over time.

SELECT
	o.date,
	ROUND(SUM(p.price * od.quantity)) AS revenue,
	SUM(ROUND(SUM(p.price * od.quantity))) OVER (ORDER BY o.date) AS cumulative_revenue
FROM
	orders o
JOIN
	order_details od
ON
	od.order_id = o.order_id
JOIN
	pizzas p
ON
	p.pizza_id = od.pizza_id
GROUP BY
	 o.date;
	 
-- Q13: The top 3 most ordered pizza type based on revenue for each pizza category.

-- We need to first rank most ordered pizza type based on revenue for each pizza category
SELECT
	pt.category,
	pt.name,
	(SUM(p.price * od.quantity)) as revenue,
	RANK() OVER (PARTITION BY pt.category ORDER BY SUM((p.price * od.quantity)) DESC) AS revenue_rank
FROM
	pizza_types pt
JOIN
	pizzas p
ON
	p.pizza_type_id = pt.pizza_type_id
JOIN
	order_details od
ON
	od.pizza_id = p.pizza_id
GROUP BY
	pt.category, pt.name

--After ranking the most ordered pizza type based on revenue for each pizza category 
--then we can select top 3 from each category
SELECT
    category,
    name,
    ROUND(revenue)
FROM
    (SELECT pt.category, pt.name,
	(SUM(p.price * od.quantity)) as revenue,
	RANK() OVER (PARTITION BY pt.category ORDER BY SUM((p.price * od.quantity)) DESC) AS revenue_rank
FROM pizza_types pt
JOIN pizzas p
ON
	p.pizza_type_id = pt.pizza_type_id
JOIN
	order_details od
ON
	od.pizza_id = p.pizza_id
GROUP BY
	category, name
)
WHERE
    revenue_rank <= 3
ORDER BY
    category, revenue_rank;



