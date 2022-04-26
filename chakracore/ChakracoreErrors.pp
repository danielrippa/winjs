unit ChakracoreErrors;

{$mode delphi}

interface

  uses ChakracoreTypes, SysUtils;

  type

    TScriptError = record
      Line: Integer;
      Column: Integer;
      Source: UnicodeString;
      ScriptName: UnicodeString;

      Message: UnicodeString;

      Exception: TJsValue;
    end;

    TJsErrorCode = (
      jecNoError = 0,

      jecUsageError = $10000,
        jecInvalidArgument,
        jecNullArgument,

      jecScriptError = $30000,
        jecOutOfMemory
    );

    EChakraCoreError = class(Exception);

    EChakracoreAPIError = class(EChakracoreError);

    EChakracoreScriptError = class(EChakraCoreError)
      ScriptError: TScriptError;

      constructor Create(aMessage: UnicodeString; aScriptError: TScriptError);
    end;

  procedure TryChakracoreAPI(APIFunctionName: UnicodeString; ErrorCode: TJsErrorCode);
  procedure ThrowError(Fmt: UnicodeString; Params: array of const);

implementation

  uses chakracore_dll, Chakracore;

  function ErrorMessage(ErrorCode: TJsErrorCode): UnicodeString;
  begin
    case ErrorCode of

      jecInvalidArgument: Result := 'Invalid argument value when calling Chakracore API ''%s''';
      jecNullArgument: Result := 'Argument was null when calling Chakracore API ''%s''';
      jecOutOfMemory: Result := 'The Chakracore engine has run out of memory';

      else

        Result := WideFormat('An error with code %d has occurred', [Ord(ErrorCode)]);

    end;
  end;

  function GetExceptionMetadata: TJsValue;
  begin
    TryChakracoreAPI('JsGetAndClearExceptionWithMetadata', JsGetAndClearExceptionWithMetadata(Result));
  end;

  function GetScriptError: TScriptError;
  var
    Metadata: TJsValue;
  begin
    Metadata := GetExceptionMetadata;

    with Result do begin
      Line := GetIntProperty(Metadata, 'line');
      Column := GetIntProperty(Metadata, 'column');
      Source := GetStringProperty(Metadata, 'source');
      ScriptName := GetStringProperty(Metadata, 'url');

      Exception := GetProperty(Metadata, 'exception');

      Message := JsValueAsString(Exception);
    end;

  end;

  procedure TryChakracoreAPI;
  var
    Message: UnicodeString;
  begin
    if ErrorCode = jecNoError then Exit;

    Message := ErrorMessage(ErrorCode);

    case TJsErrorCode(Ord(ErrorCode) and $F0000) of

      jecScriptError: raise EChakracoreScriptError.Create(Message, GetScriptError);
      jecInvalidArgument, jecNullArgument: raise EChakracoreAPIError.Create(WideFormat(Message, [APIFunctionName]));

      else
        raise EChakracoreError.Create(Message);

    end;

  end;

  constructor EChakracoreScriptError.Create;
  begin
    Message := aScriptError.Message;
    ScriptError := aScriptError;
  end;

  function CreateError(Message: TJsValue): TJsValue;
  begin
    TryChakracoreAPI('JsCreateError', JsCreateError(Message, Result));
  end;

  procedure SetException(Message: TJsValue);
  begin
    TryChakracoreAPI('JsSetException', JsSetException(CreateError(Message)));
  end;

  procedure ThrowError;
  var
    Message: TJsValue;
  begin
    Message := StringAsJsString(WideFormat(Fmt, Params));
    SetException(Message);
  end;

end.

