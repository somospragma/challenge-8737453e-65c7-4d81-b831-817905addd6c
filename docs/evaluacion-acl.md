# Evaluación de Listas de Control de Acceso (ACL) en el Sistema SOA

## Introducción
Este informe evalúa la implementación de las Listas de Control de Acceso (ACL) en el sistema SOA, analizando su eficacia, posibles vulnerabilidades y recomendaciones para mejorar la seguridad. Las ACL son un componente crítico para garantizar que solo los usuarios y servicios autorizados puedan acceder a los recursos del sistema.

## Arquitectura de ACL en el Sistema

### 1. Definición de ACL en el Contrato OpenAPI
El sistema utiliza el estándar OpenAPI 3.1 para definir las ACL bajo el campo `securitySchemes`. A continuación se detalla la configuración actual:

```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: |
        Token JWT emitido por el Servicio de Autenticación.
        Ejemplo: "Bearer {token}"
    apiKeyAuth:
      type: apiKey
      in: header
      name: X-API-Key
      description: |
        Clave API para acceso entre servicios internos.
        Ejemplo: "X-API-Key: {apiKey}"
```

### 2. Aplicación de ACL a Nivel de Endpoint
Las ACL se aplican a cada endpoint mediante el campo `security`. A continuación se muestra un ejemplo para el Servicio de Cuentas:

```yaml
paths:
  /accounts/{id}:
    get:
      summary: Obtener información de una cuenta
      security:
        - bearerAuth: []
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Información de la cuenta
        '401':
          description: Token JWT no proporcionado o inválido
        '403':
          description: El usuario no tiene permisos para acceder a esta cuenta
```

### 3. Roles y Permisos
El sistema define los siguientes roles y permisos:

| Rol               | Permisos                                                                                     |
|-------------------|-----------------------------------------------------------------------------------------------|
| USER              | - Consultar su propia información de cuenta.
                      | - Solicitar préstamos.
                      | - Recibir notificaciones.
                      |
| ADMIN             | - Todas las acciones de USER.
                      | - Gestionar cuentas de otros usuarios.
                      | - Aprobar/Rechazar préstamos.
                      | - Configurar parámetros del sistema.
                      |
| SERVICE           | - Acceso entre servicios internos mediante clave API.
                      | - Operaciones CRUD en la base de datos.
                      |

## Evaluación de Eficacia

### 1. Fortalezas
- **Granularidad**: Las ACL se aplican a nivel de endpoint, lo que permite un control detallado sobre qué operaciones puede realizar cada rol.
- **Estándar Abierto**: El uso de OpenAPI 3.1 para definir las ACL facilita la documentación y la integración con herramientas de desarrollo.
- **Autenticación Multifactor**: El sistema soporta tanto tokens JWT (para usuarios finales) como claves API (para servicios internos).
- **Validación Centralizada**: El Servicio de Autenticación centraliza la validación de tokens y permisos, reduciendo la duplicación de lógica.

### 2. Debilidades y Vulnerabilidades

#### 2.1. Falta de Validación de Permisos en el Backend
- **Problema**: Aunque las ACL se definen en el contrato OpenAPI, no hay garantía de que el backend valide correctamente los permisos. Por ejemplo, el Servicio de Cuentas podría permitir que un usuario acceda a la información de otro usuario si no se valida el `id` de la cuenta contra el `subject` del token JWT.
- **Impacto**: Acceso no autorizado a datos sensibles.
- **Recomendación**: Implementar validación de permisos en el backend para cada endpoint, asegurando que el `subject` del token JWT coincida con el `id` de la cuenta solicitada.

#### 2.2. Claves API Estáticas
- **Problema**: Las claves API para acceso entre servicios son estáticas y no tienen fecha de expiración. Esto aumenta el riesgo de que una clave comprometida sea utilizada indefinidamente.
- **Impacto**: Acceso no autorizado a servicios internos si una clave es filtrada.
- **Recomendación**: Implementar un mecanismo de rotación automática de claves API y asignar fechas de expiración cortas.

#### 2.3. Falta de Auditoría en Cambios de Permisos
- **Problema**: No hay un registro de auditoría para los cambios en las ACL, como la asignación o revocación de roles.
- **Impacto**: Dificultad para rastrear quién realizó cambios en los permisos y cuándo.
- **Recomendación**: Implementar logs de auditoría para todos los cambios en las ACL y revisarlos periódicamente.

#### 2.4. Exposición de Endpoints Sensibles
- **Problema**: Algunos endpoints críticos, como los relacionados con la gestión de préstamos, no requieren autenticación adicional más allá del token JWT. Esto podría permitir que un atacante con un token válido realice operaciones no autorizadas.
- **Impacto**: Fraude en operaciones financieras.
- **Recomendación**: Implementar autenticación multifactor (MFA) para endpoints sensibles, como la aprobación de préstamos.

#### 2.5. Falta de Rate Limiting por Rol
- **Problema**: El rate limiting se aplica globalmente, sin considerar el rol del usuario. Esto podría permitir que un usuario con un token válido realice un número excesivo de solicitudes.
- **Impacto**: Ataques de denegación de servicio (DoS).
- **Recomendación**: Implementar rate limiting diferenciado por rol, con límites más estrictos para roles con menos privilegios.

## Análisis de Riesgo

### 1. Matriz de Riesgo
| Amenaza                          | Vulnerabilidad                     | Impacto               | Probabilidad | Riesgo  |
|---------------------------------|------------------------------------|-----------------------|---------------|---------|
| Acceso no autorizado a datos    | Falta de validación de permisos    | Alto                  | Media         | Alto    |
| Compromiso de claves API        | Claves estáticas sin expiración    | Alto                  | Alta           | Alto    |
| Cambios no autorizados en ACL   | Falta de auditoría                 | Medio                 | Baja           | Medio   |
| Fraude en operaciones financieras| Exposición de endpoints sensibles  | Alto                  | Media         | Alto    |
| Ataques de DoS                  | Falta de rate limiting por rol     | Medio                 | Alta           | Alto    |

### 2. Mitigaciones Recomendadas
1. **Validación de Permisos en el Backend**:
   - Implementar lógica en el backend para validar que el `subject` del token JWT coincida con el `id` de la cuenta solicitada.
   - Ejemplo de código en el Servicio de Cuentas:
     ```javascript
     function validateAccountAccess(tokenSubject, accountId) {
       if (tokenSubject !== accountId) {
         throw new Error('Access denied: token subject does not match account ID');
       }
     }
     ```

2. **Rotación Automática de Claves API**:
   - Implementar un servicio de gestión de claves API que genere y rote claves automáticamente cada 24 horas.
   - Almacenar las claves en un servicio de secrets seguro, como AWS Secrets Manager o HashiCorp Vault.

3. **Auditoría de Cambios en ACL**:
   - Registrar todos los cambios en las ACL en un log centralizado.
   - Revisar los logs periódicamente para detectar actividades sospechosas.

4. **Autenticación Multifactor para Endpoints Sensibles**:
   - Implementar MFA para endpoints críticos, como la aprobación de préstamos.
   - Utilizar servicios como Auth0 o Okta para gestionar el MFA.

5. **Rate Limiting por Rol**:
   - Configurar rate limiting diferenciado por rol en el Servicio Cliente.
   - Ejemplo de configuración:
     ```yaml
     rate_limits:
       USER:
         requests_per_minute: 60
       ADMIN:
         requests_per_minute: 120
       SERVICE:
         requests_per_minute: 300
     ```

## Conclusión
Las ACL en el sistema SOA proporcionan un nivel básico de seguridad, pero presentan varias vulnerabilidades que podrían ser explotadas por atacantes. Las recomendaciones descritas en este informe deben implementarse para mejorar la eficacia de las ACL y reducir el riesgo de accesos no autorizados, fraudes y ataques de denegación de servicio. Además, se recomienda realizar auditorías de seguridad periódicas para garantizar que las ACL se mantengan actualizadas y efectivas.

## Referencias
- [OpenAPI 3.1 Specification](https://spec.openapis.org/oas/v3.1.0)
- [ISO 27001:2013](https://www.iso.org/standard/54534.html)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [JWT Best Practices](https://datatracker.ietf.org/doc/html/rfc8725)