unit Chakracore;

{$mode delphi}

interface

  uses ChakracoreTypes;

  function GetGlobalObject: TJsValue;

  function CreateExternalArrayBuffer(Value: UnicodeString): TJsValue;
  function EvalScriptSource(SourceContext: UIntPtr; ScriptSource, ScriptName: UnicodeString): TJsValue;

  function GetProperty(Instance: TJsValue; PropertyName: UnicodeString): TJsValue;
  function GetStringProperty(Instance: TJsValue; PropertyName: UnicodeString): UnicodeString;
  function GetIntProperty(Instance: TJsValue; PropertyName: UnicodeString): Integer;

  procedure SetProperty(Instance: TJsValue; PropertyName: UnicodeString; Value: TJsValue);

  function JsValueAsJsString(Value: TJsValue): TJsValue;
  function JsValueAsString(Value: TJsValue): UnicodeString;

  function JsStringAsString(Value: TJsValue): UnicodeString;
  function StringAsJsString(Value: UnicodeString): TJsValue;

  function IntAsJsNumber(Value: Integer): TJsValue;
  function JsNumberAsInt(Value: TJsValue): Integer;

  procedure SetFunction(Instance: TJsValue; FunctionName: UnicodeString; Callback: TJsFunctionFunc);

  function Undefined: TJsValue;
  function CreateObject: TJsValue;

  function CreateArray(ItemCount: Integer): TJsValue;
  procedure SetArrayItem(ArrayValue: TJsValue; ItemIndex: Integer; Value: TJsValue);

  function GetValueType(Value: TJsValue): TJsValueType;

implementation

  uses ChakracoreErrors, chakracore_dll;

  function GetGlobalObject;
  begin
    TryChakracoreAPI('JsGetGlobalObject', JsGetGlobalObject(Result));
  end;

  function CreateExternalArrayBuffer;
  begin

    TryChakracoreAPI(
      'JsCreateExternalArrayBuffer',

      JsCreateExternalArrayBuffer(
        //Pointer(PUnicodeChar(Value)),
        PUnicodeChar(Value),
        Length(Value) * SizeOf(UnicodeChar),
        Nil, Nil,
        Result
      )
    );

  end;

  function JsValueAsJsString;
  begin
    TryChakracoreAPI('JsConvertValueToString', JsConvertValueToString(Value, Result));
  end;

  function GetObjectProperty(Instance, PropertyName: TJsValue): TJsValue;
  begin
    TryChakracoreAPI('JsObjectGetProperty', JsObjectGetProperty(Instance, PropertyName, Result));
  end;

  function GetProperty;
  begin
    Result := GetObjectProperty(Instance, StringAsJsString(PropertyName));
  end;

  function GetStringProperty;
  begin
    Result := JsStringAsString(GetProperty(Instance, PropertyName));
  end;

  function GetIntProperty;
  begin
    Result := JsNumberAsInt(GetProperty(Instance, PropertyName));
  end;

  function JsStringLength(Value: TJsValue): Integer;
  begin
    TryChakracoreAPI('JsCopyStringUtf16', JsCopyStringUtf16(Value, 0, -1, Nil, @Result));
  end;

  function JsStringAsString;
  var
    StringValue: TJsValue;
    L: Integer;
  begin
    Result := '';

    StringValue := JsValueAsJsString(Value);
    L := JsStringLength(StringValue);

    if L > 0 then begin
      SetLength(Result, L);
      TryChakracoreAPI('JsCopyStringUtf16', JsCopyStringUtf16(StringValue, 0, L, PUnicodeChar(Result), Nil));
    end;
  end;

  function StringAsJsString;
  const
    Null: UnicodeChar = #0;
    PNull: PUnicodeChar = @Null;
  var
    P: PUnicodeChar;
  begin
    P := PUnicodeChar(Value);
    if not Assigned(P) then P := PNull;

    TryChakracoreAPI('JsCreateStringUtf16', JsCreateStringUtf16(P, Length(Value), Result));
  end;

  function JsNumberAsInt;
  begin
    TryChakracoreAPI('JsNumberToInt', JsNumberToInt(Value, Result));
  end;

  function IntAsJsNumber;
  begin
    TryChakracoreAPI('JsIntToNumber', JsIntToNumber(Value, Result));
  end;

  function EvalScriptSource;
  var
    Source, URL: TJsValue;
  begin
    Source := CreateExternalArrayBuffer(ScriptSource);
    URL := StringAsJsString(ScriptName);

    TryChakracoreAPI('JsRun', JsRun(Source, SourceContext, URL, [psaUtf16Encoded], Result));
  end;

  function JsValueAsString;
  begin
    Result := JsStringAsString(JsValueAsJsString(Value));
  end;

  function FunctionCallback(Callee: TJsValue; IsConstructCall: ByteBool; Args: PJsValue; ArgCount: Word; Callback: Pointer): TJsValue; stdcall;
  var
    Fn: TJsFunctionFunc;
  begin
    Fn := Callback;

    Inc(Args); Dec(ArgCount);

    Result := Fn(Args, ArgCount);
  end;

  function CreateNamedFunction(FunctionName: TJsValue; Callback: TJsFunctionFunc): TJsValue;
  begin
    TryChakracoreAPI('JsCreateNamedFunction', JsCreateNamedFunction(FunctionName, FunctionCallback, @Callback, Result));
  end;

  function Undefined;
  begin
    TryChakracoreAPI('JsGetUndefinedValue', JsGetUndefinedValue(Result));
  end;

  function CreateObject;
  begin
    TryChakracoreAPI('JsCreateObject', JsCreateObject(Result));
  end;

  procedure SetObjectProperty(Instance, PropertyName, Value: TJsValue);
  begin
    TryChakracoreAPI('JsObjectSetProperty', JsObjectSetProperty(Instance, PropertyName, Value, False));
  end;

  procedure SetProperty;
  begin
    SetObjectProperty(Instance, StringAsJsString(PropertyName), Value);
  end;

  procedure SetFunction;
  var
    Fn, Name: TJsValue;
  begin
    Name := StringAsJsString(FunctionName);
    Fn := CreateNamedFunction(Name, Callback);
    SetObjectProperty(Instance, Name, Fn);
  end;

  function CreateArray;
  begin
    TryChakracoreAPI('JsCreateArray', JsCreateArray(ItemCount, Result));
  end;

  procedure SetArrayItem;
  begin
    TryChakracoreAPI('JsSetIndexedProperty', JsSetIndexedProperty(ArrayValue, IntAsJsNumber(ItemIndex), Value));
  end;

  function GetValueType;
  begin
    TryChakracoreAPI('JsGetValueType', JsGetValueType(Value, Result));
  end;

end.