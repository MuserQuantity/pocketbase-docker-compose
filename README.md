# pocketbase-docker-compose

Docker Compose setup for PocketBase with data persistence and optional admin bootstrap.

## Quick start
1. Copy `env.example` to `.env` and adjust values (set `PB_ADMIN_EMAIL/PB_ADMIN_PASSWORD` and `ENCRYPTION` if needed).
2. Start services: `docker compose up -d`
3. Open the Admin UI at `http://localhost:8090/_/` (or your chosen `PB_PORT`)

## What’s included
- PocketBase container built from the included Dockerfile (version via `PB_VERSION`) with restart policy and healthcheck.
- Data persistence via `./pb_data`, `./pb_public`, and `./pb_hooks` volumes.
- Environment-driven host/port, optional admin user bootstrap, optional settings encryption, and timezone support.

## Environment variables (`.env`)
- `PB_VERSION` (default `0.34.0`): PocketBase version downloaded at build time.
- `PB_HOST` (default `0.0.0.0`): Bind address inside the container.
- `PB_PORT` (default `8090`): Port exposed by PocketBase and mapped on the host.
- `PB_ADMIN_EMAIL` / `PB_ADMIN_PASSWORD` (optional): Auto create/update a superuser when the server starts.
- `ENCRYPTION` (optional): 32-character key to enable settings encryption (`openssl rand -hex 16`). When set, the container automatically adds `--encryptionEnv ENCRYPTION`.
- `TZ` (default `UTC`): Container timezone.
- `ALPINE_MIRROR` (optional): Override the Alpine package mirror for faster builds (useful in CN networks).
- `PB_DOWNLOAD_BASE` (optional): Override the PocketBase download base URL (must include the repo path), e.g. `https://mirror.ghproxy.com/https://github.com/pocketbase/pocketbase/releases/download`.

## Useful commands
- Start/stop: `docker compose up -d` / `docker compose down`
- Logs: `docker compose logs -f pocketbase`
- Run admin commands: `docker compose exec pocketbase pocketbase superuser create --dir /pb_data`
- Run migrations: `docker compose exec pocketbase pocketbase migrate --dir /pb_data`
- Check version: `docker compose exec pocketbase pocketbase --version --dir /pb_data`

## Custom builds (optional)
If you prefer to build your own image/version:
```bash
# Build with a specific PocketBase version
docker build --build-arg VERSION=0.34.0 -t my-pocketbase .

# Build with the Dockerfile default version
docker build -t my-pocketbase:dev .
```
