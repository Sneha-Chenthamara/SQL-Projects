use music_store;
#1 Who is the senior most employee based on the job title ?
select last_name,first_name from employee where levels = 'L7';
select * from employee order by levels desc limit 1;

#2 Which countries have the most invoices ?
select count(invoice_id),billing_country from invoice group by billing_country order by count(invoice_id) desc;

#3 Which are the top 3 values of total ivoices ?
select total from invoice order by total desc limit 3;

#4 Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
# Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city,sum(total) as invoice_total from invoice group by billing_city order by invoice_total desc limit 1;

#5 Who is the best customer? The customer who has spent the most money will be declared the best customer. 
# Write a query that returns the person who has spent the most money
select * from invoice;
select * from customer;
select sum(total) as invoice_total,first_name,last_name from customer as T1 inner join invoice as T2 
on T1.customer_id = T2.customer_id group by T2.customer_id order by invoice_total desc limit 1;

#6 Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
# Return your list ordered alphabetically by email starting with A
select distinct(email),first_name,last_name,T5.name from customer as T1 inner join
invoice as T2 on T1.customer_id = T2. customer_id inner join
invoice_line as T3 on T2.invoice_id = T3.invoice_id inner join
track as T4 on T3.track_id = T4.track_id inner join
genre as T5 on T4.genre_id = T5.genre_id where T5.name = "Rock" order by email;

#7 Let's invite the artists who have written the most rock music in our dataset. 
# Write a query that returns the Artist name and total track count of the top 10 rock bands.
select T1.artist_id,T1.name, count(T1.artist_id) from artist as T1 inner join
album as T2 on T1.artist_id = T2.artist_id inner join
track as T3 on T2.album_id = T3.album_id inner join
genre as T4 on T3.genre_id = T4.genre_id 
where T4.name = "Rock" group by T1.artist_id order by count(T1.artist_id) desc limit 10;

#8 Return all the track names that have a song length longer than the average song length. 
# Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
select name,milliseconds from track having milliseconds > 
(select avg(milliseconds) from track) order by milliseconds desc;

#9 Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent





