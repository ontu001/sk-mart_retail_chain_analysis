select * from categories;
select * from customers;
select * from inventory;
select * from marketing_campaigns;
select * from order_items;
select * from orders;
select * from products;
select * from stores;



-- What are the top 5 best-selling products by quantity and revenue?
with best_selling_products as (
select
	p.name,
	sum(o.quantity) as total_order,
	sum(o.price) as revenue,
	rank() over(order by sum(o.price) desc, sum(o.quantity) desc) as rank_
from products as p
inner join order_items as o on p.id = o.product_id
group by 1

)
select *
from best_selling_products
where rank_ <=5;



-- Which customers placed the most orders?
select
	c.full_name,
	count(o.id) as total_order,
	rank() over(order by count(o.id) desc)
from customers as c
inner join orders as o on c.id = o.customer_id
group by 1



-- Who are the top customers based on total spending?
select
	c.full_name,
	sum(o.total_amount) as total_spend,
	rank() over(order by sum(o.total_amount) desc)
from customers as c
inner join orders as o on c.id = o.customer_id
group by 1



-- Compare online vs. offline sales for each store.
select
    s.store_name,
    o.order_type,
    count(distinct o.id) as total_orders,
    sum(oi.quantity * oi.price) as total_sales
from orders o
join order_items oi on o.id = oi.order_id
join stores s on o.store_id = s.id
group by 1, 2;




-- Which product categories generate the highest and lowest revenue?
select
	c.category_name,
	sum(oi.quantity * oi.price) as revenue
from categories as c
inner join products as p on c.id = p.category_id
inner join order_items as oi on p.id = oi.product_id
group by 1
order by 2 desc;




-- Which marketing campaign brought in the most orders?

select
	mc.campaign_name,
	count(distinct o.id) as total_order
from marketing_campaigns as mc
inner join orders as o on mc.id = o.marketing_id
group by 1
order by 2 desc





-- What is the revenue trend over days or months?
select
  extract(month from o.order_date) as month_,
  sum(oi.quantity * oi.price) as revenue
from orders as o
inner join order_items as oi on o.id = oi.order_id
group by 1
order by 1 asc



-- Which payment method is used most frequently?
select
	payment_method,
	count(payment_method) as used
from orders
group by 1
order by 2 desc;





-- What are the current inventory levels per store and product?
select
	s.store_name,
	p.name,
	sum(i.quantity) as inventory_level
from inventory as i
inner join stores as s on s.id = i.store_id
inner join products as p on p.id = i.product_id
group by 1, 2;





-- Rank customers by total amount spent.
select
	c.full_name,
	sum(o.total_amount) as amount_spend,
	rank() over(order by sum(o.total_amount) desc) as customer_rank
from customers as c
inner join orders as o on c.id = o.customer_id
group by 1;





-- Show the top 3 best-selling products per store.
with top_3_product as(
select
	s.store_name,
	p.name,
	sum(oi.quantity) as sold,
	rank() over(partition by s.store_name order by sum(oi.quantity) desc ) as rank_
from products as p
inner join order_items as oi on p.id = oi.product_id
inner join orders as o on oi.order_id = o.id
inner join stores as s on s.id = o.store_id
group by 1, 2
)

select *
from top_3_product
where rank_ <= 3;







-- Calculate a running total of daily revenue.
select
	 date(created_at) as order_date,
	 sum(price) as daily_revenue,
	 sum(sum(price)) over(order by date(created_at)) as runnig_total_revenue
from order_items
group by 1
order by 1;




-- Compute a 7-day rolling average of total order amounts.
with daily_order_totals as (
select 
	date(created_at) as order_date,
	sum(price) as daily_revenue
from order_items
group by 1
),
rolling_avg as(
select 
	order_date,
	daily_revenue,
	round(avg(daily_revenue) over(order by order_date rows between 6 preceding and current row),2) as rolling_avg_7_day
from daily_order_totals
)
select *
from rolling_avg
order by 1




-- Show the time difference between each customer's consecutive orders.
with time_diff as(
select
  c.full_name as full_name,
  o.id as current_order_id,
  date(o.created_at) as current_order_date,
  lag(date(o.created_at)) over (partition by c.full_name order by o.created_at) as previous_order_date,
  o.created_at - lag(o.created_at) over (partition by c.full_name order by o.created_at) as time_diff
from orders as o
inner join customers as c on c.id = o.customer_id
order by c.full_name, o.created_at
)
select *
from time_diff
where time_diff is not null



