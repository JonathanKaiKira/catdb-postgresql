#!/usr/bin/env bash
# Runs inside the isolated PostgreSQL 17 test container.
set -euo pipefail
cd /tmp/catdb
run_sql() {
    psql -X -v ON_ERROR_STOP=1 -U postgres -d catdb "$@"
}

run_sql -1 -f sql/01_schema.sql -f sql/02_seed.sql
run_sql -f sql/03_validate.sql -f tests/integrity.sql
actual_demo="$(run_sql -qAt -P 'null=<NULL>' < sql/04_demo.sql)"
diff -u tests/demo.expected - <<< "$actual_demo"
actual_exercises="$(sed -n '/^## 6 /q; /^```sql$/,/^```$/{ /^```/d; p; }' docs/aprendizaje/06-soluciones.md | run_sql -qAt)"
diff -u tests/exercises.expected - <<< "$actual_exercises"
actual_diagram="$(run_sql -At < scripts/diagram.sql)"
if [[ "${1:-}" == "--print-diagram" ]]; then
    printf '%s\n' "$actual_diagram"
else
    sed -n '/^```mermaid$/,/^```$/{ /^```/d; p; }' docs/modelo.md |
        diff -u - <(printf '%s\n' "$actual_diagram")
fi
echo 'Consultas demostrativas verificadas (10 consultas).'
echo 'Soluciones de lectura verificadas (5 ejercicios).'
