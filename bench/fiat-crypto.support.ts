import type { List } from "./fiat-crypto/extracted/fields.ts";
import {
  cons,
  curve25519Carry,
  curve25519Mul,
  curve25519Square,
  nil,
  poly1305Carry,
  poly1305Mul,
  poly1305Square,
} from "./fiat-crypto/extracted/fields.ts";

export const fields = [
  {
    carry: curve25519Carry,
    limbBits: 51n,
    modulus: 2n ** 255n - 19n,
    mul: curve25519Mul,
    name: "Curve25519 (5 x 51 bits)",
    square: curve25519Square,
  },
  {
    carry: poly1305Carry,
    limbBits: 26n,
    modulus: 2n ** 130n - 5n,
    mul: poly1305Mul,
    name: "Poly1305 (5 x 26 bits)",
    square: poly1305Square,
  },
];

export type Field = (typeof fields)[number];

export const ofArray = (limbs: readonly bigint[]): List<bigint> => {
  let result: List<bigint> = nil;

  for (const limb of limbs.toReversed()) {
    result = cons(limb, result);
  }

  return result;
};

export const toArray = (limbs: List<bigint>): bigint[] => {
  const result: bigint[] = [];
  let rest = limbs;

  while (rest.tag === "Cons") {
    result.push(rest.arg0);
    rest = rest.arg1;
  }

  return result;
};

export const encode = (field: Field, value: bigint): List<bigint> => {
  const radix = 2n ** field.limbBits;

  return ofArray(
    Array.from({ length: 5 }, (_, i) => (value / radix ** BigInt(i)) % radix)
  );
};

export const decode = (field: Field, limbs: List<bigint>): bigint =>
  toArray(limbs)
    .toReversed()
    .reduce((value, limb) => value * 2n ** field.limbBits + limb, 0n);

export const checkResults = (
  field: Field,
  actual: readonly List<bigint>[],
  expected: readonly bigint[]
): void => {
  if (actual.length !== expected.length) {
    throw new Error(`${field.name}: wrong result count`);
  }

  for (const [i, result] of actual.entries()) {
    const limbs = toArray(result);

    if (
      limbs.length !== 5 ||
      limbs.some((limb) => limb < 0n || limb >= 2n ** field.limbBits) ||
      decode(field, result) % field.modulus !== expected[i]
    ) {
      throw new Error(`${field.name}: incorrect result at input ${i}`);
    }
  }
};

export const values = (field: Field): bigint[] => {
  const radix = 2n ** field.limbBits;

  const result = [
    0n,
    1n,
    field.modulus - 1n,
    field.modulus - 2n,
    radix - 1n,
    radix,
    radix + 1n,
    2n ** 53n + 1n,
  ];

  let state = 42n;

  while (result.length < 32) {
    state =
      (state * 6_364_136_223_846_793_005n + 1_442_695_040_888_963_407n) %
      field.modulus;
    result.push(state);
  }

  return result;
};

export const workloads = fields.flatMap((field) => {
  const xs = values(field);
  const inputs = xs.map((x) => encode(field, x));

  const looseInputs = inputs.map((input) =>
    ofArray(toArray(input).map((limb) => limb * 3n))
  );

  const pairs = inputs.map((input, i) => {
    const right = inputs[(i + 1) % inputs.length];

    if (right === undefined) {
      throw new Error("Missing field operand");
    }

    return { left: input, right };
  });

  return [
    {
      expected: xs.map((x, i) => {
        const right = xs[(i + 1) % xs.length];

        if (right === undefined) {
          throw new Error("Missing reference operand");
        }

        return (x * right) % field.modulus;
      }),
      field,
      name: "carry_mulmod",
      run: () => pairs.map(({ left, right }) => field.mul(left, right)),
    },
    {
      expected: xs.map((x) => (x * x) % field.modulus),
      field,
      name: "carry_squaremod",
      run: () => inputs.map((input) => field.square(input)),
    },
    {
      expected: xs.map((x) => (x * 3n) % field.modulus),
      field,
      name: "carrymod",
      run: () => looseInputs.map((input) => field.carry(input)),
    },
  ];
});
