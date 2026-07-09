# Local Hadoop Cluster (Docker)

Multi-node **Hadoop 3.3.6** cluster for local development and student labs.

## Student guide

**Start here:** [HADOOP-STUDENT-GUIDE.md](./HADOOP-STUDENT-GUIDE.md)

Step-by-step setup for Mac, Windows, and Linux — prerequisites, start, verify, HDFS commands, MapReduce exercises, troubleshooting.

## Quick start

```bash
cd hadoop-local-docker
chmod +x scripts/*.sh      # Mac / Linux only
./scripts/start.sh
docker compose ps          # all 7 containers should be (healthy)
./scripts/smoke-test.sh
```

Windows (PowerShell):

```powershell
cd hadoop-local-docker
.\scripts\start.ps1
docker compose ps
.\scripts\smoke-test.ps1
```

## Web UIs

| Service | URL |
|---------|-----|
| HDFS NameNode | http://localhost:9870 |
| YARN ResourceManager | http://localhost:8088 |
| MapReduce History | http://localhost:19888 |

HDFS RPC on host port **9900** (internal `namenode:9000`).

## Cluster services

| Container | Role |
|-----------|------|
| `namenode` | HDFS NameNode |
| `worker-1`, `worker-2`, `worker-3` | HDFS DataNode + YARN NodeManager |
| `resourcemanager` | YARN scheduler |
| `historyserver` | Job history |
| `proxyserver` | YARN app proxy |

Image: [neshkeev/hadoop:3.3.6-jdk-11](https://hub.docker.com/r/neshkeev/hadoop) (amd64 + arm64).

## Stop / reset

```bash
./scripts/stop.sh           # stop, keep data
docker compose down -v      # stop + wipe HDFS
```
