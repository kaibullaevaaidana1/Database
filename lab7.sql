-- ==============================================================================
-- Laboratory Work 7: SQL Views and Roles
--Kaibulla Aidana
-- ==============================================================================

--------------------------------------------------------------------------------
-- Part 1: Database Setup (Use Lab 6 Tables)[cite: 1]
-- You will use the same database setup from Laboratory Work 6 (employees, departments,
-- and projects tables). If you haven't created them yet, run the setup scripts from Lab 6 Part 1.[cite: 1]
--------------------------------------------------------------------------------

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT REFERENCES departments(dept_id),
    salary DECIMAL(10, 2)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT REFERENCES departments(dept_id),
    budget DECIMAL(12, 2)
);

--------------------------------------------------------------------------------
-- Part 2: Creating Basic Views[cite: 1, 2]
--------------------------------------------------------------------------------

-- Exercise 2.1: Simple View Creation[cite: 1, 2]
-- Create a view that shows employee names with their department information (name, salary,
-- department name, and location). Include only employees who are assigned to a department.[cite: 1, 2]
-- Question: How many rows are returned? Why doesn't Tom Brown appear?[cite: 2]
CREATE VIEW employee_details AS
SELECT
    e.emp_name,
    d.dept_name,
    e.salary,
    d.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- Test your view:[cite: 2]
SELECT * FROM employee_details;


-- Exercise 2.2: View with Aggregation[cite: 2]
-- Create a view named dept_statistics showing department statistics including department name,
-- employee count, average salary, maximum salary, and minimum salary. Include all departments
-- even if they have no employees.[cite: 2]
CREATE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MAX(e.salary) AS max_salary,
    MIN(e.salary) AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Test your view:[cite: 2]
SELECT * FROM dept_statistics
ORDER BY employee_count DESC;


-- Exercise 2.3: View with Multiple Joins[cite: 2]
-- Create a view named project_overview showing complete project information including
-- project name, budget, department name, location, and the count of employees in that department (team size).[cite: 2]
CREATE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS team_size
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_id, d.dept_name, d.location;


-- Exercise 2.4: View with Filtering[cite: 2]
-- Create a view named high_earners for employees with salaries greater than $55,000,
-- showing employee name, salary, and department name.[cite: 2]
-- Question: What happens when you query this view? Can you see all high-earning employees?[cite: 2]
CREATE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;


--------------------------------------------------------------------------------
-- Part 3: Modifying and Managing Views[cite: 2, 3]
--------------------------------------------------------------------------------

-- Exercise 3.1: Replace a View[cite: 2, 3]
-- Modify the employee_details view to include a salary grade column that shows:[cite: 2, 3]
-- 'High' for salary > 60000[cite: 2, 3]
-- 'Medium' for salary > 50000[cite: 2, 3]
-- 'Standard' for all others[cite: 3]
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    d.dept_name,
    e.salary,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;


-- Exercise 3.2: Rename a View[cite: 3]
-- Rename the high_earners view to top_performers.[cite: 3]
ALTER VIEW high_earners RENAME TO top_performers;

-- Verify:[cite: 3]
SELECT * FROM top_performers;


-- Exercise 3.3: Drop a View[cite: 3]
-- Create a temporary view named temp_view showing employees with salary less than $50,000, then drop it.[cite: 3]
CREATE VIEW temp_view AS
SELECT * FROM employees
WHERE salary < 50000;

DROP VIEW temp_view;


--------------------------------------------------------------------------------
-- Part 4: Updatable Views[cite: 3, 4]
--------------------------------------------------------------------------------

-- Exercise 4.1: Create an Updatable View[cite: 3, 4]
-- Create a simple updatable view named employee salaries on the employees table showing emp_id, emp_name, dept_id, and salary.[cite: 3, 4]
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;


-- Exercise 4.2: Update Through a View[cite: 4]
-- Update John Smith's salary to $52,000 through the employee_salaries view.[cite: 4]
-- Question: Did the underlying table get updated?[cite: 4]
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

-- Verify the update:[cite: 4]
SELECT * FROM employees WHERE emp_name = 'John Smith';


-- Exercise 4.3: Insert Through a View[cite: 4]
-- Try inserting a new employee named 'Alice Johnson' (emp_id: 6, dept_id: 102, salary: 58000) through the view.[cite: 4]
-- Question: Was the insert successful? Check the employees table.[cite: 4]
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);


-- Exercise 4.4: View with CHECK OPTION[cite: 4]
-- Create a view named it_employees showing only IT department employees (dept_id = 101) with LOCAL CHECK OPTION.[cite: 4]
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

-- Try to insert an employee from a different department (This should fail):[cite: 4]
-- INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
-- VALUES (7, 'Bob Wilson', 103, 60000);
-- Question: What error message do you receive? Why?[cite: 4]


--------------------------------------------------------------------------------
-- Part 5: Materialized Views[cite: 4, 5]
--------------------------------------------------------------------------------

-- Exercise 5.1: Create a Materialized View[cite: 4, 5]
-- Create a materialized view named dept_summary_mv that shows for each department:[cite: 4, 5]
-- dept_id, dept_name, Total number of employees, Total salaries (use 0 if no employees),[cite: 4, 5]
-- Total number of projects, Total project budget (use 0 if no projects). Load data immediately (WITH DATA).[cite: 5]
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    COALESCE(SUM(e.salary), 0) AS total_salaries,
    COUNT(DISTINCT p.project_id) AS total_projects,
    COALESCE(SUM(DISTINCT p.budget), 0) AS total_project_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

-- Query the materialized view:[cite: 5]
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;


-- Exercise 5.2: Refresh Materialized View[cite: 5]
-- Insert a new employee named 'Charlie Brown' (emp_id: 8, dept_id: 101, salary: 54000).[cite: 5]
-- Query the materialized view before and after refreshing it.[cite: 5]
-- Question: What's the difference before and after refresh?[cite: 5]
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

REFRESH MATERIALIZED VIEW dept_summary_mv;


-- Exercise 5.3: Concurrent Refresh[cite: 5]
-- Create a unique index on dept_summary_mv using dept_id, then refresh the materialized view concurrently.[cite: 5]
-- Question: What's the advantage of CONCURRENTLY option?[cite: 5]
CREATE UNIQUE INDEX idx_dept_summary_mv_dept_id ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;


-- Exercise 5.4: Materialized View with NO DATA[cite: 5]
-- Create a materialized view named project_stats_mv showing project name, budget, department name,[cite: 5]
-- and count of assigned employees. Create it WITH NO DATA.[cite: 5]
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS assigned_employees
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name
WITH NO DATA;

-- Try to query it:[cite: 5]
-- SELECT * FROM project_stats_mv;
-- Question: What error do you get? How do you fix it?[cite: 5]


--------------------------------------------------------------------------------
-- Part 6: Database Roles[cite: 5, 6, 7]
--------------------------------------------------------------------------------

-- Exercise 6.1: Create Basic Roles[cite: 5, 6]
-- Create the following roles: A basic role named analyst (no login),[cite: 5, 6]
-- a role named data_viewer with LOGIN and password 'viewer123',[cite: 6]
-- a user named report_user with password 'report456'.[cite: 6]
CREATE ROLE analyst NOLOGIN;
CREATE ROLE data_viewer WITH LOGIN PASSWORD 'viewer123';
CREATE ROLE report_user WITH LOGIN PASSWORD 'report456';

-- View all roles:[cite: 6]
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';


-- Exercise 6.2: Role with Specific Attributes[cite: 6]
-- Create the following roles with their respective attributes:[cite: 6]
-- db_creator - can create databases, has login, password 'creator789'[cite: 6]
-- user_manager - can create roles, has login, password 'manager101'[cite: 6]
-- admin_user - superuser with login, password 'admin999' (use carefully!)[cite: 6]
CREATE ROLE db_creator WITH CREATEDB LOGIN PASSWORD 'creator789';
CREATE ROLE user_manager WITH CREATEROLE LOGIN PASSWORD 'manager101';
CREATE ROLE admin_user WITH SUPERUSER LOGIN PASSWORD 'admin999';


-- Exercise 6.3: Grant Privileges to Roles[cite: 6]
-- Grant the following privileges:[cite: 6]
-- SELECT privilege on employees, departments, and projects tables to analyst[cite: 6]
-- ALL PRIVILEGES on employee_details view to data_viewer[cite: 6]
-- SELECT and INSERT privileges on employees table to report_user[cite: 6]
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;


-- Exercise 6.4: Create Group Roles[cite: 6, 7]
-- Create group roles for different teams and assign members:[cite: 6, 7]
-- 1. Create group roles: hr_team, finance_team, it_team[cite: 6, 7]
-- 2. Create individual users: hr_user1 (password: 'hr001'), hr_user2 (password: 'hr002'), finance_user1 (password: 'fin001')[cite: 7]
-- 3. Assign hr_user1 and hr_user2 to hr_team[cite: 7]
-- 4. Assign finance_user1 to finance_team[cite: 7]
-- 5. Grant SELECT and UPDATE on employees to hr_team[cite: 7]
-- 6. Grant SELECT on dept_statistics to finance_team[cite: 7]
CREATE ROLE hr_team NOLOGIN;
CREATE ROLE finance_team NOLOGIN;
CREATE ROLE it_team NOLOGIN;

CREATE ROLE hr_user1 WITH LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 WITH LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 WITH LOGIN PASSWORD 'fin001';

GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;


-- Exercise 6.5: Revoke Privileges[cite: 7]
-- Perform the following revocations:[cite: 7]
-- Revoke UPDATE privilege on employees from hr_team[cite: 7]
-- Revoke hr_team membership from hr_user2[cite: 7]
-- Revoke ALL PRIVILEGES on employee_details from data_viewer[cite: 7]
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;


-- Exercise 6.6: Modify Role Attributes[cite: 7]
-- Make the following modifications:[cite: 7]
-- Add LOGIN and password 'analyst123' to the analyst role[cite: 7]
-- Make user_manager a SUPERUSER[cite: 7]
-- Remove password from analyst role (set to NULL)[cite: 7]
-- Add a connection limit of 5 to data_viewer[cite: 7]
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;


--------------------------------------------------------------------------------
-- Part 7: Advanced Role Management[cite: 7, 8]
--------------------------------------------------------------------------------

-- Exercise 7.1: Role Hierarchies[cite: 7]
-- Create a role hierarchy:[cite: 7]
-- 1. Create a parent role read_only and grant SELECT on all tables in schema public[cite: 7]
-- 2. Create child roles: junior_analyst (password: 'junior123') and senior_analyst (password: 'senior123')[cite: 7]
-- 3. Grant read_only membership to both junior and senior analysts[cite: 7]
-- 4. Grant additional INSERT and UPDATE privileges on employees to senior_analyst only[cite: 7]
CREATE ROLE read_only NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst WITH LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst WITH LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;


-- Exercise 7.2: Object Ownership[cite: 7, 8]
-- Transfer ownership of database objects:[cite: 7, 8]
-- 1. Create a new role project_manager with LOGIN and password 'pm123'[cite: 7, 8]
-- 2. Transfer ownership of the dept_statistics view to project_manager[cite: 8]
-- 3. Transfer ownership of the projects table to project_manager[cite: 8]
CREATE ROLE project_manager WITH LOGIN PASSWORD 'pm123';
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

-- Check ownership:[cite: 8]
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';


-- Exercise 7.3: Reassign and Drop Roles[cite: 8]
-- Properly remove a role by reassigning its objects:[cite: 8]
-- 1. Create a role named temp_owner with LOGIN[cite: 8]
-- 2. Create a table temp_table with an id column (INT)[cite: 8]
-- 3. Transfer ownership of temp_table to temp_owner[cite: 8]
-- 4. Reassign all objects owned by temp_owner to postgres[cite: 8]
-- 5. Drop all objects owned by temp_owner[cite: 8]
-- 6. Drop the temp_owner role[cite: 8]
CREATE ROLE temp_owner WITH LOGIN;
CREATE TABLE temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;


-- Exercise 7.4: Row-Level Security with Views[cite: 8]
-- Create role-specific views that restrict data access:[cite: 8]
-- 1. Create hr_employee view showing employees only from HR department (dept_id = 102)[cite: 8]
-- 2. Grant SELECT on this view to hr_team[cite: 8]
-- 3. Create finance_employee_view showing only emp_id, emp_name, and salary for all employees[cite: 8]
-- 4. Grant SELECT on this view to finance_team[cite: 8]
CREATE VIEW hr_employee AS
SELECT * FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;


--------------------------------------------------------------------------------
-- Part 8: Practical Scenarios[cite: 8, 9]
--------------------------------------------------------------------------------

-- Exercise 8.1: Department Dashboard View[cite: 8, 9]
-- Create a comprehensive dashboard view named dept_dashboard for department managers showing:[cite: 8, 9]
-- Department name and location, Employee count, Average salary (rounded to 2 decimals),[cite: 9]
-- Number of active projects, Total project budget, Budget per employee (rounded to 2 decimals, handle division by zero)[cite: 9]
CREATE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    COUNT(DISTINCT p.project_id) AS active_projects_count,
    COALESCE(SUM(DISTINCT p.budget), 0) AS total_project_budget,
    ROUND(
        COALESCE(SUM(DISTINCT p.budget), 0) / NULLIF(COUNT(DISTINCT e.emp_id), 0),
        2
    ) AS budget_per_employee
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name, d.location;


-- Exercise 8.2: Audit View[cite: 9]
-- Create an audit view for high-value projects:[cite: 9]
-- 1. First, add a created_date column to projects table with default CURRENT_TIMESTAMP[cite: 9]
-- 2. Include project name, budget, department name, created date[cite: 9]
-- 3. Create view high_budget_projects showing projects with budget > 75000[cite: 9]
-- 4. Add an approval_status column that shows:[cite: 9]
--    - 'Critical Review Required' for budget > 150000[cite: 9]
--    - 'Management Approval Needed' for budget > 100000[cite: 9]
--    - 'Standard Process' otherwise[cite: 9]
ALTER TABLE projects
ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;


-- Exercise 8.3: Create Access Control System[cite: 9]
-- Set up a complete access control system with multiple role levels:[cite: 9]
-- Level 1 - Viewer Role: create role viewer_role, grant SELECT on all tables and views in schema public[cite: 9]
-- Level 2 - Entry Role: create role entry_role, grant viewer_role membership, grant INSERT on employees and projects[cite: 9]
-- Level 3 - Analyst Role: create role analyst_role, grant entry_role membership, grant UPDATE on employees and projects[cite: 9]
-- Level 4 - Manager Role: create role manager_role, grant analyst_role membership, grant DELETE on employees and projects[cite: 9]
-- Create Users: alice, bob, charlie with passwords, and assign them to respective roles[cite: 9]

-- Level 1
CREATE ROLE viewer_role NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

-- Level 2
CREATE ROLE entry_role NOLOGIN;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

-- Level 3
CREATE ROLE analyst_role NOLOGIN;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

-- Level 4
CREATE ROLE manager_role NOLOGIN;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

-- Users creation and assignment
CREATE ROLE alice WITH LOGIN PASSWORD 'alice123';
CREATE ROLE bob WITH LOGIN PASSWORD 'bob123';
CREATE ROLE charlie WITH LOGIN PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;