# Validación

Ejecuté la demostración en Fedora con Podman rootless y PostgreSQL **17.12**, usando la imagen oficial `postgres:17`.

| Comprobación | Resultado local |
| --- | --- |
| Creación y carga en una base nueva | 13 tablas, 10 índices secundarios y 4 gatos ficticios |
| Integridad | 17 rechazos con SQLSTATE esperado y 3 comprobaciones sobre la muestra |
| Consultas demostrativas | 10 resultados comparados fila por fila con la salida esperada |
| Ejercicios de lectura | Las 5 soluciones ejecutaron y coincidieron con el resultado esperado |
| Diagrama | Mermaid coincide con el catálogo de PostgreSQL. El SVG se generó a partir de ese modelo y se comprobaron sus 13 tablas y 13 aristas |
| Ciclo de Podman | Arranque, arranque repetido, detención con volumen conservado y reinicio con los cuatro gatos |
| Red | `podman port` y `ss` mostraron `127.0.0.1:55432` |
| Cliente gráfico | DBeaver Community 26.2.4 abrió un editor para CatDB y confirmó la conexión a PostgreSQL 17.12 mediante JDBC 42.7.13 |
| GitHub Actions | El flujo está preparado. La ejecución remota depende de la primera publicación |

La prueba de consumo con cero gramos de la guía corresponde a un caso `23514` en la suite. El plan de peso sirve para analizar la muestra con DBeaver. El planificador puede elegir otra estrategia según los datos.
