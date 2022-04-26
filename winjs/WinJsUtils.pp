unit WinJsUtils;

{$mode delphi}

interface

  uses ChakracoreTypes;

  function ExtractFileNameWithoutExt(FilePath: UnicodeString): UnicodeString;
  function RunScriptFile(ScriptPath: UnicodeString): Integer;
  procedure WriteErrLn(Fmt: UnicodeString; Args: array of const);
  function LoadWinJsLibrary(FilePath: UnicodeString): TJsValue;
  procedure LoadLibraryProperties(Instance: TJsValue; FilePath: UnicodeString; PropertyNames: array of UnicodeString);

implementation

  uses SysUtils, StrUtils, Classes, WinJsRuntime, Chakracore, DynLibs;

  var WinJsLibraryHandles: array of TLibHandle;

  procedure WriteErrLn;
  begin
    WriteLn(StdErr, WideFormat(Fmt, Args));
  end;

  function ReadUnicodeTextFileContent(FilePath: UnicodeString): UnicodeString;
  var
    FileStream: TFileStream;
    S: UTF8String;
  begin
    Result := '';

    FileStream := TFileStream.Create(FilePath, fmOpenRead);
    try

      if FileStream.Size = 0 then Exit;

      with FileStream do begin
        SetLength(S, Size);
        Read(S[1], Size);

        Result := UTF8String(S);

      end;

    finally
      FileStream.Free;
    end;

  end;

  function ExtractFileNameWithoutExt;
  var
    Ext: UnicodeString;
  begin
    Ext := ExtractFileExt(FilePath);
    if Ext <> '' then begin
      Result := ExtractFileName(Copy(FilePath, 1, RPos(Ext, FilePath) - 1));
    end else begin
      Result := ExtractFileName(FilePath);
    end;
  end;

  function RunScriptFile;
  var
    ScriptName: UnicodeString;
    ScriptContent: UnicodeString;
    ScriptResult: TJsValue;
    ErrorLevel: TJsValue;
  begin
    Result := 0;

    ScriptName := ExtractFileNameWithoutExt(ScriptPath);
    ScriptContent := ReadUnicodeTextFileContent(ScriptPath);

    JsRuntime.EvalScriptSource(ScriptContent, ScriptName);

    ErrorLevel := GetProperty(GetGlobalObject, 'errorLevel');

    if GetValueType(ErrorLevel) = jsNumber then begin
      Result := JsNumberAsInt(ErrorLevel);
    end;

  end;

  function LoadWinJsLibrary;
  type
    TGetJsValue = function: TJsValue;
  var
    L: Integer;
    Handle: TLibHandle;
    GetJsValue: TGetJsValue;
  begin
    L := Length(WinJsLibraryHandles);
    SetLength(WinJsLibraryHandles, L + 1);

    Handle := LoadLibrary(FilePath + '.DLL');

    WinJsLibraryHandles[L] := Handle;
    GetJsValue := GetProcAddress(Handle, 'GetJsValue');

    Result := GetJsValue;
  end;

  procedure UnloadWinJsLibraries;
  var
    Handle: TLibHandle;
  begin
    for Handle in WinJsLibraryHandles do begin
      FreeLibrary(Handle);
    end;
  end;

  procedure LoadLibraryProperties;
  var
    LibraryValue: TJsValue;
    Key: UnicodeString;
    Value: TJsValue;
  begin
    LibraryValue := LoadWinJsLibrary(FilePath);

    for Key in PropertyNames do begin
      Value := GetProperty(LibraryValue, Key);
      SetProperty(Instance, Key, Value);
    end;
  end;

  finalization

    UnloadWinJsLibraries;

end.