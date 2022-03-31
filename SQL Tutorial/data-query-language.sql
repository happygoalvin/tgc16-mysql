select * from employees;

-- to select lastName, firstName and email
select lastName, firstName, email from employees;

-- only all titles but remove duplicates
select jobTitle from employees

-- select all title but remove duplicates
select distinct(jobTitle) from employees;

-- select columns and rename them at the same time
select firstName as "First Name", 
lastName as "last Name",
email as "Email" from employees;

-- use `where` to filter rows:
-- select all employees from office code 1
select * from employees where officeCode = 1;

-- display first name,last name and email from officecode 1
select firstName,lastName, email from employees where officeCode = 1;

-- ONLY work for strings
-- we can use 'like' for string comparison
select * from employees where jobTitle like "Sales Rep";

-- find all employees whose job title begin with "Sales"
select * from employees where jobTitle like "Sales%";

-- find all employees whose job title end with sales
select * from employees where jobTitle like "%Sales";

-- find all employees whose job title includes the word "sales";
select * from employees where jobTitle like "%Sales%";

-- find all products which name begins with 1969
SELECT * FROM products where productName like "1969%";

-- find all products whose name contains "Davidson" anywhere
SELECT * FROM products where productName like "%Davidson%";

-- find 2 criteria, office code = 1 and job title to be "sales rep"
-- show all sales rep with office code 1
SELECT * FROM employees where officeCode = 1 and jobTitle = "Sales Rep";

-- show all employees from office code 1 and 2
SELECT * FROM employees where officeCode = 1 or officeCode = 2;

-- show all sales rep from office code 1 and 2
SELECT * FROM employees where (officeCode = 1 or officeCode = 2) 
and jobTitle = "Sales Rep";

-- show all customers from USA in the state of NV and who has 
-- credit limit > 5000;
select * from customers where state ="NV" and country="USA" and creditLimit > 5000;

-- JOINS
-- display the first and last name of all employees along with their office address
SELECT lastName,firstName, city, addressLine1, addressLine2 FROM employees join offices
ON employees.officeCode = offices.officeCode;

-- display the firstName, lastName, city and office code
-- NOTE: because tehre are two officeCode columns, we have to specify which table to use
SELECT firstName,lastName, city, employees.officeCode FROM
    employees JOIN offices on employees.officeCode = offices.officeCode

-- same as above, but only from USA and order by the first name in ASCENDING order
-- THIS METHOD OF JOIN IS KNOWN AS INNER JOIN
SELECT firstName,lastName, city, employees.officeCode 
FROM employees JOIN offices on employees.officeCode = offices.officeCode
    where country = "USA"
	ORDER BY firstName;

-- count how many customers have sales rep
-- due to inner join, for a row in the left hand table to appear in the joined table
-- it must have a corresponding row in the right hand table
-- join by default is an inner join
select count(*) from customers join employees 
on customers.salesRepEmployeeNumber = employees.employeeNumber

-- left join is useful if comprehensive report on customers is required
-- show all customers with their sales rep, even for customers with no sales rep
select * from customers left join employees 
on customers.salesRepEmployeeNumber = employees.employeeNumber

-- AGGREGATES
-- find the avg of creditlimit among all customers
SELECT AVG(creditLimit) FROM customers;

-- count
SELECT COUNT(*) FROM customers;

-- max 
SELECT COUNT(creditLimit) FROM customers;

-- minimum
SELECT MIN(creditLimit) FROM customers;

-- find customer with min creditLimit that doesn't have 0 creditLimit
SELECT MIN(creditLimit) FROM customers
WHERE creditLimit > 0;

-- SELECT by date
-- Note, works for data type date ONLY
-- Not for varchar data types.
SELECT * FROM payments where paymentDate > "2004-04-01"
SELECT * FROM payments where paymentDate >= "2004-04-01" and paymentDate <= "2004-04-30"

-- extract out the day, month and year of the paymentDate
SELECT YEAR(paymentDate), MONTH(paymentDate), DAY(paymentDate), amount from payments;

-- find the total amount paid out in the month of June across all years
SELECT sum(amount) from payments where month(paymentDate) = 6;

--
SELECT officeCode, count(*) from employees
    group by officeCode;

-- show how many country there are per country
SELECT country,count(*) from customers GROUP BY country

-- show the avg credit limit per country
SELECT country,avg(creditLimit) from customers GROUP BY country


-- ORDER OF QUERY. 
-- 1st) FROM, JOIN, ON 2) WHERE, 3) GROUPBY, 4) SELECT, 5) HAVING
SELECT employees.officeCode, addressLine1, addressLine2, count(*) FROM employees JOIN offices
ON employees.officeCode = offices.officeCode
WHERE country="USA"
GROUP BY officeCode, addressLine1, addressLine2
HAVING count(*) > 4


-- ORDER OF SEQUENCE
-- FROM, WHERE, GROUP BY, SELECT, HAVING, ORDER BY, LIMIT
SELECT count(*), products.productCode, productName FROM orderdetails
JOIN products on products.productCode = orderdetails.productCode
where productLine = "Classic Cars"
group by productCode
having count(*) >= 28
order by count(*) DESC
limit 10;


-- SUB-QUERIES
-- finding customers with above avg credit Limit
SELECT * FROM customers 
WHERE creditLimit > (select avg(creditLimit) from customers);

-- Find all products that have not been ordered before
SELECT * from products WHERE productCode 
not in (select distinct(productCode) from orderdetails)

-- Find all customers that doesn't have a sales rep
SELECT * FROM customers WHERE customerNumber NOT IN(
SELECT customerNumber FROM customers WHERE salesRepEmployeeNumber IS NOT NULL);

-- example 4
SELECT employees.employeeNumber, employees.firstName, employees.lastName, SUM(amount) FROM employees JOIN customers
ON employees.employeeNumber = customers.salesRepEmployeeNumber
JOIN payments
ON customers.customerNumber = payments.customerNumber
GROUP BY employees.employeeNumber, employees.firstName, employees.lastName
HAVING sum(amount) > (SELECT sum(amount) * 0.1 from payments);

-- Always start from subquery clauses

-- Best product sold during year 2003 march
SELECT productCode, sum(quantityOrdered) FROM orderDetails
JOIN orders on orderdetails.orderNumber = orders.orderNumber
WHERE year(orderDate) = "2003" and month(orderDate) = "3"
GROUP BY productCode
ORDER BY sum(quantityOrdered) DESC
limit 1

-- BONUS: find the best selling product for each year and month:
SELECT productCode, year(orderDate) as orderYear, month(orderDate) as orderMonth, sum(quantityOrdered) FROM orderDetails
JOIN orders on orderdetails.orderNumber = orders.orderNumber
GROUP BY productCode, month(orderDate), year(orderDate)
HAVING productCode = (
    select productCode, sum(quantityOrdered) from orderdetails
    join orders on orderdetails.orderNumber = orders.orderNumber
    where year(orderDate)= orderYear and month(orderDate)=orderMonth
    group by productCode
    ORDER BY sum(quantityOrdered) DESC
    LIMIT 1;
)
ORDER BY year(orderDate), month(orderDate)


-- show all products, and for each product,
-- display the total quantity ordered and
-- and the customer whom ordered the most of that product
SELECT * from
(
  select productCode, sum(quantityOrdered) from orderdetails
	group by productCode
) as t1
JOIN
(
  select productCode as outerProductCode, customerNumber
from orders join orderdetails
 on orders.orderNumber = orderdetails.orderNumber
group by productCode, customerNumber
having (productCode, customerNumber) = (
  
SELECT productCode, customerNumber FROM orders JOIN orderdetails
 on orders.orderNumber = orderdetails.orderNumber
 where productCode=outerProductCode
 group by customerNumber, productCode
 order by sum(quantityOrdered) DESC
 limit 1
 ) 
)
 as t2
 on t1.productCode = t2.outerProductCode