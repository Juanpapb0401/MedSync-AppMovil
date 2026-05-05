# MedSync — App Móvil

App de gestión de medicamentos entre pacientes adultos mayores y sus cuidadores.
Stack: Flutter + Supabase + BLoC.

---

## Flujo implementado

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
                            └──► /configurar ⚠️ placeholder
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

### Pantallas destino post-login
```
Paciente ──► /profile/patient    (perfil, código MED, estado de cuenta, FAQs)
             /rutina              ⚠️ placeholder — pendiente AM-36

Cuidador ──► /profile/caregiver  (perfil, paciente vinculado, FAQs)
             /configurar          ⚠️ placeholder — pendiente AM-45 / AM-50
```