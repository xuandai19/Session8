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
