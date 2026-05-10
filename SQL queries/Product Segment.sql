-- Segment products into cost ranges and to 
-- count how many products fall into each segmant 
WITH product_segment as (
select 
product_name,
product_key,
cost,
CASE WHEN cost< 100 then 'Bellow 100'
	 WHEN cost between 100 and 500 then '100-500'
     WHEN cost between 500 and 1000 then '500-1000'
     ELSE 'Above 1000'
end as cost_range
from gold.dim_products)

select
cost_range,
COUNT(product_key) as total_products
from product_segment
group by cost_range
order by total_products desc