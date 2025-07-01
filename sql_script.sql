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

