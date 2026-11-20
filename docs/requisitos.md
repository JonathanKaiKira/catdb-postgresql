# Requisitos de CatDB

| Necesidad | Regla implementada |
| --- | --- |
| Identificar gatos | Código único, nombre y pelaje obligatorios, nacimiento opcional |
| Compartir responsabilidades | Vínculo gato–persona con un rol por pareja y alias ficticios |
| Registrar alimentación | Cada consumo referencia un gato y un alimento. Los gramos son positivos |
| Comparar peso | Una medición positiva por gato y fecha |
| Registrar consultas | Visita por gato, motivo y seguimiento opcional posterior |
| Registrar vacunas | Una aplicación de cada tipo por visita. El gato se obtiene de la visita |
| Registrar tratamientos | Medicamento y visita obligatorios. Fin opcional igual o posterior al inicio |
| Registrar gastos | Un gasto positivo en CLP, clasificado y asignado a un gato |
| Registrar actividades | Fecha y hora, tipo y observación no vacía |

CatDB conserva hechos registrados. Las fechas de seguimiento proceden de los datos de ejemplo. La muestra usa un calendario ficticio de 2030 para que las consultas sean repetibles. El alcance excluye diagnósticos, recomendaciones médicas, dosis, personas reales y automatización de recordatorios.
