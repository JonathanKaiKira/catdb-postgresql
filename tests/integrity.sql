BEGIN;
SET LOCAL search_path TO inventory_sales, pg_catalog;

CREATE FUNCTION pg_temp.expect_sqlstate(statement text, expected_sqlstate text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE statement;
    RAISE EXCEPTION 'Se esperaba SQLSTATE % para %', expected_sqlstate, statement;
EXCEPTION WHEN OTHERS THEN
    IF SQLSTATE <> expected_sqlstate THEN
        RAISE;
    END IF;
END;
$$;

SELECT pg_temp.expect_sqlstate(
    $$INSERT INTO customers (email, full_name) VALUES ('ana@example.test', 'Otra persona')$$,
    '23505');
SELECT pg_temp.expect_sqlstate(
    $$INSERT INTO customers (email, full_name) VALUES (NULL, 'Otra persona')$$, '23502');
SELECT pg_temp.expect_sqlstate(
    $$INSERT INTO sales_orders (customer_id) VALUES (-1)$$, '23503');
SELECT pg_temp.expect_sqlstate(
    $$INSERT INTO order_items SELECT * FROM order_items$$, '23505');
SELECT pg_temp.expect_sqlstate(
    $$UPDATE order_items SET quantity = 0$$, '23514');
SELECT pg_temp.expect_sqlstate(
    $$UPDATE order_items SET unit_price = 'NaN'$$, '23514');
SELECT pg_temp.expect_sqlstate(
    $$UPDATE payments SET amount = -1$$, '23514');
SELECT pg_temp.expect_sqlstate(
    $$INSERT INTO payments (order_id, reference, amount)
      SELECT order_id, reference, amount FROM payments$$, '23505');
SELECT pg_temp.expect_sqlstate(
    $$UPDATE stock_movements SET movement_type = 'shipment', quantity_delta = 1$$, '23514');
SELECT pg_temp.expect_sqlstate(
    $$UPDATE stock_movements SET warehouse_id = (SELECT warehouse_id FROM warehouses
       WHERE code = 'VAP') WHERE product_id = (SELECT product_id FROM products
       WHERE sku = 'BOX-01')$$, '23503');
SELECT pg_temp.expect_sqlstate(
    $$DELETE FROM products WHERE sku = 'NOTE-01'$$, '23503');

DO $$
BEGIN
    IF (SELECT count(*) FROM order_balances) <> 1 OR NOT EXISTS (
        SELECT FROM order_balances
        WHERE order_total = 8200 AND paid_total = 5000 AND outstanding_balance = 3200
    ) THEN
        RAISE EXCEPTION 'Los totales del pedido son incorrectos';
    END IF;

    IF EXISTS (
        (SELECT warehouses.code, products.sku, balances.quantity_on_hand
         FROM inventory_balances AS balances
         JOIN warehouses USING (warehouse_id)
         JOIN products USING (product_id)
         EXCEPT ALL VALUES ('SCL', 'NOTE-01', 48), ('SCL', 'BOX-01', 19), ('VAP', 'NOTE-01', 0))
        UNION ALL
        (VALUES ('SCL', 'NOTE-01', 48), ('SCL', 'BOX-01', 19), ('VAP', 'NOTE-01', 0)
         EXCEPT ALL
         SELECT warehouses.code, products.sku, balances.quantity_on_hand
         FROM inventory_balances AS balances
         JOIN warehouses USING (warehouse_id)
         JOIN products USING (product_id))
    ) THEN
        RAISE EXCEPTION 'Las existencias de la muestra son incorrectas';
    END IF;

    INSERT INTO sales_orders (customer_id)
    SELECT customer_id FROM customers WHERE email = 'leo@example.test';

    IF NOT EXISTS (
        SELECT FROM order_balances
        JOIN sales_orders USING (order_id)
        JOIN customers USING (customer_id)
        WHERE email = 'leo@example.test' AND order_total = 0
            AND paid_total = 0 AND outstanding_balance = 0
    ) THEN
        RAISE EXCEPTION 'El pedido vacío debe tener saldo cero';
    END IF;
END;
$$;

ROLLBACK;
\echo 'Integridad verificada (11 rechazos esperados y 3 comprobaciones de saldos).'
