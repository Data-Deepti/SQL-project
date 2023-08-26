/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

select employee_id , last_name , first_name , title , levels
from employee 
order by levels desc
limit 1 ;


/* Q2: Which countries have the most Invoices? */

select count(*) as c , billing_country 
from invoice
group by billing_country
order by c desc ;

/* Q3: What are top 3 values of total invoice? */

select total
from invoice
order by total desc ;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city , sum(total) as invoice_total
from invoice 
group by  billing_city
order by invoice_total desc
limit 1 ;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id , c.first_name , c.last_name , sum(total) as total_spending
from customer c
join invoice i on i.customer_id = c.customer_id
group by 1
order by 4 desc
limit 1 ;


/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct c.email , c.first_name , c.last_name , g.name
from customer c
join invoice i on i.customer_id = c.customer_id 
join invoice_line il on il.invoice_id = i.invoice_id 
join track t on t.track_id = il.track_id 
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
order by 1 ;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select ar.artist_id , ar.name , count(ar.artist_id) as total_tracks
from artist ar
join album al on al.artist_id = ar.artist_id
join track t on t.album_id = al.album_id
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by 1
order by 3 desc
limit 10 ; 

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name , milliseconds 
from track
where milliseconds > (select avg(milliseconds) as avg_song_length
                      from track)
order by milliseconds desc ;


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

with best_selling_artist as (
      select ar.artist_id , ar.name as artist_name , sum(il.unit_price * il.quantity) as total_sales
      from artist ar 
      join album al on al.artist_id = ar.artist_id 
      join track t on t.album_id = al.album_id
      join invoice_line il on il.track_id = t.track_id
      group by 1
      order by 3 desc
      limit 1)
	  
select c.first_name , c.last_name , bsa.artist_name , bsa.total_sales as amt_spent
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album al on al.album_id = t.album_id
join artist ar on ar.artist_id = al.artist_id
join best_selling_artist bsa on bsa.artist_id = ar.artist_id
group by 1,2,3,4
order by 4 desc

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with country_wise_popular_genre as (
    select g.name , c.country , count(il.quantity) as purchases ,
	row_number() over (partition by c.country 
					   order by count(il.quantity)desc)as row_no
	from genre g
	join track t on t.genre_id = g.genre_id
	join invoice_line il on il.track_id = t.track_id
	join invoice i on i.invoice_id = il.invoice_id
	join customer c on c.customer_id = i.customer_id
	group by 1,2
	order by 2 asc , 3 desc)

select *
from country_wise_popular_genre
where row_no <= 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with top_customer_countrywise as (
     select c.customer_id , c.first_name , c.last_name , i.billing_country , sum(i.total)as amt_spent , 
	row_number() over (partition by i.billing_country
					   order by sum(i.total) desc) as row_no
	from customer c 
	join invoice i on  i.customer_id = c.customer_id
	group by 1,2,3,4
	order by 4 asc , 5 desc)
	
select * 
from top_customer_countrywise
where row_no <= 1











