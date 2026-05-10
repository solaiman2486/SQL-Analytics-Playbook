-- Part to whole (proportional analysis)
-- How an individual part is performing compared to the overall,
-- and which category has the greatest impact on the buisness 

with category_sales as(
select 
category,
sum(sales_amount) as total_sales
from gold.fact_sales f
left join gold.dim_products p
on p.product_key=f.product_key
group by category)

select
category,
total_sales,
sum(total_sales) over () as overall_sales,
CONCAT(ROUND(((total_sales)/sum(total_sales) over ())*100,2),"%") as total_percentage
from category_sales