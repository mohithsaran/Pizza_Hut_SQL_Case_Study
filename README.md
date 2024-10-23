# **Pizza Hut SQL Case Study**
This case study involves analyzing a dataset of around 40,000 records from a fictional Pizza Hut dataset to answer various business questions. The dataset includes tables for pizzas, pizza types, order details, and other related information. The queries will cover basic, intermediate, and advanced SQL concepts to gain insights into the business operations.

## **Dataset Overview**
The dataset consists of the following tables:

pizzas: Contains information about pizzas, including their IDs, names, prices, and associated pizza types.
pizza_types: Lists the different categories of pizzas (e.g., vegetarian, non-vegetarian) along with their descriptions.
order_details: Stores details of each order, including order IDs, pizza IDs, quantities, and timestamps.
orders: Stores orders IDs, date, time of purchasing the order

## **SQL Queries and Objectives**
### **Basic Queries**
1. **Retrieve the total number of orders placed.**
```sql
   SELECT COUNT(order_id) AS total_orders 
   FROM pizza_hut.orders;
```
2. **Calculate the total revenue generated from pizza sales.**
```sql
   SELECT ROUND(SUM(p.price * od.quantity),2) as total_revenue
    FROM pizza_hut.pizzas p
    JOIN pizza_hut.order_details od
    ON p.pizza_id=od.pizza_id;
```
3. **Identify the highest-priced pizza.**
 ```sql
   SELECT pizza_id,
       MAX(price) as highest_price_pizza
    FROM pizza_hut.pizzas
    GROUP BY pizza_id
    ORDER BY 2 desc
    LIMIT 1;
 ```
4. **Identify the most common pizza size ordered.**
```sql
SELECT p.size,
       COUNT(od.quantity) as most_ordered_qty
FROM pizza_hut.pizzas p
JOIN pizza_hut.order_details od 
ON p.pizza_id=od.pizza_id
GROUP BY 1
ORDER BY 2 DESC;
```
5.**List the top 5 most ordered pizza types along with their quantities.**
```sql
SELECT p.pizza_type_id,
       COUNT(od.quantity) as most_ordered_qty
FROM pizza_hut.pizzas p
JOIN pizza_hut.order_details od 
ON p.pizza_id=od.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
### **Intermediate Queries**
6. **Join the necessary tables to find the total quantity of each pizza category ordered.**
```sql
SELECT pt.category,
      SUM(od.quantity) as total_qty
FROM pizza_hut.pizza_types pt
JOIN pizza_hut.pizzas p
ON p.pizza_type_id=pt.pizza_type_id
JOIN pizza_hut.order_details od 
ON p.pizza_id=od.pizza_id
GROUP BY 1
ORDER BY 2 DESC;
```
7. **Determine the distribution of orders by hour of the day.**
```sql
SELECT EXTRACT(HOUR FROM time) as hr,COUNT(order_id) as no_of_orders
FROM pizza_hut.orders
GROUP BY 1;
```
8. **Join relevant tables to find the category-wise distribution of pizzas.**
```sql
SELECT pt.category,
       count(od.order_id) as no_of_orders
FROM pizza_hut.pizza_types pt
JOIN pizza_hut.pizzas p
ON pt.pizza_type_id=p.pizza_type_id
JOIN pizza_hut.order_details od
ON od.pizza_id=p.pizza_id
GROUP BY 1;
```
9. **Group the orders by date and calculate the average number of pizzas ordered per day.**
```sql
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
```
### **Advanced Queries**
10. **Determine the top 3 most ordered pizza types based on revenue.**
```sql
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
```
11. **Calculate the percentage contribution of each pizza type to total revenue.**
```sql
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
```
12. **Analyze the cumulative revenue generated over time.**
```sql
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
```
13. **Determine the top 3 most ordered pizza types based on revenue for each pizza category.**
```sql
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
```
