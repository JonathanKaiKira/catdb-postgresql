# Diseño de base de datos para inventario y ventas

Una distribuidora ficticia necesita saber qué vende, quién le suministra cada producto, cuánto stock tiene en cada bodega y qué saldo queda por cobrar. Este proyecto implementa el modelo relacional en **PostgreSQL 17**, con restricciones declarativas, datos ficticios y consultas de conciliación.

## Ejecutar y reproducir

Requisitos locales: Bash y Podman. El comando descarga la imagen oficial de PostgreSQL 17 si hace falta.

```bash
./scripts/verify.sh
```

Con Docker:

```bash
CONTAINER_ENGINE=docker ./scripts/verify.sh
```

El script arranca PostgreSQL en un contenedor temporal sin red ni puertos, aplica el esquema y la muestra, ejecuta las consultas y verifica la integridad. El acceso local del contenedor usa autenticación `trust` para esta ejecución efímera. El contenedor se elimina al terminar.

En una base de pruebas existente cuyo usuario pueda crear esquemas, también puedes usar `psql` desde la raíz:

```bash
psql -X -v ON_ERROR_STOP=1 -d portfolio \
  -f sql/01_schema.sql -f sql/02_seed.sql -f sql/03_validate.sql \
  -f tests/integrity.sql
```

La base `portfolio` debe existir y el esquema `inventory_sales` debe estar libre al aplicar los scripts. Usa una base limpia para repetir la instalación. Las pruebas revierten sus cambios de datos.

## Resultados reproducibles

| Bodega | SKU | Unidades |
| --- | --- | ---: |
| SCL | BOX-01 | 19 |
| SCL | NOTE-01 | 48 |
| VAP | NOTE-01 | 0 |

El pedido de muestra suma **8.200 CLP**. Sus dos pagos totalizan **5.000 CLP** y el saldo por cobrar es **3.200 CLP**. Las consultas de excepción devuelven cero filas para estos datos.

## Estructura

| Ruta | Contenido |
| --- | --- |
| [docs/requisitos.md](docs/requisitos.md) | Alcance y reglas de negocio |
| [docs/modelo.md](docs/modelo.md) | Modelos conceptual y lógico, diagrama ER y 3FN |
| [docs/arquitectura.md](docs/arquitectura.md) | Diseño físico, índices y decisiones |
| [docs/validacion.md](docs/validacion.md) | Evidencia de la ejecución local |
| [sql/](sql/) | Esquema, muestra y consultas |
| [tests/integrity.sql](tests/integrity.sql) | Pruebas de restricciones y saldos |
| [scripts/verify.sh](scripts/verify.sh) | Verificación en un contenedor efímero |
| [.github/workflows/postgresql.yml](.github/workflows/postgresql.yml) | Validación automática con GitHub Actions |
| [AGENTS.md](AGENTS.md) | Pautas de mantenimiento |

Licencia [MIT](LICENSE).
