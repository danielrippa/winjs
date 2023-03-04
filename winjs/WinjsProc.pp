unit WinjsProc;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetWinjsProcess: TJsValue;

implementation

  uses
    Chakra, SysUtils, Windows, WinjsProcIO, ChakraUtils;

  function GetWinjsProcessId: TJsValue;
  begin
    Result := IntAsJsNumber(GetCurrentProcessID)
  end;

  function GetWinjsProcessArgs: TJsValue;
  var
    I: Integer;
  begin
    Result := CreateArray(ParamCount + 1);

    for I := 0 to ParamCount do begin
      SetArrayItem(Result, I, StringAsJsString(ParamStr(I)));
    end;
  end;

  function GetWinjsProcessEnvVars: TJsValue;
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

  function WinjsSleep(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := Undefined;
    CheckParams('sleep', Args, ArgCount, [jsNumber], 1);
    Sleep(JsNumberAsInt(Args^));
  end;

  function GetWinjsProcess;
  begin

    Result := CreateObject;

    SetProperty(Result, 'pid', GetWinjsProcessId);
    SetProperty(Result, 'args', GetWinjsProcessArgs);
    SetProperty(Result, 'envVars', GetWinjsProcessEnvVars);

    SetFunction(Result, 'sleep', @WinjsSleep);

    SetProperty(Result, 'io', GetWinjsProcessIO)

  end;

end.