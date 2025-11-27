# OptiWeb Tauri + Vite + Rust

Projet exemple Tauri (Rust) + Vite (HTML/CSS/TypeScript **sans framework UI**), avec tests (Rust + Vitest), Docker, Makefile et hook git `pre-push`.

**✅ Tout est dockerisé** : Ce projet utilise X11 forwarding via WSLg pour afficher Tauri depuis Docker sous un écran Windows.

## Prérequis

- **Docker** et **docker compose**
- **WSL2** avec **WSLg** (inclus par défaut dans les versions récentes de WSL2)
- Aucune installation de Rust/Node nécessaire sur la machine !

## Installation

```sh
make install
```

Cette commande :
- Construit l'image Docker avec Rust + Node + Tauri.
- Installe les dépendances npm dans le container (dans `/app/node_modules`).
- Prépare le backend Rust (fetch des dépendances Cargo dans `/app/src-tauri`).

Tout est installé **dans le container**, rien n'est installé sur la machine hôte.

## Démarrage (en développement)

### Tauri + Vite (app complète)

```sh
make start
```

Cette commande :
- Démarre (ou reconstruit si besoin) le container Docker `app`.
- Lance `cargo tauri dev` **dans Docker**, qui lui-même :
  - démarre Vite via `npm run dev` (frontend dans `/app/src`),
  - lance l'app Tauri (backend Rust dans `/app/src-tauri`),
  - ouvre une WebView qui pointe sur `http://localhost:5173`.
- Grâce à X11 forwarding (WSLg), la fenêtre Tauri s'affiche sur ton écran Windows.

> Note : le premier lancement peut prendre quelques secondes (Docker + compilation Rust + démarrage Vite + initialisation de la WebView). Les lancements suivants sont plus rapides.

### Mode frontend seul (sans Tauri)

Pour tester uniquement le frontend Vite dans Docker sans Tauri :

```sh
make dev
```

Ensuite il suffit d'accéder à :

- <http://localhost:5173> dans son navigateur.

Dans ce mode :
- Vite tourne dans le container, avec `root = "src"`.
- La page servie est `src/index.html`.
- Le bundle utilise `src/main.ts` comme point d'entrée.

## Structure du frontend (Vite)

Le projet Vite est structuré ainsi :

- `src/index.html` : page HTML principale (formulaire pour tester la commande Tauri `add`).
- `src/main.ts` : entrypoint TypeScript, qui :
  - expose la fonction `addTs(a, b)` utilisée par les tests Vitest,
  - écoute le formulaire et appelle la commande Tauri `add` via `invoke('add', { a, b })`.
- `src/style.css` : styles de base pour la page.

La configuration Vite (`vite.config.ts`) :

- fixe `root: 'src'` pour que Vite serve directement `src/index.html` en dev,
- génère le build dans `dist/` à la racine du projet (`outDir: '../dist'`),
- configure Vitest (tests dans `tests/**/*.spec.ts`, `environment: 'jsdom'`).

## Tests

### Tests front (TypeScript / Vitest)

```sh
make test-front
```

- Exécute `npm run test` (Vitest) dans le container, sur les tests TypeScript placés dans `tests/`.
- Exemple de test : `tests/add.spec.ts` teste la fonction `addTs` exportée par `src/main.ts`.

```ts
import { describe, it, expect } from 'vitest';
import { addTs } from '../src/main';

describe('addTs', () => {
  it('additionne deux entiers', () => {
    expect(addTs(2, 3)).toBe(5);
    expect(addTs(-1, 1)).toBe(0);
  });
});
```

### Tests back (Rust / Cargo)

```sh
make test-back
```

- Exécute `cargo test` dans `src-tauri/` à l'intérieur du container.
- Les tests Rust se trouvent dans `src-tauri/src/main.rs` (ou modules associés) et valident la commande `add`.

### Tous les tests

```sh
make test
```

- Lance successivement les tests front (`make test-front`) puis back (`make test-back`), toujours via Docker.

## Docker

Docker est utilisé **pour tout le flux de développement** (install, dev, tests, Tauri), afin que ta machine n'ait besoin que de Docker + Make.

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

- `make install` : construit l'image Docker et installe les dépendances (npm + Cargo).
- `make start` : lance Tauri en mode développement **dans Docker** (affichage via X11 forwarding/WSLg).
- `make dev` : lance uniquement Vite dans Docker (sans Tauri), accessible sur <http://localhost:5173>.
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

Le backend Rust définit une commande Tauri simple :

```rust
#[tauri::command]
fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

Le front l'appelle via l'API Tauri :

```ts
import { invoke } from '@tauri-apps/api/core';

const result = await invoke<number>('add', { a, b });
```

Le résultat est affiché dans l'interface (cf. `src/main.ts`).

## Structure du projet

- `src/` : front-end Vite (HTML/CSS/TS), avec `index.html`, `main.ts`, `style.css`.
- `src-tauri/` : backend Rust/Tauri (commande `add`, config `tauri.conf.json`).
- `tests/` : tests TypeScript (Vitest), ex : `tests/add.spec.ts`.
- `docker/` : Dockerfile de dev.
- `scripts/` : scripts utilitaires (dont hook git).
- `Makefile` : commandes de build/dev/tests.
- `docker-compose.yml` : configuration docker compose (service `app`, port 5173 exposé, X11/WSLg).
- `package.json` : configuration front (Vite, TypeScript, Vitest).
- `vite.config.ts` : configuration Vite + Vitest (`root = "src"`).
- `tsconfig.json` : configuration TypeScript.

## Comment fonctionne X11 forwarding avec Docker + WSLg ?

**X11** est le système de fenêtrage sous Linux qui gère l'affichage des interfaces graphiques.

**WSLg** (Windows Subsystem for Linux GUI) est intégré dans WSL2 et fournit un serveur X11 automatiquement.

**Le flow** :

1. Tauri tourne dans le container Docker.
2. Le container est configuré pour accéder au serveur X11 de WSLg (via `/tmp/.X11-unix` et `/mnt/wslg`).
3. Quand Tauri crée une fenêtre GTK, elle est envoyée au serveur X11.
4. WSLg affiche la fenêtre sur ton écran Windows.

**Variables d'environnement clés** :

- `DISPLAY` : indique au container où se trouve le serveur X11.
- `WAYLAND_DISPLAY` : support Wayland (alternative à X11).
- `XDG_RUNTIME_DIR` : dossier runtime pour les sockets.
- `PULSE_SERVER` : pour le son (bonus).

Tout est configuré automatiquement dans `docker-compose.yml`, donc tu n'as rien à faire manuellement !
