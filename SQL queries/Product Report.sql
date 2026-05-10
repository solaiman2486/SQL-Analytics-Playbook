/*
Product Report
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue

*/


WITH base_query AS (
-- Base Query retrieve core column from table
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ',c.last_name) as customer_name,
TIMESTAMPDIFF(year,c.birthdate, CURDATE()) as age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key=c.customer_key
WHERE order_date is not null
)
,customer_aggregation as(
-- This summerizes key matrics at the customer level
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) as total_orders,
	COUNT(DISTINCT order_number) as total_products,
	SUM(sales_amount) as total_sales,
	SUM(quantity) as total_quantity,
	MAX(order_date) AS last_order_date,
		TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
FROM base_query
GROUP BY
	customer_key,
	customer_number,
	customer_name,
	age
)
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
    CASE WHEN age<20 then 'Under 20'
		 WHEN age between 20 and 29 then '20-29'
         WHEN age between 30 and 39 then '30-39'
         WHEN age between 40 and 49 then '40-49'
	ELSE 'Above 50'
    END as age_group,
    CASE WHEN life_span>12 and total_sales>5000 THEN 'VIP'
		 WHEN life_span>12 and total_sales<=5000 THEN 'Regular'
		 ELSE 'New'
	END as customer_category,
    last_order_date,
    TIMESTAMPDIFF(month, last_order_date, CURDATE()) as recency,
	total_orders,
	total_products,
	total_sales,
	total_quantity,
    life_span,
--     Computing average order value
	CASE WHEN total_sales=0 then '0'
		 ELSE ROUND(total_sales/total_orders,2)
	END as avg_order_value,
    CASE WHEN life_span=0 then total_sales
		 ELSE total_sales/life_span
	END as avg_monthly_spend
-- 	ROUND(total_sales/total_orders,2) as avg_order_value,	
-- Computing average monthly spend
	
FROM customer_aggregation
	