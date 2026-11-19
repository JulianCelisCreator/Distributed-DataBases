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

```sql
select *
from cita 
where estado::text ilike '%asisti%' or estado::text ilike '%atendida%';
```

- [ ] **C9** 🟢 Lista los medicamentos que **no** exigen fórmula médica.
```sql
select *
from medicamento
where es_formulado = 'TRUE';
```

- [ ] **C10** 🟢 Muestra las filas del inventario cuyo stock es exactamente igual al mínimo.
```sql
select *
from inventario i
where i.stock = i.minimo_stock;

```
- [ ] **C11** 🟢 Lista las citas que tienen el motivo vacío.
```sql
select *
from cita
where motivo = '' or motivo is NULL;
```
- [ ] **C12** 🟢 Muestra los 3 servicios más caros.
```sql
select *
from servicios s
order by s.precio desc
limit 3;
```
## Parte 2. Fechas y texto

- [ ] **C13** 🟢 Muestra el año en que abrió cada sede y cuántos años lleva abierta hoy.
```sql
select s.fecha_apertura as "Fecha apertura", date_part('year', AGE(current_date, s.fecha_apertura)) as anios
from sede s;
```
- [ ] **C14** 🟡 Lista las citas con la fecha y la hora en columnas separadas, con la fecha en formato `dd/mm/aaaa`.
```sql
select 
	date_part('day', fecha_cita) || '/' || date_part('month', fecha_cita) || '/' || date_part('year', fecha_cita) as fecha,
	fecha_cita::time(0) as "fecha_hora"
from cita
```
- [ ] **C15** 🟡 Muestra cada cita en hora de Bogotá y en UTC. Explica por qué difieren y qué papel cumple la zona horaria que configuraste en el `docker-compose.yaml`.

```sql
select
	fecha_cita at TIME zone 'America/Bogota' as hora_bogota,
	fecha_cita at TIME zone 'UTC' as hora_bogota
from cita;
```
- [ ] **C16** 🟡 Cuenta cuántas citas hubo en cada franja: mañana (antes de las 12), tarde (12 a 18) y noche.

```sql
select
	case
		when (extract(hour from fecha_cita) >= 0) and (extract(hour from fecha_cita)) < 12 then 'Morning'
		when (extract(hour from fecha_cita) >= 12) and (extract(hour from fecha_cita)) < 18 then 'afternoon'
		when (extract(hour from fecha_cita) >= 18) and (extract(hour from fecha_cita)) < 24 then 'Evening'
	end as hora,
	COUNT(id_cita) as "cantidad citas"
from cita
group by hora;
```

- [ ] **C17** 🟡 Calcula la edad en años que tenía cada mascota fallecida al morir. Si no se conoce su nacimiento, muestra "Sin datos".
```sql
select nombre as nombre, coalesce(cast(EXTRACT(year from AGE(fecha_muerte, fecha_nacimiento)) as TEXT), 'sin datos') as Edad
from mascota
where fecha_muerte is not null;
```
- [ ] **C18** 🟢 Muestra el peso de cada mascota en kilogramos, con un decimal.
```sql
select TRUNC(peso_g/1000,1) as peso
from mascota;
```
- [ ] **C19** 🟡 Busca las mascotas cuya observación menciona la palabra "alergia", sin importar mayúsculas ni tildes en la escritura más común.
```sql
select *
from mascota m
where observacion ilike 'alerg%';
```
- [ ] **C20** 🟢 Muestra el nombre de cada empleado con su apellido en mayúsculas y la longitud de su nombre completo.

```sql
select nombre || ' ' || UPPER(apellido) as nombre_completo, length(nombre || ' ' || UPPER(apellido))
from personal
```
- [ ] **C21** 🟡 Lista los empleados que ingresaron en el mismo mes del año (sin importar el año) que la sede donde trabajan abrió.

```sql
select *
from personal p
join sede s on s.id_sede = p.sede_id
where p.fecha_ingreso = s.fecha_apertura;
```
- [ ] **C22** 🟡 Muestra las citas que ocurrieron en un día festivo de fin de año: entre el 24 y el 31 de diciembre de cualquier año.

```sql
select *
from cita c
where extract(day from c.fecha_cita) between 24 and 31 and extract(month from c.fecha_cita) 
```

## Parte 3. Agregación

- [ ] **C23** 🟢 Cuenta cuántos empleados tiene cada cargo.
```sql
select c.nombre_cargo  as cargo, COUNT(p.id_personal) as cantidad
from personal p
join cargo c on c.id_cargo = p.cargo_id
group by c.nombre_cargo, p.cargo_id;
```
- [ ] **C24** 🟢 Cuenta cuántas razas tiene registradas cada especie.
```sql
select e.nombre , count(r.id_raza )
from raza r
join especie e on e.id_especie = r.especie_id
group by e.nombre
```
- [ ] **C25** 🟢 Calcula el peso mínimo, máximo y promedio de las mascotas de cada sexo.
```sql
select 
	case
		when m.sexo = 'H' then 'Hembra'
		else 'Macho'
	END as sexo,
	MIN(m.peso_g), MAX(m.peso_g), TRUNC(AVG(m.peso_g)) as peso_promedio
from mascota m
group by m.sexo
```
- [ ] **C26** 🟡 Cuenta cuántas mascotas tiene cada cliente y muestra solo los que tienen más de una.
```sql
select c.nombre, count(m.cliente_id)
from mascota m
join cliente c on c.id_cliente = m.cliente_id
group by c.nombre
```

- [ ] **C27** 🟡 Muestra, por cada mes de 2025, cuántas citas se agendaron. Ordena por mes.

```sql
select distinct(extract(month from c.fecha_cita)) as MONTH, count(id_cita) as CANTIDAD
from cita c
group by extract(month from c.fecha_cita)
order by MONTH asc;
```
- [ ] **C28** 🟡 Por cada categoría de servicio, muestra cuántos servicios tiene y el precio promedio.

```sql
select c.nombre as "nombre categoria", count(s.categoria_id ), AVG(s.precio)
from servicios s
join categoria c on c.id_categoria = s.categoria_id;
```
- [ ] **C29** 🟡 Por cada sede, calcula las unidades totales en inventario y cuántos medicamentos distintos maneja.

```sql
select s.nombre_sede as "nombre sede", SUM(stock), COUNT(distinct(medicamento_id))
from sede s
join inventario i on i.sede_id = s.id_sede
group by s.nombre_sede
```
- [ ] **C30** 🟡 Calcula qué porcentaje de las citas terminó en cada estado.

```sql
select c.estado, (COUNT((c.estado) )/(select COUNT(*) from cita)::numeric)*100 as Porcentaje 
from cita c
group by c.estado
```
- [ ] **C31** 🟡 Calcula la cantidad total formulada de cada medicamento y en cuántas citas distintas se formuló.

```sql
select m.id_medicamento , m.nombre, SUM(f.cantidad), COUNT(distinct(f.cita_id)) 
from formula f
join medicamento m on m.id_medicamento = f.medicamento_id
group by m.id_medicamento 
```
- [ ] **C32** 🔴 En una sola fila, muestra cuántas mascotas hay vivas, cuántas fallecidas y cuántas sin fecha de nacimiento.
```sql
select 
	COUNT(*) filter (where fecha_muerte is null), 
	COUNT(*) filter (where m.fecha_muerte is not null), 
	COUNT(*) filter (where m.fecha_nacimiento is null)
from mascota m;

```
## Parte 4. JOINs

- [ ] **C33** 🟢 Muestra cada sede con el nombre de su ciudad y su número de teléfono.
```sql
select s.nombre_sede as "Nombre sede", l.nombre as "Nombre ciudad", t.numero as "Numero telefono"
from sede s
join lugar l ON l.id_lugar = s.ciudad_id 
join telefono t on t.id_telefono = s.telefono_id;
```
- [ ] **C34** 🟢 Lista los empleados con su número de documento y su teléfono.
```sql
select p.nombre, d.numero, t.numero
from personal p
join documento d on d.id_documento = p.documento_id
join telefono t on t.id_telefono  = p.telefono_id;
```
- [ ] **C35** 🟢 Muestra los medicamentos con el nombre de su presentación.
```sql
select m.nombre as medicamento, p.nombre as presentacion
from medicamento m 
join presentacion p on p.id_presentacion = m.presentacion_id;
```
- [ ] **C36** 🟢 Lista los servicios con el nombre de su categoría.
```sql
select s.nombre, c.nombre 
from servicios s 
join categoria c  on s.categoria_id = c.id_categoria; 
```
- [ ] **C37** 🟡 Muestra el inventario completo con el nombre de la sede y el del medicamento, ordenado por sede.
```sql
select m.nombre, s.nombre_sede, i.id_inventario, i.medicamento_id, i.minimo_stock, i.sede_id, i.stock  
from inventario i
join sede s on i.sede_id = s.id_sede
join medicamento m on i.medicamento_id = m.id_medicamento 
order by s.nombre_sede;
```
- [ ] **C38** 🟡 Muestra cada fórmula con la fecha de la cita, el nombre de la mascota, el medicamento y la cantidad.

```sql
select me.nombre as medicamento ,c.fecha_cita, m.nombre, f.cantidad 
from cita c
join formula f on f.cita_id = c.id_cita 
join mascota m on c.mascota_id = m.id_mascota
join medicamento me on me.id_medicamento = f.medicamento_id;

```
- [ ] **C39** 🟡 Lista los clientes con la ciudad donde viven y los nombres de sus mascotas, incluidos los clientes sin mascotas.
```sql
select c.nombre as nombre_cliente, l.nombre as Ciudad_residencia, m.nombre as nombre_mascota
from cliente c
join lugar l on c.ciudad_id = l.id_lugar
join mascota m on m.cliente_id = c.id_cliente
order by c.nombre;
```																																															
- [ ] **C40** 🟡 Muestra las presentaciones que ningún medicamento usa.

```sql
select *
from presentacion p
left join medicamento m on m.presentacion_id = p.id_presentacion
where m.id_medicamento  is null;
```

- [ ] **C41** 🟡 Lista los veterinarios (cargo habilitado) que no tienen ninguna cita.
```sql
select p.*
from personal p
left join cita c on p.id_personal = c.veterinario_id
where c.id_cita is null;
```
- [ ] **C42** 🟡 Lista los clientes que tienen al menos una mascota fallecida, con el nombre de la mascota.
```sql
select c.nombre as "cliente nombre", m.nombre as "nombre mascota"
from cliente c
right join mascota m on m.cliente_id = c.id_cliente
where m.fecha_muerte is not NULL
```

- [ ] **C43** 🟡 Muestra los nombres de raza que se repiten entre especies distintas (por ejemplo, "Criollo"), con la especie de cada una.
```sql
select distinct(e.nombre), r1.nombre
from raza r1
join raza r2 on r1.nombre  = r2.nombre
join especie e on e.id_especie = r1.especie_id
where r1.especie_id <> r2.especie_id
```
- [ ] **C44-bis** 🔴 Muestra los servicios (nombre y precio) que se han prestado en citas de la sede Chapinero pero **nunca** en citas de la sede Laureles, usando solo JOINs (sin subconsultas, `NOT IN`, `NOT EXISTS`, `EXCEPT` ni CTE).
  - Tablas: `servicios`, `cita`, `sede`.
  - Un servicio puede aparecer muchas veces en `cita` de la misma sede: ¿qué pasa con las filas del resultado y cómo lo arreglas sin `GROUP BY`?
  - Busca ambas sedes **por nombre**, no por id. ¿La condición del nombre de Laureles va en el `ON` o en el `WHERE`? Prueba ambas y compara.
  - Necesitas `sede` y `cita` dos veces cada una (dos alias).
  - Verificación: consulta por separado los servicios de cada sede y resta a mano.
  - **Extra:** servicios que se prestan en alguna de las dos sedes pero no en ambas, solo con JOINs (pista: `FULL OUTER JOIN`).
```sql

```

- [ ] **C44-ter** 🔴 Lista los veterinarios (nombre y apellido) que tienen citas **atendidas** en la sede Chapinero pero **ninguna** cita atendida en la sede Laureles, usando solo JOINs (sin subconsultas, `NOT IN`, `NOT EXISTS`, `EXCEPT` ni CTE).
  - Tablas: `personal`, `cita`, `sede`.
  - Tiene la misma estructura que el C44-bis, pero ahora hay **dos** condiciones sobre el lado "que no debe existir": la sede y el estado. ¿Dónde va `estado = 'atendida'` para `c_la`: en el `ON` o en el `WHERE`? ¿Y para `c_ch`?
  - Trampa: un veterinario con una cita **cancelada** en Laureles **sí** debe salir. Comprueba que tu consulta lo incluye.
  - Fíjate que `personal` tiene su propio `sede_id` (la sede donde trabaja). No es lo que se pregunta: usa la sede **de la cita**.
  - Verificación: escribe también la intersección (atendidos en ambas sedes). Entre las dos consultas deben sumar todos los veterinarios con citas atendidas en Chapinero, sin repetir ninguno.
```sql

```

- [ ] **C44-quater** 🔴 Lista **todos** los servicios (nombre y precio) que **no** tuvieron ninguna cita atendida en la sede Laureles durante el año 2025, incluidos los servicios que nunca han tenido citas. Usa solo JOINs (sin subconsultas, `NOT IN`, `NOT EXISTS`, `EXCEPT` ni CTE).
  - Tablas: `servicios`, `cita`, `sede`.
  - Diferencia con el C44-bis: ahora la tabla base **no** es `cita` sino `servicios`. ¿Con qué tabla empieza el `FROM`? ¿Sigues necesitando un alias `c_ch`?
  - En el `ON` del `LEFT JOIN` de la cita van **cuatro** condiciones: el servicio, la sede, el estado y el rango de fechas. ¿Qué pasa con los servicios sin citas si pones la fecha en el `WHERE`?
  - `fecha_cita` es `TIMESTAMPTZ`: filtra el año con un rango (`>=` inicio y `<` inicio del año siguiente), no con `LIKE` ni convirtiendo a texto.
  - ¿Sigues necesitando `DISTINCT`? Piensa cuántas filas produce cada servicio cuando el `LEFT JOIN` no encuentra pareja.
  - Verificación: cuenta los servicios totales y los que sí se atendieron en Laureles en 2025. Tu resultado debe tener exactamente la diferencia.
```sql

```

### Self join: una tabla unida consigo misma

Idea clave: en un *self join* usas la misma tabla **dos veces con alias distintos**, y cada alias cumple un **rol** diferente (empleado/jefe, mascota A/mascota B, cita anterior/cita siguiente). Antes de escribir SQL, decide qué rol tiene cada alias.

- [ ] **SJ-1** 🟢 Lista las parejas de mascotas que pertenecen al **mismo cliente**: nombre del cliente, mascota A y mascota B.
  - Tablas: `mascota` (dos veces: `m1`, `m2`), `cliente`.
  - Primero únelas solo con `m1.cliente_id = m2.cliente_id` y mira el resultado: ¿aparece cada mascota emparejada **consigo misma**? ¿Aparece cada pareja **dos veces** (Max-Luna y Luna-Max)?
  - Arregla los dos problemas con **una sola** condición sobre los id. ¿Por qué `m1.id_mascota <> m2.id_mascota` resuelve solo uno de los dos, y qué operador resuelve ambos?
  - Verificación: un cliente con 3 mascotas debe producir exactamente 3 parejas. ¿Y uno con 4?
```sql
select c.nombre, m1.nombre, m2.nombre
from mascota m1
join mascota m2 on m1.cliente_id = m2.cliente_id and m1.id_mascota > m2.id_mascota
join cliente c on m1.cliente_id = c.id_cliente
```

- [ ] **SJ-2** 🟡 Muestra los empleados que ganan **más que su jefe directo**: nombre y salario del empleado, nombre y salario del jefe.
  - Tablas: `personal` (dos veces: `e` = empleado, `j` = jefe).
  - La columna `jefe_id` está en la fila del **empleado** y apunta al `id_personal` del **jefe**. Escribe el `ON` y léelo en voz alta: "el jefe de `e` es `j` cuando...". Si lo escribes al revés (`j.jefe_id = e.id_personal`), ¿qué roles quedan intercambiados?
  - ¿Qué pasa con la directora (no tiene jefe)? ¿Debe aparecer? ¿Importa usar `JOIN` o `LEFT JOIN` en esta pregunta en particular?
  - Variante: muestra **todos** los empleados con el nombre de su jefe, y `'(sin jefe)'` cuando no tengan. Ahora sí importa el tipo de join; usa `COALESCE`.
```sql
select p1.nombre, p1.cargo_id, p1.salario, coalesce(p2.nombre,'Sin jefe') as "Jefe", p2.cargo_id, p2.salario
from personal p1
left join personal p2 on p1.jefe_id  = p2.id_personal
```

- [ ] **SJ-3** 🔴 Muestra las mascotas que **volvieron** a una cita dentro de los **15 días** siguientes a una cita atendida: nombre de la mascota, fecha de la cita atendida y fecha de la cita de regreso.
  - Tablas: `cita` (dos veces: `c1` = cita atendida, `c2` = regreso), `mascota`.
  - El `ON` combina igualdad y desigualdades: misma mascota, `c2` **después** de `c1`, y `c2` a lo sumo 15 días después (`c1.fecha_cita + interval '15 days'`). ¿Qué pasaría si olvidas la condición "después de"?
  - El estado `'atendida'` es de `c1`, no de `c2`. ¿El regreso debe estar atendido también? Decide y justifica.
  - Si una mascota tiene 3 citas en 10 días, ¿cuántas filas produce? Haz la cuenta a mano antes de ejecutar y compara.
  - **Extra:** muestra solo el **primer** regreso de cada cita atendida, sin subconsultas (pista: un tercer alias `c3` con `LEFT JOIN` que busque una cita "entre `c1` y `c2`" y exige que no exista; es el anti-join que ya practicaste).
```sql
select m.nombre, c1.fecha_cita, c2.fecha_cita
from cita c1
join mascota m on c1.mascota_id = m.id_mascota and c1.estado= 'atendida' 
join cita c2 on c2.mascota_id = c1.mascota_id
			and c2.fecha_cita > c1.fecha_cita
			and c2.fecha_cita <= c1.fecha_cita + interval '15 days'

```

## Parte 5. Jerarquías: `lugar` y `personal`

- [ ] **C45** 🟢 Lista todos los lugares con el nombre de su región (país, departamento, ciudad...).
```sql
select l.nombre, r.nombre  
from lugar l
join region r on l.region_id = r.id_region
```
- [ ] **C46** 🟡 Muestra cada ciudad con el nombre de su departamento (o distrito capital), usando un *self join* sobre `lugar`.
```sql
select l1.nombre as nombre_ciudad, l2.nombre as nombre_departamento
from lugar l1
join lugar l2 on l1.lugar_padre_id = l2.id_lugar 
where l1.region_id = 5
```
- [ ] **C47** 🟡 Muestra cada sede con su ciudad, su departamento y su país en columnas separadas.

```sql
select  s.nombre_sede, l1.nombre, l2.nombre, l3.nombre
from lugar l1
left join lugar l2 on l1.lugar_padre_id  =  l2.id_lugar
left join lugar l3 on l2.lugar_padre_id = l3.id_lugar
right join sede s on s.ciudad_id = l1.id_lugar 

```

### CTE: consultas con nombre (preparación para C49 y C50)

Idea clave: una CTE (`WITH nombre AS (...)`) es una **tabla temporal con nombre** que solo existe durante la consulta. Sirve para partir un problema en pasos: primero calculas algo, le pones nombre y después lo usas como si fuera una tabla más.

- [ ] **CTE-1** 🟢 Reescribe la C47 con una CTE: primero calcula cada ciudad con su departamento y su país, y después une ese resultado con `sede`.
  - Tablas: `lugar` (tres veces dentro de la CTE), `sede`.
  - La CTE se puede llamar, por ejemplo, `ciudad_completa`, y no debe saber nada de las sedes. ¿Qué columnas necesita exponer para que la consulta principal pueda hacer el join con `sede`?
  - Ejecuta primero la CTE sola (solo el `SELECT` de adentro) y revisa el resultado antes de unirla.
  - Verificación: el resultado debe ser idéntico al de tu C47. ¿Cuál de las dos versiones te parece más fácil de leer?
```sql

```

- [ ] **CTE-2** 🟡 Usando tu C48 como CTE, muestra solo los lugares que tienen **más hijos que el promedio** de hijos por lugar.
  - Tablas: `lugar` (dos veces, dentro de la CTE).
  - La CTE es tu C48 tal cual, con alias claros en las columnas. La consulta principal la usa **dos veces**: una para listar los lugares y otra para calcular el promedio.
  - ¿El promedio debe incluir los lugares con 0 hijos? Cambia el resultado: decide y justifica.
  - ¿Por qué esto es más difícil sin CTE? Intenta escribirlo sin `WITH` y compara.
  - Verificación: calcula el promedio a mano con los datos del DML (total de lugares con padre ÷ total de lugares) y revisa que salgan los lugares correctos.
```sql

```

- [ ] **CTE-3** 🟡 Muestra cada ciudad con **cuántos clientes** viven en ella y **cuántas sedes** tiene, usando **dos CTE**.
  - Tablas: `lugar`, `cliente`, `sede`.
  - Varias CTE se separan con coma: `WITH a AS (...), b AS (...) SELECT ...`. Solo se escribe un `WITH`.
  - Trampa: intenta primero hacerlo **sin CTE**, con `lugar LEFT JOIN cliente LEFT JOIN sede` y un `GROUP BY`. Mira los números: ¿por qué salen inflados? Piensa cuántas filas produce una ciudad con 5 clientes y 2 sedes.
  - Con las CTE, cada una cuenta por separado y después las unes por ciudad. ¿Qué tipo de join necesitas para que una ciudad sin sedes o sin clientes no desaparezca? ¿Qué muestras en vez de `NULL`?
  - Verificación: la suma de la columna de clientes debe ser igual a `SELECT COUNT(*) FROM cliente WHERE ciudad_id IS NOT NULL`.
```sql

```

### CTE recursiva: una consulta que se repite

Idea clave: `WITH RECURSIVE` tiene dos partes unidas con `UNION ALL`. El **ancla** se ejecuta una sola vez y es el punto de partida. La parte **recursiva** se une con la propia CTE y produce el siguiente nivel; se repite, viendo solo las filas nuevas de la vuelta anterior, hasta que una vuelta no produce nada. Antes de escribir SQL, decide: ¿cuál es el punto de partida y en qué dirección avanzo?

- [ ] **CTR-1** 🟢 Sin usar ninguna tabla, genera los números del 1 al 10 con una CTE recursiva. Agrega una segunda columna con la **suma acumulada** (1, 3, 6, 10...).
  - El ancla es un `SELECT` sin `FROM`. La parte recursiva lee de la propia CTE.
  - ¿Dónde va la condición que detiene la recursión? Quítala a propósito, con un `LIMIT 20` en la consulta principal para protegerte, y mira qué pasa.
  - La suma acumulada es una columna que se **arrastra** de vuelta en vuelta: en cada fila nueva, ¿qué le sumas a la suma de la fila anterior?
  - Verificación: la fila del 10 debe tener suma 55.
```sql

```

- [ ] **CTR-2** 🟡 Partiendo de **Bogotá D.C.**, lista todos los lugares que están debajo de ella, a cualquier nivel, con su **nivel** (1 = localidad, 2 = barrio).
  - Tablas: `lugar` (dentro de la CTE y en la parte recursiva).
  - Ancla: el lugar Bogotá D.C., buscado **por nombre** y con nivel 0.
  - Parte recursiva: **bajas** del padre a los hijos. Es el mismo `ON` de tu C48: ¿qué columna de `lugar` se compara con qué columna de la CTE?
  - El nivel se arrastra igual que la suma de la CTR-1.
  - ¿Debe aparecer Bogotá D.C. en el resultado? Si no, ¿dónde la filtras: en la CTE o en la consulta principal?
  - Verificación: deben salir 6 localidades con nivel 1 y 8 barrios con nivel 2. Compáralo con el DML.
```sql

```

- [ ] **CTR-3** 🟡 Partiendo del barrio **El Chicó**, **sube** hasta el país y muestra cada lugar del camino con cuántos niveles está por encima del barrio.
  - Tablas: `lugar`.
  - Ahora la dirección es al revés que en la CTR-2: avanzas del hijo al padre. ¿Cómo cambia el `ON`? Léelo en voz alta: "el siguiente lugar es el padre del que tengo, cuando...".
  - ¿Por qué se detiene sola esta recursión, sin ninguna condición de parada? Piensa en el `lugar_padre_id` de Colombia.
  - Verificación: debe salir El Chicó (0), Chapinero (1), Bogotá D.C. (2) y Colombia (3).
  - **Extra:** cambia el barrio por Medellín. ¿Cuántos niveles salen ahora? Es la misma consulta y no tuviste que agregar ni quitar joins: eso es justamente lo que no podías hacer en la C47.
  - Con esto la C49 ya es casi directa: solo te falta arrastrar el texto de la ruta y hacerlo para todos los barrios a la vez.
```sql

```

- [ ] **C48** 🟡 Cuenta cuántos lugares "hijos" tiene cada lugar.
```sql
select p.nombre, COUNT(h.lugar_padre_id)
from lugar p
left join lugar h on p.id_lugar = h.lugar_padre_id 
group by p.nombre, p.id_lugar 
```

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
