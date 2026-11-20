# Validación local

En Fedora con Podman y la imagen oficial `postgres:17`, el comando del README `./scripts/verify.sh` finalizó con código 0.

- PostgreSQL creó 11 tablas, 7 índices secundarios y 2 vistas.
- El conjunto de datos produjo 19, 48 y 0 unidades en las tres posiciones de ejemplo.
- La conciliación produjo un total de 8.200 CLP, abonos por 5.000 CLP y un saldo de 3.200 CLP. Las consultas de excepción devolvieron cero filas.
- Once operaciones inválidas fueron rechazadas con el SQLSTATE esperado. También pasaron tres comprobaciones de saldos, incluida la de un pedido vacío.
- El flujo de GitHub Actions ejecuta el mismo script con Docker. Su ejecución remota queda pendiente de publicación.
