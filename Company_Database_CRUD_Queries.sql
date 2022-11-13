CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(40),
    last_name VARCHAR(40),
    birth_date DATE,
    sex VARCHAR(1),
    salary INT,
    super_id INT,
    branch_id INT
);

CREATE TABLE branch (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(40),
    mgr_id INT,
    mgr_start_date DATE,
    FOREIGN KEY(mgr_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);

ALTER TABLE employee
ADD FOREIGN KEY(super_id)
REFERENCES employee(emp_id)
ON DELETE SET NULL;

ALTER TABLE employee
ADD FOREIGN KEY(branch_id)
REFERENCES branch(branch_id)
ON DELETE SET NULL;

DESCRIBE employee;

DESCRIBE branch;

CREATE TABLE client (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    client_name VARCHAR(40),
    branch_id INT
);

DESCRIBE client;

CREATE TABLE works_with (
    emp_id INT,
    client_id INT,
    total_sales INT,
    PRIMARY KEY(emp_id, client_id),
    FOREIGN KEY(emp_id) REFERENCES employee(emp_id) ON DELETE CASCADE,
    FOREIGN KEY(client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

DESCRIBE works_with;

CREATE TABLE branch_supplier (
    branch_id INT,
    supplier_name VARCHAR(40),
    supply_type VARCHAR(40),
    PRIMARY KEY(branch_id, supplier_name),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE
);

DESCRIBE branch_supplier;

-- Populating the Company database

-- Corporate branch

INSERT INTO employee VALUES(100, 'David', 'Wallace', '1967-11-17', 'M', 250000, NULL, NULL);

INSERT INTO branch VALUES(1, 'Corporate', 100, '2006-02-09');

UPDATE employee
SET branch_id = 1
WHERE emp_id = 100;

INSERT INTO employee VALUES(101, 'Jan', 'Levinson', '1961-05-11', 'F', 110000, 100, 1);

-- Scranton branch

INSERT INTO employee VALUES(102, 'Michael', 'Scott', '1964-03-15', 'M', 75000, 100, NULL);

INSERT INTO branch VALUES(2, 'Scranton', 102, '1992-04-06');

UPDATE employee
SET branch_id = 2
WHERE emp_id = 102;

INSERT INTO employee VALUES(103, 'Angela', 'Martin', '1971-06-25', 'F', 63000, 102, 2);

INSERT INTO employee VALUES(104, 'Kelly', 'Kapoor', '1980-02-05', 'F', 55000, 102, 2);

INSERT INTO employee VALUES(105, 'Stanley', 'Hudson', '1958-02-19', 'M', 69000, 102, 2);

-- Stamford Branch

INSERT INTO employee VALUES(106, 'Josh', 'Porter', '1969-09-05', 'M', 78000, 100, NULL);

INSERT INTO branch VALUES(3, 'Stamford', 106, '1998-02-13');

UPDATE employee
SET branch_id = 3
WHERE emp_id = 106;

INSERT INTO employee VALUES(107, 'Andy', 'Bernard', '1973-07-22', 'M', 65000, 106, 3);

INSERT INTO employee VALUES(108, 'Jim', 'Halpert', '1978-10-11', 'M', 71000, 106, 3);

--Branch supplier

INSERT INTO branch_supplier VALUES(2, 'Hammer Mill', 'Paper');

INSERT INTO branch_supplier VALUES(2, 'Uni-ball', 'Writing Utensils');

INSERT INTO branch_supplier VALUES(3, 'Patriot Paper', 'Paper');

INSERT INTO branch_supplier VALUES(2, 'J.T. Forms & Lables', 'Custom Forms');

INSERT INTO branch_supplier VALUES(3, 'Uni-ball', 'Writing Utensils');

INSERT INTO branch_supplier VALUES(3, 'Hammer Mill', 'Paper');

INSERT INTO branch_supplier VALUES(3, 'Stamford Lables', 'Custom Forms');

-- Client

INSERT INTO client VALUES(400, 'Dunmore Highschool', 2);

INSERT INTO client VALUES(401, 'Lackawana Country', 2);

INSERT INTO client VALUES(402, 'FedEx', 3);

INSERT INTO client VALUES(403, 'John Daly Law, LLC', 3);

INSERT INTO client VALUES(404, 'Scranton Whitepages', 2);

INSERT INTO client VALUES(405, 'Times Newspaper', 3);

INSERT INTO client VALUES(406, 'FedEx', 2);

-- Works_with

INSERT INTO works_with VALUES(105, 400, 55000);

INSERT INTO works_with VALUES(102, 401, 267000);

INSERT INTO works_with VALUES(108, 402, 22500);

INSERT INTO works_with VALUES(107, 403, 5000);

INSERT INTO works_with VALUES(108, 403, 12000);

INSERT INTO works_with VALUES(105, 404, 33000);

INSERT INTO works_with VALUES(107, 405, 26000);

INSERT INTO works_with VALUES(102, 406, 15000);

INSERT INTO works_with VALUES(105, 406, 130000);

SELECT *
FROM works_with;

SELECT *
FROM branch;

SELECT *
FROM branch_supplier;

-- Find all employees

SELECT *
FROM employee;

-- Find all clients

SELECT *
FROM client;

-- Find all employees ordered by salary ascending/descending

SELECT *
from employee
ORDER BY salary ASC;

SELECT *
FROM employee
ORDER BY salary DESC;

-- Find all employees ordered by sex then name

SELECT *
FROM employee
ORDER BY sex, first_name;

-- Find the first 5 employees in the table

SELECT *
FROM employee
LIMIT 5;

-- Find the first and last names of all employees

SELECT first_name, last_name
FROM employee;

-- Find the forename and surnames names of all employees

SELECT first_name AS forename, last_name AS surname
FROM employee;

-- Find out all the different genders

SELECT DISTINCT sex
FROM employee;

-- Find all male employees

SELECT *
FROM employee
WHERE sex = 'M';

-- Find all employees at branch 2

SELECT *
FROM employee
WHERE branch_id = 2;

-- Find all employee's id's and names who were born after 1969

SELECT *
FROM employee
WHERE birth_date > '1969-12-31';

-- Find all female employees at branch 2

SELECT *
FROM employee
WHERE sex = 'F' AND branch_id = 2;

-- Find all employees who are female & born after 1969 or who make over 80000

SELECT *
FROM employee
WHERE (sex = 'F' AND birth_date > '1969-12-31') OR salary > 80000;

-- Find all employees born between 1970 and 1975

SELECT *
FROM employee
WHERE birth_date BETWEEN '1970-01-01' AND '1975-01-01';

-- Find all employees named Jim, Michael, Johnny or David

SELECT *
FROM employee
WHERE first_name IN ('Jim', 'Michael', 'Johnny', 'David');

--FUNCTIONS

-- Find the number of employees

SELECT COUNT(emp_id)
FROM employee;

-- Find the average of all employee's salaries

SELECT AVG(salary)
FROM employee;

-- Find the sum of all employee's salaries

SELECT SUM(salary)
FROM employee;

-- Find out how many employees have supervisors

SELECT COUNT(emp_id)
FROM employee;

-- Find out how many males and females there are

SELECT COUNT(emp_id)
FROM employee
WHERE sex='M';

SELECT COUNT(emp_id)
FROM employee
WHERE sex='F';

SELECT COUNT(sex), sex
FROM employee
GROUP BY sex;

-- Find the total sales of each salesman

SELECT emp_id, SUM(total_sales)
FROM works_with
GROUP BY emp_id
ORDER BY SUM(total_sales);

-- Find the total amount of money spent by each client

SELECT client_id, SUM(total_sales)
FROM works_with
GROUP BY client_id;

--WILDCARDS

-- % = any # characters, _ = one character

-- Find any client's who are an LLC

SELECT *
FROM client
WHERE client_name LIKE '%LLC%';

-- Find any branch suppliers who are in the label business

SELECT *
FROM branch_supplier
WHERE supplier_name LIKE '%lable%';

-- Find any employee born on the 11th day of the month or born in february

SELECT *
FROM employee
WHERE birth_date LIKE '%11' OR birth_date LIKE '____-02%';

-- Find any clients who are schools

SELECT *
FROM client
WHERE client_name LIKE '%school%';

--UNION

-- Find a list of employee and branch names

SELECT first_name
FROM employee
UNION
SELECT branch_name
FROM branch;

-- Find a list of all clients & branch suppliers' names

SELECT client_name AS client_name
FROM client
UNION
SELECT supplier_name AS supplier_name
FROM branch_supplier;

-- Find a list of all money spent or earned by the company

SELECT emp_id AS source_id, salary
FROM employee
UNION
SELECT client_id, total_sales
FROM works_with;

--JOIN

INSERT INTO branch VALUES(4, 'Buffalo', NULL, NULL);

-- Find all branches and the names of their managers

SELECT employee.emp_id, employee.first_name, employee.last_name, branch.branch_name, branch.branch_id
FROM employee
LEFT JOIN branch
ON employee.emp_id = branch.mgr_id;

-- NESTED QUERIES

-- Find names of all employees who have sold over 50,000

SELECT first_name, last_name
FROM employee
WHERE emp_id IN (SELECT emp_id
                 FROM (SELECT emp_id, SUM(total_sales) as total_sales
                       FROM works_with
                       GROUP BY emp_id) AS totals
                 WHERE total_sales > 50000);

-- Find all clients who are handled by the branch that Michael Scott manages
-- Assume you know Michael's ID

SELECT client_name
FROM client
WHERE branch_id IN (SELECT branch_id
FROM branch
WHERE mgr_id = 102);

-- Find all clients who are handled by the branch that Michael Scott manages
-- Assume you DONT'T know Michael's ID

SELECT client_name
FROM client
WHERE branch_id IN (SELECT branch_id
FROM branch
WHERE mgr_id = (SELECT emp_id
FROM employee
WHERE first_name = 'Michael' AND last_name = 'Scott'));

-- Find the names of employees who work with clients handled by the scranton branch

SELECT first_name, last_name
FROM employee
WHERE emp_id IN (SELECT emp_id
FROM works_with
WHERE client_id IN (SELECT client_id
FROM client
WHERE branch_id = 2));

--Another implementation of the above query
SELECT employee.first_name, employee.last_name
FROM employee
WHERE employee.emp_id IN (
                         SELECT works_with.emp_id
                         FROM works_with
                         )
AND employee.branch_id = 2;

-- Find the names of all clients who have spent more than 100,000 dollars

SELECT client_name
FROM client
WHERE client_id IN (SELECT client_id
FROM (SELECT client_id, SUM(total_sales) AS total_purchased
FROM works_with
GROUP BY client_id) AS totals
WHERE total_purchased > 100000);

--ON DELETE SET NULL/CASCADE

DELETE FROM employee
WHERE emp_id = 102;

UPDATE branch
SET mgr_id = 102
WHERE branch_id = 2;

SELECT *
FROM branch;

SELECT *
FROM works_with;

SELECT *
FROM employee;

UPDATE employee
SET branch_id = 2
WHERE emp_id = 102;

UPDATE employee
SET super_id = 102
WHERE emp_id IN (103, 104, 105);


--TRIGGERS

CREATE TABLE trigger_test(
    message VARCHAR(100)
);

-- CREATE
--      TRIGGER 'event_name' BEFORE/AFTER INSERT/UPDATE/DELETE
--      ON 'database'.'table'
--      FOR EACH ROW BEGIN
--              -- trigger body
--              -- this code is applied to every
--              -- inserted/updated/deleted row
--      END;

-- Add new line 'Added new employee' to trigger_test table, notifying about new employee being added to employee table.
-- This code has been executed on the command line MySQL client

DELIMITER $$
CREATE
    TRIGGER add_new_employee BEFORE INSERT
    ON company.employee
    FOR EACH ROW BEGIN
        INSERT INTO trigger_test VALUES('Added new employee');
    END$$
DELIMITER ;

INSERT INTO employee VALUES(109, 'Oscar', 'Martinez', '1968-02-19', 'M', 69000, 106, 3);

SELECT * FROM trigger_test;

SELECT * FROM employee;

-- Add new line to trigger_test table, notifying about new employee being added to employee table,
-- and containing first name of the new added employee.
-- This code has been executed on the command line MySQL client

DELIMITER $$
CREATE
    TRIGGER new_employee_name BEFORE INSERT
    ON company.employee
    FOR EACH ROW
        BEGIN
            INSERT INTO trigger_test VALUES(NEW.first_name);
        END$$
DELIMITER ;

INSERT INTO employee VALUES(110, 'Kevin', 'Malone', '1978-02-19', 'M', 69000, 106, 3);

DROP TRIGGER add_new_employee;

DROP TRIGGER new_employee_name;

ALTER TABLE trigger_test
ADD first_name VARCHAR(40);

ALTER TABLE trigger_test
ADD when_added DATETIME;

-- Create a trigger, notifying about new employee and adding information about employee's name
-- and the date and time when it has been added.
-- This code has been executed on the command line MySQL client

DELIMITER $$
CREATE
    TRIGGER new_employee_added BEFORE INSERT
    ON company.employee
    FOR EACH ROW
        BEGIN
            INSERT INTO trigger_test VALUES('New employee added', NEW.first_name, CURRENT_TIMESTAMP);
        END $$
DELIMITER ;

INSERT INTO employee VALUES(111, 'Pam', 'Beesly', '1988-02-19', 'F', 69000, 106, 3);

DELETE FROM employee
WHERE first_name = 'Pam';

ALTER TABLE trigger_test
ADD sex VARCHAR(1);

ALTER TABLE trigger_test
DROP COLUMN sex;

DESCRIBE trigger_test;

DROP TRIGGER new_employee_added;

-- Create a trigger, notifying about new employee and adding information about employee's sex, name
-- and the date and time when it has been added.
-- This code has been executed on the command line MySQL client

DELIMITER $$
CREATE
    TRIGGER new_emp_added BEFORE INSERT
    ON company.employee
    FOR EACH ROW
        BEGIN
            IF NEW.sex = 'M' THEN
                INSERT INTO trigger_test VALUES('Male employee added', NEW.first_name, CURRENT_TIMESTAMP);
            ELSEIF NEW.sex = 'F' THEN
                INSERT INTO trigger_test VALUES('Female employee added', NEW.first_name, CURRENT_TIMESTAMP);
            ELSE
                INSERT INTO trigger_test VALUES('Other employee added', NEW.first_name, CURRENT_TIMESTAMP);
            END IF;
        END $$
DELIMITER ;

SELECT * FROM trigger_test;

SELECT * FROM employee;

DROP TRIGGER new_emp_added;

INSERT INTO employee VALUES(112, 'Max', 'Holloway', '1987-03-14', 'M', 72000, 106, 3);

INSERT INTO employee VALUES(113, 'Ivan', 'Smith', '1957-11-02', 'M', 95000, 106, 3);



