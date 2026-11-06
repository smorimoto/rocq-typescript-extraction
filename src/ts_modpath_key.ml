type t = Names.ModPath.t

let compare = Names.ModPath.compare
let hash = Names.ModPath.hash
let sexp_of_t t = Base.Sexp.Atom (Names.ModPath.debug_to_string t)
