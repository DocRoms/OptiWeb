import { describe, it, expect } from 'vitest';
import { addTs } from '../src/main';

describe('addTs', () => {
  it('additionne deux entiers', () => {
    expect(addTs(2, 3)).toBe(5);
    expect(addTs(-1, 1)).toBe(0);
  });
});

