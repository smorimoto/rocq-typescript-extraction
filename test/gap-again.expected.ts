const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export interface PointsAndMore {
  readonly px: number;
  readonly py: number;
}

const corners: (
  _0: readonly [PointsAndMore, PointsAndMore]
) => readonly PointsAndMore[] = <A>(line: readonly [A, A]): readonly A[] => [
  ...line,
];

export interface EndsType {
  readonly left: PointsAndMore;
  readonly right: PointsAndMore;
}

const cornersRecord: (
  _0: readonly [PointsAndMore, PointsAndMore]
) => EndsType = <A>(line: readonly [A, A]) => ({
  left: line[0],
  right: line[1],
});

export const use = (p: PointsAndMore): readonly PointsAndMore[] =>
  corners(pair(p, p));

export const useRecord = (p: PointsAndMore): EndsType =>
  cornersRecord(pair(p, p));
