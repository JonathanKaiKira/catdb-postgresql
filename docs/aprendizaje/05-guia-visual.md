# 05 · Explorar CatDB en DBeaver

## Conexión en Fedora

1. Desde la raíz del repositorio ejecuta `./scripts/demo.sh start`. Si está en marcha, `./scripts/demo.sh info` muestra la configuración.
2. Abre **DBeaver Community**. Elige **Database → New Database Connection → PostgreSQL**.
3. Configura host `127.0.0.1`, puerto `55432`, base `catdb` y usuario `catdb_dev`. Si elegiste otro puerto, usa el de `info`.
4. Abre localmente el archivo que indica `info` y copia solo el valor de `POSTGRES_PASSWORD` en el campo **Password**. Usa ese valor únicamente en DBeaver. Puedes dejar desactivado **Save password locally**.
5. Pulsa **Test Connection**. Si DBeaver solicita el controlador JDBC de PostgreSQL, pulsa **Download** y repite la prueba. El asistente debe informar una conexión correcta a PostgreSQL 17.
6. Pulsa **Finish** y nombra la conexión `CatDB local` si lo deseas. El servicio escucha en loopback y el usuario de desarrollo es propietario de la instancia de demostración.

## Tablas, relaciones y resultados

1. En **Database Navigator**, expande la conexión y abre **Databases → catdb → Schemas → catdb → Tables**. Según la versión o configuración, el nodo **Databases** puede quedar omitido.
2. Abre `cats`. Revisa **Properties** para columnas y restricciones y selecciona **Data** para ver las cuatro filas. Si no aparecen, actualiza el esquema con **Refresh**.
3. Abre `cat_caregivers` y revisa **Foreign Keys**. Para ver el mapa, abre el esquema `catdb` y busca la pestaña **ER Diagram**. También puedes seleccionar tablas y abrir **View Diagram** desde su menú contextual. DBeaver permite exportar la vista como imagen.
4. Abre [04_demo.sql](../../sql/04_demo.sql) con **File → Open File** o copia su contenido a **SQL Editor → New SQL Script**. Selecciona `CatDB local` como conexión activa en la barra del editor.
5. Sitúa el cursor dentro de la primera sentencia y pulsa `Ctrl+Enter`. Lee las filas de **Results** y repite con el [recorrido SQL](04-sql-explicado.md). Puedes ordenar columnas en la cuadrícula, pero conserva el `ORDER BY` del SQL para reproducir los resultados.
6. Para finalizar, desconecta DBeaver y ejecuta `./scripts/demo.sh stop`. El volumen conserva los datos.

[Conexiones de DBeaver](https://dbeaver.com/docs/dbeaver/Create-Connection/) · [Controlador PostgreSQL](https://dbeaver.com/docs/dbeaver/Database-driver-PostgreSQL/)

## Abrir con el perfil de Flatpak

Para la instancia y el puerto predeterminados, este lanzador abre el archivo de consultas y usa un archivo PgPass privado dentro de `.catdb/`. Cierra DBeaver por completo antes del primer uso para que la aplicación tome el archivo de credenciales del lanzador.

```bash
./scripts/dbeaver.sh --configure  # una vez, si todavía no existe CatDB local
./scripts/dbeaver.sh              # siguientes sesiones
```

Si ya tienes una conexión llamada `CatDB local` creada manualmente, puedes seguir usando esa conexión con su configuración actual. El lanzador automatiza el perfil PgPass y nunca pasa la contraseña como argumento.

[Autenticación PgPass](https://dbeaver.com/docs/dbeaver/Authentication-PostgreSQL-Pgpass/) · [CLI de DBeaver](https://dbeaver.com/docs/dbeaver/Command-Line/)
