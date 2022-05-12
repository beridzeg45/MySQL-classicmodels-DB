#Many to many relationship
-- List products sold by order date.
select productname, date(orderDate) as orderdate
from products
join orderdetails
using(productcode)
join orders
using (ordernumber)
order by orderDate;

-- List the order dates in descending order for orders for the 1940 Ford Pickup Truck.
select productname,orderNumber,date(orderdate) as orderdate
from orders
join orderdetails
using(ordernumber)
join products
using(productcode)
where productName="1940 ford pickup truck"
order by 3 desc, 2 asc;

-- List the names of customers and their corresponding order number where a particular order from that customer has a value greater than $25,000?
select customerName,orderNumber, round(sum(quantityOrdered*priceEach)) as value
from customers
join orders
using(customernumber)
join orderdetails
using(ordernumber)
group by ordernumber
having value >25000
order by 3,2;

-- Are there any products that appear on all orders?
select productcode from
(select productcode, count(orderNumber) as count
from orderdetails
group by productCode
order by 2 desc) as view
where count =
(select count(distinct ordernumber)
from orderdetails);

-- List the names of products sold at less than 80% of the MSRP.
select distinct productname, priceEach, MSRP
from orderdetails
join products
using (productcode)
where priceEach<MSRP*0.8
order by 1;

-- Reports those products that have been sold with a markup of 100% or more (i.e.,  the priceEach is at least twice the buyPrice)
select distinct productName
from products
join orderdetails
using(productcode)
where priceEach>=2*buyPrice;

-- List the products ordered on a Monday.
select productname, orderNumber
from orderdetails
join orders
using (ordernumber)
join products
using(productcode)
where dayname(orderdate)="monday"
order by 1,2;

-- What is the quantity on hand for products listed on 'On Hold' orders?
select sum(quantityInStock)
from orderdetails
join orders
using(ordernumber)
join products
using(productcode)
where status="on hold";
