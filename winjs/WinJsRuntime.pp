unit WinJsRuntime;

{$mode delphi}

interface

  uses ChakracoreTypes;

  type

    TWinJsRuntime = record
      private
        FSourceContext: UIntPtr;
      public
        procedure Init;
        function EvalScriptSource(ScriptSource: UnicodeString; ScriptName: UnicodeString = ''): TJsValue;
    end;

  var JsRuntime: TWinJsRuntime;

implementation

  uses ChakracoreUtils, ChakracoreErrors, chakracore_dll, Chakracore, DynLibs, WinJsUtils;

  const

    crlf = #13 + #10;

    RaiseError = ' var raise = function(it) { ' + crlf +
                 '   throw new Error(it); ' + crlf +
                 ' }; ';

    Assert = ' var assert = function(predicate, message) { ' + crlf +
             '   if (!predicate) { ' + crlf +
             '     raise(message); ' + crlf +
             '   }; ' + crlf +
             ' }; ';

    OrElse = ' var orElse = function(one, another){ ' + crlf +
             '   if (one !== void 8) { ' + crlf +
             '     return one; ' + crlf +
             '   } else { ' + crlf +
             '     if (''function'' === typeof another) { ' + crlf +
             '       return another(); ' + crlf +
             '     } else { ' + crlf +
             '       return another; ' + crlf +
             '     }; ' + crlf +
             '   }; ' + crlf +
             ' }; ';

  function GlobalLoadLibrary(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('loadLibrary', Args, ArgCount, [jsString], 1);
    Result := LoadWinJsLibrary(JsStringAsString(Args^));
  end;

  procedure TWinJsRuntime.Init;
  var
    Global: TJsValue;
    Prelude: TJsValue;
  begin
    Global := GetGlobalObject;

    SetFunction(Global, 'loadLibrary', @GlobalLoadLibrary);

    LoadLibraryProperties(Global, 'WinJsPrelude', [
      'debug', 'getStdin', 'envVars', 'args', 'now',
      'stderr', 'stdout', 'pid'
    ]);

    EvalScriptSource(RaiseError);
    EvalScriptSource(Assert);
    EvalScriptSource(OrElse);
  end;

  function TWinJsRuntime.EvalScriptSource;
  begin
    Inc(FSourceContext);
    Result := Chakracore.EvalScriptSource(FSourceContext, ScriptSource, ScriptName);
  end;

  procedure InitContext;
  const
    EnableExperimentalFeatures = $00000020;
  var
    Runtime, Context: TJsValue;
  begin
    TryChakracoreAPI('JsCreateRuntime', JsCreateRuntime(EnableExperimentalFeatures, Nil, Runtime));
    TryChakracoreAPI('JsCreateContext', JsCreateContext(Runtime, Context));
    TryChakracoreAPI('JsSetCurrentContext', JsSetCurrentContext(Context));
  end;

  initialization

    InitContext;
    JsRuntime.Init;

end.