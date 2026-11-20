# Modelo conceptual, lógico y diagrama ER

En CatDB, el gato es el punto de partida para investigar alimentación, pesos, visitas, gastos y actividades. Una persona puede cuidar a varios gatos y cada gato puede tener varias personas vinculadas. Una visita puede registrar varias vacunas y tratamientos. La visita relaciona ambos hechos con el gato.

Cada FK tiene un padre obligatorio y cada padre admite cero o más filas hijas. Las líneas sólidas muestran relaciones identificadoras, donde la FK forma parte de la PK hija. Las líneas punteadas muestran relaciones con identidad propia. `UK` marca claves únicas de una sola columna. La restricción compuesta `UNIQUE (cat_id, measured_on)` de `weights` complementa las marcas del diagrama.

```mermaid
erDiagram
    activities {
        int8 activity_id PK
        int8 cat_id FK
        timestamptz occurred_at
        text activity_type
        text note
    }
    caregivers {
        int8 caregiver_id PK
        text alias UK
    }
    caregivers ||--o{ cat_caregivers : caregiver_id
    cat_caregivers {
        int8 cat_id PK,FK
        int8 caregiver_id PK,FK
        text role
    }
    cats {
        int8 cat_id PK
        text cat_code UK
        text name
        date birth_date
        text coat
    }
    cats ||--o{ cat_caregivers : cat_id
    cats ||..o{ activities : cat_id
    cats ||..o{ expenses : cat_id
    cats ||..o{ feedings : cat_id
    cats ||..o{ vet_visits : cat_id
    cats ||..o{ weights : cat_id
    expenses {
        int8 expense_id PK
        int8 cat_id FK
        date incurred_on
        text category
        int4 amount_clp
    }
    feedings {
        int8 feeding_id PK
        int8 cat_id FK
        int8 food_id FK
        timestamptz fed_at
        int4 grams
    }
    foods {
        int8 food_id PK
        text name UK
        text food_type
    }
    foods ||..o{ feedings : food_id
    medications {
        int8 medication_id PK
        text name UK
    }
    medications ||..o{ treatments : medication_id
    treatments {
        int8 treatment_id PK
        int8 visit_id FK
        int8 medication_id FK
        date started_on
        date ended_on
    }
    vaccinations {
        int8 visit_id PK,FK
        int8 vaccine_id PK,FK
    }
    vaccines {
        int8 vaccine_id PK
        text name UK
    }
    vaccines ||--o{ vaccinations : vaccine_id
    vet_visits {
        int8 visit_id PK
        int8 cat_id FK
        date visited_on
        text reason
        date follow_up_on
    }
    vet_visits ||--o{ vaccinations : visit_id
    vet_visits ||..o{ treatments : visit_id
    weights {
        int8 weight_id PK
        int8 cat_id FK
        date measured_on
        int4 grams
    }
```

## Normalización hasta 3FN

1. **1FN.** Una fila registra un hecho y cada campo contiene un valor. Un catálogo de gatos no tiene listas de dueños, vacunas o pesos en una celda.
2. **2FN.** En `cat_caregivers`, el rol depende de la pareja completa `(cat_id, caregiver_id)`. En `vaccinations` la pareja identifica el hecho sin atributos adicionales. En `weights`, los gramos dependen de la pareja `(cat_id, measured_on)` y no de uno de sus componentes.
3. **3FN.** Las descripciones de alimentos, vacunas y medicamentos viven en sus catálogos. Un tratamiento guarda la visita y de ella se obtiene el gato, lo que evita la dependencia transitiva tratamiento → visita → gato. Los totales de gasto se calculan a partir de los hechos.

[Detalle de las 13 tablas](aprendizaje/03-modelo-relacional.md).
[Diagrama en SVG](diagrama.svg).
