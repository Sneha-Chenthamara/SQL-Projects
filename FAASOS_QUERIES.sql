Use FASOOS_ORDERS;

#1  How many rolls were ordered ?
select count(order_id) from customer_orders;

#2  How many unique customers have placed orders ?
select count(distinct(customer_id)) from customer_orders;

#3 How many orders are delivered ?
select count(order_id) from 
(select *,case when cancellation in ('Cancellation','Customer Cancellation') then 'C' else 'NC' end as order_cancel_details from driver_order)
as driver_order1 where order_cancel_details = 'NC'; 

#4 How many orders are delieverd by each driver ?
select driver_id, count(order_id) from 
(select *,case when cancellation in ('Cancellation','Customer Cancellation') then 'C' else 'NC' end as order_cancel_details from driver_order)
as driver_order1 where order_cancel_details = 'NC' group by driver_id; 

#5 How many each type of rolls were delivered ?
select roll_id,count(roll_id) from customer_orders as T1 inner join 
(select *,case when cancellation in ('Cancellation','Customer Cancellation') then 'C' else 'NC' end as order_cancel_details from driver_order)
as T2 on T1.order_id = T2.order_id where order_cancel_details = 'NC' group by roll_id;

#6 How many veg and non-veg orders were placed by customers ?
select customer_id,T2.roll_id, count(T2.roll_id),roll_name 
from customer_orders as T1 inner join rolls as T2 on T1.roll_id = T2.roll_id
group by customer_id,roll_id order by customer_id;

#7 What was maximum number of rolls delivered in a single order ?
select max(num_orders) from(
select customer_id, count(roll_id) as num_orders from customer_orders as T1 inner join (select order_id from
(select *,case when cancellation in ('Cancellation','Customer Cancellation') then 'C' else 'NC' end as order_cancel_details from driver_order)
as driver_order1 where order_cancel_details = 'NC') as T2 on T1.order_id = T2.order_id group by customer_id) as T3;

#8 For how many delieverd rolls had at least one change and how many had no change ?
# Creating temporary table for customer_orders

with temp_customer_orders(order_id,customer_id,roll_id,new_not_include_items,new_extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items = '' then '0' else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included = '' or extra_items_included = 'NaN' then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
)

# Creating temporary table for driver_order
,temp_driver_order(order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,distance,duration,
case when cancellation in ('Cancellation','Customer Cancellation') then '0' else '1' end as new_cancellation
from driver_order
)

select customer_id,chg_no_chg,count(order_id) from
(
select *,case when new_not_include_items = '0' and new_extra_items_included = '0' then 'no change' else 'change' end as chg_no_chg
from temp_customer_orders where order_id in (
select order_id from temp_driver_order where new_cancellation != 0)) as T1
group by customer_id,chg_no_chg;

#9 WHat was the total number of rolls ordered for each hour of the day ?
select hour_buckets,count(hour_buckets) from
(select *, concat(hour(order_date),'-',hour(order_date)+1) as hour_buckets from customer_orders) as T1
group by hour_buckets;

#10 What was the number of orders for each day of the week ?
select dow,count(distinct order_id) from
(select *,dayname(order_date) as dow from customer_orders) as T1
group by dow;

#11 WHat is the difference betweeb the longest and shortest delivery time for all orders ?
select max(duration) - min(duration) from
(select cast(case when duration like '%min%' then left(duration,locate('m',duration)-1) else duration end as unsigned) as duration
from driver_order where duration is not null) as T1;

# 12 What was the average speed for each delivery ?

select order_id,driver_id,distance/duration as speed from
(select order_id,driver_id,cast(case when distance like '%km%' then left(distance,locate('k',distance)-1) else distance end as float) as distance,
cast(case when duration like '%min%' then left(duration,locate('m',duration)-1) else duration end as float) as duration
from driver_order where distance is not null)as T1 ;

#13 What is the successful delivery percentage for each driver ?
select driver_id,(success_order/total_order)*100 as success_percenatge from
(select driver_id,sum(cancel_no_cancel) as success_order, count(driver_id) as total_order from
(select driver_id, case when lower(cancellation) like '%cancel%' then 0 else 1 end as cancel_no_cancel from driver_order) as T1
group by driver_id) as T2;