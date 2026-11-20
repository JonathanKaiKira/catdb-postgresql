# Operación de la demostración

El entorno usa Podman rootless y un volumen nombrado. La publicación de TCP se limita a `127.0.0.1`. `CATDB_INSTANCE` permite separar volúmenes, nombres de contenedor y contraseñas. `CATDB_PORT` permite elegir un puerto libre al crear la instancia. Mantén ese puerto al reiniciarla. La configuración local tiene permisos privados y el repositorio la ignora.

En una base de pruebas vacía ya existente, puedes usar `psql` directamente:

```bash
psql -X -v ON_ERROR_STOP=1 -1 -d catdb -f sql/01_schema.sql -f sql/02_seed.sql
psql -X -v ON_ERROR_STOP=1 -d catdb -f sql/03_validate.sql -f tests/integrity.sql
```

Los scripts dejan intacta una instalación previa del esquema durante el arranque. Para practicar con datos nuevos, crea la instancia alternativa del README.

## Limpieza manual con confirmación

La eliminación del volumen borra permanentemente los datos de esa instancia. Primero desconecta DBeaver, detén la instancia, identifica los recursos y respalda lo que necesites. Para el nombre predeterminado puedes revisar lo siguiente:

```bash
./scripts/demo.sh stop
podman container ls -a --filter name=catdb-postgresql-demo
podman volume ls --filter name=catdb-postgresql-demo-data
```

Ejecuta este bloque solo cuando hayas confirmado que quieres borrar esos recursos. La confirmación solicita el nombre exacto del volumen.

```bash
read -r -p 'Escribe catdb-postgresql-demo-data para confirmar el borrado: ' confirm
if [[ "$confirm" == catdb-postgresql-demo-data ]]; then
    podman rm catdb-postgresql-demo &&
        podman volume rm catdb-postgresql-demo-data
fi
```

Tras borrarlos, `start` reconstruye la muestra. El archivo local de conexión se conserva y permanece excluido de Git.
