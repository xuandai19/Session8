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
