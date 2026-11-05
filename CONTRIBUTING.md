# Guía de contribución

1. Rama desde `main`: `feat/…`, `fix/…`, `docs/…`.
2. `bin/setup` y luego, antes de cada PR: `bin/rubocop`, `bin/brakeman`, `bin/rails test test:system`.
3. Commits con [Conventional Commits](https://www.conventionalcommits.org/es/).

## Convenciones

- Controladores delgados: la lógica de negocio va en modelos, servicios (`app/services`) o
  consultas (`app/queries`).
- Toda regla crítica se valida en el modelo **y** se protege en la base con una migración
  (ver `docs/adr/0002-reglas-en-modelo-y-base.md`).
- Ningún texto visible al usuario queda en inglés: usa `config/locales/es.yml`
  (las pruebas fallan si falta una traducción).
- Las pruebas nunca salen a internet (WebMock). Las integraciones externas se inyectan.
- Endpoints nuevos de la API: documentarlos en `docs/api.md` y `docs/openapi.yaml`.
