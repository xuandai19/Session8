CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100),
    job_level INT,
    salary NUMERIC
);

CREATE OR REPLACE PROCEDURE adjust_salary(
    IN p_emp_id INT,
    OUT p_new_salary NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees e
    SET salary = salary * (1 + (job_level * 0.05))
    WHERE e.emp_id = p_emp_id
    RETURNING salary INTO p_new_salary;
end;
$$;

CALL adjust_salary(3, p_new_salary);
SELECT p_new_salary;
