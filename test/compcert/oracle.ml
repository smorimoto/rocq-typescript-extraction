let () =
  List.iter
    (fun row -> print_endline (String.concat "," (List.map string_of_int row)))
    Reference.reference_results
;;
