unit WinJsRT;

{$mode delphi}

interface

  uses ChakraTypes;

  type

    TWinJsRuntime = record
      private
        FSourceContext: UIntPtr;
      public
        procedure Init;
        function EvalScriptSource(ScriptSource: WideString; ScriptName: WideString = ''): TJsValue;
    end;

  var JsRuntime: TWinJsRuntime;

implementation

  uses ChakraErr, chakracore_dll, Chakra, DynLibs, WinJsUtils, WinjsObj, ChakraUtils, WinjsProc;

  procedure TWinJsRuntime.Init;
  var
    Global: TJsValue;
    Prelude: TJsValue;
  begin

    Global := GetGlobalObject;

    SetProperty(Global, 'process', GetWinjsProcess);
    SetProperty(Global, 'winjs', GetWinjs);

  end;

  function TWinJsRuntime.EvalScriptSource;
  begin
    Inc(FSourceContext);
    Result := Chakra.EvalScriptSource(FSourceContext, ScriptSource, ScriptName);
  end;

  procedure InitContext;
  const
    EnableExperimentalFeatures = $00000020;
  var
    Runtime, Context: TJsValue;
  begin
    TryChakraAPI('JsCreateRuntime', JsCreateRuntime(EnableExperimentalFeatures, Nil, Runtime));
    TryChakraAPI('JsCreateContext', JsCreateContext(Runtime, Context));
    TryChakraAPI('JsSetCurrentContext', JsSetCurrentContext(Context));
  end;

  initialization

    InitContext;
    JsRuntime.Init;

end.