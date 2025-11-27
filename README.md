# OptiWeb Tauri + Vite + Rust

Projet exemple Tauri (Rust) + Vite (HTML/CSS/TypeScript sans framework UI), avec tests (Rust + Vitest), Docker, Makefile et hook git `pre-push`.

**✅ Tout est dockerisé** : Ce projet utilise X11 forwarding via WSLg pour afficher Tauri depuis Docker sur ton écran Windows.

## Prérequis

- **Docker** et **docker compose**
- **WSL2** avec **WSLg** (inclus par défaut dans les versions récentes de WSL2)
- Aucune installation de Rust/Node nécessaire sur ta machine !

## Installation

```sh
make install
```

Cette commande :
- Construit l'image Docker avec Rust + Node + Tauri.
- Installe les dépendances npm dans le container.

## Démarrage en développement

```sh
make start
```

Cette commande lance `cargo tauri dev` **dans Docker**, et grâce à X11 forwarding (WSLg), la fenêtre Tauri s'affiche sur ton écran Windows.

### Mode frontend seul (sans Tauri)

Pour tester uniquement le frontend Vite dans Docker sans Tauri :

```sh
make dev
```

Ensuite accède à http://localhost:5173 dans ton navigateur.

## Tests

### Tests front (TypeScript / Vitest)

```sh
make test-front
```

- Exécute `npm run test` (Vitest) dans le container, sur les tests TypeScript placés dans `tests/`.

### Tests back (Rust / Cargo)

```sh
make test-back
```

- Exécute `cargo test` dans `src-tauri/` à l'intérieur du container.

### Tous les tests

```sh
make test
```

- Lance successivement les tests front (`make test-front`) puis back (`make test-back`), toujours via Docker.

## Docker

Docker est utilisé pour les tests et le CI, pas pour le développement Tauri (qui nécessite un environnement graphique).

### Construction de l'image

```sh
make install
```

ou manuellement :

```sh
docker compose up -d --build
```

### Arrêt des services Docker

```sh
make stop
```

## Makefile

Les principales cibles disponibles (tout dans Docker) :

- `make install` : construit l'image Docker et installe les dépendances.
- `make start` : lance Tauri en mode développement **dans Docker** (affichage via X11 forwarding/WSLg).
- `make dev` : lance uniquement Vite dans Docker (sans Tauri), accessible sur http://localhost:5173.
- `make stop` : arrête les services Docker.
- `make test-front` : lance les tests front (Vitest) dans le container.
- `make test-back` : lance les tests backend (Cargo tests) dans le container.
- `make test` : lance tous les tests.
- `make shell` : ouvre un shell bash dans le container `app`.

## Hook git `pre-push`

Un hook `pre-push` est fourni dans `scripts/pre-push`.

### Installation du hook

```sh
chmod +x scripts/pre-push scripts/install-hooks.sh
./scripts/install-hooks.sh
```

Ce script :
- Copie `scripts/pre-push` dans `.git/hooks/pre-push`.
- Rend le hook exécutable.

### Comportement

À chaque `git push` :
- Le hook exécute `make test` **via Docker**.
- Si les tests échouent, le push est bloqué (code de sortie non nul).

## Commande Tauri exposée au front

Le backend Rust définit une commande Tauri :

```rust
#[tauri::command]
fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

Le front l'appelle via l'API Tauri :

```ts
import { invoke } from '@tauri-apps/api/tauri';

const result = await invoke<number>('add', { a, b });
```

Le résultat est affiché dans l'interface (cf. `src/main.ts`).

## Structure du projet

- `src/` : front-end Vite (HTML/CSS/TS).
- `src-tauri/` : backend Rust/Tauri.
- `tests/` : tests TypeScript (Vitest).
- `docker/` : Dockerfile de dev.
- `scripts/` : scripts utilitaires (dont hook git).
- `Makefile` : commandes de build/dev/tests.
- `docker-compose.yml` : configuration docker compose.
- `package.json` : configuration front (Vite, TypeScript, Vitest).
- `vite.config.ts` : configuration Vite + Vitest.
- `tsconfig.json` : configuration TypeScript.

## Comment fonctionne X11 forwarding avec Docker + WSLg ?

**X11** est le système de fenêtrage sous Linux qui gère l'affichage des interfaces graphiques.

**WSLg** (Windows Subsystem for Linux GUI) est intégré dans WSL2 et fournit un serveur X11 automatiquement.

**Le flow** :
1. Tauri tourne dans le container Docker
2. Le container est configuré pour accéder au serveur X11 de WSLg (via `/tmp/.X11-unix` et `/mnt/wslg`)
3. Quand Tauri crée une fenêtre GTK, elle est envoyée au serveur X11
4. WSLg affiche la fenêtre sur ton écran Windows

**Variables d'environnement clés** :
- `DISPLAY` : indique au container où se trouve le serveur X11
- `WAYLAND_DISPLAY` : support Wayland (alternative à X11)
- `XDG_RUNTIME_DIR` : dossier runtime pour les sockets
- `PULSE_SERVER` : pour le son (bonus)

Tout est configuré automatiquement dans `docker-compose.yml`, donc tu n'as rien à faire manuellement !
