# Proceso de Negocio - Sistema SOA de Gestión de Pagos

## Descripción General
Este documento describe el flujo de negocio para el procesamiento de pagos en un sistema SOA, incluyendo las interacciones entre servicios, actores y puntos de decisión críticos. El proceso sigue la notación BPMN 2.0 y cubre tanto el happy path como los escenarios de error.

## Diagrama BPMN
```bpmn
<?xml version="1.0" encoding="UTF-8"?>
<bpmn:definitions xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL"
                  xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI"
                  xmlns:dc="http://www.omg.org/spec/DD/20100524/DC"
                  id="Definitions_1"
                  targetNamespace="http://bpmn.io/schema/bpmn">
  <bpmn:process id="Process_PagosSOA" isExecutable="false">
    <bpmn:startEvent id="StartEvent_1" name="Inicio Proceso de Pago">
      <bpmn:outgoing>Flow_1</bpmn:outgoing>
    </bpmn:startEvent>
    
    <bpmn:task id="Task_ValidarToken" name="Validar Token de Autenticación">
      <bpmn:incoming>Flow_1</bpmn:incoming>
      <bpmn:outgoing>Flow_2</bpmn:outgoing>
    </bpmn:task>
    
    <bpmn:exclusiveGateway id="Gateway_1" name="Token Válido?">
      <bpmn:incoming>Flow_2</bpmn:incoming>
      <bpmn:outgoing>Flow_3</bpmn:outgoing>
      <bpmn:outgoing>Flow_4</bpmn:outgoing>
    </bpmn:exclusiveGateway>
    
    <bpmn:task id="Task_RechazarPago" name="Rechazar Pago (Token Inválido)">
      <bpmn:incoming>Flow_4</bpmn:incoming>
      <bpmn:outgoing>Flow_5</bpmn:outgoing>
    </bpmn:task>
    
    <bpmn:endEvent id="EndEvent_1" name="Fin Proceso (Rechazo)">
      <bpmn:incoming>Flow_5</bpmn:incoming>
    </bpmn:endEvent>
    
    <bpmn:task id="Task_ValidarSaldo" name="Validar Saldo Disponible">
      <bpmn:incoming>Flow_3</bpmn:incoming>
      <bpmn:outgoing>Flow_6</bpmn:outgoing>
    </bpmn:task>
    
    <bpmn:exclusiveGateway id="Gateway_2" name="Saldo Suficiente?">
      <bpmn:incoming>Flow_6</bpmn:incoming>
      <bpmn:outgoing>Flow_7</bpmn:outgoing>
      <bpmn:outgoing>Flow_8</bpmn:outgoing>
    </bpmn:exclusiveGateway>
    
    <bpmn:task id="Task_RechazarSaldo" name="Rechazar Pago (Saldo Insuficiente)">
      <bpmn:incoming>Flow_8</bpmn:incoming>
      <bpmn:outgoing>Flow_9</bpmn:outgoing>
    </bpmn:task>
    
    <bpmn:endEvent id="EndEvent_2" name="Fin Proceso (Saldo Insuficiente)">
      <bpmn:incoming>Flow_9</bpmn:incoming>
    </bpmn:endEvent>
    
    <bpmn:task id="Task_ProcesarPago" name="Procesar Pago">
      <bpmn:incoming>Flow_7</bpmn:incoming>
      <bpmn:outgoing>Flow_10</bpmn:outgoing>
    </bpmn:task>
    
    <bpmn:task id="Task_RegistrarTransaccion" name="Registrar Transacción">
      <bpmn:incoming>Flow_10</bpmn:incoming>
      <bpmn:outgoing>Flow_11</bpmn:outgoing>
    </bpmn:task>
    
    <bpmn:task id="Task_NotificarUsuario" name="Notificar Usuario">
      <bpmn:incoming>Flow_11</bpmn:incoming>
      <bpmn:outgoing>Flow_12</bpmn:outgoing>
    </bpmn:task>
    
    <bpmn:endEvent id="EndEvent_3" name="Fin Proceso (Éxito)">
      <bpmn:incoming>Flow_12</bpmn:incoming>
    </bpmn:endEvent>
    
    <!-- Flows -->
    <bpmn:sequenceFlow id="Flow_1" sourceRef="StartEvent_1" targetRef="Task_ValidarToken" />
    <bpmn:sequenceFlow id="Flow_2" sourceRef="Task_ValidarToken" targetRef="Gateway_1" />
    <bpmn:sequenceFlow id="Flow_3" sourceRef="Gateway_1" targetRef="Task_ValidarSaldo" name="Sí" />
    <bpmn:sequenceFlow id="Flow_4" sourceRef="Gateway_1" targetRef="Task_RechazarPago" name="No" />
    <bpmn:sequenceFlow id="Flow_5" sourceRef="Task_RechazarPago" targetRef="EndEvent_1" />
    <bpmn:sequenceFlow id="Flow_6" sourceRef="Task_ValidarSaldo" targetRef="Gateway_2" />
    <bpmn:sequenceFlow id="Flow_7" sourceRef="Gateway_2" targetRef="Task_ProcesarPago" name="Sí" />
    <bpmn:sequenceFlow id="Flow_8" sourceRef="Gateway_2" targetRef="Task_RechazarSaldo" name="No" />
    <bpmn:sequenceFlow id="Flow_9" sourceRef="Task_RechazarSaldo" targetRef="EndEvent_2" />
    <bpmn:sequenceFlow id="Flow_10" sourceRef="Task_ProcesarPago" targetRef="Task_RegistrarTransaccion" />
    <bpmn:sequenceFlow id="Flow_11" sourceRef="Task_RegistrarTransaccion" targetRef="Task_NotificarUsuario" />
    <bpmn:sequenceFlow id="Flow_12" sourceRef="Task_NotificarUsuario" targetRef="EndEvent_3" />
  </bpmn:process>
  
  <bpmndi:BPMNDiagram id="BPMNDiagram_1">
    <bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Process_PagosSOA">
      <bpmndi:BPMNShape id="_BPMNShape_StartEvent_2" bpmnElement="StartEvent_1">
        <dc:Bounds x="100" y="100" width="36" height="36" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_ValidarToken_di" bpmnElement="Task_ValidarToken">
        <dc:Bounds x="200" y="80" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Gateway_1_di" bpmnElement="Gateway_1">
        <dc:Bounds x="350" y="100" width="50" height="50" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_RechazarPago_di" bpmnElement="Task_RechazarPago">
        <dc:Bounds x="450" y="200" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="EndEvent_1_di" bpmnElement="EndEvent_1">
        <dc:Bounds x="600" y="220" width="36" height="36" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_ValidarSaldo_di" bpmnElement="Task_ValidarSaldo">
        <dc:Bounds x="450" y="80" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Gateway_2_di" bpmnElement="Gateway_2">
        <dc:Bounds x="600" y="100" width="50" height="50" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_RechazarSaldo_di" bpmnElement="Task_RechazarSaldo">
        <dc:Bounds x="700" y="200" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="EndEvent_2_di" bpmnElement="EndEvent_2">
        <dc:Bounds x="850" y="220" width="36" height="36" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_ProcesarPago_di" bpmnElement="Task_ProcesarPago">
        <dc:Bounds x="700" y="80" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_RegistrarTransaccion_di" bpmnElement="Task_RegistrarTransaccion">
        <dc:Bounds x="850" y="80" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_NotificarUsuario_di" bpmnElement="Task_NotificarUsuario">
        <dc:Bounds x="1000" y="80" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="EndEvent_3_di" bpmnElement="EndEvent_3">
        <dc:Bounds x="1150" y="100" width="36" height="36" />
      </bpmndi:BPMNShape>
    </bpmndi:BPMNPlane>
  </bpmndi:BPMNDiagram>
</bpmn:definitions>
```

## Actores y Responsabilidades
| Actor               | Responsabilidad                                                                 | Servicios Involucrados                     |
|---------------------|---------------------------------------------------------------------------------|--------------------------------------------|
| Usuario             | Inicia el proceso de pago proporcionando credenciales y detalles de la transacción | Servicio de Autenticación, Servicio de Pagos |
| Servicio de Autenticación | Valida el token de autenticación y verifica permisos                          | API Gateway, Servicio de Autenticación       |
| Servicio de Cuentas | Valida el saldo disponible en la cuenta del usuario                           | Servicio de Cuentas                         |
| Servicio de Pagos   | Procesa la transacción y actualiza el saldo                                   | Servicio de Pagos, Base de Datos            |
| Servicio de Notificaciones | Envía notificaciones al usuario sobre el estado de la transacción             | Servicio de Notificaciones                  |

## Puntos de Decisión
1. **Validación de Token**
   - **Decisión**: ¿El token de autenticación es válido y tiene los permisos necesarios?
   - **Ruta Sí**: Continuar con la validación de saldo.
   - **Ruta No**: Rechazar el pago y notificar al usuario.

2. **Validación de Saldo**
   - **Decisión**: ¿El saldo disponible en la cuenta es suficiente para procesar el pago?
   - **Ruta Sí**: Proceder con el procesamiento del pago.
   - **Ruta No**: Rechazar el pago y notificar al usuario sobre saldo insuficiente.

## Reglas de Negocio
- **RB001**: El token de autenticación debe estar vigente y emitido para el usuario que solicita el pago.
- **RB002**: El saldo disponible en la cuenta debe ser igual o superior al monto del pago.
- **RB003**: Todas las transacciones deben registrarse en el sistema para auditoría.
- **RB004**: Las notificaciones deben enviarse en un plazo no mayor a 5 minutos después de procesar la transacción.

## Escenarios de Error
1. **Token Inválido**
   - **Causa**: El token proporcionado no es válido o ha expirado.
   - **Acción**: Rechazar el pago y notificar al usuario con el código de error `401 Unauthorized`.

2. **Saldo Insuficiente**
   - **Causa**: El saldo en la cuenta del usuario es menor al monto del pago.
   - **Acción**: Rechazar el pago y notificar al usuario con el código de error `402 Payment Required`.

3. **Error en el Procesamiento del Pago**
   - **Causa**: Fallo en el servicio de pagos al intentar registrar la transacción.
   - **Acción**: Reintentar el procesamiento hasta 3 veces. Si persiste el error, notificar al usuario con el código `500 Internal Server Error`.

## Consideraciones de Seguridad
- **Autenticación**: Todos los servicios deben validar el token JWT proporcionado en cada solicitud.
- **Autorización**: Las ACLs deben aplicarse para garantizar que solo los usuarios con los permisos adecuados puedan acceder a los servicios.
- **Cifrado**: Todas las comunicaciones entre servicios deben estar cifradas utilizando TLS 1.2 o superior.
- **Auditoría**: Todas las transacciones deben registrarse en un sistema de auditoría para garantizar trazabilidad.

## Dependencias Externas
- **Servicio de Autenticación**: Proporciona validación de tokens y gestión de permisos.
- **Base de Datos de Cuentas**: Almacena la información de saldo y transacciones de los usuarios.
- **Servicio de Notificaciones**: Envía notificaciones por correo electrónico y SMS.