# Replicación en CockroachDB y consenso Raft

Taller de **Bases de Datos Distribuidas**: un cluster de CockroachDB con 3 nodos en Docker, la base de datos `oficio` y pruebas de replicación, caída de nodos y consenso Raft.

## Integrantes

- Julián Cabrera
- Andrés Carvajal
- César Pulido
- Julián Celis

## Qué hay en esta carpeta

| Archivo | Contenido |
|---|---|
| `docker-compose.yml` | Cluster de 3 nodos (`roach1`, `roach2`, `roach3`, CockroachDB v25.2.0, modo inseguro) y un contenedor `roach-init` que inicializa el cluster y carga `DDL.sql` y `DML.sql` una sola vez. |
| `DDL.sql` | Crea la base `oficio` con 4 tablas (`estudiante`, `hobbie`, `recompensa`, `registro_actividad`), claves UUID y 3 índices secundarios. |
| `DML.sql` | 540 registros en una transacción: 150 estudiantes, 40 hobbies, 50 recompensas y 300 registros de actividad, con UUID fijos para que los datos sean reproducibles. |
| `DQL.sql` | 7 consultas: top 10 por dinero ganado, por tiempo invertido y por ganancia por minuto, top 5 "más camelladores", clasificación por dinero recaudado (con y sin CTE) y top 10 "más vagos". |
| `pruebas_replicacion.md` | Guía paso a paso de las pruebas de replicación. |
| `README_postgres_antiguo.md` | README anterior (montaje con PostgreSQL), guardado como respaldo. |

## Arquitectura

- Los 3 nodos son iguales: no hay nodo primario y cualquiera acepta lecturas y escrituras. El nodo al que se conecta el cliente hace de *gateway*.
- Cada nodo tiene cinco capas: SQL, transacciones (ACID serializable con MVCC), distribución en *ranges*, replicación y almacenamiento (Pebble).
- Cada *range* tiene 3 réplicas, una en cada nodo. El *leaseholder* atiende las lecturas y coordina las escrituras de su range.
- Una escritura queda confirmada cuando 2 de las 3 réplicas la tienen en su log de Raft. Por eso el cluster sigue funcionando si se cae un nodo, pero deja de responder si se caen dos.

| Nodo | Puerto SQL | Consola web |
|---|---|---|
| roach1 | 26257 | http://localhost:8080 |
| roach2 | 26258 | http://localhost:8081 |
| roach3 | 26259 | http://localhost:8082 |

## Cómo ejecutarlo

```bash
docker compose up -d                                    # levanta los 3 nodos y carga los datos
docker exec roach1 cockroach node status --insecure     # los 3 nodos con is_live = true
docker exec -it roach1 cockroach sql --insecure -d oficio
```

Para correr las consultas en cualquier nodo:

```bash
docker exec -i roach2 cockroach sql --insecure -d oficio < DQL.sql
```

Para apagar el cluster: `docker compose down` conserva los datos y `docker compose down -v` los borra.

## Pruebas de replicación

Están detalladas en [`pruebas_replicacion.md`](pruebas_replicacion.md):

1. **Nivel 1:** escribir en un nodo y leer desde los otros; actualizar desde `roach3` y verificar en `roach1`.
2. **Nivel 2:** apagar `roach1`, seguir leyendo y escribiendo con 2 de 3 nodos y comprobar que, al volver, se pone al día. Como extra, con 2 nodos caídos se pierde el quórum.
3. **Nivel 3:** ver el factor de replicación, qué nodos guardan cada range y cómo cambia el *leaseholder* cuando cae un nodo.

## Video

La presentación (arquitectura, diseño físico, consenso Raft, demo en vivo y consultas) está en `../Presentacion_CockroachDB_FINAL_v3.mp4` y dura 9:52.
