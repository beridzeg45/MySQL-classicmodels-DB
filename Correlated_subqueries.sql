#Correlated subqueries
-- Who reports to Mary Patterson?
select concat(firstname," ",lastname) as employee
from employees
where reportsTo=
(select employeeNumber from employees where firstName="Mary" and lastname="patterson");
#second way(self join)
select concat(e.firstname," ",e.lastname) as employee
from employees e
join employees m
on e.reportsTo=m.employeeNumber
where m.firstName="mary" and m.lastName="patterson";

-- Which payments in any month and year are more than twice the average for that month and year 
-- (i.e. compare all payments in Oct 2004 with the average payment for Oct 2004)?
-- Order the results by the date of the payment. You will need to use the date functions.
select *
from payments p, (select year(paymentdate) as year,monthname(paymentDate) as month,  avg(amount) as average
from payments
group by monthname(paymentdate), year(paymentdate)) as a
where monthname(p.paymentdate)=a.month and
year(paymentdate)=a.year and
p.amount>2*average
order by paymentdate;
#second way
select checknumber, date(paymentdate) as paymentdate,year,month,p.amount, a.amount as avg_for_month, customernumber
from payments p,
(select year(paymentDate) as year,monthname(paymentdate) as month, avg(amount) as amount from payments group by 1,2  order by paymentdate) as a
where year(p.paymentdate)=a.year and monthname(p.paymentdate)=a.month and p.amount>2*a.amount
order by paymentDate;

-- Report for each product, the percentage value of its stock on hand as a percentage of the stock on hand for product line to which it belongs.
-- Order the report by product line and percentage value within product line descending.
-- Show percentages with two decimal places.
select p.productline,productname, quantityInStock,grouped, round(quantityInStock/grouped*100,2) as percent
from products p, (select productline, sum(quantityInStock) as grouped from products group by productline) a
where p.productline=a.productline
order by productline, percent desc;


#Second way
select productCode,  
round(quantityInStock/(select sum(quantityInStock) from products)*100,2) as "percent of total", 
productLine,
round(quantityInStock/(select sum(quantityinstock) from products where productLine=p.productline group by productline)*100,2) as "percent of productline"
from products p;


--  For orders containing more than two products, report those products that constitute more than 50% of the value of the order.
select o.ordernumber, productname, format(quantityOrdered*priceEach,0) as value, format(order_value,0) as order_value
from orderdetails o,
(select orderNumber, sum(quantityOrdered*priceEach) as order_value
from orderdetails
where orderNumber in
(select distinct orderNumber
from orderdetails
group by orderNumber
having count(productCode)>2)
group by orderNumber) a, 
products p
where o.ordernumber=a.orderNumber and quantityOrdered*priceEach>0.5*order_value and o.productcode=p.productCode;

#second way

select *
from orderdetails od
where quantityOrdered*priceEach>
(select sum(quantityOrdered*priceEach) from orderdetails where orderNumber=od.orderNumber  group by orderNumber)*0.5
and orderNumber in
(select ordernumber
from orderdetails
group by orderNumber
having count(productcode)>2);
