# Operación de la demostración

El entorno usa Podman rootless en Fedora y Docker Desktop con contenedores Linux en Windows. Ambos motores guardan los datos en un volumen nombrado. La publicación de TCP se limita a `127.0.0.1`. `CATDB_INSTANCE` permite separar volúmenes, nombres de contenedor y contraseñas. `CATDB_PORT` permite elegir un puerto libre al crear la instancia. Mantén ese puerto al reiniciarla. La configuración local se guarda en `.catdb/` con acceso restringido y Git la ignora. Usa una carpeta local de tu cuenta. En Windows, el script aplica permisos NTFS al directorio para tu usuario.

Sigue la instalación desde cero y el inicio rápido del [README en español](../README.es.md#requisitos-e-instalación). El comando `test` puede ejecutarse aunque la demostración esté detenida.

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

En Windows, abre PowerShell 7 en la raíz del clon. Comprueba que los recursos pertenecen a la instancia que quieres borrar y confirma el nombre del volumen.

```powershell
.\scripts\demo.ps1 stop
docker container ls -a --filter name=catdb-postgresql-demo
docker volume ls --filter name=catdb-postgresql-demo-data
$confirm = Read-Host 'Escribe catdb-postgresql-demo-data para confirmar el borrado'
if ($confirm -ceq 'catdb-postgresql-demo-data') {
    docker container rm catdb-postgresql-demo
    if ($LASTEXITCODE -eq 0) {
        docker volume rm catdb-postgresql-demo-data
    }
}
```

## Diagnóstico por síntoma

- Si falla la primera descarga, verifica la conexión al registro y vuelve a ejecutar `start`. Puedes comprobar la descarga con `docker pull docker.io/library/postgres:17` o `podman pull docker.io/library/postgres:17`.
- Si falla la inicialización, comprueba los registros con `docker logs catdb-postgresql-demo` o `podman logs catdb-postgresql-demo`. Usa el nombre de la instancia alternativa si corresponde.
- Si un servicio ya usa el puerto, el motor informa del conflicto al reservarlo. Libera el puerto y reintenta o elige un nombre y puerto libres. Si el nombre ya corresponde a un contenedor existente, conserva el puerto original.
- Si se perdió la credencial de un volumen existente, restaura el archivo indicado por `info` desde el respaldo original. Arrancar una instancia distinta permite seguir practicando mientras conservas ese volumen.
