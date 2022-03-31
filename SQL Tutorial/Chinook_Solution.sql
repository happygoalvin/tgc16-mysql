1 - Display all Sales Support Agents with their first name and last name

select Title, FirstName, LastName from Employee where Title like "Sales Support Agent";

2 - Display all employees hired between 2002 and 2003,
and display their first name and last name

SELECT FirstName, LastName, HireDate FROM Employee
WHERE YEAR(HireDate) >= 2002 and YEAR(HireDate) <= 2003; 


3 - Display all artists that have the word 'Metal' in their name
select * from Artist where name like "%Metal%";

4 - Display all employees who are in sales (sales manager, sales rep etc.)
select * from Employee where Title like "%Sales%";

5 - Display the titles of all tracks which has the genre "easy listening"
SELECT Track.GenreId, Track.Name, Genre.Name FROM Track join Genre 
on Track.GenreId = Genre.GenreId
where Genre.Name = "easy listening";

6 - Display all the tracks from all albums along with the genre of each track
SELECT Track.Name, Album.Title, Genre.Name FROM Track JOIN Album 
ON Track.AlbumId = Album.AlbumId
JOIN Genre ON Track.GenreId = Genre.GenreId;


7 - Using the Invoice table, show the average payment made for each country

SELECT billingCountry, Avg(Total) FROM Invoice
GROUP BY billingCountry;


8 - Using the Invoice table, show the average payment made for each country, but only for countries that paid more than $5.50 in total average
SELECT billingCountry, Avg(Total) FROM Invoice
GROUP BY billingCountry
HAVING AVG(Total) >= 5.50;

9 - Using the Invoice table, show the average payment made for each customer, 
but only for customer reside in Germany and only 
if that customer has paid more than 10 in total

SELECT Customer.CustomerId, Customer.FirstName, Customer.LastName, Customer.Country, billingCountry, AVG(Total) FROM Invoice
JOIN Customer ON Invoice.CustomerId = Customer.CustomerId
GROUP BY Customer.CustomerId, Customer.FirstName, Customer.LastName, Customer.Country, billingCountry
HAVING billingCountry="Germany" and SUM(Total) >= 10;

-- alternative more effective code
SELECT Customer.CustomerId, Customer.FirstName, Customer.LastName, Customer.Country, billingCountry, AVG(Total) FROM Invoice
JOIN Customer ON Invoice.CustomerId = Customer.CustomerId
WHERE billingCountry="Germany"
GROUP BY Customer.CustomerId, Customer.FirstName, Customer.LastName, Customer.Country, billingCountry
HAVING SUM(Total) >= 10;

10 - Display the average length of Jazz song (that is, the genre of the song is Jazz) for each album
SELECT Album.Title, AVG(Milliseconds), Genre.Name FROM Track 
JOIN Genre ON Track.GenreId = Genre.GenreId
JOIN Album ON Track.AlbumId = Album.AlbumId
WHERE Genre.Name = "Jazz"
GROUP BY Album.Title, Genre.Name;
