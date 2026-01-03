# Library Management System Project

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_project`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/Md-Rifat-Sarker2/SQL_Library_Management_System/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/Md-Rifat-Sarker2/SQL_Library_Management_System/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_project`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_project;

--creating branch table
drop table if exists branch;
create table branch
	(
            branch_id varchar(10) primary key,	
            manager_id varchar(10),
            branch_address varchar(55),
            contact_no varchar(10)
	);
alter table branch
alter column contact_no type varchar(20);
--creating employees table
drop table if exists employees;
create table employees
	(
            emp_id varchar(10) primary key,
            emp_name varchar(25),
            position varchar(15),
            salary int,
            branch_id varchar(25) --FK
	);

--creating books table
drop table if exists books;
create table books
	(
            isbn varchar(20) primary key,	
            book_title varchar(75),
            category varchar(10),
            rental_price float,
            status varchar(15),	
            author varchar(35),	
            publisher varchar(55)
	);
alter table books
alter column category type varchar(20);

--creating memebers table
drop table if exists members;
create table members
	(
            member_id varchar(10) primary key,
            member_name varchar(25),
            member_address varchar(75),
            reg_date date
	);

--creating issued_status table
drop table if exists issued_status;
create table issued_status
	(
            issued_id varchar(10) primary key,
            issued_member_id varchar(10), --FK
            issued_book_name varchar(75),
            issued_date date,
            issued_book_isbn varchar(25), --FK
            issued_emp_id varchar(10) --FK
	);

--creating return_status table
drop table if exists return_status;
create table return_status
	(
            return_id varchar(10) primary key,
            issued_id varchar(10),
            return_book_name varchar(75),
            return_date date,
            return_book_isbn varchar(20)
	);

--Foreign key
alter table issued_status
add constraint fk_members
foreign key (issued_member_id)
references members(member_id);

alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);

alter table issued_status
add constraint fk_employees
foreign key (issued_emp_id)
references employees(emp_id);

alter table employees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

alter table return_status
add constraint fk_issued_status
foreign key (issued_id)
references issued_status(issued_id);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into books (isbn,book_title,category,rental_price,status,author,publisher)
values 
	(
            '978-1-60129-456-2', 
            'To Kill a Mockingbird', 
            'Classic', 
            6.00, 
            'yes', 
            'Harper Lee', 
            'J.B. Lippincott & Co.'
	);
```
**Task 2: Update an Existing Member's Address**

```sql
update members
set member_address = '125 Main St'
where member_id = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
delete from issued_status
where issued_id = 'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select * from issued_status
where issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select 
            issued_emp_id,
            count(*) as total_book_issued
from issued_status
group by issued_emp_id
having count(issued_id) >1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table book_cnts
as
select 
	b.isbn,
	b.book_title,
	count (ist.issued_id) as no_issued
from books as b
join
issued_status ist
on ist.issued_book_isbn = b.isbn
group by 1,2;

select * from book_cnts;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category (Classic)**:

```sql
select * from books
where category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select 
	b.category,
	count(*),
	sum(b.rental_price)
from books b
join issued_status ist
on ist.issued_book_isbn = b.isbn
group by 1;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
select *
from members
where reg_date>=current_date - interval '650 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select 
	e1.*,
	b.manager_id,
	e2.emp_name
from employees e1
join branch b
on b.branch_id = e1.branch_id
join employees e2
on b.manager_id = e2.emp_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
create table books_price_greater_than_7
as
select * from books
where rental_price>7;

select * from books_price_greater_than_7;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
select 
	distinct ist.issued_book_name
from issued_status ist
left join 
return_status rst
on rst.issued_id = ist.issued_id
where rst.return_id is null;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM 
	issued_status as ist
	JOIN 
	members as m
    ON m.member_id = ist.issued_member_id
	
	JOIN 
	books as bk
	ON bk.isbn = ist.issued_book_isbn
	
	LEFT JOIN 
	return_status as rs
	ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

--Store Procedures
create or replace procedure add_return_record(p_return_id varchar(10),p_issued_id varchar(10),p_book_quality varchar(15))
language plpgsql
as $$

declare 
	v_isbn varchar(50);
	v_book_name varchar(80);
	
begin
	--inserting into returns based on user inputs
	insert into return_status(return_id,issued_id,return_date,book_quality)
	values
		(p_return_id,p_issued_id,current_date,p_book_quality);

	--store isbn based on user input
	select 
		issued_book_isbn,
		issued_book_name
		into
		v_isbn,
		v_book_name
	from issued_status
	where issued_id=p_issued_id;

	--Update book information
	update books
	set status='yes'
	where isbn=v_isbn;

	--show meeage
	raise notice 'Thank you for returning the books: %',v_book_name;
end;
$$

-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

--Calling function
call add_return_record('RS138','IS135','Good');
call add_return_record('RS148', 'IS140', 'Good');

```


**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
create table branch_reports
as
select 
	b.branch_id,
	b.manager_id,
	count(ist.issued_id) as number_book_issued,
	count(rs.return_id),
	sum(bk.rental_price) as total_revenue
from 
	issued_status as ist
	join 
	employees as e
	on e.emp_id = ist.issued_emp_id

	join
	branch as b
	on b.branch_id = e.branch_id
	
	left join
	return_status rs
	on rs.issued_id = ist.issued_id

	join
	books as bk
	on bk.isbn = ist.issued_book_isbn
	
	group by 1,2;


select * from branch_reports;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

create table active_members
as
select * from members
where member_id in (select 
					     distinct issued_member_id
					from issued_status
					where issued_date>= current_date - interval '2 month');

select * from active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
select 
	e.emp_name,
	b.*,
	count(rst.issued_id)
from 
	issued_status as rst
	join
	employees as e
	on rst.issued_emp_id = e.emp_id

	join 
	branch as b
	on b.branch_id = e.branch_id
group by 1,2
order by 6  desc
limit 3;
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
```sql
select 
	m.member_name,
	count(rs.book_quality) as total_damage_count
from  
	issued_status as rst
	join 
	members as m
	on
	m.member_id = rst.issued_member_id

	join
	return_status as rs
	on
	rs.issued_id = rst.issued_id
where rs.book_quality ='Damaged'
group by 1;
```


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

create or replace procedure 
issue_book(p_issued_id varchar(10), p_issued_member_id varchar(10),p_issued_book_isbn varchar(25),p_issued_emp_id varchar(10))
language plpgsql
as $$

declare 
	v_status varchar(15);
	
begin
	--cheacking if book is avaiable 'yes'
	select 
		status
		into 
		v_status
	from books
	where isbn=p_issued_book_isbn;

	--Condidion
	if v_status = 'yes' then 
		--inserting records
		insert into issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
		values
			(p_issued_id,p_issued_member_id,current_date,p_issued_book_isbn,p_issued_emp_id);

		--updating records
		update books
			set status = 'no'
		where isbn = p_issued_book_isbn;
		
		raise notice 'Book records added successfully for book isbn : %',p_issued_book_isbn;

	else
		raise notice 'Sorry to inform you the book you have requested is unavaiable book isbn : %',p_issued_book_isbn;
	end if;

end;
$$

call issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
call issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/Md-Rifat-Sarker2/SQL_Library_Management_System.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Md Rifat sarker

For more information about me, please connect with following link:

- **FaceBook**: [Profile Link](https://www.facebook.com/md.rifat.sarker.268451/)
- **Instagram**: [Profile Link](https://www.instagram.com/md_rifat_sarker/)
- **LinkedIn**: [Profile Link](https://www.linkedin.com/in/mdrifatsarker/)

Thank you for your support, and I look forward to connecting with you!
