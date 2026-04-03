create table student (
    student_id serial primary key,
    student_name varchar(100) not null,
    student_age int,
    student_status boolean default true
);

-- Viết 1 procedure cho phép thêm ms 1 sv
/*
    INPUT: name, age, status --> có 3 tham số vào
    OUTPUT: 0 có tham số ra
 */

CREATE OR REPLACE PROCEDURE create_student (
    IN name_in VARCHAR(100),
    IN age_in INT,
    IN status_in BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- block statemnet -> thực hiện chức năng procedure
    INSERT INTO student(student_name, student_age, student_status)
    VALUES (name_in, age_in, status_in);
END;
$$;

CALL create_student('Nguyen Van A', 20, true);

-- Cho phép cập nhật sv theo mã sv
/*
    INPUT: id, name, age, status
    OUTPUT: 0 có
 */

CREATE OR REPLACE PROCEDURE update_student(
    IN id_in INT,
    IN name_in VARCHAR(100),
    IN age_in INT,
    IN status_in BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE student
    SET student_name = name_in,
        student_age = age_in,
        student_status = status_in
    WHERE student_id = id_in;
end;
$$;

CALL update_student();

CREATE OR REPLACE PROCEDURE delete_student(IN id_in INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM student
    WHERE student_id = id_in;
end;
$$;

-- Tính tổng số sv theo tuổi
/*
    INPUT: age_in
    OUTPUT: cnt_student
 */

CREATE OR REPLACE PROCEDURE cnt_student_by_age(
    IN age_in INT,
    OUT cnt_student INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT count(s.student_id) INTO cnt_student
    FROM student s
    WHERE s.student_age = age_in;
end;
$$;
-- GỌI PROCEDURE có tham số trả ra
DO $$
    DECLARE --khai báo biến
        cnt INT;
    BEGIN
        CALL cnt_student_by_age(24, cnt);
        RAISE NOTICE 'So luong sinh vien: %', cnt;
    end;
$$;
-- Viết procedure tính tổng tuổi của các sv trên 20 tuổi - for

CREATE PROCEDURE sum_age(IN age_in INT, OUT sum_age INT)
LANGUAGE plpgsql
AS $$
    DECLARE student_row RECORD;
BEGIN
    sum_age := 0;
    FOR student_row IN
    SELECT s.student_name, s.student_age
    FROM student s
    WHERE s.student_age > age_in
        LOOP
            -- Tính tổng tuổi
            sum_age := sum_age + student_row.student_age;
        end loop;
end;
$$;
DO $$
    DECLARE sum_student_age INT;
    BEGIN
        CALL sum_age(20, sum_student_age);
        RAISE NOTICE 'Tong tuoi cac sv tren 20 tuoi: %', sum_student_age;
    end;
$$;

/*
1. Xây dựng csdl Session_08_example
2. Xây dụng bảng có tên BOOK gồm
    - Mã sách
 */

CREATE DATABASE Session_08_example;

CREATE TABLE book (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    price FLOAT CHECK (price > 0),
    author VARCHAR(200),
    status BOOLEAN
);

CREATE OR REPLACE PROCEDURE create_book(
    IN name_in VARCHAR,
    IN price_in INT,
    IN author_in VARCHAR,
    IN status_in BOOLEAN
)
    LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO book(name, price, author, status)
    VALUES (name_in, price_in, author_in, status_in);
end;
$$;

CALL create_book('Lap trình C', 36.5, 'Ha Xuan Dai', true);

CREATE OR REPLACE PROCEDURE update_book(
    IN id_in INT,
    IN name_in VARCHAR,
    IN price_in FLOAT,
    IN author_in VARCHAR,
    IN status_in BOOLEAN
)
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE book
    SET name = name_in,
        price = price_in,
        author = author_in,
        status = status_in
    WHERE id = id_in;
END;
$$;

CALL update_book('Lap trình C++', 50.0, 'Ha Xuan Dai', true);

CREATE OR REPLACE PROCEDURE delete_book(IN id_in INT)
    LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM book WHERE id = id_in;
END;
$$;

CALL delete_book(1);


CREATE OR REPLACE PROCEDURE sum_author(
    IN author_in VARCHAR(200),
    OUT sum_price FLOAT
)
    LANGUAGE plpgsql
AS $$
BEGIN
    SELECT sum(b.price) INTO sum_price
    FROM book b
    WHERE b.author like author_in;
end;
$$;

DO $$
    DECLARE sum_author_price INT;
    BEGIN
        CALL sum_author('Ha Xuan Dai');
        RAISE NOTICE 'Tong gia cac sach theo tac gia: %', sum_author_price;
    end;
$$;

CREATE OR REPLACE PROCEDURE stat_books_by_author_for()
    LANGUAGE plpgsql
AS $$
DECLARE
    DECLARE book_row RECORD;
BEGIN
    FOR book_row IN
    SELECT b.author, COUNT(b.id) as total
    FROM book b
    GROUP BY author
        LOOP
            RAISE NOTICE 'Tac gia: %, So luong: %', book_row.author, book_row.total;
        END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE stat_books_by_author_while()
    LANGUAGE plpgsql
AS $$
DECLARE
    v_author VARCHAR(200);
    v_cntBook INT;
    cur_stat CURSOR FOR SELECT b.author, COUNT(b.id) as total
                        FROM book b
                        GROUP BY author;
BEGIN
    OPEN cur_stat;
    FETCH cur_stat INTO v_author, v_cntBook;
    WHILE FOUND LOOP
            RAISE NOTICE 'Tac gia: %, So luong: %', v_author, v_cntBook;
            FETCH cur_stat INTO  v_author, v_cntBook;
        END LOOP;
    CLOSE cur_stat;
END;
$$;

CALL stat_books_by_author_while();



CREATE TABLE order_detail (
    id SERIAL PRIMARY KEY,
    order_id INT,
    product_name VARCHAR(100),
    quantity INT,
    unit_price NUMERIC
);

CREATE OR REPLACE PROCEDURE calculate_order_total (
    IN order_id_input INT,
    OUT total NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT sum(od.unit_price) INTO total
    FROM order_detail od
    WHERE od.order_id = order_id_input;
end;
$$;

DO $$
    DECLARE v_total NUMERIC;
    BEGIN
        CALL calculate_order_total(101, v_total);
        RAISE NOTICE 'Tổng giá trị đơn hàng 101 là: %', v_total;
    END
$$;



CREATE TABLE inventory (
    product_id SERIAL PRIMARY KEY,
    prodcut_name VARCHAR(100),
    quantity INT
);

CREATE OR REPLACE PROCEDURE check_stock(
    IN p_id INT,
    IN p_qty INT
)
    LANGUAGE plpgsql
AS $$
DECLARE v_current_qty INT;
BEGIN
    SELECT quantity INTO v_current_qty
    FROM inventory
    WHERE product_id = p_id;

    IF v_current_qty < p_qty THEN
        RAISE EXCEPTION 'Không đủ hàng trong kho (Hiện có: %, Cần: %)', v_current_qty, p_qty;
    ELSE
        RAISE NOTICE 'Đủ hàng! Sản phẩm % có sẵn % đơn vị.', p_id, v_current_qty;
    END IF;
END;
$$;



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
    -- DECLARE p_level INT; p_salary NUMERIC;
BEGIN
    UPDATE employees e
    SET salary = salary * (1 + (job_level * 0.05))
    WHERE e.emp_id = p_emp_id
    RETURNING salary INTO p_new_salary;
    -- SELECT e.job_level INTO p_level
    -- FROM employees e
    -- WHERE e.emp_id = p_emp_id;
    -- SELECT e.salary INTO p_salary
    -- FROM employees e
    -- WHERE e.emp_id = p_emp_id;
    -- IF p_level = 1 then
        -- p_new_salary := p_salary * 1.05;
    -- ELSIF p_level = 2 then
        -- p_new_salary := p_salary * 1.1;
    -- ELSE p_new_salary := p_salary * 1.15;
    -- END IF;
    -- UPDATE employees e
    -- SET salary = p_new_salary
    -- WHERE e.emp_id = p_emp_id;
end;
$$;

CALL adjust_salary(3, p_new_salary);
SELECT p_new_salary;



CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price NUMERIC,
    discount_percent INT
);

CREATE OR REPLACE PROCEDURE calculate_discount(
    IN p_id INT,
    OUT p_final_price NUMERIC
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_price NUMERIC;
    v_discount INT;
    v_applied_discount INT;
BEGIN
    SELECT price, discount_percent INTO v_price, v_discount
    FROM products
    WHERE id = p_id;
    IF v_discount > 50 THEN
        v_applied_discount := 50;
    ELSE
        v_applied_discount := v_discount;
    END IF;
    p_final_price := v_price - (v_price * v_applied_discount / 100);

    UPDATE products
    SET price = p_final_price
    WHERE id = p_id;
END;
$$;

CALL calculate_discount(2, p_final_price);
SELECT p_final_price;




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
