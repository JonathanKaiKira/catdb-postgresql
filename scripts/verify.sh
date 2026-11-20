#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
engine="${CONTAINER_ENGINE:-podman}"
container_id="$("$engine" run --detach --rm --network none \
    -e POSTGRES_HOST_AUTH_METHOD=trust -e POSTGRES_DB=portfolio \
    docker.io/library/postgres:17 postgres -c listen_addresses='')"
trap '"$engine" stop "$container_id" >/dev/null' EXIT

# The bootstrap server runs as a child. Wait until PID 1 is the final server.
for ((attempt = 1; attempt <= 60; attempt++)); do
    if "$engine" exec "$container_id" sh -ec '
        test "$(cat /proc/1/comm)" = postgres
        pg_isready -q -U postgres -d portfolio
    '; then
        for sql_file in sql/01_schema.sql sql/02_seed.sql sql/03_validate.sql tests/integrity.sql; do
            "$engine" exec -i "$container_id" psql -X -v ON_ERROR_STOP=1 \
                -U postgres -d portfolio < "$project_dir/$sql_file"
        done
        exit 0
    fi
    sleep 1
done

"$engine" logs "$container_id" >&2
exit 1
