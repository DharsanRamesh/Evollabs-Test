Teleport Access Lab (Reference Implementation)
==============================================

This repository is a **reference implementation** for the "Teleport Access Lab" take‑home assessment.  
It is intentionally small and self‑contained so you can run it locally and use it as a baseline when evaluating candidate submissions.

What this lab demonstrates
--------------------------

- **Secure access patterns with Teleport**:
  - Teleport Auth + Proxy + SSH + Application Access running in containers.
  - One SSH target enrolled into Teleport and reachable with `tsh ssh`.
  - One internal HTTP app published through Teleport Application Access.
- **Least‑privilege access rules**:
  - Three roles: `admin`, `engineer`, `readonly`.
  - Users are mapped to those roles via Teleport user resources.
  - Tests show both **allowed** and **denied** paths.
- **Automation and validation**:
  - `make up` brings up the full environment and bootstraps roles/users.
  - `make test` runs smoke tests using `tsh` to prove behaviour.
- **Operator view and troubleshooting**:
  - README and `docs/design.md` point to useful Teleport logs and commands.

Prerequisites
-------------

- Docker and Docker Compose (v2) installed locally.
- `make` installed.
- Teleport CLI (`tsh`) installed on your machine (matching the Teleport image version, e.g. 16.2.x).

Quick start
-----------

From a clean clone:

```bash
make up      # build images, start containers, bootstrap roles/users/identities
make test    # run automated access checks
make down    # stop and remove containers/volumes
```

You can then access:

- Teleport Web UI: `https://localhost:3080` (self‑signed certificate; accept the warning).

Automation and tests
--------------------

- **Bring‑up validation**:
  - `make up` runs `docker compose up` and waits for Teleport to report healthy via `teleport status`.
  - It then runs `scripts/bootstrap_teleport.sh` which:
    - Applies role definitions from `teleport/resources/roles.yaml`.
    - Applies user definitions from `teleport/resources/users.yaml`.
    - Generates non‑interactive identity files for `engineer` and `readonly` users.
- **Smoke tests** (`make test` / `tests/run.sh`):
  1. **SSH allowed**: `engineer` can authenticate to the SSH node via Teleport (shell launch is skipped due to the distroless image, see note below).
  2. **App allowed**: `engineer` can log into the `demo-app` application via Teleport Application Access (`tsh app login` succeeds; the CLI prints a working `curl` example).
  3. **Access denied**: `readonly` user is denied SSH access (RBAC denies shell logins).

Teardown
--------

```bash
make down    # stop containers and remove volumes
make clean   # down + remove generated Teleport data/identity files
```

Top 3 troubleshooting steps
---------------------------

1. **Check container health and logs**  
   - `docker compose ps`  
   - `docker compose logs teleport`  
   - Ensure `teleport` service is `running` and health checks are passing.

2. **Inspect Teleport status and nodes**  
   - `docker exec teleport teleport status --config=/etc/teleport/teleport.yaml`  
   - `docker exec teleport tctl nodes ls`  
   - Verify the SSH node with labels `env=lab, service=ssh-node` is registered.

3. **Audit recent events**  
   - `docker exec teleport tctl events ls --namespace=default --tail=20`  
   - Look for `session.start`, `session.end`, `app.session.start`, and access denial events.

Security hygiene
----------------

- **No real secrets** are committed:
  - Teleport data (certs, keys, tokens) live under `teleport/data` and are created at runtime.
  - User identity files used by tests are stored under `teleport/identities` and can be safely deleted.
- Configuration uses a **lab‑only static token** in `teleport/teleport.yaml`.  
  In a production scenario, you would replace this with short‑lived join tokens or Auto‑discovery.
 - The SSH service runs inside a **distroless** container that does not ship with a login shell.  
   Successful SSH authentication for the `engineer` user currently surfaces as a specific `fork/exec /sbin/nologin` error;  
   the tests treat this as a valid "allowed" path, while `readonly` is still explicitly denied.

Files and layout
----------------

- `docker-compose.yml` – container orchestration for Teleport and the demo app.
- `teleport/teleport.yaml` – Teleport configuration (auth, proxy, ssh, app services).
- `teleport/resources/roles.yaml` – role definitions for `admin`, `engineer`, `readonly`.
- `teleport/resources/users.yaml` – user definitions bound to those roles.
- `targets/app/` – simple Python HTTP server used as the internal app.
- `scripts/bootstrap_teleport.sh` – bootstraps roles, users, and identity files.
- `scripts/wait_for_teleport.sh` – waits for Teleport to become healthy.
- `tests/run.sh` – automated smoke tests for allowed/denied paths.
- `docs/design.md` – short architecture and design notes.

Notes for interviewers
----------------------

- This repo is intended as a **baseline** so you can:
  - Confirm the assessment is realistic on a clean laptop.
  - Compare candidate submissions against a working example.
- Candidates should not be given this implementation directly, but they may follow a similar shape:
  - Docker‑based Teleport cluster.
  - Programmatic roles/users.
  - Automated tests showing success + denial.

