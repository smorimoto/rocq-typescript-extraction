const add: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => BigInt.asUintN(63, x + y);

const mul: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => BigInt.asUintN(63, x * y);

const eqb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => x === y;

const opp: (_0: number) => number = (x: number): number => -x;

const div: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x / y;

const length: (_0: string) => bigint = (s: string): bigint => BigInt(s.length);

const cat: (_0: string, _1: string) => string = (
  s1: string,
  s2: string
): string => (s1 + s2).slice(0, 16_777_211);

export const answer = 42n;
export const maxInt = 9_223_372_036_854_775_807n;
export const sum = (x0: bigint, x1: bigint): bigint => add(x0, x1);
export const square = (x0: bigint): bigint => mul(x0, x0);
export const isAnswer = (x0: bigint): boolean => eqb(x0, answer);

export const describe = (x0: bigint): string =>
  isAnswer(x0) ? "the answer" : "a number";

export const greeting = "h\u00C3\u00A9llo, ";
export const greet = (name: string): string => cat(greeting, name);
export const greetLength = (name: string): bigint => length(greet(name));
export const half = 0.5;
export const third: number = div(1, 3);
export const minusZero: number = opp(0);

interface X {
  readonly tag: "X";
}

interface Y {
  readonly tag: "Y";
}

type Axis = X | Y;

const x: X = { tag: "X" };

const isX = (a: Axis): boolean => {
  switch (a.tag) {
    case "X": {
      return true;
    }

    case "Y": {
      return false;
    }

    default: {
      return a satisfies never;
    }
  }
};

export const horizontal: boolean = isX(x);
