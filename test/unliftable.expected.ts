const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

const negb: (_0: boolean) => boolean = (b: boolean): boolean => !b;
const s = (n: number): number => n + 1;

export type Payload<B extends boolean> = B extends true ? number : boolean;

export const weighNeg = (b: boolean, x: Payload<boolean>): number => {
  if (negb(b)) {
    return __magic<Payload<boolean>, number>(x);
  }

  return __magic<Payload<boolean>, boolean>(x) ? s(0) : 0;
};

export const inlineNeg = (b: boolean): boolean | number =>
  negb(b) ? s(0) : false;

export const natDep = (n: number): boolean | number => (n === 0 ? 0 : true);
