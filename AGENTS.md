# AGENTS.md

Instrucciones para el agente de IA que abra este repositorio (Claude Code, Cursor, Codex, Copilot, Gemini). Se cargan solas: no hay que pegar nada en ningun chat.

## Que es este repositorio

Es el codigo base de un reto de aprendizaje de Pragma: **Evaluación de Riesgos de Seguridad en Arquitectura SOA**.

| | |
|---|---|
| Tema | analisis de vulnerabilidad |
| Nivel | advanced-l2 |
| Chapter | Integración — Analista |
| Especialidad | SOA |
| Stack | YAML / OpenAPI 3.1 |
| Patron arquitectonico | Documentación de Arquitectura SOA con análisis de seguridad |
| Tiempo estimado | 8 horas |

## Receta del stack

Esqueleto obligatorio:

- `openapi.yaml`
- `proceso.bpmn.md`
- `mapeo-de-datos.csv`

Dependencias:

- @redocly/cli latest
- OpenAPI 3.1 Specification 3.1.0
- BPMN 2.0 n/a
- ISO 27001 n/a

## Tu tarea

Dejar este conjunto de artefactos en estado **verificable**: que el comando de verificacion corra sin errores. Escribi los archivos en disco, en este repositorio. No generes ZIPs ni archivos adjuntos.

En orden:

1. Corre `npx --yes @redocly/cli lint contracts/openapi.yaml` y mira que falla.
2. Completa lo que falte de la lista de abajo: manifiesto de dependencias, punto de entrada, capa de interfaz y las capas del patron declarado.
3. Arregla SOLO los errores que impiden compilar o arrancar.
4. Volve a correr `npx --yes @redocly/cli lint contracts/openapi.yaml` hasta que pase.
5. Pará ahí.

## Regla dura: las fases son trabajo del humano

**PROHIBIDO implementar los entregables de las fases.** El valor del reto esta en que la persona los resuelva. Tu trabajo es que tenga un proyecto que arranca; el hueco pedagogico se queda como esta.

No resuelvas nada de esto:

- **Fase 1 — Exploración del Sistema SOA**: Mapa de componentes y restricciones del sistema SOA.
- **Fase 2 — Evaluación de Listas de Control de Acceso (ACL)**: Informe de evaluación de las ACL en el sistema SOA.
- **Fase 3 — Auditoría de Seguridad**: Plan de auditoría de seguridad para el sistema SOA.

Distincion operativa:

- **Arreglar** (si): import faltante, tipo que no existe, dependencia sin declarar, error de sintaxis, archivo referenciado que no existe.
- **No tocar** (no): logica de negocio incompleta, validaciones ausentes, secretos hardcodeados, APIs deprecadas que funcionan, concurrencia insegura, patrones mejorables. Eso es lo que la persona tiene que encontrar.

## Superficie de practica (NO completes)

Estos archivos SON el ejercicio de la persona. No los implementes; deja stubs. No toques la logica que el reto pide completar.

- [ ] `contracts/openapi.yaml` — El topic pide el contrato de API: openapi.yaml es el ejercicio.

## Lo que falta y tenes que completar

No se detectaron huecos: estan los archivos declarados, el boilerplate del stack y ninguna referencia quedo colgando. Igual corre el comando de verificacion — que los archivos existan no garantiza que compilen.

### Presentes (10)

- `contracts/openapi.yaml`
- `contracts/criterios-aceptacion.feature`
- `proceso.bpmn.md`
- `mapeo-de-datos.csv`
- `README.md`
- `docs/mapa-componentes-soa.md`
- `docs/evaluacion-acl.md`
- `analysis/plan-auditoria-seguridad.md`
- `analysis/mapeo-datos-seguridad.csv`
- `analysis/analisis-riesgo.md`

### Capas del patron declarado

Cada una tiene que existir como directorio real con al menos un archivo. Codigo plano en la raiz no satisface el patron.

- `docs`
- `contracts`
- `analysis`

## Verificacion

```bash
npx --yes @redocly/cli lint contracts/openapi.yaml
```

El comando tiene que pasar SIN implementar los archivos de la superficie de practica: solo andamiaje.

Ese comando pasando es la definicion de "terminado" para vos.

## Convenciones que tenes que respetar

- Un solo ecosistema: no declares librerias de otro lenguaje ni mezcles gestores de paquetes.
- Toda libreria que uses tiene que estar declarada en el manifiesto de dependencias.
- Todo import declarado tiene que usarse; todo tipo usado tiene que existir o venir de una dependencia declarada.
- El patron es **Documentación de Arquitectura SOA con análisis de seguridad**: los contratos (interfaces, puertos) los define la capa interna y los implementa la externa, nunca al revés.
- Los archivos que crees llevan implementacion real, no stubs: sin `TODO`, sin cuerpos vacios, sin `// getters y setters`.

## Contexto del candidato

Sirve para calibrar el nivel del codigo, no para resolver las fases.

- Perfil: Chapter Integración, Especialidad Analista SOA, Tecnología SOA, Advanced
- Brecha que el reto ataca: Explica el propósito de las listas de control de acceso (ACL) en el contexto de la seguridad. ¿Cuál es el papel de las auditorías de seguridad en el ciclo de vida de desarrollo de software? Explica cómo se podrían abordar los riesgos de seguridad en sistemas distribuidos y microservicios.
- Mision: Candidato con nivel Advanced en arquitectura SOA y análisis de integración

---

*Generado por Challenge Generator — Pragma. `README.md` tiene el enunciado completo del reto para la persona. `PROMPT_MEJORA.md` es la variante para pegar en un chat, si se prefiere ese flujo.*
