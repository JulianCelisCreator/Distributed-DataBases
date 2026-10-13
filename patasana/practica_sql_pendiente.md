# Práctica SQL PataSana: lo que queda pendiente

> Basada en `practica_sql_patasana.md`, adaptada a **tu** `DDL.sql` y `DML.sql`.
> Motor: PostgreSQL · Leyenda: 🟢 básico · 🟡 intermedio · 🔴 avanzado · ⚠️ ajustado a tu modelo
>
> Los ejercicios conservan su número original para que puedas cruzarlos con la práctica.
> Los ✔ son resultados esperados **verificados con tus datos**.

---

## 0. Antes de empezar

### 0.1 Ya está hecho (no aparece abajo)

| Ejercicios | Qué |
|---|---|
| 3, 5, 7, 9, 10, 12, 29 | Estructura ya resuelta en `DDL.sql` |
| 31–40 | Datos iniciales cargados en `DML.sql` |

### 0.2 Equivalencia de nombres

La práctica usa otros nombres. Estos son los tuyos:

| Práctica | Tu modelo |
|---|---|
| `sedes.nombre` / `sedes.ciudad` | `sede.nombre_sede` / `sede.ciudad_id` → `lugar.nombre` |
| `cargos.es_veterinario` | `cargo.esta_habilitado` |
| `empleados` (`nombres`, `apellidos`, `email`, `activo`) | `personal` (`nombre`, `apellido`, `correo`, `is_active`) |
| `empleados.documento` / `clientes.documento` | `documento_id` → `documento.numero` |
| `clientes.telefono` | `telefono_id` → `telefono.numero` |
| `clientes.ciudad` | `ciudad_id` → `lugar.nombre` |
| `mascotas.peso_kg` | `mascota.peso_g` (**gramos**: 20 kg = 20000) |
| `mascotas.fecha_fallecimiento` | `mascota.fecha_muerte` |
| `servicios.categoria` / `duracion_min` | `categoria_id` → `categoria.nombre` / `duracion` |
| `citas.fecha_hora` / `id_veterinario` | `cita.fecha_cita` / `veterinario_id` |
| `medicamentos.precio_unitario` / `requiere_formula` / `presentacion` | `precio_unitario_actual` / `es_formulado` / `presentacion_id` → `presentacion.nombre` |
| `inventario.stock_minimo` | `inventario.minimo_stock` |
| `formulas` / `facturas` | `formula` / `factura` |
| `detalle_factura` | `linea_factura` |
| `pagos` (`fecha`, `metodo`, `monto`) | `abono` (`fecha_abono`, `metodo_pago_id` → `metodo_pago.metodo`, `valor`) |
| `movimientos_inventario` / `cierres_mensuales` | `movimiento_inventario` / `cierre_mensual` |
| FK `id_sede`, `id_cliente`... | FK `sede_id`, `cliente_id`... |

### 0.3 Cómo recargar

Cuando un ejercicio cambie datos y quieras repetirlo, usa `BEGIN; ... ROLLBACK;` o recarga todo:

```sql
DROP DATABASE patasana;   -- desde otra base, por ejemplo postgres
```
```bash
psql -U postgres -f DDL.sql
psql -U postgres -f DML.sql
```

---

## Parte 1. DDL: lo que falta de la estructura

### 1.1 Completar tablas existentes

- [ ] **1** 🟢 Agrega `ENCODING 'UTF8'` al `CREATE DATABASE`.
- [ ] **2** 🟢 Crea el esquema `clinica` y configura el `search_path`. ⚠️ Tus tablas están en `public`: decide si las mueves o si creas todo de nuevo dentro de `clinica`.
- [ ] **4** 🟢 Agrega a `raza` el `UNIQUE (especie_id, nombre)` y `NOT NULL` en ambas columnas. Explica por qué `UNIQUE (nombre)` sola no sirve (pista: "Criollo").
- [ ] **6** 🟢 `personal.is_active` con `DEFAULT TRUE`.
- [ ] **8** 🟢 `servicios`: precio `NUMERIC(12,2)` con `CHECK (precio >= 0)` (hoy es `DECIMAL(12,3)` con `> 0`) y la columna `activo BOOLEAN NOT NULL DEFAULT TRUE`.
- [ ] **11** 🟡 `medicamento.nombre` con `UNIQUE`. En `inventario`: cambia `id_inventario` + `UNIQUE` por `PRIMARY KEY (sede_id, medicamento_id)` (igual que hiciste con `formula`) y agrega `CHECK (stock >= 0)`.
- [ ] **13** 🟢 `factura.estado`: `NOT NULL DEFAULT 'pendiente'`. Opcional: pásalo a `ENUM` como hiciste con `estado_cita`.
- [ ] **14** 🟡 Responde: ¿por qué tiene sentido `ON DELETE CASCADE` en `linea_factura` y no en `abono`?
- [ ] **15** 🟢 Escribe explícito `ON DELETE RESTRICT` en `abono.factura_id`.
- [ ] **16** 🟡 Decide qué pasa con las mascotas si se borra a su dueño (`RESTRICT`, `CASCADE` o `SET NULL`), escríbelo en `mascota.cliente_id` y justifícalo. Pista: con `SET NULL`, ¿qué pasa con el `NOT NULL` que ya tiene?

### 1.2 Comandos ALTER (en un archivo aparte, por ejemplo `01b_alter.sql`)

- [ ] **17** 🟢 ⚠️ `observacion` ya existe en `mascota`. Practica `ALTER TABLE ... ADD COLUMN` agregando `color VARCHAR(30)`, y luego bórrala con `DROP COLUMN`.
- [ ] **18** 🟡 ⚠️ `sede.correo` ya existe y es opcional. Hazla obligatoria así: `SET DEFAULT` temporal → `UPDATE` con correos reales → `SET NOT NULL` → `DROP DEFAULT`.
- [ ] **19** 🟢 Renombra `cita.motivo` a `motivo_consulta` y devuélvela a su nombre original.
- [ ] **20** 🟡 ⚠️ Tu peso está en gramos (`NUMERIC(10,2)`). ¿Qué pasaría si cambias a `NUMERIC(5,1)`? Pista: Zeus pesa 34500 g. Pruébalo dentro de `BEGIN; ... ROLLBACK;`.
- [ ] **21** 🟡 Agrega a `cliente` la restricción `chk_email_formato`: el correo debe tener `@` y un punto después.
- [ ] **22** 🟢 Elimina esa restricción, verifícalo con `\d cliente` y vuelve a crearla.
- [ ] **23** 🔴 Crea el `DOMAIN dinero` (`NUMERIC(12,2)` con `CHECK (VALUE >= 0)`) y úsalo en `servicios.precio`, `medicamento.precio_unitario_actual` y `abono.valor`.

### 1.3 Índices, documentación y extras

- [ ] **24** 🟢 Índice sobre `cita(fecha_cita)`. ¿En qué consultas lo usaría el motor?
- [ ] **25** 🟡 Índice compuesto `cita(mascota_id, fecha_cita)`. ¿Sirve para buscar solo por `fecha_cita`? ¿Por qué importa el orden?
- [ ] **26** 🔴 Índice único **parcial**: un cliente no puede tener dos mascotas **vivas** con el mismo nombre (`WHERE fecha_muerte IS NULL`).
- [ ] **27** 🟢 `COMMENT ON TABLE cita` y `COMMENT ON COLUMN cita.estado`.
- [ ] **28** 🟢 Crea `tmp_pruebas`, insértale 3 filas, vacíala con `TRUNCATE` y bórrala con `DROP`. Explica la diferencia entre `DELETE`, `TRUNCATE` y `DROP`.
- [ ] **30** 🟡 Genera el diagrama entidad-relación (DBeaver o similar) y verifica cada cardinalidad.

### 1.4 Extra de diseño (no está en la práctica, pero lo pide el enunciado)

- [x] **E1** 🟡 RN-01 (hecho al convertir `region` en tipo de lugar): `sede` no tenía ciudad, solo región. Se agregó `ciudad_id REFERENCES lugar(id_lugar)`, como ya hiciste en `cliente` y se actualizaron las 4 sedes.
- [ ] **E2** 🟢 `cliente.telefono_id NOT NULL`: el teléfono del cliente es obligatorio (RN-04).
- [ ] **E3** 🟢 `cita.ultima_modificacion DEFAULT now()`, para no escribirlo en cada `INSERT`.
- [ ] **E4** 🟢 `categoria.nombre NOT NULL UNIQUE`.

---

## Parte 2. DML (41–60)

- [ ] **41** 🟢 Intenta insertar una mascota con peso `-2000` g. ¿Qué restricción lo impide? Copia el mensaje.
- [ ] **42** 🟢 Intenta agendar otra cita con Natalia Ríos (id 3) el `2025-01-15 09:00`. ¿Qué restricción falla?
- [ ] **43** 🟢 ⚠️ Intenta registrar el documento `79456123` (ya es de Carlos Méndez). ¿Qué pasa? Pista: en tu modelo el documento va en la tabla `documento`.
- [ ] **44** 🟢 ⚠️ Inserta un cliente nuevo y obtén su `id_cliente` con `RETURNING`. Antes necesitas su fila en `documento` y en `telefono`, y recuerda que `correo` y `direccion` son obligatorios. Reto: hazlo con CTE encadenadas (`WITH d AS (INSERT ... RETURNING ...)`).
- [ ] **45** 🟡 Genera las facturas con `INSERT ... SELECT`: una por cada cita **atendida**, con `fecha_emision` igual a `fecha_cita`. ✔ 23 facturas.
- [ ] **46** 🟡 Genera la línea del **servicio** de cada factura en `linea_factura`: descripción = nombre del servicio, cantidad 1, valor = precio.
- [ ] **47** 🟡 Genera las líneas de los **medicamentos** desde `formula`: descripción = nombre del medicamento, cantidad = cantidad formulada, valor = `precio_unitario_actual`.
- [ ] **48** 🟡 ⚠️ Inserta los abonos de la tabla de abajo. Obtén `factura_id` a partir del número de cita y `metodo_pago_id` a partir del nombre del método, con subconsultas o `JOIN`.
- [ ] **49** 🟡 Con un `UPDATE` y subconsultas, marca como `pagada` cada factura cuyo total abonado sea mayor o igual a su total. ✔ 19 pagadas; quedan pendientes las de las citas 13, 17, 23 y 24.
- [ ] **50** 🟢 Anula la factura de la cita 17.
- [ ] **51** 🟡 ⚠️ Sube 8 % el precio de los servicios de la categoría `Prevención`, redondeando a la centena. Necesitas `UPDATE ... FROM categoria`.
- [ ] **52** 🟢 Marca como inactivo (`is_active = FALSE`) a Tomás Gil.
- [ ] **53** 🟡 ⚠️ Con `UPDATE ... FROM`, aumenta 5 % el salario del personal con cargo habilitado (`esta_habilitado`) de la sede Laureles.
- [ ] **54** 🟢 ⚠️ Cambia el correo de Julián Herrera a `julian.herrera@mail.com`. En tu modelo ya tiene uno (ficticio).
- [ ] **55** 🟡 Cambia a `no_asistio` las citas `programada` cuya fecha ya pasó. ¿Cuántas filas se afectan hoy y por qué? ✔ 0 (al 2026-10-10).
- [ ] **56** 🟡 Elimina el medicamento "Suero oral". Luego intenta eliminar "Amoxicilina 500mg": ¿qué ocurre y por qué?
- [ ] **57** 🟡 Elimina a Óscar Duarte, que no tiene mascotas. ⚠️ ¿Qué pasa con sus filas en `documento` y `telefono`? Luego intenta eliminar a Carlos Méndez y explica el resultado según tu decisión del ejercicio 16.
- [ ] **58** 🔴 *Upsert*: llega un pedido. La sede 2 recibe 100 Omeprazol, y la sede 3 recibe 50 Amoxicilina y 30 Omeprazol. Con un solo `INSERT ... ON CONFLICT (sede_id, medicamento_id) DO UPDATE`, suma el stock si existe o crea el registro si no (mínimo 30 para los nuevos).
- [ ] **59** 🟡 Descuenta del inventario de la sede 1 lo formulado en la cita 22 y devuelve el stock resultante con `RETURNING`.
- [ ] **60** 🟢 Crea `cita_2025` con `CREATE TABLE ... AS SELECT`, solo con las citas de 2025. ✔ 21 filas.

**Abonos para el ejercicio 48** (identificados por la cita de su factura):

| cita | fecha | método | monto |
|---|---|---|---|
| 1 | 2025-01-15 | tarjeta | 69500 |
| 2 | 2025-01-15 | efectivo | 75000 |
| 3 | 2025-02-03 | transferencia | 132600 |
| 5 | 2025-03-05 | tarjeta | 103000 |
| 6 | 2025-03-05 | efectivo | 150000 |
| 8 | 2025-04-02 | tarjeta | 250000 |
| 8 | 2025-04-30 | transferencia | 249000 |
| 9 | 2025-04-22 | tarjeta | 380000 |
| 10 | 2025-05-06 | efectivo | 65000 |
| 11 | 2025-05-06 | tarjeta | 87000 |
| 12 | 2025-06-10 | efectivo | 60000 |
| 13 | 2025-06-25 | tarjeta | 100000 |
| 14 | 2025-09-02 | efectivo | 35000 |
| 15 | 2025-07-14 | efectivo | 55000 |
| 16 | 2025-08-01 | transferencia | 136800 |
| 18 | 2025-09-20 | tarjeta | 75000 |
| 20 | 2025-11-03 | transferencia | 150000 |
| 21 | 2025-12-10 | efectivo | 65000 |
| 22 | 2026-01-12 | tarjeta | 87000 |
| 23 | 2026-02-16 | tarjeta | 300000 |
| 25 | 2026-04-20 | efectivo | 75000 |
| 27 | 2026-08-24 | transferencia | 65000 |

---

## Parte 3. DQL básico (61–75)

- [ ] **61** 🟢 Todas las columnas de todas las mascotas.
- [ ] **62** 🟢 ⚠️ Nombre, apellido y teléfono de los clientes, ordenados por apellido (`JOIN telefono`).
- [ ] **63** 🟢 ⚠️ Clientes de Medellín (`JOIN lugar`).
- [ ] **64** 🟢 ⚠️ Mascotas de más de 20 kg (`peso_g > 20000`), de la más pesada a la más liviana. ✔ 5.
- [ ] **65** 🟢 Servicios con precio entre 50.000 y 200.000 (`BETWEEN`).
- [ ] **66** 🟢 ⚠️ Ciudades distintas donde viven los clientes.
- [ ] **67** 🟢 Las 5 citas más recientes.
- [ ] **68** 🟢 Citas en estado `programada`.
- [ ] **69** 🟢 ⚠️ Clientes sin correo. En tu modelo `correo` es obligatorio: ¿cuántas filas devuelve y por qué? ✔ 0.
- [ ] **70** 🟢 Mascotas cuyo nombre empieza por "M" o termina en "a".
- [ ] **71** 🟢 Personal sin jefe.
- [ ] **72** 🟢 Medicamentos que requieren fórmula (`es_formulado`), de mayor a menor precio.
- [ ] **73** 🟢 Mascotas vivas (`fecha_muerte IS NULL`) nacidas antes de 2020.
- [ ] **74** 🟢 Citas atendidas en la sede 2 durante 2025.
- [ ] **75** 🟢 Segunda página de clientes, de 5 en 5, ordenados por id (`LIMIT` / `OFFSET`).

---

## Parte 4. Funciones y expresiones (76–88)

- [ ] **76** 🟢 Nombre completo de cada cliente en una columna y en mayúsculas.
- [ ] **77** 🟡 Edad de cada mascota con `AGE`. Si no tiene fecha de nacimiento, "Desconocida" (`COALESCE`).
- [ ] **78** 🟡 Antigüedad de cada empleado en años y meses.
- [ ] **79** 🟢 ⚠️ Clasifica las mascotas con `CASE`: Pequeño (< 10000 g), Mediano (< 25000 g) o Grande.
- [ ] **80** 🟢 Clasifica los servicios por duración: Rápido (≤ 15 min), Normal (≤ 60 min) o Largo.
- [ ] **81** 🟡 Día de la semana de cada cita. ¿Cuáles cayeron en sábado o domingo?
- [ ] **82** 🟢 Citas agendadas antes del mediodía.
- [ ] **83** 🟡 Precio de los servicios con separador de miles y `$` usando `to_char`.
- [ ] **84** 🟡 Dominio del correo de cada cliente (lo que va después de la `@`) con `split_part`.
- [ ] **85** 🟢 Iniciales de cada empleado (por ejemplo, "M.O.").
- [ ] **86** 🟢 Valor del inventario por fila (`stock * precio_unitario_actual`).
- [ ] **87** 🟡 Días que faltan para cada cita programada.
- [ ] **88** 🟡 Mascotas que cumplen años en el mes actual.

---

## Parte 5. Agregación (89–102)

- [ ] **89** 🟢 Total de mascotas. ✔ 20
- [ ] **90** 🟢 Mascotas por especie (`mascota → raza → especie`). ✔ Perro 10, Gato 7, Ave 2, Conejo 1
- [ ] **91** 🟢 Citas por estado. ✔ atendida 23, programada 3, cancelada 2, no_asistio 2
- [ ] **92** 🟢 Precio promedio, mínimo y máximo de los servicios.
- [ ] **93** 🟢 Citas por sede y por año.
- [ ] **94** 🟡 ⚠️ Ciudades con más de 4 clientes (`HAVING`, `JOIN lugar`).
- [ ] **95** 🟡 Total de cada factura (suma de `linea_factura.subtotal`). ✔ La de la cita 8 suma 499.000.
- [ ] **96** 🟢 ⚠️ Total recaudado por método de pago (`abono → metodo_pago`).
- [ ] **97** 🟡 Citas atendidas por cada veterinario (por id).
- [ ] **98** 🟡 Peso promedio por especie, solo para especies con al menos 2 mascotas.
- [ ] **99** 🟡 Ingreso recaudado por mes durante 2025, según `fecha_abono`.
- [ ] **100** 🟡 Medicamentos más formulados, por cantidad total.
- [ ] **101** 🔴 Una fila por sede con citas atendidas, canceladas y no asistidas en columnas separadas (`COUNT(*) FILTER (WHERE ...)`).
- [ ] **102** 🟢 Nómina total y salario promedio por sede.

---

## Parte 6. JOINs (103–120)

- [ ] **103** 🟢 Mascotas con su raza y su especie.
- [ ] **104** 🟢 Mascotas con el nombre completo de su dueño.
- [ ] **105** 🟢 Citas con el nombre de la mascota, el veterinario, el servicio y la sede.
- [ ] **106** 🟢 Personal con su cargo y su sede.
- [ ] **107** 🟡 Personal con el nombre de su jefe (*self join*). La directora debe aparecer con jefe vacío.
- [ ] **108** 🟡 Todos los clientes con su número de mascotas, incluidos los que tienen 0.
- [ ] **109** 🟡 Sedes sin citas. ✔ PataSana Usaquén
- [ ] **110** 🟡 Servicios nunca solicitados. ✔ Hospitalización (día)
- [ ] **111** 🟡 Medicamentos nunca formulados.
- [ ] **112** 🟡 Especies sin mascotas. ✔ Reptil
- [ ] **113** 🟡 Historia clínica de Luna: cada cita con fecha, servicio, veterinario y medicamentos formulados (si los hay).
- [ ] **114** 🟡 Cada factura con el cliente, su total, lo abonado y el saldo.
- [ ] **115** 🟡 Clientes con saldo pendiente mayor que 0 (sin contar facturas anuladas).
- [ ] **116** 🟡 Medicamentos por debajo del mínimo, con el nombre de la sede y del medicamento.
- [ ] **117** 🟡 Ingreso recaudado por sede (`abono → factura → cita → sede`).
- [ ] **118** 🟡 ⚠️ Ingreso facturado por categoría de servicio (`linea_factura → factura → cita → servicios → categoria`).
- [ ] **119** 🔴 Para cada veterinario, cuántas especies distintas ha atendido.
- [ ] **120** 🔴 Con `CROSS JOIN`, la matriz sede × servicio con su número de citas, incluidas las combinaciones en 0.

---

## Parte 7. Subconsultas (121–130)

- [ ] **121** 🟢 Servicios con precio mayor que el promedio (subconsulta escalar).
- [ ] **122** 🟡 Mascotas del cliente que tiene más mascotas.
- [ ] **123** 🟡 Clientes con al menos un gato (con `IN` y luego con `EXISTS`).
- [ ] **124** 🟡 Mascotas que nunca han tenido cita (`NOT EXISTS`).
- [ ] **125** 🟡 La cita más reciente de cada mascota (subconsulta correlacionada).
- [ ] **126** 🟡 Personal que gana más que el promedio de su sede.
- [ ] **127** 🟡 La mascota más pesada de cada especie.
- [ ] **128** 🟡 Facturas cuyo total supera el promedio de todas (tabla derivada en el `FROM`).
- [ ] **129** 🔴 Medicamentos más caros que **todos** los que no requieren fórmula (`> ALL`).
- [ ] **130** 🟡 Cada cliente con su número total de citas, con una subconsulta en el `SELECT`.

---

## Parte 8. Operaciones de conjuntos (131–135)

- [ ] **131** 🟢 ⚠️ `UNION`: ciudades donde hay sedes o clientes. Sedes por `sede.ciudad_id`, clientes por `cliente.ciudad_id`.
- [ ] **132** 🟢 ⚠️ `INTERSECT`: ciudades que tienen sede y también clientes.
- [ ] **133** 🟡 `EXCEPT`: medicamentos del catálogo que no están en el inventario de ninguna sede.
- [ ] **134** 🟡 ⚠️ `UNION ALL`: directorio de personas (personal y clientes) con nombre, teléfono o correo y una columna `tipo`.
- [ ] **135** 🟡 `EXCEPT`: mascotas atendidas en 2025 que no han vuelto en 2026.

---

## Parte 9. CTE (136–145)

- [ ] **136** 🟡 Con una CTE, total de cada factura y luego las que tienen saldo.
- [ ] **137** 🟡 Con CTE encadenadas, gasto total por cliente y clasificación Oro (> 500.000), Plata (> 150.000) o Bronce.
- [ ] **138** 🟡 Con una CTE, el mes con mayor ingreso recaudado.
- [ ] **139** 🔴 CTE **recursiva**: organigrama desde la directora, con nivel y ruta (`Ortiz > Cárdenas > Ríos`).
- [ ] **140** 🔴 CTE recursiva: todos los subordinados, directos e indirectos, de Felipe Cárdenas.
- [ ] **141** 🔴 CTE recursiva: todos los días de octubre de 2026 con su número de citas, incluidos los días en 0.
- [ ] **142** 🟡 La primera cita de cada mascota, con el servicio que recibió.
- [ ] **143** 🟡 Clientes cuya última visita atendida fue hace más de 6 meses.
- [ ] **144** 🔴 ⚠️ CTE que modifica datos (`WITH ... UPDATE ... RETURNING`): descuenta el inventario de una fórmula y, en la misma sentencia, inserta en `movimiento_inventario` (ya existe en tu DDL).
- [ ] **145** 🔴 CTE recursiva: las próximas 4 fechas de vacuna antirrábica de Rex, cada 12 meses desde su última vacunación.

---

## Parte 10. Funciones de ventana (146–155)

- [ ] **146** 🟡 Numera las citas de cada mascota en orden cronológico (`ROW_NUMBER`).
- [ ] **147** 🟡 Ranking de veterinarios por citas atendidas dentro de su sede (`RANK`).
- [ ] **148** 🟡 Ingreso acumulado día a día (*running total*).
- [ ] **149** 🟡 Días entre citas consecutivas de cada mascota (`LAG`).
- [ ] **150** 🟡 Junto a cada cita, la siguiente de la misma mascota (`LEAD`).
- [ ] **151** 🟡 Cada empleado con el salario promedio de su cargo y la diferencia con el suyo (`AVG() OVER`).
- [ ] **152** 🔴 Los 2 servicios más solicitados en cada sede.
- [ ] **153** 🟡 Divide a los clientes en 3 grupos según su gasto (`NTILE`).
- [ ] **154** 🟡 En cada cita, el primer servicio que recibió esa mascota (`FIRST_VALUE`).
- [ ] **155** 🔴 Porcentaje que aporta cada sede al ingreso total (`SUM() OVER ()`).

---

## Parte 11. Vistas (156–163)

- [ ] **156** 🟢 `v_agenda`: citas programadas con mascota, dueño, teléfono, veterinario y sede.
- [ ] **157** 🟡 `v_historia_clinica`: mascota, fecha, servicio, veterinario, motivo y medicamentos formulados.
- [ ] **158** 🟡 `v_estado_cuenta`: factura, cliente, total, abonado, saldo y estado.
- [ ] **159** 🟢 Consulta `v_estado_cuenta` para los clientes con saldo pendiente, ordenados por saldo.
- [ ] **160** 🔴 ⚠️ Vista actualizable `v_servicios_activos` `WITH CHECK OPTION`. Requiere la columna `activo` del ejercicio 8. Prueba un `UPDATE` válido y un `INSERT` que viole la condición.
- [ ] **161** 🟡 Vista materializada `mv_ingresos_mensuales` (ingreso por sede y mes). Inserta un abono, observa que la vista no cambia y luego haz `REFRESH`.
- [ ] **162** 🔴 Haz que `mv_ingresos_mensuales` se pueda refrescar con `REFRESH ... CONCURRENTLY`. ¿Qué índice necesita y por qué?
- [ ] **163** 🟡 Agrega una columna a `v_agenda` con `CREATE OR REPLACE VIEW`. ¿Qué cambios no permite? Elimina una vista con dependencias usando `DROP VIEW ... CASCADE`.

---

## Parte 12. DCL: control de acceso (164–171)

- [ ] **164** 🟢 Roles de grupo `rol_admin`, `rol_veterinario` y `rol_recepcion` (sin login).
- [ ] **165** 🟢 Usuarios `natalia` (veterinaria), `jorge` (recepción) y `mariana` (administradora), con contraseña y miembros de su rol.
- [ ] **166** 🟡 ⚠️ Recepción: consultar, insertar y actualizar `cliente`, `mascota` y `cita` (y lo que necesiten: `documento`, `telefono`), y solo consultar `servicios`.
- [ ] **167** 🟡 Veterinarios: consultar `mascota` y `cita`, insertar en `formula` y actualizar **solo** la columna `estado` de `cita`.
- [ ] **168** 🟡 Recepción no debe ver `personal.salario`. Resuélvelo con privilegios por columna y con una vista sin esa columna.
- [ ] **169** 🟡 Quita a recepción el `DELETE` (`REVOKE`) y compruébalo con `SET ROLE jorge`.
- [ ] **170** 🔴 Con `ALTER DEFAULT PRIVILEGES`, las tablas futuras dan `SELECT` a `rol_admin` automáticamente.
- [ ] **171** 🔴 *Row Level Security*: cada veterinario ve solo **sus** citas. Agrega `personal.usuario_bd`, crea la política y pruébala con `SET ROLE natalia`.

---

## Parte 13. TCL: transacciones (172–179)

- [ ] **172** 🟡 En una transacción: cita atendida, su factura, sus líneas y su abono, con `COMMIT`.
- [ ] **173** 🟡 Lo mismo, con un abono de monto negativo. Verifica que tras el error y el `ROLLBACK` no quedó nada.
- [ ] **174** 🔴 Formula tres medicamentos con un `SAVEPOINT` antes de cada uno. Si uno no tiene stock, `ROLLBACK TO SAVEPOINT` y sigue con los demás.
- [ ] **175** 🔴 Dos terminales: ambas actualizan el stock del mismo medicamento en una transacción. ¿Qué pasa con la segunda? ¿Qué valor queda?
- [ ] **176** 🔴 Diferencia entre `READ COMMITTED` y `REPEATABLE READ` con una lectura no repetible.
- [ ] **177** 🔴 `SELECT ... FOR UPDATE` para que dos recepcionistas no agenden a la vez el último horario libre de un veterinario.
- [ ] **178** 🔴 Provoca un *deadlock* con dos sesiones que actualizan dos filas en orden inverso. Explica cómo se evita.
- [ ] **179** 🟡 En `psql`, `\set AUTOCOMMIT off`, haz un `DELETE` y explica el riesgo de olvidar `COMMIT` o `ROLLBACK`.

---

## Parte 14. Funciones, procedimientos y triggers (180–200)

- [ ] **180** 🟢 `fn_edad_mascota(id_mascota)`: edad en años (`NULL` si no se conoce).
- [ ] **181** 🟢 `fn_total_factura(id_factura)`.
- [ ] **182** 🟡 `fn_saldo_cliente(id_cliente)`, sin contar facturas anuladas.
- [ ] **183** 🟡 `fn_historia_clinica(id_mascota)` que retorne una tabla: fecha, servicio, veterinario y medicamentos.
- [ ] **184** 🟡 `fn_citas_por_rango(desde, hasta)` con `hasta` por defecto igual a la fecha actual.
- [ ] **185** 🟡 ⚠️ `sp_registrar_cliente_mascota(...)`: inserta documento, teléfono, cliente y su primera mascota.
- [ ] **186** 🔴 `sp_agendar_cita(mascota, veterinario, servicio, fecha_cita, motivo)`: valida con `RAISE EXCEPTION` que el empleado tiene cargo habilitado y está activo, que la mascota está viva y que el veterinario no está ocupado. La sede es la del veterinario.
- [ ] **187** 🔴 `sp_atender_cita(id_cita, medicamentos INT[], cantidades INT[])`: marca la cita como atendida, inserta las fórmulas, descuenta el inventario de la sede y crea la factura con sus líneas.
- [ ] **188** 🔴 ⚠️ `sp_registrar_abono(id_factura, monto, metodo)`: rechaza facturas anuladas y montos mayores que el saldo; si completa el total, pasa la factura a `pagada`. `metodo` llega como texto: búscalo en `metodo_pago`.
- [ ] **189** 🔴 `sp_cancelar_citas_mascota(id_mascota)` que cancele sus citas programadas con `COMMIT` dentro. ¿Por qué se puede en un `PROCEDURE` y no en una `FUNCTION`?
- [ ] **190** 🟡 ⚠️ `sp_ajustar_precios(categoria, porcentaje)` con un parámetro `INOUT` que devuelva cuántos servicios se actualizaron. La categoría llega por nombre: búscala en `categoria`.
- [ ] **191** 🟡 Función con `FOR ... LOOP` que recorra el inventario bajo el mínimo y haga `RAISE NOTICE` con la cantidad sugerida (el doble del mínimo menos el stock).
- [ ] **192** 🔴 Trigger: no se pueden agendar citas para mascotas fallecidas (RN-09).
- [ ] **193** 🔴 Trigger: no se puede asignar una cita a un empleado cuyo cargo no está habilitado (RN-03).
- [ ] **194** 🔴 Trigger de auditoría (RN-16): crea `auditoria_precios` y registra precio anterior, nuevo, `current_user` y fecha cada vez que cambie el precio de un servicio. Pruébalo con el ejercicio 51.
- [ ] **195** 🔴 Trigger: al insertar un abono, la factura pasa a `pagada` si ya se cubrió el total.
- [ ] **196** 🔴 Trigger: al insertar una fórmula, descuenta el stock de la sede de la cita y lanza error si no alcanza (RN-12).
- [ ] **197** 🟡 ⚠️ Ya tienes `cita.ultima_modificacion`: crea un trigger `BEFORE UPDATE` que la mantenga actualizada.
- [ ] **198** 🟡 Trigger: no se reciben abonos de facturas anuladas (RN-15).
- [ ] **199** 🔴 En `sp_agendar_cita`, captura `unique_violation` con un bloque `EXCEPTION` y devuelve: *"El veterinario ya tiene una cita a esa hora"*.
- [ ] **200** 🔴 ⚠️ **Proyecto final.** `sp_cierre_mensual(anio, mes)`: para el mes indicado, guarda en `cierre_mensual` por sede el ingreso recaudado, las citas atendidas, las no asistidas y el saldo pendiente. Recuerda que tu `periodo` es un `DATE` del día 1 (`make_date(anio, mes, 1)`). Al terminar, refresca `mv_ingresos_mensuales`. Ejecútalo para agosto de 2026 y valida contra tus consultas de las partes 5 y 6.
