unit WinjsUtils;

{$mode delphi}

interface

  uses
    ChakraTypes, SysUtils;

  type

    EWinjsException = class(Exception)
      private
        FErrorCode: Integer;
      public
        constructor Create(aMessage: WideString; aErrorCode: Integer);
        property ErrorCode: Integer read FErrorCode;
    end;

  function LoadScript(aFilePath: WideString; aScriptName: WideString = ''): TJsValue;
  function LoadLibrary(FilePath: WideString): THandle;
  function LoadWasm(FilePath: WideString): TJsValue;
  function RunScriptFile(FilePath: WideString): Integer;

  function ReadUnicodeTextFileContent(FilePath: WideString): WideString;

  function StringifyJsValue(aValue: TJsValue): TJsValue;

  procedure WriteErrLn(Fmt: WideString; Args: array of const);

implementation

  uses
    Classes, StrUtils, WinjsRT, Chakra, Windows, DynLibs;

  procedure WriteErrLn;
  begin
    WriteLn(StdErr, WideFormat(Fmt, Args));
  end;

  function ReadUnicodeTextFileContent;
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

  function ExtractFileNameWithoutExt(FilePath: WideString): WideString;
  var
    Ext: WideString;
  begin
    Ext := ExtractFileExt(FilePath);
    if Ext <> '' then begin
      Result := ExtractFileName(Copy(FilePath, 1, RPos(Ext, FilePath) - 1));
    end else begin
      Result := ExtractFileName(FilePath);
    end;
  end;

  function LoadScript;
  var
    ScriptName: WideString;
    ScriptContent: WideString;
  begin
    ScriptContent := ReadUnicodeTextFileContent(aFilePath);

    if aScriptName = '' then begin
      ScriptName := ExtractFilenameWithoutExt(aFilePath);
    end else begin
      ScriptName := Format('%s (%s)', [aScriptName, aFilePath]);
    end;

    Result := JsRuntime.EvalScriptSource(ScriptContent, ScriptName);
  end;

  function RunScriptFile;
  var
    ScriptResult: TJsValue;
    ErrorLevel: TJsValue;
  begin
    Result := 0;

    LoadScript(FilePath);

    ErrorLevel := GetProperty(GetGlobalObject, 'errorLevel');

    if GetValueType(ErrorLevel) = jsNumber then begin
      Result := JsNumberAsInt(ErrorLevel);
    end;
  end;

  function LoadLibrary;
  var
    Handle: THandle;
    LastError: DWORD;
    ErrorMessage: String;
    Path: String;
  begin

    Path := FilePath;
{*
    if not FileExists(Path) then begin
      raise Exception.CreateFmt('Winjs library ''%s'' not found.', [FilePath]);
    end;
*}
    Handle := DynLibs.LoadLibrary(Path);

    if Handle = 0 then begin
      LastError := GetLastError();
      ErrorMessage := SysErrorMessage(LastError);

      raise Exception.CreateFmt('%s ''%s''', [ErrorMessage, FilePath]);
    end;

    Result := Handle;
  end;

  function LoadWasm;
  begin
    Result := StringAsJsString(ReadUnicodeTextFileContent(FilePath));
  end;

  constructor EWinjsException.Create;
  begin
    inherited Create(aMessage);
    FErrorCode := aErrorCode;
  end;

  function StringifyJsValue;
  var
    JSON: TJsValue;
    stringify: TJsValue;
    Args: Array of TJsValue;
    ArgCount: Word;
  begin
    JSON := GetProperty(GetGlobalObject, 'JSON');
    stringify := GetProperty(JSON, 'stringify');

    Args := [ JSON, aValue ];
    ArgCount := Length(Args);

    Result := CallFunction(stringify, @Args[0], ArgCount);
  end;

end.