# Three-Tier Architecture Demo

![Full Architecture Diagram](docs/AWS-3Tier-Architecture-App-Dark.svg)

See infrastructure details in [docs/INFRA_RESOURCES.md](docs/INFRA_RESOURCES.md).

## Purpose

A production-inspired demo that validates a three-tier architecture with a Next.js web tier, a NestJS app tier, and an RDS PostgreSQL data tier. It focuses on clear connectivity between tiers, practical infrastructure, and containerized deployments.

## Tech Stack

- **Frontend:** Next.js (React 19), MUI, Tailwind CSS
- **Backend:** NestJS, Prisma ORM
- **Database:** PostgreSQL 18
- **Infrastructure:** Terraform, AWS (VPC, NAT Gateway, ALB, ASG, RDS)
- **Containers:** Docker, ECR

## Functionality

- Backend health check and DB connectivity check with visible status
- DB health now includes `seeded`, `seededAt`, and `schemaReady`
- One-time database bootstrap endpoint (`POST /health/db/seed-once`) auto-applies `prisma migrate deploy` if schema is missing
- One-time database bootstrap endpoint (`POST /health/db/seed-once`) seeds student data once and prevents repeat seeding
- Student management (list, add, edit, delete, refresh)
- Inline editing with save on change
- Instance details displayed per request to demonstrate load balancing
- Backend API exposes health and students endpoints
- Frontend proxies API calls through Next.js server routes

## Local Usage (PowerShell)

### 1) Start PostgreSQL

Using the included Docker Compose file:

```powershell
Set-Location local-db
docker compose up -d
```

Single-command alternative (without Compose):

```powershell
docker run --name demo-postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=three-tier-demo -p 5432:5432 -d postgres:18
```

Notes:

- Consider changing the default password from `secret` to something secure (not critical for local use).
- If port 5432 is already in use, choose a different host port, e.g., `-p 5555:5432`.

### 2) Build and run the backend container

If your DB password contains special characters, URI-encode it before building the `DATABASE_URL`:

```powershell
[System.Uri]::EscapeDataString("your_password_here")
```

```powershell
docker build -t demo-backend -f backend/Dockerfile backend

docker run --name demo-backend -p 3001:3001 `
  -e NODE_ENV=production -e PORT=3001 `
  -e DATABASE_URL="postgresql://postgres:secret@host.docker.internal:5555/three-tier-demo" `
  demo-backend
```

Optionally, run one-time bootstrap via endpoint (run once after backend starts):

```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:3001/health/db/seed-once"
```

### 3) Build and run the frontend container

```powershell
docker build -t demo-frontend -f frontend/Dockerfile frontend

docker run --name demo-frontend -p 3000:3000 -d `
  -e INTERNAL_API_BASE_URL="http://host.docker.internal:3001" `
  demo-frontend
```

Open `http://localhost:3000`.

## Local Usage Without Containers (PowerShell)

### 1) Install PostgreSQL Server and pgAdmin

Download links:

```text
https://www.postgresql.org/download
https://www.postgresql.org/ftp/pgadmin/pgadmin4/
```

Use the EDB interactive installer for PostgreSQL. It usually offers pgAdmin during setup. Create a database named `three-tier-demo`.

#### Alternative — Use a PostgreSQL Container

You can mix native processes with a PostgreSQL container:

- Run the PostgreSQL container with `docker compose up -d` (see above)
- Run the backend with `pnpm start:dev` (see below)
- Run the frontend with `pnpm dev` (see below)

### 2) Run backend locally

Encode the password if it contains special characters:

```powershell
$encodedPassword = [System.Uri]::EscapeDataString("your_password_here")
```

Run the backend:

```powershell
Set-Location backend
pnpm install
pnpm db:generate

$env:NODE_ENV="development"
$env:DATABASE_URL="postgresql://postgres:$encodedPassword@localhost:5432/three-tier-demo"
pnpm start:dev
```

Optional one-time bootstrap from endpoint:

```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:3001/health/db/seed-once"
```

### 3) Run frontend locally

```powershell
Set-Location frontend
pnpm install
$env:INTERNAL_API_BASE_URL="http://localhost:3001"
pnpm dev
```

Open `http://localhost:3000`.

## Cloud Deployment (3 Stages)

### Stage 1: ECR (Image Registries)

```powershell
terraform -chdir=terraform/ecr init
terraform -chdir=terraform/ecr apply
```

Copy the repository URLs from the outputs and set them in `terraform/main/terraform.tfvars`:

- `frontend_ecr_repo_url`
- `backend_ecr_repo_url`
- `ssm_parameter_path_prefix`

The ECR stack outputs also include the SSM parameter names and prefix for image tags.

Build and push images to ECR (use a tag such as a short git SHA or date).

```powershell
# Example: generate the tag with a git command
git rev-parse --short HEAD
```

```powershell
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Build + push frontend
docker build -t <frontend_ecr_repo_url>:<tag> -f frontend/Dockerfile frontend
docker push <frontend_ecr_repo_url>:<tag>

# Build + push backend
docker build -t <backend_ecr_repo_url>:<tag> -f backend/Dockerfile backend
docker push <backend_ecr_repo_url>:<tag>
```

Update the SSM parameters for image tags (these are read by the EC2 user-data scripts):

```powershell
aws ssm put-parameter --name "/<project_name>/frontend/image_tag" --value "<tag>" --type String --overwrite
aws ssm put-parameter --name "/<project_name>/backend/image_tag" --value "<tag>" --type String --overwrite
```

### Stage 2: Infrastructure

```powershell
terraform -chdir=terraform/main init
terraform -chdir=terraform/main apply
```

> **Note:** This assumes the local environment already has AWS credentials configured.
> Image tags are controlled via SSM parameters under
> `/${project_name}/frontend/image_tag` and `/${project_name}/backend/image_tag`.
> The stack outputs the public application URL as the internet-facing ALB DNS endpoint over HTTP.

### Stage 3: One-Time DB Initialization (Seed-Once Endpoint)

Use the seed-once action from the UI DB panel or call the backend endpoint directly.
The endpoint auto-runs migrations when needed and then seeds once.

```powershell
Invoke-RestMethod -Method Post -Uri "http://<app-access-url>/api/proxy/health/db/seed-once"
```

Response behavior:

- First successful call seeds the DB and returns success.
- Later calls return conflict (`already seeded`).
- If two calls race, only one proceeds (DB advisory lock).

#### Alternative — AWS Console (SSM Session)

Open an SSM Session Manager shell and trigger the endpoint from inside the app instance:

```sh
curl -X POST http://localhost:80/health/db/seed-once
```

## Docs

- [Infrastructure Resources](docs/INFRA_RESOURCES.md)
