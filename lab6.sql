-- =============================================================================
-- Laboratory Work 6: SQL JOINS - Full Solutions
-- Aidana Kaibulla
-- Student ID = 25B031303
-- =============================================================================

DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- Step 1.1: Create Sample Tables

CREATE TABLE departments (
dept_id INT PRIMARY KEY,
dept_name VARCHAR(50),
location VARCHAR(50)
);


CREATE TABLE employees (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(50),
dept_id INT,
salary DECIMAL(10, 2),
FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL
);

CREATE TABLE projects (
project_id INT PRIMARY KEY,
project_name VARCHAR(50),
dept_id INT,
budget DECIMAL(10, 2),
FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL
);

\-- Step 1.2: Insert Sample Data

INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');


INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

-- =============================================================================
-- PART 2: CROSS JOIN EXERCISES
-- =============================================================================

-- Exercise 2.1: Basic CROSS JOIN

SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;
-- The result contains 20 rows (5 employees * 4 departments = 20 combinations)

-- Exercise 2.2: Alternative CROSS JOIN Syntax
-- a) Comma notation:
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- b) INNER JOIN with TRUE condition:
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;

-- Exercise 2.3: Practical CROSS JOIN
-- Schedule showing all employees paired with all projects (e.g., availability matrix).
SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p;

-- =============================================================================
-- PART 3: INNER JOIN EXERCISES
-- =============================================================================

-- Exercise 3.1: Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- Answer to Questions:
-- 4 rows are returned. Tom Brown is not included because his dept_id is NULL, which does not match any dept_id in departments.
-- Exercise 3.2: INNER JOIN with USING

SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
-- Answer to Question:
-- When using the USING clause, the join column (dept_id) appears only once in the projected output table rather than as two separate columns (e.dept_id and d.dept_id).

-- Exercise 3.3: NATURAL INNER JOIN
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;

-- Exercise 3.4: Multi-table INNER JOIN
-- Join all three tables to show employee name, department name, and project name.
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

-- =============================================================================
-- PART 4: LEFT JOIN EXERCISES
-- =============================================================================

-- Exercise 4.1: Basic LEFT JOIN
SELECT e.emp_name, e.dept_id AS emp_dept,
d.dept_id AS dept_dept,
d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Answer to Question:
-- Tom Brown is included in the output, but the department fields (dept_dept and dept_name) contain NULL values.

-- Exercise 4.2: LEFT JOIN with USING
SELECT emp_name, dept_id, dept_name
FROM employees
LEFT JOIN departments USING (dept_id);

-- Exercise 4.3: Find Unmatched Records
-- Find employees who are NOT assigned to any department.
SELECT
e.emp_name,
e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Exercise 4.4: LEFT JOIN with Aggregation
-- Show all departments with the count of employees in each department.
SELECT
d.dept_name,
COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

-- =============================================================================
-- PART 5: RIGHT JOIN EXERCISES
-- =============================================================================

-- Exercise 5.1: Basic RIGHT JOIN
SELECT
e.emp_name,
d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Exercise 5.2: Convert to LEFT JOIN
-- Rewrite Exercise 5.1 using LEFT JOIN instead of RIGHT JOIN by reversing table order.
SELECT
e.emp_name,
d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- Exercise 5.3: Find Departments Without Employees
SELECT
d.dept_name,
d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

-- =============================================================================
-- PART 6: FULL JOIN EXERCISES
-- =============================================================================

-- Exercise 6.1: Basic FULL JOIN
SELECT
e.emp_name,
e.dept_id AS emp_dept,
d.dept_id AS dept_dept,
d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
-- Answer to Question:
-- Department 'Marketing' has NULL values on the left side (no employees matched).
-- Employee 'Tom Brown' has NULL values on the right side (no department matched).

-- Exercise 6.2: FULL JOIN with Projects
SELECT
d.dept_name,
p.project_name,
p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

-- Exercise 6.3: Find Orphaned Records
SELECT
CASE
WHEN e.emp_id IS NULL THEN 'Department without employees'
WHEN d.dept_id IS NULL THEN 'Employee without department'
ELSE 'Matched'
END AS record_status,
e.emp_name,
d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

-- =============================================================================
-- PART 7: ON vs WHERE CLAUSE
-- =============================================================================

-- Exercise 7.1: Filtering in ON Clause (Outer Join)
SELECT
e.emp_name,
d.dept_name,
e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- Exercise 7.2: Filtering in WHERE Clause (Outer Join)
SELECT
e.emp_name,
d.dept_name,
e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Answer to Question (Comparison of 7.1 vs 7.2):
-- Query 7.1 (ON clause filter): Evaluates the condition during the join process.
--   All 5 employees are preserved. Employees not in 'Building A' will still appear, but their department details will be NULL.
-- Query 7.2 (WHERE clause filter): Evaluates the condition after the join has occurred.
--   It filters out any rows where d.location is not 'Building A' (including rows with NULLs), behaving like an INNER JOIN.

-- Exercise 7.3: ON vs WHERE with INNER JOIN
-- Query 1 (ON Clause):
SELECT
e.emp_name,
d.dept_name,
e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- Query 2 (WHERE Clause):
SELECT
e.emp_name,
d.dept_name,
e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Answer to Question:
-- There is NO difference in the result set for INNER JOIN.
-- Because non-matching rows are discarded by definition in an INNER JOIN, filtering before or after the join yields the exact same rows.

-- =============================================================================
-- PART 8: COMPLEX JOIN SCENARIOS
-- =============================================================================

-- Exercise 8.1: Multiple Joins with Different Types
SELECT
d.dept_name,
e.emp_name,
e.salary,
p.project_name,
p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- Exercise 8.2: Self Join
-- Alter table and populate manager_id
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

-- Query showing employees with their managers:
SELECT
e.emp_name AS employee,
m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Exercise 8.3: Join with Subquery / Aggregation SELECT d.dept_name, AVG(e.salary) AS avg_salary FROM departments d INNER JOIN employees e ON d.dept_id = e.dept_id GROUP BY d.dept_id, d.dept_name HAVING AVG(e.salary) > 50000;

-- LAB QUESTIONS & ANSWERS /\* Q1: What is the difference between INNER JOIN and LEFT JOIN?
-- A1: INNER JOIN returns only the rows where there is a match in both joining tables.
-- LEFT JOIN returns all rows from the left table, along with matching rows from the right table.
-- If there is no match, NULL values are returned for the right table's columns.

--Q2: When would you use CROSS JOIN in a practical scenario?
-- A2: A CROSS JOIN is useful for generating all possible pairings of two datasets, such as:
--  Creating a matrix of availability (employees x shifts or projects). - Generating test data combinations. - Product catalogs combining all colors with all sizes.

--Q3: Explain why the position of a filter condition (ON vs WHERE) matters for outer joins but not for inner joins.
-- A3: For OUTER JOINs, conditions in the ON clause determine which rows from the right table are matched to the left table (preserving unmatched left-table rows with NULLs).
-- Conditions in the WHERE clause are evaluated after the join, filtering out any rows (including NULL-padded rows) that fail the condition.
-- For INNER JOINs, non-matching rows are eliminated regardless, so filtering in ON vs WHERE yields identical results.

--Q4: What is the result of: SELECT COUNT(\*) FROM table1 CROSS JOIN table2 if table1 has 5 rows and table2 has 10