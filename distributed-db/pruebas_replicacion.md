# Pruebas de replicación en CockroachDB

Cluster de 3 nodos definido en `docker-compose.yml`. Todos los comandos se ejecutan desde la carpeta `distributed-db/`.

| Nodo   | Contenedor | SQL (host) | Consola web             |
|--------|------------|------------|-------------------------|
| roach1 | `roach1`   | 26257      | <http://localhost:8080>   |
| roach2 | `roach2`   | 26258      | <http://localhost:8081>   |
| roach3 | `roach3`   | 26259      | <http://localhost:8082>   |

Dentro de cada contenedor el nodo escucha en `localhost:26257`, así que `docker exec <nodo> cockroach sql ...` siempre habla con **ese** nodo.

---

## 0. Preparación

```bash
docker compose up -d
docker compose ps

# Estado del cluster: los 3 nodos deben aparecer con is_live = true
docker exec roach1 cockroach node status --insecure
```

Fíjate en la columna `id` y `address` de `node status`: el **node id** (1, 2, 3) no tiene por qué coincidir con el número del contenedor. Lo necesitas para leer el nivel 3.

Para abrir una consola SQL interactiva en un nodo:

```bash
docker exec -it roach1 cockroach sql --insecure -d oficio
```

Para saber a qué nodo estás conectado:

```sql
SELECT crdb_internal.node_id();
```

---

## Nivel 1: Escribir en un nodo y leer desde otro

#### 1. Insertar en roach1

```bash
docker exec roach1 cockroach sql --insecure -d oficio -e \
  "INSERT INTO hobbie (nombre_hobbie) VALUES ('Prueba replicacion 1') RETURNING id_hobbie, crdb_internal.node_id() AS nodo;"
```

#### 2. Leer desde roach2 y roach3

```bash
docker exec roach2 cockroach sql --insecure -d oficio -e \
  "SELECT id_hobbie, nombre_hobbie, crdb_internal.node_id() AS nodo FROM hobbie WHERE nombre_hobbie LIKE 'Prueba replicacion%';"

docker exec roach3 cockroach sql --insecure -d oficio -e \
  "SELECT id_hobbie, nombre_hobbie, crdb_internal.node_id() AS nodo FROM hobbie WHERE nombre_hobbie LIKE 'Prueba replicacion%';"
```

#### 3. Actualizar desde roach3 y leer desde roach1

```bash
docker exec roach3 cockroach sql --insecure -d oficio -e \
  "UPDATE hobbie SET nombre_hobbie = 'Prueba replicacion 1 (editada en roach3)' WHERE nombre_hobbie = 'Prueba replicacion 1';"

docker exec roach1 cockroach sql --insecure -d oficio -e \
  "SELECT nombre_hobbie FROM hobbie WHERE nombre_hobbie LIKE 'Prueba replicacion%';"
```

**Qué esperar:** la fila aparece al instante en todos los nodos. Recuerda que esto prueba **consistencia**: el gateway podría estar leyendo del leaseholder remoto. La prueba de que existen copias físicas es el nivel 2.

---

## Nivel 2: Tumbar un nodo

#### 1. Apagar roach1

```bash
docker stop roach1

# roach1 debe aparecer con is_live = false
docker exec roach2 cockroach node status --insecure
```

#### 2. Leer desde roach2 los datos que se escribieron en roach1

```bash
docker exec roach2 cockroach sql --insecure -d oficio -e \
  "SELECT nombre_hobbie FROM hobbie WHERE nombre_hobbie LIKE 'Prueba replicacion%';"

docker exec roach2 cockroach sql --insecure -d oficio -e "SELECT count(*) FROM estudiante;"   # 150
```

#### 3. Escribir mientras roach1 está caído

```bash
docker exec roach2 cockroach sql --insecure -d oficio -e \
  "INSERT INTO hobbie (nombre_hobbie) VALUES ('Prueba replicacion 2 (roach1 apagado)');"
```

#### 4. Levantar roach1 y comprobar que se puso al día

```bash
docker start roach1

# Esperar a que roach1 vuelva a is_live = true
docker exec roach2 cockroach node status --insecure

# Leer desde roach1 la fila que se escribió mientras estaba apagado
docker exec roach1 cockroach sql --insecure -d oficio -e \
  "SELECT nombre_hobbie FROM hobbie WHERE nombre_hobbie LIKE 'Prueba replicacion%';"
```

**Qué esperar:** con 2 de 3 nodos vivos hay mayoría, así que se lee y se escribe sin problema. Al volver, roach1 recibe del líder las entradas del log que le faltan.

### Extra: perder el quórum (2 nodos caídos)

```bash
docker stop roach1 roach2

# timeout corta el comando a los 20 s, porque sin mayoría la consulta se queda esperando
timeout 20 docker exec roach3 cockroach sql --insecure -d oficio -e "SELECT count(*) FROM hobbie;"
echo "codigo de salida: $?"   # 124 = se agotó el tiempo

docker start roach1 roach2
docker exec roach3 cockroach node status --insecure
```

**Qué esperar:** roach3 está vivo y tiene una copia completa, pero **no responde**: 1 de 3 no es mayoría, así que no puede mantener la lease ni confirmar escrituras en el log de Raft. Al levantar los otros dos, todo vuelve a funcionar.

---

## Nivel 3: Ver dónde están las réplicas

#### 1. Factor de replicación

```bash
docker exec roach1 cockroach sql --insecure -d oficio -e "SHOW ZONE CONFIGURATION FROM TABLE hobbie;"
```

Busca `num_replicas = 3`.

#### 2. Réplicas y leaseholder de cada tabla

```bash
docker exec roach1 cockroach sql --insecure -d oficio -e "
SELECT 'estudiante' AS tabla, range_id, lease_holder, replicas FROM [SHOW RANGES FROM TABLE estudiante WITH DETAILS]
UNION ALL
SELECT 'hobbie', range_id, lease_holder, replicas FROM [SHOW RANGES FROM TABLE hobbie WITH DETAILS]
UNION ALL
SELECT 'recompensa', range_id, lease_holder, replicas FROM [SHOW RANGES FROM TABLE recompensa WITH DETAILS]
UNION ALL
SELECT 'registro_actividad', range_id, lease_holder, replicas FROM [SHOW RANGES FROM TABLE registro_actividad WITH DETAILS];"
```

- `replicas` tiene los node ids que guardan una copia (con 3 nodos: `{1,2,3}`).
- `lease_holder` es el node id que atiende lecturas y coordina escrituras de ese range.

Para ver todo el detalle de una tabla:

```bash
docker exec roach1 cockroach sql --insecure -d oficio -e "SHOW RANGES FROM TABLE hobbie WITH DETAILS;"
```

#### 3. Ver cómo se mueve la lease al caer un nodo

1. Con la consulta del paso 2, anota qué nodo es el `lease_holder` de `hobbie` y busca su contenedor con `node status`.
2. Apaga ese contenedor, por ejemplo `docker stop roach2`.
3. Espera unos segundos y repite la consulta desde un nodo vivo:

   ```bash
   docker exec roach1 cockroach sql --insecure -d oficio -e \
     "SELECT range_id, lease_holder, replicas FROM [SHOW RANGES FROM TABLE hobbie WITH DETAILS];"
   ```

   El `lease_holder` ahora es otro nodo: las réplicas que quedaban eligieron un nuevo líder.
4. Vuelve a levantar el nodo con `docker start roach2`.

#### 4. Consola web

- <http://localhost:8080> → **Overview**: 3 nodos vivos y el número de réplicas de cada uno.
- Con un nodo apagado aparecen **Under-replicated ranges** (ranges con menos de 3 réplicas sanas). Desaparecen al levantarlo.
- **Metrics → Replication**: gráficas de réplicas, leaseholders y ranges por nodo.

---

## Limpieza

```bash
docker exec roach1 cockroach sql --insecure -d oficio -e \
  "DELETE FROM hobbie WHERE nombre_hobbie LIKE 'Prueba replicacion%';"
```
