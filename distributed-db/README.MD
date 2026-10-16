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
docker exec -it primario psql -U <user> -c "SELECT client_addr, state FROM pg_stat_replication;"
docker exec -it replica  psql -U <user> -c "SELECT pg_is_in_recovery();"   # t = standby
```
