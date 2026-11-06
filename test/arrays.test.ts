import { expect, test } from "bun:test";

import {
  bumped,
  copy,
  default0,
  digits,
  get0,
  length,
  make,
  set0,
} from "./arrays.ts";

test("set returns a new array and leaves the original as it was", () => {
  expect(bumped).toMatchInlineSnapshot(`
    {
      "default": 0n,
      "items": [
        1n,
        9n,
        3n,
      ],
    }
  `);
  expect(digits).toMatchInlineSnapshot(`
    {
      "default": 0n,
      "items": [
        1n,
        2n,
        3n,
      ],
    }
  `);
  expect(set0(digits, 3n, 9n)).toBe(digits);
  expect(set0(digits, 2n ** 63n - 1n, 9n)).toBe(digits);
  expect(get0(set0(digits, 1n, 9n), 1n)).toBe(9n);
  expect(get0(digits, 1n)).toBe(2n);

  const twoFives = make(2n, 5n);
  expect(get0(set0(twoFives, 0n, 6n), 0n)).toBe(6n);
  expect(get0(set0(twoFives, 0n, 6n), 1n)).toBe(5n);
  expect(get0(set0(twoFives, 2n, 6n), 1n)).toBe(5n);
  expect(twoFives).toMatchInlineSnapshot(`
    {
      "default": 5n,
      "items": [
        5n,
        5n,
      ],
    }
  `);
});

test("copy is the array itself, which nothing changes", () => {
  expect(copy(digits)).toBe(digits);
  expect(length(copy(digits))).toBe(3n);
  expect(default0(copy(digits))).toBe(0n);
});

test("make shares the default value but allocates independent persistent arrays", () => {
  const value = { count: 7 };
  const first = make(3n, value);
  const second = make(3n, value);
  expect(first.items).not.toBe(second.items);
  expect(default0(first)).toBe(value);

  for (const item of first.items) {
    expect(item).toBe(value);
  }

  const replacement = { count: 9 };
  const updated = set0(first, 1n, replacement);
  expect(get0(updated, 1n)).toBe(replacement);
  expect(get0(first, 1n)).toBe(value);
  expect(get0(second, 1n)).toBe(value);
});

test("stored undefined is distinct from a nonundefined default", () => {
  const original = make<string | undefined>(3n, "default");
  const updated = set0(original, 1n, undefined);
  expect(get0(updated, 0n)).toBe("default");
  expect(get0(updated, 1n)).toBeUndefined();
  expect(get0(updated, 2n)).toBe("default");
  expect(get0(updated, 3n)).toBe("default");
  expect(get0(copy(updated), 1n)).toBeUndefined();
  expect(default0(updated)).toBe("default");
  expect(get0(original, 1n)).toBe("default");
});
