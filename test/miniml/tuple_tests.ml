open Base
open Stdio

let%expect_test "a tuple reconstructs its element types" =
  print_string (Tuple_cases.declaration "pair");
  [%expect_exact
    {|export const pair = <A, B>(x: A, y: B): readonly [A, B] => [x, y];
|}]
;;

let%expect_test "a tuple pattern binds a computed scrutinee once" =
  print_string (Tuple_cases.declaration "swap");
  [%expect_exact
    {|export const swap = <A, B>(x: A, y: B): readonly [B, A] => {
  const p: readonly [A, B] = [x, y];

  return [p[1], p[0]];
};
|}]
;;

let%expect_test "a tuple pattern reuses an already bound scrutinee" =
  print_string (Tuple_cases.declaration "second");
  [%expect_exact
    {|export const second = <A, B>(x: A, y: B): B => {
  const p: readonly [A, B] = [x, y];

  return p[1];
};
|}]
;;

let%expect_test "nested tuples reconstruct their nested result type" =
  print_string (Tuple_cases.declaration "nested");
  [%expect_exact
    {|export const nested = <A, B, C>(
  x: A,
  y: B,
  z: C
): readonly [A, readonly [B, C]] => [x, [y, z]];
|}]
;;

let%expect_test "a wildcard does not shift the selected tuple element" =
  print_string (Tuple_cases.declaration "wild");
  [%expect_exact
    {|export const wild = <A, B>(x: A, y: B): B => {
  const p: readonly [A, B] = [x, y];

  return p[1];
};
|}]
;;

let%expect_test "a tuple pattern inside a tuple keeps the outer variable" =
  print_string (Tuple_cases.declaration "inside");
  [%expect_exact
    {|export const inside = <A, B>(x: A, y: B): readonly [B, A] => {
  const p: readonly [A, B] = [x, y];

  return [p[1], x];
};
|}]
;;

let%expect_test "a tagged match inside a tuple remains a conditional" =
  print_string (Tuple_cases.declaration "flipped");
  [%expect_exact
    {|export const flipped = <A>(
  signOfTheFirstArgumentWhoseTagTheConditionalTestOfTheTupleReads: Sign,
  x: A
): readonly [Sign, A] => [
  signOfTheFirstArgumentWhoseTagTheConditionalTestOfTheTupleReads.tag ===
  "NegativeOrZero"
    ? positive
    : negativeOrZero,
  x,
];
|}]
;;

let%expect_test "the tagged tuple input exports its constructor types" =
  print_string (Tuple_cases.sign_declaration ());
  [%expect_exact
    {|export interface NegativeOrZero {
  readonly tag: "NegativeOrZero";
}

export interface Positive {
  readonly tag: "Positive";
}

export type Sign = NegativeOrZero | Positive;

export const negativeOrZero: NegativeOrZero = { tag: "NegativeOrZero" };
export const positive: Positive = { tag: "Positive" };
|}]
;;

let%expect_test "the complete module preserves the expected declarations in order" =
  let lines text = String.split_lines text |> List.filter ~f:(Fn.non String.is_empty) in
  let expected =
    Tuple_cases.sign_declaration ()
    :: List.map
         [ "pair"; "swap"; "second"; "nested"; "wild"; "inside"; "flipped" ]
         ~f:Tuple_cases.declaration
    |> String.concat ~sep:"\n"
    |> lines
  in
  let actual = Tuple_cases.source () |> lines in
  if not (List.equal String.equal expected actual)
  then
    print_s
      [%message
        "module declarations differ" (expected : string list) (actual : string list)];
  [%expect {| |}]
;;
