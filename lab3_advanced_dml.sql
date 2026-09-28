-- =====================================================================
-- Laboratory Work #3 - Advanced DML Operations
-- =====================================================================
-- Test data is (re)loaded by reset_test_data() (see Part A), because
-- earlier tasks (#9, #13-#15, #19, #22) destroy data needed by later ones.
-- =====================================================================


-- =====================================================================
-- Part A: Database and Table Setup
-- =====================================================================

-- Task 1
CREATE DATABASE advanced_lab;
-- psql: switch to the new DB. In DataGrip/DBeaver: reconnect to advanced_lab instead.
\c advanced_lab

CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary     INTEGER CHECK (salary >= 0),
    hire_date  DATE,
    status     VARCHAR(50) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id    SERIAL PRIMARY KEY,
    dept_name  VARCHAR(100) NOT NULL UNIQUE,
    budget     INTEGER CHECK (budget >= 0),
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(50) NOT NULL,
    dept_id      INTEGER REFERENCES departments (dept_id) ON DELETE SET NULL,
    start_date   DATE,
    end_date     DATE,
    budget       INTEGER CHECK (budget >= 0)
);

-- Test scaffolding: wipes all three tables and loads a known data set.
CREATE OR REPLACE FUNCTION reset_test_data() RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
    TRUNCATE employees, departments, projects RESTART IDENTITY CASCADE;

    INSERT INTO departments (dept_name, budget, manager_id) VALUES
        ('HR',      50000,  1),
        ('IT',      150000, 2),
        ('Sales',   130000, 3),
        ('Finance', 90000,  4),
        ('Legal',   20000,  5);   -- no employees: target for Task 15

    INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES
        ('John',  'Doe',    'IT',      70000, '2018-03-15', 'Active'),
        ('Alice', 'Smith',  'HR',      45000, '2019-06-01', 'Active'),
        ('Sam',   'Smooth', 'Finance', 55000, '2021-09-10', 'Active'),
        ('Bob',   'Lee',    'Sales',   62000, '2017-01-20', 'Active'),
        ('Kate',  'Kim',    'Sales',   48000, '2022-05-05', 'Inactive'),
        ('Tom',   'Ray',    'IT',      90000, '2015-11-11', 'Terminated'),
        ('Nina',  'Fox',    'HR',      38000, '2023-06-15', 'Active'),
        ('Ivan',  'Pit',    NULL,      35000, '2023-08-01', 'Active'),  -- Task 14 target
        ('Lena',  'Ort',    'IT',      65000, '2020-02-02', 'Inactive'),
        ('Max',   'Wolf',   'IT',      60000, '2021-04-04', 'Active');  -- IT = 4 employees (Task 27)

    INSERT INTO projects (project_name, dept_id, start_date, end_date, budget) VALUES
        ('Alpha',   2, '2021-01-01', '2022-06-30', 40000),  -- ended before 2023 (Task 16)
        ('Beta',    2, '2023-01-01', '2023-12-31', 80000),  -- IT, >50000 (Task 27)
        ('Gamma',   3, '2022-03-01', '2022-12-31', 30000),  -- ended before 2023 (Task 16)
        ('Delta',   1, '2024-01-01', '2024-12-31', 60000),  -- HR: only 2 employees
        ('Epsilon', 3, '2024-02-01', '2025-02-01', 70000);  -- Sales: only 2 employees
END;
$$;


-- =====================================================================
-- Part B: Advanced INSERT Operations (tables are still empty here)
-- =====================================================================

-- Task 2: INSERT with column specification (emp_id via DEFAULT -> serial)
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (DEFAULT, 'John', 'Doe', 'IT');

-- Task 3: INSERT with DEFAULT values (salary -> NULL, status -> 'Active')
INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Alice', 'Smith', 'HR', DEFAULT, DEFAULT);

-- Task 4: multiple rows in a single statement
INSERT INTO departments (dept_name, budget, manager_id)
VALUES ('HR', 50000, 1),
       ('IT', 10000, 2),
       ('Sales', 130000, 3);

-- Task 5: INSERT with expressions (50000 * 1.1 = 55000.0, numeric is cast to integer on assignment)
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Sam', 'Smooth', 'Finance', 50000 * 1.1, CURRENT_DATE);

-- Task 6: INSERT from SELECT into a temporary table
CREATE TEMP TABLE temp_employees (LIKE employees);
INSERT INTO temp_employees
SELECT * FROM employees WHERE department = 'IT';

SELECT * FROM temp_employees;


-- =====================================================================
-- Part C: Complex UPDATE Operations
-- =====================================================================
SELECT reset_test_data();

-- Task 7: arithmetic expression (numeric result is rounded to integer; NULL salary stays NULL)
UPDATE employees SET salary = salary * 1.10;

-- Task 8: multiple conditions
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- Task 9: CASE expression
-- NOTE: overwrites department for ALL rows (as the task requires); BETWEEN is inclusive,
-- so exactly 80000 falls into 'Senior'; NULL salary goes to ELSE -> 'Junior'.
UPDATE employees
SET department = CASE
                     WHEN salary > 80000              THEN 'Management'
                     WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
                     ELSE 'Junior'
                 END;

-- Task 10: SET ... = DEFAULT (department has no default -> NULL)
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- Task 11: UPDATE with subquery
-- Task 9 replaced department names, so restore the data first, otherwise AVG() is NULL for every dept.
SELECT reset_test_data();
-- Correlated subquery: budget = 120% of the average salary of the department's employees.
-- A department without employees gets NULL (AVG of empty set).
UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
);

-- Task 12: multiple columns in a single statement
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

SELECT * FROM employees ORDER BY emp_id;
SELECT * FROM departments ORDER BY dept_id;


-- =====================================================================
-- Part D: Advanced DELETE Operations
-- =====================================================================
SELECT reset_test_data();

-- Task 13: simple WHERE
DELETE FROM employees WHERE status = 'Terminated';

-- Task 14: complex WHERE (removes Ivan Pit)
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- Task 15: DELETE with subquery
-- Deviation from the text: dept_id is INTEGER, employees.department is VARCHAR (type mismatch),
-- so compare dept_name. The IS NOT NULL filter is required: NOT IN with a NULL in the list
-- would evaluate to NULL and delete nothing.
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);   -- removes 'Legal'; projects.dept_id is set to NULL via ON DELETE SET NULL

-- Task 16: DELETE with RETURNING (removes Alpha and Gamma)
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


-- =====================================================================
-- Part E: Operations with NULL Values
-- =====================================================================

-- Task 17: INSERT with NULLs
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Alex', 'Brown', NULL, NULL);

-- Task 18: UPDATE NULL handling (IS NULL, not = NULL)
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- Task 19: DELETE with NULL conditions
-- After Task 18 no department is NULL, so only rows with NULL salary (Alex) are removed.
DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;


-- =====================================================================
-- Part F: RETURNING Clause Operations
-- =====================================================================
SELECT reset_test_data();

-- Task 20: INSERT with RETURNING (generated id + concatenated full name)
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Emma', 'Watson', 'HR', 60000)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

-- Task 21: UPDATE with RETURNING
-- RETURNING sees the NEW row, so old salary = salary - 5000.
-- (PostgreSQL 18+ alternative: RETURNING OLD.salary AS old_salary, NEW.salary AS new_salary)
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

-- Task 22: DELETE with RETURNING all columns
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- =====================================================================
-- Part G: Advanced DML Patterns
-- =====================================================================

-- Task 23: conditional INSERT (idempotent: the second run inserts 0 rows)
INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Michael', 'Scott', 'Management', 95000
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Michael' AND last_name = 'Scott'
);

INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Michael', 'Scott', 'Management', 95000
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Michael' AND last_name = 'Scott'
);   -- 0 rows

-- Task 24: UPDATE with JOIN logic via subqueries
-- Budget > 100000 -> +10%, otherwise +5%. EXISTS restricts the update to employees whose
-- department exists in departments (otherwise the scalar subquery returns NULL -> ELSE branch).
UPDATE employees e
SET salary = salary * CASE
                          WHEN (SELECT d.budget FROM departments d WHERE d.dept_name = e.department) > 100000
                              THEN 1.10
                          ELSE 1.05
                      END
WHERE e.department IS NOT NULL
  AND EXISTS (SELECT 1 FROM departments d WHERE d.dept_name = e.department);

-- Task 25: bulk operations
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Alice',   'Cooper', 'IT',         60000),
       ('Bob',     'Marley', 'HR',         55000),
       ('Charlie', 'Brown',  'Sales',      50000),
       ('David',   'Bowie',  'IT',         75000),
       ('Eva',     'Green',  'Management', 90000);

-- Row-value IN matches exact (first, last) pairs; separate IN lists would allow cross-matches.
UPDATE employees
SET salary = salary * 1.10
WHERE (first_name, last_name) IN (('Alice', 'Cooper'), ('Bob', 'Marley'), ('Charlie', 'Brown'),
                                  ('David', 'Bowie'),  ('Eva', 'Green'))
RETURNING emp_id, first_name, last_name, salary;

-- Task 26: data migration simulation
SELECT reset_test_data();

DROP TABLE IF EXISTS employee_archive;
-- INCLUDING ALL copies defaults, constraints and indexes. Note: emp_id's default still
-- uses the SAME sequence as employees.
CREATE TABLE employee_archive (LIKE employees INCLUDING ALL);

-- Atomic move: DELETE ... RETURNING feeds the INSERT in one statement,
-- so rows can't be lost or duplicated between two separate queries.
WITH moved AS (
    DELETE FROM employees
    WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM moved;

SELECT * FROM employee_archive;
SELECT * FROM employees ORDER BY emp_id;

-- Task 27: complex business logic
SELECT reset_test_data();

-- Projects with budget > 50000 whose department has more than 3 employees
-- (only 'Beta': IT has 4 employees). date + integer = date (days).
UPDATE projects p
SET end_date = end_date + 30
WHERE p.budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      WHERE e.department = (SELECT d.dept_name FROM departments d WHERE d.dept_id = p.dept_id)
  ) > 3
RETURNING project_id, project_name, end_date;
