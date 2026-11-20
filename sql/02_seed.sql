BEGIN;
SET LOCAL search_path TO inventory_sales, pg_catalog;

INSERT INTO customers (email, full_name) VALUES
    ('ana@example.test', 'Ana Rojas'), ('leo@example.test', 'Leo Soto');
INSERT INTO suppliers (supplier_code, name) VALUES
    ('SUM-A', 'Suministros Andinos'), ('SUM-B', 'Distribuidora Austral');
INSERT INTO categories (name) VALUES ('Oficina'), ('Embalaje');
INSERT INTO products (sku, name, category_id, list_price)
SELECT sample.sku, sample.name, categories.category_id, sample.price
FROM (VALUES ('NOTE-01', 'Cuaderno', 'Oficina', 3500),
             ('BOX-01', 'Caja mediana', 'Embalaje', 1800))
    AS sample(sku, name, category_name, price)
JOIN categories ON categories.name = sample.category_name;

INSERT INTO product_suppliers (product_id, supplier_id)
SELECT products.product_id, suppliers.supplier_id
FROM products CROSS JOIN suppliers
WHERE products.sku = 'NOTE-01' OR suppliers.supplier_code = 'SUM-B';

INSERT INTO warehouses (code) VALUES ('SCL'), ('VAP');
INSERT INTO inventory_positions (warehouse_id, product_id)
SELECT warehouse_id, product_id
FROM warehouses CROSS JOIN products
WHERE code = 'SCL' OR sku = 'NOTE-01';

INSERT INTO stock_movements
    (warehouse_id, product_id, movement_type, quantity_delta, occurred_at)
SELECT warehouses.warehouse_id, products.product_id, sample.kind, sample.delta,
       sample.event_time::timestamptz
FROM (VALUES ('NOTE-01', 'receipt', 50, '2026-01-14 09:00+00'),
             ('NOTE-01', 'shipment', -2, '2026-01-15 12:50+00'),
             ('BOX-01', 'receipt', 20, '2026-01-14 10:00+00'),
             ('BOX-01', 'shipment', -1, '2026-01-15 12:50+00'))
    AS sample(sku, kind, delta, event_time)
JOIN products USING (sku)
JOIN warehouses ON warehouses.code = 'SCL';

WITH sample_order AS (
    INSERT INTO sales_orders (customer_id, ordered_at)
    SELECT customer_id, '2026-01-15 12:00+00'
    FROM customers WHERE email = 'ana@example.test'
    RETURNING order_id
), sample_items AS (
    INSERT INTO order_items (order_id, line_number, product_id, quantity, unit_price)
    SELECT sample_order.order_id, sample.line_number, products.product_id,
           sample.quantity, sample.price
    FROM (VALUES ('NOTE-01', 1, 2, 3200), ('BOX-01', 2, 1, 1800))
        AS sample(sku, line_number, quantity, price)
    JOIN products USING (sku)
    CROSS JOIN sample_order
)
INSERT INTO payments (order_id, reference, amount, paid_at)
SELECT order_id, sample.reference, sample.amount, sample.event_time::timestamptz
FROM sample_order
CROSS JOIN (VALUES ('DEMO-001', 3000, '2026-01-15 12:05+00'),
                   ('DEMO-002', 2000, '2026-01-15 12:10+00'))
    AS sample(reference, amount, event_time);

COMMIT;
