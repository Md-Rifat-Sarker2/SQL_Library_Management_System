--Advance SQL Task

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
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

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
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

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and 
the total revenue generated from book rentals.
*/
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

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book 
in the last 2 months.
*/
create table active_members
as
select * from members
where member_id in (select 
					     distinct issued_member_id
					from issued_status
					where issued_date>= current_date - interval '2 month');

select * from active_members;

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, 
and their branch.
*/
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

/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, and the number of times they've issued damaged books.
*/

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

/*
Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/
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










