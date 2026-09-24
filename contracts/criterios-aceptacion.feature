Feature: Validación de Listas de Control de Acceso (ACL) y Auditorías de Seguridad
  Como analista de integración
  Quiero validar que las ACLs y auditorías funcionan correctamente
  Para garantizar la seguridad del sistema SOA

  Background:
    Given el sistema SOA está desplegado y operativo
    And los servicios de autenticación y autorización están disponibles

  Scenario: Registro exitoso de transacción con permisos adecuados
    Given un usuario con scope "transactions:write"
    And el usuario autenticado con OAuth2
    When el usuario envía una solicitud POST a "/transactions" con los siguientes datos:
      | sourceAccount      | destinationAccount    | amount | currency | concept        |
      | ES9121000418450200051332 | ES7100302053091234567895 | 150.75 | EUR      | Pago de factura |
    Then la respuesta debe tener código HTTP 201
    And el cuerpo de la respuesta debe contener:
      | transactionId | status    |
      | .*        | COMPLETED |
    And el registro de auditoría debe contener una entrada con:
      | action              | resourceType | status  |
      | CREATE_TRANSACTION | TRANSACTION | SUCCESS |

  Scenario: Intento de registro de transacción sin permiso
    Given un usuario sin scope "transactions:write"
    And el usuario autenticado con OAuth2
    When el usuario envía una solicitud POST a "/transactions" con los siguientes datos:
      | sourceAccount      | destinationAccount    | amount | currency | concept        |
      | ES9121000418450200051332 | ES7100302053091234567895 | 150.75 | EUR      | Pago de factura |
    Then la respuesta debe tener código HTTP 403
    And el cuerpo de la respuesta debe contener:
      | code     | message                                      |
      | FORBIDDEN | El usuario no tiene permiso para realizar transacciones |
    And el registro de auditoría debe contener una entrada con:
      | action              | resourceType | status   |
      | CREATE_TRANSACTION | TRANSACTION | FAILURE |

  Scenario: Consulta de cuenta con ACLs restrictivas
    Given un usuario con scope "accounts:read"
    And el usuario autenticado con OAuth2
    And la cuenta con ID "acc-550e8400-e29b-41d4-a716-446655440002" pertenece al usuario
    When el usuario envía una solicitud GET a "/accounts/acc-550e8400-e29b-41d4-a716-446655440002"
    Then la respuesta debe tener código HTTP 200
    And el cuerpo de la respuesta debe contener:
      | accountNumber           | balance  |
      | ES9121000418450200051332 | 1250.30  |
    And el registro de auditoría debe contener una entrada con:
      | action        | resourceType | status  |
      | VIEW_ACCOUNT  | ACCOUNT      | SUCCESS |

  Scenario: Intento de consulta de cuenta ajena
    Given un usuario con scope "accounts:read"
    And el usuario autenticado con OAuth2
    And la cuenta con ID "acc-550e8400-e29b-41d4-a716-446655440002" no pertenece al usuario
    When el usuario envía una solicitud GET a "/accounts/acc-550e8400-e29b-41d4-a716-446655440002"
    Then la respuesta debe tener código HTTP 403
    And el cuerpo de la respuesta debe contener:
      | code     | message                                  |
      | FORBIDDEN | Acceso denegado a la cuenta solicitada |
    And el registro de auditoría debe contener una entrada con:
      | action        | resourceType | status   |
      | VIEW_ACCOUNT  | ACCOUNT      | FAILURE |

  Scenario: Consulta de logs de auditoría con rol insuficiente
    Given un usuario sin rol "AUDITOR"
    And el usuario autenticado con OAuth2
    When el usuario envía una solicitud GET a "/audit/logs?startDate=2023-10-01T00:00:00Z&endDate=2023-10-03T23:59:59Z"
    Then la respuesta debe tener código HTTP 403
    And el cuerpo de la respuesta debe contener:
      | code     | message                                        |
      | FORBIDDEN | El usuario no tiene permiso para acceder a los logs |
    And no debe existir registro de auditoría para esta acción

  Scenario: Consulta de logs de auditoría exitosa
    Given un usuario con rol "AUDITOR" y scope "audit:read"
    And el usuario autenticado con OAuth2
    When el usuario envía una solicitud GET a "/audit/logs?startDate=2023-10-01T00:00:00Z&endDate=2023-10-03T23:59:59Z"
    Then la respuesta debe tener código HTTP 200
    And la respuesta debe contener al menos un registro con:
      | action              | resourceType | status  |
      | CREATE_TRANSACTION | TRANSACTION | SUCCESS |
    And el registro de auditoría debe contener una entrada con:
      | action        | resourceType | status  |
      | VIEW_AUDIT   | AUDIT       | SUCCESS |