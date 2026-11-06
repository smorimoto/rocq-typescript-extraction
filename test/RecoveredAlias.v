From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Module Payloads.
  Inductive item_value := Missing | Item (value : nat).
  Definition item := item_value.
  Definition witness : item := Item 11.

  Inductive choice := Primary | Secondary.
  Definition payload (c : choice) : Type :=
    match c with Primary => item | Secondary => bool end.
End Payloads.

Module Type PAYLOAD.
  Parameter item : Type.
  Parameter witness : item.
End PAYLOAD.

Module Type CONTAINER.
  Declare Module Alias : PAYLOAD.
End CONTAINER.

Module Read (C : CONTAINER).
  Definition get : C.Alias.item := C.Alias.witness.
End Read.

Module Container.
  Module Alias := Payloads.

  (* Kernel reconstruction retains the source alias even though MiniML
     references have already been resolved. *)
  Definition choose (b : bool) : if b then Alias.item else bool :=
    match b return if b then Alias.item else bool with
    | true => Alias.Item 7
    | false => false
    end.

  Definition select (c : Alias.choice) : Alias.payload c :=
    match c return Alias.payload c with
    | Alias.Primary => Alias.Item 7
    | Alias.Secondary => false
    end.
End Container.

(* Substituting a nested module parameter introduces the alias again
   after the structure's initial alias resolution. *)
Module Applied := Read Container.

TypeScript Extraction "recovered-alias.ts" Container.choose Container.select Read Applied.
