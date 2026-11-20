#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
engine="${CONTAINER_ENGINE:-podman}"
container_id="$("$engine" run --detach --rm --network none \
    -e POSTGRES_HOST_AUTH_METHOD=trust -e POSTGRES_DB=catdb \
    docker.io/library/postgres:17 postgres -c listen_addresses='')"
trap '"$engine" stop "$container_id" >/dev/null' EXIT

psql_in_container() {
    "$engine" exec -i "$container_id" psql -X -v ON_ERROR_STOP=1 -U postgres -d catdb "$@"
}

# Wait for the final server, rather than the image's bootstrap server.
for ((attempt = 1; attempt <= 60; attempt++)); do
    if "$engine" exec "$container_id" sh -ec '
        test "$(cat /proc/1/comm)" = postgres
        pg_isready -q -U postgres -d catdb
    '; then
        cd "$project_dir"
        cat sql/01_schema.sql sql/02_seed.sql | psql_in_container -1 -f -
        psql_in_container < sql/03_validate.sql
        psql_in_container < tests/integrity.sql
        actual_demo="$(psql_in_container -qAt -P 'null=<NULL>' < sql/04_demo.sql)"
        diff -u tests/demo.expected - <<< "$actual_demo"
        actual_exercises="$(sed -n '/^## 6 /q; /^```sql$/,/^```$/{ /^```/d; p; }' docs/aprendizaje/06-soluciones.md | psql_in_container -qAt)"
        diff -u tests/exercises.expected - <<< "$actual_exercises"
        actual_diagram="$(psql_in_container -At < scripts/diagram.sql)"
        if [[ "${1:-}" == "--print-diagram" ]]; then
            printf '%s\n' "$actual_diagram"
        else
            sed -n '/^```mermaid$/,/^```$/{ /^```/d; p; }' docs/modelo.md |
                diff -u - <(printf '%s\n' "$actual_diagram")
        fi
        echo 'Consultas demostrativas verificadas (10 consultas).'
        echo 'Soluciones de lectura verificadas (5 ejercicios).'
        exit 0
    fi
    sleep 1
done

"$engine" logs "$container_id" >&2
exit 1
