# MedSync — App Móvil

App de gestión de medicamentos entre pacientes adultos mayores y sus cuidadores.
Stack: Flutter + Supabase + BLoC.

---

## Sprint 2 — Flujo implementado

### Pantallas destino post-login (Sprint 2)
```
Paciente ──► /profile/patient    (perfil, código MED, estado de cuenta, FAQs)
             /rutina              ⚠️ placeholder — pendiente AM-36

Cuidador ──► /profile/caregiver  (perfil — AM-44, FAQs — AM-55, cerrar sesión — AM-43)
             /dashboard           (AM-45) Dashboard del cuidador
             /configurar          (AM-50) Pantalla principal de Configurar
```

### Configurar Tratamiento (cuidador)
```
/configurar  (AM-50)
    ├──► /tratamientos/lista    (AM-51) Ver tratamientos configurados
    │         ├──► /tratamientos/editar    (AM-46) Editar tratamiento existente
    │         └──► /tratamientos/crear     (AM-53) Crear nuevo tratamiento — FAB
    └──► /tratamientos/crear    (AM-53) Crear Nuevo Tratamiento
```

### Dashboard del cuidador
```
/dashboard  (AM-45)
    └──► CalendarModal           (AM-49) Navegación por fechas — modal in-screen
```

### HUs completadas en Sprint 2
```
AM-50  Pantalla principal de Configurar
AM-45  Dashboard del cuidador
AM-53  Crear nuevo tratamiento
AM-46  Editar tratamiento existente
AM-51  Ver tratamientos configurados
AM-47  Eliminar tratamiento
AM-49  Navegación por fechas en Dashboard
AM-44  Ver información de perfil del cuidador
AM-43  Cerrar sesión
AM-55  Preguntas frecuentes
```

---

## Sprint 1 — Flujo implementado

### Primer inicio (onboarding)
```
Onboarding (3 slides)
    └──► /auth/login
```

### Login
```
/auth/login
    ├──► (rol: paciente) ──► /profile/patient
    ├──► (rol: cuidador) ──► /profile/caregiver
    ├──► ¿Olvidaste contraseña? ──► /auth/forgot-password
    └──► ¿No tienes cuenta?     ──► /auth/role-selection
```

### Registro
```
/auth/role-selection
    ├──► (Paciente) ──► /auth/register-patient
    │                       └──► /auth/binding-code ──► /rutina ⚠️ placeholder
    └──► (Cuidador) ──► /auth/register-caregiver
                            └──► /configurar
```

### Recuperar contraseña
```
/auth/forgot-password
    └──► /auth/forgot-password-sent
             └──► /auth/otp-verification
                      └──► /auth/create-new-password
                               └──► /auth/password-updated
                                        └──► /auth/login
```

### Pantallas destino post-login (Sprint 1)
```
Paciente ──► /profile/patient    (perfil, código MED, estado de cuenta, FAQs)
             /rutina              ⚠️ placeholder — pendiente AM-36

Cuidador ──► /profile/caregiver  (perfil, paciente vinculado, FAQs)
             /configurar          implementado en Sprint 2
```