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
