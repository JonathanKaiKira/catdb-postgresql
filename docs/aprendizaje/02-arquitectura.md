# 02 · Arquitectura

`sql/01_schema.sql` define la estructura, `02_seed.sql` carga el escenario y `04_demo.sql` contiene los ejemplos. `scripts/demo.sh` en Fedora y `scripts/demo.ps1` en Windows mantienen el entorno persistente. El comando `test` de cada script ejecuta la misma suite SQL en otro contenedor. El [diagrama](../modelo.md) se valida contra el catálogo de PostgreSQL.

- **Identidad.** El ID se usa para referencias internas y el código `LUNA` sirve como identificador legible en ejemplos.
- **Historial.** Peso y alimentación tienen filas separadas por evento. Así es posible comparar períodos sin sobrescribir mediciones.
- **Relaciones.** La visita identifica el gato de cada vacuna y tratamiento. Guardar el gato también en esas tablas crearía dos lugares que podrían discrepar.
- **Ciclo de vida.** La carga inicial se ejecuta en una transacción y el volumen conserva los cambios al detener el contenedor. Las pruebas usan datos nuevos cada vez.

Consulta el [diseño físico](../arquitectura.md) para explicar los tipos, los índices y las decisiones que quedaron fuera del modelo.
