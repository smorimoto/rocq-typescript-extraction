const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

const andb: (_0: boolean, _1: boolean) => boolean = (
  a: boolean,
  b: boolean
): boolean => a && b;

const negb: (_0: boolean) => boolean = (b: boolean): boolean => !b;
const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export type Payload<B extends boolean> = B extends true ? number : boolean;

export const weigh = <B extends boolean>(b: B, x: Payload<B>): number => {
  if (b) {
    return __magic<Payload<B>, number>(x);
  }

  return __magic<Payload<B>, boolean>(x) ? s(0) : 0;
};

export interface Packet0<B extends boolean> {
  readonly tag: "Packet";
  readonly b: B;
  readonly x: Payload<B>;
}

export type Packet = Packet0<true> | Packet0<false>;

export const packet = <B extends boolean>(b: B, x: Payload<B>): Packet0<B> => ({
  b,
  tag: "Packet",
  x,
});

export const weight = (p: Packet): number => weigh(p.b, p.x);
export const small: Packet = packet(true, s(s(s(0))));

export const dep = <B extends boolean>(
  b: B
): B extends true ? number : boolean =>
  b
    ? __magic<number, B extends true ? number : boolean>(0)
    : __magic<boolean, B extends true ? number : boolean>(false);

export const zero: number = dep(true);
export const one: number = s(dep(true));
export const flip = (b: boolean): boolean => negb(andb(dep(false), b));

export const twice = <B extends boolean>(
  b: B
): readonly [
  B extends true ? number : boolean,
  B extends true ? number : boolean,
] => pair(dep(b), dep(b));

export type Dep4<B extends boolean> = B extends true
  ? (_: number) => number
  : (_: number) => boolean;

export const fn = <B extends boolean>(b: B): Dep4<B> =>
  b
    ? __magic<(_: number) => number, Dep4<B>>((n: number): number => n)
    : __magic<(_: number) => boolean, Dep4<B>>(
        (_unused: number): boolean => true
      );

export const applied: number = fn(true)(s(s(s(s(0)))));
export const heavy: number = add(weigh(true, s(s(s(0)))), weigh(false, true));
