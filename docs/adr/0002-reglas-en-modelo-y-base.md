# ADR-0002 · Reglas críticas en el modelo y en PostgreSQL

- **Estado:** aceptada · **Fecha:** 2026-11

## Contexto

Las validaciones de ActiveRecord se pueden saltar (`update_column`, `insert_all`, consola,
condiciones de carrera entre dos solicitudes). En cobranza, un acuerdo duplicado o una promesa
sin valor tienen impacto operativo y regulatorio.

## Decisión

Toda regla cuya violación sea costosa se implementa dos veces:

1. **En el modelo**, para dar al usuario un mensaje claro y traducido.
2. **En PostgreSQL** (`CHECK`, índices únicos, índices parciales, llaves foráneas), como garantía.

Ejemplo de carrera resuelta por la base: dos solicitudes crean al mismo tiempo un acuerdo para
la misma obligación. Ambas pasan la validación; el índice único parcial
`WHERE status = 'active'` rechaza la segunda (`RecordNotUnique`), y el caso de uso la convierte
en un error de validación normal.

## Consecuencias

- Las pruebas verifican también la capa de base (`update_column` debe fallar).
- Una prueba detectó durante el desarrollo un error clásico de lógica de tres valores:
  `promise_amount > 0` con `NULL` da `NULL` y el `CHECK` **pasaba**. La restricción ahora exige
  `IS NOT NULL` explícitamente.
- Cambiar un catálogo (p. ej. un canal nuevo) requiere migración: es intencional.
