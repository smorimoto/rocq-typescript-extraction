const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export interface SIG<T> {
  readonly z: T;
}

export type MT = number;

const M$z = 0;

const M = {
  z: M$z,
} as const;

export interface GResult {
  readonly z: number;
}

export const G = <T>(_Y: SIG<T>): GResult => M;
export const Id = <T>(Y: SIG<T>): SIG<T> => Y;
export const GS = <T>(_Y: SIG<T>): SIG<number> => M;

export type AT = boolean;

const A$z = true;

const A = {
  z: A$z,
} as const;

export type GAT = MT;

export const GA = G<boolean>(A);

export type IAT = AT;

export const IA = Id<boolean>(A);

export type GSAT = MT;

export const GSA = GS<boolean>(A);
export const both: readonly [number, boolean] = pair(GA.z, IA.z);
