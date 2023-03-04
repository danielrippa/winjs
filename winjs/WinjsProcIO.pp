unit WinjsProcIO;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetWinjsProcessIO: TJsValue;

implementation

  uses
    Chakra, ChakraUtils, Windows;

  procedure Debug(Value: WideString);
  var
    S: String;
  begin
    S := UTF8Encode(Value);
    OutputDebugString(PChar(S));
  end;

  function GlobalGetStdin(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    StandardInput: UnicodeString;
    Character: Char;
  begin
    StandardInput := '';

    while not EOF(Input) do begin
      Read(Character);
      StandardInput := StandardInput + Character;
    end;

    Result := StringAsJsString(StandardInput);
  end;

  function GlobalStdErr(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := Undefined;
    CheckParams('stderr', Args, ArgCount, [], 1);

    Write(StdErr, JsValueAsString(Args^));
  end;

  function GlobalStdOut(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := Undefined;
    CheckParams('stdout', Args, ArgCount, [], 1);

    Write(JsValueAsString(Args^));
  end;

  function GlobalDebug(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    DebugOutput: UnicodeString;
  begin
    Result := Undefined;

    if ArgCount = 0 then Exit;

    DebugOutput := '';

    while ArgCount > 0 do begin

      if Length(DebugOutput) <> 0 then begin
        DebugOutput := DebugOutput + ' ';
      end;

      DebugOutput := DebugOutput + JsValueAsString(Args^);

      Inc(Args); Dec(ArgCount);

    end;

    Debug(DebugOutput);

  end;

  function GetWinjsProcessIO;
  begin

    Result := CreateObject;

    SetFunction(Result, 'getStdin', @GlobalGetStdin);
    SetFunction(Result, 'stderr', @GlobalStdErr);
    SetFunction(Result, 'stdout', @GlobalStdOut);

    SetFunction(Result, 'debug', @GlobalDebug);

  end;

end.