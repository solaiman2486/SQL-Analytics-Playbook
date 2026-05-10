-- Performance analysis ...
-- Comparing the current value to a target value 
-- helps measure success and compare performace

-- Analyze the yearly performance of the product 
-- by Comparing each products sales to both 
-- its average sales performance and the previous years sales 

with yearly_product_sales as (

select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where f.order_date and f.sales_amount is not null
group by year(f.order_date),p.product_name 
order by year(f.order_date),p.product_name 
)

select
order_year,
product_name ,
current_sales,
avg(current_sales) over (partition by product_name) as average_sales,
current_sales - avg(current_sales) over (partition by product_name) as Difference_avg,
CASE WHEN current_sales - avg(current_sales) over (partition by product_name) >0 then 'Above Avg'
	 WHEN current_sales - avg(current_sales) over (partition by product_name) <0 then 'Below Avg'
     else 'Avg'
end as avg_change,
LAG (current_sales) over (partition by product_name order by order_year) as Prev_year_salse,
current_sales-LAG (current_sales) over (partition by product_name order by order_year) as Diff_prev_yr,
 CASE WHEN current_sales -LAG (current_sales) over (partition by product_name order by order_year) >0 then 'Increasing'
	 WHEN current_sales - LAG (current_sales) over (partition by product_name order by order_year) <0 then 'Decreasing'
     else 'Nutral'
end as prev_yr_change
from yearly_product_sales
order by product_name, order_year