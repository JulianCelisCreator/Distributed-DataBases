\c postgres
DROP DATABASE IF EXISTS oficio;
CREATE DATABASE oficio;
\c oficio

CREATE TABLE estudiante (
    id_estudiante UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR (255) NOT NULL,
    fecha_nacimiento DATE NOT NULL
);

CREATE TABLE hobbie (
    id_hobbie UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_hobbie VARCHAR (255) NOT NULL UNIQUE
);

CREATE TABLE recompensa (
    id_recompensa UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    --fk
    hobbie_id UUID REFERENCES hobbie(id_hobbie) NOT NULL
);

CREATE TABLE registro_actividad (
    id_registro UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    duracion INTEGER NOT NULL CHECK (duracion > 0),
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    --fk
    recompensa_id UUID REFERENCES recompensa(id_recompensa) NOT NULL,
    estudiante_id UUID REFERENCES estudiante(id_estudiante) NOT NULL
);

CREATE INDEX idx_registro_actividad_estudiante_id ON registro_actividad(estudiante_id);
CREATE INDEX idx_registro_actividad_recompensa_id ON registro_actividad(recompensa_id);
CREATE INDEX idx_recompensa_hobbie_id ON recompensa(hobbie_id);
