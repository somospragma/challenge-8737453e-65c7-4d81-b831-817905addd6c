# Plan de Auditoría de Seguridad para Arquitectura SOA

## 1. Introducción
Este plan detalla la estrategia de auditoría de seguridad para evaluar y mitigar riesgos en un sistema SOA distribuido. El enfoque sigue las mejores prácticas de ISO 27001 y OWASP, adaptadas a entornos de microservicios y APIs.

## 2. Objetivos
- Identificar vulnerabilidades en componentes críticos del sistema.
- Evaluar la eficacia de los controles de seguridad existentes.
- Proponer recomendaciones para mitigar riesgos identificados.
- Establecer un ciclo de auditoría continuo integrado al SDLC.

## 3. Alcance
El alcance incluye:
- Servicios expuestos en el contrato OpenAPI (`contracts/openapi.yaml`).
- Flujos de negocio descritos en `proceso.bpmn.md`.
- Transformaciones de datos sensibles documentadas en `analysis/mapeo-datos-seguridad.csv`.
- Mecanismos de autenticación y autorización definidos en `securitySchemes` del OpenAPI.

## 4. Identificación de Riesgos
### 4.1. Riesgos Técnicos
| Riesgo                          | Impacto                          | Probabilidad | Nivel de Riesgo |
|---------------------------------|----------------------------------|--------------|-----------------|
| Exposición de datos sensibles   | Pérdida de confidencialidad      | Alta         | Crítico         |
| Falta de cifrado en tránsito    | Intercepción de comunicaciones   | Media        | Alto            |
| ACLs mal configuradas           | Acceso no autorizado             | Alta         | Crítico         |
| Falta de validación de inputs   | Inyección de código              | Media        | Alto            |
| Ausencia de logs de auditoría   | Imposibilidad de trazabilidad    | Alta         | Crítico         |

### 4.2. Riesgos de Negocio
- Incumplimiento de regulaciones (ej. GDPR, PCI-DSS).
- Pérdida de reputación por brechas de seguridad.
- Interrupción de servicios críticos.

## 5. Evaluación de Controles
### 5.1. Controles Existentes
| Control                          | Tipo               | Efectividad | Estado          |
|---------------------------------|--------------------|-------------|-----------------|
| Autenticación OAuth2            | Preventivo         | Media       | Implementado    |
| Cifrado TLS 1.2                 | Preventivo         | Alta        | Parcial         |
| Validación de schemas OpenAPI   | Preventivo         | Baja        | No implementado |
| Rate limiting                   | Detectivo          | Media       | Implementado    |
| Logs de accesos                 | Detectivo          | Baja        | Parcial         |

### 5.2. Hallazgos Clave
1. **Exposición de endpoints sensibles**: El servicio `/transfers` permite operaciones sin requerir scopes específicos.
2. **Falta de cifrado en payloads**: Algunos esquemas OpenAPI no especifican formatos cifrados para datos sensibles.
3. **ACLs ambiguas**: La definición de `securitySchemes` en OpenAPI no especifica permisos granulares por rol.

## 6. Recomendaciones
### 6.1. Prioritarias
1. **Reforzar ACLs**:
   - Definir scopes específicos para cada endpoint según roles (`admin`, `user`, `service`).
   - Ejemplo para `/transfers`:
     ```yaml
     security:
       - OAuth2:
           - transfers:write
     ```
2. **Cifrado obligatorio**:
   - Modificar esquemas OpenAPI para incluir campos cifrados en payloads sensibles.
   - Usar `format: encrypted` para campos como `accountNumber`.

### 6.2. Medianas Plazo
1. **Validación de schemas**:
   - Implementar validación estricta de schemas en los servicios usando decoradores.
   - Ejemplo en Python:
     ```python
     @validate_schema(TransferSchema)
     def transfer_funds(payload):
         pass
     ```
2. **Logs estructurados**:
   - Incluir campos obligatorios en logs: `user_id`, `timestamp`, `action`, `status`.

### 6.3. Largo Plazo
1. **Integración con SIEM**:
   - Centralizar logs en un sistema SIEM para correlación de eventos.
2. **Automatización de auditorías**:
   - Usar herramientas como OWASP ZAP en pipelines CI/CD.

## 7. Etapas del Ciclo de Vida de Desarrollo
| Fase               | Actividades de Auditoría                          | Herramientas/Referencias                     |
|--------------------|---------------------------------------------------|-----------------------------------------------|
| Diseño             | Revisión de esquemas OpenAPI y ACLs               | Swagger Editor, ISO 27001                    |
| Desarrollo         | Análisis estático de código                       | SonarQube, Bandit                             |
| Pruebas            | Pruebas de penetración                            | OWASP ZAP, Burp Suite                         |
| Despliegue         | Escaneo de vulnerabilidades en imágenes           | Trivy, Clair                                  |
| Operación          | Monitoreo continuo y respuesta a incidentes       | ELK Stack, SIEM                               |

## 8. Métricas de Éxito
- Reducción del 80% en vulnerabilidades críticas identificadas.
- Implementación del 100% de controles preventivos recomendados.
- Tiempo de respuesta a incidentes < 1 hora.

## 9. Responsabilidades
| Rol                | Responsabilidad                                  |
|--------------------|---------------------------------------------------|
| Arquitecto SOA     | Revisión de ACLs y esquemas OpenAPI               |
| Equipo de Seguridad| Ejecución de pruebas de penetración               |
| DevOps             | Implementación de controles en pipelines CI/CD    |

## 10. Cronograma
| Actividad                          | Duración  | Responsable        |
|-----------------------------------|-----------|--------------------|
| Revisión inicial de riesgos        | 2 semanas | Equipo de Seguridad |
| Implementación de ACLs mejoradas   | 1 semana  | Arquitecto SOA      |
| Pruebas de penetración             | 1 semana  | Equipo de Seguridad |
| Informe final                      | 3 días    | Todos               |

---
*Documento alineado con ISO 27001 y mejores prácticas OWASP para APIs.*