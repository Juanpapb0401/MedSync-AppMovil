# MedSync — Estado actual de la base de datos

## Motor
PostgreSQL via Supabase  
Proyecto: `https://artnzmzycsnixyzdlovq.supabase.co`

---

## Tablas creadas

### profile
Tabla central de usuarios. `id` es el mismo UUID que genera Supabase Auth en `auth.users`.

| Campo | Tipo | Restricción |
|---|---|---|
| id | UUID | PK — mismo UUID de auth.users |
| full_name | VARCHAR(100) | NOT NULL |
| email | VARCHAR(100) | NOT NULL, UNIQUE |
| password | VARCHAR(100) | NOT NULL |
| type | VARCHAR(15) | NOT NULL, CHECK ('paciente', 'cuidador') |
| linking_code | VARCHAR(20) | UNIQUE, nullable — solo pacientes, formato MED-XXXX |

### user_relation
Vinculación paciente ↔ cuidador. Reemplaza el campo `caregiver` que existía en `profile`.

| Campo | Tipo | Restricción |
|---|---|---|
| profile_id | UUID | PF — FK → profile(id), representa el paciente |
| profile_id1 | UUID | PF — FK → profile(id), representa el cuidador |

PK compuesta: `(profile_id, profile_id1)`

### profile_type
Especialización de profile (herencia por rol).

| Campo | Tipo | Restricción |
|---|---|---|
| id | SERIAL | PK |
| type | VARCHAR(20) | NOT NULL |
| profile_id | UUID | FK → profile(id) |

### medicine
Catálogo de medicamentos.

| Campo | Tipo | Restricción |
|---|---|---|
| id | UUID | PK DEFAULT gen_random_uuid() |
| name | VARCHAR(100) | NOT NULL, UNIQUE |
| medicine_type | VARCHAR(50) | NOT NULL |

### treatment
Tratamiento asignado a un paciente por su cuidador.

| Campo | Tipo | Restricción |
|---|---|---|
| id | UUID | PK DEFAULT gen_random_uuid() |
| dose | NUMERIC | NOT NULL |
| unit | VARCHAR(10) | NOT NULL |
| start_date | DATE | NOT NULL |
| end_date | DATE | nullable |
| instructions | VARCHAR(500) | nullable |
| medicine_id | UUID | FK → medicine(id) |
| profile_id | UUID | FK → profile(id) |

### schedule
Horarios de toma para cada tratamiento.

| Campo | Tipo | Restricción |
|---|---|---|
| id | UUID | PK DEFAULT gen_random_uuid() |
| frequency_type | VARCHAR(15) | NOT NULL, CHECK ('fija', 'intervalo') |
| time | TIME | nullable (solo si frequency_type = 'fija') |
| interval_hours | NUMERIC | nullable (solo si frequency_type = 'intervalo') |
| treatment_id | UUID | FK → treatment(id) |

Índice: `schedule_idx (treatment_id)`

### restriction
Instrucciones/restricciones adicionales por tratamiento. Antes se llamaba `instructions`.

| Campo | Tipo | Restricción |
|---|---|---|
| id | SERIAL | PK |
| treatment_id | UUID | FK → treatment(id) |
| description | TEXT | NOT NULL |
| restriction_type | VARCHAR(50) | NOT NULL |

### notification
Log de tomas. Registra cada alarma generada por un schedule.

| Campo | Tipo | Restricción |
|---|---|---|
| id | UUID | PK DEFAULT gen_random_uuid() |
| scheduled_datetime | TIMESTAMP | NOT NULL |
| original_scheduled_datetime | TIMESTAMP | NOT NULL |
| taken_datetime | TIMESTAMP | nullable |
| status | VARCHAR(20) | NOT NULL, CHECK ('pendiente', 'tomado', 'omitido', 'sin_confirmar') |
| notes | VARCHAR(60) | nullable |
| schedule_id | UUID | FK → schedule(id) |

---

## Diagrama de relaciones

```
profile ◄──────────────── user_relation ────────────────► profile
(paciente)   profile_id ↗              ↖ profile_id1   (cuidador)

profile ──────────────────────────────────────────────────────────
  └──► treatment ◄──── medicine
           │
           ├──► schedule
           │        │
           │        └──► notification
           │
           └──► restriction

profile_type ──────────────────────────────────────────────────►profile
```

---

## Usuarios de prueba

Sincronizados con `auth.users`. Contraseña de todos: `pass1234`

| UUID | full_name | email | type | vinculado con |
|---|---|---|---|---|
| c6b53e80-440a-42f9-a1b9-2cceb2db3d3e | Ana Torres | ana@example.com | cuidador | Carlos |
| a6fbc919-f136-4244-a49a-1f2e8ff6ccdc | Juan Martínez | juan@example.com | cuidador | María |
| 5700b27f-528a-4620-8039-732cecee503a | Carlos Ramírez | carlos@example.com | paciente | Ana |
| 44b5bd7d-4362-4002-8fe4-de64eee3e5dd | María López | maria@example.com | paciente | Juan |

### Vinculaciones en user_relation
| profile_id (paciente) | profile_id1 (cuidador) |
|---|---|
| 5700b27f (Carlos) | c6b53e80 (Ana) |
| 44b5bd7d (María) | a6fbc919 (Juan) |

---

## Medicamentos

| nombre | medicine_type |
|---|---|
| Metformina | Antidiabético |
| Atorvastatina | Hipolipemiante |
| Losartán | Antihipertensivo |
| Omeprazol | Antiácido |
| Aspirina | Analgésico |
| Ibuprofeno | Analgésico |
| Amoxicilina | Antibiótico |
| Paracetamol | Analgésico |

---

## Tratamientos de prueba

| paciente | medicamento | dosis | frecuencia |
|---|---|---|---|
| Carlos Ramírez | Metformina | 850mg | Cada 8h |
| Carlos Ramírez | Atorvastatina | 20mg | Fija 8am |
| María López | Losartán | 50mg | Fija 9pm |

---

## Notificaciones (estados presentes)

| estado | cantidad |
|---|---|
| tomado | 4 |
| omitido | 1 |
| sin_confirmar | 1 |
| pendiente | 3 |

---

## Notas importantes para el código Flutter

- `profile.id` siempre es el UUID de `auth.users` — nunca generes uno propio
- La vinculación paciente-cuidador se lee y escribe en `user_relation`, no en `profile`
- `profile_id` en `user_relation` = paciente, `profile_id1` = cuidador
- El `linking_code` solo existe en perfiles de tipo `paciente`, formato `MED-XXXX`
- Todos los IDs de tablas secundarias (medicine, treatment, schedule, notification) usan `gen_random_uuid()` automáticamente
- La tabla `restriction` antes se llamaba `instructions` — si ves referencias viejas a `instructions` en el código, están desactualizadas
