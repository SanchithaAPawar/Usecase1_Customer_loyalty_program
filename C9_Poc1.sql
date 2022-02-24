create table members
(
cid varchar2(20)primary key,
jdate date
);
create table menu
(
pid numeric(10) primary key,
pname varchar(20),
price numeric(10)
);

CREATE TABLE sales
(
cid varchar(1) REFERENCES members(cid),
odate date,
pid int REFERENCES menu(pid)
);
insert into menu values (1,'sushi',10);
insert into menu values (2,'curry',15);
insert into menu values (3,'ramen',12);

insert into members values ('A','07/jan/2021');
insert into members values ('B','09/jan/2021');
insert into members values ('C','07/jan/2021');


select * from members;




INSERT ALL
INTO SALES VALUES ('A',to_date('2021-01-01','YYYY-MM-DD'),1)
INTO SALES VALUES ('A',to_date('2021-01-01','YYYY-MM-DD'),2)
INTO SALES VALUES ('A',to_date('2021-01-07','YYYY-MM-DD'),2)
INTO SALES VALUES ('A',to_date('2021-01-10','YYYY-MM-DD'),3)
INTO SALES VALUES ('A',to_date('2021-01-11','YYYY-MM-DD'),3)
INTO SALES VALUES ('A',to_date('2021-01-11','YYYY-MM-DD'),3)
INTO SALES VALUES ('B',to_date('2021-01-01','YYYY-MM-DD'),2)
INTO SALES VALUES ('B',to_date('2021-01-02','YYYY-MM-DD'),2)
INTO SALES VALUES ('B',to_date('2021-01-04','YYYY-MM-DD'),1)
INTO SALES VALUES ('B',to_date('2021-01-11','YYYY-MM-DD'),1)
INTO SALES VALUES ('B',to_date('2021-01-16','YYYY-MM-DD'),3)
INTO SALES VALUES ('B',to_date('2021-02-01','YYYY-MM-DD'),3)
INTO SALES VALUES ('C',to_date('2021-01-01','YYYY-MM-DD'),3)
INTO SALES VALUES ('C',to_date('2021-01-01','YYYY-MM-DD'),3)
INTO SALES VALUES ('C',to_date('2021-01-07','YYYY-MM-DD'),3)
select * from DUAL;

select * from sales;

select * from menu;
--1) What is the total amount each customer spent at the restaurant? 
select s.cid,sum(m.price) as totalspent from sales s join menu m on s.pid=m.pid group by s.cid; 

--2) How many days has each customer visited the restaurant?



select t.cid,count(totalTimeVisited) as tVisit from
(select cid,count(odate) as totalTimeVisited 
from sales  group by cid,odate) t 
group by cid 
order by cid ;



--3) What was the first item from the menu purchased by each customer?

select ft.cid,m.pid from
(select s.*,dense_rank() over(order by odate asc)AS dnk FROM sales s) ft 
join menu m on ft.pid=m.pid
where ft.dnk=1 order by ft.cid;

--4) What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.pname, mpi.cnt from
(select s.pid,count(s.pid) as cnt from sales s group by s.pid order by cnt desc) mpi 
join menu m
on mpi.pid = m.pid where rownum = 1;

--5) Which item was the most popular for each customer? 



select * from
(select t.cid,m.pid,t.cnt,rank() over (partition by t.cid order by cid asc,cnt desc) as rnk 
from (select cid,pid,count(pid) cnt from sales group by cid,pid order by cid asc,cnt desc) t
join menu m 
on t.pid=m.pid)where rnk=1;











--6) Which item was purchased first by the customer after they became a member? 

select t.cid,m.pname from
(select s.cid,s.pid,s.odate,rank() over(partition by s.cid order by s.odate ASC) as rnk
from sales s join members mem on s.cid = mem.cid where s.odate >= mem.jdate) t join menu m
on t.pid = m.pid where t.rnk= 1;

select s.cid,s.pid,s.odate,rank() over(partition by s.cid order by s.odate ASC)as rnk
from sales s;


select s.cid,s.pid,s.odate,rank() over(partition by s.cid order by s.odate ASC) as rnk
from sales s join members mem on s.cid = mem.cid where s.odate >= mem.jdate;

SELECT * FROM sales;


--7) Which item was purchased just before the customer became a member?


select t.cid,m.pname from
(select s.cid,s.pid,s.odate,rank() over(partition by s.cid order by s.odate desc) as rnk
from sales s join members mem on s.cid = mem.cid where s.odate < mem.jdate) t join menu m
on t.pid = m.pid where t.rnk= 1;


--8) What is the total items and amount spent for each member before they became a member?

select t.cid,count(m.pid) as cnt,sum(m.price) as tt from
(select s.cid,s.pid,s.odate,rank() over(partition by s.cid order by s.odate desc) as rnk
from sales s join members mem on s.cid = mem.cid where s.odate < mem.jdate) t join menu m
on t.pid = m.pid group by t.cid;

--9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select * from menu;
select cid,sum(points) from 
(select s.cid,
(
case m.price
when 10 then m.price*20 
else 10*m.price
end
) as points from sales s join menu m on s.pid=m.pid) group by cid order by cid;


--In the first week after a customer joins the program (including their join date) they earn
--2x points on all items, not just sushi - how many points do customer A and B have at the
--end of January?

select * from sales;
select cid,sum(points) as spoints from
(select s.cid,
(
case 
when s.odate between mem.jdate and mem.jdate+6 then m.price*20
else m.price*10 
END
) AS points 
from sales s join members mem on s.cid=mem.cid
join menu m on s.pid=m.pid) group by cid ;
select * from emp;  