# Evaluación de Riesgos de Seguridad en Arquitectura SOA

En el contexto de la arquitectura SOA, se requiere evaluar y mitigar los riesgos de seguridad en sistemas distribuidos y microservicios. El objetivo es entender el propósito de las listas de control de acceso (ACL) y el papel de las auditorías de seguridad en el ciclo de vida de desarrollo de software. El análisis se centrará en un sistema SOA ficticio con múltiples servicios que interactúan entre sí.

## Informacion General

| Campo | Valor |
|-------|-------|
| **Tema** | analisis de vulnerabilidad |
| **Nivel** | advanced-l2 |
| **Tipo** | mixed |
| **Tiempo estimado** | 8 horas |

## Fases del Reto

### Fase 0: Configuración del Proyecto

**Objetivo:** Obtener el proyecto base funcional enviando el Código Base a un asistente de IA, que lo analizará, corregirá errores y generará un ZIP listo para usar.

**Tiempo estimado:** 15-30 minutos

**Instrucciones:**

- Asegúrate de tener instalado para ejecutar el proyecto: Un IDE o editor de código.
- Copia todo el contenido del campo **Código Base** de este reto — incluyendo el texto de instrucciones que aparece al inicio.
- Abre un asistente de IA (Claude en claude.ai, ChatGPT o Gemini — se recomienda Claude), pega el contenido copiado en el chat y envíalo.
- El asistente analizará los archivos, corregirá errores y generará un archivo ZIP descargable. Descárgalo y extráelo en la carpeta donde quieras trabajar.
- Verifica que el proyecto arranca sin errores.

**Entregable:** El proyecto compila/arranca sin errores.

<details>
<summary>Pistas de conocimiento</summary>

- Copia el Código Base completo incluyendo el texto de instrucciones al inicio — esas instrucciones le indican al asistente exactamente qué hacer con los archivos.
- Si el asistente no genera el ZIP automáticamente al terminar el análisis, escríbele: "genera el ZIP ahora".
- Si el proyecto tiene errores al arrancar, comparte el mensaje de error con el mismo asistente para que lo corrija.

</details>

### Fase 1: Exploración del Sistema SOA

**Objetivo:** Identificar los componentes y las interacciones clave en el sistema SOA.

**Tiempo estimado:** 2 horas

**Instrucciones:**

- Analiza el sistema SOA proporcionado y enumera los servicios, sus responsabilidades y las interacciones entre ellos.
- Identifica las restricciones y ambigüedades presentes en el sistema.

**Entregable:** Mapa de componentes y restricciones del sistema SOA.

<details>
<summary>Pistas de conocimiento</summary>

- Considera los diferentes tipos de servicios y cómo se comunican.
- Piensa en las posibles vulnerabilidades basadas en las interacciones identificadas.

</details>

### Fase 2: Evaluación de Listas de Control de Acceso (ACL)

**Objetivo:** Evaluar la implementación y eficacia de las ACL en el sistema SOA.

**Tiempo estimado:** 3 horas

**Instrucciones:**

- Investiga el propósito de las ACL en el contexto de la seguridad del sistema.
- Evalúa cómo se implementan las ACL en los servicios identificados y determina si son efectivas para mitigar riesgos.

**Entregable:** Informe de evaluación de las ACL en el sistema SOA.

<details>
<summary>Pistas de conocimiento</summary>

- Considera los diferentes niveles de acceso y permisos que deben ser gestionados.
- Piensa en cómo las ACL pueden ser explotadas si no están correctamente implementadas.

</details>

### Fase 3: Auditoría de Seguridad

**Objetivo:** Realizar una auditoría de seguridad en el ciclo de vida de desarrollo del sistema SOA.

**Tiempo estimado:** 3 horas

**Instrucciones:**

- Determina el papel de las auditorías de seguridad en el ciclo de vida de desarrollo del software.
- Propón un plan de auditoría que incluya la identificación de riesgos, evaluación de controles y recomendaciones para mitigar vulnerabilidades.

**Entregable:** Plan de auditoría de seguridad para el sistema SOA.

<details>
<summary>Pistas de conocimiento</summary>

- Considera las diferentes etapas del ciclo de vida de desarrollo y cómo las auditorías pueden ser integradas.
- Piensa en los tipos de riesgos que deben ser identificados y cómo pueden ser mitigados.

</details>

## Dimensiones Evaluadas

- **queEs**: ¿Cuál es el propósito de las listas de control de acceso (ACL) en el sistema SOA?
- **paraQueSirve**: ¿Cuál es el papel de las auditorías de seguridad en el ciclo de vida de desarrollo de software?
- **erroresComunes**: ¿Cuáles son los errores comunes en la implementación de ACL y cómo pueden ser mitigados?
- **queDecisionesImplica**: ¿Qué decisiones críticas deben tomarse al diseñar un plan de auditoría de seguridad para el sistema SOA?

## Criterios de Evaluacion

- Identificar y explicar el propósito de las ACL en el sistema SOA.
- Evaluar la implementación y eficacia de las ACL.
- Determinar el papel de las auditorías de seguridad en el ciclo de vida de desarrollo.
- Proponer un plan de auditoría de seguridad que incluya identificación de riesgos y recomendaciones para mitigar vulnerabilidades.

## Como trabajar con un asistente de IA

Hay dos caminos, elegi uno:

- **AGENTS.md** (recomendado) — instrucciones nativas del repo. Abri esta carpeta con tu agente local (Claude Code, Cursor, Codex, Copilot, Gemini) y las carga solo. Sabe que archivos faltan y con que comando se verifica, y completa el scaffold escribiendo en disco.
- **PROMPT_MEJORA.md** — para copiar y pegar en un chat (claude.ai, ChatGPT). Devuelve un ZIP con el proyecto. Sirve si no tenes un agente en el IDE.

Ninguno de los dos resuelve las fases del reto: eso es tu trabajo.

## Verificacion

El proyecto esta listo para trabajar cuando este comando corre sin errores:

```bash
npx --yes @redocly/cli lint contracts/openapi.yaml
```

---

*Reto generado automaticamente por Challenge Generator - Pragma*
