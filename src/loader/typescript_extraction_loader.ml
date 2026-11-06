let () =
  Mltop.add_init_function "rocq-typescript-extraction.plugin" (fun () ->
    let recording = Printexc.backtrace_status () in
    Fun.protect
      ~finally:(fun () -> Printexc.record_backtrace recording)
      (fun () ->
         Mltop.run_interp_fun
           (Mltop.declare_ml_modules false [ "rocq-typescript-extraction.backend" ])))
;;
