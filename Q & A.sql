/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
limit 1;

/* Q2: Which countries have the most Invoices? */

SELECT billing_country, count (invoice_id) 
FROM invoice
GROUP BY 1
ORDER BY 2 DESC;

/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city, sum (total) as sum_of_total_invoices
from invoice
group by 1
order by 2 desc
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, c.first_name, c.last_name, sum(i.total) as total_spend
from customer c join invoice i
on c.customer_id = i.customer_id
group by 1,2,3
order by 4 desc
limit 1;

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct c.email, c.first_name, c.last_name, g.name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
order by 1;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

Select distinct a.artist_id, a.name, COUNT(a.artist_id) AS number_of_songs
from artist a
join album ab on a.artist_id = ab.artist_id
join track t on ab.album_id = t.album_id
join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
group by 1
order by 3 desc
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.*/

select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by 2 desc;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with t1 as (
	SELECT c.country, g.name, g.genre_id, COUNT(il.quantity) AS purchases,
	rank() over (partition by c.country order by count(il.quantity) desc) as rnk
	from invoice_line il
	join invoice i on il.invoice_id = i.invoice_id
	join customer c on i.customer_id = c.customer_id
	join track t on il.track_id = t.track_id
	join genre g on g.genre_id = t.genre_id
	group by 1,2,3
	order by 1, 4 desc
)
select country, name, genre_id, purchases
from t1
where rnk = 1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with t1 as (
	select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(i.total) as total_spend,
	rank() over (partition by billing_country order by sum(i.total) desc) as rnk
	from customer c join invoice i
	on c.customer_id = i.customer_id
	group by 1,2,3,4
)
select customer_id, first_name, last_name, billing_country, total_spend from t1 where rnk = 1;