open Import
open Ts_print

let%expect_test "raw code preserves a comment containing an apostrophe" =
  print_string
    (program
       { header = None
       ; imports = []
       ; decls =
           [ { exported = true
             ; decl =
                 Value
                   { name = "quotedComment"
                   ; ty = None
                   ; value = Code "[1, /* don't drop */ 2]"
                   }
             }
           ]
       });
  [%expect_exact "export const quotedComment = [1, /* don't drop */ 2];\n"]
;;

let%expect_test "raw function types are parenthesized in unions and arrays" =
  print_string (Printing_cases.render Printing_cases.function_types);
  [%expect_exact
    {|export type FunctionOrBoolean = ((_: number) => number) | boolean;

export type RawFunctionOrBoolean = ((_: number) => number) | boolean;

export type FunctionArray = readonly ((_: number) => number)[];
|}]
;;

let%expect_test "brackets and arrows in quoted types do not affect precedence" =
  print_string (Printing_cases.render Printing_cases.quoted_type_tokens);
  [%expect_exact
    {|export type QuotedBracketFunctionOrBoolean = ((_: "(") => number) | boolean;

export type QuotedAngleFunctionOrBoolean = ((_: ">") => number) | boolean;

export type ArrowLiteralOrBoolean = "=>" | boolean;
|}]
;;

let%expect_test "raw array element types retain their grouping" =
  print_string (Printing_cases.render Printing_cases.array_types);
  [%expect_exact
    {|export type ConditionalArray = readonly (1 extends 2 ? 3 : 4)[];

export type TupleArray = readonly (readonly [number, number])[];
|}]
;;

let%expect_test "only top-level conditionals need parentheses in unions" =
  print_string (Printing_cases.render Printing_cases.conditional_unions);
  [%expect_exact
    {|export type NestedConditionalOrNumber =
  | Promise<string extends number ? true : false>
  | number;

export type ConditionalOrNumber =
  | (string extends number ? true : false)
  | number;

export type RawConditionalOrNumber =
  | (string extends number ? true : false)
  | number;
|}]
;;

let%expect_test "indexed calls keep empty arguments inline and expand long arguments" =
  print_string
    (Printing_cases.render
       (Printing_cases.indexed_type
        @ Printing_cases.indexed_bindings
        @ Printing_cases.indexed_calls));
  [%expect_exact
    {|type T = readonly unknown[];

const a: readonly [(xs: readonly unknown[]) => T] = [(xs) => xs];
const nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn = 0;
export const x: T = a[0]([]);

export const t: T = a[0]([
  nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn,
]);
|}]
;;

let%expect_test "discarded object literals remain expressions" =
  print_string (Printing_cases.render Printing_cases.discarded_objects);
  [%expect_exact
    {|export const discardRecord = (read: () => number): number => {
  void { value: read() };
  void ({
    value: read(),
  } as const);

  return 0;
};
|}]
;;

let%expect_test "quotes in regular expressions do not start string literals" =
  print_string (Printing_cases.render Printing_cases.quoted_regexp);
  [%expect_exact
    {|export const quotedRegexp = [/"/u, 1];
|}]
;;

let%expect_test "tuple annotations break only when they exceed the line width" =
  print_string (Printing_cases.render Printing_cases.tuple_annotations);
  [%expect_exact
    {|export const pair: readonly [number, number] = [0, 0];

export const all: readonly [
  readonly [readonly [number, number], number],
  number,
] = [[[0, 0], 0], 0];
|}]
;;

let%expect_test "long tuple annotations keep the initializer after the closing bracket" =
  print_string (Printing_cases.render Printing_cases.long_annotation);
  [%expect_exact
    {|const pair0 = <A, B>(p: A, q: B): readonly [A, B] => [p, q];

export const nest: readonly [
  readonly [
    readonly [
      readonly [readonly [readonly [number, number], number], number],
      number,
    ],
    number,
  ],
  number,
] = pair0(pair0(pair0(pair0(pair0(pair0(0, 0), 0), 0), 0), 0), 0);
|}]
;;
