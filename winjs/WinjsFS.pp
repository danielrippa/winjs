unit WinjsFS;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetWinjsFS: TJsValue;

implementation

  uses
    Chakra, ChakraUtils, SysUtils, WinjsUtils;

  function FsFileExists(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    FilePath: WideString;
  begin
    CheckParams('fileExists', Args, ArgCount, [jsString], 1);
    FilePath := JsstringAsString(Args^);

    Result := BooleanAsJsBoolean(FileExists(FilePath));
  end;

  function FsFolderExists(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    FilePath: WideString;
  begin
    CheckParams('folderExists', Args, ArgCount, [jsString], 1);
    FilePath := JsstringAsString(Args^);

    Result := BooleanAsJsBoolean(DirectoryExists(FilePath));
  end;

  function FsGetCurrentFolder(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := StringAsJsString(GetCurrentDir);
  end;

  function FsSetCurrentFolder(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('setCurrentFolder', Args, ArgCount, [jsString], 1);
    Result := BooleanAsJsBoolean(SetCurrentDir(JsStringAsString(Args^)));
  end;

  function FsReadTextFile(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aFileName: WideString;
  begin
    Result := Undefined;
    CheckParams('readTextFile', Args, ArgCount, [jsString], 1);

    aFileName := JsStringAsString(Args^);
    if not FileExists(aFileName) then Exit;

    Result := StringAsJsString(ReadUnicodeTextFileContent(aFileName));
  end;

  function GetWinjsFS;
  begin
    Result := CreateObject;

    SetFunction(Result, 'fileExists', FsFileExists);
    SetFunction(Result, 'folderExists', FsFolderExists);
    SetFunction(Result, 'getCurrentFolder', FsGetCurrentFolder);
    SetFunction(Result, 'setCurrentFolder', FsSetCurrentFolder);
    SetFunction(Result, 'readTextFile', FsReadTextFile);
  end;

end.