-- Grouping customer into three segments on their spending behavior 
--  #VIP: Customer with at least 12 month of history and spending more than 5000
--  #Regular: Customer with at least 12 month of history and spending more than 5000 or less
--  #New: Customer with life span less than 12 months 
-- Finding the total number customer by each group  

WITH customer_spending as (
SELECT 
    p.customer_key,
    SUM(f.sales_amount) AS total_spending,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers p
    ON f.customer_key = p.customer_key
GROUP BY p.customer_key
)
SELECT
customer_key,
total_spending,
life_span,
CASE WHEN life_span>12 and total_spending>5000 THEN 'VIP'
	 WHEN life_span>12 and total_spending<=5000 THEN 'Regular'
     ELSE 'New'
END as customer_category
from customer_spending;

-- TO Calculate The total Customer Category

WITH customer_spending as (
SELECT 
    p.customer_key,
    SUM(f.sales_amount) AS total_spending,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers p
    ON f.customer_key = p.customer_key
GROUP BY p.customer_key
)

SELECT 
customer_category,
COUNT(customer_key) as total_customer 
FROM(
SELECT
	customer_key,
	CASE WHEN life_span>12 and total_spending>5000 THEN 'VIP'
		WHEN life_span>12 and total_spending<=5000 THEN 'Regular'
		ELSE 'New'
	END as customer_category
FROM customer_spending
)t
GROUP BY customer_category 
ORDER BY total_customer DESC