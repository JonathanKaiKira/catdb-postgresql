# Diseño físico y decisiones

- **Identidad e integridad.** Claves sustitutas `bigint` con identidad para entidades y claves compuestas para asociaciones, posiciones y líneas. Las claves foráneas conservan referencias históricas e impiden borrar filas padre referenciadas. La referencia compuesta de movimientos comprueba que la pareja bodega y producto existe.
- **Importes y tiempo.** `numeric(14,2)` permite cálculo decimal exacto. Las restricciones descartan importes negativos, pagos nulos en valor y el valor especial `NaN`. Las cantidades de producto son enteros y las fechas de eventos usan `timestamptz`. La muestra declara las horas en UTC.
- **Stock derivado.** El signo de cada movimiento se valida según su tipo. El saldo se obtiene sumando los movimientos y la unión externa incluye posiciones con cero eventos. El historial puede corregirse mediante ajustes. El modelo no impone un historial inmutable ni bloquea saldos negativos concurrentes.
- **Conciliación.** Líneas y pagos se agrupan por separado antes de unirse al pedido para evitar que una combinación de varias líneas y varios pagos multiplique sus importes.
- **Instalación.** El DDL y la carga ficticia se ejecutan en transacciones separadas. Las consultas de lectura referencian el esquema explícitamente. La prueba usa una transacción reversible para sus cambios lógicos. Las secuencias de PostgreSQL pueden avanzar incluso cuando se revierten inserciones.

## Índices secundarios

| Índice | Acceso previsto |
| --- | --- |
| `products_category_idx` | Productos por categoría y comprobación de referencias al borrar categorías |
| `product_suppliers_supplier_idx` | Productos por proveedor |
| `inventory_positions_product_idx` | Bodegas habilitadas para un producto |
| `sales_orders_customer_date_idx` | Historial de pedidos por cliente y rango de fechas |
| `order_items_product_idx` | Líneas históricas por producto |
| `payments_order_idx` | Pagos asociados a un pedido |
| `stock_movements_position_date_idx` | Historial por posición y rango temporal |

Las claves primarias y restricciones únicas ya crean sus propios índices. Los índices secundarios reflejan patrones de acceso previstos. La muestra sirve para verificar resultados e integridad, y el rendimiento a escala queda por medir con datos representativos.
