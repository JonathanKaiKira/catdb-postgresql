# 03 · Modelo relacional

| Tabla | Finalidad y campos | Relaciones, restricciones y ejemplo |
| --- | --- | --- |
| `cats` | Ficha con ID, código, nombre, nacimiento y pelaje | Código único. El nacimiento puede faltar, como en Nube |
| `caregivers` | Personas simuladas con ID y alias | Alias único. Casa Norte puede vincularse con Luna y Milo |
| `cat_caregivers` | Asignación de un rol | FK a gato y responsable. PK de ambos IDs. Luna tiene un propietario y una cuidadora de apoyo |
| `foods` | Catálogo con ID, nombre y tipo | Nombre único. Tipo `wet` o `dry`, como Húmedo A y Seco B |
| `feedings` | Consumo con fecha y hora y gramos | FK a gato y alimento, cantidad positiva. Luna consume 85 g de Húmedo A |
| `weights` | Medición con día y gramos | FK a gato, gramos positivos y una fila por gato y día. Luna pesa 4.150 g el 1 de mayo |
| `vet_visits` | Visita con día, motivo y seguimiento opcional | FK a gato. El seguimiento es posterior. Para Luna va del 3 de mayo al 3 de junio |
| `vaccines` | Catálogo de vacunas ficticias | Nombre único. Vacuna ficticia A |
| `vaccinations` | Vacuna registrada durante una visita | FK a visita y vacuna con PK compuesta. A aparece en la visita de Luna |
| `medications` | Catálogo de medicamentos ficticios | Nombre único. Medicamento ficticio A |
| `treatments` | Registro de uso con fecha de inicio y fin opcional | FK a visita y medicamento. Fin igual o posterior al inicio. El registro de Milo va del 8 al 12 de mayo |
| `expenses` | Importe por día y categoría | FK a gato, CLP positivos y categoría entre `food`, `vet` y `supplies`. Luna tiene un gasto veterinario de 25.000 CLP |
| `activities` | Evento con instante, tipo y nota | FK a gato, nota obligatoria no vacía y tipo acotado. Luna jugó con una pelota |

Todas las fechas del relato corresponden al escenario ficticio de 2030. Para seguir una FK en DBeaver, abre la tabla hija, ubica el campo y busca su tabla destino en **Foreign Keys**. Luego sigue la misma arista en el [diagrama ER](../modelo.md).
