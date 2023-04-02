# WinJs

```

winjs =

  process: 

    pid: number
    args: []
    env-vars: {}
    sleep: (ms: number) -> void
    io:
      get-stdin: -> string
      stderr: (value: string) -> void
      stdout: (value: string) -> void
      debug: (..args: string) -> void

  os:
    
    now: -> string

  winjs:
  
    eval-script-source: (script-source: string, script-path: string) -> {}
    load-script: (script-name: string, script-content: string) -> {}
    load-library: (dll-filename: string) -> {}
    load-wasm: (wasm-filename: string) -> {}
    throw-exception: (message: string, error-code: number) -> void

```

