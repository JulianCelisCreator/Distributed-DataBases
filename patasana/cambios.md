# PataSana: cambios pendientes en el DDL

> Fuera de alcance por ahora: auditoría (historial de precios, movimientos de inventario) y vistas (agenda, estado de cuenta, ingresos precalculados, etc.).
>
> Los números de línea corresponden a la versión revisada de `DDL.sql`; pueden moverse a medida que edites.

## 1. Estado de los cambios

| Cambio | Estado |
|---|---|
| Quitar `marca` y `medicamento_factura` | ✅ Hecho |
| `mascota_id` en `cita`; quitar `estado_id` y `factura_id` | ✅ Hecho |
| `sede_id` en `personal` | ✅ Hecho |
| Orden de creación (`lugar` → `telefono`, `cita` → `formula`) | ✅ Hecho |
| Comas y `;` en todas las tablas anteriores | ✅ Corregido |
| `telefono`: `CHECK (numero ~ '^[0-9]+$')` | ✅ Corregido |
| `formula`: `UNIQUE (cita_id, medicamento_id)` | ✅ Corregido |
| `factura.cita_id NOT NULL UNIQUE` | ✅ Hecho |
| `metodo_pago.metodo NOT NULL UNIQUE` | ✅ Hecho |
| `abono`: FK `NOT NULL` y método de pago | ✅ Hecho |
| `cierre_mensual`: coma, `;`, columnas del enunciado, `periodo NOT NULL` con día 1 | ✅ Hecho |
| `linea_factura.factura_id NOT NULL` | 🛑 Agregado en una posición que rompe la sintaxis (ver 2.1) |
| `cierre_mensual`: `CHECK` con nombre de columna mal escrito | 🛑 Pendiente (ver 3.1) |
| `cierre_mensual`: quitar `factura_id` | ❌ Sigue ahí (ver 3.2) |
| `cierre_mensual`: `sede_id NOT NULL` y nombre `uq_` | ⚠️ Pendiente (ver 3.3) |
| `cargo.nombre_cargo NOT NULL UNIQUE` | ⚠️ Pendiente (ver 2.2) |

---

## 2. Fuera de `cierre_mensual`

### 2.1 🛑 `linea_factura` (línea 239): `NOT NULL` partió el `REFERENCES`

```sql
factura_id INTEGER REFERENCES factura(id_factura) NOT NULL ON DELETE CASCADE
```

`ON DELETE CASCADE` **no es una restricción independiente**: es parte de la cláusula `REFERENCES` y tiene que ir **pegada** a ella. Al meter `NOT NULL` en medio, PostgreSQL termina el `REFERENCES`, lee `NOT NULL` y luego encuentra un `ON DELETE` suelto que no pertenece a nada, así que da error de sintaxis.

```sql
factura_id INTEGER NOT NULL REFERENCES factura(id_factura) ON DELETE CASCADE
```

**Regla práctica:** escribe el `NOT NULL` antes del `REFERENCES`. Así nunca separas la FK de sus opciones (`ON DELETE`, `ON UPDATE`).

### 2.2 `cargo.nombre_cargo` (línea 49)

Sigue aceptando `NULL` y repetidos. Debe ser `NOT NULL UNIQUE`: un cargo sin nombre no tiene sentido, y dos cargos "veterinario" generarían confusión al revisar quién puede atender.

---

## 3. Revisión de `cierre_mensual` (líneas 256–267)

Mejoró mucho: ya tiene las cuatro columnas del enunciado, todas con `NOT NULL` y `CHECK (>= 0)`, y `periodo` obliga a que sea el día 1.

### 3.1 🛑 Línea 261: el `CHECK` usa un nombre que no existe

```sql
citas_no_asistidas INTEGER NOT NULL CHECK (citas_no_atendidas >= 0),
```

La columna se llama `citas_no_asistidas`, pero el `CHECK` dice `citas_no_atendidas` (**asistidas** ≠ **atendidas**). PostgreSQL responde *column "citas_no_atendidas" does not exist*.

**Truco para evitarlo:** cuando el `CHECK` está en la misma línea que la columna, copia y pega el nombre en vez de reescribirlo.

(`PERIODO` en mayúsculas en la línea 258 **sí funciona**: PostgreSQL convierte a minúsculas los nombres sin comillas. Pero por consistencia conviene escribirlo igual que la columna.)

### 3.2 ❌ Línea 265: `factura_id` sigue sobrando

Quitaste `cita_id`, pero `factura_id` tiene el mismo problema: una FK apunta a **una sola** factura, y un cierre resume **todas** las facturas de la sede en el mes.

Piénsalo así: ¿qué factura pondrías en el cierre de septiembre de Laureles, si ese mes hubo 200? No hay una respuesta correcta, y esa es la señal de que la columna no pertenece a la tabla. Lo que el cierre necesita de las facturas (el saldo pendiente) **ya está guardado como número** en `saldo_pendiente`.

La única FK que tiene sentido es `sede_id`, porque cada cierre sí es de **una** sede.

### 3.3 ⚠️ Detalles

| Línea | Qué | Por qué |
|---|---|---|
| 264 | `sede_id` sin `NOT NULL` | Un cierre sin sede no tiene sentido. Además, un `UNIQUE` **no detecta duplicados con `NULL`**: podrías insertar muchos cierres del mismo mes con `sede_id = NULL`. |
| 266 | Nombre `chk_mes_periodo` | `chk_` se usa por convención para `CHECK`. Para `UNIQUE` usa `uq_`, por ejemplo `uq_cierre_sede_periodo`. No da error, pero confunde a quien lee. |
| — | `fecha_cierre` (opcional) | `TIMESTAMPTZ NOT NULL DEFAULT now()`, para saber cuándo se hizo el cierre. |

---

### 3.4 Cómo debería quedar

```sql
CREATE TABLE cierre_mensual (
    id_cierre_mensual  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    periodo            DATE          NOT NULL CHECK (EXTRACT(DAY FROM periodo) = 1),
    ingreso_recaudado  DECIMAL(14,2) NOT NULL CHECK (ingreso_recaudado >= 0),
    citas_atendidas    INTEGER       NOT NULL CHECK (citas_atendidas >= 0),
    citas_no_asistidas INTEGER       NOT NULL CHECK (citas_no_asistidas >= 0),
    saldo_pendiente    DECIMAL(14,2) NOT NULL CHECK (saldo_pendiente >= 0),
    fecha_cierre       TIMESTAMPTZ   NOT NULL DEFAULT now(),

    -- FK
    sede_id INTEGER NOT NULL REFERENCES sede(id_sede),
    CONSTRAINT uq_cierre_sede_periodo UNIQUE (sede_id, periodo)
);
```

### 3.5 ¿Y quién llena la tabla?

El enunciado dice que *"al final de cada mes se hace un cierre"*. Eso es un **procedimiento** que calcula los cuatro valores con `SUM` y `COUNT` sobre `abono`, `cita`, `factura` y `linea_factura` para cada sede, e inserta una fila por sede. Lo dejamos para la parte de procedimientos (sección 6): por ahora solo importa que la tabla tenga dónde guardarlos.

---

## 4. Por qué `formula` y `linea_factura` son tablas distintas

- La **fórmula** es un acto clínico: pertenece a la **cita**, forma parte de la historia clínica y existe aunque la factura se anule.
- La **línea de factura** es un cobro: pertenece a la **factura**.

### 4.1 Para qué sirve `linea_factura`

Una factura cobra **una cantidad variable de cosas**: siempre una por el servicio y, además, una por cada medicamento formulado.

```text
FACTURA #15   fecha: 2026-10-10   estado: pendiente
┌──────────────────────────────┬──────────┬────────────────┬──────────┐
│ descripción                  │ cantidad │ valor unitario │ subtotal │
├──────────────────────────────┼──────────┼────────────────┼──────────┤
│ Consulta general             │    1     │     60.000     │  60.000  │
│ Amoxicilina tableta          │   10     │      1.500     │  15.000  │
│ Meloxicam frasco             │    1     │     32.000     │  32.000  │
├──────────────────────────────┴──────────┴────────────────┼──────────┤
│                                                    TOTAL │ 107.000  │
└──────────────────────────────────────────────────────────┴──────────┘
```

La parte de arriba (número, fecha, estado) aparece **una sola vez** y va en `factura`. Cada fila del medio es una **línea**. Una fila de `factura` no puede tener un número variable de columnas, así que las líneas van en otra tabla con FK a `factura` (relación **1:N**). Es el mismo patrón de *encabezado + detalle* de un pedido o un carrito de compras.

### 4.2 Por qué copia el precio en vez de leerlo de `medicamento` o `servicios`

Porque **los precios cambian**. Si la línea leyera el precio actual, al subir el de la amoxicilina **cambiaría el total de facturas viejas que ya se cobraron**. La línea guarda el precio vigente en el momento de facturar (*"al precio vigente"*, dice el enunciado).

### 4.3 Puntos clave de su diseño

- **`ON DELETE CASCADE`**: *"si se elimina una factura sus líneas no tienen razón de existir"*. ✅ Ya lo tienes.
- **`subtotal` como columna generada**: PostgreSQL lo calcula solo y nunca queda inconsistente. ✅ Ya lo tienes.
- **El total de la factura no se guarda**: se calcula con `SUM(subtotal)`.

### 4.4 Opcional: saber de dónde salió cada línea

Si quieres unir cada línea con su servicio o medicamento, por ejemplo para *"lo facturado por categoría de servicio"*:

```sql
    servicio_id    INTEGER REFERENCES servicios(id_servicio),
    medicamento_id INTEGER REFERENCES medicamento(id_medicamento),
    CONSTRAINT chk_linea_origen CHECK (
        (servicio_id IS NOT NULL AND medicamento_id IS NULL) OR
        (servicio_id IS NULL     AND medicamento_id IS NOT NULL)
    )
```

El `CHECK` obliga a que cada línea sea **o** de un servicio **o** de un medicamento. No es obligatorio: también puedes sacarlo con `factura → cita → servicio`.

---

## 5. Restricciones del enunciado que aún no están en el DDL

No son errores de sintaxis ni entidades faltantes, pero el enunciado las pide. Te las dejo para cuando revises atributos:

| Tabla | Falta | Enunciado |
|---|---|---|
| `medicamento` | `UNIQUE` en `nombre` | *"un nombre que no se repite"* |
| `servicios` | `CHECK (precio >= 0)` en vez de `> 0` | *"un precio [...] que nunca es negativo"* |
| `servicios` | columna `vigente BOOLEAN` | *"puede estar vigente o haberse dejado de ofrecer"* |
| `inventario` | `CHECK (stock >= 0)` | *"existencia actual, que nunca puede ser negativa"* |
| `personal` | `CHECK (salario > 0)` | *"su salario, que siempre es mayor que cero"* |
| `raza` | `UNIQUE (especie_id, nombre)` | *"el nombre de una raza no se repite dentro de su especie"* |

---

## 6. Para después (triggers o procedimientos)

Un `CHECK` no puede consultar otras tablas, así que estas reglas no se resuelven en el `CREATE TABLE`:

- Solo se puede formular en una cita **atendida**.
- Al formular se **descuenta del inventario** de la sede de la cita, y se rechaza si no hay existencias.
- Un abono no puede superar lo que falta por pagar, y la factura pasa a **pagada** cuando se completa.
- Solo un empleado con cargo habilitado y activo puede tener citas.
- El **cierre mensual**: un procedimiento que calcula e inserta una fila por sede (ver 3.5).

---

## 7. Revisión frente a `practica_sql_patasana.md`

> Probado en un PostgreSQL 18 temporal: `DDL.sql` corre sin errores (26 tablas) y luego se ejecutó `DML.sql`.

### 7.1 🛑 Por qué `DML.sql` falla hoy

Los datos de la práctica **no traen dirección** de empleados ni de clientes, y **algunas personas no tienen correo**. Tu DDL obliga a tener esos datos:

| Línea | Columna | Problema con los datos | Qué dice la regla |
|---|---|---|---|
| 71 | `personal.direccion NOT NULL` | Ningún empleado tiene dirección | La RN-02 no pide dirección |
| 75 | `personal.correo NOT NULL` | Sebastián Mora no tiene correo | RN-02: *"el email es opcional, pero si existe es único"* |
| 89 | `cliente.correo UNIQUE NOT NULL` | Julián Herrera y Diego Salazar no tienen correo | RN-04: *"email opcional (único si existe)"* |
| 91 | `cliente.direccion NOT NULL` | Ningún cliente tiene dirección | La RN-04 no pide dirección |

Como el `INSERT` de `personal` falla, todo lo que depende de los empleados falla en cadena: `cita` necesita al veterinario y `formula` necesita la cita. Lo mismo pasa con `cliente` → `mascota`. **Un solo `NOT NULL` mal puesto tumba medio script.**

**Corrección:** quitar `NOT NULL` de esas 4 columnas. Además, a `personal.correo` le falta `UNIQUE`: *"si existe es único"* es justo lo que hace `UNIQUE` sin `NOT NULL`, porque `UNIQUE` permite varios `NULL`.

Con esos 4 cambios el DML entra completo y los conteos coinciden con los ✔ de la práctica:

| Verificación | Esperado | Obtenido |
|---|---|---|
| Ej. 89: total de mascotas | 20 | 20 ✅ |
| Ej. 90: mascotas por especie | Perro 10, Gato 7, Ave 2, Conejo 1 | igual ✅ |
| Ej. 91: citas por estado | atendida 23, programada 3, cancelada 2, no_asistio 2 | igual ✅ |
| Ej. 60: citas de 2025 | 21 | 21 ✅ |

### 7.2 Cómo se adaptaron los datos a tu DDL

| Dato de la práctica | Cómo quedó en tu modelo |
|---|---|
| Ciudad de la sede | `sede.ciudad_id` → `lugar` (Bogotá D.C., Medellín, Cali) |
| Teléfono, documento | Filas en `telefono` y `documento`, enlazadas por id |
| Tipo de documento | No viene en la práctica: `tipo_id` queda `NULL` |
| Peso en kg | Convertido a gramos (`peso_g`): 0.04 kg → 40 g |
| Estado `no_asistio` | Escrito `'no asistió'`, como exige tu `CHECK` |
| `ultima_modificacion` | No tiene `DEFAULT` y es `NOT NULL`: se insertó `now()` |
| Facturas, detalle y pagos | **No** van en el DML: la práctica los hace generar en los ejercicios 45–48 |

### 7.3 Ejercicios que deben fallar (41–43)

La práctica dice: *"Los ejercicios 41–43 [...] **deben fallar**"*.

| Ejercicio | Prueba | Resultado |
|---|---|---|
| 41 | Mascota con peso negativo | ✅ Falla por `chk_mascotas_peso` |
| 42 | Otra cita con Natalia Ríos el 2025-01-15 09:00 | ❌ **Se insertó.** Falta `UNIQUE (veterinario_id, fecha_cita)` en `cita` (RN-08) |
| 43 | Cliente con documento `79456123` repetido | ❌ **Se insertó.** Falta `UNIQUE` en `documento.numero` (RN-02, RN-04) |

El 42 es exactamente el primer problema del enunciado: *"dos mascotas quedaron agendadas con el mismo veterinario a la misma hora"*.

### 7.4 Reglas de negocio pendientes en el DDL

Pruebas hechas sobre la base cargada. ❌ = el DDL dejó pasar un dato inválido.

| RN | Falta | Prueba |
|---|---|---|
| RN-01 | ✅ Hecho: `sede.ciudad_id REFERENCES lugar` reemplazó a `region_id` | — |
| RN-02 / RN-04 | `UNIQUE` en `documento.numero` | ❌ ej. 43 |
| RN-02 | `CHECK (salario > 0)`, `is_active DEFAULT TRUE`, `UNIQUE` en `personal.correo` | — |
| RN-04 | `cliente.telefono_id NOT NULL` (*"teléfono obligatorio"*) | — |
| RN-05 | `UNIQUE (especie_id, nombre)` en `raza`, `UNIQUE` en `especie.nombre` | ❌ se insertó otro "Labrador" para Perro |
| RN-06 | `CHECK (fecha_nacimiento <= CURRENT_DATE)` y `CHECK (fecha_muerte >= fecha_nacimiento)` | — |
| RN-07 | `CHECK (precio >= 0)` en vez de `> 0`; columna `activo BOOLEAN DEFAULT TRUE` en `servicios` | — |
| RN-08 | `UNIQUE (veterinario_id, fecha_cita)`; `estado DEFAULT 'programada'` y `NOT NULL` | ❌ ej. 42 |
| RN-10 | `UNIQUE` en `medicamento.nombre` | — |
| RN-11 | `CHECK (stock >= 0)` en `inventario` | ❌ se pudo poner `stock = -1` |
| RN-13 | `estado DEFAULT 'pendiente'` y `NOT NULL` en `factura` | — |
| — | `cita.ultima_modificacion DEFAULT now()`, para no tener que escribirlo en cada insert | — |

Estas **no** se resuelven en el DDL. Quedan para los triggers (sección 6, ejercicios 192–198):

- RN-09: se pudo agendar una cita para Toby, que falleció.
- RN-03: se pudo asignar una cita a Sebastián Mora, que es auxiliar.

### 7.5 Diferencia de nombres con la práctica

La práctica pide usar sus nombres (`sedes`, `empleados`, `citas.fecha_hora`, `id_sede`...). Decidiste mantener los tuyos, así que al resolver los ejercicios hay que traducir:

| Práctica | Tu DDL |
|---|---|
| `sedes` / `empleados` / `clientes` / `mascotas` / `citas` | `sede` / `personal` / `cliente` / `mascota` / `cita` |
| `formulas` / `facturas` / `detalle_factura` / `pagos` | `formula` / `factura` / `linea_factura` / `abono` |
| `cargos.es_veterinario` | `cargo.esta_habilitado` |
| `empleados.activo` | `personal.is_active` |
| `citas.fecha_hora` | `cita.fecha_cita` |
| `mascotas.peso_kg` | `mascota.peso_g` (en gramos) |
| `mascotas.fecha_fallecimiento` | `mascota.fecha_muerte` |
| `servicios.duracion_min` | `servicios.duracion` |
| `medicamentos.requiere_formula` | `medicamento.es_formulado` |
| `inventario.stock_minimo` | `inventario.minimo_stock` |
| `pagos.monto` / `pagos.metodo` | `abono.valor` / `abono.metodo_pago_id` → `metodo_pago` |
| FK `id_sede`, `id_cliente`... | FK `sede_id`, `cliente_id`... |

### 7.6 Última revisión

| Cambio | Estado |
|---|---|
| `UNIQUE` en `documento.numero` | ✅ El ej. 43 ya falla como debe |
| `CHECK (fecha_nacimiento <= CURRENT_DATE)` | ✅ Probado: rechaza fechas futuras |
| `ENUM estado_cita` con `DEFAULT 'programada'` (ej. 9) | ✅ `DML.sql` actualizado a `'no_asistio'` |
| `especie.nombre` (línea 101) | 🛑 Dice `NOT NUL`: el DDL se detiene ahí |
| `CHECK (salario >= 0)` (línea 73) | ⚠️ Debe ser `> 0`: hoy se acepta salario 0 |
| `UNIQUE (veterinario_id, fecha_cita)` (ej. 10) | ❌ El ej. 42 todavía se inserta |
| `direccion` / `correo` `NOT NULL` en `personal` y `cliente` | ❌ Siguen bloqueando el DML (ver 7.1) |
| `CHECK (fecha_muerte >= fecha_nacimiento)` | ❌ Pendiente |
| `factura.estado` | ⚠️ Puede ir a `ENUM` igual que `cita.estado`, con `DEFAULT 'pendiente'` |

### 7.7 Decisiones de diseño tuyas (para justificar en el informe)

| Decisión | Choca con | Cómo se resolvió en el DML |
|---|---|---|
| `direccion NOT NULL` en `personal` y `cliente` | La práctica no trae direcciones | Direcciones **ficticias** en la ciudad de cada persona |
| `correo NOT NULL` en `personal` y `cliente` | RN-02 y RN-04: el correo es opcional | Correos **ficticios** para Sebastián Mora, Julián Herrera y Diego Salazar |
| `motivo NOT NULL` en `cita` | Enunciado: la cita *"puede llevar un motivo"*; 10 citas de la práctica no lo tienen | Motivos **ficticios** acordes al servicio en las 10 citas sin motivo. Vas a cambiarlo a opcional |

Efectos en los ejercicios:
- **Ej. 69** (clientes sin email) devolverá 0 filas.
- **Ej. 54** (registrar el email de Julián Herrera) pasa a ser un cambio de correo, no un registro.

Ya resuelto en el DDL: `UNIQUE (veterinario_id, fecha_cita)` (ej. 10), `CHECK (salario > 0)`, `especie.nombre NOT NULL UNIQUE` y `CHECK (fecha_muerte >= fecha_nacimiento)`. Probado: rechaza una muerte anterior al nacimiento y acepta la misma fecha (cría nacida muerta).
