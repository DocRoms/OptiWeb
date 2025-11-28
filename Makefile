DOCKER_COMPOSE := docker compose
SERVICE := app
CONTAINER_FRONT_DIR := /app
CONTAINER_TAURI_DIR := /app/src-tauri

.PHONY: install start stop test-front test-back test docker-up docker-down shell dev git-hooks

# Build de l'image et démarrage du service, puis installation des deps dans le volume monté
install: docker-up git-hooks
	$(DOCKER_COMPOSE) exec $(SERVICE) bash -c "cd $(CONTAINER_FRONT_DIR) && npm install && cd $(CONTAINER_TAURI_DIR) && cargo fetch || true"

# Configure les hooks git pour utiliser .githooks (dans ce dépôt uniquement)
git-hooks:
	@git config core.hooksPath .githooks

# Démarrer Tauri dans Docker avec X11 forwarding (WSLg)
start: docker-up
	$(DOCKER_COMPOSE) exec $(SERVICE) bash -c "cd $(CONTAINER_TAURI_DIR) && cargo tauri dev"

# Démarrer uniquement Vite dans Docker (pour tester le front sans Tauri)
dev: docker-up
	$(DOCKER_COMPOSE) exec $(SERVICE) bash -c "cd $(CONTAINER_FRONT_DIR) && npm run dev -- --host 0.0.0.0"

stop: docker-down

docker-up:
	$(DOCKER_COMPOSE) up -d --build

docker-down:
	$(DOCKER_COMPOSE) down || true

shell:
	$(DOCKER_COMPOSE) run --rm $(SERVICE) bash

test-front:
	$(DOCKER_COMPOSE) run --rm $(SERVICE) bash -c "cd $(CONTAINER_FRONT_DIR) && npm test"

test-back:
	$(DOCKER_COMPOSE) run --rm $(SERVICE) bash -c "cd $(CONTAINER_TAURI_DIR) && cargo test"

test: test-front test-back
