unit WinjsOS;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetWinjsOS: TJsValue;

implementation

  uses
    Chakra, ChakraUtils, SysUtils;

  function OSNow(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := StringAsJsString(FormatDateTime('yyyy"-"m"-"d h:m":"s":"z', Now));
  end;

  function GetWinjsOS;
  begin

    Result := CreateObject;

    SetFunction(Result, 'now', OSNow);

  end;

end.