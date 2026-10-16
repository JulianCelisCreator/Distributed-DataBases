#!/bin/bash
# Se ejecuta solo en el primario, la primera vez (volumen vacío).
set -e   # si un comando falla, detener el script

# 1. Crear el usuario con permiso de replicación
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-SQL
    CREATE ROLE ${REPLICATION_USER} WITH REPLICATION LOGIN PASSWORD '${REPLICATION_PASSWORD}';
SQL

# 2. Permitir que ese usuario se conecte para replicar desde la red de Docker
echo "host replication ${REPLICATION_USER} all scram-sha-256" >> "$PGDATA/pg_hba.conf"
