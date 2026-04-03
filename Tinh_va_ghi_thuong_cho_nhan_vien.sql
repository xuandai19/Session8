CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary NUMERIC(10,2),
    bonus NUMERIC(10,2) DEFAULT 0
);

INSERT INTO employees (name, department, salary)
VALUES ('Nguyen Van A','HR',4000),
       ('Tran Thi B','IT',6000),
       ('Le Van C','Finance',10500),
       ('Pham Thi D','IT',8000),
       ('Do Van E','HR',12000);

CREATE OR REPLACE PROCEDURE update_employee_status (
    IN p_emp_id INT,
    OUT p_status TEXT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_salary NUMERIC;
BEGIN
    SELECT salary INTO v_salary
    FROM employees
    WHERE id = p_emp_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee not found';
    END IF;

    IF v_salary < 5000 THEN
        p_status := 'Junior';
    ELSIF v_salary >= 5000 AND v_salary <= 10000 THEN
        p_status := 'Mid-level';
    ELSE
        p_status := 'Senior';
    END IF;

    UPDATE employees
    SET status = p_status
    WHERE id = p_emp_id;

    RAISE NOTICE 'Nhân viên ID % đã được cập nhật thành: %', p_emp_id, p_status;
END;
$$;

CREATE OR REPLACE PROCEDURE calculate_bonus (
    IN p_emp_id INT,
    IN p_percent NUMERIC,
    OUT p_bonus NUMERIC
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_salary NUMERIC;
    v_bonus NUMERIC;
BEGIN
    SELECT salary INTO v_salary
    FROM employees
    WHERE id = p_emp_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee not found';
    END IF;

    IF p_percent <= 0 THEN
        p_bonus := 0;
    ELSE
        v_bonus := v_salary * p_percent / 100;
        p_bonus := v_bonus;

        UPDATE employees
        SET bonus = v_bonus
        WHERE id = p_emp_id;
    END IF;
end;
$$
