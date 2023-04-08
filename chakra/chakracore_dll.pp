unit chakracore_dll;

{$mode delphi}

interface

  uses ChakraTypes, ChakraErr;

  function JsCreateRuntime(Attributes: Cardinal; ThreadService: TJsThreadServiceFunc; out Runtime: TJsValue): TJsErrorCode; stdcall;
  function JsCreateContext(Runtime: TJsValue; out NewContext: TJsValue): TJsErrorCode; stdcall;
  function JsGetCurrentContext(out CurrentContext: TJsValue): TJsErrorCode; stdcall;
  function JsSetCurrentContext(Context: TJsValue): TJsErrorCode; stdcall;
  function JsRun(Script: TJsValue; SourceContext: UIntPtr; SourceUrl: TJsValue; ParseAttributes: TJsParseScriptAttributeSet; out Result: TJsValue): TJsErrorCode; stdcall;
  function JsGetGlobalObject(out GlobalObject: TJsValue): TJsErrorCode; stdcall;
  function JsGetAndClearExceptionWithMetadata(out metadata: TJsValue): TJsErrorCode; stdcall;
  function JsCreateExternalArrayBuffer(Data: Pointer; ByteLength: Cardinal; FinalizeCallback: TJsFinalizeProc; CallbackState: Pointer; out Result: TJsValue): TJsErrorCode; stdcall;
  function JsCreateNamedFunction(FunctionName: TJsValue; NativeFunction: TJsNativeFunc; CallbackState: Pointer; out FunctionValue: TJSvalue): TJsErrorCode; stdcall;
  function JsConvertValueToString(Value: TJsValue; out StringValue: TJsValue): TJsErrorCode; stdcall;
  function JsObjectGetProperty(Instance, Key: TJsValue; out Value: TJsValue): TJsErrorCode; stdcall;
  function JsObjectSetProperty(Instance, Key, Value: TJsValue; UseStrictRules: ByteBool): TJsErrorCode; stdcall;
  function JsCopyStringUtf16(Value: TJsValue; Start: Integer; Length: Integer; Buffer: PUnicodeChar; Written: PNativeUInt): TJsErrorCode; stdcall;
  function JsCreateStringUtf16(Content: PUnicodeChar; Length: NativeUInt; out Value: TJsValue): TJsErrorCode; stdcall;
  function JsNumberToInt(Value: TJsValue; out IntValue: Integer): TJsErrorCode; stdcall;
  function JsIntToNumber(IntValue: Integer; out Value: TJsValue): TJsErrorCode; stdcall;
  function JsBoolToBoolean(BooleanValue: ByteBool; out Value: TJsValue): TJsErrorCode; stdcall;
  function JsBooleanToBool(BooleanValue: TJsValue; out Value: ByteBool): TJsErrorCode; stdcall;
  function JsGetUndefinedValue(out UndefinedValue: TJsValue): TJsErrorCode; stdcall;
  function JsCreateObject(out Value: TJsValue): TJsErrorCode; stdcall;
  function JsCreateArray(ItemCount: Cardinal; out ArrayValue: TJsValue): TJsErrorCode; stdcall;
  function JsSetIndexedProperty(ArrayValue, ItemIndex, Value: TJsValue): TJsErrorCode; stdcall;
  function JsCreateError(Message: TJsValue; out Error: TJsValue): TJsErrorCode; stdcall;
  function JsSetException(Error: TJsValue): TJsErrorCode; stdcall;
  function JsGetValueType(Value: TJsValue; out ValueType: TJsValueType): TJsErrorCode; stdcall;
  function JsCallFunction(Func: TJsValue; Args: PJsValue; ArgCount: Word; out ResultValue: TJsValue): TJsErrorCode; stdcall;

implementation

  const dll = 'chakracore.dll';

  function JsCreateRuntime; external dll;
  function JsCreateContext; external dll;
  function JsGetCurrentContext; external dll;
  function JsSetCurrentContext; external dll;
  function JsRun; external dll;
  function JsGetGlobalObject; external dll;
  function JsGetAndClearExceptionWithMetadata; external dll;
  function JsCreateExternalArrayBuffer; external dll;
  function JsCreateNamedFunction; external dll;
  function JsConvertValueToString; external dll;
  function JsObjectGetProperty; external dll;
  function JsObjectSetProperty; external dll;
  function JsCopyStringUtf16; external dll;
  function JsCreateStringUtf16; external dll;
  function JsNumberToInt; external dll;
  function JsIntToNumber; external dll;
  function JsBoolToBoolean; external dll;
  function JsBooleanToBool; external dll;
  function JsGetUndefinedValue; external dll;
  function JsCreateObject; external dll;
  function JsCreateArray; external dll;
  function JsSetIndexedProperty; external dll;
  function JsCreateError; external dll;
  function JsSetException; external dll;
  function JsGetValueType; external dll;
  function JsCallFunction; external dll;

end.