#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

instance="${CATDB_INSTANCE:-catdb-postgresql-demo}"
port="${CATDB_PORT:-55432}"
if [[ ! "$instance" =~ ^catdb-[a-z0-9][a-z0-9-]*$ ]] ||
   [[ ! "$port" =~ ^[1-9][0-9]{0,4}$ ]] || ((port > 65535)); then
    echo 'Usa CATDB_INSTANCE=catdb-nombre y un CATDB_PORT válido.' >&2
    exit 2
fi
volume="$instance-data"
config=".catdb/$instance.env"
owner_label='io.cathub.project=catdb-postgresql'

require_owner() {
    local kind="$1" name="$2"
    if [[ "$(podman "$kind" inspect --format '{{ index .Labels "io.cathub.project" }}' "$name")" != catdb-postgresql ]]; then
        echo "El recurso $name no pertenece a CatDB." >&2
        exit 1
    fi
}

# Containers store their labels under .Config, unlike named volumes.
require_container() {
    if [[ "$(podman container inspect --format '{{ index .Config.Labels "io.cathub.project" }}' "$instance")" != catdb-postgresql ]]; then
        echo "El contenedor $instance no pertenece a CatDB." >&2
        exit 1
    fi
}

wait_for_database() {
    for ((attempt = 1; attempt <= 60; attempt++)); do
        if podman exec "$instance" sh -ec '
            test "$(cat /proc/1/comm)" = postgres
            pg_isready -q -U catdb_dev -d catdb
        '; then
            return
        fi
        sleep 1
    done
    podman logs "$instance" >&2
    return 1
}

database_sql() {
    podman exec -i "$instance" psql -X -v ON_ERROR_STOP=1 -U catdb_dev -d catdb "$@"
}

connection_info() {
    require_container
    printf 'Base: catdb\nUsuario: catdb_dev\nEsquema: catdb\nPuerto publicado: '
    podman port "$instance" 5432/tcp
    printf 'Credencial local: %s/%s (valor de POSTGRES_PASSWORD)\n' "$project_dir" "$config"
}

case "${1:-}" in
    start)
        umask 077
        mkdir -p .catdb
        # Keep the lock in flock, outside the process tree that starts conmon.
        if [[ "${CATDB_DEMO_LOCKED:-}" != "$instance" ]]; then
            export CATDB_DEMO_LOCKED="$instance"
            exec flock --close ".catdb/$instance.lifecycle.lock" "$project_dir/scripts/demo.sh" start
        fi

        if podman container exists "$instance"; then
            require_container
            if [[ "$(podman container inspect --format '{{range index .HostConfig.PortBindings "5432/tcp"}}{{.HostIp}}:{{.HostPort}}{{end}}' "$instance")" != "127.0.0.1:$port" ]]; then
                echo 'La instancia ya tiene otro puerto. Usa el puerto original u otra instancia.' >&2
                exit 1
            fi
        fi

        if podman volume exists "$volume"; then
            require_owner volume "$volume"
            if [[ ! -s "$config" ]]; then
                echo 'Falta la credencial local del volumen existente. Conserva los datos y recupera ese archivo.' >&2
                exit 1
            fi
        fi
        if [[ ! -s "$config" ]]; then
            password="$(od -An -N24 -tx1 /dev/urandom | tr -d '[:space:]')"
            printf 'POSTGRES_PASSWORD=%s\n' "$password" > "$config"
            unset password
        fi
        podman volume create --ignore --label "$owner_label" "$volume" >/dev/null
        require_owner volume "$volume"
        if podman container exists "$instance"; then
            if [[ "$(podman container inspect --format '{{.State.Running}}' "$instance")" != true ]]; then
                podman start "$instance" >/dev/null
            fi
        else
            podman run -d --name "$instance" --label "$owner_label" \
                -p "127.0.0.1:$port:5432" \
                --env-file "$config" -e POSTGRES_USER=catdb_dev -e POSTGRES_DB=catdb \
                -v "$volume:/var/lib/postgresql/data" \
                docker.io/library/postgres:17 >/dev/null
        fi
        wait_for_database
        {
            cat <<'SQL'
SELECT pg_advisory_xact_lock(314159, 17) AS locked \gset
SELECT NOT EXISTS (
    SELECT FROM pg_namespace WHERE nspname = 'catdb'
) AS needs_install \gset
\if :needs_install
SQL
            cat sql/01_schema.sql sql/02_seed.sql
            printf '%s\n' '\endif'
        } | database_sql -q -1 -f -
        connection_info
        ;;
    stop)
        if podman container exists "$instance"; then
            require_container
            podman stop "$instance" >/dev/null
        fi
        echo 'Demostración detenida. Los datos se conservan.'
        ;;
    info)
        connection_info
        ;;
    test)
        exec ./scripts/verify.sh
        ;;
    *)
        echo 'Uso: ./scripts/demo.sh {start|stop|info|test}' >&2
        exit 2
        ;;
esac
