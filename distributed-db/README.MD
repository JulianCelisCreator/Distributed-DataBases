# SQL Distributed DataBases

Two PostgreSQL 18 nodes with physical streaming replication:

| Service    | Role                  | Port |
|------------|-----------------------|------|
| `primario` | Read/write            | 5433 |
| `replica`  | Read-only (standby)   | 5434 |

On the first start (empty volumes) the primary runs `docker/00-replicacion.sh`, `DDL.sql` and `DML.sql`,
and the replica copies it with `pg_basebackup`. Credentials are read from `.env`
(`POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `REPLICATION_USER`, `REPLICATION_PASSWORD`).

```bash
docker compose up -d          # start both nodes
docker compose ps             # status
docker compose logs -f        # logs
docker compose down           # stop (data is kept in the volumes)
docker compose down -v        # stop and delete the data (DDL/DML run again on next start)
```

Check the replication:

```bash
docker exec -it primario psql -U <user> -d oficio -c "SELECT client_addr, state FROM pg_stat_replication;"   # state = streaming
docker exec -it replica  psql -U <user> -d oficio -c "SELECT pg_is_in_recovery();"   # t = standby
```

The tables live in the `oficio` database (created by `DDL.sql`), so always pass `-d oficio`.

Insert on the primary and verify on the replica (point 4):

```bash
docker exec -i primario psql -U <user> -d oficio < nuevos_hobbies.sql     # 3 new hobbies + activity
docker exec -it replica psql -U <user> -d oficio -c "SELECT nombre_hobbie FROM hobbie ORDER BY id_hobbie DESC LIMIT 3;"
docker exec -it replica psql -U <user> -d oficio -c "INSERT INTO hobbie (nombre_hobbie) VALUES ('x');"   # fails: read-only
```

Queries (read-only, same result on both nodes):

```bash
docker exec -i primario psql -U <user> -d oficio < consultas.sql
docker exec -i replica  psql -U <user> -d oficio < consultas.sql
```
