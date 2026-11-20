# CatDB · CatHub

CatDB es una base de datos de **PostgreSQL 17** para explorar el historial de cuidado de gatos domésticos ficticios. El modelo permite seguir quién cuida a cada gato, comparar sus mediciones, sumar gastos y consultar visitas y seguimientos registrados.

## Demostración local

En Fedora, con Bash y Podman:

```bash
./scripts/demo.sh start
./scripts/demo.sh info
```

La primera ejecución descarga la imagen oficial `postgres:17` si hace falta y carga el escenario. DBeaver se conecta a `127.0.0.1:55432`, base `catdb`, usuario `catdb_dev`. El script genera una contraseña local y muestra la ubicación del archivo privado, excluido de Git. Sigue la [guía de DBeaver](docs/aprendizaje/05-guia-visual.md) y el [recorrido de 12 minutos](docs/aprendizaje/09-recorrido-demo.md).

```bash
./scripts/demo.sh test
./scripts/demo.sh stop
```

`test` usa una base temporal sin red. Comprueba restricciones, resultados SQL y correspondencia del diagrama con el catálogo. `stop` conserva el volumen y `start` vuelve a abrir la misma base.

### Repetir desde una base limpia

Usa otra instancia y otro puerto para conservar la demostración anterior. Emplea el mismo nombre de instancia en los comandos de esa sesión.

```bash
CATDB_INSTANCE=catdb-practica CATDB_PORT=55433 ./scripts/demo.sh start
CATDB_INSTANCE=catdb-practica ./scripts/demo.sh stop
```

Si necesitas eliminar la instancia original, revisa primero qué datos quieres conservar y confirma explícitamente esa eliminación antes de actuar. El [procedimiento de limpieza manual](docs/operacion.md) identifica los recursos afectados.

## Resultados de la muestra

Hay cuatro gatos ficticios. Luna tiene dos responsables, tres mediciones y **35.000 CLP** en gastos. Entre sus dos últimas mediciones hay una diferencia de **−50 g**. Pipa aparece en las consultas de responsables y gastos aunque aún carece de historial. Con un corte ficticio al **15 de mayo de 2030**, se muestran los seguimientos registrados para Luna y Milo.

## Explorar el repositorio

| Ruta | Contenido |
| --- | --- |
| [docs/requisitos.md](docs/requisitos.md) | Reglas de negocio y alcance |
| [docs/modelo.md](docs/modelo.md) | Diagrama Mermaid, SVG y normalización a 3FN |
| [docs/arquitectura.md](docs/arquitectura.md) | Tipos, restricciones e índices |
| [docs/aprendizaje/](docs/aprendizaje/) | Guías, 10 consultas, ejercicios, soluciones y entrevista |
| [sql/](sql/) | DDL, muestra ficticia, consultas de validación y demostración |
| [scripts/](scripts/) y [tests/](tests/) | Entorno persistente, suite efímera y resultados esperados |
| [docs/validacion.md](docs/validacion.md) | Resultados realmente ejecutados |

CatDB almacena hechos de un escenario ficticio. El alcance se limita al diseño relacional y a consultas de lectura del historial. Licencia [MIT](LICENSE).
