# ADR-0001 · Hotwire en lugar de una SPA

- **Estado:** aceptada · **Fecha:** 2026-11

## Contexto

Los gestores de cobranza trabajan todo el día en formularios y listas (bandeja de cobro,
historial, acuerdos). Se necesita una interfaz rápida e interactiva, pero el equipo es pequeño
y el dominio (validaciones, políticas de negociación) vive en el servidor.

## Opciones

| Opción | A favor | En contra |
|---|---|---|
| SPA (React/Vue) + API | Ecosistema de componentes | Dos aplicaciones, validaciones duplicadas, estado en el cliente, build de JS |
| **Hotwire (Turbo + Stimulus)** | HTML desde el servidor, una sola fuente de verdad, sin build | Menos adecuado para interfaces tipo hoja de cálculo |

## Decisión

Hotwire con importmap (sin Node ni bundler):

- **Turbo Drive** para navegación instantánea con *morphing*.
- **Turbo Frames** para actualizar partes de la página (búsqueda de clientes).
- **Turbo Streams** para respuestas de formularios que modifican varias zonas (gestión
  registrada → historial + formulario + mensaje).
- **Stimulus** solo para comportamiento local (campos condicionales, filas dinámicas, suma en
  vivo, copiar al portapapeles).

## Consecuencias

- Las reglas de negocio no se duplican en JavaScript: el cliente solo ayuda (p. ej. la suma de
  cuotas) y el servidor decide.
- El plan de cuotas con festivos se calcula en el servidor y llega como Turbo Stream.
- La API JSON existe para integraciones, no para la interfaz.
