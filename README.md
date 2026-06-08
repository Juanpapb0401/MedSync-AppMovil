# MedSync

App móvil para gestión de tratamientos médicos entre **pacientes adultos mayores** y sus **cuidadores**. El cuidador configura el plan de medicamentos; el paciente recibe alarmas y confirma cada toma.

---

## Stack técnico

| Capa | Tecnología |
|---|---|
| Framework | Flutter (Dart SDK `^3.8.1`) |
| Backend / Auth | Supabase (PostgreSQL + Auth) |
| Estado | BLoC (`flutter_bloc ^9.0.0`) |
| Inyección de dependencias | `get_it ^8.0.3` |
| Notificaciones OS | `flutter_local_notifications ^20.1.0` + `timezone ^0.10.0` |
| Fuente | Poppins (`google_fonts`) |
| Almacenamiento local | `shared_preferences` |

---

## Arquitectura

Clean Architecture por feature, con tres capas por módulo:

```
lib/
├── components/          # Design system compartido (AppColors, widgets reutilizables)
├── di/                  # Inyección de dependencias (get_it)
├── features/
│   ├── auth/            # Autenticación completa
│   ├── dashboard/       # Dashboard del cuidador
│   ├── onboarding/      # Slides de bienvenida
│   ├── profile/         # Perfiles paciente y cuidador
│   ├── rutina/          # Rutina diaria + sistema de alarmas
│   └── treatment/       # Gestión de tratamientos
└── main.dart            # Entry point, rutas nombradas, DI
```

Cada feature sigue la estructura:
```
<feature>/
├── domain/
│   ├── model/       # Clases Dart puras (sin codegen)
│   ├── repo/        # Interfaces abstractas
│   └── usecases/    # Una clase por caso de uso
├── data/
│   ├── sources/     # Llamadas directas a Supabase
│   └── repo/        # Implementaciones de domain/repo
└── ui/
    ├── bloc/        # BLoC completo (Events + States)
    └── screens/     # Pantallas con Scaffold
```

---

## Funcionalidades implementadas

### Autenticación

| HU | Descripción |
|---|---|
| AM-1 | Onboarding de 3 slides (se muestra una sola vez) |
| AM-2 | Inicio de sesión con email/contraseña + navegación por rol |
| AM-3 | Recuperar contraseña (envío de enlace al correo) |
| AM-4 | Confirmación de correo enviado |
| AM-5 | Crear nueva contraseña |
| AM-6 | Confirmación de contraseña actualizada |
| AM-7 | Selección de rol (Paciente / Cuidador) |
| AM-8 | Registro de paciente con avatar opcional |
| AM-9 | Código de vinculación `MED-XXXX` (copiar / compartir) |
| AM-10 | Registro de cuidador con código del paciente |

**Flujo completo:**
```
Onboarding
  └──► Login
         ├──► (paciente)  ──► Mi Rutina
         ├──► (cuidador)  ──► Configurar Tratamiento
         └──► Recuperar contraseña
                └──► Correo enviado
                       └──► Verificar OTP
                              └──► Nueva contraseña
                                     └──► Contraseña actualizada
                                            └──► Login
```

---

### Perfil del paciente (AM-48)

- Avatar, nombre, correo y badge de rol
- Estado de cuenta activa e indicador de cuidador vinculado
- Código `MED-XXXX` con botón de copia
- Preguntas frecuentes en accordion
- Cerrar sesión con modal de confirmación

---

### Perfil del cuidador (AM-52)

- Header verde con avatar, nombre, correo y badge "Cuidador"
- Sección de estado: cuenta activa + paciente vinculado
- Card del paciente vinculado (avatar, nombre, código MED)
- Card de soporte con correo `soporte@medsync.app`
- Preguntas frecuentes en accordion — AM-55
- Cerrar sesión con modal de confirmación — AM-56

---

### Rutina diaria del paciente (AM-36)

- Saludo personalizado con nombre del paciente
- Banner de advertencia cuando hay tomas pendientes
- Lista de medicamentos del día ordenada cronológicamente
- Cada card muestra: nombre, hora, dosis, unidad y restricciones
- Badge de estado: **Pendiente** (amarillo) / **Tomado** (verde) / **Omitido** (rojo)
- Botón campana con contador de notificaciones no leídas

---

### Sistema de alarmas y notificaciones (AM-37 · AM-38 · AM-39 · AM-40)

El sistema tiene dos capas complementarias que cubren foreground y background:

#### Aviso previo — 5 minutos antes (AM-37)
- `InAppNotificationService` detecta vía timer (cada 30 s) cuando faltan 5 minutos
- App en **foreground**: muestra SnackBar flotante con nombre del medicamento y hora
- App en **background / cerrada**: llega OS notification silenciosa
- El ítem se agrega al Centro de notificaciones (campana)

#### Alarma principal — hora exacta (AM-38)
- App en **foreground**: `GlobalNotificationWrapper` muestra un `AlarmDialog` con animación de campana y opciones de acción
- App en **background / cerrada**: llega OS notification persistente; al tocarla, la app navega directamente a `ConfirmarTomaScreen`
- El ítem también aparece en el Centro de notificaciones aunque el aviso previo no se haya visto

#### Centro de notificaciones (campana)
- Accesible desde `RutinaScreen` en cualquier momento
- Texto dinámico: _"¡Faltan 5 minutos para tu toma!"_ o _"¡Es hora de tomar tu medicamento!"_ según el momento
- Botón "Limpiar" para eliminar todos los ítems

#### Confirmar toma (AM-39)
Pantalla fullscreen con animación pulse-glow:
- Nombre del medicamento, hora programada y dosis
- Badge de advertencia si hay restricciones (ej. "Evitar lácteos")
- **"Ya me la tomé"** — registra en Supabase, detiene la alarma, notifica al cuidador
- **"Recordar en 2 minutos"** — reprograma alarma OS + in-app exactamente 2 minutos después

#### Alerta al cuidador por tomas sin confirmar (AM-40)
- Después de 2 snoozes sin confirmar, el estado cambia a `sin_confirmar`
- El Dashboard del cuidador refleja el estado automáticamente

---

### Dashboard del cuidador (AM-45 · AM-49)

- Título con nombre del paciente vinculado
- Navegador de fechas con flechas + modal de calendario (AM-49); fecha actual bloqueada hacia adelante
- Tres tarjetas estadísticas: **Tomadas** (verde) / **Omitidas** (rojo) / **Logro %** (amarillo)
- Alerta visual si hay tomas `sin_confirmar`
- Lista de medicamentos del día con punto de color, nombre, hora y badge de estado

---

### Configurar tratamiento — cuidador (AM-50 · AM-51 · AM-53 · AM-46 · AM-47)

```
/configurar  (resumen + contador de medicamentos activos)
    ├──► Ver Tratamientos
    │       ├──► Editar tratamiento  ──► guarda y vuelve a la lista
    │       └──► Eliminar tratamiento  ──► confirmación inline + toast
    └──► Crear Nuevo Tratamiento
```

**Crear / Editar tratamiento:**
- Campos: Medicamento, Dosis, Unidad (`mg` / `ml` / `comprimidos`), Frecuencia (`Cada 8h / 12h / 24h`), Hora de inicio
- Chips de restricciones preestablecidos + input para restricciones personalizadas
- Al guardar, genera automáticamente los schedules y las notificaciones del día en Supabase

**Eliminar tratamiento:**
- Confirmación inline en la card con borde rojo y opción "Deshacer"
- Toast de confirmación tras eliminar

---

## Rutas nombradas

```dart
'/onboarding'
'/auth/login'
'/auth/register-patient'
'/auth/register-caregiver'
'/auth/binding-code'
'/auth/forgot-password'
'/auth/forgot-password-sent'
'/auth/otp-verification'
'/auth/create-new-password'
'/auth/password-updated'
'/auth/role-selection'
'/rutina'
'/rutina/confirmar-toma'       // args: { medicamento, currentDate }
'/configurar'
'/tratamientos/lista'
'/tratamientos/crear'
'/tratamientos/editar'          // args: { treatmentId, treatment, patientName }
'/dashboard'
'/profile/caregiver'
'/profile/patient'
```

---

## Design system

Tokens en `lib/components/app_colors.dart`:

| Token | Valor |
|---|---|
| Primary | `#049B83` |
| Primary light | `#E0F5F3` |
| Background | `#FFFFFF` |
| Background secondary | `#F8FAF9` |
| Text primary | `#1A1A1A` |
| Text secondary | `#6B7280` |
| Text muted | `#9CA3AF` |
| Card border | `#E5E7EB` |
| Success bg / text | `#DCFCE7` / `#15803D` |
| Warning bg / text | `#FEF9C3` / `#854D0E` |
| Danger bg / text | `#FEE2E2` / `#DC2626` |
| Navbar | `#1A1A1A` |

Componentes base exportados desde `package:medsync/components/components.dart`:
`MedSyncButton`, `MedSyncTextField`, `BackButton`, `RoleCard`, `InfoCard`, `AvatarPicker`, `OnboardingProgressDots`.

---

## Comandos

```bash
flutter pub get       # Instalar dependencias
flutter run           # Correr en dispositivo/emulador conectado
flutter analyze       # Lint (debe pasar sin errores antes de commitear)
flutter test          # Ejecutar tests
```

---

## Variables de entorno

Crear `.env` en la raíz del proyecto:

```
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
```

---

## Equipo

| Nombre | Rol |
|---|---|
| Juan Pablo Parra | Desarrollador |
| Juan Esteban Eraso | Desarrollador |
| Daniel González | Desarrollador |
| Daniel Plazas | Desarrollador |
| Nicolás Cardona | Desarrollador |
| Thomas Brueck Estrada | Desarrollador |

---

> Proyecto académico — Apps Móviles · 2026
