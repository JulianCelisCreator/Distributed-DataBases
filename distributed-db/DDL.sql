\c postgres
DROP DATABASE IF EXISTS oficio;
CREATE DATABASE oficio;
\c oficio

CREATE TABLE estudiante (
    id_estudiante INTEGER GENERATED ALWAYS AS IDENTIFIER PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    fecha_nacimiento DATE NOT NULL
);

CREATE TABLE hobbie (
    id_hobbie INTEGER GENERATED ALWAYS AS IDENTIFIER PRIMARY KEY,
    nombre_hobbie VARCHAR (255) NOT NULL UNIQUE
);

CREATE TABLE recompensa (
    id_recompensa INTEGER GENERATED ALWAYS AS IDENTIFIER PRIMARY KEY,    
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    --fk
    hobbie_id INTEGER REFERENCES hobbie(id_hobbie) NOT NULL,
    vigente_desde TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(hobbie_id, vigente_desde)
);

CREATE TABLE registro_actividad (
    id_registro INTEGER GENERATED ALWAYS AS IDENTIFIER PRIMARY KEY,
    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    --fk
    recompensa_id INTEGER REFERENCES recompensa(id_recompensa) NOT NULL,
    estudiante_id INTEGER REFERENCES estudiante(id_estudiante) NOT NULL
);

