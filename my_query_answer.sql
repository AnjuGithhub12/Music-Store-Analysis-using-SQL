--1.senior most employee based on job title-> reports to null 
SELECT s.first_name ,s.last_name  FROM sql_all_query_inTsql.dbo.employee as s
where s.reports_to is null
--2.countries having the most invoices-?count of invoices ased
select i.billing_country,count(i.invoice_id) as count_invoices from  sql_all_query_inTsql.dbo.invoice as i
group by i.billing_country
order by count_invoices desc
-- 3 values of total invoice -> 
select top 3 i.total,i.billing_country from sql_all_query_inTsql.dbo.invoice as i
order by i.total desc
--4. city with best customers -> highest sum of invoice totals city
select top 1 i.billing_city ,sum(i.total) as invoice_total from sql_all_query_inTsql.dbo.invoice as i
group by i.billing_city
order by invoice_total desc
--5.best customer-> who spent the most money -> select person who spent the most money
select c.customer_id,c.first_name,c.last_name,c.total
from (
select  top 1 sum(i.total) as total ,c.first_name,c.last_name,c.customer_id
from sql_all_query_inTsql.dbo.customer as c
inner join sql_all_query_inTsql.dbo.invoice as i
on c.customer_id=i.customer_id
group by c.customer_id,c.first_name,c.last_name
order by total desc 

) as c
-- QUES-2 Moderate
-- 1.email -> starting with A -> first name -> last name -> Genre of all Rock Music Listners??
select distinct c.first_name,c.last_name,c.email  from sql_all_query_inTsql.dbo.customer as c
inner join 
(select i.customer_id from  sql_all_query_inTsql.dbo.invoice as i
inner join (
select l.invoice_id ,l.track_id from sql_all_query_inTsql.dbo.invoice_line  as l
inner join (
select t.track_id from sql_all_query_inTsql.dbo.track as t
inner join (
select g.genre_id 
from  sql_all_query_inTsql.dbo.genre as g
where g.name='Rock'
)as p
on p.genre_id=t.genre_id
) as q
on q.track_id=l.track_id
) as m
on m.invoice_id=i.invoice_id
) as k
on k.customer_id=c.customer_id
order by c.email
--2. artist with most rock music in our dataset -> 1.artist name -> 2.total track count of top rock brands
select top 10 b.name as artist_name ,b.artist_id,count(t.track_id) as track_count from sql_all_query_inTsql.dbo.track as t
inner join  sql_all_query_inTsql.dbo.genre as g
on t.genre_id=g.genre_id
inner join sql_all_query_inTsql.dbo.album2 as a1
on a1.album_id=t.album_id
inner join  sql_all_query_inTsql.dbo.artist as b
on b.artist_id=a1.artist_id
where g.name='Rock'
group by b.name,b.artist_id
order by track_count desc
--3. return name and milliseconds where milliseconds >average milliseconds -> return milliseconds desc order
select t.name ,t.milliseconds as milliseconds 
from sql_all_query_inTsql.dbo.track as t
where t.milliseconds>(
select avg(t.milliseconds) from sql_all_query_inTsql.dbo.track as t
--393599->average value
)
order by t.milliseconds desc

--QUES-3 Advance 
-- 1.amount spent by each customer on artists->return 1.customer_name 2.artist_name and 3.total spent by customer on artists
select c.customer_id,c.first_name ,c.last_name ,b.name as artist_name ,sum(l.unit_price*l.quantity) as total_spent
from sql_all_query_inTsql.dbo.track as t
inner join sql_all_query_inTsql.dbo.invoice_line l
on l.track_id=t.track_id
inner join sql_all_query_inTsql.dbo.invoice as i
on i.invoice_id=l.invoice_id
inner join sql_all_query_inTsql.dbo.customer as c
on c.customer_id=i.customer_id
inner join sql_all_query_inTsql.dbo.album2 as a1
on t.album_id=a1.album_id
inner join sql_all_query_inTsql.dbo.artist as b
on a1.artist_id=b.artist_id
where b.name='Queen'
group by b.name,c.last_name,c.first_name,c.customer_id
order by total_spent desc
--2. most popular genre for each country-> genre with has highest amount of purchases ->return each country with top genre ->
---> return all genres where maximum number of purchases is shared -> 
--return country with highest amount of genres purchased  and genres names--> required is the count  
;with ranked_genres as
(select i.billing_country,g.name as genre_name ,count(i.invoice_id) as no_of_purchases ,g.genre_id,
rank() over (partition by i.billing_country order by count(i.invoice_id)desc) as genre_rank
from  sql_all_query_inTsql.dbo.genre as g
inner join sql_all_query_inTsql.dbo.track as t
on g.genre_id=t.genre_id
inner join sql_all_query_inTsql.dbo.invoice_line l
on l.track_id=t.track_id
inner join sql_all_query_inTsql.dbo.invoice as i
on l.invoice_id=i.invoice_id
group by i.billing_country,g.name,g.genre_id
)
select billing_country,genre_id,genre_name,no_of_purchases,genre_rank
from ranked_genres 
where genre_rank=1
order by  billing_country asc,
  no_of_purchases DESC

--3 customer who spent most on music -> its country -> amount spent by it ->
---1.customer who spent the most on music for each country
;with ranking_customer as (
select i.billing_country,c.customer_id,c.first_name,c.last_name,sum(l.unit_price*l.quantity) as price ,rank() over(partition by i.billing_country order by sum(l.unit_price*l.quantity) desc) as rank_cust
from sql_all_query_inTsql.dbo.track as t
inner join sql_all_query_inTsql.dbo.invoice_line l
on t.track_id=l.track_id
inner join sql_all_query_inTsql.dbo.invoice as i 
on i.invoice_id=l.invoice_id
inner join sql_all_query_inTsql.dbo.customer as c
on i.customer_id=c.customer_id
group by i.billing_country,c.customer_id,c.first_name,c.last_name

) 
select billing_country,customer_id,first_name,last_name ,price from ranking_customer
where rank_cust=1
order by  billing_country asc,price desc

 




