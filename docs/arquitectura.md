# Diseño físico y decisiones

- PostgreSQL 17 guarda el modelo en el esquema `catdb`. Las claves de identidad `bigint` separan la identidad interna de nombres y códigos. Las tablas puente usan claves primarias compuestas.
- `date` representa días en visitas, gastos, pesos y tratamientos. `timestamptz` representa instantes en alimentación y actividades. La demostración agrupa consumos por fecha UTC.
- Pesos y consumos se guardan en gramos. Los importes se registran como CLP enteros y PostgreSQL devuelve `bigint` al sumar esos enteros.
- Las claves foráneas impiden borrar referencias con historial activo. No se imponen unicidad de propietario, coherencia temporal entre tablas ni validaciones clínicas. El modelo permite un gato sin responsables y varios responsables con el mismo rol.
- El esquema y la muestra entran en una sola transacción. La demostración persiste en un volumen de Podman. La suite usa una instancia separada, efímera y sin red.

| Índice secundario | Acceso previsto |
| --- | --- |
| `cat_caregivers_caregiver_idx` | Gatos por responsable |
| `feedings_cat_time_idx` | Consumo por gato y hora |
| `feedings_food_idx` | Consumos por alimento y comprobación de referencias |
| `vet_visits_cat_date_idx` | Última visita e historial por gato, con desempate por ID |
| `vet_visits_follow_up_idx` | Rango de seguimientos registrados mediante índice parcial |
| `vaccinations_vaccine_idx` | Visitas por vacuna |
| `treatments_visit_idx` | Medicamentos por visita |
| `treatments_medication_idx` | Tratamientos por medicamento |
| `expenses_cat_date_idx` | Gastos de un gato en un período |
| `activities_cat_time_idx` | Cronología de actividades por gato |

Las claves primarias y restricciones únicas ya crean sus propios índices, incluido `weights(cat_id, measured_on)`. Con pocos registros, un escaneo secuencial puede ser más barato. Para justificar cambios a escala, mide con `EXPLAIN (ANALYZE, BUFFERS)` y un conjunto representativo.
