-- --Commulative analysis  
-- calculate the total sales per month
-- and the running total of sales over time 

select
order_date,
total_sales,
sum(total_sales) over (order by order_date) as running_total_sales
From (
	select
		date_format(order_date, '%Y-%m') as order_date,
		sum(sales_amount) as total_sales
	from gold.fact_sales
	where order_date and sales_amount is not null
	group by date_format(order_date, '%Y-%m')
)t;
-- dividing by each year



SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price  -- Changed to avg_price
FROM (
    SELECT
        YEAR(order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price 
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL AND sales_amount IS NOT NULL  -- Fixed WHERE clause
    GROUP BY YEAR(order_date)
) AS t;