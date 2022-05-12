#Regular expressions
-- Find products containing the name 'Ford'.
select *
from products
where productname like "%ford%";
-- List products ending in 'ship'.
select *
from products
where productName like "%ship";

-- Report the number of customers in Denmark, Norway, and Sweden.
select customerName, country
from customers
where country in ("denmark","norway","sweden");

-- What are the products with a product code in the range S700_1000 to S700_1499?
select *
from products
where productCode between "s700_1000" and "s700_1499";

-- Which customers have a digit in their name?
select *
from customers
where customerName regexp "[1-9]";

-- List the names of employees called Dianne or Diane.
select *
from employees
where firstName regexp ("diane|dianne") or lastName regexp ("diane|dianne");

-- List the products containing ship or boat in their product name.
select *
from products
where productName regexp ("ship|boat");
#second way
select *
from products
where productName like "%ship%" or productName like "%boat%";

-- List the products with a product code beginning with S700.
select *
from products
where productCode like "s700%";
#second way
select *
from products
where productCode regexp "^s700";

-- List the names of employees called Larry or Barry.
select *
from employees
where firstName regexp ("larry|barry") or lastName regexp("larry|barry");

-- List the names of employees with non-alphabetic characters in their names.
select *
from customers
where customerName  regexp '[^a-zA-Z]' and customerName not regexp " ";


-- List the vendors whose name ends in Diecast
select productVendor
from products
where productVendor like "%diecast";
