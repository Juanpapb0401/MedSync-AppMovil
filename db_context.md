# MedSync — Estado actual de la base de datos

## Motor
PostgreSQL via Supabase  
Proyecto: `https://artnzmzycsnixyzdlovq.supabase.co`

---

## Tablas creadas

### profile
Tabla central de usuarios. Se referencia a sí misma para la vinculación paciente → cuidador.

| Campo | Tipo | Restricción |
|---|---|---|
| id | VARCHAR(10) | PK |
| full_name | VARCHAR(100) | NOT NULL |
| email | VARCHAR(30) | NOT NULL, UNIQUE |
| password | VARCHAR(30) | NOT NULL |
| type | VARCHAR(15) | NOT NULL, CHECK ('paciente', 'cuidador') |
| caregiver | VARCHAR(10) | FK → profile(id) |

### profile_type
Especialización de profile (herencia por rol).

| Campo | Tipo | Restricción |
|---|---|---|
| id | SERIAL | PK |
| type | VARCHAR(20) | NOT NULL |
| profile_id | VARCHAR(10) | FK → profile(id) |

### medicine
Catálogo de medicamentos.

| Campo | Tipo | Restricción |
|---|---|---|
| id | VARCHAR(10) | PK |
| name | VARCHAR(30) | NOT NULL, UNIQUE |

### treatment
Tratamiento asignado a un paciente por su cuidador.

| Campo | Tipo | Restricción |
|---|---|---|
| id | VARCHAR(10) | PK |
| dose | NUMERIC | NOT NULL |
| unit | VARCHAR(10) | NOT NULL |
| start_date | DATE | NOT NULL |
| end_date | DATE | nullable |
| instructions | VARCHAR(500) | nullable |
| medicine_id | VARCHAR(10) | FK → medicine(id) |
| profile_id | VARCHAR(10) | FK → profile(id) |

### schedule
Horarios de toma para cada tratamiento.

| Campo | Tipo | Restricción |
|---|---|---|
| id | VARCHAR(10) | PK |
| frequency_type | VARCHAR(15) | NOT NULL, CHECK ('fija', 'intervalo') |
| time | TIME | nullable (solo si frequency_type = 'fija') |
| interval_hours | NUMERIC | nullable (solo si frequency_type = 'intervalo') |
| treatment_id | VARCHAR(10) | FK → treatment(id) |

### instructions
Instrucciones adicionales por tratamiento. Un tratamiento puede tener varias.

| Campo | Tipo | Restricción |
|---|---|---|
| id | SERIAL | PK |
| treatment_id | VARCHAR(10) | FK → treatment(id) |
| description | TEXT | NOT NULL |

### notification
Log de tomas. Registra cada alarma generada por un schedule.

| Campo | Tipo | Restricción |
|---|---|---|
| id | VARCHAR(20) | PK |
| scheduled_datetime | TIMESTAMP | NOT NULL |
| original_scheduled_datetime | TIMESTAMP | NOT NULL |
| taken_datetime | TIMESTAMP | nullable |
| status | VARCHAR(20) | NOT NULL, CHECK ('pendiente', 'tomado', 'omitido', 'sin_confirmar') |
| notes | VARCHAR(200) | nullable |
| schedule_id | VARCHAR(10) | FK → schedule(id) |

---

## Diagrama de relaciones

```
profile ──────────────────────────────┐
  │ (caregiver FK → profile.id)       │ auto-referencia
  │                                   │
  └──► treatment ◄──── medicine       │
           │                          │
           ├──► schedule              │
           │        │                 │
           │        └──► notification │
           │                          │
           └──► instructions          │
                                      │
profile_type ◄────────────────────────┘
```

---

## Datos de prueba insertados

### Perfiles
| id | nombre | email | rol | vinculado con |
|---|---|---|---|---|
| USR001 | Carlos Ramírez | carlos@example.com | paciente | USR003 (Ana) |
| USR002 | María López | maria@example.com | paciente | USR004 (Juan) |
| USR003 | Ana Torres | ana@example.com | cuidador | — |
| USR004 | Juan Martínez | juan@example.com | cuidador | — |

### Medicamentos
| id | nombre |
|---|---|
| MED001 | Metformina |
| MED002 | Atorvastatina |
| MED003 | Losartán |
| MED004 | Omeprazol |
| MED005 | Aspirina |

### Tratamientos
| id | paciente | medicamento | dosis | frecuencia |
|---|---|---|---|---|
| TRT001 | Carlos (USR001) | Metformina | 850mg | Cada 8h |
| TRT002 | Carlos (USR001) | Atorvastatina | 20mg | Fija 8am |
| TRT003 | María (USR002) | Losartán | 50mg | Fija 9pm |

### Notificaciones (estados presentes)
| estado | cantidad |
|---|---|
| tomado | 4 |
| omitido | 1 |
| sin_confirmar | 1 |
| pendiente | 3 |

---

## Problema actual

Los datos de prueba están insertados únicamente en la tabla `profile` de la base de datos.  
Sin embargo, Supabase maneja la autenticación en su propia tabla interna `auth.users`, que es independiente y protegida.

Esto significa que aunque `carlos@example.com` existe en `profile`, **no existe en `auth.users`**, por lo que cualquier intento de login desde la app falla porque Supabase no lo reconoce como usuario autenticado.

Para resolver esto hay que crear los 4 usuarios en `auth.users` y luego sincronizar sus UUIDs con los registros de `profile`.