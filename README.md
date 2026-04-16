# TVBH Development Setup

This project supports a Docker-first local workflow where Postgres runs in Docker,
and you can run the Rails app + Vite + jobs from a `web` container.

## 1. Clone and enter the project

```bash
git clone <your-repo-url>
cd tvbh
```

## 2. Create your environment file

```bash
cp .env.example .env
```

Edit `.env` if needed. The defaults are already wired for Docker Compose.

## 3. Build and start containers

```bash
docker compose up --build -d
```

## 4. Prepare the database

```bash
docker compose run --rm web bin/rails db:prepare
```

## 5. Run Vite SSR build once

```bash
docker compose run --rm web bin/vite build --ssr
```

## 6. Start the app stack

```bash
docker compose exec web bin/dev
```

`bin/dev` starts:
- Rails web server on `http://localhost:3000`
- Vite dev server on `http://localhost:3036`
- Jobs worker

## Common commands

```bash
docker compose exec web bin/rails c
docker compose exec web bin/rails db:migrate
docker compose exec web bin/rails test
docker compose exec web bin/rails db:seed
```

## Stop everything

```bash
docker compose down
```

To also remove database data volume:

```bash
docker compose down -v
```
