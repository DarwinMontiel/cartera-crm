# ADR-0003 · Festivos desde una API pública con caché y respaldo

- **Estado:** aceptada · **Fecha:** 2026-11

## Contexto

Las cuotas de un acuerdo deben vencer en días hábiles. Colombia tiene 18 festivos al año y la
mayoría se mueven al lunes (Ley Emiliani), así que una lista fija se desactualiza.

## Decisión

`HolidayCalendar` consulta la API pública de [Nager.Date](https://date.nager.at)
(`/api/v3/PublicHolidays/{año}/CO`) con:

- *timeouts* de 3 s de conexión y lectura;
- caché por año (`Rails.cache`, 30 días) y memoización por instancia;
- **respaldo versionado** en `config/holidays_co.yml` si la API falla, no responde o devuelve
  algo inválido (se registra una advertencia en el log).

El calendario se inyecta (`PaymentAgreement.calendar`) para que las pruebas usen uno
determinístico y la suite nunca salga a internet (WebMock bloquea la red).

## Consecuencias

- Una caída de un tercero nunca impide registrar un acuerdo.
- Las pruebas cubren respuesta exitosa, caché, error HTTP y *timeout* con WebMock.
- El respaldo debe actualizarse una vez al año (está documentado en el propio YAML).
