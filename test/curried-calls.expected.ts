const s = (n: number): number => n + 1;

interface Nil {
  readonly tag: "Nil";
}

interface Cons<A> {
  readonly tag: "Cons";
  readonly arg0: A;
  readonly arg1: List<A>;
}

type List<A> = Nil | Cons<A>;

const nil: Nil = { tag: "Nil" };

const cons = <A>(arg0: A, arg1: List<A>): List<A> => ({
  arg0,
  arg1,
  tag: "Cons",
});

const length = <A>(l: List<A>): number => {
  let depth = 0;
  let l0 = l;

  for (;;) {
    let returned0: number;

    switch (l0.tag) {
      case "Nil": {
        returned0 = 0;
        break;
      }

      case "Cons": {
        depth += 1;
        l0 = l0.arg1;
        continue;
      }

      default: {
        returned0 = l0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned0;
      }

      depth -= 1;
      returned0 = s(returned0);
    }
  }
};

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

const mul: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n * m;

export const staged = (n: number): ((_: number) => number) => {
  const t: number = mul(n, n);

  return (m: number): number => add(t, m);
};

const stagedProduct = (n: number, p: number): ((_: number) => number) => {
  const t: number = mul(n, p);

  return (m: number): number => add(t, m);
};

const stagedSum = (n: number): ((_: number) => (_: number) => number) => {
  const t: number = mul(n, n);

  return (m: number) =>
    (k: number): number =>
      add(add(t, m), k);
};

const stagedLength = <A>(n: number): ((_: List<A>) => number) => {
  const t: number = mul(n, n);

  return (l: List<A>): number => add(t, length(l));
};

const stagedApply = (n: number): ((_: (_: number) => number) => number) => {
  const t: number = mul(n, n);

  return (f: (_: number) => number): number => f(t);
};

const triple = (n: number): number => mul(n, s(s(s(0))));
const sum = (x: number, x0: number): number => add(x, x0);
const five = (): number => s(s(s(s(s(0)))));
const base: number = s(s(0));
const morningTemperatureReadingInTenths: number = s(s(s(s(0))));
export const initialiser: number = staged(triple(base))(base);

export const longInitialiser: number = staged(
  triple(
    sum(morningTemperatureReadingInTenths, morningTemperatureReadingInTenths)
  )
)(triple(morningTemperatureReadingInTenths));

export const returned = (n: number, m: number): number => staged(triple(n))(m);

export const longReturned = (
  firstMeasurementOfTheDay: number,
  secondMeasurementOfTheDay: number
): number =>
  staged(triple(firstMeasurementOfTheDay))(secondMeasurementOfTheDay);

export const longestReturned = (
  firstMeasurementOfTheDayInTenthsOfADegreeAtTheWeatherStation: number,
  secondMeasurement: number
): number =>
  staged(triple(firstMeasurementOfTheDayInTenthsOfADegreeAtTheWeatherStation))(
    secondMeasurement
  );

export const brokenReturned = (
  firstMeasurementOfTheDayInTenthsOfADegreeAtTheWeatherStationOne: number,
  secondMeasurement: number
): number =>
  staged(
    triple(firstMeasurementOfTheDayInTenthsOfADegreeAtTheWeatherStationOne)
  )(secondMeasurement);

export const inBlock = (n: number, m: number): number => {
  const k: number = add(n, m);

  return staged(triple(k))(staged(k)(m));
};

export const longInBlock = (
  firstMeasurementOfTheDay: number,
  secondMeasurementOfTheDay: number
): number => {
  const total: number = add(
    firstMeasurementOfTheDay,
    secondMeasurementOfTheDay
  );

  return staged(triple(total))(staged(total)(secondMeasurementOfTheDay));
};

export const nested = (n: number, m: number): number =>
  sum(staged(triple(n))(m), n);

export const longNested = (
  firstMeasurementOfTheDay: number,
  secondMeasurementOfTheDay: number
): number =>
  sum(
    staged(triple(firstMeasurementOfTheDay))(secondMeasurementOfTheDay),
    firstMeasurementOfTheDay
  );

export const withTypeArguments = (n: number): number =>
  stagedLength<number>(triple(n))(cons(n, nil));

export const longWithTypeArguments = (
  firstMeasurementOfTheDayInTenths: number
): number =>
  stagedLength<number>(triple(firstMeasurementOfTheDayInTenths))(
    cons(firstMeasurementOfTheDayInTenths, nil)
  );

export const withArrow = (n: number): number =>
  stagedApply(triple(n))((z: number): number => add(z, n));

export const longWithArrow = (
  firstMeasurementOfTheDayInTenths: number
): number =>
  stagedApply(triple(firstMeasurementOfTheDayInTenths))((z: number): number =>
    add(z, firstMeasurementOfTheDayInTenths)
  );

export const threeLinks = (n: number, m: number): number =>
  stagedSum(triple(n))(m)(n);

export const longThreeLinks = (
  firstMeasurementOfTheDay: number,
  secondMeasurementOfTheDay: number
): number =>
  stagedSum(triple(firstMeasurementOfTheDay))(secondMeasurementOfTheDay)(
    firstMeasurementOfTheDay
  );

export const wideCallee = (n: number, m: number): number =>
  stagedProduct(triple(n), m)(n);

export const longWideCallee = (
  firstMeasurementOfTheDay: number,
  secondMeasurementOfTheDay: number
): number =>
  stagedProduct(
    triple(firstMeasurementOfTheDay),
    secondMeasurementOfTheDay
  )(firstMeasurementOfTheDay);

export const nullary = (m: number): number => staged(five())(m);

export const longNullary = (
  secondMeasurementOfTheDayInTenthsOfADegree: number
): number => staged(five())(secondMeasurementOfTheDayInTenthsOfADegree);

export interface Staging {
  readonly staged: (_0: number) => (_: number) => number;
  readonly triple: (_0: number) => number;
}

export interface ThroughResult {
  readonly member: (n: number, m: number) => number;
  readonly longMember: (
    firstMeasurementOfTheDay: number,
    secondMeasurementOfTheDay: number
  ) => number;
  readonly longestMember: (
    firstMeasurementOfTheDayInTenthsOfADegreeAtTheWeatherStation: number,
    secondMeasurement: number
  ) => number;
}

export const Through = (X: Staging): ThroughResult => {
  const member = (n: number, m: number): number => X.staged(X.triple(n))(m);

  const longMember = (
    firstMeasurementOfTheDay: number,
    secondMeasurementOfTheDay: number
  ): number =>
    X.staged(X.triple(firstMeasurementOfTheDay))(secondMeasurementOfTheDay);

  const longestMember = (
    firstMeasurementOfTheDayInTenthsOfADegreeAtTheWeatherStation: number,
    secondMeasurement: number
  ): number =>
    X.staged(
      X.triple(firstMeasurementOfTheDayInTenthsOfADegreeAtTheWeatherStation)
    )(secondMeasurement);

  return { longMember, longestMember, member };
};
