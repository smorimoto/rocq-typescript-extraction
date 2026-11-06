Set Debug "backtrace".
From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Redirect "backtrace-enabled" Fail Check backtrace_missing.

Set Debug "-backtrace".
Declare ML Module "rocq-typescript-extraction.plugin".
Redirect "backtrace-disabled" Fail Check backtrace_missing.
