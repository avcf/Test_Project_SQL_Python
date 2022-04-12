--Create new store 
Create table Store (
	ID nvarchar (10) not null primary key,
	store_name varchar(255) not null,
	store_address varchar(255) not null,
	store_city nvarchar(100) not null,
	check(ID like '___-%')
	);

-- Add info in store
INSERT INTO store (ID,store_name ,store_address,store_city)
values
('Abq-123134','cola mina','235 catress, mari', 'Cali'),
('UYN-156198','Sinda','1245 solda, filan','NZ'),
('JHK-869870','DEZ','56 vlin, cal', 'TD')

--Add store column in orderdetails	
AlTER TABLE orderdetails
add store nvarchar(10) 

--update new store info in orderdetails fof different discount
update OrderDetails
set store ='Abq-123134'
where Discount =0.1

--Display 5 products with the highest unit prices 
--and 5 products with the smallest unit prices
select *from
(select top 5*
from Product p
order by p.UnitPrice desc) as a
union all
select*from
(select top 5*
from Product p
order by p.UnitPrice ) as b
order by UnitPrice desc

---display CustomerID, CustomerName and the number of orders of customers who have the highest number of orders.
declare @i int
select @i=
 max (sol) from(
select Customerid, count (customerid) as sol
from Orders group by CustomerID) as n
select o.CustomerID, c.CustomerName, count (o.customerid)
from Orders o join Customer c
on o.CustomerID=c.ID
group by o.CustomerID, c.CustomerName
having count (o.customerid)= @i

---which order has the longest shipping time and from which store 
declare @y int
select @y = max(shipdate) from
(select datediff(day,orderdate,shipdate) as shipdate from Orders) as ship

with lateship as (
select o.ID, o.OrderDate,o.ShipDate,o.ShipMode,s.store_name,datediff(day,orderdate,shipdate) as shiptime
from Orders o left join OrderDetails od on o.ID=od.OrderID 
	left join Store s on od.store=s.ID
where datediff(day,orderdate,shipdate)=@y
)

---how many late shipment from each store above
select store_name, count(store_name) as number_of_late_shipment
from lateship
group by store_name
order by  number_of_late_shipment desc

---top 5 product name are top purchase, those with same quantity are at same rank

select productid, p.ProductName, quantity,quantity_rank 
from(
	select productid, quantity, dense_RANK () OVER ( ORDER BY quantity DESC) as quantity_rank 
	from(
		select productid, count(Quantity) as quantity
		from OrderDetails 
		group by ProductID) as n) as m left join Product p on m.ProductID=p.ID
where quantity_rank <= 5
order by quantity_rank

-----show profit of stores in years
SELECT store,[2014] as '2014', [2015] as'2015',[2016] as '2016', [2017] as'2017'
FROM   
(SELECT store, profit, datepart(year,o.shipdate)as years
FROM OrderDetails od left join store s on od.store=s.id left join orders o on od.orderid=o.id
) od  
PIVOT  
(sum(profit)  
FOR years IN  
(  [2014] ,[2015] ,[2016],[2017])
) AS pvt  
ORDER BY pvt.store  

---show profit of each top products above follow by store name 

SELECT productid, [Abq-123134] as 'Abq-123134',[UYN-156198] as 'UYN-156198', [JHK-869870] as 'JHK-869870' 
FROM   
(SELECT productid, Store, profit
FROM OrderDetails
where productid in (select productid
from(
	select productid, quantity, dense_RANK () OVER ( ORDER BY quantity DESC) as quantity_rank 
	from(
		select productid, count(Quantity) as quantity
		from OrderDetails 
		group by ProductID) as n) as m left join Product p on m.ProductID=p.ID
where quantity_rank <= 5)
) od  
PIVOT  
(sum(profit)  
FOR store IN  
(  [Abq-123134] ,[UYN-156198] ,[JHK-869870])
) AS pvt  
ORDER BY pvt.productid;  

--- display customer whose lastname start with H and places order in 12/2014 or 11/2014 and shipmode is same day
select c.CustomerName, o.OrderDate,o.ShipMode
from Customer c left join Orders o  on c.ID=o.CustomerID
where CustomerName like '% H%' and datepart(month,o.orderDate) in (11,12) and datepart(year,o.orderDate) =2014  and o.ShipMode='Same Day'

----creare a procedure to check customer is new or old one
create proc checkcustomername @customername nvarchar (255), @result nvarchar(255) output
as
begin
set @result = 
	case 
	when @customername in (select distinct customername from customer) then 'this is an old customer'
	else 'this is a new customer'
	end
end
---example
declare @result  nvarchar(255)
exec checkcustomername 'Adrian Barton',@result output
print @result

---create trigger so when insert in product, display the ProductName and the SubCategoryName, subcategoryid of the products
 create trigger insertproduct 
 on product for insert
 as
 begin
	select i.ProductName,i.SubCategoryID, s.SubCategoryName
	from Product p left join SubCategory s on p.SubCategoryID=s.ID join  inserted i on p.ProductName=i.ProductName
 end
-- example:
insert into Product(ProductName, UnitPrice, SubCategoryID)
values ('Pencil 356', 1.335, 4)

---create procedure to display the number of products in an orderid.
create proc countproduct @orderid nvarchar (100) , @numberofproduct int output
as
begin
set @numberofproduct =
	(select count(productid)
	from OrderDetails
	where OrderID=@orderid)
end
-- example:
declare @t int
exec countproduct 'CA-2014-100678', @t output
print concat('number of products: ',@t)
