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

  winjs:
  
    load-script: (js-filename: string, script-name: string) -> {}
    load-library: (dll-filename: string) -> {}
    load-wasm: (wasm-filename: string) -> {}

    os:

      now: -> string

    file-system:

      file-exists: (file-path: string) -> boolean
      folder-exists: (folder-path: string) -> boolean
      read-text-file: (file-path: string) -> string | void
      get-current-folder: -> string
      set-current-folder: (location: string) -> boolean

```

