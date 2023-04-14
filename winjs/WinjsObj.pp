unit WinjsObj;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetWinjs: TJsValue;

implementation

  uses
    Chakra, WinjsRT, ChakraUtils, WinjsUtils, Windows, SysUtils, DynLibs, WinjsOS, WinjsFS;

  var WinJsLibraryHandles: array of TLibHandle;

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

    WinJsLibraryHandles[L] := Handle;

    GetJsValue := GetProcAddress(Handle, 'GetJsValue');

    Result := GetJsValue;
  end;

  function WinjsLoadLibrary(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('loadLibrary', Args, ArgCount, [jsString], 1);
    Result := LoadWinJsLibrary(JsStringAsString(Args^));
  end;

  function WinjsLoadScript(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aFileName, aScriptName: WideString;
  begin
    CheckParams('loadScript', Args, ArgCount, [jsString, jsString], 2);

    aFileName := JsStringAsString(Args^); Inc(Args);
    aScriptName := JsStringAsString(Args^);

    Result := LoadScript(aFileName, aScriptName);
  end;

  function WinjsLoadWasm(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('loadWasm', Args, ArgCount, [jsString], 1);
    Result := LoadWasm(JsStringAsString(Args^));
  end;

  function GetWinjs;
  begin
    Result := CreateObject;

    SetFunction(Result, 'loadScript', WinjsLoadScript);
    SetFunction(Result, 'loadLibrary', WinjsLoadLibrary);
    SetFunction(Result, 'loadWasm', WinjsLoadWasm);

    SetProperty(Result, 'os', GetWinjsOS);
    SetProperty(Result, 'fileSystem', GetWinjsFs);
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
