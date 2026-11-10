(** How Rocq names become TypeScript names.

    No other module turns a [global], a module path, a binder, or an
    {!Ts_type.t} into text, or names a declaration or a local.

    Value names are lowerCamelCase. They name terms, constructor functions
    and constants, the {!realisers} of [Extract Inductive], parameters,
    locals, and module object members, so [safe_pred] becomes [safePred]
    and constructor [S] becomes [s].
    Type-level names are PascalCase. They name types, constructor
    interfaces, type variables, and modules, so [nat] becomes [Nat].
    Underscores are dropped, and the letter after an inner one is
    capitalised. File names are kebab-case, so separate extraction writes
    library [ListDef] to [list-def.ts].

    Every name is an ECMAScript identifier. Primes map to U+02B9 and
    subscript digits to ASCII digits, so [x₁] becomes [x1]. Any other
    character that cannot continue an identifier maps to [_] and its code
    point in hex, so [y½] becomes [y_00bd]. A name that would then start
    with a character that cannot start one, such as a digit, keeps a
    leading underscore, so [_1] stays [_1]. No identifier contains [shape]
    in any case, which the no-shape-in-symbol-names rule of Ultracite's
    anti-slop preset rejects and a suffix would keep. Each occurrence
    becomes [form], capitalised as the word was, so [shape_area] becomes
    [formArea], the type [shape] [Form], and the library [Shapes] is
    imported as [$Forms]. A tag is a string, so it keeps the
    constructor's name, as ["Shape"].

    The transform can merge names that Rocq kept apart, so a name that is
    already used gets a numeric suffix, as in [s] and [s0], in structure
    order. Reserved words count as used, and so do, at the top level of a
    file, the names of the helpers' parameters and locals, such as
    [value], and the parameters of the code of every
    [Extract Inlined Constant], such as [x] in
    ["((x: bigint, y: bigint): bigint => x + y)"], which would shadow a
    top-level value of that name where the code is written out. Value
    names are distinct within
    their scope, which is the file or a module, and so are the short names
    of types, and, apart from them, the tags of constructors, so that a
    module and its module type tag a constructor the same whatever the
    order of their inductives. The value names of a module, a module
    type, a functor body, or an application, and the names of the
    modules nested in it, are the keys of its object, and depend on the
    Rocq name alone, so that a module object and the interface of a
    module type it implements hold a member under the same key. A Rocq
    name that the transform leaves as written is its own key, and any
    other takes, in structure order, the first numeric suffix that no
    other key of the extraction has, so [set] beside a member [set0] is
    [set1] in every module and module type, and a constructor [Empty]
    beside a member [empty] is [empty0]. Type names are
    distinct within the file, at whose top level every type is declared,
    so the interface of a constructor named like its type takes the
    suffix, as [Tagged0] for the constructor [Tagged] of [tagged], and
    the tag stays ["Tagged"].

    A reference cannot see into an enclosing module from inside a nested
    one, and module values must exist before the module object does. So a
    value declared in a module gets a flat file-level name that joins the
    module path with [$], such as [M$two] or [M$N$wrap]. No Rocq identifier
    or name derived from one contains [$], so these names cannot collide
    with Rocq-derived ones. A type declared in a module is named after the
    module path and its short name joined in PascalCase, so [Geometry.Circle]
    is [GeometryCircle] and [Geometry.Units.Box] is [GeometryUnitsBox].

    A module alias, [Module M := N], is named as a module is, and declares
    one alias of each type of the module it stands for, named as a type
    declared in [M] would be, so [N.t] is [MT] through [M] and [N.Sub.u] is
    [MSubU]. The values of [N] keep their own names, since every reference
    through [M] is resolved to them.

    A module type is a type, named by its path as a type declared in a
    module is, so [Module Type S] is [S] and [M.S] is [MS], and its members
    are named as a module's are. So is the signature of a parameter
    declared with a module type applied to another parameter, which
    MiniML writes out under the parameter, named after the functor and
    the parameter, as [MakeTacP] for [P : IsTotalOrder O] of [MakeTac].
    A functor signature is a type named the
    same way, with the interface of its result named after it, as
    [FTResult], and the result's members named as a module's are. A
    functor is a value, named as a module
    is, with its types named by its path, as [FWrapped], and the interface
    of its result [FResult]. Its members are locals of its arrow, named
    when the body is printed. An application is a value named as a module
    is, whose types are named by its path, as [BWrapped], those abstract
    in the module type it is sealed with included, and whose
    members are properties of its object. A member of a functor parameter
    is named as the member of its module type, and reached as a property
    of the parameter's object. *)

open Extraction_plugin

(** The type for the names of a structure. *)
type t

(** [keywords] is the set of names that no generated name takes, as a
    value or as a type, so a Rocq name that would become one of them gets a
    numeric suffix, as type [date] becomes [Date0]. It holds, in groups,
    the Keywords section of MDN's Lexical grammar page, which lists the
    reserved words, those reserved in strict mode, modules, or async
    bodies, the future reserved words of current and older standards, and
    the identifiers with special meanings; the names on MDN's Global
    Objects page; the TypeScript keywords and primitive type names; the
    TypeScript utility and global types; the helpers of the output;
    [callback], [cb], and [next], whose calls Oxlint's
    node/callback-return reads as callbacks that must be returned; and
    [then], which unicorn's no-thenable forbids as the key of an object
    and as an exported name. Names are case-sensitive, so [Map] is
    reserved and [map] is not. *)
val keywords : Names.Id.Set.t

(** [create state sigs struc] is the names of every global declared in
    [struc], of every member of a module type of [struc], of every member
    of an application, and of every module, module type, functor, and
    application of [struc], chosen in structure order, so the names are
    deterministic. A global reached through a functor parameter, or
    through a module type defined as another, is named as the global it
    stands for, which {!Ts_sig.canon} gives through [sigs]. Monolithic
    extraction names all files in one scope, and separate extraction gives
    each file its own, as [state] says. The other functions only read the
    names [create] chose. *)
val create : Common.State.t -> Ts_sig.t -> Miniml.ml_structure -> t

(** {1 Identifiers} *)

(** [camel id] is [id] in lowerCamelCase, made an identifier as above. It
    is empty when [id] is only underscores. *)
val camel : Names.Id.t -> string

(** [pascal id] is [id] in PascalCase, made an identifier as above, as a
    module or a functor parameter is named. *)
val pascal : Names.Id.t -> string

(** [is_method s] is [true] if [s] is a name whose call through an object
    a rule of the presets reads as a call of a method of a built-in, as
    {!group_key} keeps off objects. *)
val is_method : string -> bool

(** [is_reserved s] is [true] if [s] is one of {!keywords}. *)
val is_reserved : string -> bool

(** {1 Extraction directives} *)

(** [custom r] is the TypeScript code that [Extract Constant],
    [Extract Inlined Constant], or [Extract Inductive] gives the term or
    constructor [r].

    @raise CErrors.UserError if the code is not {!Ts_print.balanced}. *)
val custom : Miniml.global -> string

(** [custom_match p] is the match function that [Extract Inductive] gives
    packet [p], if it gives one.

    @raise CErrors.UserError if the code is not {!Ts_print.balanced}. *)
val custom_match : Miniml.ml_ind_packet -> string option

(** [realisers p] is the code of [Extract Inductive] for packet [p]
    that is declared once, as a constant, rather than written out at every
    use. It is the code of each constructor with arguments, then the match
    function, keeping only the code that is not {!Ts_print.is_atom}. Each
    comes with the global it realises, the constructor, or the inductive
    type for the match function. The code of a constant constructor is a
    value, which a [const] could not type when the inductive is generic,
    so it is always written out. The realisers of a type declared in the
    body of a functor are declared at the top level of the file, under the
    functor's name, for the body and for every application of the
    functor, whose realisers they are. *)
val realisers : Miniml.ml_ind_packet -> (Miniml.global * string) list

(** {1 Globals} *)

(** [value names r] is how an expression refers to the term or constructor
    [r]. It is the local name for a member of the functor body of
    {!in_body}, or for a member of a parameter that the body binds, and
    [Code s] for an inline custom that {!realisers} does not list. A
    realiser of a type declared in a functor body is the top-level
    constant that declares it, from the body and through an application
    of the functor alike, and so is a member hoisted out of the body of
    {!in_body}, which the body refers to by its top-level name. A
    member of an application of the current file, or of a functor
    parameter, is a property of
    the application's or the parameter's object, as [B.twice] or [X.f],
    through the objects of the modules nested in it, or the local that
    {!bind_methods} binds it to, as [sort]. Any other global of
    the current file is its flat name, such as [add] or [M$two]. For a
    global of another file that {!bindings} binds it is the local name,
    such as [add], and for any other global in a module, or in an
    application, of another file a
    path through the import and its module objects, such as
    [$Datatypes.M.x]. A reference to another file records an import in
    [names]. *)
val value : t -> Miniml.global -> Ts_print.expr

(** [match_function names r code] is how an expression refers to [code],
    the match function that [Extract Inductive] gives the inductive type
    [r]. It is the constant that declares [code], through module and
    import paths as {!value} gives it, when {!realisers} lists [r], or
    the type of a functor body that [r] stands for, and [Code code]
    otherwise. *)
val match_function : t -> Miniml.global -> string -> Ts_print.expr

(** [value_name names r] is the flat binding name that the declaration of
    [r] introduces, such as [add], [s], or [M$two], or its local name in
    the functor body of {!in_body}. The constant that declares the match
    function of a custom inductive [r] is named [match] followed by the
    type's name in PascalCase, as in [matchNat]. *)
val value_name : t -> Miniml.global -> string

(** [group_members rv av] is the globals of [rv], the mutually recursive
    group with bodies [av], that the output declares. They are those whose
    body is not [MLexn "UNUSED"] and that [Extract Constant] does not
    realise. *)
val group_members : Miniml.global array -> Miniml.ml_ast array -> Miniml.global list

(** [group_name names r] is the flat name of the object that declares the
    mutually recursive group whose first {!group_members} member is [r],
    when the group has two such members or more.
    It joins the members' names, as in [evenOdd] for [even] and [odd], or
    [Pos$addAddCarry] in module [Pos], and is a value name of the members'
    scope. *)
val group_name : t -> Miniml.global -> string option

(** [member_name names r] is the short name of the term or constructor
    [r], which is its property in its module object, and the key of its
    Rocq name in every module object and interface. *)
val member_name : t -> Miniml.global -> string

(** [group_key names r] is the property that the object of a mutually
    recursive group holds its member [r] under. It is {!member_name},
    unless that is a name whose call through an object a rule of the
    presets reads as a call of a method of a built-in, such as [map],
    [reduce], or [hasOwnProperty], and then it takes a suffix as the value
    names of the members' scope do, as in [map0]. *)
val group_key : t -> Miniml.global -> string

(** [type_name names r] is the name of the alias or interface
    that the declaration of type [r] introduces at the top level of its
    file. It is the names of the modules around [r] followed by its short
    name, as in [GeometryFigure] for type [figure] of module [Geometry]. *)
val type_name : t -> Miniml.global -> string

(** [type_name_opt names r] is the type name of [r], if [r] has one. *)
val type_name_opt : t -> Miniml.global -> string option

(** [interface_name names c] is the name of the interface that constructor
    [c] declares. It is made from {!tag} as {!type_name} is made from the
    short name of a type. *)
val interface_name : t -> Miniml.global -> string

(** [tag names c] is the tag of constructor [c], the short name that
    {!interface_name} is made from, so constructor [Circle] of module
    [Geometry] is tagged ["Circle"] and its interface is [GeometryCircle].
    It is distinct from the tags of the other constructors of its scope
    and from nothing else. *)
val tag : t -> Miniml.global -> string

(** [interface_ref names c] is how a type refers to the interface of
    constructor [c], through an import path as {!ty} does. *)
val interface_ref : t -> Miniml.global -> string

(** [type_ref names r] is how a type refers to the alias or interface of
    type [r], {!type_name} through an import path as {!ty} does. *)
val type_ref : t -> Miniml.global -> string

(** {1 Modules} *)

(** [module_name names mp] is the name of module [mp]. A top-level module
    gives it to its module object, a nested module to its
    property in its parent's object, and every module to the flat names of
    the values and types it declares. A nested module is named by the key
    of its label, as a value member is. A top-level module avoids the
    value names of its file, where its object is a value, and also the
    type names of the file, which a linter would read as a second
    declaration. An alias is named the same way. *)
val module_name : t -> Names.ModPath.t -> string

(** [module_ref names mp] is how an expression refers to the object of
    module [mp], which is not a file. It is its name for a top-level
    module of the current file, a path through the properties of its
    parents' objects for a nested one, as [N.Sub], and a path through the
    import of its file for a module of another file, as [$Dep.N]. A
    functor or an application of the current file is referred to by its
    flat name, as [M$F], since its value is declared before the object of
    the module around it, and a functor parameter by its local name in
    the body of the functor. A reference to another file records an
    import in [names]. The alias of a module refers to its object this
    way. *)
val module_ref : t -> Names.ModPath.t -> Ts_print.expr

(** [same_file names mp] is [true] if the module [mp] is declared in the
    file being printed, or in any file in monolithic extraction. *)
val same_file : t -> Names.ModPath.t -> bool

(** [flat_name names mp] is the flat binding name of the value of the
    functor or application [mp], or of the object of the nested module
    [mp] when a value declared before the object of the module around it
    reads it, which joins the names of the modules around it and its own
    with [$], as [M$F], and is its name alone at the top level, or in the
    body of a functor for a module nested in the body. In a functor body
    the name avoids a binding already in scope, so a module named like a
    top-level value takes a numeric suffix. *)
val flat_name : t -> Names.ModPath.t -> string

(** [top_name names mp] is the name of the top-level value through which a
    consumer reaches the module [mp]. It is the name of the object of the
    top-level module around [mp], or the name of [mp] itself when it is
    top-level. *)
val top_name : t -> Names.ModPath.t -> string

(** [signature_name names mp] is the name of the interface, or of the type
    alias, that the module type [mp] declares. It is the names of the
    modules around it followed by its own, in PascalCase, as [S] or [MS].
    For a functor [mp], it is the name of the interface of its result, as
    [FResult].

    @raise CErrors.Anomaly if [mp] is neither a module type nor a functor of [names]. *)
val signature_name : t -> Names.ModPath.t -> string

(** [result_name names mp] is the name of the interface of the result of
    the functor signature [mp], whose own name is the alias of its arrow
    type, as [FTResult] for [FT].

    @raise CErrors.Anomaly
      if [mp] is not a functor signature of [names] whose result is a
      signature of its own. *)
val result_name : t -> Names.ModPath.t -> string

(** [signature_ref names mp] is how a type refers to what
    {!signature_name} names, through an import path as {!ty} does when
    [mp] is in another file. A reference to another file records an
    import in [names]. *)
val signature_ref : t -> Names.ModPath.t -> string

(** [result_ref names mp] is how a type refers to what {!result_name}
    names, through an import path as {!signature_ref} does. A reference
    to another file records an import in [names]. *)
val result_ref : t -> Names.ModPath.t -> string

(** The type for the types an alias declares. *)
type aliased =
  { declared : Miniml.global (** The type the alias stands for. *)
  ; under : Miniml.global
    (** The same type named through the alias, as [M.t] for [N.t]. *)
  ; name : string (** The name of the alias, as [MT]. *)
  ; params : Names.Id.t list (** The parameters of the type. *)
  }

(** [alias_types names mp] is the types that the alias [mp] declares, in
    structure order. There is one for each type of the module it stands
    for that has a declaration, through nested modules and aliases.

    @raise CErrors.Anomaly if [mp] is not an alias of [names]. *)
val alias_types : t -> Names.ModPath.t -> aliased list

(** {1 Types} *)

(** The type for the names of the type variables in scope. *)
type tvars

(** [params names n] is the names of [Var i] for [i] in [1..n]. They are
    the first [n] of [A] to [Z], [T27], [T28], and so on that no type in
    [names] is named. Declared types of terms use them. *)
val params : t -> int -> tvars

(** [named names ids] is the names of the parameters [ids] of an inductive
    or a [Dtype]. They are the Rocq names in PascalCase, made distinct and
    kept apart from every type name in [names], which a parameter would
    shadow. *)
val named : t -> Names.Id.t list -> tvars

(** [slots n] is the names of [Tvar i] for [i] in [1..n] in the type of a
    type lambda, which reads its arguments from its slots, as
    [this["Target"]] and [this["Target1"]]. *)
val slots : int -> tvars

(** [erased] is the names of the type variables of a [const], which cannot
    bind type parameters. Every type variable renders as [any]. *)
val erased : tvars

(** [type_params names abstracts] is a type parameter name for each
    abstract type of [abstracts], as {!named} chooses them from the
    identifiers of the abstract types, with its global. {!in_scope} binds
    them. *)
val type_params : t -> Ts_sig.abstract list -> (Miniml.global * string) list

(** [in_scope names params] is [names] with each abstract type of
    [params] named by its type parameter, so that {!ty} writes the
    parameter for the type, and with the parameters among the type names
    that {!val-params} and {!named} keep apart. An abstract type that takes
    parameters is a type lambda, so {!ty} writes its application to [A]
    as [Kind<T, A>], the helper of its arity, through the import of the
    file of the module type that declares it. *)
val in_scope : t -> (Miniml.global * string) list -> t

(** [is_abstract names r] is [true] if [r] is an abstract type that
    {!in_scope} named in [names]. *)
val is_abstract : t -> Miniml.global -> bool

(** [type_lambda] is [TypeLambda], the name of the helper type of the
    abstract types that take parameters, which a structure that has one
    reserves, and whose properties are the slots {!kind_slot} of the
    arguments and [type]. *)
val type_lambda : string

(** [kind_name n] is the name of the helper type that applies an abstract
    type of [n] parameters to its arguments. It is [Kind] for [n = 1] and
    [Kind2], [Kind3], and so on for the arities beyond. *)
val kind_name : int -> string

(** [kind_slot i] is the property of {!type_lambda} that holds argument
    [i], from [0]. It is [Target], then [Target1], [Target2], and so
    on. *)
val kind_slot : int -> string

(** [kind_ref names r name] is how the current file refers to the helper
    [name] of the abstract type [r]. It goes through the import of the
    file of the module type that declares [r] when that is another
    file. *)
val kind_ref : t -> Miniml.global -> string -> string

(** [lambda_name names base] is [base], or [base] with a numeric suffix,
    apart from every type name and every name it gave before. *)
val lambda_name : t -> string -> string

(** [implicit_params names r] is the type parameters that the type or
    constructor [r] takes beyond its own, one per abstract type that
    {!Ts_sig.implicit} gives it, as {!ty} names them in the scope of
    [names]. *)
val implicit_params : t -> Miniml.global -> string list

(** [implicit_args names r] is the type arguments that a reference to
    the type or constructor [r] passes for its {!implicit_params}, as
    {!ty} writes each abstract type. Each is its type parameter, or the
    type that a constraint fixes it to under the path of [r]. *)
val implicit_args : t -> Miniml.global -> Ts_print.ty list

(** [tparams tvars] is the list to print between [<] and [>]. It is empty
    for {!erased}. *)
val tparams : tvars -> string list

(** [generic names tvars ids] is [tvars] with names for [Var i] for [i]
    in [ids], the type parameters of a local generic function, and those
    names, in order. They are the first of [A] to [Z], [T27], and so on
    that no type of [names] and no type variable of [tvars] is named,
    since Oxlint's [no-shadow] rejects a type parameter that shadows
    another. Under {!erased}, the result names only those. *)
val generic : t -> tvars -> int list -> tvars * string list

(** [hide tvars ids] is [tvars] where [Var i] for [i] in [ids] is
    [never], as an unsolved meta is. A function of a local recursive
    group does not bind a type parameter of the group that its type does
    not mention, and its body may still mention it. *)
val hide : tvars -> int list -> tvars

(** [ty names tvars t] is the TypeScript type of [t]. [Arrow (a, b)] is
    [(_: A) => B], because function values are curried, or [() => B] when
    [a] is {!Ts_type.is_erased}, since an erased parameter is dropped and a
    function that keeps no parameter is nullary. [Glob (r, args)]
    is the name of [r] with [<args>] when [args] is not empty, followed
    by the {!implicit_params} of [r], and the type parameter of
    {!in_scope} that an abstract type is bound to. An inline
    custom, such as the type of an [Extract Inductive], prints its code in
    place of the name. Code that contains placeholders [$1], [$2], and so
    on gets type argument [n] in place of [$n] and no [<args>], so
    ["readonly [$1, $2]"] makes [prod A B] [readonly [A, B]], a tuple
    that breaks one element per line as any other. Every [$]
    followed by digits is a placeholder, and code that is one placeholder
    alone is that argument. Code that is the name of a generated type,
    alone, as ["Bounds"], or applied to placeholders only, as
    ["Cell<$1>"], refers to that type as the name of [r] would, so that
    another file reaches it through its import, as [$Spans.Bounds]. Any
    other code is printed as written, except that {!qualify_code} writes
    each generated type it mentions, as [Point] in
    ["readonly Point[]"], as the current file refers to it. A name is
    looked up among the types of the file that declares [r], then among
    those of the other files. A primitive
    type that {!Ts_primitives.builtin} gives a keyword is that keyword, as
    [bigint] for [PrimInt63.int], and [PrimArray.array] is named [PArray]
    as a declared type is. [Var i] is named by [tvars]. [Forall (vs, t)]
    is the function type of [t] with a type parameter for each of [vs],
    named as {!generic} names them, [<A>(_: A) => A]. [Erased] is
    [undefined]. A meta is the type {!Ts_type.zonk} gives it. A tuple is
    [readonly [A, B]]. A union has its members in the order of their
    printed form, so that the output is deterministic, and one member per
    printed form, since two types may print the same, as [nat] and [N] do
    under the Number preset, and it is that member alone when every
    member prints the same. A reference to a type of another file records
    an import in [names].

    @raise CErrors.UserError
      if a placeholder is [$0] or names a type argument that [r] does not
      have, or if the code names a type that the file of [r] does not
      declare and more than one other file does.
    @raise Ts_type.Lost
      if [t] mentions a meta of a position that MiniML lost and nothing
      solved. *)
val ty : t -> tvars -> Ts_type.t -> Ts_print.ty

(** [qualify_code names r ~params code] is the type code [code] of the
    mapped type [r] with each identifier that {!Ts_print.reads} counts as
    a reference, other than [params], and that names a generated type,
    written as the current file refers to that type. The identifier stays
    as it is in the file that declares the type, and goes through the
    import of that file, as [$Shapes.Point], in another. The operand of
    [typeof] is written the same way when it names a top-level generated
    value, as [typeof $Shapes.origin]. It records the import in [names].

    @raise CErrors.UserError
      if an identifier names a type, or a [typeof] operand names a
      top-level value, that the file of [r] does not declare and more
      than one other file does. *)
val qualify_code : t -> Miniml.global -> params:string list -> string -> string

(** [signature names tparams] is the names of the type parameters
    [tparams] of a signature, as {!tparams} gives them, and their
    declarations. A parameter of ML is named by {!val-params}, and one with a
    hint, a lifted binder or a parameter of a [Dtype], after its hint in
    PascalCase, apart from the type names of [names] and the other
    parameters, so [b] gives [B] and [is_num] gives [IsNum]. A bound is
    the type {!ty} gives it. *)
val signature : t -> Ts_type.tparam list -> tvars * Ts_print.tparam list

(** [function_type names (tvars, tparams) t ~arity] is the uncurried type
    of a function of [arity] parameters with declared type [t], generic
    over [tparams], whose names [tvars] gives, as {!signature} gives both,
    such as [<A>(_0: A, _1: Nat) => A], without the parameters that are
    {!Ts_type.is_erased}. Its types are named by [names]. It annotates
    [Extract Constant] terms, which are called uncurried, and types the
    function members of an interface. *)
val function_type
  :  t
  -> tvars * Ts_print.tparam list
  -> Ts_type.t
  -> arity:int
  -> Ts_print.ty

(** {1 Locals} *)

(** The type for the identifiers that a new local must not take. *)
type avoid

(** [avoid names] is the reserved words, every value name of the top level
    of [names], the local name of every binding of {!bindings} in the file
    of {!in_file}, every name {!lift} recorded in it, every local of the
    functor body of {!in_body}, and every parameter of the code of an
    [Extract Inlined Constant], which would shadow a local of that name
    where the code is written out. Locals never shadow a global or a
    binding, so substituting a field path for a pattern variable is
    always hygienic. *)
val avoid : t -> avoid

(** [lift names x] records [x], the name of a private constant that the
    translation of a declaration lifts to the top level of the file,
    before the declaration. {!val-avoid} and {!lifted} hold [x] from then on,
    so that no local declared after the constant takes its name, since
    Oxlint's no-shadow rejects a local declared after a module-level
    constant of that name. The caller chooses [x] apart from {!val-avoid}. *)
val lift : t -> string -> unit

(** [lifted names] is the names that {!lift} recorded in the file of
    {!in_file}. *)
val lifted : t -> avoid

(** [restore names a] makes [a], which {!lifted} gave earlier, the names
    that {!lift} recorded, so that a translation abandoned since then
    lifted nothing. *)
val restore : t -> avoid -> unit

(** [in_body names ~body ~params ~locals ~holders ~hoisted ~modules] is
    [names] for printing the body of a functor, at the path [body], whose
    parameters are the modules [params], each with the local name of its
    object, whose members, and the members of its parameters that the
    body binds at its top, are the locals [locals], whose mutually
    recursive groups are the objects [holders], keyed by their first
    member, and whose members [hoisted] are declared at the top level of
    the file, under the functor's name, since they read nothing of the
    body. [modules] are the modules, functors, and applications declared
    in the body, each with the local name of its object. {!value} refers
    to a local by its name, to any other member of a parameter as a
    property of the parameter's object, and to a hoisted member by its
    top-level name, and {!value_name} and {!group_name} give the locals,
    which {!val-avoid} holds, the top-level names of the hoisted members, or,
    for a member of the body that both miss, its short name, from which a
    local is chosen. The body of a functor declared in the body of
    another keeps the parameters and the locals of the body around it. *)
val in_body
  :  t
  -> body:Names.ModPath.t
  -> params:(Names.ModPath.t * string) list
  -> locals:(Miniml.global * string) list
  -> holders:(Miniml.global * string) list
  -> hoisted:Miniml.global list
  -> modules:(Names.ModPath.t * string) list
  -> t

(** [reserve avoid s] is [s], or [s] with the first numeric suffix that
    [avoid] lacks when [avoid] has [s], and [avoid] extended with it. *)
val reserve : avoid -> string -> string * avoid

(** [add avoid s] is [avoid] with [s]. *)
val add : avoid -> string -> avoid

(** [apart names] is the identifiers [names] and no other. *)
val apart : string list -> avoid

(** [merge a b] is the identifiers that [a] or [b] holds. *)
val merge : avoid -> avoid -> avoid

(** [fresh avoid b] is a fresh local named after binder [b] in
    lowerCamelCase, and [avoid] extended with it. A [Dummy] binder, or one
    named only with underscores, becomes [_unused], [_unused0], and so on.
    The leading underscore marks the parameter unused on purpose, as
    Oxlint's [no-unused-vars] asks, and the suffix keeps the names apart,
    because strict mode forbids duplicate parameter names. *)
val fresh : avoid -> Miniml.ml_ident -> string * avoid

(** [key avoid id] is a fresh property name for the function [id] of an
    object of mutually recursive local functions, and [avoid] extended
    with it. It is what {!fresh} gives, unless that is a name that
    {!group_key} keeps off an object, and then it takes a suffix, as
    {!group_key} does. *)
val key : avoid -> Names.Id.t -> string * avoid

(** {1 Separate extraction} *)

(** [in_file names mp sels] is [names] for printing the file [mp] with the
    declarations [sels] in separate extraction, where references to
    globals of other files go through imports. It reads [sels] for the
    globals that the output refers to and chooses the local name of every
    binding of {!bindings} then, and of {!methods_of}, as
    {!bind_methods} does, before any local is named, so that {!val-avoid} has
    them. It is [names] itself in monolithic extraction. *)
val in_file : t -> Names.ModPath.t -> Miniml.ml_module_structure -> t

(** [bind_methods names sels] is [names] for printing the declarations
    [sels] in monolithic extraction, with a local for every member of an
    application of the file, or of a module nested in one, outside the
    bodies of functors, that [sels] refer to and whose name is one that
    {!group_key} keeps off an object, such as [sort], which a call through
    the application's object, as [Sort.sort(l)], would trip. The local is
    the member's name, with a suffix when the file already takes it, and
    {!value} refers to the member by it. A functor body binds the members
    of its own applications itself. *)
val bind_methods : t -> Miniml.ml_module_structure -> t

(** [methods_of names root] is, for the application whose object is the
    top-level value [root], the paths through its object and its nested
    modules, as [("Sort", [])], each with the pairs of a member's name and
    its local that {!bind_methods} chose, in order of first reference. *)
val methods_of : t -> string -> (Ts_print.path * (string * string) list) list

(** [file_name names dp] is the name, without its suffix, of the file that
    separate extraction writes for library [dp]. An import of the file
    names it too, as in [from "./list-def.ts"]. It is the name that
    [Table.file_of_modfile] gives the library, which is the last component
    of its path with a numeric suffix when another library or the
    [Extraction Blacklist] already took it, put in kebab-case, the
    convention for file names in TypeScript projects. Every letter is
    lowercased, an underscore becomes a hyphen, and a hyphen goes before an
    uppercase letter that follows a lowercase letter or a digit, and before
    an uppercase letter that is between another uppercase letter and a
    lowercase one. So [Datatypes] is [datatypes], [ListDef] is [list-def],
    [My_Lib] is [my-lib], [Lib1] is [lib1], and [HTTPServer] is
    [http-server]. The alias of the import keeps the library's name, as in
    [$ListDef]. *)
val file_name : t -> Names.DirPath.t -> string

(** [imports names] is the alias and the file name of one import per
    file that {!value}, {!ty}, and {!interface_ref} referenced so far from
    the file of {!in_file}, in order of first reference. It is empty in
    monolithic extraction. *)
val imports : t -> (string * string) list

(** [bindings names] is, for each object of another file that {!value}
    bound a value from, the path of the object through the alias of its
    import, as [("$ListDef", [])] for the file itself or
    [("$Other", ["M"])] for its module [M], and the pairs of each bound
    value's name and the local name that refers to it, in order of first
    reference. Every top-level value of another file is bound. A value in
    a module of another file is bound only when its name is one that
    {!group_key} keeps off an object, such as [map] or [reduce], which a
    call through the module object would trip. Any other is referred to
    through the alias, as [$Datatypes.M.x]. The local name is the value's
    own unless the current file already declares it, and then takes a
    suffix. *)
val bindings : t -> (Ts_print.path * (string * string) list) list
