
-- Generalidades



-- Lugares
-- region: tipo de lugar (país, departamento, ciudad, localidad, barrio...)
CREATE TABLE region (
    id_region INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR (150) NOT NULL UNIQUE
);


CREATE TABLE lugar (
    id_lugar INTEGER PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    lugar_padre_id INTEGER REFERENCES lugar(id_lugar),
    region_id INTEGER REFERENCES region(id_region) NOT NULL
);


CREATE TABLE telefono (
    id_telefono INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_id INTEGER REFERENCES lugar(id_lugar),
    numero VARCHAR(15) NOT NULL,
    --- Apply constraint to
    CONSTRAINT telephone_format CHECK (numero ~ '^[0-9]+$')
);

CREATE TABLE sede (
    id_sede INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_sede VARCHAR(50) NOT NULL UNIQUE,
    direccion VARCHAR(255) NOT NULL UNIQUE,
    correo VARCHAR(255) UNIQUE,
    fecha_apertura DATE NOT NULL,
    -- Foreign Keys
    ciudad_id INTEGER REFERENCES lugar(id_lugar),
    telefono_id INTEGER REFERENCES telefono(id_telefono) NOT NULL
);



-- Empleados

CREATE TABLE cargo (
    id_cargo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_cargo VARCHAR(255) NOT NULL UNIQUE,
    esta_habilitado BOOLEAN NOT NULL
);

CREATE TABLE tipo_documento (
    id_tipo_documento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo VARCHAR (255)
);

CREATE TABLE documento (
    id_documento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero VARCHAR (50) NOT NULL UNIQUE,

    ---Foreing key
    tipo_id INTEGER REFERENCES tipo_documento(id_tipo_documento)

);

CREATE TABLE personal (
    id_personal INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR (255) NOT NULL,
    direccion VARCHAR (255) NOT NULL,
    is_active BOOLEAN NOT NULL,
    salario DECIMAL (13,3) NOT NULL CHECK (salario > 0),
    fecha_ingreso DATE NOT NULL,
    correo VARCHAR(100) NOT NULL,

    -- Foreign keys
    telefono_id INTEGER REFERENCES telefono(id_telefono),
    documento_id INTEGER REFERENCES documento(id_documento),
    cargo_id INTEGER REFERENCES cargo(id_cargo),
    jefe_id INTEGER REFERENCES personal(id_personal),
    sede_id INTEGER REFERENCES sede(id_sede)
);

CREATE TABLE cliente (
    id_cliente INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(255),
    apellido VARCHAR (255),
    correo VARCHAR(255) UNIQUE NOT NULL,
    fecha_registro DATE DEFAULT CURRENT_DATE,
    direccion VARCHAR(100) NOT NULL,

    -- Foreign Keys
    documento_id INTEGER REFERENCES documento(id_documento),
    telefono_id INTEGER REFERENCES telefono(id_telefono),
    ciudad_id INTEGER REFERENCES lugar(id_lugar)
);

CREATE TABLE especie (
    id_especie INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL UNIQUE
);

CREATE TABLE raza (
    id_raza INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(255),

    --
    especie_id INTEGER REFERENCES especie(id_especie)
);

CREATE TABLE mascota (
    id_mascota INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    fecha_nacimiento DATE CHECK (fecha_nacimiento <= CURRENT_DATE),
    fecha_muerte DATE CHECK (fecha_muerte >= fecha_nacimiento),
    sexo CHAR(1) NOT NULL CONSTRAINT chk_usuarios_sexo CHECK (sexo IN ('M','H')),
    peso_g NUMERIC(10,2) NOT NULL CONSTRAINT chk_mascotas_peso CHECK (peso_g > 0),
    observacion TEXT,
    -- Foreign key
    raza_id INTEGER REFERENCES raza(id_raza) NOT NULL,
    cliente_id INTEGER REFERENCES cliente(id_cliente) NOT NULL
);

CREATE TABLE categoria (
    id_categoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR (255)
);


--


--- Medicamentos | Inventario


CREATE TABLE presentacion (
    id_presentacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE medicamento (
    id_medicamento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    precio_unitario_actual DECIMAL (10,2) CONSTRAINT chk_precio CHECK (precio_unitario_actual > 0),
    es_formulado BOOLEAN NOT NULL,

    -- FK
    presentacion_id INTEGER REFERENCES presentacion(id_presentacion) NOT NULL
);

CREATE TABLE pedido (
    id_pedido INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cantidad INT NOT NULL,

    --FK
    medicamento_id INTEGER REFERENCES medicamento(id_medicamento),
    sede_id INTEGER REFERENCES sede(id_sede)
);

CREATE TABLE movimiento_inventario (
    id_movimiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo VARCHAR (20),
    cantidad INT NOT NULL CHECK (cantidad > 0),
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    usuario TEXT NOT NULL DEFAULT current_user,

    --FK
    sede_id INTEGER REFERENCES sede(id_sede),
    medicamento_id INTEGER REFERENCES medicamento(id_medicamento)

);


-- inventario
CREATE TABLE inventario (
    id_inventario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    stock INT NOT NULL DEFAULT 0,
    minimo_stock INT NOT NULL DEFAULT 0,

    -- fk
    medicamento_id INTEGER REFERENCES medicamento(id_medicamento),
    sede_id INTEGER REFERENCES sede(id_sede),
    UNIQUE (sede_id, medicamento_id)
);



-- Servicio

CREATE TABLE servicios (
    id_servicio INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR (255) UNIQUE NOT NULL,
    precio DECIMAL (12,3) NOT NULL CONSTRAINT chk_precio CHECK (precio>0),
    duracion INT NOT NULL CONSTRAINT chk_duracion CHECK (duracion>0),
    -- FK
    categoria_id INTEGER REFERENCES categoria(id_categoria)
);
CREATE TYPE estado_cita AS ENUM ('programada', 'atendida', 'cancelada', 'no_asistio');

CREATE TABLE cita (
    id_cita INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_cita TIMESTAMPTZ NOT NULL,
    motivo TEXT,
    estado estado_cita NOT NULL DEFAULT 'programada',
    ultima_modificacion TIMESTAMPTZ NOT NULL,
    --FK
    veterinario_id INTEGER REFERENCES personal(id_personal) NOT NULL,
    sede_id INTEGER REFERENCES sede(id_sede) NOT NULL,
    servicio_id INTEGER REFERENCES servicios(id_servicio) NOT NULL,
    mascota_id INTEGER REFERENCES mascota(id_mascota) NOT NULL,
    UNIQUE (veterinario_id, fecha_cita)
);

CREATE TABLE formula (
    cantidad INT NOT NULL CONSTRAINT chk_cantidad CHECK (cantidad > 0),
    indicaciones TEXT NOT NULL,

    -- FK
    medicamento_id INTEGER REFERENCES medicamento(id_medicamento) NOT NULL,
    cita_id INTEGER REFERENCES cita(id_cita) NOT NULL,
    CONSTRAINT pk_formula PRIMARY KEY (cita_id, medicamento_id)
);
--

CREATE TABLE factura (
    id_factura INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_emision TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(127) CONSTRAINT chk_estado CHECK (estado IN ('pendiente','pagada','anulada')),

    -- FK
    cita_id INTEGER REFERENCES cita(id_cita) NOT NULL UNIQUE
);

CREATE TABLE linea_factura  (
    id_detalle_factura INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    valor_unitario DECIMAL (12,2) NOT NULL CHECK (valor_unitario >= 0),
    subtotal DECIMAL (14,2) GENERATED ALWAYS AS (cantidad * valor_unitario) STORED,
    -- FK
    factura_id INTEGER NOT NULL REFERENCES factura(id_factura)  ON DELETE CASCADE
);

CREATE TABLE metodo_pago (
    id_metodo_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    metodo VARCHAR(31) NOT NULL UNIQUE
);

CREATE TABLE abono (
    id_abonos INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    valor DECIMAL (10,2) NOT NULL CONSTRAINT chk_valor CHECK (valor > 0.00),
    fecha_abono DATE DEFAULT CURRENT_DATE NOT NULL,
    --FK
    factura_id INTEGER REFERENCES factura(id_factura) NOT NULL,
    metodo_pago_id INTEGER REFERENCES metodo_pago(id_metodo_pago) NOT NULL
);

CREATE TABLE cierre_mensual (
    id_cierre_mensual INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    periodo DATE NOT NULL CHECK (EXTRACT(DAY FROM PERIODO) = 1),
    ingreso_recaudado DECIMAL (16,2) NOT NULL CHECK (ingreso_recaudado >= 0),
    citas_atendidas INT NOT NULL CHECK (citas_atendidas >= 0),
    citas_no_asistidas INTEGER NOT NULL CHECK (citas_no_asistidas >= 0),
    saldo_pendiente DECIMAL (16,2) NOT NULL CHECK (saldo_pendiente >= 0),
    -- FK
    sede_id INTEGER REFERENCES sede(id_sede) NOT NULL,
    CONSTRAINT uq_mes_periodo UNIQUE (sede_id,periodo)
);
