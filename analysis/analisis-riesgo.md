# Análisis de Riesgo para Integración SOA

## 1. Contexto
Este documento evalúa los riesgos asociados a la integración de servicios en una arquitectura SOA distribuida, considerando modos de falla, impacto en el negocio y estrategias de mitigación. El análisis se enfoca en los flujos descritos en `proceso.bpmn.md` y los contratos definidos en `contracts/openapi.yaml`.

## 2. Metodología
Se utilizó el marco ISO 27005 para identificar amenazas y vulnerabilidades, combinado con técnicas de STRIDE para modelar escenarios de ataque.

## 3. Modos de Falla y Amenazas

### 3.1. Spoofing (Suplantación)
| Amenaza                          | Fuente                                   | Impacto                          | Probabilidad |
|----------------------------------|------------------------------------------|----------------------------------|--------------|
| Suplantación de servicio         | Ataque MITM en redes no cifradas        | Acceso no autorizado a datos     | Media        |
| Robo de credenciales OAuth2      | Phishing o fuerza bruta                  | Escalación de privilegios        | Alta         |

**Escenario**: Un atacante intercepta el token OAuth2 de un usuario legítimo y lo usa para realizar transferencias desde su cuenta.

**Mitigación**:
- Implementar mTLS para comunicaciones entre servicios.
- Usar tokens JWT con firma asimétrica (RS256) y expiración corta (5 min).
- Habilitar rate limiting en endpoints de autenticación.

### 3.2. Tampering (Manipulación)
| Amenaza                          | Fuente                                   | Impacto                          | Probabilidad |
|----------------------------------|------------------------------------------|----------------------------------|--------------|
| Manipulación de payloads         | Falta de validación de schemas           | Corrupción de datos              | Alta         |
| Modificación de logs             | Acceso a sistemas de logging             | Pérdida de trazabilidad          | Media        |

**Escenario**: Un payload de transferencia es modificado en tránsito para aumentar el monto enviado.

**Mitigación**:
- Validar schemas en el servidor usando decoradores.
- Firmar digitalmente payloads sensibles con HMAC.
- Usar OpenAPI para definir esquemas estrictos y ejemplos.

### 3.3. Repudiation (Repudio)
| Amenaza                          | Fuente                                   | Impacto                          | Probabilidad |
|----------------------------------|------------------------------------------|----------------------------------|--------------|
| Falta de logs de auditoría       | Configuración insuficiente               | Imposibilidad de probar acciones | Alta         |
| Usuarios niegan transacciones    | Ausencia de firma digital                | Disputas legales                 | Media        |

**Escenario**: Un usuario afirma que no autorizó una transferencia, pero no hay registros suficientes para verificarlo.

**Mitigación**:
- Implementar logs estructurados con campos obligatorios:
  ```json
  {
    "timestamp": "ISO8601",
    "user_id": "UUID",
    "action": "transfer",
    "status": "success|failed",
    "ip_address": "IPv4/IPv6",
    "signature": "HMAC"
  }
  ```
- Incluir firmas digitales en transacciones críticas.

### 3.4. Information Disclosure (Fuga de Información)
| Amenaza                          | Fuente                                   | Impacto                          | Probabilidad |
|----------------------------------|------------------------------------------|----------------------------------|--------------|
| Exposición de datos sensibles    | ACLs mal configuradas                   | Pérdida de confidencialidad      | Alta         |
| Inyección de datos en logs       | Falta de sanitización                    | Fuga de PII                      | Media        |

**Escenario**: Un endpoint `/accounts/{id}` devuelve información completa de la cuenta sin verificar permisos.

**Mitigación**:
- Aplicar principle of least privilege en ACLs:
  ```yaml
  paths:
    /accounts/{id}:
      get:
        security:
          - OAuth2:
              - accounts:read
  ```
- Sanitizar logs para evitar incluir datos sensibles.

### 3.5. Denial of Service (DoS)
| Amenaza                          | Fuente                                   | Impacto                          | Probabilidad |
|----------------------------------|------------------------------------------|----------------------------------|--------------|
| Ataques de flooding              | Falta de rate limiting                   | Interrupción de servicios        | Alta         |
| Procesamiento de payloads grandes| Falta de límites en esquemas             | Degradación de rendimiento       | Media        |

**Escenario**: Un atacante envía miles de solicitudes simultáneas al endpoint `/transfers`.

**Mitigación**:
- Configurar rate limiting en APIs:
  ```yaml
  paths:
    /transfers:
      post:
        x-rate-limit:
          requests: 100
          per: 1 minute
  ```
- Validar tamaños máximos de payloads en OpenAPI:
  ```yaml
  schemas:
    TransferRequest:
      maxProperties: 10
      properties:
        amount:
          type: number
          maximum: 1000000
  ```

### 3.6. Elevation of Privilege (Escalada)
| Amenaza                          | Fuente                                   | Impacto                          | Probabilidad |
|----------------------------------|------------------------------------------|----------------------------------|--------------|
| ACLs demasiado permisivas       | Configuración genérica                   | Acceso a funciones no autorizadas| Alta         |
| Tokens con scopes excesivos      | Definición de scopes ambiguos            | Escalación de privilegios        | Media        |

**Escenario**: Un token OAuth2 con scope `user` permite acceder a endpoints administrativos.

**Mitigación**:
- Definir scopes granulares en OpenAPI:
  ```yaml
  components:
    securitySchemes:
      OAuth2:
        type: oauth2
        flows:
          authorizationCode:
            scopes:
              accounts:read: "Leer cuentas"
              transfers:write: "Realizar transferencias"
              admin: "Funciones administrativas"
  ```
- Usar RBAC para asignar permisos.

## 4. Impacto en el Negocio
| Amenaza               | Impacto Operativo                     | Impacto Financiero               | Impacto Reputacional          |
|-----------------------|----------------------------------------|----------------------------------|----------------------------------|
| Spoofing              | Interrupción de servicios              | Pérdidas por fraude              | Pérdida de confianza            |
| Tampering             | Corrupción de datos                    | Costos de recuperación           | Daño a la marca                 |
| Repudiation           | Disputas legales                       | Multas regulatorias              | Pérdida de credibilidad         |
| Information Disclosure| Incumplimiento de regulaciones         | Multas (GDPR, PCI-DSS)           | Daño reputacional               |
| DoS                   | Interrupción de servicios críticos     | Pérdidas por downtime            | Frustración de clientes         |
| Elevation of Privilege| Acceso no autorizado                   | Robo de fondos                   | Demandas legales                |

## 5. Estrategias de Mitigación
### 5.1. Controles Técnicos
| Control                          | Implementación                          | Herramienta/Referencia           |
|---------------------------------|-----------------------------------------|-----------------------------------|
| Autenticación fuerte            | OAuth2 + mTLS                           | Keycloak, OpenSSL                |
| Validación de schemas           | Decoradores en servicios                | Pydantic, Joi                    |
| Rate limiting                    | Middleware en API Gateway               | Kong, AWS WAF                    |
| Cifrado en tránsito             | TLS 1.2/1.3                             | OpenSSL                          |
| Logs estructurados              | Formato JSON con firma digital          | ELK Stack                        |

### 5.2. Controles de Proceso
- **Revisión de código**: Análisis estático en cada commit.
- **Pruebas de penetración**: Ejecutar trimestralmente.
- **Capacitación**: Talleres anuales sobre seguridad en APIs.
- **Gestión de incidentes**: Plan documentado para respuesta a brechas.

## 6. Trade-offs: Orquestación vs Coreografía
### 6.1. Orquestación
**Ventajas**:
- Centralización del control de flujo.
- Facilidad para implementar transacciones distribuidas.
- Mejor visibilidad del estado global.

**Riesgos**:
- Punto único de fallo.
- Cuello de botella en el orquestador.
- Dificultad para escalar servicios individuales.

**Mitigación de riesgos**:
- Implementar orquestador en alta disponibilidad.
- Usar circuit breakers para manejar fallos.
- Monitorear latencia en el orquestador.

### 6.2. Coreografía
**Ventajas**:
- Escalabilidad horizontal.
- Resiliencia ante fallos de servicios individuales.
- Flexibilidad para cambiar flujos.

**Riesgos**:
- Complejidad en el seguimiento de flujos.
- Dificultad para manejar transacciones atómicas.
- Riesgo de ciclos infinitos.

**Mitigación de riesgos**:
- Implementar timeouts en eventos.
- Usar logs distribuidos para trazabilidad.
- Validar esquemas de eventos con OpenAPI.

### 6.3. Decisión Recomendada
Se recomienda un **modelo híbrido**:
- Usar **orquestación** para flujos críticos con transacciones atómicas (ej. transferencias).
- Usar **coreografía** para flujos no críticos y escalables (ej. notificaciones).

**Justificación**:
- Balancea la necesidad de control en operaciones financieras con la escalabilidad en servicios secundarios.
- Reduce el riesgo de fallos en cascada mientras mantiene flexibilidad.

## 7. Matriz de Riesgo Residual
| Amenaza               | Probabilidad Inicial | Impacto Inicial | Riesgo Inicial | Controles Implementados               | Probabilidad Residual | Impacto Residual | Riesgo Residual |
|-----------------------|----------------------|------------------|-----------------|----------------------------------------|-----------------------|-------------------|------------------|
| Spoofing              | Alta                 | Alto             | Crítico         | mTLS + OAuth2 + rate limiting           | Baja                  | Medio             | Medio            |
| Tampering             | Alta                 | Alto             | Crítico         | Schema validation + HMAC                | Media                 | Bajo              | Bajo             |
| Repudiation           | Media                | Alto             | Alto             | Logs estructurados + firma digital      | Baja                  | Bajo              | Bajo             |
| Information Disclosure| Alta                 | Alto             | Crítico         | ACLs granulares + sanitización de logs  | Media                 | Medio             | Medio            |
| DoS                   | Alta                 | Alto             | Crítico         | Rate limiting + payload size limits     | Media                 | Medio             | Medio            |
| Elevation of Privilege| Alta                 | Alto             | Crítico         | RBAC + scopes granulares                | Baja                  | Medio             | Bajo             |

## 8. Conclusiones
- El principal riesgo identificado es la **exposición de datos sensibles** debido a ACLs mal configuradas.
- Los controles recomendados reducen el riesgo residual a niveles **medios/bajos**.
- La implementación de un modelo híbrido (orquestación + coreografía) mitiga riesgos operativos sin sacrificar escalabilidad.

## 9. Próximos Pasos
1. Priorizar la implementación de ACLs granulares en OpenAPI.
2. Configurar rate limiting en el API Gateway.
3. Implementar validación de schemas en servicios críticos.
4. Realizar pruebas de penetración en los endpoints sensibles.

---
*Documento alineado con ISO 27005 y marco STRIDE para análisis de amenazas.*