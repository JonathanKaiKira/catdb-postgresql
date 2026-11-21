# 09 · Recorrido de 12 minutos

Antes de presentar, sigue la [guía de DBeaver](05-guia-visual.md) para arrancar CatDB y probar la conexión y abre [04_demo.sql](../../sql/04_demo.sql) en DBeaver. Confirma que el controlador JDBC ya se descargó. Ten a mano el [diagrama](../modelo.md) y la [guía de resultados](04-sql-explicado.md).

| Tiempo | Qué haces | Qué explicas |
| --- | --- | --- |
| 00:00–01:00 | Presenta CatHub y abre CatDB en el navegador de bases | Preguntas que resuelve y datos ficticios |
| 01:00–03:00 | Abre `cats`, mira sus cuatro filas y recorre el diagrama hasta `cat_caregivers` | Identidad, N:M y rol en la tabla puente |
| 03:00–04:30 | Ejecuta 01, 02 y 03 | Catálogo, nacimiento desconocido y Pipa sin responsables |
| 04:30–06:30 | Ejecuta 04, 05 y 06 | Peso y alimentación de Luna. Qué suma el total de 35.000 CLP |
| 06:30–08:30 | Ejecuta 07, 08 y 09 | Corte de ejemplo, última visita y cronología registrada de vacunas y tratamientos |
| 08:30–10:00 | Ejecuta 10 | Una ventana mantiene las filas. La diferencia final de Luna es −50 g |
| 10:00–11:00 | Muestra el `CHECK` de peso y su caso en `tests/integrity.sql` | La restricción la aplica PostgreSQL. La suite espera `23514` |
| 11:00–12:00 | Muestra el resultado de la suite y explica el volumen | Reproducibilidad, qué persiste y límites del proyecto |

Para practicar sin público, cambia `LUNA` por `MILO` en la consulta 04 sin guardar el cambio y predice la salida antes de ejecutarla. Después usa el ejercicio 6 para practicar un rechazo en una transacción que se revierte. Al cerrar la sesión, detén la instancia con `.\scripts\demo.ps1 stop` en Windows o `./scripts/demo.sh stop` en Fedora para conservar los datos.
