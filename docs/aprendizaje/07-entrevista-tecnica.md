# 07 · Entrevista técnica

**1. ¿Qué problema resuelve CatDB?** Centraliza el historial de cuidados. Permite cruzar gatos, responsables, consumo, peso, consultas y gastos con reglas verificables.

**2. ¿Por qué PostgreSQL?** Soporta integridad declarativa, transacciones, funciones de ventana, índices parciales y tipos temporales adecuados. La imagen 17 facilita repetir el entorno.

**3. ¿Cómo encontraste las entidades?** Separé fichas, catálogos y hechos. Un peso es un hecho fechado de un gato, y un alimento tiene atributos compartidos entre muchos consumos.

**4. ¿Dónde hay una relación 1:N?** Un gato puede tener muchas mediciones y cada medición pertenece a un gato. `weights.cat_id` es una FK obligatoria.

**5. ¿Dónde hay una N:M?** Una persona puede cuidar varios gatos y un gato puede tener varias personas. `cat_caregivers` materializa las parejas y guarda el rol.

**6. ¿Qué aporta la PK compuesta?** Impide duplicar una pareja gato–persona o visita–vacuna. Sus componentes son también claves foráneas.

**7. ¿Qué es 3FN?** Formalmente, para una dependencia funcional no trivial, el determinante debe ser superclave o el atributo dependiente debe pertenecer a alguna clave candidata. Aquí separé los datos descriptivos de los hechos. Llego al gato de un tratamiento por la visita.

**8. ¿Cómo se mantiene la integridad?** Con PK, FK, `NOT NULL`, `UNIQUE` y `CHECK`. La base comprueba reglas incluso para una escritura directa desde DBeaver.

**9. ¿Qué hace PostgreSQL si el seguimiento es nulo?** La comparación de fechas da desconocido, lo que satisface el `CHECK`. Si hay una fecha, debe ser posterior a la visita.

**10. ¿Cómo verificaste los rechazos?** Intenté escrituras inválidas en una transacción y comprobé SQLSTATE. Por ejemplo, consumo positivo usa `23514` ante un cero y una FK huérfana produce `23503`.

**11. ¿Por qué existen dos índices para visitas?** El compuesto favorece la última visita de un gato. El parcial cubre búsquedas por fecha de seguimiento entre visitas que sí tienen una fecha.

**12. ¿Por qué un índice puede no usarse?** El planificador estima costos. Recorrer unas pocas filas puede ser más barato que acceder mediante índice. Lo mediría con datos representativos y `EXPLAIN (ANALYZE, BUFFERS)`.

**13. ¿Cómo mantienes a Pipa en los resultados?** Parto de `cats` y uso `LEFT JOIN`. En gastos, `COALESCE` representa la ausencia de importes como cero.

**14. ¿Cuándo usarías `LAG`?** Para medir la diferencia respecto de la fila anterior sin colapsar las filas. Particiono por gato y ordeno por fecha.

**15. ¿Cómo se reproduce el entorno?** Podman carga el esquema y la muestra juntos en una transacción. El entorno de demostración conserva el volumen y la suite crea una base efímera sin red.

**16. ¿Qué cambia al escalar?** Revisaría consultas reales, cardinalidad y costo de escritura de los índices. La paginación y una estrategia de retención pueden cobrar importancia en cronologías.

**17. ¿Qué reglas agregarías con una aplicación?** Definiría historial de responsables y permisos de acceso antes de ampliarlo. Cualquier regla entre tablas, como comparar el inicio de un tratamiento con una fecha de visita, requiere una decisión de negocio y pruebas de concurrencia si aplica.

**18. ¿Cómo evitas que el diagrama se desactualice?** Una consulta lee tablas, campos y claves del catálogo PostgreSQL. La suite compara esa salida con el Mermaid versionado.
