unit ChakraErr;

{$mode delphi}

interface

  uses ChakraTypes, SysUtils;

  type

    TScriptError = record
      Line: Integer;
      Column: Integer;
      Source: WideString;
      ScriptName: WideString;

      Message: WideString;

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

    EChakraError = class(Exception);

    EChakraAPIError = class(EChakraError);

    EChakraScriptError = class(EChakraError)
      ScriptError: TScriptError;

      constructor Create(aMessage: WideString; aScriptError: TScriptError);
    end;

  procedure TryChakraAPI(APIFunctionName: WideString; ErrorCode: TJsErrorCode);
  procedure ThrowError(Fmt: WideString; Params: array of const);

implementation

  uses chakracore_dll, Chakra;

  function ErrorMessage(ErrorCode: TJsErrorCode): WideString;
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
    TryChakraAPI('JsGetAndClearExceptionWithMetadata', JsGetAndClearExceptionWithMetadata(Result));
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

  procedure TryChakraAPI;
  var
    Message: WideString;
  begin
    if ErrorCode = jecNoError then Exit;

    Message := ErrorMessage(ErrorCode);

    case TJsErrorCode(Ord(ErrorCode) and $F0000) of

      jecScriptError: raise EChakraScriptError.Create(Message, GetScriptError);
      jecInvalidArgument, jecNullArgument: raise EChakraAPIError.Create(WideFormat(Message, [APIFunctionName]));

      else
        raise EChakraError.Create(Message);

    end;

  end;

  constructor EChakraScriptError.Create;
  begin
    Message := aScriptError.Message;
    ScriptError := aScriptError;
  end;

  function CreateError(Message: TJsValue): TJsValue;
  begin
    TryChakraAPI('JsCreateError', JsCreateError(Message, Result));
  end;

  procedure SetException(Message: TJsValue);
  begin
    TryChakraAPI('JsSetException', JsSetException(CreateError(Message)));
  end;

  procedure ThrowError;
  var
    Message: TJsValue;
  begin
    Message := StringAsJsString(WideFormat(Fmt, Params));
    SetException(Message);
  end;

end.

