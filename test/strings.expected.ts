export const maxLength = 16_777_211n;

export const make: (_0: bigint, _1: bigint) => string = (
  i: bigint,
  c: bigint
): string => {
  const byte = String.fromCharCode(Number(c % 256n));

  return byte.repeat(Math.min(Number(i), 16_777_211));
};

export const length: (_0: string) => bigint = (s: string): bigint =>
  BigInt(s.length);

export const get0: (_0: string, _1: bigint) => bigint = (
  s: string,
  i: bigint
): bigint => BigInt(s.charCodeAt(Number(i)) || 0);

export const sub: (_0: string, _1: bigint, _2: bigint) => string = (
  s: string,
  off: bigint,
  len: bigint
): string => s.slice(Number(off), Number(off) + Number(len));

export const cat: (_0: string, _1: string) => string = (
  s1: string,
  s2: string
): string => (s1 + s2).slice(0, 16_777_211);

export const compare: (_0: string, _1: string) => "Eq" | "Lt" | "Gt" = (
  s1: string,
  s2: string
): "Eq" | "Lt" | "Gt" => {
  if (s1 < s2) {
    return "Lt";
  }

  if (s1 > s2) {
    return "Gt";
  }

  return "Eq";
};

export const eqb = (s1: string, s2: string): boolean => {
  const s: "Eq" | "Lt" | "Gt" = compare(s1, s2);

  switch (s) {
    case "Eq": {
      return true;
    }

    default: {
      return false;
    }
  }
};

export const latin = "h\u00C3\u00A9llo";
