--1. How many customer do we have,
select*
from Credittest
--> result show 10,000 rows

--2. How many customer have credit score
select*
from Credittest
where CreditScore is not null
--> result show 8,019 rows

--3. 
---3.1 What is the average loan amount right now
select avg(CurrentLoanAmount) as Average_Current_Loan_Amount
from Credittest
--> result show 11603801.2123

---3.2 which customer has amount of loan > average loan and sort from highest to lowest
declare @y int
select @y= Average_Current_Loan_Amount from(select avg(CurrentLoanAmount) as Average_Current_Loan_Amount from Credittest) as temp

select *
from credittest
where CurrentLoanAmount >@y
order by CurrentLoanAmount
--> result show 1133 rows 
---3.3 but lots of them has current loan amount = 99,999,999. Maybe there are some typo, So let's extract them and see what we can get (@y in 3.2)

select *
from credittest
where CurrentLoanAmount >@y and CurrentLoanAmount < 99999999
order by CurrentLoanAmount
--> 3.4 result is null as average inclued those 99,999,999 values, let's recalculate the avg and extract again 
declare @y int
select @y= Average_Current_Loan_Amount from(select avg(CurrentLoanAmount) as Average_Current_Loan_Amount from Credittest where CurrentLoanAmount <99999999) as temp

select *
from credittest
where CurrentLoanAmount >@y
order by CurrentLoanAmount
-->result show 5008 rows

--4. The number of short term, ratio in total

select count(term) as number_of_short_term, concat (format(count(term)*100/10000,'#,##.00'),'%') as ratio
from Credittest
where term ='Short Term'
-->result: 7295 and 72%

--5. The number of  long term loan ,ratio in total
select count(term) as number_of_Long_term, concat (format(count(term)*100/10000,'#,##.00'),'%') as ratio
from Credittest
where term ='Long Term'
-->result:2705 and 27%

--6. is the one with highest credit score has longest year of credit history
select * from
(select loanid,
case 
when
	 (select YearsofCreditHistory as mb
	 from credittest 
	 where YearsofCreditHistory  in (select max(YearsofCreditHistory) as a from credittest) ) =
	 (select  creditscore as ma
	 from credittest
  	 where creditscore in (select max(CreditScore) as a from credittest)  )
then ' yes'
else 'no'
end as result
from credittest) as c
where result ='yes'
-->result: null

--7. show custid, houseownership name , purpose name,credit score  of those has credit problem total and filer those credit score > avg credit score, order by credit score largest to smalless
select c.CustomerID, r.HomeOwnership,p.Purpose,c.CreditScore
from credittest c left join  Purpose p on c.Purpose=p.ID left join rsadd r on c.HomeOwnership=r.ID
where c.NumberofCreditProblems <>0 
order by CreditScore desc
-->result: 1347 rows

declare @i int
select @i = avg(creditscore) from credittest

select c.CustomerID, r.HomeOwnership,p.Purpose,c.CreditScore
from credittest c left join  Purpose p on c.Purpose=p.ID left join rsadd r on c.HomeOwnership=r.ID
where c.NumberofCreditProblems <>0 and CreditScore >@i
order by CreditScore desc
-->result:69 rows

--8.those with loan purpose : buy house and have taxlien, how is their annual income and how many years have they stay in their job(not null)
select c.CustomerID, c.AnnualIncome, c.Yearsincurrentjob,c.TaxLiens, p.Purpose
from credittest c left join  Purpose p on c.Purpose=p.ID 
where p.Purpose='Buy House' and c.Yearsincurrentjob is not null and c.TaxLiens != 0

--9.insert new loan product
insert into Purpose (id,Purpose)
values ('BT','Beauty Service')

--10. any customer have more than 1 loan, print their info

declare @x int
select @x= number_of_contract from (
	select count(customerid) as number_of_contract
	from credittest
	group by CustomerID
	having count(customerid) >1 ) as b
print @x
-->result: null
