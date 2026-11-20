# Requisitos de negocio

| ID | Requisito | Implementación |
| --- | --- | --- |
| RF-01 | Identificar clientes por correo y productos por SKU. Clasificar cada producto en una categoría. | `customers`, `products`, `categories` |
| RF-02 | Asociar un producto con varios proveedores y gestionar varios productos por proveedor. | `suppliers`, `product_suppliers` |
| RF-03 | Habilitar posiciones por bodega y producto. Registrar entradas, salidas y ajustes en cada posición habilitada. | `warehouses`, `inventory_positions`, `stock_movements` |
| RF-04 | Consultar existencias por posición, incluidas las posiciones sin movimientos. | `inventory_balances` |
| RF-05 | Registrar pedidos por cliente y líneas numeradas con cantidad positiva y precio acordado. | `sales_orders`, `order_items` |
| RF-06 | Registrar uno o varios pagos por pedido con referencia única e importe positivo. | `payments` |
| RF-07 | Calcular total, pagos y saldo por cobrar. Identificar existencias negativas y sobrepagos. | `order_balances`, `sql/03_validate.sql` |

La moneda es CLP para todo el conjunto. El pedido puede existir vacío durante su preparación. Cada movimiento representa un evento de inventario y se registra independientemente de los pedidos. La conciliación muestra diferencias para revisión. La reserva de stock, la trazabilidad entre despacho y pedido, las transiciones de estado, la facturación y el rechazo transaccional de saldo negativo o sobrepago quedan para una etapa posterior.
