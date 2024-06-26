USE music_library;

#who is the senior most employee based on job title?

Select employee_id, last_name, first_name, title, levels
from employee
Order by levels desc
Limit 1;

#Which countries have the most invoices?

Select count(*) as Count_of_invoices, billing_country
from invoice
group by billing_country
order by Count_of_invoices desc;

#What are top 3 values of total invoice

Select invoice_id,customer_id,total
from invoice
order by total desc
limit 3;

# Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
# Write a query that returns one city that has the highest sum of invoice totals. 
# Return both the city name & sum of all invoice totals

Select billing_city, sum(total) as invoice_total
from invoice
group by billing_city
Order by invoice_total desc
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id, customer.first_name, Customer.last_name, 
sum(invoice.total) as total_spending
from customer
join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, Customer.last_name
order by total_spending desc
Limit 1;

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT email AS Email,first_name AS FirstName, 
last_name AS LastName, genre.name AS Name
from customer
JOIN invoice on customer.customer_id = invoice.customer_id
JOIN invoice_line on invoice.invoice_id = invoice_line.invoice_id
JOIN track on invoice_line.track_id = track.track_id
JOIN genre on track.genre_id = genre.genre_id
Where genre.name = "Rock"
Order by Email Asc;

#method 2
SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name like "Rock")
    ORDER BY email;
    
/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album2 ON album2.album_id = track.album_id
JOIN artist ON artist.artist_id = album2.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.name, artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT track.name, track.milliseconds
FROM track
Where Milliseconds > (Select avg (milliseconds)
						from track)
Order by track.milliseconds DESC;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on best selling artist? Write a query to return customer name, artist name and total spent */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY 1, 2
	ORDER BY 3 DESC
	LIMIT 1)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH Popular_Genre as (
SELECT count(invoice_line.invoice_id) as Purchase_Qty, customer.country, genre.name, genre.genre_id,
ROW_Number () OVER (Partition by customer.country order by count(invoice_line.invoice_id) desc) as Row_no
FROM invoice I
JOIN customer on customer.customer_id = I.customer_id
JOIN invoice_line on I.invoice_id = invoice_line.invoice_id
JOIN track on invoice_line.track_id = track.track_id
JOIN genre on genre.genre_id = track.genre_id
GROUP BY 2,3,4
order by 2 asc, 1 desc
)
SELECT * FROM Popular_Genre WHERE Row_no <=1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customer_by_Country as 
(
SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(i.total) AS total_spending,
ROW_Number () OVER (partition by i.billing_country order by SUM(i.total) desc) as Row_no
FROM customer c
JOIN invoice i on c.customer_id = i.customer_id
GROUP BY 1,2,3,4
order by 4 asc, 5 desc
)
SELECT * from Customer_by_Country where Row_no <= 1


