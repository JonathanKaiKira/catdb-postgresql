-- Deriva el diagrama del catálogo, conservando columnas y claves compuestas.
WITH tables AS (
    SELECT c.oid, c.relname
    FROM pg_class AS c JOIN pg_namespace AS n ON n.oid = c.relnamespace
    WHERE n.nspname = 'catdb' AND c.relkind = 'r'
), elements AS (
    SELECT t.relname AS label, 0 AS position, format('    %s {', t.relname) AS line
    FROM tables AS t
    UNION ALL
    SELECT t.relname, a.attnum,
           format('        %s %s%s', type.typname
               COLLATE "C", a.attname,
               coalesce(' ' || nullif(concat_ws(',',
                   CASE WHEN EXISTS (SELECT FROM pg_constraint WHERE conrelid = t.oid
                       AND contype = 'p' AND a.attnum = ANY(conkey)) THEN 'PK' END,
                   CASE WHEN EXISTS (SELECT FROM pg_constraint WHERE conrelid = t.oid
                       AND contype = 'f' AND a.attnum = ANY(conkey)) THEN 'FK' END,
                   CASE WHEN EXISTS (SELECT FROM pg_constraint WHERE conrelid = t.oid
                       AND contype = 'u' AND cardinality(conkey) = 1
                       AND a.attnum = ANY(conkey)) THEN 'UK' END
               ), ''), ''))
    FROM tables AS t
    JOIN pg_attribute AS a ON a.attrelid = t.oid
    JOIN pg_type AS type ON type.oid = a.atttypid
    WHERE a.attnum > 0 AND NOT a.attisdropped
    UNION ALL
    SELECT relname, 10000, '    }' FROM tables
    UNION ALL
    SELECT parent.relname, 20000,
           format('    %s %s%so{ %s : %s', parent.relname,
               CASE WHEN EXISTS (
                   SELECT FROM pg_attribute AS a WHERE a.attrelid = child.oid
                       AND a.attnum = ANY(fk.conkey) AND NOT a.attnotnull
               ) THEN '|o' ELSE '||' END,
               CASE WHEN EXISTS (
                   SELECT FROM pg_constraint AS pk WHERE pk.conrelid = child.oid
                       AND pk.contype = 'p' AND fk.conkey <@ pk.conkey
               ) THEN '--' ELSE '..' END,
               child.relname, a.attname)
    FROM pg_constraint AS fk
    JOIN tables AS child ON child.oid = fk.conrelid
    JOIN tables AS parent ON parent.oid = fk.confrelid
    JOIN pg_attribute AS a ON a.attrelid = child.oid AND a.attnum = fk.conkey[1]
    WHERE fk.contype = 'f'
)
SELECT line FROM (
    SELECT '' AS label, -1 AS position, 'erDiagram' AS line
    UNION ALL
    SELECT * FROM elements
) AS diagram
ORDER BY label COLLATE "C", position, line COLLATE "C";
