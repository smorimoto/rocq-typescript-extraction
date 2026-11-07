From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Redirect "backtrace-default" Fail Check backtrace_missing.
Redirect "debug-default" Test Debug.
