#!/bin/bash
# Arranque de la réplica (reemplaza el entrypoint normal de la imagen).
set -e

# 1. Solo la primera vez: si no hay datos, copiar el primario
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Volumen vacío: copiando datos desde ${PRIMARY_HOST}..."
    # -Fp: carpetas normales | -Xs: incluye el WAL de la copia
    # -P: progreso | -R: crea standby.signal y la conexión al primario
    until pg_basebackup -h "$PRIMARY_HOST" -U "$REPLICATION_USER" \
            -D "$PGDATA" -Fp -Xs -P -R; do
        echo "Primario no disponible, reintentando en 2s..."
        rm -rf "${PGDATA:?}"/*
        sleep 2
    done
    chmod 0700 "$PGDATA"
fi

# 2. Arrancar Postgres; al ver standby.signal, arranca como réplica
exec docker-entrypoint.sh postgres
