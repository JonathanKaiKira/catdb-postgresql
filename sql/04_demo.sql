-- 01. SELECT y ORDER BY: catálogo de gatos por código.
SELECT cat_code, name, coat FROM catdb.cats ORDER BY cat_code;

-- 02. WHERE: fecha de nacimiento desconocida.
SELECT cat_code FROM catdb.cats WHERE birth_date IS NULL ORDER BY cat_code;

-- 03. LEFT JOIN: conserva gatos aunque todavía no tengan responsables.
SELECT c.cat_code, r.alias, cr.role
FROM catdb.cats AS c
LEFT JOIN catdb.cat_caregivers AS cr USING (cat_id)
LEFT JOIN catdb.caregivers AS r USING (caregiver_id)
ORDER BY c.cat_code, r.alias COLLATE "C";

-- 04. JOIN y filtro: historial de peso de Luna.
SELECT w.measured_on, w.grams
FROM catdb.weights AS w JOIN catdb.cats AS c USING (cat_id)
WHERE c.cat_code = 'LUNA'
ORDER BY w.measured_on;

-- 05. Cadena de JOIN: consumo de Luna con nombres de alimentos.
SELECT (f.fed_at AT TIME ZONE 'UTC')::date AS day_utc, d.name, f.grams
FROM catdb.feedings AS f
JOIN catdb.cats AS c USING (cat_id)
JOIN catdb.foods AS d USING (food_id)
WHERE c.cat_code = 'LUNA'
ORDER BY f.fed_at, f.feeding_id;

-- 06. GROUP BY y COALESCE: gasto total, incluso para gatos sin gastos.
SELECT c.cat_code, COALESCE(sum(e.amount_clp), 0) AS total_clp
FROM catdb.cats AS c LEFT JOIN catdb.expenses AS e USING (cat_id)
GROUP BY c.cat_code ORDER BY total_clp DESC, c.cat_code;

-- 07. Filtro de fechas: seguimientos desde el corte del escenario.
SELECT c.cat_code, v.follow_up_on
FROM catdb.vet_visits AS v JOIN catdb.cats AS c USING (cat_id)
WHERE v.follow_up_on >= DATE '2030-05-15'
ORDER BY v.follow_up_on, c.cat_code, v.visit_id;

-- 08. LATERAL: última visita por gato, incluso si no tiene historial.
SELECT c.cat_code, v.visited_on, v.reason
FROM catdb.cats AS c
LEFT JOIN LATERAL (
    SELECT visited_on, reason
    FROM catdb.vet_visits
    WHERE cat_id = c.cat_id
    ORDER BY visited_on DESC, visit_id DESC
    LIMIT 1
) AS v ON true
ORDER BY c.cat_code;

-- 09. UNION ALL: vacunas y tratamientos en una cronología común.
SELECT c.cat_code, v.visited_on AS event_date, 'vacuna' AS kind, x.name
FROM catdb.vaccinations AS a
JOIN catdb.vaccines AS x USING (vaccine_id)
JOIN catdb.vet_visits AS v USING (visit_id)
JOIN catdb.cats AS c USING (cat_id)
UNION ALL
SELECT c.cat_code, t.started_on, 'tratamiento', m.name
FROM catdb.treatments AS t
JOIN catdb.medications AS m USING (medication_id)
JOIN catdb.vet_visits AS v USING (visit_id)
JOIN catdb.cats AS c USING (cat_id)
ORDER BY event_date, cat_code, kind, name;

-- 10. LAG: cambio de peso frente a la medición anterior del mismo gato.
SELECT c.cat_code, w.measured_on, w.grams,
       w.grams - lag(w.grams) OVER (
           PARTITION BY w.cat_id ORDER BY w.measured_on
       ) AS delta_grams
FROM catdb.weights AS w JOIN catdb.cats AS c USING (cat_id)
ORDER BY c.cat_code, w.measured_on;
