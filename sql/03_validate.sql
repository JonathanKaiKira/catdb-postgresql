SELECT warehouses.code, products.sku, balances.quantity_on_hand
FROM inventory_sales.inventory_balances AS balances
JOIN inventory_sales.warehouses USING (warehouse_id)
JOIN inventory_sales.products USING (product_id)
ORDER BY warehouses.code, products.sku;

SELECT order_id, order_total, paid_total, outstanding_balance
FROM inventory_sales.order_balances
ORDER BY order_id;

SELECT warehouses.code, products.sku, balances.quantity_on_hand
FROM inventory_sales.inventory_balances AS balances
JOIN inventory_sales.warehouses USING (warehouse_id)
JOIN inventory_sales.products USING (product_id)
WHERE balances.quantity_on_hand < 0;

SELECT order_id, outstanding_balance
FROM inventory_sales.order_balances
WHERE outstanding_balance < 0;
