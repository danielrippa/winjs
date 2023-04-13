unit Win32TextFile;

{$mode delphi}

interface

  uses
    SysUtils;

  function ReadTextFileContent(FilePath: WideString; out Content: WideString): Boolean;
  function WriteTextFileContent(FilePath, Content: WideString): Boolean;
  function AppendTextFileLine(FilePath, Line: String): Boolean;

implementation

  uses
    Classes, Windows;

  function ReadTextFileContent;
  var
    FileStream: TFileStream;
    S: UTF8String;
  begin
    Result := False;

    FileStream := TFileStream.Create(FilePath, fmOpenRead);
    try

      if FileStream.Size = 0 then Exit;

      with FileStream do begin
        SetLength(S, Size);
        Read(S[1], Size);

        Content := UTF8String(S);

        Result := True;
      end;

    finally
      FileStream.Free;
    end;

  end;


  function WriteTextFileContent;
  var
    FileContent: String;
  begin
    Result := False;
    try
      FileContent := UTF8Encode(Content);
      with TFileStream.Create(FilePath, fmCreate) do begin
        Write(FileContent[1], Length(FileContent));
        Free;
      end;

      Result := True;
    except
    end;
  end;

  function AppendTextFileLine;
  const
    FILE_APPEND_DATA = 4;
    OPEN_ALWAYS = 4;
  var
    Handle: THandle;
    Stream: THandleStream;
  begin

    Handle := CreateFile(PChar(FilePath), FILE_APPEND_DATA, 0, Nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if Handle <> INVALID_HANDLE_VALUE then begin
      try

        Stream := THandleStream.Create(Handle);

        try
          Line := Line + #13#10;
          Stream.WriteBuffer(Line[1], Length(Line) * SizeOf(Char));
        finally
          Stream.Free;
        end;

      finally
        FileClose(Handle);
      end;
    end;

  end;

end.
