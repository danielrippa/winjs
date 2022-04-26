unit WinJsPreludeUtils;

{$mode delphi}

interface

  uses ChakracoreTypes;

  function GetJsValue: TJsValue;

implementation

  uses Windows, Chakracore, SysUtils, ChakracoreUtils;

  procedure Debug(Value: UnicodeString);
  var
    S: String;
  begin
    S := UTF8Encode(Value);
    OutputDebugString(PChar(S));
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

  function GlobalNow(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    ThisMoment: TDateTime;
  begin
    ThisMoment := SysUtils.Now;
    Result := StringAsJsString(FormatDateTime('yyyy"-"m"-"d h:m":"s":"z', ThisMoment));
  end;

  function GlobalArgs: TJsValue;
  var
    I: Integer;
  begin
    Result := CreateArray(ParamCount + 1);

    for I := 0 to ParamCount do begin
      SetArrayItem(Result, I, StringAsJsString(ParamStr(I)));
    end;
  end;

  function GlobalEnvVars: TJsValue;
  var
    I: Integer;
    S: array of String;
  begin
    Result := CreateObject;

    for I := 0 to GetEnvironmentVariableCount - 1 do begin
      S := GetEnvironmentString(I).Split(['=']);

      if (Length(S) > 1) and (not S[0].IsEmpty) then begin
        SetProperty(Result, S[0], StringAsJsString(S[1]));
      end;
    end;
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

  function GlobalPId: TJsValue;
  begin
    Result := IntAsJsNumber(GetCurrentProcessID)
  end;

  (*
  function GlobalLoadLibrary(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('loadLibrary', Args, ArgCount, [jsString], 1);
    Result := LoadWinJsLibrary(JsStringAsString(Args^));
  end;
  *)

  function GetJsValue;
  begin
    Result := CreateObject;

    SetFunction(Result, 'debug', @GlobalDebug);
    SetFunction(Result, 'getStdin', @GlobalGetStdIn);
    SetProperty(Result, 'pid', GlobalPId);

    SetFunction(Result, 'now', @GlobalNow);
    SetProperty(Result, 'args', GlobalArgs);
    SetProperty(Result, 'envVars', GlobalEnvVars);
    SetFunction(Result, 'stderr', @GlobalStdErr);
    SetFunction(Result, 'stdout', @GlobalStdOut);
  end;

end.