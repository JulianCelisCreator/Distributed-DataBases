\c postgres
DROP DATABASE IF EXISTS oficio;
CREATE DATABASE oficio;
\c oficio

CREATE TABLE estudiante (
    id_estudiante UUID GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    fecha_nacimiento DATE NOT NULL
);

CREATE TABLE hobbie (
    id_hobbie UUID GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_hobbie VARCHAR (255) NOT NULL UNIQUE
);

CREATE TABLE recompensa (
    id_recompensa UUID GENERATED ALWAYS AS IDENTITY PRIMARY KEY,    
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    --fk
    hobbie_id UUID REFERENCES hobbie(id_hobbie) NOT NULL,
    vigente_desde TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(hobbie_id, vigente_desde)
);
/**
CREATE TABLE recompensa (
    id_recompensa UUID GENERATED ALWAYS AS IDENTITY PRIMARY KEY,    
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    --fk
    hobbie_id UUID REFERENCES hobbie(id_hobbie) NOT NULL,

);
**/

CREATE TABLE registro_actividad (
    id_registro UUID GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT NOW() CHECK (fecha_inicio <= fecha_fin()),
    fecha_fin TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    --fk
    recompensa_id UUID REFERENCES recompensa(id_recompensa) NOT NULL,
    estudiante_id UUID REFERENCES estudiante(id_estudiante) NOT NULL
);

/**
CREATE TABLE registro_actividad (
    id_registro UUID GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    duracion INTEGER NOT NULL CHECK (duracion > 0),
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    --fk
    recompensa_id UUID REFERENCES recompensa(id_recompensa) NOT NULL,
    estudiante_id UUID REFERENCES estudiante(id_estudiante) NOT NULL
);
**/