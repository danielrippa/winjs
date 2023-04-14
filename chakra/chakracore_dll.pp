unit chakracore_dll;

{$mode delphi}

interface

  uses ChakraTypes, ChakraErr;

  const dll = 'chakracore.dll';

  function JsCreateRuntime(Attributes: Cardinal; ThreadService: TJsThreadServiceFunc; out Runtime: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsCreateContext(Runtime: TJsValue; out NewContext: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsGetCurrentContext(out CurrentContext: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsSetCurrentContext(Context: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsRun(Script: TJsValue; SourceContext: UIntPtr; SourceUrl: TJsValue; ParseAttributes: TJsParseScriptAttributeSet; out Result: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsRunScript(Script: PWideChar; SourceContext: UintPtr; SourceUrl: PWideChar; out Result: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsGetGlobalObject(out GlobalObject: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsGetAndClearExceptionWithMetadata(out metadata: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsCreateExternalArrayBuffer(Data: Pointer; ByteLength: Cardinal; FinalizeCallback: TJsFinalizeProc; CallbackState: Pointer; out Result: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsCreateNamedFunction(FunctionName: TJsValue; NativeFunction: TJsNativeFunc; CallbackState: Pointer; out FunctionValue: TJSvalue): TJsErrorCode; stdcall; external dll;
  function JsConvertValueToString(Value: TJsValue; out StringValue: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsObjectGetProperty(Instance, Key: TJsValue; out Value: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsObjectSetProperty(Instance, Key, Value: TJsValue; UseStrictRules: ByteBool): TJsErrorCode; stdcall; external dll;
  function JsCopyStringUtf16(Value: TJsValue; Start: Integer; Length: Integer; Buffer: PUnicodeChar; Written: PNativeUInt): TJsErrorCode; stdcall; external dll;
  function JsCreateStringUtf16(Content: PUnicodeChar; Length: NativeUInt; out Value: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsNumberToInt(Value: TJsValue; out IntValue: Integer): TJsErrorCode; stdcall; external dll;
  function JsIntToNumber(IntValue: Integer; out Value: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsBoolToBoolean(BooleanValue: ByteBool; out Value: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsBooleanToBool(BooleanValue: TJsValue; out Value: ByteBool): TJsErrorCode; stdcall; external dll;
  function JsGetUndefinedValue(out UndefinedValue: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsCreateObject(out Value: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsCreateArray(ItemCount: Cardinal; out ArrayValue: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsSetIndexedProperty(ArrayValue, ItemIndex, Value: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsCreateError(Message: TJsValue; out Error: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsSetException(Error: TJsValue): TJsErrorCode; stdcall; external dll;
  function JsGetValueType(Value: TJsValue; out ValueType: TJsValueType): TJsErrorCode; stdcall; external dll;
  function JsCallFunction(Func: TJsValue; Args: PJsValue; ArgCount: Word; out ResultValue: TJsValue): TJsErrorCode; stdcall; external dll;

implementation

end.