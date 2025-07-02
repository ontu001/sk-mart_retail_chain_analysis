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

