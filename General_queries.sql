#General queries
-- Who is at the top of the organization (i.e.,  reports to no one).
select concat(firstname," ",lastname) as CEO
from employees
where reportsTo is null;

-- Who reports to William Patterson?
select *
from employees
where reportsTo = 
(select employeeNumber from employees where firstName="william" and lastName="patterson");
#second way(self join)
select concat(e.firstname," ",e.lastname) as employee
from employees e
join employees m 
on e.reportsTo=m.employeeNumber
where m.firstName="william" and m.lastName="patterson";

-- List all the products purchased by Herkku Gifts.
select distinct productname as "purchased by Herkku Gifts"
from orderdetails
join orders 
using (ordernumber)
join products
using(productcode)
where customerNumber=
(select customerNumber from customers where customerName="herkku gifts")
order by 1;

-- Compute the commission for each sales representative, assuming the commission is 5% of the value of an order.
-- Sort by employee last name and first name.
select employeeNumber, concat(firstname," ",lastname) as employee,
 concat(format(sum(quantityOrdered*priceEach)*0.05,2)," $") as commission
from orderdetails
join orders
using(ordernumber)
join customers
using(customernumber)
join employees
on customers.salesRepEmployeeNumber=employees.employeeNumber
group by employeeNumber
order by 1;

-- What is the difference in days between the most recent and oldest order date in the Orders file?
select datediff(max(orderdate),min(orderdate)) as diff
from orders;

-- Compute the average time between order date and ship date for each customer ordered by the largest difference.
select customerNumber, customername, round(avg(datediff(shippeddate,orderdate)),1) as days
from orders
join customers
using(customernumber)
group by customerNumber
order by 3 desc;


-- What is the value of orders shipped in August 2004? (Hint).
select  format(sum(quantityOrdered*priceEach),2) as value
from orderdetails
join orders
using(ordernumber)
where year(shippeddate)=2004 and 
monthname(shippeddate)="august";
#or
#where shippedDate between "2004-08-01" and "2004-08-31"
#or 
#where shippedDate >="2004-08-01" and shippedDate<="2004-08-31"

-- Compute the total value ordered, total amount paid, and their difference for each customer for orders placed in 2004 and payments received in 2004 
select v.customernumber, format(v.ordered,0) as ordered, format(payed,0) as payed,
 format(ordered-payed,0) as difference,if(round(ordered-payed)>0,"debt","no debt") as status 
 from
(select customerNumber, sum(quantityOrdered*priceEach) as ordered
from orderdetails
join orders
using(ordernumber)
where year(orderDate)=2004
group by customerNumber 
order by 1 asc) as v
join
(select customerNumber, sum(amount) as payed
from payments
where year(paymentdate)=2004
group by customerNumber
order by 1) as a
using(customernumber);
 
-- List the employees who report to those employees who report to Diane Murphy.
--  Use the CONCAT function to combine the employee's first name and last name into a single field for reporting.
select concat(firstname," ",lastname) as employee
from employees
where reportsTo in 
(select employeeNumber
from employees
where reportsTo=(select employeeNumber from employees where firstName="diane" and lastName="murphy"));


-- What is the percentage value of each product in inventory sorted by the highest percentage first
select productCode, format(quantityInStock*MSRP,0) as value,
 concat(format((quantityInStock*MSRP/(select sum(quantityInStock*MSRP) from products)*100),2)," %") as percent
from products
order by 3 desc;

-- What is the value of orders shipped in August 2004? 
select concat(format(sum(quantityOrdered*priceeach),0)," $") as value
from orders
join orderdetails
using(ordernumber)
where year(shippeddate)=2004 and month(shippeddate)=8;

-- What is the ratio the value of payments made to orders received for each month of 2004.
-- (i.e., divide the value of payments made by the orders received)?
select o.*, payments_made, round(payments_made/orders_recieved,2) as ratio
from
(select monthname(orderdate) as month, format(sum(quantityOrdered*priceEach),0) as "orders_recieved"
from orders
join orderdetails
using(ordernumber)
where year(orderdate)=2004
group by monthname(orderdate)
order by orderdate) as o
join
(select monthname(paymentdate) as month, format(sum(amount),0) as "payments_made"
from payments
where year(paymentdate)=2004
group by monthname(paymentdate)
order by paymentDate) as p
using(month)
order by ratio desc;

-- What is the difference in the amount received for each month of 2004 compared to 2003?
select a.*,amount2004, round(amount2004-amount2003,0) as difference,
if(amount2004-amount2003>0,"UP","DOWN") as progress
from
(select monthname(paymentdate) as month, round(sum(amount),0) as amount2003
from payments
where year(paymentDate)=2003
group by monthname(paymentdate)
order by paymentdate) as a
join 
(select monthname(paymentdate) as month, round(sum(amount),0) as amount2004
from payments
where year(paymentDate)=2004
group by monthname(paymentdate)
order by paymentdate) as b
using(month);

-- find out the most popular products that were bought with productcode = S10_2016
select a.productcode, count(*) as count 
from orderdetails a
join (select distinct orderNumber from orderdetails where productCode = "S10_2016") b on (a.orderNumber = b.orderNumber)
where a.productCode != "S10_2016" 
group by a.productCode 
order by count desc;

#second way(views)
drop view if exists a;
create view a as
select *
from orderdetails
where orderNumber in
(select distinct ordernumber
from orderdetails
where productCode="S10_2016");

select productCode, count(ordernumber)
from a
join products using(productcode)
group by productcode
having productCode!="S10_2016"
order by 2 desc limit 5;


-- ABC reporting: Compute the revenue generated by each customer based on their orders.
-- Also, show each customer's revenue as a percentage of total revenue. Sort by customer name.
with a as
(select customerName, sum(quantityOrdered*priceEach) as revenue
from customers
left join orders using(customernumber)
left join orderdetails using(ordernumber)
group by 1)
select customername, concat(round(revenue/(select sum(revenue) from a)*100,1)," %") as percent
from a
order by 1;

-- Compute the profit generated by each customer based on their orders. Also, show each customer's profit as a percentage of total profit.
--  Sort by profit descending.
with a as
(select customername, sum(quantityOrdered*(priceEach-buyPrice)) as profit
from customers
left join orders using(customernumber)
left join orderdetails using(ordernumber)
left join products using(productcode)
group by customerName
order by sum(quantityOrdered*(priceEach-buyPrice)) desc)
select customername, format(profit,0) as profit_, 
concat(round(profit/(select sum(profit) from a)*100,2)," %") as percent_of_all_profit
from a
order by profit desc;


-- Compute the revenue generated by each sales representative based on the orders from the customers they serve.
select firstName,lastName, concat(format(sum(quantityOrdered*priceEach),0)," $") as revenue
from employees e
join customers c on e.employeeNumber=c.salesRepEmployeeNumber
join orders using(customernumber)
join orderdetails using(ordernumber) 
group by employeeNumber;

-- Compute the profit generated by each sales representative based on the orders from the customers they serve. Sort by profit generated descending.
select employeeNumber, firstName,lastName, concat(format(sum(quantityOrdered *(priceEach-buyPrice)),0)," $") as profit
from employees e 
join customers c on e.employeeNumber=c.salesRepEmployeeNumber
join orders using(customerNumber)
join orderdetails using(orderNumber)
join products using(productCode) 
group by employeeNumber
order by sum(quantityOrdered *(priceEach-buyPrice)) desc;

-- Compute the revenue generated by each product, sorted by product name.
select productName, round(sum(quantityOrdered*priceEach),2) as revenue
from orderdetails
right join products
using(productcode)
group by productCode
order by productName asc;

-- Compute the profit generated by each product line, sorted by profit descending.
select productLine, round(sum(quantityOrdered*(priceEach-buyPrice)),2) as profit
from orderdetails
join products
using(productcode)
group by productLine
order by 2 desc;

-- Same as Last Year (SALY) analysis: Compute the ratio for each product of sales for 2003 versus 2004.
select a.*,b.percent2004, if(percent2004>percent2003,"increase","decrease") as progress
from
(select productCode, 
round(sum(quantityOrdered*priceEach)/
(select sum(quantityOrdered*priceEach) from orderdetails join orders using(ordernumber) where year(orderdate)=2003)
*100,2) as percent2003
from orderdetails
join orders
using(ordernumber)
where year(orderdate)=2003
group by productCode) as a 
join
(select productCode, 
round(sum(quantityOrdered*priceEach)/
(select sum(quantityOrdered*priceEach) from orderdetails join orders using(ordernumber) where year(orderdate)=2004)
*100,2) as percent2004
from orderdetails
join orders
using(ordernumber)
where year(orderdate)=2004
group by productCode) as b
using(productcode)
order by productCode;

-- Compute the ratio of payments for each customer for 2003 versus 2004.
select customername,round(amount2003/(amount2003+amount2004),2) as ratio2003,round(amount2004/(amount2003+amount2004),2) as ratio2004
from customers
left join
(select customername,sum(amount) as amount2003
from customers
left join payments using(customernumber)
where year(paymentdate)=2003
group by customerName) as a using(customername)
left join 
(select customername,sum(amount) as amount2004
from customers
left join payments using(customernumber)
where year(paymentdate)=2004
group by customerName) as b using(customername);

-- Find the products sold in 2003 but not 2004.
Select productcode
from orderdetails
join orders
using(ordernumber)
where year(orderdate)=2003
and productCode not in
(select distinct productcode
from orderdetails
join orders
using(ordernumber)
where year(orderdate)=2004);

-- Find the customers without payments in 2003.
select distinct customerName
from customers
left join payments
using(customernumber)
where customerNumber not in
(select distinct customerNumber from payments where year(paymentdate)=2003)
