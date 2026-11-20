# Mantenimiento de CatDB

- Mantén el DDL, la guía de tablas y el diagrama ER alineados. El CI compara Mermaid con el catálogo real.
- Usa español en la documentación e inglés para identificadores SQL. Incluye únicamente datos ficticios.
- Ejecuta `./scripts/verify.sh` tras cambios en SQL o ejemplos. Prueba el ciclo de `demo.sh` si modificas la operación local.
- Conserva el volumen al detener la demostración. Mantén las credenciales locales fuera de Git.
- Describe casos límite y resultados verificables para enseñar cada técnica.
