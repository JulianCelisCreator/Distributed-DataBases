-- =============================================================================
-- PataSana · DML: datos iniciales (sección 4 de practica_sql_patasana.md)
-- Adaptado a DDL.sql. Ejecutar sobre una base recién creada: los id se asumen
-- en el orden de inserción (1, 2, 3...), como pide la práctica.
--
-- Datos de la práctica. Las direcciones y algunos correos son FICTICIOS porque
-- el DDL los exige y la práctica no los trae (están marcados abajo).
-- Ver cambios.md, sección 7, para las columnas del DDL que chocan con esto.
-- =============================================================================

\c patasana

-- -----------------------------------------------------------------------------
-- Lugares
-- region: tipo de lugar. lugar: jerarquía por lugar_padre_id
-- (país → departamento → ciudad → localidad → barrio).
-- Solo los países usan su indicativo como id (Colombia = 57); el resto va en
-- orden.
-- -----------------------------------------------------------------------------

INSERT INTO region (nombre) VALUES
    ('País'),               -- 1
    ('Estado'),             -- 2
    ('Departamento'),       -- 3
    ('Distrito capital'),   -- 4
    ('Ciudad'),             -- 5
    ('Localidad'),          -- 6
    ('Barrio');             -- 7

-- País
INSERT INTO lugar (id_lugar, nombre, lugar_padre_id, region_id) VALUES
    (57, 'Colombia', NULL, 1);

-- Distrito capital y los 10 departamentos más poblados
INSERT INTO lugar (id_lugar, nombre, lugar_padre_id, region_id) VALUES
    ( 1, 'Bogotá D.C.',        57, 4),
    ( 2, 'Antioquia',          57, 3),
    ( 3, 'Valle del Cauca',    57, 3),
    ( 4, 'Cundinamarca',       57, 3),
    ( 5, 'Atlántico',          57, 3),
    ( 6, 'Santander',          57, 3),
    ( 7, 'Bolívar',            57, 3),
    ( 8, 'Córdoba',            57, 3),
    ( 9, 'Nariño',             57, 3),
    (10, 'Norte de Santander', 57, 3),
    (11, 'Cauca',              57, 3);

-- Ciudades
INSERT INTO lugar (id_lugar, nombre, lugar_padre_id, region_id) VALUES
    (12, 'Medellín', 2, 5),
    (13, 'Cali',     3, 5);

-- Localidades de Bogotá
INSERT INTO lugar (id_lugar, nombre, lugar_padre_id, region_id) VALUES
    (14, 'Chapinero',     1, 6),
    (15, 'Usaquén',       1, 6),
    (16, 'Teusaquillo',   1, 6),
    (17, 'La Candelaria', 1, 6),
    (18, 'Fontibón',      1, 6),
    (19, 'Kennedy',       1, 6);

-- Barrios de Bogotá
INSERT INTO lugar (id_lugar, nombre, lugar_padre_id, region_id) VALUES
    (20, 'Chapinero Alto',  14, 7),
    (21, 'El Chicó',        14, 7),
    (22, 'Santa Bárbara',   15, 7),
    (23, 'Cedritos',        15, 7),
    (24, 'Galerías',        16, 7),
    (25, 'Las Aguas',       17, 7),
    (26, 'Modelia',         18, 7),
    (27, 'Kennedy Central', 19, 7);

-- -----------------------------------------------------------------------------
-- Teléfonos
-- id 1-4: sedes (fijos) · id 5-19: clientes (cliente n → teléfono n + 4)
-- id 20-31: empleados (empleado n → teléfono n + 19)
-- FICTICIO: la práctica no trae teléfono de los empleados; son celulares
-- inventados.
-- codigo_id = 57: todos los números son de Colombia.
-- -----------------------------------------------------------------------------

INSERT INTO telefono (numero, codigo_id) VALUES
    -- sedes
    ('6013456789', 57), ('6044567890', 57), ('6025678901', 57), ('6016789012', 57),
    -- clientes 1-15
    ('3104567890', 57), ('3157894561', 57), ('3201239876', 57), ('3009876543', 57), ('3112345678', 57),
    ('3145678901', 57), ('3176543210', 57), ('3189012345', 57), ('3012345678', 57), ('3165432109', 57),
    ('3198765432', 57), ('3023456789', 57), ('3134567012', 57), ('3047890123', 57), ('3058901234', 57),
    -- empleados 1-12 (celulares)
    ('3101112233', 57), ('3152223344', 57), ('3203334455', 57), ('3004445566', 57),
    ('3115556677', 57), ('3146667788', 57), ('3177778899', 57), ('3188889900', 57),
    ('3019990011', 57), ('3160001122', 57), ('3192113344', 57), ('3024225566', 57);

-- -----------------------------------------------------------------------------
-- Documentos
-- id 1-12: empleados (empleado n → documento n)
-- id 13-27: clientes (cliente n → documento n + 12)
-- La práctica no indica el tipo de documento, así que tipo_id queda NULL.
-- -----------------------------------------------------------------------------

INSERT INTO documento (numero) VALUES
    -- empleados 1-12
    ('52111222'), ('79222333'), ('1020333444'), ('80444555'), ('43555666'), ('1036666777'),
    ('1037777888'), ('16888999'), ('1144999000'), ('1143000111'), ('1019111222'), ('1035222333'),
    -- clientes 1-15
    ('79456123'), ('52345678'), ('1020456789'), ('43567890'), ('1036789012'),
    ('32123456'), ('16789012'), ('1144567890'), ('80123456'), ('1017234567'),
    ('94567123'), ('1001234567'), ('79888111'), ('1152345678'), ('1130987654');

-- -----------------------------------------------------------------------------
-- 4.1 Sedes
-- ciudad_id: 1 Bogotá D.C. · 12 Medellín · 13 Cali
-- -----------------------------------------------------------------------------

INSERT INTO sede (nombre_sede, direccion, fecha_apertura, ciudad_id, telefono_id) VALUES
    ('PataSana Chapinero', 'Cra 13 # 54-20', '2018-02-01',  1, 1),
    ('PataSana Laureles',  'Cl 33 # 76-15',  '2020-07-15', 12, 2),
    ('PataSana Granada',   'Av 9N # 15-30',  '2023-03-10', 13, 3),
    ('PataSana Usaquén',   'Cl 120 # 7-45',  '2025-11-01',  1, 4);

-- -----------------------------------------------------------------------------
-- 4.2 Cargos
-- -----------------------------------------------------------------------------

INSERT INTO cargo (nombre_cargo, esta_habilitado) VALUES
    ('Director(a) general', FALSE),
    ('Veterinario jefe',    TRUE),
    ('Veterinario',         TRUE),
    ('Recepcionista',       FALSE),
    ('Auxiliar',            FALSE);

-- -----------------------------------------------------------------------------
-- 4.3 Empleados
-- Mariana (id 1) va primero porque los demás la tienen como jefe.
-- FICTICIO: la práctica no trae direcciones; se inventaron en la ciudad de la
-- sede de cada empleado. El correo de Sebastián Mora también es ficticio.
-- -----------------------------------------------------------------------------

INSERT INTO personal (nombre, apellido, direccion, is_active, salario, fecha_ingreso, correo,
                      documento_id, telefono_id, cargo_id, jefe_id, sede_id) VALUES
    ('Mariana',   'Ortiz',     'Cl 93 # 11-27, Bogotá',     TRUE, 12000000, '2018-01-15', 'mariana.ortiz@patasana.co',    1, 20, 1, NULL, 1),
    ('Felipe',    'Cárdenas',  'Cra 7 # 72-41, Bogotá',     TRUE,  7500000, '2018-02-01', 'felipe.cardenas@patasana.co',  2, 21, 2, 1,    1),
    ('Natalia',   'Ríos',      'Cl 63 # 9-18, Bogotá',      TRUE,  5200000, '2019-05-10', 'natalia.rios@patasana.co',     3, 22, 3, 2,    1),
    ('Jorge',     'Peña',      'Cra 24 # 45-12, Bogotá',    TRUE,  2100000, '2021-03-01', 'jorge.pena@patasana.co',       4, 23, 4, 2,    1),
    ('Daniela',   'Montoya',   'Cra 70 # 44-30, Medellín',  TRUE,  7200000, '2020-07-01', 'daniela.montoya@patasana.co',  5, 24, 2, 1,    2),
    ('Andrés',    'Quintero',  'Cl 10 # 43-55, Medellín',   TRUE,  4900000, '2021-09-15', 'andres.quintero@patasana.co',  6, 25, 3, 5,    2),
    ('Paula',     'Restrepo',  'Cra 80 # 32-14, Medellín',  TRUE,  2000000, '2022-01-10', 'paula.restrepo@patasana.co',   7, 26, 4, 5,    2),
    ('Camilo',    'Arango',    'Av 6N # 23-40, Cali',       TRUE,  6800000, '2023-03-01', 'camilo.arango@patasana.co',    8, 27, 2, 1,    3),
    ('Luisa',     'Fernández', 'Cl 5 # 38-21, Cali',        TRUE,  4500000, '2024-02-01', 'luisa.fernandez@patasana.co',  9, 28, 3, 8,    3),
    ('Sebastián', 'Mora',      'Cra 44 # 9-62, Cali',       TRUE,  1750000, '2025-06-01', 'sebastian.mora@patasana.co',  10, 29, 5, 8,    3),
    ('Valeria',   'Suárez',    'Cl 127 # 15-33, Bogotá',    TRUE,  4600000, '2025-08-18', 'valeria.suarez@patasana.co',  11, 30, 3, 2,    1),
    ('Tomás',     'Gil',       'Cl 50 # 65-08, Medellín',   TRUE,  1800000, '2026-01-12', 'tomas.gil@patasana.co',       12, 31, 5, 5,    2);

-- -----------------------------------------------------------------------------
-- 4.4 Clientes
-- ciudad_id: 1 Bogotá D.C. · 12 Medellín · 13 Cali
-- FICTICIO: la práctica no trae direcciones; se inventaron en la ciudad de cada
-- cliente. Los correos de Julián Herrera y Diego Salazar también son ficticios.
-- -----------------------------------------------------------------------------

INSERT INTO cliente (nombre, apellido, correo, fecha_registro, direccion,
                     documento_id, telefono_id, ciudad_id) VALUES
    ('Carlos',       'Méndez',  'carlos.mendez@mail.com', '2018-03-05', 'Cl 57 # 13-40, Bogotá',    13,  5, 1),
    ('Ana Lucía',    'Torres',  'ana.torres@mail.com',    '2019-06-12', 'Cra 15 # 85-22, Bogotá',   14,  6, 1),
    ('Julián',       'Herrera', 'julian.h@mail.com',      '2020-01-20', 'Cl 45 # 19-07, Bogotá',    15,  7, 1),
    ('Sara',         'Gómez',   'sara.gomez@mail.com',    '2020-08-03', 'Cra 76 # 35-18, Medellín', 16,  8, 12),
    ('Mateo',        'Zapata',  'mateo.z@mail.com',       '2021-02-14', 'Cl 33 # 81-45, Medellín',  17,  9, 12),
    ('Isabel',       'Cruz',    'isabel.cruz@mail.com',   '2021-11-30', 'Cra 65 # 48-10, Medellín', 18, 10, 12),
    ('Ricardo',      'Lozano',  'ricardo.l@mail.com',     '2023-04-02', 'Av 4N # 17-25, Cali',      19, 11, 13),
    ('Gabriela',     'Vélez',   'gaby.velez@mail.com',    '2023-05-19', 'Cl 9 # 48-33, Cali',       20, 12, 13),
    ('Diego',        'Salazar', 'diego.s@mail.com',       '2022-07-07', 'Cra 11 # 118-50, Bogotá',  21, 13, 1),
    ('Laura',        'Patiño',  'laura.p@mail.com',       '2024-01-09', 'Cl 30 # 70-12, Medellín',  22, 14, 12),
    ('Hernán',       'Castaño', 'hernan.c@mail.com',      '2024-09-21', 'Cra 100 # 11-60, Cali',    23, 15, 13),
    ('Valentina',    'Ruiz',    'vale.ruiz@mail.com',     '2025-02-28', 'Cl 140 # 9-31, Bogotá',    24, 16, 1),
    ('Óscar',        'Duarte',  'oscar.d@mail.com',       '2025-10-10', 'Cra 50 # 26-14, Bogotá',   25, 17, 1),
    ('Lina Marcela', 'Rojas',   'lina.rojas@mail.com',    '2025-12-01', 'Cl 8 # 25-47, Medellín',   26, 18, 12),
    ('Felipe',       'Agudelo', 'felipe.a@mail.com',      '2026-01-15', 'Cl 16 # 56-20, Cali',      27, 19, 13);

-- -----------------------------------------------------------------------------
-- 4.5 Especies y razas
-- -----------------------------------------------------------------------------

INSERT INTO especie (nombre) VALUES
    ('Perro'), ('Gato'), ('Ave'), ('Conejo'), ('Reptil');

INSERT INTO raza (nombre, especie_id) VALUES
    ('Labrador',         1),   -- 1
    ('Criollo',          1),   -- 2  (perro)
    ('Golden Retriever', 1),   -- 3
    ('Bulldog Francés',  1),   -- 4
    ('Siamés',           2),   -- 5
    ('Persa',            2),   -- 6
    ('Criollo',          2),   -- 7  (gato)
    ('Periquito',        3),   -- 8
    ('Cabeza de león',   4);   -- 9

-- -----------------------------------------------------------------------------
-- 4.6 Mascotas
-- El DDL guarda el peso en gramos (peso_g): kg de la práctica × 1000.
-- Sombra es rescatado: fecha de nacimiento desconocida (NULL).
-- -----------------------------------------------------------------------------

INSERT INTO mascota (nombre, raza_id, sexo, fecha_nacimiento, peso_g, cliente_id, fecha_muerte) VALUES
    ('Luna',   1, 'H', '2019-04-10', 28500,  1, NULL),
    ('Max',    2, 'M', '2017-09-01', 18000,  1, NULL),
    ('Michi',  5, 'H', '2020-02-14',  4200,  2, NULL),
    ('Rocky',  4, 'M', '2021-06-30', 12300,  3, NULL),
    ('Nala',   3, 'H', '2018-12-05', 30100,  4, NULL),
    ('Simba',  6, 'M', '2019-08-20',  5000,  4, NULL),
    ('Kiwi',   8, 'M', '2023-03-01',    40,  5, NULL),
    ('Toby',   2, 'M', '2015-05-15', 22000,  6, '2025-09-10'),
    ('Canela', 7, 'H', '2022-01-10',  3800,  6, NULL),
    ('Bruno',  1, 'M', '2020-10-10', 32000,  7, NULL),
    ('Mía',    5, 'H', '2023-07-07',  3500,  8, NULL),
    ('Copito', 9, 'M', '2024-01-20',  1600,  8, NULL),
    ('Zeus',   3, 'M', '2016-03-03', 34500,  9, NULL),
    ('Pelusa', 6, 'H', '2021-11-11',  4600, 10, NULL),
    ('Lola',   4, 'H', '2022-05-05', 11000, 11, NULL),
    ('Thor',   2, 'M', '2024-08-08',  9500, 12, NULL),
    ('Pepa',   7, 'H', '2025-03-15',  2100, 12, NULL),
    ('Coco',   8, 'H', '2024-06-01',    30, 14, NULL),
    ('Rex',    1, 'M', '2025-09-01', 12000, 15, NULL),
    ('Sombra', 7, 'M', NULL,          4000,  3, NULL);

-- -----------------------------------------------------------------------------
-- 4.7 Servicios
-- -----------------------------------------------------------------------------

INSERT INTO categoria (nombre) VALUES
    ('Consulta'),        -- 1
    ('Prevención'),      -- 2
    ('Estética'),        -- 3
    ('Cirugía'),         -- 4
    ('Diagnóstico'),     -- 5
    ('Hospitalización'); -- 6

INSERT INTO servicios (nombre, categoria_id, precio, duracion) VALUES
    ('Consulta general',       1,  65000,   30),
    ('Consulta especializada', 1, 120000,   45),
    ('Vacunación',             2,  45000,   15),
    ('Desparasitación',        2,  35000,   15),
    ('Baño y peluquería',      3,  55000,   60),
    ('Cirugía menor',          4, 450000,   90),
    ('Esterilización',         4, 380000,  120),
    ('Radiografía',            5, 150000,   30),
    ('Hospitalización (día)',  6, 200000, 1440);

-- -----------------------------------------------------------------------------
-- 4.8 Medicamentos
-- -----------------------------------------------------------------------------

INSERT INTO presentacion (nombre) VALUES
    ('tableta'),   -- 1
    ('frasco'),    -- 2
    ('dosis'),     -- 3
    ('cápsula'),   -- 4
    ('sobre');     -- 5

INSERT INTO medicamento (nombre, presentacion_id, precio_unitario_actual, es_formulado) VALUES
    ('Amoxicilina 500mg',     1,  1200, TRUE),
    ('Meloxicam 1.5mg/ml',    2, 38000, TRUE),
    ('Ivermectina 1%',        2, 25000, TRUE),
    ('Prazicuantel',          1,  4500, FALSE),
    ('Vacuna antirrábica',    3, 30000, FALSE),
    ('Vacuna triple felina',  3, 42000, FALSE),
    ('Omeprazol 20mg',        4,   900, TRUE),
    ('Shampoo dermatológico', 2, 48000, FALSE),
    ('Tramadol 50mg',         1,  2500, TRUE),
    ('Suero oral',            5,  3000, FALSE);

-- -----------------------------------------------------------------------------
-- 4.9 Inventario
-- La sede 4 (Usaquén) todavía no tiene inventario.
-- -----------------------------------------------------------------------------

INSERT INTO inventario (sede_id, medicamento_id, stock, minimo_stock) VALUES
    -- Sede 1 · Chapinero
    (1, 1, 200, 50), (1, 2, 15, 5), (1, 3, 10, 5), (1, 4, 80, 20), (1, 5, 25, 10),
    (1, 6,   8, 10), (1, 7, 150, 30), (1, 8, 4, 5), (1, 9, 20, 10),
    -- Sede 2 · Laureles
    (2, 1, 120, 50), (2, 2, 3, 5), (2, 3, 12, 5), (2, 4, 60, 20), (2, 5, 30, 10),
    (2, 6,  14, 10), (2, 7, 0, 30), (2, 9, 5, 10),
    -- Sede 3 · Granada
    (3, 1,  90, 50), (3, 2, 10, 5), (3, 4, 40, 20), (3, 5, 18, 10), (3, 6, 9, 10),
    (3, 8,   7, 5);

-- -----------------------------------------------------------------------------
-- 4.10 Citas
-- estado usa el ENUM estado_cita ('programada', 'atendida', 'cancelada', 'no_asistio').
-- ultima_modificacion es NOT NULL y no tiene DEFAULT: se usa now().
-- FICTICIO: las citas 4, 7, 12, 14, 15, 18, 19, 21, 26 y 29 no traen motivo en la
-- práctica; se inventó uno acorde al servicio.
-- -----------------------------------------------------------------------------

INSERT INTO cita (mascota_id, veterinario_id, sede_id, servicio_id, fecha_cita, estado, motivo, ultima_modificacion) VALUES
    ( 1,  3, 1, 1, '2025-01-15 09:00', 'atendida',   'Control anual',              now()),  --  1
    ( 2,  3, 1, 3, '2025-01-15 09:30', 'atendida',   'Vacuna antirrábica',         now()),  --  2
    ( 3,  2, 1, 2, '2025-02-03 10:00', 'atendida',   'Vómito recurrente',          now()),  --  3
    ( 4,  3, 1, 5, '2025-02-20 14:00', 'cancelada',  'Baño y corte de pelo',       now()),  --  4
    ( 5,  6, 2, 1, '2025-03-05 11:00', 'atendida',   'Cojera',                     now()),  --  5
    ( 6,  6, 2, 8, '2025-03-05 11:30', 'atendida',   'Sospecha de fractura',       now()),  --  6
    ( 7,  5, 2, 1, '2025-03-18 08:00', 'no_asistio', 'Revisión de plumaje',        now()),  --  7
    ( 8,  5, 2, 6, '2025-04-02 15:00', 'atendida',   'Retiro de masa',             now()),  --  8
    ( 9,  6, 2, 7, '2025-04-22 09:00', 'atendida',   'Esterilización',             now()),  --  9
    (10,  9, 3, 1, '2025-05-06 10:30', 'atendida',   'Control',                    now()),  -- 10
    (11,  9, 3, 3, '2025-05-06 11:00', 'atendida',   'Vacuna triple felina',       now()),  -- 11
    (12,  8, 3, 4, '2025-06-10 16:00', 'atendida',   'Desparasitación de rutina',  now()),  -- 12
    (13,  2, 1, 2, '2025-06-25 09:00', 'atendida',   'Artrosis',                   now()),  -- 13
    ( 1, 11, 1, 4, '2025-09-02 10:00', 'atendida',   'Desparasitación trimestral', now()),  -- 14
    (14,  6, 2, 5, '2025-07-14 13:00', 'atendida',   'Baño y deslanado',           now()),  -- 15
    (15,  8, 3, 2, '2025-08-01 10:00', 'atendida',   'Problemas respiratorios',    now()),  -- 16
    ( 8,  5, 2, 1, '2025-09-08 09:00', 'atendida',   'Deterioro general',          now()),  -- 17
    (16,  3, 1, 3, '2025-09-20 15:30', 'atendida',   'Vacuna de cachorro',         now()),  -- 18
    ( 2, 11, 1, 1, '2025-10-14 08:30', 'cancelada',  'Control general',            now()),  -- 19
    (10,  9, 3, 8, '2025-11-03 11:00', 'atendida',   'Control de cadera',          now()),  -- 20
    (18,  6, 2, 1, '2025-12-10 09:30', 'atendida',   'Revisión general',           now()),  -- 21
    ( 3,  3, 1, 3, '2026-01-12 10:00', 'atendida',   'Refuerzo de vacuna',         now()),  -- 22
    ( 5,  5, 2, 6, '2026-02-16 14:00', 'atendida',   'Extracción dental',          now()),  -- 23
    (17, 11, 1, 7, '2026-03-09 08:00', 'atendida',   'Esterilización',             now()),  -- 24
    (19,  9, 3, 3, '2026-04-20 09:00', 'atendida',   'Primera vacuna antirrábica', now()),  -- 25
    ( 4,  3, 1, 1, '2026-06-01 16:30', 'no_asistio', 'Control de peso',            now()),  -- 26
    (20, 11, 1, 1, '2026-08-24 11:00', 'atendida',   'Primera consulta',           now()),  -- 27
    ( 1,  3, 1, 1, '2026-10-20 09:00', 'programada', 'Control anual',              now()),  -- 28
    ( 6,  6, 2, 5, '2026-10-28 10:00', 'programada', 'Baño y corte de uñas',       now()),  -- 29
    (11,  9, 3, 2, '2026-11-05 15:00', 'programada', 'Revisión dermatológica',     now());  -- 30

-- -----------------------------------------------------------------------------
-- 4.11 Fórmulas
-- -----------------------------------------------------------------------------

INSERT INTO formula (cita_id, medicamento_id, cantidad, indicaciones) VALUES
    ( 1, 4,  1, 'Una tableta, repetir en 3 meses'),
    ( 2, 5,  1, 'Dosis anual'),
    ( 3, 7, 14, '1 cápsula diaria por 14 días'),
    ( 5, 2,  1, '0.1 ml/kg cada 24 h por 5 días'),
    ( 8, 1, 20, '1 tableta cada 12 h por 10 días'),
    ( 8, 9, 10, '1 tableta cada 12 h si hay dolor'),
    (11, 6,  1, 'Dosis anual'),
    (12, 3,  1, 'Aplicación única'),
    (13, 2,  1, '0.1 ml/kg cada 24 h'),
    (13, 9,  6, '1 tableta cada 12 h por 3 días'),
    (16, 1, 14, '1 tableta cada 12 h por 7 días'),
    (18, 5,  1, 'Primera dosis'),
    (22, 6,  1, 'Refuerzo'),
    (23, 1, 10, '1 tableta cada 12 h por 5 días'),
    (23, 2,  1, '0.1 ml/kg cada 24 h'),
    (25, 5,  1, 'Primera dosis');

-- -----------------------------------------------------------------------------
-- 4.12 Pagos: catálogo de métodos
-- Las facturas, su detalle y los abonos NO van aquí: según la práctica se
-- generan en los ejercicios 45-48 (INSERT ... SELECT a partir de las citas).
-- -----------------------------------------------------------------------------

INSERT INTO metodo_pago (metodo) VALUES
    ('efectivo'), ('tarjeta'), ('transferencia');
