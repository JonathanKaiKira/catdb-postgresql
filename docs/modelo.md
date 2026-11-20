# Modelo de datos

## Modelo conceptual

Un cliente puede realizar varios pedidos. Cada pedido agrupa líneas y recibe pagos parciales. Cada línea corresponde a un producto y conserva el precio de la venta. Los productos pertenecen a una categoría y pueden tener varios proveedores. Una bodega habilita posiciones para productos y cada posición acumula movimientos de inventario.

## Modelo lógico

Las claves primarias se muestran en el diagrama. También son únicas las claves candidatas de negocio `customers.email`, `suppliers.supplier_code`, `categories.name`, `products.sku`, `warehouses.code` y `payments.reference`. Los campos utilizados en cada relación se detallan en el [DDL](../sql/01_schema.sql).

```mermaid
erDiagram
    CUSTOMERS ||--o{ SALES_ORDERS : realiza
    SALES_ORDERS ||--o{ ORDER_ITEMS : contiene
    SALES_ORDERS ||--o{ PAYMENTS : recibe
    PRODUCTS ||--o{ ORDER_ITEMS : aparece_en
    CATEGORIES ||--o{ PRODUCTS : clasifica
    PRODUCTS ||--o{ PRODUCT_SUPPLIERS : tiene
    SUPPLIERS ||--o{ PRODUCT_SUPPLIERS : suministra
    WAREHOUSES ||--o{ INVENTORY_POSITIONS : habilita
    PRODUCTS ||--o{ INVENTORY_POSITIONS : ocupa
    INVENTORY_POSITIONS ||--o{ STOCK_MOVEMENTS : registra
    CUSTOMERS {
        bigint customer_id PK
    }
    SALES_ORDERS {
        bigint order_id PK
        bigint customer_id FK
    }
    ORDER_ITEMS {
        bigint order_id PK,FK
        integer line_number PK
        bigint product_id FK
    }
    PAYMENTS {
        bigint payment_id PK
        bigint order_id FK
    }
    CATEGORIES {
        bigint category_id PK
    }
    PRODUCTS {
        bigint product_id PK
        bigint category_id FK
    }
    PRODUCT_SUPPLIERS {
        bigint product_id PK,FK
        bigint supplier_id PK,FK
    }
    SUPPLIERS {
        bigint supplier_id PK
    }
    WAREHOUSES {
        bigint warehouse_id PK
    }
    INVENTORY_POSITIONS {
        bigint warehouse_id PK,FK
        bigint product_id PK,FK
    }
    STOCK_MOVEMENTS {
        bigint movement_id PK
        bigint warehouse_id FK
        bigint product_id FK
    }
```

La relación entre movimientos y posiciones usa una sola clave foránea compuesta por `warehouse_id` y `product_id`.

## Normalización

1. **1FN.** Los valores son escalares. Las líneas de pedido, pagos y vínculos entre productos y proveedores residen en filas independientes.
2. **2FN.** En `order_items`, el producto, la cantidad y el precio pactado dependen de la combinación `(order_id, line_number)`. Las otras tablas de clave compuesta representan asociaciones y carecen de atributos no clave.
3. **3FN.** Los nombres de categoría, cliente y proveedor se almacenan en sus entidades. El precio de catálogo depende del producto. El precio pactado depende de la línea y preserva el historial cuando cambia el catálogo. Existencias y saldos se calculan en vistas a partir de movimientos, líneas y pagos.
