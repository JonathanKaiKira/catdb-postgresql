# 04 · SQL explicado

Abre [sql/04_demo.sql](../../sql/04_demo.sql) en DBeaver con la conexión CatDB. Coloca el cursor dentro de una sentencia y ejecuta **Execute SQL Statement** (`Ctrl+Enter`). Avanza en orden y contrasta cada cuadrícula con esta tabla. El archivo [demo.expected](../../tests/demo.expected) contiene todas las filas verificadas y usa `<NULL>` para valores ausentes.

| Consulta | Qué hacer y por qué | Resultado esperado |
| --- | --- | --- |
| 01 | Ejecuta el catálogo. `ORDER BY` fija el orden por código | Luna, Milo, Nube y Pipa |
| 02 | Busca fechas ausentes con `IS NULL` | Solo `NUBE` |
| 03 | Sigue los dos `LEFT JOIN` desde gatos por los IDs de la tabla puente | Cinco filas. Luna aparece con dos responsables y Pipa con alias y rol nulos |
| 04 | Filtra por `LUNA`. Cambia el filtro a `MILO` para comparar | Luna registra 4.100, 4.200 y 4.150 g. Milo registra 5.200 y 5.150 g |
| 05 | Sigue las FK de consumo hacia gato y alimento. Observa el día en UTC | El 10 de mayo Luna consumió 85 g de Húmedo A y 30 g de Seco B |
| 06 | Lee `GROUP BY` como «una fila por código». `COALESCE` convierte un total ausente en cero | Luna 35.000, Milo 26.000, Nube 9.000 y Pipa 0 CLP |
| 07 | Cambia el corte del 15 de mayo al 4 de junio para confirmar el filtro | Antes del cambio aparecen Luna (3 de junio) y Milo (8 de junio). Después queda Milo |
| 08 | Observa cómo `LATERAL` busca una fila por gato. El ID desempata visitas del mismo día | Luna 3 de mayo, Milo 8, Nube 9 y Pipa sin fecha |
| 09 | Lee cada rama de `UNION ALL` antes de ejecutar la sentencia completa | Vacuna de Luna del 3 de mayo y tratamiento de Milo del 8 de mayo |
| 10 | Compara cada peso con `LAG`. La partición reinicia la comparación para cada gato | Luna `NULL`, +100 y −50 g. Milo `NULL` y −50 g. Nube `NULL` |

Un `JOIN` combina filas relacionadas. La FK impide que una referencia apunte a una fila inexistente aunque nadie ejecute el `JOIN`. El `LEFT JOIN` conserva filas de la izquierda sin coincidencia. `GROUP BY` combina varias filas en un total por grupo, mientras que una función de ventana mantiene cada fila original.

Practica con este plan. La restricción única de pesos ofrece un índice por gato y fecha. En la muestra es normal que el planificador escoja un escaneo secuencial.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT measured_on, grams
FROM catdb.weights
WHERE cat_id = (SELECT cat_id FROM catdb.cats WHERE cat_code = 'LUNA')
ORDER BY measured_on;
```
