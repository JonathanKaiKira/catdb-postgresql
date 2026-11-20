#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

create=false
case "${1:-}" in
    --configure) create=true ;;
    '') ;;
    *)
        echo 'Uso: ./scripts/dbeaver.sh [--configure]' >&2
        exit 2
        ;;
esac

config=.catdb/catdb-postgresql-demo.env
if [[ ! -s "$config" ]]; then
    echo 'Inicia la instancia predeterminada con ./scripts/demo.sh start.' >&2
    exit 1
fi

umask 077
IFS= read -r credential < "$config"
if [[ ! "$credential" =~ ^POSTGRES_PASSWORD=[0-9a-f]{48}$ ]]; then
    echo 'La credencial de demostración no tiene el formato esperado.' >&2
    exit 1
fi
pgpass="$project_dir/.catdb/dbeaver.pgpass"
printf '127.0.0.1:55432:catdb:catdb_dev:%s\n' "${credential#POSTGRES_PASSWORD=}" > "$pgpass"
unset credential

connection='driver=postgres-jdbc|name=CatDB local|host=127.0.0.1|port=55432|database=catdb|user=catdb_dev|auth=postgres_pgpass'
exec flatpak run --env="PGPASSFILE=$pgpass" io.dbeaver.DBeaverCommunity \
    -con "$connection|create=$create|save=true|connect=true" -f "$project_dir/sql/04_demo.sql"
