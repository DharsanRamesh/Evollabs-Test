SHELL := /bin/bash

.PHONY: up down logs test clean

up:
	@echo "Starting Teleport lab environment..."
	docker compose up -d --build
	@echo "Waiting for Teleport to become healthy..."
	./scripts/wait_for_teleport.sh
	@echo "Bootstrapping Teleport roles, users, and identities..."
	./scripts/bootstrap_teleport.sh

down:
	@echo "Stopping Teleport lab environment..."
	docker compose down -v

logs:
	docker compose logs -f

test:
	@echo "Running access tests..."
	./tests/run.sh

clean: down
	@echo "Cleaning generated files..."
	rm -rf teleport/data teleport/identities || true

