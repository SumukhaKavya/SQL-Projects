drop database if exists library;
create database library;
use library;
create table tbl_borrower(
borrower_CardNo int auto_increment primary key,
borrower_BorrowerName varchar(40),
borrower_BorrowerAddress varchar(100),
borrower_BorrowerPhone varchar(50));
select * from tbl_borrower;
create table tbl_publisher(
publisher_PublisherName varchar(50) primary key,
publisher_PublisherAddress varchar(100),
publisher_PublisherPhone varchar(50));
select * from tbl_publisher;
create table tbl_book(
book_BookID int auto_increment primary key,
book_Title varchar(50),
book_PublisherName varchar(50),
foreign key(book_PublisherName) references tbl_publisher(publisher_PublisherName) on delete cascade);
select * from tbl_book;
create table tbl_book_authors(
book_authors_AuthorID int auto_increment primary key,
book_authors_BookID int not null,
book_authors_AuthorName varchar(50),
foreign key(book_authors_BookID) references tbl_book(book_BookID) on delete cascade);
select * from tbl_book_authors;
create table library_branch(
library_branch_BranchID int auto_increment primary key,
library_branch_BranchName varchar(50),
library_branch_BranchAddress varchar(100));
select * from library_branch;
create table tbl_book_copies(
book_copies_CopiesID int auto_increment primary key,
book_copies_BookID int not null,
book_copies_BranchID int not null,
book_copies_No_Of_Copies int,
foreign key(book_copies_BookID) references tbl_book(book_BookID) on delete cascade,
foreign key(book_copies_BranchID) references library_branch(library_branch_BranchID) on delete cascade);
select * from tbl_book_copies;
create table tbl_book_loans(
book_loans_LoansID int auto_increment primary key,
book_loans_BookID int not null,
book_loans_BranchID int not null,
book_loans_CardNo int not null,
book_loans_DateOut date,
book_loans_DueDate date,
foreign key(book_loans_BookID) references tbl_book(book_BookID) on delete cascade,
foreign key(book_loans_BranchID) references library_branch(library_branch_BranchID) on delete cascade,
foreign key(book_loans_CardNo) references tbl_borrower(borrower_CardNo) on delete cascade);
select * from tbl_book_loans;

-- Task Questions:
-- 1.How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
select temp.book_copies_BookID,temp.book_copies_No_Of_Copies from(
select t1.book_copies_BookID,t1.book_copies_BranchID,t1.book_copies_No_Of_Copies from tbl_book_copies as t1 inner join tbl_book as t2 
on t1.book_copies_BookID=t2.book_BookID
where t2.book_Title="The Lost Tribe") as temp
inner join library_branch on temp.book_copies_BranchID=library_branch.library_branch_BranchID 
where library_branch_BranchName="Sharpstown";

-- 2.How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select temp.book_copies_No_Of_Copies,library_branch.library_branch_BranchName from(
select t1.book_copies_No_Of_Copies,t1.book_copies_BranchID from tbl_book_copies as t1 inner join tbl_book as t2 
on t1.book_copies_BookID=t2.book_BookID
where t2.book_Title="The Lost Tribe") as temp
inner join library_branch on temp.book_copies_BranchID=library_branch.library_branch_BranchID;

-- 3.Retrieve the names of all borrowers who do not have any books checked out.
select t1.borrower_BorrowerName from tbl_borrower as t1 left join tbl_book_loans as t2
on t1.borrower_CardNo=t2.book_loans_CardNo where t2.book_loans_DateOut is null;

-- 4.For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 
select t3.book_Title,t4.borrower_BorrowerName,t4.borrower_BorrowerAddress
from library_branch as t1 inner join tbl_book_loans as t2 on t1.library_branch_BranchID=t2.book_loans_BranchID 
inner join tbl_book as t3 on t3.book_BookID = t2.book_loans_BookID
inner join tbl_borrower as t4 on t4.borrower_CardNo = t2.book_loans_CardNo 
where t1.library_branch_BranchName ="Sharpstown" and t2.book_loans_DueDate="0002-03-18";

-- 5.For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
select t1.library_branch_BranchName, count(t2.book_loans_BookID) as total_number_of_books
 from library_branch as t1 inner join tbl_book_loans as t2
on t1.library_branch_BranchID=t2.book_loans_BranchID
 group by t1.library_branch_BranchName;

-- 6.Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
select t1.borrower_BorrowerName,t1.borrower_BorrowerAddress,count(t2.book_loans_BookID) as number_of_books
from tbl_borrower as t1 inner join tbl_book_loans as t2
on t1.borrower_CardNo=t2.book_loans_CardNo
group by t1.borrower_BorrowerName,t1.borrower_BorrowerAddress
having number_of_books > 5;

-- 7.For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
select t2.book_Title,t3.book_copies_No_Of_Copies from
tbl_book_authors as t1 
inner join tbl_book as t2 on t1.book_authors_BookID=t2.book_BookID
inner join tbl_book_copies as t3 on t3.book_copies_BookID=t2.book_BookID
inner join library_branch as t4 on t3.book_copies_BranchID=t4.library_branch_BranchID
where t1.book_authors_AuthorName="Stephen King" and t4.library_branch_BranchName="Central";