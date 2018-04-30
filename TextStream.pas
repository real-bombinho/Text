unit TextStream;

interface

uses System.Classes, System.SysUtils;

type
  TTextStream = class(TObject)
    private
      FHost: TStream;
      FOffset,FSize: Integer;
      FBuffer: array[0..1023] of Char;
      FEOF: Boolean;
      function FillBuffer: Boolean;
    protected
      property Host: TStream read FHost;
    public
      constructor Create(AHost: TStream);
      destructor Destroy; override;
      function ReadLn: string; overload;
      function ReadLn(out Data: string): Boolean; overload;
      property EOF: Boolean read FEOF;
      property HostStream: TStream read FHost;
      property Offset: Integer read FOffset write FOffset;
    end;

implementation


{ TTextStream }

constructor TTextStream.Create(AHost: TStream);
begin
  FHost := AHost;
  FillBuffer;
end;

destructor TTextStream.Destroy;
begin
  FHost.Free;
  inherited Destroy;
end;

function TTextStream.FillBuffer: Boolean;
begin
  FOffset := 0;
  FSize := FHost.Read(FBuffer,SizeOf(FBuffer));
  Result := FSize > 0;
  FEOF := Result;
end;

function TTextStream.ReadLn(out Data: string): Boolean;
var
  Len, Start: Integer;
  EOLChar: Char;
  s: AnsiString;
begin
  Data := ''; s := '';
  Result := False;
  repeat
    if FOffset >= FSize then
      if not FillBuffer then
        Exit; // no more data to read from stream -> exit
    Result := True;
    Start := FOffset;
    while (FOffset<FSize) and (not CharinSet(FBuffer[FOffset], [#13,#10])) do
      Inc(FOffset);
    Len := FOffset-Start;
    if Len > 0 then
    begin
      SetLength(s, Length(s) + Len);
      Move(FBuffer[Start], s[Succ(Length(s)-Len)], Len);
      Data := string(s);
    end else
      Data := '';
  until FOffset <> FSize; // EOL char found
  EOLChar := FBuffer[FOffset];
  Inc(FOffset);
  if (FOffset = FSize) then
    if not FillBuffer then
      Exit;
  if CharInSet(FBuffer[FOffset], [#13,#10]-[EOLChar]) then begin
    Inc(FOffset);
    if (FOffset = FSize) then
      FillBuffer;
  end;
end;

function TTextStream.ReadLn: string;
begin
  ReadLn(Result);
end;

end.
