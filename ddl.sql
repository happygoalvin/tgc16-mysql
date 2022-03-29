-- create new database
create database swimming_school
-- end with ; 
-- check current selected database
select DATABASE();

-- to switch database
use swimming_school

-- create table
-- <name of column> <data type>
create table parents(
    parent_id int unsigned auto_increment primary key,
    first_name varchar(200) not null,
    last_name varchar(200) not null
) engine = innodb;
-- `engine = innodb` is for FK to work

-- show all tables
show tables;

-- insert
-- insert into <table name> (<column 1>, <column 2>,...) values (value 1, value 2)
insert into parents (first_name, last_name) values ("Ah Kow", "Tan");

-- show all rows from a table
select * from parents;

-- insert multiple
insert into parents (first_name, last_name) values
    ("Chu Kang", "Phua"),
    ("Ah Teck", "Tan"),
    ("See Mei", "Liang");

-- creating the students table
create table students (
    student_id int unsigned primary key auto_increment,
    name varchar(45) not null,
    swimming_level varchar(45),
    date_of_birth date
) engine = innodb;

-- Add in a FK
-- note the data type have to be exact same as the data type we're referencing.
-- i.e int unsigned for parents has to match int unsigned for students
-- step 1: create the column for the foreign key
alter table students add column parent_id int unsigned;

-- step 2: setup the foreign key
alter table students add constraint fk_students_parents
    foreign key (parent_id) references parents(parent_id);

-- insert in some students
insert into students (name, swimming_level, date_of_birth, parent_id)
 values ('Xiao Kow', 'beginner', '2010-09-10', 4);

-- Update
update students set swimming_level='intermediate' WHERE student_id=1;

-- Delete
delete from students WHERE student_id=1;

-- To rename a column
alter table students rename column name to first_name;

-- To rename a table
rename table students to swimming_students;
