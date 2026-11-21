#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
engine="${CONTAINER_ENGINE:-podman}"
if ! command -v "$engine" >/dev/null || ! "$engine" info >/dev/null; then
    echo "Instala $engine y comprueba que su motor esté disponible." >&2
    exit 1
fi
container_id="$("$engine" run --detach --rm --network none \
    -e POSTGRES_HOST_AUTH_METHOD=trust -e POSTGRES_DB=catdb \
    docker.io/library/postgres:17 postgres -c listen_addresses='')"
trap '"$engine" stop "$container_id" >/dev/null' EXIT

for ((attempt = 1; attempt <= 60; attempt++)); do
    if "$engine" exec "$container_id" sh -ec 'test "$(cat /proc/1/comm)" = postgres && pg_isready -q -U postgres -d catdb'; then
        "$engine" exec "$container_id" mkdir -p /tmp/catdb/{docs/aprendizaje,scripts}
        for path in sql tests docs/modelo.md docs/aprendizaje/06-soluciones.md scripts/diagram.sql scripts/verify-sql.sh; do
            "$engine" cp "$path" "${container_id}:/tmp/catdb/$path"
        done
        "$engine" exec "$container_id" bash /tmp/catdb/scripts/verify-sql.sh "$@"
        exit 0
    fi
    sleep 1
done

"$engine" logs "$container_id" >&2
echo 'PostgreSQL no quedó listo en 60 segundos.' >&2
exit 1
