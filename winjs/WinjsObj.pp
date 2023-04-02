unit WinjsObj;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetWinjs: TJsValue;

implementation

  uses
    Chakra, WinjsRT, ChakraUtils, WinjsUtils, Windows, SysUtils, DynLibs;

  var WinJsLibraryHandles: array of TLibHandle;

  function WinjsEvalScriptSource(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    ScriptSource: WideString;
    ScriptPath: WideString;
  begin
    CheckParams('evalScriptSource', Args, ArgCount, [jsString, jsString], 1);

    ScriptSource := JsStringAsString(Args^);
    ScriptPath := '';

    if ArgCount > 1 then begin
      Inc(Args);
      ScriptPath := JsStringAsString(Args^);
    end;

    Result := JsRuntime.EvalScriptSource(ScriptSource, ScriptPath);
  end;

  function LoadWinJsLibrary(FilePath: WideString): TJsValue;
  type
    TGetJsValue = function: TJsValue;
  var
    L: Integer;
    Handle: TLibHandle;
    GetJsValue: TGetJsValue;
  begin
    L := Length(WinJsLibraryHandles);
    SetLength(WinJsLibraryHandles, L + 1);

    Handle := WinjsUtils.LoadLibrary(FilePath);

    WinJsLibraryHandles[L + 1] := Handle;

    GetJsValue := GetProcAddress(Handle, 'GetJsValue');

    Result := GetJsValue();
  end;

  function WinjsLoadLibrary(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('loadLibrary', Args, ArgCount, [jsString], 1);
    Result := LoadWinJsLibrary(JsStringAsString(Args^));
  end;

  function WinjsLoadScript(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('loadScript', Args, ArgCount, [jsString], 1);
    Result := LoadScript(JsStringAsString(Args^));
  end;

  function WinjsThrowException(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    Message: WideString;
    ErrorCode: Integer;
  begin
    CheckParams('throwException', Args, ArgCount, [jsString, jsNumber], 2);

    Message := JsStringAsString(Args^); Inc(Args);
    ErrorCode := JsNumberAsInt(Args^);

    raise EWinjsException.Create(Message, ErrorCode);
  end;

  function WinjsLoadWasm(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('loadWasm', Args, ArgCount, [jsString], 1);
    Result := LoadWasm(JsStringAsString(Args^));
  end;

  function GetWinjs;
  begin
    Result := CreateObject;

    SetFunction(Result, 'evalScriptSource', WinjsEvalScriptSource);
    SetFunction(Result, 'loadScript', WinjsLoadScript);
    SetFunction(Result, 'loadLibrary', WinjsLoadLibrary);
    SetFunction(Result, 'loadWasm', WinjsLoadWasm);
    SetFunction(Result, 'throwException', WinjsThrowException);
  end;

  procedure UnloadWinJsLibraries;
  var
    Handle: TLibHandle;
  begin
    for Handle in WinJsLibraryHandles do begin
      FreeLibrary(Handle);
    end;
  end;

  finalization

    UnloadWinJsLibraries;

end.
