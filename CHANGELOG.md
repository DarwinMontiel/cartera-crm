# Changelog

Formato [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) · [SemVer](https://semver.org/lang/es/).

## [1.0.0] - 2026-11-05

### Agregado
- Autenticación nativa de Rails 8 con límite de intentos y recuperación de contraseña.
- Clientes con búsqueda en vivo (Turbo Frame, índice de trigramas) y normalización de datos.
- Bandeja de cobro por franja de mora y detalle de obligación con historial de gestiones.
- Registro de gestiones con promesas de pago vía Turbo Streams.
- Acuerdos de pago con plan de cuotas en días hábiles (API de festivos + respaldo), formulario
  anidado dinámico y validación de política de cobertura.
- API REST v1 con tokens hasheados, errores uniformes, paginación, límite de solicitudes y
  registro idempotente de acuerdos.
- Restricciones de integridad en PostgreSQL (CHECK, índices únicos y parciales).
- Tablero con indicadores de cartera y gestión.
- Interfaz en español (i18n), modo oscuro y diseño responsive.
- CI: Brakeman, bundler-audit, importmap audit, RuboCop, pruebas, pruebas de sistema y build Docker.
- Despliegue con Kamal 2 (web, jobs, PostgreSQL, TLS).

[1.0.0]: https://github.com/DarwinMontiel/cartera-crm/releases/tag/v1.0.0
