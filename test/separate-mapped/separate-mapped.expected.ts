import * as $Spans from "./spans.ts";

const { matchSpan, matchWrapped, span, wrap } = $Spans;
export const clamp = (b: $Spans.Bounds): $Spans.Bounds => span(b);

export const low = (r: $Spans.Bounds): number =>
  matchSpan((b: $Spans.Bounds): number => b.lo, r);

export const wrapLow = (r: $Spans.Bounds): $Spans.Cell<number> => wrap(low(r));

export const unwrap = <A>(w: $Spans.Cell<A>): A =>
  matchWrapped((x: A): A => x, w);
