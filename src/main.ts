import { invoke } from '@tauri-apps/api/core';

export function addTs(a: number, b: number): number {
  return a + b;
}

async function setup() {
  const form = document.getElementById('add-form') as HTMLFormElement | null;
  const inputA = document.getElementById('input-a') as HTMLInputElement | null;
  const inputB = document.getElementById('input-b') as HTMLInputElement | null;
  const resultEl = document.getElementById('result');
  const errorEl = document.getElementById('error');

  if (!form || !inputA || !inputB || !resultEl || !errorEl) {
    console.error('Elements manquants dans le DOM');
    return;
  }

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    errorEl.textContent = '';
    resultEl.textContent = '';

    const a = Number.parseInt(inputA.value, 10);
    const b = Number.parseInt(inputB.value, 10);

    if (Number.isNaN(a) || Number.isNaN(b)) {
      errorEl.textContent = 'Veuillez saisir deux entiers valides.';
      return;
    }

    try {
      const sum = await invoke<number>('add', { a, b });
      resultEl.textContent = `Résultat : ${sum}`;
    } catch (err) {
      console.error(err);
      errorEl.textContent = 'Erreur lors de l\'appel à la commande Tauri.';
    }
  });
}

if (typeof window !== 'undefined') {
  window.addEventListener('DOMContentLoaded', () => {
    void setup();
  });
}
