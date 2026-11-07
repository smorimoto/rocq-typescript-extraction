Set Debug "backtrace".
From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Redirect "backtrace-enabled" Fail Check backtrace_missing.
