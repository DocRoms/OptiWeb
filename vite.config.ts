import { defineConfig } from 'vite';
import { resolve } from 'path';

// Configuration Vite pour un projet HTML/CSS/TS sans framework, avec root dans src
export default defineConfig({
  root: 'src',
  build: {
    outDir: '../dist',
    rollupOptions: {
      input: resolve(__dirname, 'src/index.html'),
    },
  },
  server: {
    host: '0.0.0.0',
    port: 5173,
  },
  test: {
    root: __dirname,
    globals: true,
    environment: 'jsdom',
    include: ['tests/**/*.spec.ts'],
  },
});
