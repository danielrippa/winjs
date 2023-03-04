unit ChakraUtils;

{$mode delphi}

interface

  uses ChakraTypes;

  procedure CheckParams(FunctionName: UnicodeString; Args: PJsValue; ArgCount: Word; ArgTypes: array of TJsValueType; MandatoryCount: Integer);

implementation

  uses ChakraErr, SysUtils, Chakra;

  function JsTypeName(Value: TJsValueType): UnicodeString;
  begin
    case Value of
      JsUndefined: Result := 'Undefined';
      JsNull: Result := 'Null';
      JsNumber: Result := 'Number';
      JsString: Result := 'String';
      JsBoolean: Result := 'Boolean';
      JsObject: Result := 'Object';
      JsFunction: Result := 'Function';
      JsError: Result := 'Error';
      JsArray: Result := 'Array';
      JsSymbol: Result := 'Symbol';
      JsArrayBuffer: Result := 'ArrayBuffer';
      JsTypedArray: Result := 'TypedArray';
      JsDataView: Result := 'DataView';
    end;
  end;

  procedure CheckParams;
  var
    I: Integer;
    Value: TJsValue;
    ValueType: TJsValueType;
    RequiredTypeName, ValueTypeName: UnicodeString;
    ValueString: UnicodeString;
  begin
    if MandatoryCount > ArgCount then begin
      ThrowError('Not enough parameters when calling ''%s''. %d parameters expected but %d parameters given', [FunctionName, MandatoryCount, ArgCount]);
    end;

    for I := 0 to Length(ArgTypes) - 1 do begin

      Value := Args^; Inc(Args);

      ValueType := GetValueType(Value);

      if ValueType <> ArgTypes[I] then begin

        ValueTypeName := JsTypeName(ValueType);
        ValueString := JsValueAsString(Value);

        RequiredTypeName := JsTypeName(ArgTypes[I]);

        ThrowError('Error calling ''%s''. Argument[%d] (%s)%s must be %s', [ FunctionName, I, ValueTypeName, ValueString, RequiredTypeName ]);

      end;
    end;
  end;

end.