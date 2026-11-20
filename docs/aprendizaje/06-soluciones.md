# Soluciones

## 1 · Nacimiento conocido

```sql
SELECT cat_code FROM catdb.cats
WHERE birth_date IS NOT NULL ORDER BY birth_date, cat_code;
```

MILO, LUNA y PIPA. Los valores nulos quedan fuera mediante `IS NOT NULL`.

## 2 · Responsables

```sql
SELECT c.name, link.role
FROM catdb.cat_caregivers AS link
JOIN catdb.cats AS c USING (cat_id)
JOIN catdb.caregivers AS r USING (caregiver_id)
WHERE r.alias = 'Casa Norte'
ORDER BY c.cat_code;
```

Luna y Milo, ambos con rol `owner`. El vínculo guarda el rol de cada pareja.

## 3 · Conteo

```sql
SELECT c.cat_code, count(v.visit_id) AS visits
FROM catdb.cats AS c LEFT JOIN catdb.vet_visits AS v USING (cat_id)
GROUP BY c.cat_code ORDER BY c.cat_code;
```

Luna 2, Milo 1, Nube 1 y Pipa 0. `count(v.visit_id)` ignora el nulo generado por la unión externa en la fila de Pipa.

## 4 · Consumo diario

```sql
SELECT c.cat_code, sum(f.grams)
FROM catdb.feedings AS f JOIN catdb.cats AS c USING (cat_id)
WHERE f.fed_at >= TIMESTAMPTZ '2030-05-10 00:00+00'
  AND f.fed_at < TIMESTAMPTZ '2030-05-11 00:00+00'
GROUP BY c.cat_code ORDER BY c.cat_code;
```

Luna 115 g y Milo 45 g. El intervalo incluye el inicio y excluye la medianoche del día siguiente.

## 5 · Comparación de peso

```sql
SELECT w.measured_on, w.grams,
       lag(w.grams) OVER (ORDER BY w.measured_on) AS previous_grams,
       w.grams - lag(w.grams) OVER (ORDER BY w.measured_on) AS delta_grams
FROM catdb.weights AS w JOIN catdb.cats AS c USING (cat_id)
WHERE c.cat_code = 'LUNA'
ORDER BY w.measured_on DESC LIMIT 1;
```

1 de mayo, 4.150 g, 4.200 g previos y −50 g. La ventana se calcula antes de limitar la salida a una fila.

## 6 · Restricción

Ejecuta las tres sentencias por separado en la misma sesión. Si el cliente revierte la transacción automáticamente después del error, la última sentencia puede informar que ya no hay transacción activa.

```sql
BEGIN;
INSERT INTO catdb.feedings (cat_id, food_id, fed_at, grams)
SELECT c.cat_id, f.food_id, TIMESTAMPTZ '2030-05-12 12:00+00', 0
FROM catdb.cats AS c CROSS JOIN catdb.foods AS f
WHERE c.cat_code = 'LUNA' AND f.name = 'Seco B';
ROLLBACK;
```

PostgreSQL devuelve `23514` por violar `CHECK (grams > 0)`.
