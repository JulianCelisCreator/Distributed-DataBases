# Práctica SQL: Red de Clínicas Veterinarias **PataSana**

> Motor: **PostgreSQL 16** · Nivel: de cero a procedimientos almacenados · 200 ejercicios
>
> Leyenda de dificultad: 🟢 básico · 🟡 intermedio · 🔴 avanzado

---

## 1. El problema

**PataSana** es una red de clínicas veterinarias con sedes en Bogotá, Medellín y Cali,
y una cuarta sede en Bogotá que acaba de abrir. Hoy todo se maneja en hojas de cálculo:
la recepción agenda las citas en un Excel compartido, los veterinarios anotan los
tratamientos en papel, el inventario de medicamentos se cuenta a mano cada mes y nadie
sabe con certeza qué clientes deben dinero.

En los últimos meses se presentaron estos problemas:

- Dos mascotas fueron agendadas con el mismo veterinario a la misma hora.
- Se agendó una cita de control para un perro que había fallecido semanas antes.
- La sede de Medellín se quedó sin Omeprazol sin que nadie lo notara.
- Una factura se cobró dos veces y otra nunca se cobró.
- Un auxiliar quedó registrado como "veterinario" de una cirugía.
- Gerencia no puede responder preguntas simples como *"¿cuánto facturó cada sede el mes
  pasado?"* o *"¿qué clientes no vuelven desde hace 6 meses?"*.

La directora general, **Mariana Ortiz**, te contrata para diseñar e implementar la base de
datos que resuelva esto.

---

## 2. Reglas de negocio

| Código | Regla |
|---|---|
| **RN-01** | Cada **sede** tiene un nombre único, ciudad, dirección, teléfono y fecha de apertura. |
| **RN-02** | Cada **empleado** pertenece a una sede y tiene un cargo. Puede tener un **jefe**, que también es empleado. El documento es único; el email es opcional, pero si existe es único. El salario debe ser mayor que 0. Un empleado puede estar activo o inactivo. |
| **RN-03** | Los **cargos** son un catálogo. Solo los cargos marcados como veterinarios pueden atender citas. |
| **RN-04** | Cada **cliente** (dueño) tiene documento único, teléfono obligatorio, email opcional (único si existe), ciudad y fecha de registro (por defecto, la fecha actual). |
| **RN-05** | Las **especies** son un catálogo (Perro, Gato, …). Cada **raza** pertenece a una especie, y el nombre de la raza es único *dentro* de su especie: existe "Criollo" para perros y para gatos. |
| **RN-06** | Cada **mascota** pertenece a un cliente y tiene una raza. Sexo `M` o `H`; peso mayor que 0. La fecha de nacimiento es opcional (mascotas rescatadas) y no puede ser futura. Si la mascota fallece, se registra la fecha de fallecimiento, que no puede ser anterior al nacimiento. |
| **RN-07** | Los **servicios** tienen nombre único, categoría, precio (≥ 0), duración en minutos (> 0) y pueden estar activos o no. |
| **RN-08** | Una **cita** relaciona una mascota, un veterinario, una sede y un servicio en una fecha y hora. Su estado es uno de: `programada` (por defecto), `atendida`, `cancelada`, `no_asistio`. Un veterinario **no puede** tener dos citas a la misma fecha y hora. |
| **RN-09** | No se pueden agendar citas para mascotas fallecidas. |
| **RN-10** | Los **medicamentos** tienen nombre único, presentación, precio unitario y un indicador de si requieren fórmula médica. |
| **RN-11** | El **inventario** registra, por sede y medicamento, el stock actual (≥ 0) y el stock mínimo. Cuando el stock queda por debajo del mínimo hay que hacer un pedido. |
| **RN-12** | En una cita **atendida**, el veterinario puede formular medicamentos (**fórmula**): cantidad (> 0) e indicaciones. Al formular, el medicamento se descuenta del inventario de la sede de la cita. |
| **RN-13** | Cada cita atendida genera **máximo una factura** con fecha de emisión y estado: `pendiente` (por defecto), `pagada`, `anulada`. |
| **RN-14** | La factura tiene un **detalle** de líneas (descripción, cantidad, valor unitario): el servicio prestado y cada medicamento formulado. El total de la factura es la suma de sus líneas. |
| **RN-15** | Una factura puede recibir **varios pagos** (abonos). Método: `efectivo`, `tarjeta`, `transferencia`. Monto mayor que 0. Cuando lo pagado cubre el total, la factura pasa a `pagada`. No se reciben pagos de facturas anuladas. |
| **RN-16** | Los cambios de precio de los servicios deben quedar **auditados**: precio anterior, precio nuevo, quién lo cambió y cuándo. |

---

## 3. Diccionario de datos mínimo

Para que los ejercicios sean comunes a todos, usa **estos nombres** de tablas y columnas.
Tú decides los tipos de dato, las llaves primarias y foráneas, las restricciones, los
valores por defecto y los índices. Ese es el ejercicio de DDL.

| Tabla | Columnas |
|---|---|
| `sedes` | id_sede, nombre, ciudad, direccion, telefono, fecha_apertura |
| `cargos` | id_cargo, nombre, es_veterinario |
| `empleados` | id_empleado, nombres, apellidos, documento, email, id_cargo, id_sede, id_jefe, fecha_ingreso, salario, activo |
| `clientes` | id_cliente, nombres, apellidos, documento, telefono, email, ciudad, fecha_registro |
| `especies` | id_especie, nombre |
| `razas` | id_raza, nombre, id_especie |
| `mascotas` | id_mascota, nombre, id_raza, sexo, fecha_nacimiento, peso_kg, id_cliente, fecha_fallecimiento |
| `servicios` | id_servicio, nombre, categoria, precio, duracion_min, activo |
| `citas` | id_cita, id_mascota, id_veterinario, id_sede, id_servicio, fecha_hora, estado, motivo |
| `medicamentos` | id_medicamento, nombre, presentacion, precio_unitario, requiere_formula |
| `inventario` | id_sede, id_medicamento, stock, stock_minimo |
| `formulas` | id_cita, id_medicamento, cantidad, indicaciones |
| `facturas` | id_factura, id_cita, fecha_emision, estado |
| `detalle_factura` | id_detalle, id_factura, descripcion, cantidad, valor_unitario |
| `pagos` | id_pago, id_factura, fecha, metodo, monto |

> Los valores monetarios están en **pesos colombianos (COP)**, sin decimales en la práctica.

---

## 4. Datos iniciales

Los usarás en la parte de DML. Los `id` asúmelos en el orden en que aparecen.

### 4.1 Sedes

| id | nombre | ciudad | dirección | teléfono | apertura |
|---|---|---|---|---|---|
| 1 | PataSana Chapinero | Bogotá | Cra 13 # 54-20 | 6013456789 | 2018-02-01 |
| 2 | PataSana Laureles | Medellín | Cl 33 # 76-15 | 6044567890 | 2020-07-15 |
| 3 | PataSana Granada | Cali | Av 9N # 15-30 | 6025678901 | 2023-03-10 |
| 4 | PataSana Usaquén | Bogotá | Cl 120 # 7-45 | 6016789012 | 2025-11-01 |

### 4.2 Cargos

| id | nombre | es_veterinario |
|---|---|---|
| 1 | Director(a) general | no |
| 2 | Veterinario jefe | sí |
| 3 | Veterinario | sí |
| 4 | Recepcionista | no |
| 5 | Auxiliar | no |

### 4.3 Empleados

| id | nombres | apellidos | documento | email | cargo | sede | jefe | ingreso | salario |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Mariana | Ortiz | 52111222 | mariana.ortiz@patasana.co | 1 | 1 | — | 2018-01-15 | 12000000 |
| 2 | Felipe | Cárdenas | 79222333 | felipe.cardenas@patasana.co | 2 | 1 | 1 | 2018-02-01 | 7500000 |
| 3 | Natalia | Ríos | 1020333444 | natalia.rios@patasana.co | 3 | 1 | 2 | 2019-05-10 | 5200000 |
| 4 | Jorge | Peña | 80444555 | jorge.pena@patasana.co | 4 | 1 | 2 | 2021-03-01 | 2100000 |
| 5 | Daniela | Montoya | 43555666 | daniela.montoya@patasana.co | 2 | 2 | 1 | 2020-07-01 | 7200000 |
| 6 | Andrés | Quintero | 1036666777 | andres.quintero@patasana.co | 3 | 2 | 5 | 2021-09-15 | 4900000 |
| 7 | Paula | Restrepo | 1037777888 | paula.restrepo@patasana.co | 4 | 2 | 5 | 2022-01-10 | 2000000 |
| 8 | Camilo | Arango | 16888999 | camilo.arango@patasana.co | 2 | 3 | 1 | 2023-03-01 | 6800000 |
| 9 | Luisa | Fernández | 1144999000 | luisa.fernandez@patasana.co | 3 | 3 | 8 | 2024-02-01 | 4500000 |
| 10 | Sebastián | Mora | 1143000111 | — | 5 | 3 | 8 | 2025-06-01 | 1750000 |
| 11 | Valeria | Suárez | 1019111222 | valeria.suarez@patasana.co | 3 | 1 | 2 | 2025-08-18 | 4600000 |
| 12 | Tomás | Gil | 1035222333 | tomas.gil@patasana.co | 5 | 2 | 5 | 2026-01-12 | 1800000 |

### 4.4 Clientes

| id | nombres | apellidos | documento | teléfono | email | ciudad | registro |
|---|---|---|---|---|---|---|---|
| 1 | Carlos | Méndez | 79456123 | 3104567890 | carlos.mendez@mail.com | Bogotá | 2018-03-05 |
| 2 | Ana Lucía | Torres | 52345678 | 3157894561 | ana.torres@mail.com | Bogotá | 2019-06-12 |
| 3 | Julián | Herrera | 1020456789 | 3201239876 | — | Bogotá | 2020-01-20 |
| 4 | Sara | Gómez | 43567890 | 3009876543 | sara.gomez@mail.com | Medellín | 2020-08-03 |
| 5 | Mateo | Zapata | 1036789012 | 3112345678 | mateo.z@mail.com | Medellín | 2021-02-14 |
| 6 | Isabel | Cruz | 32123456 | 3145678901 | isabel.cruz@mail.com | Medellín | 2021-11-30 |
| 7 | Ricardo | Lozano | 16789012 | 3176543210 | ricardo.l@mail.com | Cali | 2023-04-02 |
| 8 | Gabriela | Vélez | 1144567890 | 3189012345 | gaby.velez@mail.com | Cali | 2023-05-19 |
| 9 | Diego | Salazar | 80123456 | 3012345678 | — | Bogotá | 2022-07-07 |
| 10 | Laura | Patiño | 1017234567 | 3165432109 | laura.p@mail.com | Medellín | 2024-01-09 |
| 11 | Hernán | Castaño | 94567123 | 3198765432 | hernan.c@mail.com | Cali | 2024-09-21 |
| 12 | Valentina | Ruiz | 1001234567 | 3023456789 | vale.ruiz@mail.com | Bogotá | 2025-02-28 |
| 13 | Óscar | Duarte | 79888111 | 3134567012 | oscar.d@mail.com | Bogotá | 2025-10-10 |
| 14 | Lina Marcela | Rojas | 1152345678 | 3047890123 | lina.rojas@mail.com | Medellín | 2025-12-01 |
| 15 | Felipe | Agudelo | 1130987654 | 3058901234 | felipe.a@mail.com | Cali | 2026-01-15 |

### 4.5 Especies y razas

**Especies:** 1 Perro · 2 Gato · 3 Ave · 4 Conejo · 5 Reptil

| id | raza | especie |
|---|---|---|
| 1 | Labrador | Perro |
| 2 | Criollo | Perro |
| 3 | Golden Retriever | Perro |
| 4 | Bulldog Francés | Perro |
| 5 | Siamés | Gato |
| 6 | Persa | Gato |
| 7 | Criollo | Gato |
| 8 | Periquito | Ave |
| 9 | Cabeza de león | Conejo |

### 4.6 Mascotas

| id | nombre | raza | sexo | nacimiento | peso_kg | dueño | fallecimiento |
|---|---|---|---|---|---|---|---|
| 1 | Luna | Labrador | H | 2019-04-10 | 28.5 | 1 | — |
| 2 | Max | Criollo (perro) | M | 2017-09-01 | 18.0 | 1 | — |
| 3 | Michi | Siamés | H | 2020-02-14 | 4.2 | 2 | — |
| 4 | Rocky | Bulldog Francés | M | 2021-06-30 | 12.3 | 3 | — |
| 5 | Nala | Golden Retriever | H | 2018-12-05 | 30.1 | 4 | — |
| 6 | Simba | Persa | M | 2019-08-20 | 5.0 | 4 | — |
| 7 | Kiwi | Periquito | M | 2023-03-01 | 0.04 | 5 | — |
| 8 | Toby | Criollo (perro) | M | 2015-05-15 | 22.0 | 6 | 2025-09-10 |
| 9 | Canela | Criollo (gato) | H | 2022-01-10 | 3.8 | 6 | — |
| 10 | Bruno | Labrador | M | 2020-10-10 | 32.0 | 7 | — |
| 11 | Mía | Siamés | H | 2023-07-07 | 3.5 | 8 | — |
| 12 | Copito | Cabeza de león | M | 2024-01-20 | 1.6 | 8 | — |
| 13 | Zeus | Golden Retriever | M | 2016-03-03 | 34.5 | 9 | — |
| 14 | Pelusa | Persa | H | 2021-11-11 | 4.6 | 10 | — |
| 15 | Lola | Bulldog Francés | H | 2022-05-05 | 11.0 | 11 | — |
| 16 | Thor | Criollo (perro) | M | 2024-08-08 | 9.5 | 12 | — |
| 17 | Pepa | Criollo (gato) | H | 2025-03-15 | 2.1 | 12 | — |
| 18 | Coco | Periquito | H | 2024-06-01 | 0.03 | 14 | — |
| 19 | Rex | Labrador | M | 2025-09-01 | 12.0 | 15 | — |
| 20 | Sombra | Criollo (gato) | M | — *(rescatado)* | 4.0 | 3 | — |

### 4.7 Servicios

| id | nombre | categoría | precio | duración (min) |
|---|---|---|---|---|
| 1 | Consulta general | Consulta | 65000 | 30 |
| 2 | Consulta especializada | Consulta | 120000 | 45 |
| 3 | Vacunación | Prevención | 45000 | 15 |
| 4 | Desparasitación | Prevención | 35000 | 15 |
| 5 | Baño y peluquería | Estética | 55000 | 60 |
| 6 | Cirugía menor | Cirugía | 450000 | 90 |
| 7 | Esterilización | Cirugía | 380000 | 120 |
| 8 | Radiografía | Diagnóstico | 150000 | 30 |
| 9 | Hospitalización (día) | Hospitalización | 200000 | 1440 |

### 4.8 Medicamentos

| id | nombre | presentación | precio_unitario | requiere fórmula |
|---|---|---|---|---|
| 1 | Amoxicilina 500mg | tableta | 1200 | sí |
| 2 | Meloxicam 1.5mg/ml | frasco | 38000 | sí |
| 3 | Ivermectina 1% | frasco | 25000 | sí |
| 4 | Prazicuantel | tableta | 4500 | no |
| 5 | Vacuna antirrábica | dosis | 30000 | no |
| 6 | Vacuna triple felina | dosis | 42000 | no |
| 7 | Omeprazol 20mg | cápsula | 900 | sí |
| 8 | Shampoo dermatológico | frasco | 48000 | no |
| 9 | Tramadol 50mg | tableta | 2500 | sí |
| 10 | Suero oral | sobre | 3000 | no |

### 4.9 Inventario (stock / stock mínimo)

| medicamento | Sede 1 | Sede 2 | Sede 3 |
|---|---|---|---|
| 1 Amoxicilina | 200 / 50 | 120 / 50 | 90 / 50 |
| 2 Meloxicam | 15 / 5 | 3 / 5 | 10 / 5 |
| 3 Ivermectina | 10 / 5 | 12 / 5 | — |
| 4 Prazicuantel | 80 / 20 | 60 / 20 | 40 / 20 |
| 5 Vacuna antirrábica | 25 / 10 | 30 / 10 | 18 / 10 |
| 6 Vacuna triple felina | 8 / 10 | 14 / 10 | 9 / 10 |
| 7 Omeprazol | 150 / 30 | 0 / 30 | — |
| 8 Shampoo dermatológico | 4 / 5 | — | 7 / 5 |
| 9 Tramadol | 20 / 10 | 5 / 10 | — |

La sede 4 (Usaquén) aún no tiene inventario. "—" significa que no hay registro.

### 4.10 Citas

| id | mascota | veterinario | sede | servicio | fecha y hora | estado | motivo |
|---|---|---|---|---|---|---|---|
| 1 | 1 Luna | 3 | 1 | 1 | 2025-01-15 09:00 | atendida | Control anual |
| 2 | 2 Max | 3 | 1 | 3 | 2025-01-15 09:30 | atendida | Vacuna antirrábica |
| 3 | 3 Michi | 2 | 1 | 2 | 2025-02-03 10:00 | atendida | Vómito recurrente |
| 4 | 4 Rocky | 3 | 1 | 5 | 2025-02-20 14:00 | cancelada | — |
| 5 | 5 Nala | 6 | 2 | 1 | 2025-03-05 11:00 | atendida | Cojera |
| 6 | 6 Simba | 6 | 2 | 8 | 2025-03-05 11:30 | atendida | Sospecha de fractura |
| 7 | 7 Kiwi | 5 | 2 | 1 | 2025-03-18 08:00 | no_asistio | — |
| 8 | 8 Toby | 5 | 2 | 6 | 2025-04-02 15:00 | atendida | Retiro de masa |
| 9 | 9 Canela | 6 | 2 | 7 | 2025-04-22 09:00 | atendida | Esterilización |
| 10 | 10 Bruno | 9 | 3 | 1 | 2025-05-06 10:30 | atendida | Control |
| 11 | 11 Mía | 9 | 3 | 3 | 2025-05-06 11:00 | atendida | Vacuna triple felina |
| 12 | 12 Copito | 8 | 3 | 4 | 2025-06-10 16:00 | atendida | — |
| 13 | 13 Zeus | 2 | 1 | 2 | 2025-06-25 09:00 | atendida | Artrosis |
| 14 | 1 Luna | 11 | 1 | 4 | 2025-09-02 10:00 | atendida | — |
| 15 | 14 Pelusa | 6 | 2 | 5 | 2025-07-14 13:00 | atendida | — |
| 16 | 15 Lola | 8 | 3 | 2 | 2025-08-01 10:00 | atendida | Problemas respiratorios |
| 17 | 8 Toby | 5 | 2 | 1 | 2025-09-08 09:00 | atendida | Deterioro general |
| 18 | 16 Thor | 3 | 1 | 3 | 2025-09-20 15:30 | atendida | — |
| 19 | 2 Max | 11 | 1 | 1 | 2025-10-14 08:30 | cancelada | — |
| 20 | 10 Bruno | 9 | 3 | 8 | 2025-11-03 11:00 | atendida | Control de cadera |
| 21 | 18 Coco | 6 | 2 | 1 | 2025-12-10 09:30 | atendida | — |
| 22 | 3 Michi | 3 | 1 | 3 | 2026-01-12 10:00 | atendida | Refuerzo de vacuna |
| 23 | 5 Nala | 5 | 2 | 6 | 2026-02-16 14:00 | atendida | Extracción dental |
| 24 | 17 Pepa | 11 | 1 | 7 | 2026-03-09 08:00 | atendida | Esterilización |
| 25 | 19 Rex | 9 | 3 | 3 | 2026-04-20 09:00 | atendida | Primera vacuna antirrábica |
| 26 | 4 Rocky | 3 | 1 | 1 | 2026-06-01 16:30 | no_asistio | — |
| 27 | 20 Sombra | 11 | 1 | 1 | 2026-08-24 11:00 | atendida | Primera consulta |
| 28 | 1 Luna | 3 | 1 | 1 | 2026-10-20 09:00 | programada | Control anual |
| 29 | 6 Simba | 6 | 2 | 5 | 2026-10-28 10:00 | programada | — |
| 30 | 11 Mía | 9 | 3 | 2 | 2026-11-05 15:00 | programada | Revisión dermatológica |

### 4.11 Fórmulas

| cita | medicamento | cantidad | indicaciones |
|---|---|---|---|
| 1 | 4 Prazicuantel | 1 | Una tableta, repetir en 3 meses |
| 2 | 5 Vacuna antirrábica | 1 | Dosis anual |
| 3 | 7 Omeprazol | 14 | 1 cápsula diaria por 14 días |
| 5 | 2 Meloxicam | 1 | 0.1 ml/kg cada 24 h por 5 días |
| 8 | 1 Amoxicilina | 20 | 1 tableta cada 12 h por 10 días |
| 8 | 9 Tramadol | 10 | 1 tableta cada 12 h si hay dolor |
| 11 | 6 Vacuna triple felina | 1 | Dosis anual |
| 12 | 3 Ivermectina | 1 | Aplicación única |
| 13 | 2 Meloxicam | 1 | 0.1 ml/kg cada 24 h |
| 13 | 9 Tramadol | 6 | 1 tableta cada 12 h por 3 días |
| 16 | 1 Amoxicilina | 14 | 1 tableta cada 12 h por 7 días |
| 18 | 5 Vacuna antirrábica | 1 | Primera dosis |
| 22 | 6 Vacuna triple felina | 1 | Refuerzo |
| 23 | 1 Amoxicilina | 10 | 1 tableta cada 12 h por 5 días |
| 23 | 2 Meloxicam | 1 | 0.1 ml/kg cada 24 h |
| 25 | 5 Vacuna antirrábica | 1 | Primera dosis |

### 4.12 Pagos

Las facturas no se dan como datos: las **generas tú** en el ejercicio 45. Los pagos se
identifican por la **cita** de la factura que pagan.

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

## 5. Ejercicios

> **Cómo trabajar:** guarda tu solución en archivos `.sql` por parte (`01_ddl.sql`,
> `02_dml.sql`, …). Cuando un ejercicio modifique datos y quieras repetirlo, envuélvelo en
> `BEGIN; … ROLLBACK;` o recarga tus scripts. Los ejercicios marcados con ✔ traen un
> resultado esperado para que verifiques.

### Parte 1. DDL: definición de la estructura (1–30)

- [ ] **1** 🟢 Crea la base de datos `patasana` con codificación `UTF8` y conéctate a ella.
- [ ] **2** 🟢 Crea el esquema `clinica` y configura el `search_path` para trabajar en él por defecto.
- [ ] **3** 🟢 Crea las tablas catálogo `sedes`, `cargos` y `especies`, con llave primaria autoincremental (`GENERATED ALWAYS AS IDENTITY`) y `UNIQUE` en el nombre.
- [ ] **4** 🟢 Crea `razas` con su llave foránea a `especies` y una restricción `UNIQUE` compuesta que cumpla la RN-05. Explica por qué `UNIQUE (nombre)` sola no sirve.
- [ ] **5** 🟢 Crea `clientes` según la RN-04: documento `UNIQUE NOT NULL`, email `UNIQUE` opcional y `fecha_registro` con valor por defecto.
- [ ] **6** 🟡 Crea `empleados` con llaves foráneas a `cargos` y `sedes`, la auto-referencia `id_jefe`, `CHECK (salario > 0)` y `activo` por defecto en verdadero.
- [ ] **7** 🟡 Crea `mascotas` con todas las restricciones de la RN-06: sexo, peso, nacimiento no futuro y fallecimiento posterior al nacimiento.
- [ ] **8** 🟢 Crea `servicios` con precio `NUMERIC(12,2)` ≥ 0, duración > 0 y `activo` por defecto en verdadero.
- [ ] **9** 🟡 Crea un tipo `ENUM` llamado `estado_cita` con los cuatro estados de la RN-08 y úsalo en la tabla `citas`, con `programada` por defecto.
- [ ] **10** 🟡 Agrega a `citas` la restricción que impide que un veterinario tenga dos citas a la misma fecha y hora.
- [ ] **11** 🟢 Crea `medicamentos` e `inventario`. El inventario usa llave primaria compuesta `(id_sede, id_medicamento)` y `CHECK (stock >= 0)`.
- [ ] **12** 🟢 Crea `formulas` con llave primaria compuesta `(id_cita, id_medicamento)` y `CHECK (cantidad > 0)`.
- [ ] **13** 🟡 Crea `facturas` garantizando que una cita tenga como máximo una factura (RN-13), con el estado validado por `CHECK` y `pendiente` por defecto.
- [ ] **14** 🟡 Crea `detalle_factura` con `ON DELETE CASCADE` hacia `facturas`. ¿Por qué tiene sentido el cascade aquí y no en `pagos`?
- [ ] **15** 🟢 Crea `pagos` con `CHECK` para el método y el monto, y `ON DELETE RESTRICT` hacia `facturas`.
- [ ] **16** 🟡 Decide qué debe pasar con las mascotas si se intenta borrar a su dueño: `RESTRICT`, `CASCADE` o `SET NULL`. Implementa tu decisión y justifícala.
- [ ] **17** 🟢 `ALTER TABLE`: agrega a `mascotas` la columna `observaciones TEXT`.
- [ ] **18** 🟡 Agrega a `sedes` la columna `email` como `NOT NULL` con un valor por defecto temporal, actualízala con correos reales y luego elimina el valor por defecto.
- [ ] **19** 🟢 Renombra la columna `motivo` de `citas` a `motivo_consulta` y después devuélvela a su nombre original.
- [ ] **20** 🟡 Cambia el tipo de `peso_kg` a `NUMERIC(6,3)`. Un periquito pesa 0.03 kg: ¿qué pasaría con `NUMERIC(5,1)`?
- [ ] **21** 🟡 Agrega a `clientes` una restricción con nombre `chk_email_formato` que valide que el email tenga `@` y un punto después.
- [ ] **22** 🟢 Elimina la restricción del ejercicio anterior, verifícalo con `\d clientes` y vuelve a crearla.
- [ ] **23** 🔴 Crea un `DOMAIN` llamado `dinero` (`NUMERIC(12,2)` con `CHECK >= 0`) y úsalo en `servicios.precio`, `medicamentos.precio_unitario` y `pagos.monto`.
- [ ] **24** 🟢 Crea un índice sobre `citas(fecha_hora)`. ¿En qué consultas lo aprovecharía el motor?
- [ ] **25** 🟡 Crea un índice compuesto `citas(id_mascota, fecha_hora)`. ¿Sirve para buscar solo por `fecha_hora`? ¿Por qué importa el orden de las columnas?
- [ ] **26** 🔴 Crea un índice único **parcial** que impida que un cliente tenga dos mascotas *vivas* con el mismo nombre.
- [ ] **27** 🟢 Documenta la base con `COMMENT ON TABLE` y `COMMENT ON COLUMN` en `citas` y en su columna `estado`.
- [ ] **28** 🟢 Crea la tabla `tmp_pruebas`, insértale 3 filas, vacíala con `TRUNCATE` y luego elimínala con `DROP`. Explica la diferencia entre `DELETE`, `TRUNCATE` y `DROP`.
- [ ] **29** 🔴 Agrega a `detalle_factura` la columna generada `subtotal` (`GENERATED ALWAYS AS (cantidad * valor_unitario) STORED`).
- [ ] **30** 🟡 Genera el diagrama entidad-relación (por ejemplo, con DBeaver) y verifica cada cardinalidad contra las reglas de negocio.

### Parte 2. DML: manipulación de datos (31–60)

- [ ] **31** 🟢 Inserta las 4 sedes.
- [ ] **32** 🟢 Inserta los cargos.
- [ ] **33** 🟡 Inserta las especies y las razas. En las razas, obtén `id_especie` con una subconsulta por nombre en vez de escribir el número.
- [ ] **34** 🟡 Inserta los empleados. ¿Qué error obtienes si insertas a Felipe Cárdenas antes que a Mariana Ortiz? ¿Cómo lo evitas?
- [ ] **35** 🟢 Inserta los 15 clientes en un único `INSERT` de varias filas.
- [ ] **36** 🟢 Inserta las 20 mascotas.
- [ ] **37** 🟢 Inserta los servicios y los medicamentos.
- [ ] **38** 🟢 Inserta el inventario.
- [ ] **39** 🟢 Inserta las 30 citas.
- [ ] **40** 🟢 Inserta las fórmulas.
- [ ] **41** 🟢 Intenta insertar una mascota con peso `-2`. ¿Qué restricción lo impide? Copia el mensaje de error.
- [ ] **42** 🟢 Intenta agendar otra cita con la veterinaria Natalia Ríos (id 3) el `2025-01-15 09:00`. ¿Qué restricción falla?
- [ ] **43** 🟢 Intenta insertar un cliente con el documento `79456123`. ¿Qué pasa?
- [ ] **44** 🟢 Inserta un cliente nuevo y obtén su `id_cliente` en la misma sentencia con `RETURNING`.
- [ ] **45** 🟡 Genera las facturas con `INSERT … SELECT`: una por cada cita **atendida**, con fecha de emisión igual a la fecha de la cita. ✔ 23 facturas.
- [ ] **46** 🟡 Genera el detalle del **servicio** de cada factura con `INSERT … SELECT`: descripción = nombre del servicio, cantidad 1, valor = precio del servicio.
- [ ] **47** 🟡 Genera el detalle de los **medicamentos** formulados con `INSERT … SELECT` desde `formulas`.
- [ ] **48** 🟡 Inserta los pagos de la tabla 4.12, obteniendo `id_factura` con una subconsulta a partir del número de cita.
- [ ] **49** 🟡 Con un `UPDATE` y subconsultas, marca como `pagada` cada factura cuyo total pagado sea mayor o igual a su total. ✔ 19 pagadas; quedan pendientes las de las citas 13, 17, 23 y 24.
- [ ] **50** 🟢 Anula la factura de la cita 17.
- [ ] **51** 🟡 Sube un 8 % el precio de los servicios de categoría `Prevención`, redondeando a la centena más cercana.
- [ ] **52** 🟢 Marca como inactivo al empleado Tomás Gil.
- [ ] **53** 🟡 Con `UPDATE … FROM`, aumenta un 5 % el salario de los empleados con cargo veterinario de la sede de Medellín.
- [ ] **54** 🟢 Registra el email de Julián Herrera: `julian.herrera@mail.com`.
- [ ] **55** 🟡 Cambia a `no_asistio` las citas `programada` cuya fecha y hora ya pasó. ¿Cuántas filas se afectan hoy y por qué?
- [ ] **56** 🟡 Elimina el medicamento "Suero oral". Luego intenta eliminar "Amoxicilina 500mg": ¿qué ocurre y por qué?
- [ ] **57** 🟡 Elimina al cliente Óscar Duarte, que no tiene mascotas. Luego intenta eliminar a Carlos Méndez y explica el resultado según tu decisión del ejercicio 16.
- [ ] **58** 🔴 *Upsert*: llega un pedido de medicamentos. La sede 2 recibe 100 Omeprazol y la sede 3 recibe 50 Amoxicilina y 30 Omeprazol. Con un solo `INSERT … ON CONFLICT … DO UPDATE`, suma el stock si el registro existe o créalo si no (stock mínimo 30 para los nuevos).
- [ ] **59** 🟡 Descuenta del inventario de la sede 1 las cantidades formuladas en la cita 22 y devuelve el stock resultante con `RETURNING`.
- [ ] **60** 🟢 Crea la tabla `citas_2025` con `CREATE TABLE … AS SELECT` que contenga solo las citas de 2025. ✔ 21 filas.

### Parte 3. DQL básico (61–75)

- [ ] **61** 🟢 Lista todas las columnas de todas las mascotas.
- [ ] **62** 🟢 Muestra nombre, apellido y teléfono de los clientes, ordenados por apellido.
- [ ] **63** 🟢 Lista los clientes de Medellín.
- [ ] **64** 🟢 Mascotas que pesan más de 20 kg, de la más pesada a la más liviana.
- [ ] **65** 🟢 Servicios con precio entre 50.000 y 200.000 (usa `BETWEEN`).
- [ ] **66** 🟢 Ciudades distintas en las que viven los clientes.
- [ ] **67** 🟢 Las 5 citas más recientes.
- [ ] **68** 🟢 Citas en estado `programada`.
- [ ] **69** 🟢 Clientes sin email.
- [ ] **70** 🟢 Mascotas cuyo nombre empieza por "M" o termina en "a".
- [ ] **71** 🟢 Empleados que no tienen jefe.
- [ ] **72** 🟢 Medicamentos que requieren fórmula, ordenados por precio de mayor a menor.
- [ ] **73** 🟢 Mascotas vivas nacidas antes de 2020.
- [ ] **74** 🟢 Citas atendidas en la sede 2 durante 2025.
- [ ] **75** 🟢 Paginación: la segunda página de clientes, de 5 en 5, ordenados por id (`LIMIT` / `OFFSET`).

### Parte 4. Funciones y expresiones (76–88)

- [ ] **76** 🟢 Nombre completo de cada cliente en una sola columna y en mayúsculas.
- [ ] **77** 🟡 Edad de cada mascota en años con `AGE`. Si no tiene fecha de nacimiento, muestra "Desconocida" (`COALESCE`).
- [ ] **78** 🟡 Antigüedad de cada empleado en años y meses.
- [ ] **79** 🟢 Clasifica las mascotas por peso con `CASE`: Pequeño (< 10 kg), Mediano (< 25 kg) o Grande.
- [ ] **80** 🟢 Clasifica los servicios por duración: Rápido (≤ 15 min), Normal (≤ 60 min) o Largo.
- [ ] **81** 🟡 Muestra el nombre del día de la semana de cada cita. ¿Qué citas cayeron en sábado o domingo?
- [ ] **82** 🟢 Citas agendadas antes del mediodía.
- [ ] **83** 🟡 Muestra el precio de los servicios con separador de miles y el signo `$` usando `to_char`.
- [ ] **84** 🟡 Dominio del email de cada cliente (lo que va después de la `@`) con `split_part`.
- [ ] **85** 🟢 Iniciales de cada empleado (por ejemplo, "M.O.").
- [ ] **86** 🟢 Valor del inventario por fila (`stock * precio_unitario`).
- [ ] **87** 🟡 Cuántos días faltan para cada cita programada.
- [ ] **88** 🟡 Mascotas que cumplen años en el mes actual.

### Parte 5. Agregación (89–102)

- [ ] **89** 🟢 Número total de mascotas. ✔ 20
- [ ] **90** 🟢 Número de mascotas por especie. ✔ Perro 10, Gato 7, Ave 2, Conejo 1
- [ ] **91** 🟢 Número de citas por estado. ✔ atendida 23, programada 3, cancelada 2, no_asistio 2
- [ ] **92** 🟢 Precio promedio, mínimo y máximo de los servicios.
- [ ] **93** 🟢 Número de citas por sede y por año.
- [ ] **94** 🟡 Ciudades con más de 4 clientes (`HAVING`).
- [ ] **95** 🟡 Total de cada factura (suma de su detalle). ✔ La factura de la cita 8 suma 499.000.
- [ ] **96** 🟢 Total recaudado por método de pago.
- [ ] **97** 🟡 Número de citas atendidas por cada veterinario (por id).
- [ ] **98** 🟡 Peso promedio por especie, solo para especies con al menos 2 mascotas.
- [ ] **99** 🟡 Ingreso recaudado por mes durante 2025, según la fecha del pago.
- [ ] **100** 🟡 Medicamentos más formulados, por cantidad total.
- [ ] **101** 🔴 En una sola fila por sede, el número de citas atendidas, canceladas y no asistidas en columnas separadas (usa `COUNT(*) FILTER (WHERE …)`).
- [ ] **102** 🟢 Nómina total y salario promedio por sede.

### Parte 6. JOINs (103–120)

- [ ] **103** 🟢 Mascotas con el nombre de su raza y su especie.
- [ ] **104** 🟢 Mascotas con el nombre completo de su dueño.
- [ ] **105** 🟢 Citas con el nombre de la mascota, el veterinario, el servicio y la sede.
- [ ] **106** 🟢 Empleados con su cargo y su sede.
- [ ] **107** 🟡 Empleados con el nombre de su jefe (*self join*). La directora debe aparecer con jefe vacío.
- [ ] **108** 🟡 Todos los clientes con su número de mascotas, incluidos los que tienen 0.
- [ ] **109** 🟡 Sedes que no tienen citas. ✔ PataSana Usaquén
- [ ] **110** 🟡 Servicios que nunca se han solicitado. ✔ Hospitalización (día)
- [ ] **111** 🟡 Medicamentos que nunca se han formulado.
- [ ] **112** 🟡 Especies sin mascotas registradas. ✔ Reptil
- [ ] **113** 🟡 Historia clínica de Luna: cada cita con su fecha, servicio, veterinario y los medicamentos formulados (si los hay).
- [ ] **114** 🟡 Cada factura con el cliente, su total, lo pagado y el saldo.
- [ ] **115** 🟡 Clientes con saldo pendiente mayor que 0 (sin contar facturas anuladas).
- [ ] **116** 🟡 Medicamentos por debajo del stock mínimo, con el nombre de la sede y del medicamento.
- [ ] **117** 🟡 Ingreso recaudado por sede (pagos → factura → cita → sede).
- [ ] **118** 🟡 Ingreso facturado por categoría de servicio.
- [ ] **119** 🔴 Para cada veterinario, cuántas especies distintas ha atendido.
- [ ] **120** 🔴 Con `CROSS JOIN`, la matriz de todas las combinaciones sede × servicio con su número de citas, incluidas las combinaciones con 0.

### Parte 7. Subconsultas (121–130)

- [ ] **121** 🟢 Servicios con precio mayor que el promedio (subconsulta escalar).
- [ ] **122** 🟡 Mascotas del cliente que tiene más mascotas.
- [ ] **123** 🟡 Clientes que tienen al menos un gato (resuélvelo con `IN` y luego con `EXISTS`).
- [ ] **124** 🟡 Mascotas que nunca han tenido una cita (`NOT EXISTS`).
- [ ] **125** 🟡 La cita más reciente de cada mascota (subconsulta correlacionada).
- [ ] **126** 🟡 Empleados que ganan más que el promedio de su sede.
- [ ] **127** 🟡 La mascota más pesada de cada especie.
- [ ] **128** 🟡 Facturas cuyo total supera el promedio de todas las facturas (tabla derivada en el `FROM`).
- [ ] **129** 🔴 Medicamentos cuyo precio es mayor que el de **todos** los que no requieren fórmula (`> ALL`).
- [ ] **130** 🟡 Cada cliente con su número total de citas, calculado con una subconsulta en el `SELECT`.

### Parte 8. Operaciones de conjuntos (131–135)

- [ ] **131** 🟢 `UNION`: ciudades donde hay sedes o clientes.
- [ ] **132** 🟢 `INTERSECT`: ciudades que tienen sede y también clientes.
- [ ] **133** 🟡 `EXCEPT`: medicamentos del catálogo que no están en el inventario de ninguna sede.
- [ ] **134** 🟡 `UNION ALL`: un directorio de personas (empleados y clientes) con nombre, teléfono o email y una columna `tipo`.
- [ ] **135** 🟡 `EXCEPT`: mascotas atendidas en 2025 que no han vuelto en 2026.

### Parte 9. CTE: expresiones de tabla comunes (136–145)

- [ ] **136** 🟡 Con una CTE, calcula el total de cada factura y luego lista las que tienen saldo.
- [ ] **137** 🟡 Con CTE encadenadas, calcula el gasto total por cliente y clasifícalos en Oro (> 500.000), Plata (> 150.000) o Bronce.
- [ ] **138** 🟡 Con una CTE, encuentra el mes con mayor ingreso recaudado.
- [ ] **139** 🔴 CTE **recursiva**: el organigrama completo desde la directora, con el nivel de cada empleado y la ruta (`Ortiz > Cárdenas > Ríos`).
- [ ] **140** 🔴 CTE recursiva: todos los subordinados, directos e indirectos, de Felipe Cárdenas.
- [ ] **141** 🔴 CTE recursiva: genera todos los días de octubre de 2026 y muestra cuántas citas hay cada día, incluidos los días con 0.
- [ ] **142** 🟡 La primera cita de cada mascota, con el servicio que recibió.
- [ ] **143** 🟡 Clientes cuya última visita atendida fue hace más de 6 meses (para enviarles un recordatorio).
- [ ] **144** 🔴 CTE que modifica datos (`WITH … UPDATE … RETURNING`): descuenta el inventario de una fórmula y, en la misma sentencia, inserta un registro en una tabla `movimientos_inventario`.
- [ ] **145** 🔴 CTE recursiva: calcula las próximas 4 fechas de vacuna antirrábica de Rex, cada 12 meses a partir de su última vacunación.

### Parte 10. Funciones de ventana (146–155)

- [ ] **146** 🟡 Numera las citas de cada mascota en orden cronológico (`ROW_NUMBER`).
- [ ] **147** 🟡 Ranking de veterinarios por citas atendidas dentro de su sede (`RANK`).
- [ ] **148** 🟡 Ingreso acumulado día a día (*running total*).
- [ ] **149** 🟡 Días transcurridos entre citas consecutivas de cada mascota (`LAG`).
- [ ] **150** 🟡 Junto a cada cita, la siguiente cita de la misma mascota (`LEAD`).
- [ ] **151** 🟡 Cada empleado con el salario promedio de su cargo y la diferencia con el suyo (`AVG() OVER`).
- [ ] **152** 🔴 Los 2 servicios más solicitados en cada sede.
- [ ] **153** 🟡 Divide a los clientes en 3 grupos según su gasto (`NTILE`).
- [ ] **154** 🟡 En cada cita, muestra el primer servicio que recibió esa mascota (`FIRST_VALUE`).
- [ ] **155** 🔴 Porcentaje que aporta cada sede al ingreso total (`SUM() OVER ()`).

### Parte 11. Vistas (156–163)

- [ ] **156** 🟢 Crea la vista `v_agenda`: citas programadas con mascota, dueño, teléfono, veterinario y sede.
- [ ] **157** 🟡 Crea la vista `v_historia_clinica`: mascota, fecha, servicio, veterinario, motivo y medicamentos formulados.
- [ ] **158** 🟡 Crea la vista `v_estado_cuenta`: factura, cliente, total, pagado, saldo y estado.
- [ ] **159** 🟢 Consulta `v_estado_cuenta` para obtener los clientes con saldo pendiente, ordenados por saldo.
- [ ] **160** 🔴 Crea la vista actualizable `v_servicios_activos` `WITH CHECK OPTION`. Prueba un `UPDATE` válido y un `INSERT` que viole la condición.
- [ ] **161** 🟡 Crea la vista materializada `mv_ingresos_mensuales` (ingreso por sede y mes). Inserta un pago nuevo, observa que la vista no cambia y luego aplícale `REFRESH`.
- [ ] **162** 🔴 Haz que `mv_ingresos_mensuales` se pueda refrescar con `REFRESH … CONCURRENTLY`. ¿Qué índice se necesita y por qué?
- [ ] **163** 🟡 Agrega una columna a `v_agenda` con `CREATE OR REPLACE VIEW`. ¿Qué cambios no permite? Elimina una vista que tenga dependencias usando `DROP VIEW … CASCADE`.

### Parte 12. DCL: control de acceso (164–171)

- [ ] **164** 🟢 Crea los roles de grupo `rol_admin`, `rol_veterinario` y `rol_recepcion` (sin login).
- [ ] **165** 🟢 Crea los usuarios `natalia` (veterinaria), `jorge` (recepción) y `mariana` (administradora), cada uno con contraseña y miembro de su rol.
- [ ] **166** 🟡 Recepción puede consultar, insertar y actualizar `clientes`, `mascotas` y `citas`, y solo consultar `servicios`. Otorga esos permisos con `GRANT`.
- [ ] **167** 🟡 Los veterinarios pueden consultar mascotas y citas, insertar fórmulas y actualizar **solo** la columna `estado` de `citas` (privilegio por columna).
- [ ] **168** 🟡 Recepción no debe ver los salarios. Resuélvelo de dos formas: con privilegios por columna y con una vista sin la columna `salario`.
- [ ] **169** 🟡 Quita a recepción el permiso de `DELETE` (`REVOKE`) y compruébalo con `SET ROLE jorge`.
- [ ] **170** 🔴 Con `ALTER DEFAULT PRIVILEGES`, haz que las tablas que se creen en el futuro den `SELECT` a `rol_admin` automáticamente.
- [ ] **171** 🔴 *Row Level Security*: cada veterinario solo puede ver **sus** citas. Agrega a `empleados` una columna `usuario_bd`, crea la política y pruébala con `SET ROLE natalia`.

### Parte 13. TCL: transacciones (172–179)

- [ ] **172** 🟡 En una sola transacción, registra una cita atendida, su factura, el detalle y el pago, y confirma con `COMMIT`.
- [ ] **173** 🟡 Repite el ejercicio anterior, pero con un pago de monto negativo. Verifica que, tras el error y el `ROLLBACK`, no quedó nada registrado.
- [ ] **174** 🔴 Formula tres medicamentos en una transacción usando un `SAVEPOINT` antes de cada uno. Si uno no tiene stock, haz `ROLLBACK TO SAVEPOINT` y continúa con los demás.
- [ ] **175** 🔴 Abre dos terminales. En ambas, inicia una transacción y actualiza el stock del mismo medicamento. ¿Qué pasa con la segunda sesión? ¿Qué valor queda al final?
- [ ] **176** 🔴 Demuestra la diferencia entre `READ COMMITTED` y `REPEATABLE READ`, mostrando una lectura no repetible con dos sesiones.
- [ ] **177** 🔴 Usa `SELECT … FOR UPDATE` para que dos recepcionistas no puedan agendar al mismo tiempo el último horario libre de un veterinario.
- [ ] **178** 🔴 Provoca un *deadlock* con dos sesiones que actualizan dos filas en orden inverso. Lee el mensaje de PostgreSQL y explica cómo se evita.
- [ ] **179** 🟡 En `psql`, desactiva el autocommit con `\set AUTOCOMMIT off`, haz un `DELETE` y explica el riesgo de olvidar el `COMMIT` o el `ROLLBACK`.

### Parte 14. Funciones, procedimientos almacenados y triggers (180–200)

- [ ] **180** 🟢 Función SQL `fn_edad_mascota(id_mascota)` que devuelva la edad en años (`NULL` si no se conoce).
- [ ] **181** 🟢 Función `fn_total_factura(id_factura)` que devuelva el total de la factura.
- [ ] **182** 🟡 Función `fn_saldo_cliente(id_cliente)` que devuelva el saldo pendiente del cliente, sin contar facturas anuladas.
- [ ] **183** 🟡 Función que retorne una tabla, `fn_historia_clinica(id_mascota)`, con fecha, servicio, veterinario y medicamentos.
- [ ] **184** 🟡 Función `fn_citas_por_rango(desde, hasta)` en la que `hasta` tenga valor por defecto igual a la fecha actual.
- [ ] **185** 🟡 Procedimiento `sp_registrar_cliente_mascota(...)` que inserte un cliente y su primera mascota.
- [ ] **186** 🔴 Procedimiento `sp_agendar_cita(mascota, veterinario, servicio, fecha_hora)` que valide con `RAISE EXCEPTION` que el empleado es veterinario y está activo, que la mascota está viva y que el veterinario no está ocupado. La sede de la cita es la del veterinario.
- [ ] **187** 🔴 Procedimiento `sp_atender_cita(id_cita, medicamentos, cantidades)`: marca la cita como atendida, inserta las fórmulas, descuenta el inventario de la sede, y crea la factura y su detalle. Recibe los medicamentos y las cantidades como arreglos (`INT[]`).
- [ ] **188** 🔴 Procedimiento `sp_registrar_pago(id_factura, monto, metodo)`: rechaza facturas anuladas y montos mayores que el saldo, y si el pago completa el total, cambia la factura a `pagada`.
- [ ] **189** 🔴 Procedimiento `sp_cancelar_citas_mascota(id_mascota)` que cancele todas sus citas programadas y use `COMMIT` dentro del procedimiento. ¿Por qué esto es posible en un `PROCEDURE` y no en una `FUNCTION`?
- [ ] **190** 🟡 Procedimiento `sp_ajustar_precios(categoria, porcentaje)` con un parámetro `INOUT` que devuelva cuántos servicios se actualizaron.
- [ ] **191** 🟡 Función con un `FOR … LOOP` que recorra el inventario bajo el mínimo y emita un `RAISE NOTICE` con la cantidad sugerida a pedir (el doble del mínimo menos el stock actual).
- [ ] **192** 🔴 Trigger que impida agendar citas para mascotas fallecidas (RN-09).
- [ ] **193** 🔴 Trigger que impida asignar a una cita un empleado cuyo cargo no es veterinario (RN-03).
- [ ] **194** 🔴 Trigger de auditoría (RN-16): crea `auditoria_precios` y registra el precio anterior, el nuevo, `current_user` y la fecha cada vez que cambie el precio de un servicio. Pruébalo con el ejercicio 51.
- [ ] **195** 🔴 Trigger que, al insertar un pago, cambie la factura a `pagada` si lo pagado ya cubre el total.
- [ ] **196** 🔴 Trigger que, al insertar una fórmula, descuente el stock de la sede de la cita, y que lance un error si no hay stock suficiente (RN-12).
- [ ] **197** 🟡 Agrega a `citas` la columna `actualizado_en` y un trigger `BEFORE UPDATE` que la mantenga actualizada.
- [ ] **198** 🟡 Trigger que impida registrar pagos de facturas anuladas (RN-15).
- [ ] **199** 🔴 En `sp_agendar_cita`, captura `unique_violation` con un bloque `EXCEPTION` y devuelve un mensaje amigable: *"El veterinario ya tiene una cita a esa hora"*.
- [ ] **200** 🔴 **Proyecto final.** Procedimiento `sp_cierre_mensual(anio, mes)` que, para el mes indicado, guarde en la tabla `cierres_mensuales` por sede: ingreso recaudado, citas atendidas, citas no asistidas y saldo pendiente. Al terminar debe refrescar `mv_ingresos_mensuales`. Ejecútalo para agosto de 2026 y valida los resultados contra tus consultas de las partes 5 y 6.

---

## 6. Recomendaciones

- Resuelve las partes **en orden**: cada una usa lo construido en la anterior.
- Los ejercicios 41–43 y 56–57 **deben fallar**. El objetivo es leer y entender el error.
- Las partes 12 y 13 se entienden mejor con **dos terminales `psql` abiertas** al mismo tiempo.
- Si algo queda inconsistente, recarga desde cero: `DROP SCHEMA clinica CASCADE;` y vuelve
  a ejecutar tus scripts `01_ddl.sql` y `02_dml.sql`.
