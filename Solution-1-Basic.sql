--show dataset
select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;


--PROJECT TASK

--Task 1: Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
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

--Task 2: Update an Existing Member's Address
update members
set member_address = '125 Main St'
where member_id = 'C101';

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id = 'IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id = 'E101';

--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select 
	issued_emp_id,
	count(*) as total_book_issued
from issued_status
group by issued_emp_id
having count(issued_id) >1;

---CTAS
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
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

--Task 7. Retrieve All Books in a Specific Category(Classic)
select * from books
where category = 'Classic';

--Task 8: Find Total Rental Income by Category:
select 
	b.category,
	count(*),
	sum(b.rental_price)
from books b
join issued_status ist
on ist.issued_book_isbn = b.isbn
group by 1;

--Task 9: List Members Who Registered in the Last 650 Days:
select *
from members
where reg_date>=current_date - interval '650 days';

--Task 10: List Employees with Their Branch Manager's Name and their branch details:
select 
	e1.*,
	b.manager_id,
	e2.emp_name
from employees e1
join branch b
on b.branch_id = e1.branch_id
join employees e2
on b.manager_id = e2.emp_id;

--Task 11: Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
create table books_price_greater_than_7
as
select * from books
where rental_price>7;

select * from books_price_greater_than_7;

--Task 12: Retrieve the List of Books Not Yet Returned
select 
	distinct ist.issued_book_name
from issued_status ist
left join 
return_status rst
on rst.issued_id = ist.issued_id
where rst.return_id is null;









