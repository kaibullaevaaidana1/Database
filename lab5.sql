-- Name: Aidana Kaibulla
-- Student ID: 25B031303

--------------------------------------------------------------------------------
-- PART 1: CHECK Constraints
--------------------------------------------------------------------------------

-- Task 1.1: Basic CHECK Constraint
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65), -- age must be between 18 and 65[cite: 48]
    salary NUMERIC CHECK (salary > 0)          -- salary must be greater than 0[cite: 48]
);

-- Task 1.2: Named CHECK Constraint
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    -- Named CHECK constraint to ensure valid discount[cite: 48]
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND
        discount_price > 0 AND
        discount_price < regular_price
    )
);

-- Task 1.3: Multiple Column CHECK
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10), -- num_guests between 1 and 10[cite: 48]
    CONSTRAINT chk_checkout_after_checkin CHECK (check_out_date > check_in_date) -- check_out_date after check_in_date[cite: 48]
);

-- Task 1.4: Testing CHECK Constraints
-- Successful insertion for employees[cite: 49]
INSERT INTO employees VALUES (1, 'Ivan', 'Ivanov', 25, 1200.50);
INSERT INTO employees VALUES (2, 'Anna', 'Smirnova', 40, 2500.00);

-- Failed insertion (violating age and salary):
-- INSERT INTO employees VALUES (3, 'Petr', 'Petrov', 16, -100);
-- Violated constraints: age (16 is out of 18-65 range) and salary (-100 is not > 0)[cite: 49].

-- Successful insertion for products_catalog[cite: 49]
INSERT INTO products_catalog VALUES (1, 'Laptop', 1000.00, 850.00);
INSERT INTO products_catalog VALUES (2, 'Phone', 500.00, 450.00);

-- Failed insertion (violating valid_discount):
-- INSERT INTO products_catalog VALUES (3, 'Tablet', 300.00, 350.00);
-- Violated constraint 'valid_discount' because discount_price (350) > regular_price (300)[cite: 49].

-- Successful insertion for bookings[cite: 49]
INSERT INTO bookings VALUES (1, '2026-11-01', '2026-11-05', 2);
INSERT INTO bookings VALUES (2, '2026-12-10', '2026-12-15', 4);

-- Failed insertion (violating dates and guest count):
-- INSERT INTO bookings VALUES (3, '2026-11-10', '2026-11-05', 12);
-- Violation: check_out_date is before check_in_date, and num_guests (12) > 10[cite: 49].


--------------------------------------------------------------------------------
-- PART 2: NOT NULL Constraints
--------------------------------------------------------------------------------

-- Task 2.1: NOT NULL Implementation
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT, -- can be NULL[cite: 49]
    registration_date DATE NOT NULL
);

-- Task 2.2: Combining Constraints
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),         -- quantity must be >= 0[cite: 49]
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),       -- unit_price must be > 0[cite: 49]
    last_updated TIMESTAMP NOT NULL
);

-- Task 2.3: Testing NOT NULL[cite: 49]
-- Successful complete insertion
INSERT INTO customers VALUES (1, 'test@mail.com', '+77011234567', '2026-10-01');
-- Insertion with NULL in nullable column phone
INSERT INTO customers VALUES (2, 'test2@mail.com', NULL, '2026-10-02');

-- Failed insertion (attempting to pass NULL into NOT NULL column email):
-- INSERT INTO customers VALUES (3, NULL, '+77019876543', '2026-10-03');
-- Error: email column does not accept NULL values[cite: 49].


--------------------------------------------------------------------------------
-- PART 3: UNIQUE Constraints
--------------------------------------------------------------------------------

-- Task 3.1: Single Column UNIQUE
CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE, -- username must be unique[cite: 49]
    email TEXT UNIQUE,    -- email must be unique[cite: 49]
    created_at TIMESTAMP
);

-- Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    -- UNIQUE constraint on combination of columns[cite: 49, 50]
    CONSTRAINT unique_student_course_semester UNIQUE (student_id, course_code, semester)
);

-- Task 3.3: Modify users table to add named UNIQUE constraints[cite: 50]
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP,
    CONSTRAINT unique_username UNIQUE (username),
    CONSTRAINT unique_email UNIQUE (email)
);

-- Testing UNIQUE:
INSERT INTO users VALUES (1, 'alex_code', 'alex@mail.com', NOW());
-- Failed insertion of duplicate username or email:
-- INSERT INTO users VALUES (2, 'alex_code', 'other@mail.com', NOW());
-- Error: violation of unique constraint 'unique_username'[cite: 50].


--------------------------------------------------------------------------------
-- PART 4: PRIMARY KEY Constraints
--------------------------------------------------------------------------------

-- Task 4.1: Single Column Primary Key
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY, -- unique and cannot be NULL[cite: 50]
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES (1, 'IT', 'Almaty');
INSERT INTO departments VALUES (2, 'HR', 'Astana');
INSERT INTO departments VALUES (3, 'Finance', 'Shymkent');

-- Failed attempts:
-- INSERT INTO departments VALUES (1, 'Marketing', 'Karaganda'); -- Duplicate dept_id[cite: 50]
-- INSERT INTO departments VALUES (NULL, 'Legal', 'Aktobe');   -- NULL in PRIMARY KEY[cite: 50]

-- Task 4.2: Composite Primary Key
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id) -- primary key is combination of student_id and course_id[cite: 50]
);

-- Task 4.3: Comparison Exercise[cite: 50]
-- 1. Difference between UNIQUE and PRIMARY KEY:
--    - PRIMARY KEY does not allow NULL values and automatically creates a unique index (a table can have only one PK).
--    - UNIQUE allows one NULL value (depending on SQL dialect, in PG multiple NULLs are allowed since they are not equal to each other) and a table can have multiple UNIQUE constraints.
-- 2. When to use single-column vs. composite PRIMARY KEY:
--    - Single-column is used when an entity has a natural or surrogate unique ID (e.g., customer id).
--    - Composite is used in junction tables (many-to-many), where row uniqueness is guaranteed by a combination of two or more foreign keys (like student_courses).
-- 3. Why a table can have only one PRIMARY KEY but multiple UNIQUE constraints:
--    - Primary key defines the physical/logical identity of the entity (row) itself in the table. An entity can have only one primary identifier, whereas an object can have multiple unique business attributes (email, phone, tax ID).


--------------------------------------------------------------------------------
-- PART 5: FOREIGN KEY Constraints
--------------------------------------------------------------------------------

-- Task 5.1: Basic Foreign Key
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id), -- reference to departments table[cite: 51]
    hire_date DATE
);

-- Successful insertion (dept_id = 1 exists)[cite: 51]
INSERT INTO employees_dept VALUES (101, 'Daniyar', 1, '2026-01-15');

-- Failed insertion (dept_id 99 does not exist in departments table)[cite: 51]:
-- INSERT INTO employees_dept VALUES (102, 'Aliya', 99, '2026-02-01');
-- Error: foreign key violation.

-- Task 5.2: Complete library system database schema[cite: 51]
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

-- Insert sample data into library tables[cite: 51]
INSERT INTO authors VALUES (1, 'Martin Fowler', 'USA');
INSERT INTO publishers VALUES (1, 'Piter', 'Saint Petersburg');
INSERT INTO books VALUES (1, 'Refactoring', 1, 1, 2018, '978-5-4461-1317-0');

-- Task 5.3: ON DELETE Options[cite: 51, 52]
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT -- Restricts category deletion if referenced[cite: 51]
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE, -- Cascades deletion of order items when order is deleted[cite: 52]
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

-- Testing ON DELETE[cite: 52]:
INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO products_fk VALUES (1, 'Smartphone', 1);

-- 1. Try to delete a category referenced by a product (will fail due to RESTRICT):
-- DELETE FROM categories WHERE category_id = 1;
-- Error: UPDATE or DELETE on table "categories" violates foreign key constraint RESTRICT[cite: 52].

-- 2. Cascade delete order[cite: 52]:
INSERT INTO orders VALUES (10, '2026-10-13');
INSERT INTO order_items VALUES (1, 10, 1, 2);
-- Deleting the parent order automatically deletes dependent rows in order_items:
DELETE FROM orders WHERE order_id = 10;


--------------------------------------------------------------------------------
-- PART 6: Practical Application — E-commerce Database Schema
--------------------------------------------------------------------------------

-- Task 6.1: E-commerce database design[cite: 52]

-- 1. Customers table
CREATE TABLE ecommerce_customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL, -- Unique email[cite: 52]
    phone TEXT,
    registration_date DATE NOT NULL
);

-- 2. Products table
CREATE TABLE ecommerce_products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),           -- Non-negative price[cite: 52]
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0) -- Non-negative stock quantity[cite: 52]
);

-- 3. Orders table
CREATE TABLE ecommerce_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES ecommerce_customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')) -- Order status check[cite: 52]
);

-- 4. Order details table
CREATE TABLE ecommerce_order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES ecommerce_orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES ecommerce_products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),    -- Positive quantity[cite: 52]
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- Insert at least 5 sample records per table[cite: 52]
INSERT INTO ecommerce_customers VALUES
(1, 'Aibek', 'aibek@gmail.com', '+77021112233', '2026-09-01'),
(2, 'Dilnaz', 'dilnaz@mail.kz', '+77052223344', '2026-09-05'),
(3, 'Timur', 'timur@gmail.com', '+77073334455', '2026-09-10'),
(4, 'Aruzhan', 'aruzhan@mail.kz', '+77014445566', '2026-09-12'),
(5, 'Sanzhar', 'sanzhar@gmail.com', '+77775556677', '2026-09-15');

INSERT INTO ecommerce_products VALUES
(1, 'Wireless Headphones', 'Bluetooth 5.2 headphones', 25000.00, 15),
(2, 'Mechanical Keyboard', 'RGB backlight, blue switches', 32000.00, 8),
(3, 'Gaming Mouse', '16000 DPI', 18000.00, 20),
(4, 'Monitor 27"', 'IPS 165Hz', 110000.00, 5),
(5, 'USB-C Hub', '7 in 1', 12500.00, 30);

INSERT INTO ecommerce_orders VALUES
(101, 1, '2026-10-01', 57000.00, 'delivered'),
(102, 2, '2026-10-03', 110000.00, 'shipped'),
(103, 3, '2026-10-05', 25000.00, 'processing'),
(104, 4, '2026-10-08', 30500.00, 'pending'),
(105, 5, '2026-10-10', 12500.00, 'cancelled');

INSERT INTO ecommerce_order_details VALUES
(1, 101, 1, 1, 25000.00),
(2, 101, 3, 1, 18000.00),
(3, 102, 4, 1, 110000.00),
(4, 103, 1, 1, 25000.00),
(5, 104, 5, 1, 12500.00);

-- Test queries to verify constraints[cite: 52]:
-- 1. Check customer email uniqueness (will fail):
-- INSERT INTO ecommerce_customers VALUES (6, 'Test', 'aibek@gmail.com', '+77000000000', '2026-10-13');

-- 2. Check order status CHECK constraint (will fail):
-- INSERT INTO ecommerce_orders VALUES (106, 1, '2026-10-13', 1000.00, 'unknown_status');

-- 3. Check positive quantity in order details (will fail):
-- INSERT INTO ecommerce_order_details VALUES (6, 101, 2, -3, 32000.00);