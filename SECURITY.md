# Política de seguridad

## Reportar una vulnerabilidad

No abras un issue público: usa **Security → Report a vulnerability** (reporte privado de GitHub).

## Prácticas del proyecto

- `config/master.key` y cualquier `.env` están fuera del control de versiones.
- Tokens de API guardados como SHA-256, revocables y con registro de último uso.
- Límite de intentos de inicio de sesión y de solicitudes a la API.
- Brakeman, bundler-audit e importmap audit en cada push (CI).
- Dependabot para gemas, GitHub Actions e imagen base de Docker.
- Los datos de demostración son sintéticos; no se deben cargar datos reales de clientes en
  entornos de desarrollo (Ley 1581 de 2012 de protección de datos personales).
