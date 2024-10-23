-- Pizza Hut Case Study SQL

-- CREATE DATABASE Pizza_hut;
-- USE Pizza_hut;

-- Imported orders,order_details,pizza_types,pizzas data via wizard

-- Checking the data
SELECT * FROM pizza_hut.orders;
SELECT * FROM pizza_hut.order_details;
SELECT * FROM pizza_hut.pizza_types;
SELECT * FROM pizza_hut.pizzas;

-- ALTER TABLE pizza_hut.pizza_types
-- RENAME COLUMN string_field_3 TO ingredients;


-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_orders 
FROM pizza_hut.orders;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(p.price * od.quantity),2) as total_revenue
FROM pizza_hut.pizzas p
JOIN pizza_hut.order_details od
ON p.pizza_id=od.pizza_id;

-- Identify the highest-priced pizza.
SELECT pizza_id,
       MAX(price) as highest_price_pizza
FROM pizza_hut.pizzas
GROUP BY pizza_id
ORDER BY 2 desc
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT p.size,
       COUNT(od.quantity) as most_ordered_qty
FROM pizza_hut.pizzas p
JOIN pizza_hut.order_details od 
ON p.pizza_id=od.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT p.pizza_type_id,
       COUNT(od.quantity) as most_ordered_qty
FROM pizza_hut.pizzas p
JOIN pizza_hut.order_details od 
ON p.pizza_id=od.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category,
      SUM(od.quantity) as total_qty
FROM pizza_hut.pizza_types pt
JOIN pizza_hut.pizzas p
ON p.pizza_type_id=pt.pizza_type_id
JOIN pizza_hut.order_details od 
ON p.pizza_id=od.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- Determine the distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM time) as hr,COUNT(order_id) as no_of_orders
FROM pizza_hut.orders
GROUP BY 1;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT pt.category,
       count(od.order_id) as no_of_orders
FROM pizza_hut.pizza_types pt
JOIN pizza_hut.pizzas p
ON pt.pizza_type_id=p.pizza_type_id
JOIN pizza_hut.order_details od
ON od.pizza_id=p.pizza_id
GROUP BY 1;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(total_qty),0) as avg_no_of_pizzas_ordered_per_day
       FROM
       (
        SELECT o.date,
               sum(od.quantity) as total_qty
        FROM pizza_hut.orders o
        JOIN pizza_hut.order_details od
        ON o.order_id=od.order_id
        GROUP BY 1
       ) as qty_by_date;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT p.pizza_id,
       pt.name,
       SUM(p.price*od.quantity) as revenue
FROM pizza_hut.pizzas p
JOIN pizza_hut.order_details od
ON p.pizza_id=od.pizza_id
JOIN pizza_hut.pizza_types pt
ON p.pizza_type_id=pt.pizza_type_id
GROUP BY 1,2
ORDER BY 2 DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
WITH total_revenue AS (
  SELECT SUM(p.price * od.quantity) AS total_revenue
  FROM pizza_hut.pizzas p
  JOIN pizza_hut.order_details od
  ON p.pizza_id = od.pizza_id
)

SELECT pt.category,
       ROUND(SUM(p.price * od.quantity) / total_revenue.total_revenue * 100, 2) AS percentage_contribution_revenue
FROM pizza_hut.pizzas p
JOIN pizza_hut.order_details od
ON p.pizza_id = od.pizza_id
JOIN pizza_hut.pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
JOIN total_revenue
ON TRUE
GROUP BY pt.category, total_revenue.total_revenue
ORDER BY percentage_contribution_revenue DESC;

-- Analyze the cumulative revenue generated over time.
SELECT * FROM `pizza_hut.orders`;
SELECT * FROM `pizza_hut.order_details`;
SELECT * FROM `pizza_hut.pizzas`;

SELECT order_date,
       total_revenue,
       SUM(total_revenue) OVER(ORDER BY order_date) as cum_revenue
       FROM
        (SELECT o.date as order_date,
              ROUND(SUM(p.price * od.quantity),2) as total_revenue
        FROM pizza_hut.order_details od
        JOIN pizza_hut.pizzas p
        ON p.pizza_id=od.pizza_id
        JOIN pizza_hut.orders o
        ON o.order_id=od.order_id
        GROUP BY 1
        ORDER BY 2);

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category,
       total_revenue,
       rnk
FROM
    (SELECT category,
          total_revenue,
          RANK() OVER(PARTITION BY CATEGORY ORDER BY total_revenue DESC) as rnk
    FROM
      (SELECT pt.name as name,
              pt.category as category,
              ROUND(SUM(p.price * od.quantity),2) as total_revenue
              FROM pizza_hut.order_details od
              JOIN pizza_hut.pizzas p
              ON p.pizza_id=od.pizza_id
              JOIN pizza_hut.pizza_types pt
              ON p.pizza_type_id=pt.pizza_type_id
              GROUP BY 1,2
              ORDER BY 3 DESC) as a) 
WHERE rnk<=3;





