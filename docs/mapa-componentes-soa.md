# Mapa de Componentes del Sistema SOA

## Introducción
Este documento describe la arquitectura de componentes del sistema SOA, sus responsabilidades, interacciones y restricciones identificadas. El sistema está diseñado para operar en un entorno distribuido con múltiples servicios que interactúan entre sí para cumplir con los requisitos funcionales y no funcionales del dominio.

## Diagrama de Componentes
```
+---------------------+       +---------------------+       +---------------------+
|   Servicio Cliente   |       |   Servicio Cuentas   |       |   Servicio Préstamos |
| (Client Service)     |------>| (Account Service)    |------>| (Loan Service)       |
+---------------------+       +---------------------+       +---------------------+
        ^                                     |
        |                                     |
        v                                     v
+---------------------+       +---------------------+
| Servicio Autenticación|       | Servicio Notificaciones|
| (Auth Service)        |       | (Notification Service)|
+---------------------+       +---------------------+
        ^
        |
        v
+---------------------+
|   Base de Datos      |
| (Shared Database)    |
+---------------------+
```

## Descripción de Componentes

### 1. Servicio Cliente (Client Service)
- **Responsabilidad**: Actúa como punto de entrada para las solicitudes de los usuarios finales. Expone una API RESTful que recibe peticiones HTTP y las redirige a los servicios internos correspondientes.
- **Interacciones**:
  - Consume el Servicio de Autenticación para validar tokens JWT.
  - Invoca al Servicio de Cuentas para operaciones relacionadas con cuentas de usuario.
  - Invoca al Servicio de Préstamos para operaciones de solicitud y gestión de préstamos.
- **Restricciones**:
  - Debe implementar rate limiting para evitar ataques de denegación de servicio (DoS).
  - Debe validar todos los parámetros de entrada antes de redirigir las solicitudes.
  - Solo acepta conexiones HTTPS.

### 2. Servicio Cuentas (Account Service)
- **Responsabilidad**: Gestiona la información de las cuentas de usuario, incluyendo creación, actualización, consulta y eliminación de cuentas.
- **Interacciones**:
  - Consume el Servicio de Autenticación para verificar permisos.
  - Invoca al Servicio de Préstamos para operaciones que involucren saldos o transacciones.
  - Accede a la Base de Datos compartida para persistir y recuperar datos.
- **Restricciones**:
  - Solo puede ser invocado por el Servicio Cliente o el Servicio de Préstamos.
  - Debe implementar validaciones de negocio para evitar saldos negativos.
  - Debe auditar todas las operaciones de modificación de datos.

### 3. Servicio Préstamos (Loan Service)
- **Responsabilidad**: Gestiona las solicitudes de préstamos, incluyendo evaluación de crédito, aprobación, desembolso y cobranza.
- **Interacciones**:
  - Consume el Servicio de Cuentas para verificar saldos y realizar transacciones.
  - Invoca al Servicio de Notificaciones para enviar alertas a los usuarios.
  - Accede a la Base de Datos compartida para persistir y recuperar datos.
- **Restricciones**:
  - Solo puede ser invocado por el Servicio Cliente.
  - Debe implementar lógica de retries para operaciones críticas.
  - Debe validar la capacidad de pago del usuario antes de aprobar un préstamo.

### 4. Servicio Autenticación (Auth Service)
- **Responsabilidad**: Gestiona la autenticación y autorización de usuarios y servicios. Emite y valida tokens JWT.
- **Interacciones**:
  - Es invocado por el Servicio Cliente y el Servicio de Cuentas para validar tokens.
  - Accede a la Base de Datos compartida para validar credenciales.
- **Restricciones**:
  - Debe implementar políticas de contraseñas seguras.
  - Debe auditar todos los intentos de autenticación fallidos.
  - Debe soportar OAuth 2.0 y OpenID Connect.

### 5. Servicio Notificaciones (Notification Service)
- **Responsabilidad**: Envía notificaciones a los usuarios vía email, SMS o push notifications.
- **Interacciones**:
  - Es invocado por el Servicio de Préstamos para enviar alertas.
  - Accede a la Base de Datos compartida para obtener información de contacto.
- **Restricciones**:
  - Debe implementar un mecanismo de cola para manejar picos de carga.
  - Debe garantizar la entrega de notificaciones críticas.
  - Debe cumplir con regulaciones de privacidad como GDPR.

### 6. Base de Datos (Shared Database)
- **Responsabilidad**: Almacena datos persistentes para todos los servicios.
- **Interacciones**:
  - Es accedida por todos los servicios para operaciones CRUD.
- **Restricciones**:
  - Debe implementar backups automáticos.
  - Debe garantizar la consistencia transaccional para operaciones críticas.
  - Debe estar protegida contra inyecciones SQL.

## Restricciones Globales del Sistema
- **Comunicación**: Todos los servicios deben comunicarse mediante HTTPS y validar certificados SSL.
- **Seguridad**: Los tokens JWT deben tener un tiempo de expiración corto y ser renovados mediante refresh tokens.
- **Resiliencia**: Los servicios deben implementar circuit breakers y retries para manejar fallos temporales.
- **Auditoría**: Todas las operaciones críticas deben ser auditadas y los logs deben ser centralizados.
- **Monitoreo**: Los servicios deben exponer métricas de salud y rendimiento para su monitoreo.

## Ejemplo de Flujo de Trabajo
1. **Solicitud de Préstamo**:
   - El usuario envía una solicitud de préstamo al Servicio Cliente.
   - El Servicio Cliente valida el token JWT con el Servicio de Autenticación.
   - El Servicio Cliente invoca al Servicio de Préstamos.
   - El Servicio de Préstamos verifica el saldo del usuario con el Servicio de Cuentas.
   - El Servicio de Préstamos aprueba o rechaza la solicitud y notifica al usuario vía el Servicio de Notificaciones.

2. **Consulta de Saldo**:
   - El usuario envía una solicitud de consulta de saldo al Servicio Cliente.
   - El Servicio Cliente valida el token JWT con el Servicio de Autenticación.
   - El Servicio Cliente invoca al Servicio de Cuentas.
   - El Servicio de Cuentas recupera el saldo de la Base de Datos y lo retorna al Servicio Cliente.

---