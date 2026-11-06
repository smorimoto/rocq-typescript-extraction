const __lazy = <T>(force: () => T): (() => T) => {
  let cell: { readonly value: T } | undefined;

  return () => {
    if (cell === undefined) {
      cell = { value: force() };
    }

    return cell.value;
  };
};

export type INPUT = Record<never, never>;

export interface MakeBufCons<Token> {
  readonly tag: "BufCons";
  readonly bufHead: Token;
  readonly bufTail: MakeBuffer<Token>;
}

export type MakeBuffer<Token> = () => MakeBufCons<Token>;

export interface MakeResult<Token> {
  readonly bufCons: (
    bufHead0: Token,
    bufTail0: MakeBuffer<Token>
  ) => MakeBufCons<Token>;
  readonly bufHead: (b: MakeBuffer<Token>) => Token;
  readonly bufTail: (b: MakeBuffer<Token>) => MakeBuffer<Token>;
}

export const Make = <Token>(_I: INPUT): MakeResult<Token> => {
  const bufCons = (
    bufHead0: Token,
    bufTail0: MakeBuffer<Token>
  ): MakeBufCons<Token> => ({
    bufHead: bufHead0,
    bufTail: bufTail0,
    tag: "BufCons",
  });

  const bufHead = (b: MakeBuffer<Token>): Token => b().bufHead;
  const bufTail = (b: MakeBuffer<Token>): MakeBuffer<Token> => b().bufTail;

  return { bufCons, bufHead, bufTail };
};

export interface UseInterBufCons<Token> {
  readonly tag: "BufCons";
  readonly bufHead: Token;
  readonly bufTail: UseInterBuffer<Token>;
}

export type UseInterBuffer<Token> = () => UseInterBufCons<Token>;

interface UseInter<Token> {
  readonly bufCons: (
    bufHead: Token,
    bufTail: UseInterBuffer<Token>
  ) => UseInterBufCons<Token>;
  readonly bufHead: (_0: UseInterBuffer<Token>) => Token;
  readonly bufTail: (_0: UseInterBuffer<Token>) => UseInterBuffer<Token>;
}

export interface UseResult<Token> {
  readonly prepend: (
    head0: Token,
    tail: UseInterBuffer<Token>
  ) => UseInterBuffer<Token>;
  readonly head: (x: UseInterBuffer<Token>) => Token;
}

const Use =
  <Token>(_I: INPUT) =>
  (Inter: UseInter<Token>): UseResult<Token> => {
    const prepend = (
      head0: Token,
      tail: UseInterBuffer<Token>
    ): UseInterBuffer<Token> =>
      __lazy((): UseInterBufCons<Token> => Inter.bufCons(head0, tail));

    const head = (x: UseInterBuffer<Token>): Token => Inter.bufHead(x);

    return { head, prepend };
  };

export type DriverInterBufCons<Token> = MakeBufCons<Token>;

export type DriverInterBuffer<Token> = MakeBuffer<Token>;

export interface DriverResult<Token> {
  readonly Inter: MakeResult<Token>;
  readonly Consumer: UseResult<Token>;
}

export const Driver = <Token>(I: INPUT): DriverResult<Token> => {
  const Inter = Make<Token>(I);
  const Consumer = Use<Token>(I)(Inter);

  return { Consumer, Inter };
};
