# Despliegue

La aplicación se distribuye como imagen Docker de producción (`Dockerfile` multi-stage con
jemalloc, *bootsnap* precompilado, usuario sin privilegios y Thruster delante de Puma).

## Kamal 2 (servidor Linux propio)

`config/deploy.yml` define:

- contenedor `web` y contenedor `job` (Solid Queue) en el mismo servidor;
- `kamal-proxy` con TLS automático (Let's Encrypt) y *healthcheck* en `/up`;
- PostgreSQL 16 como *accessory*, expuesto solo en `127.0.0.1`;
- imagen publicada en GitHub Container Registry.

```bash
export KAMAL_REGISTRY_PASSWORD=ghp_...          # token con permiso write:packages
export CARTERA_CRM_DATABASE_PASSWORD=...        # contraseña de la base de producción
kamal setup                                      # primera vez
kamal deploy                                     # siguientes despliegues, sin downtime
kamal app exec "bin/rails db:seed"               # opcional: datos de demostración
```

Los secretos se leen del entorno de quien despliega (`.kamal/secrets`); `config/master.key`
nunca se versiona.

## Cualquier PaaS con Docker (Render, Railway, Fly.io)

1. Crear una base PostgreSQL administrada y una app desde este repositorio usando el `Dockerfile`.
2. Variables: `RAILS_MASTER_KEY`, `DATABASE_URL` (o `DB_HOST` + `CARTERA_CRM_DATABASE_PASSWORD`),
   `SOLID_QUEUE_IN_PUMA=true` para correr los *jobs* dentro de Puma en instancias pequeñas.
3. Comando de *release*: `bin/rails db:prepare`.

## Checklist de producción

- [x] `config.force_ssl` y `assume_ssl` activos (Rails 8 por defecto).
- [x] Límite de intentos de inicio de sesión (`rate_limit` en `SessionsController`).
- [x] Límite de solicitudes de la API por token.
- [x] Brakeman, bundler-audit e importmap audit en CI.
- [x] Restricciones de integridad en la base (ver [ADR-0002](adr/0002-reglas-en-modelo-y-base.md)).
- [ ] Copias de seguridad programadas de PostgreSQL (`pg_dump` diario a almacenamiento externo).
- [ ] Monitoreo de errores (p. ej. Sentry o Honeybadger) y alertas de *healthcheck*.
