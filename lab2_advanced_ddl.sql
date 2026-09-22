CREATE DATABASE university_main
WITH OWNER = postgres
TEMPLATE = template0
ENCODING = 'UTF8';

CREATE DATABASE university_archive
WITH TEMPLATE = template0
CONNECTION LIMIT = 50;

create database university_test
with IS_TEMPLATE = true
connection limit = 10;


CREATE TABLESPACE student_data
LOCATION '/data/students';

CREATE TABLESPACE course_data
OWNER postgres
LOCATION '/data/courses';

create database university_distributed
with TEMPLATE = template0
encoding = 'LATIN9'
tablespace = student_data;


create table students(
    student_id serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    phone char(15),
    date_of_birth date,
    enrollment_date date,
    gpa numeric(4,2),
    is_active boolean,
    graduation_year smallint
);

create table professors(
    professor_id serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    office_number varchar(20),
    hire_date date,
    salary numeric(15,2),
    is_tenured boolean,
    years_experience integer
);

create table courses(
    course_id serial primary key,
    course_code char(8),
    course_title varchar(100),
    description text,
    credits smallint,
    max_enrollment integer,
    course_fee numeric(10,2),
    is_online boolean,
    created_at timestamp without time zone
);

create table class_schedule (
    schedule_id serial PRIMARY KEY,
    course_id integer,
    professor_id integer,
    classroom varchar(20),
    class_date date,
    start_time time without time zone,
    end_time time without time zone,
    duration interval
);

create table student_records (
    record_id serial PRIMARY KEY,
    student_id integer,
    course_id integer,
    semester varchar(20),
    year integer,
    grade char(2),
    attendance_percentage numeric(5,1),
    submission_timestamp timestamp with time zone,
    last_updated timestamp with time zone
);

ALTER TABLE students
ADD COLUMN middle_name varchar(30),
ADD COLUMN student_status varchar(20),
ALTER COLUMN phone TYPE varchar(20),
ALTER COLUMN student_status SET DEFAULT 'ACTIVE',
ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
ADD COLUMN department_code char(5),
ADD COLUMN research_area text,
ALTER COLUMN years_experience TYPE smallint,
ALTER COLUMN is_tenured SET DEFAULT false,
ADD COLUMN last_promotion_date date;

ALTER TABLE courses
ADD COLUMN prerequisite_course_id integer,
ADD COLUMN difficulty_level smallint,
ALTER COLUMN course_code TYPE varchar(10),
ALTER COLUMN credits SET DEFAULT 3,
ADD COLUMN lab_required boolean DEFAULT false;

ALTER TABLE class_schedule
ADD COLUMN room_capacity integer,
DROP COLUMN duration,
ADD COLUMN session_type varchar(15),
ALTER COLUMN classroom TYPE varchar(30),
ADD COLUMN equipment_needed text;

ALTER TABLE student_records
ADD COLUMN extra_credit_points numeric(4,1),
ALTER COLUMN grade TYPE varchar(5),
ALTER COLUMN extra_credit_points SET DEFAULT 0.0,
ADD COLUMN final_exam_date date,
DROP COLUMN last_updated;


create table departments (
    department_id serial PRIMARY KEY,
    department_name varchar(100),
    department_code char(5),
    building varchar(50),
    phone varchar(15),
    budget numeric(15,2),
    established_year integer
);

create table library_books (
    book_id serial PRIMARY KEY,
    isbn char(13),
    title varchar(200),
    author varchar(100),
    publisher varchar(100),
    publication_date date,
    price numeric(10,2),
    is_available boolean,
    acquisition_timestamp timestamp without time zone
);

create table student_book_loans (
    loan_id serial PRIMARY KEY,
    student_id integer,
    book_id integer,
    loan_date date,
    due_date date,
    return_date date,
    fine_amount numeric(10,2),
    loan_status varchar(20)
);

ALTER TABLE professors ADD COLUMN department_id integer;
ALTER TABLE students ADD COLUMN advisor_id integer;
ALTER TABLE courses ADD COLUMN department_id integer;

CREATE TABLE grade_scale(
    grade_id serial primary key,
    letter_grade char(2),
    min_percentage numeric(5,1),
    max_percentage numeric(5,1),
    gpa_points numeric(3,2)
);

CREATE TABLE semester_calendar (
    semester_id serial primary key,
    semester_name varchar(20),
    academic_year integer,
    start_date date,
    end_date date,
    registration_deadline timestamp with time zone,
    is_current boolean
);

DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
    grade_id serial PRIMARY KEY,
    letter_grade char(2),
    min_percentage numeric(5,1),
    max_percentage numeric(5,1),
    gpa_points numeric(3,2),
    description text
);

DROP TABLE semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id serial primary key,
    semester_name varchar(20),
    academic_year integer,
    start_date date,
    end_date date,
    registration_deadline timestamp with time zone,
    is_current boolean
);

ALTER DATABASE university_test
IS_TEMPLATE = false;

DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup
WITH TEMPLATE = university_main;
