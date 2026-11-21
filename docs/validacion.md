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
| Cliente gráfico | DBeaver Community 26.2.4 abrió 04_demo.sql y confirmó la conexión a PostgreSQL 17.12 mediante JDBC 42.7.13. El navegador mostró las 13 tablas y la primera consulta devolvió cuatro filas en el editor |
| PowerShell 7 en Fedora | El analizador aceptó ambos scripts. El comando rechazó un puerto fuera de rango antes de llamar al motor. |
| Windows | El flujo de GitHub Actions verifica sintaxis y manejo de argumentos en Windows. El ciclo de PowerShell con contenedores Linux se ejecuta en Ubuntu con Docker. La ejecución manual de Docker Desktop y DBeaver en Windows queda pendiente. |

La prueba de consumo con cero gramos de la guía corresponde a un caso `23514` en la suite. El plan de peso sirve para analizar la muestra con DBeaver. El planificador puede elegir otra estrategia según los datos.

El ciclo actualizado en Fedora comprobó 13 tablas tras el arranque y conservó una fila insertada por la prueba después de detener y volver a iniciar la instancia.
