# PataSana: ejercicios de consulta de datos

> Basados en **tu** `DDL.sql` y `DML.sql`. Solo enunciados: la solución la escribes tú.
> Leyenda: 🟢 básico · 🟡 intermedio · 🔴 avanzado
>
> Numeración propia (C1, C2...), para no confundirla con la de `practica_sql_patasana.md`.
> Ninguno repite los ejercicios 61–155 de la práctica.
>
> Conexión: DBeaver en `localhost:5435`, base `patasana`. Todos los ejercicios son de **solo lectura**.

---

## Parte 1. Filtrar y ordenar

- [ ] **C1** 🟢 Lista las sedes con su nombre y su fecha de apertura, de la más antigua a la más nueva.
```sql
SELECT s.nombre_sede AS "nombre sede", s.fecha_apertura AS "fecha apertura"
FROM sede s
ORDER BY "fecha_apertura";
```
- [ ] **C2** 🟢 Muestra los cargos que están habilitados para atender pacientes
```sql
select c.nombre_cargo as "rol name"
from cargo c
where esta_habilitado is true;
```
- [ ] **C3** 🟢 Muestra los empleados inactivos. Si no hay ninguno, explica qué columna lo indica y qué valor tendría.
```sql
select CONCAT(p.nombre, ' ',p.apellido) as "nombre empleado"
from personal p
where is_active is true;

select (p.nombre || ' ' || p.apellido) as "nombre empleado"
from personal p
where is_active is true;
```
- [ ] **C4** 🟢 Lista las mascotas hembra que pesan menos de 5 kg. Recuerda que el peso está en gramos.
```sql
select m.nombre as "nombre", m.peso_g|| ' gr' as "peso mascota"
from mascota m
where m.peso_g < 5000;

```
- [ ] **C5** 🟢 Muestra las mascotas cuya fecha de nacimiento no se conoce.
```sql
select m.nombre as nombre
from mascota m
where m.fecha_nacimiento is null;
```
- [ ] **C6** 🟢 Muestra las mascotas fallecidas con su fecha de muerte, de la más reciente a la más antigua.
```sql
SELECT *
FROM mascota m
WHERE fecha_muerte IS NOT NULL
ORDER BY fecha_muerte desc;
```
- [ ] **C7** 🟢 Lista los servicios que duran 30 minutos o más, ordenados por duración y, a igual duración, por precio.
```sql
select *
from servicios s
where duracion >= 30
order by s.duracion, s.precio asc;
```
- [ ] **C8** 🟢 Muestra las citas canceladas o en estado *no asistió*.
- [ ] **C9** 🟢 Lista los medicamentos que **no** exigen fórmula médica.
- [ ] **C10** 🟢 Muestra las filas del inventario cuyo stock es exactamente igual al mínimo.
- [ ] **C11** 🟢 Lista las citas que tienen el motivo vacío.
- [ ] **C12** 🟢 Muestra los 3 servicios más caros.

## Parte 2. Fechas y texto

- [ ] **C13** 🟢 Muestra el año en que abrió cada sede y cuántos años lleva abierta hoy.
- [ ] **C14** 🟡 Lista las citas con la fecha y la hora en columnas separadas, con la fecha en formato `dd/mm/aaaa`.
- [ ] **C15** 🟡 Muestra cada cita en hora de Bogotá y en UTC. Explica por qué difieren y qué papel cumple la zona horaria que configuraste en el `docker-compose.yaml`.
- [ ] **C16** 🟡 Cuenta cuántas citas hubo en cada franja: mañana (antes de las 12), tarde (12 a 18) y noche.
- [ ] **C17** 🟡 Calcula la edad en años que tenía cada mascota fallecida al morir. Si no se conoce su nacimiento, muestra "Sin datos".
- [ ] **C18** 🟢 Muestra el peso de cada mascota en kilogramos, con un decimal.
- [ ] **C19** 🟡 Busca las mascotas cuya observación menciona la palabra "alergia", sin importar mayúsculas ni tildes en la escritura más común.
- [ ] **C20** 🟢 Muestra el nombre de cada empleado con su apellido en mayúsculas y la longitud de su nombre completo.
- [ ] **C21** 🟡 Lista los empleados que ingresaron en el mismo mes del año (sin importar el año) que la sede donde trabajan abrió.
- [ ] **C22** 🟡 Muestra las citas que ocurrieron en un día festivo de fin de año: entre el 24 y el 31 de diciembre de cualquier año.

## Parte 3. Agregación

- [ ] **C23** 🟢 Cuenta cuántos empleados tiene cada cargo.
- [ ] **C24** 🟢 Cuenta cuántas razas tiene registradas cada especie.
- [ ] **C25** 🟢 Calcula el peso mínimo, máximo y promedio de las mascotas de cada sexo.
- [ ] **C26** 🟡 Cuenta cuántas mascotas tiene cada cliente y muestra solo los que tienen más de una.
- [ ] **C27** 🟡 Muestra, por cada mes de 2025, cuántas citas se agendaron. Ordena por mes.
- [ ] **C28** 🟡 Por cada categoría de servicio, muestra cuántos servicios tiene y el precio promedio.
- [ ] **C29** 🟡 Por cada sede, calcula las unidades totales en inventario y cuántos medicamentos distintos maneja.
- [ ] **C30** 🟡 Calcula qué porcentaje de las citas terminó en cada estado.
- [ ] **C31** 🟡 Calcula la cantidad total formulada de cada medicamento y en cuántas citas distintas se formuló.
- [ ] **C32** 🔴 En una sola fila, muestra cuántas mascotas hay vivas, cuántas fallecidas y cuántas sin fecha de nacimiento.

## Parte 4. JOINs

- [ ] **C33** 🟢 Muestra cada sede con el nombre de su ciudad y su número de teléfono.
- [ ] **C34** 🟢 Lista los empleados con su número de documento y su teléfono.
- [ ] **C35** 🟢 Muestra los medicamentos con el nombre de su presentación.
- [ ] **C36** 🟢 Lista los servicios con el nombre de su categoría.
- [ ] **C37** 🟡 Muestra el inventario completo con el nombre de la sede y el del medicamento, ordenado por sede.
- [ ] **C38** 🟡 Muestra cada fórmula con la fecha de la cita, el nombre de la mascota, el medicamento y la cantidad.
- [ ] **C39** 🟡 Lista los clientes con la ciudad donde viven y los nombres de sus mascotas, incluidos los clientes sin mascotas.
- [ ] **C40** 🟡 Muestra las presentaciones que ningún medicamento usa.
- [ ] **C41** 🟡 Lista los veterinarios (cargo habilitado) que no tienen ninguna cita.
- [ ] **C42** 🟡 Lista los clientes que tienen al menos una mascota fallecida, con el nombre de la mascota.
- [ ] **C43** 🟡 Muestra los nombres de raza que se repiten entre especies distintas (por ejemplo, "Criollo"), con la especie de cada una.
- [ ] **C44** 🔴 Muestra los medicamentos que maneja Chapinero pero no Laureles, usando solo JOINs (sin subconsultas ni operaciones de conjuntos).

## Parte 5. Jerarquías: `lugar` y `personal`

- [ ] **C45** 🟢 Lista todos los lugares con el nombre de su región (país, departamento, ciudad...).
- [ ] **C46** 🟡 Muestra cada ciudad con el nombre de su departamento (o distrito capital), usando un *self join* sobre `lugar`.
- [ ] **C47** 🟡 Muestra cada sede con su ciudad, su departamento y su país en columnas separadas.
- [ ] **C48** 🟡 Cuenta cuántos lugares "hijos" tiene cada lugar.
- [ ] **C49** 🔴 Con una CTE recursiva, muestra la ruta completa de cada barrio hasta el país, por ejemplo *Chapinero > Bogotá D.C. > Colombia*.
- [ ] **C50** 🔴 Con una CTE recursiva, lista todos los lugares que están dentro de Colombia, a cualquier nivel, con su profundidad.
- [ ] **C51** 🟡 Muestra cada empleado con el nombre de su jefe y el cargo del jefe.
- [ ] **C52** 🟡 Cuenta cuántos subordinados **directos** tiene cada jefe.
- [ ] **C53** 🔴 Con una CTE recursiva, calcula para cada empleado cuántos niveles lo separan de la directora.
- [ ] **C54** 🔴 Muestra los empleados cuyo jefe trabaja en **otra** sede. ¿Tiene sentido según el enunciado?

## Parte 6. Subconsultas

- [ ] **C55** 🟢 Muestra las mascotas que pesan más que el promedio de todas.
- [ ] **C56** 🟡 Muestra las mascotas que pesan más que el promedio **de su especie**.
- [ ] **C57** 🟡 Muestra el empleado con el salario más alto de cada sede.
- [ ] **C58** 🟡 Lista los servicios que se han usado en todas las sedes que tienen citas.
- [ ] **C59** 🟡 Muestra las sedes que tienen más empleados que el promedio de empleados por sede.
- [ ] **C60** 🟡 Lista los clientes cuyas mascotas han tenido citas con más de un veterinario.
- [ ] **C61** 🔴 Muestra los medicamentos cuyo stock total en la red es menor que la suma de sus mínimos.

## Parte 7. Operaciones de conjuntos

- [ ] **C62** 🟢 Lista todos los números de teléfono registrados, indicando si pertenecen a una sede, a un empleado o a un cliente.
- [ ] **C63** 🟡 Muestra los números de documento que aparecen tanto en `personal` como en `cliente`. ¿Qué significaría que hubiera alguno?
- [ ] **C64** 🟡 Muestra las especies que tienen razas registradas pero ninguna mascota.
- [ ] **C65** 🟡 Muestra los medicamentos que están en inventario pero nunca se han formulado.

## Parte 8. CTE y funciones de ventana

- [ ] **C66** 🟡 Con una CTE, calcula las citas atendidas por veterinario y muestra solo los que están por encima del promedio.
- [ ] **C67** 🟡 Numera las mascotas de cada cliente de la mayor a la menor.
- [ ] **C68** 🟡 Muestra los empleados ordenados por salario dentro de su sede, con su posición (`DENSE_RANK`).
- [ ] **C69** 🟡 Para cada cita, muestra cuántas citas había tenido antes esa misma mascota.
- [ ] **C70** 🟡 Muestra la diferencia de salario entre cada empleado y el que le sigue en su misma sede.
- [ ] **C71** 🔴 Por cada sede, muestra el medicamento con más unidades en stock y el que tiene menos.
- [ ] **C72** 🔴 Calcula el número acumulado de citas mes a mes para cada sede.

## Parte 9. Calidad de datos: reglas que el DDL todavía no impide

> Estas consultas buscan datos que **violan** el enunciado. Lo ideal es que devuelvan 0 filas. Si devuelven algo, encontraste un caso que un trigger debería bloquear.

- [ ] **C73** 🟡 Citas con fecha posterior a la muerte de la mascota.
- [ ] **C74** 🟡 Citas asignadas a un empleado cuyo cargo no está habilitado para atender (por ejemplo, un auxiliar).
- [ ] **C75** 🟡 Citas asignadas a un empleado inactivo.
- [ ] **C76** 🟡 Citas cuya sede no coincide con la sede donde trabaja el veterinario.
- [ ] **C77** 🟡 Fórmulas registradas en citas que no están atendidas.
- [ ] **C78** 🟡 Clientes que tienen dos mascotas **vivas** con el mismo nombre.
- [ ] **C79** 🟡 Mascotas con fecha de muerte pero con citas programadas a futuro.
- [ ] **C80** 🟡 Citas en estado *programada* cuya fecha ya pasó (deberían estar como *no asistió* o *atendida*).
- [ ] **C81** 🔴 Medicamentos formulados en una sede que no tiene ese medicamento en su inventario.
- [ ] **C82** 🔴 Veterinarios con dos citas que se solapan en el tiempo, teniendo en cuenta la duración del servicio (no solo la misma hora exacta).

## Parte 10. Preguntas de la gerencia (del enunciado)

- [ ] **C83** 🟡 Agenda de citas programadas, con la fecha, la mascota, el servicio, el veterinario y el teléfono del dueño.
- [ ] **C84** 🟡 Historia clínica completa de Rex: todas sus citas, con el estado, el servicio, el veterinario y los medicamentos formulados.
- [ ] **C85** 🟡 Los veterinarios que más atienden, con su sede y su número de citas atendidas.
- [ ] **C86** 🟡 Los servicios más solicitados en cada sede.
- [ ] **C87** 🟡 Medicamentos por debajo del mínimo en cada sede y cuántas unidades convendría pedir para volver al mínimo.
- [ ] **C88** 🔴 Clientes que no vuelven hace más de seis meses: fecha de su última cita atendida y días transcurridos.
- [ ] **C89** 🔴 Próxima fecha de vacunación de cada mascota, suponiendo una vacuna cada 12 meses desde su última cita de vacunación.

## Parte 11. Facturación

> Necesitas datos en `factura`, `linea_factura` y `abono`. Hoy están vacías: primero resuelve los ejercicios 45–48 de la práctica.

- [ ] **C90** 🟡 Total de cada factura con su número de líneas.
- [ ] **C91** 🟡 Estado de cuenta de cada factura: total, abonado y saldo.
- [ ] **C92** 🟡 Clientes que deben dinero, con la suma de sus saldos (sin contar facturas anuladas).
- [ ] **C93** 🟡 Ingreso recaudado por sede, por mes y por método de pago.
- [ ] **C94** 🟡 Lo facturado por categoría de servicio.
- [ ] **C95** 🟡 Los 5 clientes que más gastan.
- [ ] **C96** 🔴 Citas atendidas que **no** tienen factura.
- [ ] **C97** 🔴 Facturas marcadas como *pagada* cuyo abonado no cubre el total, y facturas *pendientes* que ya están totalmente pagadas.
- [ ] **C98** 🔴 Facturas donde una línea de medicamento tiene un valor unitario distinto del precio actual del medicamento. Explica por qué eso **no** es un error.

## Parte 12. Retos

- [ ] **C99** 🔴 Un "tablero" por sede en una sola fila: empleados, veterinarios activos, mascotas atendidas distintas, citas por estado y medicamentos bajo el mínimo.
- [ ] **C100** 🔴 Para cada veterinario, el porcentaje de sus citas que terminó en *no asistió*, comparado con el porcentaje de su sede.
