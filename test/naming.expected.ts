export interface True {
  readonly tag: "True";
}

export interface False {
  readonly tag: "False";
}

export type Bool = True | False;

export const true0: True = { tag: "True" };
export const false0: False = { tag: "False" };

export interface O {
  readonly tag: "O";
}

export interface S {
  readonly tag: "S";
  readonly arg0: Nat;
}

export type Nat = O | S;

export const o: O = { tag: "O" };
export const s = (arg0: Nat): Nat => ({ arg0, tag: "S" });

const add = (n: Nat, m: Nat): Nat => {
  let depth0 = 0;
  let n0 = n;

  for (;;) {
    let returned: Nat;

    switch (n0.tag) {
      case "O": {
        returned = m;
        break;
      }

      case "S": {
        depth0 += 1;
        n0 = n0.arg0;
        continue;
      }

      default: {
        returned = n0 satisfies never;
      }
    }

    for (;;) {
      if (depth0 === 0) {
        return returned;
      }

      depth0 -= 1;
      returned = s(returned);
    }
  }
};

export interface New {
  readonly tag: "New";
}

export interface Old {
  readonly tag: "Old";
}

export type Word = New | Old;

export const new0: New = { tag: "New" };
export const old: Old = { tag: "Old" };
export const s0 = (n: Nat): Nat => s(n);
export const fooBar: Nat = s(o);
export const fooBar0: Nat = s(s(o));

export interface Cfg {
  readonly tag: "Cfg";
  readonly arg0: Nat;
  readonly arg1: Nat;
}

export type OptionCfg = Cfg;

export const cfg = (arg0: Nat, arg1: Nat): Cfg => ({ arg0, arg1, tag: "Cfg" });
export const depth = (c: OptionCfg): Nat => c.arg1;

export interface Tagged0 {
  readonly tag: "Tagged";
  readonly arg0: Nat;
  readonly arg1: Nat;
}

export type Tagged = Tagged0;

export const tagged = (arg0: Nat, arg1: Nat): Tagged0 => ({
  arg0,
  arg1,
  tag: "Tagged",
});

export const untag = (t: Tagged): Nat => t.arg1;

export interface MkA {
  readonly tag: "MkA";
}

export interface MkB {
  readonly tag: "MkB";
}

export type A = MkA | MkB;

export const mkA: MkA = { tag: "MkA" };
export const mkB: MkB = { tag: "MkB" };

export interface Box0<A0> {
  readonly tag: "Box";
  readonly contents: A0;
  readonly other: A;
}

export type Box<A0> = Box0<A0>;

export const box = <A0>(contents: A0, other: A): Box0<A0> => ({
  contents,
  other,
  tag: "Box",
});

export const unbox = <B>(b: Box<B>): B => b.contents;

const Word0$flip = (w: Word): Word => {
  switch (w.tag) {
    case "New": {
      return old;
    }

    case "Old": {
      return new0;
    }

    default: {
      return w satisfies never;
    }
  }
};

export const Word0 = {
  flip: Word0$flip,
} as const;

export const primed = (nʹ: Nat): Nat => add(nʹ, s0(nʹ));

export interface Klass0 {
  readonly tag: "Klass";
  readonly arg0: Nat;
  readonly arg1: Nat;
}

export type Klass = Klass0;

export const klass = (arg0: Nat, arg1: Nat): Klass0 => ({
  arg0,
  arg1,
  tag: "Klass",
});

export const klassSize = (k: Klass): Nat => k.arg1;
export const twice = (o0: Nat): Nat => add(o0, o0);
export const accent = (né: Nat): Nat => add(né, s(o));

export interface TipRound {
  readonly tag: "Round";
}

export interface TipPointed {
  readonly tag: "Pointed";
}

export type TipKind = TipRound | TipPointed;

const Tip$round: TipRound = { tag: "Round" };
const Tip$pointed: TipPointed = { tag: "Pointed" };

const Tip$kindRect = <B>(round: B, pointed: B, k: TipKind): B => {
  switch (k.tag) {
    case "Round": {
      return round;
    }

    case "Pointed": {
      return pointed;
    }

    default: {
      return k satisfies never;
    }
  }
};

const Tip$kindRec = <B>(round: B, pointed: B, k: TipKind): B => {
  switch (k.tag) {
    case "Round": {
      return round;
    }

    case "Pointed": {
      return pointed;
    }

    default: {
      return k satisfies never;
    }
  }
};

export const Tip = {
  kindRec: Tip$kindRec,
  kindRect: Tip$kindRect,
  pointed: Tip$pointed,
  round: Tip$round,
} as const;

export type TipKind0 = TipKind;

export interface OuterUp {
  readonly tag: "Up";
}

export interface OuterDown {
  readonly tag: "Down";
}

export type OuterT = OuterUp | OuterDown;

const Outer$up: OuterUp = { tag: "Up" };
const Outer$down: OuterDown = { tag: "Down" };

const Outer$tRect = <B>(up: B, down: B, t: OuterT): B => {
  switch (t.tag) {
    case "Up": {
      return up;
    }

    case "Down": {
      return down;
    }

    default: {
      return t satisfies never;
    }
  }
};

const Outer$tRec = <B>(up: B, down: B, t: OuterT): B => {
  switch (t.tag) {
    case "Up": {
      return up;
    }

    case "Down": {
      return down;
    }

    default: {
      return t satisfies never;
    }
  }
};

export interface OuterOuterLeft {
  readonly tag: "Left";
}

export interface OuterOuterRight {
  readonly tag: "Right";
}

export type OuterOuterU = OuterOuterLeft | OuterOuterRight;

const Outer$Outer$left: OuterOuterLeft = { tag: "Left" };
const Outer$Outer$right: OuterOuterRight = { tag: "Right" };

const Outer$Outer$uRect = <B>(left: B, right: B, u: OuterOuterU): B => {
  switch (u.tag) {
    case "Left": {
      return left;
    }

    case "Right": {
      return right;
    }

    default: {
      return u satisfies never;
    }
  }
};

const Outer$Outer$uRec = <B>(left: B, right: B, u: OuterOuterU): B => {
  switch (u.tag) {
    case "Left": {
      return left;
    }

    case "Right": {
      return right;
    }

    default: {
      return u satisfies never;
    }
  }
};

const Outer$Outer$flip = (x2: OuterOuterU): OuterOuterU => {
  switch (x2.tag) {
    case "Left": {
      return Outer$Outer$right;
    }

    case "Right": {
      return Outer$Outer$left;
    }

    default: {
      return x2 satisfies never;
    }
  }
};

export interface OuterTipSmall {
  readonly tag: "Small";
}

export interface OuterTipLarge {
  readonly tag: "Large";
}

export type OuterTipSize = OuterTipSmall | OuterTipLarge;

const Outer$Tip$small: OuterTipSmall = { tag: "Small" };
const Outer$Tip$large: OuterTipLarge = { tag: "Large" };

const Outer$Tip$sizeRect = <B>(small: B, large: B, s1: OuterTipSize): B => {
  switch (s1.tag) {
    case "Small": {
      return small;
    }

    case "Large": {
      return large;
    }

    default: {
      return s1 satisfies never;
    }
  }
};

const Outer$Tip$sizeRec = <B>(small: B, large: B, s1: OuterTipSize): B => {
  switch (s1.tag) {
    case "Small": {
      return small;
    }

    case "Large": {
      return large;
    }

    default: {
      return s1 satisfies never;
    }
  }
};

export interface OuterPiece0 {
  readonly tag: "Piece";
  readonly kind: TipKind;
  readonly size: OuterTipSize;
}

export type OuterPiece = OuterPiece0;

const Outer$piece = (kind: TipKind, size: OuterTipSize): OuterPiece0 => ({
  kind,
  size,
  tag: "Piece",
});

const Outer$pieceRect = <B>(
  piece: (_: TipKind) => (_: OuterTipSize) => B,
  p: OuterPiece
): B => piece(p.kind)(p.size);

const Outer$pieceRec = <B>(
  piece: (_: TipKind) => (_: OuterTipSize) => B,
  p: OuterPiece
): B => piece(p.kind)(p.size);

const Outer$swap = (x2: OuterT): OuterT => {
  switch (x2.tag) {
    case "Up": {
      return Outer$down;
    }

    case "Down": {
      return Outer$up;
    }

    default: {
      return x2 satisfies never;
    }
  }
};

const Outer$bigRound: OuterPiece = Outer$piece(Tip$round, Outer$Tip$large);

export const Outer = {
  Outer: {
    flip: Outer$Outer$flip,
    left: Outer$Outer$left,
    right: Outer$Outer$right,
    uRec: Outer$Outer$uRec,
    uRect: Outer$Outer$uRect,
  },
  Tip: {
    large: Outer$Tip$large,
    sizeRec: Outer$Tip$sizeRec,
    sizeRect: Outer$Tip$sizeRect,
    small: Outer$Tip$small,
  },
  bigRound: Outer$bigRound,
  down: Outer$down,
  piece: Outer$piece,
  pieceRec: Outer$pieceRec,
  pieceRect: Outer$pieceRect,
  swap: Outer$swap,
  tRec: Outer$tRec,
  tRect: Outer$tRect,
  up: Outer$up,
} as const;

export const _1: Nat = o;
export const x1: Nat = s(o);
export const y_00bd: Nat = s(s(o));

export interface Indexed0 {
  readonly tag: "Indexed";
  readonly _2: Nat;
  readonly x2: Nat;
}

export type Indexed = Indexed0;

export const indexed = (_2: Nat, x2: Nat): Indexed0 => ({
  _2,
  tag: "Indexed",
  x2,
});

export const pick = (_3: Nat, x3: Nat): Nat => add(x3, _3);
export const map = (n: Nat): Nat => add(n, n);

export type Date0 = Nat;

export const set0 = (d: Nat): Nat => s(d);

export interface Ok {
  readonly tag: "Ok";
  readonly n: Nat;
}

export interface Error0 {
  readonly tag: "Error";
}

export type Outcome = Ok | Error0;

export const ok = (n: Nat): Outcome => ({ n, tag: "Ok" });
export const error: Error0 = { tag: "Error" };

export interface Then {
  readonly tag: "Then";
}

export interface Else {
  readonly tag: "Else";
}

export type Branch = Then | Else;

export const then0: Then = { tag: "Then" };
export const else0: Else = { tag: "Else" };

export interface X {
  readonly tag: "X";
}

export interface Y {
  readonly tag: "Y";
}

export type Axis = X | Y;

export const x0: X = { tag: "X" };
export const y: Y = { tag: "Y" };

const isX = (ax: Axis): Bool => {
  switch (ax.tag) {
    case "X": {
      return true0;
    }

    case "Y": {
      return false0;
    }

    default: {
      return ax satisfies never;
    }
  }
};

export const horizontal: Bool = isX(x0);
export const still = (x2: Nat): Nat => ((x: Nat): Nat => x)(x2);
