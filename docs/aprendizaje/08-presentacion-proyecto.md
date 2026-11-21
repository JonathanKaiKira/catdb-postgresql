# 08 · Presentar CatDB

## Aproximadamente dos minutos para reclutadores

«CatDB es el primer proyecto de CatHub. Diseñé una base de datos relacional para seguir el cuidado de gatos ficticios. Una misma persona puede cuidar a varios gatos y cada gato puede guardar un historial de alimentación, peso, visitas y gastos.

En DBeaver puedo abrir el diagrama y seguir el camino desde una ficha hasta los datos relacionados. Por ejemplo, Luna tiene dos responsables, tres registros de peso y 35.000 pesos chilenos de gastos. Pipa todavía carece de movimientos, y sigue apareciendo en el reporte con un gasto de cero.

Implementé el modelo en PostgreSQL 17. Las restricciones verifican que las referencias existan y que pesos y consumos sean positivos. Podman en Fedora y Docker Desktop en Windows reproducen el escenario. La demostración conserva sus datos al detenerse y las pruebas crean su propia instancia de base de datos.

Preparé diez consultas comentadas y ejercicios, porque quería poder justificar el modelo y demostrar que sus resultados se pueden reproducir.»

## Entrevista técnica

1. Empieza por la N:M de responsabilidades y muestra cómo la PK compuesta y las FK protegen el vínculo.
2. Sigue la ruta gato → visita → vacunación. Justifica que el gato se derive de la visita. Explica la diferencia entre una medida por día y un consumo por instante.
3. Ejecuta las consultas 06 y 10. Compara el resultado de agrupación con el de una ventana. Señala cómo se conserva a Pipa en la primera.
4. Muestra el índice compuesto de visitas, el índice parcial y el plan de peso de la [guía SQL](04-sql-explicado.md). Explica por qué un conjunto pequeño puede usar un escaneo secuencial.
5. Abre `tests/integrity.sql`, elige un SQLSTATE y explica qué comprueba. Distingue la base persistente de la base de pruebas.
6. Cierra con una mejora posible y su condición de negocio. Por ejemplo, si cambian los responsables en el tiempo, modelar períodos y decidir cómo tratar solapamientos.
