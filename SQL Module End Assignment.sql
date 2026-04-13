-- Analyzing E-Learning Platform Purchases using MySQL --

create database if not exists online_learning_platform_db;
use online_learning_platform_db;

/*-------------------------------------
1.	Table: learners
		Attributes:
○	learner_id (Primary Key)
○	full_name
○	Country

----------------------------------------*/

create table if not exists learners (learner_id int primary key auto_increment,
									 full_name varchar(100) not null,
                                     country varchar(100));
									
					 
create table if not exists courses (course_id int primary key auto_increment,
								    course_name varchar(100) not null,
                                    category varchar(50),
                                    unit_price decimal(10,2));
						
create table if not exists purchases (purchase_id int primary key auto_increment,
									  learner_id int,
									  course_id int,
                                      Quantity int,
                                      purchase_date DATE default (current_date),
                                      foreign key (learner_id) References learners(learner_id),
                                      foreign key (course_id) References courses (course_id));
                                      
                                    
INSERT INTO learners (full_name, country) VALUES 
('John Doe', 'USA'),
('Jane Smith', 'Canada'),
('Arun Kumar', 'India'),
('Maria Garcia', 'Spain'),
('Hans Müller', 'Germany');                    
 
 INSERT INTO learners (full_name, country) VALUES 
('Yuki Tanaka', 'Japan'),
('Chen Wei', 'China'),
('Aisha Bello', 'Nigeria'),
('Mateo Silva', 'Brazil'),
('Sofia Rossi', 'Italy'),
('Liam O’Connor', 'Ireland'),
('Zoe Lefebvre', 'France'),
('Dmitry Volkov', 'Russia'),
('Amara Singh', 'India'),
('Fatima Al-Sayed', 'Egypt');

Select * from learners;

INSERT INTO courses (course_name, category, unit_price) VALUES 
('Python Basics', 'Programming', 49.99),
('Advanced SQL', 'Data Science', 59.99),
('Web Design', 'Design', 39.99),
('Machine Learning', 'Data Science', 89.99);                     
    
INSERT INTO courses (course_name, category, unit_price) VALUES 
('Cybersecurity 101', 'IT', 69.99),
('Digital Marketing', 'Marketing', 29.99),
('Tableau for Data Viz', 'Data Science', 45.00),
('Java Mastery', 'Programming', 74.99),
('Financial Modeling', 'Business', 99.99),
('UX/UI Principles', 'Design', 55.00),
('Cloud Computing', 'IT', 85.00),
('Agile Management', 'Business', 40.00),
('React Framework', 'Programming', 65.00),
('Deep Learning', 'Data Science', 110.00);    
  
Select * from courses; 
  
INSERT INTO purchases (learner_id, course_id, Quantity, purchase_date) VALUES 
(1, 1, 1, '2025-01-10'),
(2, 2, 1, '2025-02-14'),
(3, 1, 2, '2025-03-22'),
(4, 3, 1, '2025-05-05'),
(5, 4, 1, '2025-06-18'),
(1, 4, 1, '2025-08-12'),
(2, 3, 3, '2025-10-09'),
(3, 2, 1, '2025-12-25');                
   
INSERT INTO purchases (learner_id, course_id, Quantity, purchase_date) VALUES 
(6, 5, 1, '2025-01-15'),
(7, 10, 1, '2025-02-20'),
(8, 6, 2, '2025-03-05'),
(9, 14, 1, '2025-04-12'),
(10, 1, 1, '2025-05-30'),
(11, 8, 1, '2025-07-22'),
(12, 12, 1, '2025-09-14'),
(13, 2, 3, '2025-11-01'),
(14, 9, 1, '2025-11-15'),
(15, 11, 2, '2025-12-05');   
   
Select * from purchases;

/*---------------------------------------------------------------------------------------------------------------------
Use SQL INNER JOIN, LEFT JOIN, and RIGHT JOIN to:
●	Combine learner, course, and purchase data.
●	1.Display each learner’s purchase details (course name, category, quantity, total amount, and purchase date).
--------------------------------------------------------------------------------------------------------------------------*/

select l.learner_id, 
l.country, 
l.full_name, 
c.course_name, 
c.category, 
p.Quantity, 
p.purchase_date, 
Round(c.unit_price * p.Quantity, 2) as total_revenue
from purchases p
join courses c on p.course_id = c.course_id
join learners l on p.learner_id = l.learner_id
order by total_revenue desc;

/*-------------------------------------------------------------------------------------
2.Display each learner’s total spending (quantity × unit_price) along with their country.
----------------------------------------------------------------------------------------*/

select l.learner_id, 
l.full_name, 
l.country, 
round(p.Quantity * c.unit_price, 2) as Total_spending
from purchases p 
join courses c on p.course_id = c.course_id
join learners l on p.learner_id = l.learner_id
order by Total_spending desc;

/*-------------------------------------------------------------------
3.Find the top 3 most purchased courses based on total quantity sold
----------------------------------------------------------------------*/

select * from (
select c.course_name, sum(p.Quantity) as Total_quantity_sold,
Dense_rank() over (order by sum(p.Quantity) desc) as rnk
from purchases p 
join courses c on c.course_id = p.course_id
group by c.course_name) as Ranked_table
where rnk <= 3;

/*-----------------------------------------------------------------------------------------------------------------
4.Show each course category’s total revenue and the number of unique learners who purchased from that category.
--------------------------------------------------------------------------------------------------------------------*/

select count(distinct p.learner_id) as unique_learners, 
c.category, 
round(sum(p.Quantity*c.unit_price), 2) as total_revenue
from purchases p 
join courses c on c.course_id = p.course_id
group by c.category 
order by total_revenue desc;

/*---------------------------------------------------------------------------
5.List all learners who have purchased courses from more than one category.
------------------------------------------------------------------------------*/

select l.full_name, count(distinct c.category) as category_count
from learners l
join purchases p on p.learner_id = l.learner_id
join courses c on c.course_id = p.course_id
group by l.full_name
Having category_count > 1;

/*----------------------------------------------------
6.Identify courses that have not been purchased at all.
-------------------------------------------------------*/
select c.course_name, p.purchase_id, p.Quantity 
from courses c 
left join purchases p on p.course_id = c.course_id
where p.purchase_id is null;

/*--------------------------------------------------------------------------------------------------
7.List each country and the Total Revenue generated from that country, sorted from highest to lowest.
------------------------------------------------------------------------------------------------------*/

select l.country, sum(p.Quantity * c.unit_price) as total_revenue 
from learners l
left join purchases p on l.learner_id = p.learner_id
left join courses c on p.course_id = c.course_id
group by l.country
order by total_revenue desc;

/*--------------------------------------------------------------------------------------------------------
8.List all courses that have a unit_price higher than the average price of all courses in the database.
-----------------------------------------------------------------------------------------------------------*/

select round(avg(unit_price), 2) from courses;

select course_name, unit_price 
from courses
where unit_price > (select round(avg(unit_price), 2) from courses);





                     