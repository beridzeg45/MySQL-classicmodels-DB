#One to many relationship
-- Report the account representative for each customer.
select customerName, concat(firstName," ",lastname) as representative
from customers c 
left join employees e 
on c.salesRepEmployeeNumber=e.employeeNumber;

-- Report total payments for Atelier graphique.
#With subquery
select concat("$ ",format(sum(amount),2)) as payment
from payments
where customerNumber=
(select customerNumber from customers where customerName="Atelier graphique");
#With join
select concat("$ ",format(sum(amount),2)) as payment
from payments
join customers
using(customernumber)
where customerName="Atelier graphique";

-- Report the total payments by date
select date(paymentdate) as paymentdate,  concat("$ ",format(sum(amount),0)) as payment
from payments
group by paymentDate
order by 1;


-- Report the products that have not been sold.
select *
from products
where productCode not in 
(select productCode from orderdetails);

-- List the amount paid by each customer.
select customerNumber, customername, concat(format(sum(amount),2)," $") as payment
from payments
join customers
using (customernumber)
group by customerNumber;

-- How many orders have been placed by Herkku Gifts?
#With subquery
select count(ordernumber)
from orders
where customerNumber=
(select customerNumber from customers where customerName="herkku gifts");

-- Who are the employees in Boston?
select employeeNumber, firstName, lastName
from employees
join offices
using (officecode)
where city="boston";

#second way 


select employeeNumber, firstName, lastName
from employees
where officecode in 
(select officeCode from offices where city="boston");

-- Report those payments greater than $100,000. Sort the report so the customer who made the highest payment appears first.
select customerNumber, format(sum(amount),2) as amount
from payments
group by customerNumber
having sum(amount)>power(10,5)
order by 2 desc;

-- List the value of 'On Hold' orders.
select  sum(quantityOrdered*priceEach)
from orderdetails
join orders
using(ordernumber)
where status="on hold";
# second way
select  sum(quantityOrdered*priceEach)
from orderdetails
where ordernumber in 
(select orderNumber from orders where status="on hold");

-- Report the number of orders 'On Hold' for each customer.
select customerNumber,status, count(ordernumber)
from orders
right join customers
using (customernumber)
where status="on hold"
group by customerNumber;

select customerNumber, status, if(status="on hold",count(orderNumber),0) as count
from customers c 
left join orders o
using (customernumber)
#where status="on hold"
group by customernumber,status;
