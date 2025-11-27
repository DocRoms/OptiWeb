FROM rust:latest

# Installer Node.js 20 (LTS stable, plus léger que 24)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Installer les dépendances Tauri minimales (Debian Trixie utilise webkit2gtk-4.1)
RUN apt-get update && apt-get install -y \
    libwebkit2gtk-4.1-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    && rm -rf /var/lib/apt/lists/*

# S'assurer que cargo est dans le PATH pour les shells non-login
ENV PATH="/usr/local/cargo/bin:${PATH}"

# Installer tauri-cli pour pouvoir utiliser `cargo tauri dev`
RUN cargo install tauri-cli --locked

WORKDIR /app

# Copier et installer les dépendances
COPY package.json ./
RUN npm install

COPY . .

CMD ["bash"]
