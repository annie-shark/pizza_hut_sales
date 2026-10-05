----For Deleting tables----
drop table pizzas;
drop table pizza_types;
drop table orders;
drop table order_details;

---- creating tables----

CREATE TABLE PIZZAS (

pizza_id varchar(50) primary key,
pizza_type_id varchar(50) not null,
size varchar(5) not null,
price numeric(6,2) not null,
CONSTRAINT fk_pizza_types FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id)
);

create table pizza_types (

pizza_type_id varchar(50) primary key,
name varchar(100) not null,
category varchar(50) not null,
ingredients varchar(200)
);

create table orders (
order_id int primary key,
date date not null,
time time not null
);

create table order_details (
order_details_id int primary key,
order_id int not null,
pizza_id varchar(50) not null,
quantity int not null,
CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders (order_id),
CONSTRAINT fk_pizzas FOREIGN KEY (pizza_id) REFERENCES pizzas(pizza_id)
);

select * from pizzas;
select * from pizza_types;
select * from orders;
select * from order_details;

select 'pizza_types' as tbl, count(*) from pizza_types
union all select 'pizzas',count(*) from pizzas
union all select 'orders',count(*) from orders
union all select 'order_details', count(*) from order_details;


---------------------------------------------------------------BEGINNER LEVEL-------------------------------------------------------------------------------------------------------

-----Retrieve the total number of orders placed.-----

select count(order_id) as total_orders from orders;

----saving query in a view------

create view q1 as
select count(order_id) as total_orders from orders;
select * from q1

----Calculate the total revenue generated from pizza sales.

select round(sum(od.quantity* p.price),2) as revenue
from order_details od
join pizzas p
on p.pizza_id = od.pizza_id

----saving query in a view------

create view q2 as 
select round(sum(od.quantity* p.price),2) as revenue
from order_details od
join pizzas p
on p.pizza_id = od.pizza_id

select * from q2

----Identify the highest-priced pizza.----

select pt.name, p.price
from pizza_types pt
join pizzas p
on
p.pizza_type_id = pt.pizza_type_id
order by p.price desc limit 1;

create view q3 as 
select pt.name, p.price
from pizza_types pt
join pizzas p
on
p.pizza_type_id = pt.pizza_type_id
order by p.price desc limit 1;

-----Identify the most common pizza size ordered.---

select quantity, count(order_details_id) as order_count
from order_details 
group by quantity
order by 2 desc;


select p.size, count(od.order_details_id) as order_count
from order_details od
join pizzas p
on p.pizza_id = od.pizza_id
group by p.size
order by 2 desc

create view q4 as 
select p.size, count(od.order_details_id) as order_count
from order_details od
join pizzas p
on p.pizza_id = od.pizza_id
group by p.size
order by 2 desc

-----List the top 5 most ordered pizza types along with their quantities.---
select pt.name,sum(od.quantity) as qty
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
group by pt.name
order by qty desc limit 5

create view q5 as 
select pt.name,sum(od.quantity) as qty
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
group by pt.name
order by qty desc limit 5

-------------------------------------------------------------------INTERMEDIATE LEVEL-------------------------------------------------------------------------------------------


-----Join the necessary tables to find the total quantity of each pizza category ordered.----------

 select pt.category, sum(od.quantity) as pizza_count
 from
 pizza_types pt
 join pizzas p
 on pt.pizza_type_id = p.pizza_type_id
 join order_details od
 on p.pizza_id = od.pizza_id
group by pt.category
order by pizza_count desc;

-----------Determine the distribution of orders by hour of the day.--------
select extract(hour from time) as order_hour, count(order_id) orders_hour
from orders
group by extract(hour from time)
order by order_hour desc

----------Join relevant tables to find the category-wise distribution of pizzas.--

select category, count(name) from pizza_types
group by category

-------Group the orders by date and calculate the average number of pizzas ordered per day.---
select round(avg(t_qty),2) as Average_qty from
(select o.date, sum(od.quantity) as t_qty
from
orders o
join order_details od
on o.order_id = od.order_id
group by o.date
order by t_qty desc) as order_qty;


--------Determine the top 3 most ordered pizza types based on revenue.-------

select pt.name, sum(od.quantity * p.price) as revenue
from
pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
group by pt.name
order by revenue desc limit 3

-----------------------------------------------------------------ADVANCE LEVEL----------------------------------------------------------------------------------------------


---------Calculate the percentage contribution of each pizza type to total revenue.------

select pt.category, round((sum(od.quantity * p.price)/(select round(sum(od.quantity* p.price),2) 
from order_details od
join pizzas p
on p.pizza_id = od.pizza_id))*100,2) as percentage
from
pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
group by pt.category

-----Analyze the cumulative revenue generated over time.----------


select a.date, sum(revenue) over(order by a.date) as cum
from
(select o.date, sum(od.quantity * p.price) as revenue
from
orders o
join order_details od
on o.order_id = od.order_id
join pizzas p
on p.pizza_id = od.pizza_id
group by o.date) as a


-------Determine the top 3 most ordered pizza types based on revenue for each pizza category.-------
select category,name ,rev,rankings
from
(select category,name, rev,
rank() over (partition by category order by rev desc) as rankings
from
(select pt.category, pt.name, sum(od.quantity*p.price) as rev
from
pizza_types pt
join pizzas p
on 
pt.pizza_type_id = p.pizza_type_id
join order_details od
on
od.pizza_id = p.pizza_id
group by pt.category, pt.name
order by rev desc) as r) as b
where rankings <= 3



