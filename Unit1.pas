unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.StdCtrls,  Vcl.ImgList,
  System.StrUtils, //  System.ImageList,
  TextStream;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    OpenTextFileDialog1: TOpenTextFileDialog;
    ImageList1: TImageList;
    ToolButton2: TToolButton;
    Edit1: TEdit;
    CheckBox1: TCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fileName: string;
    lastFound: longint;
    fileList: TStringList;
    procedure openFile(const FName: string);
    procedure openPDFFile(const FName: string);
    function findNext(FindIn: TStrings; const SearchFor: string): longint;
    procedure debugShow(const s: string);
  protected
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses ShellAPI;

procedure TForm1.FormCreate(Sender: TObject);
begin
  OpenTextFileDialog1.Filter := 'Text files (*.txt)|*.TXT|CSV files (*.csv)|*.CSV|PDF files (*.pdf)|*.PDF|Any file (*.*)|*.*';
  fileList := TStringList.Create;
  DragAcceptFiles(Handle, True);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  DragAcceptFiles(Handle, False);
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  if OpenTextFileDialog1.Execute(Form1.Handle) then
  begin
    if AnsiLowerCase(RightStr(OpenTextFileDialog1.FileName, 4)) = '.pdf' then
      openPDFFile(OpenTextFileDialog1.FileName)
    else
      openFile(OpenTextFileDialog1.FileName);
    Form1.Caption := OpenTextFileDialog1.FileName;
  end;
end;

procedure TForm1.OpenFile(const FName: string);
var
  sLine: string;
  i: integer;
  tsFile: TTextStream;
begin
  fileName := FName;
  Memo1.Lines.Clear;
  tsFile := TTextStream.Create(TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite));
  tsFile.debug := DebugShow;
  try
    i := 0;
    while (tsFile.ReadLn(sLine)) and (i < 1000) do      //Limit for 1000 Lines
    begin
      Memo1.Lines.Add(sLine);
      inc(i);
    end;
  finally
    tsFile.Free;
  end;
end;

procedure TForm1.OpenPDFFile(const FName: string);
var
  sLine: string;
  i: integer;
  tsFile: TTextStream;
  ignore: boolean;
begin
  fileName := FName;
  Memo1.Lines.Clear;
  tsFile := TTextStream.Create(TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite));
  tsFile.debug := DebugShow;
  try
    i := 0;
    ignore := false;
    while (tsFile.ReadLn(sLine)) do      //no Limit for 1000 Lines
    begin
      if not ignore then
      begin
        if AnsiLowercase(RightStr(sLine, 6)) = 'stream' then
        begin
          ignore := true;
          Memo1.Lines.Add(sLine);
          Memo1.Lines.Add( '...');
        end
        else
          Memo1.Lines.Add(sLine);
      end
      else
        if pos('endstream', AnsiLowercase(sLine)) <> 0 then
        begin
          Memo1.Lines.Add(RightStr(sLine, 9){sLine});
          //showmessage(sline);
          ignore := false;
        end;

      inc(i);
    end;
  finally
    tsFile.Free;
  end;
end;

{procedure TForm1.OpenDatFile(const FName: string);
var
  sLine: string;
  i, x, y, n: integer;
  tsFile: TTextStream;
  isBoilerTable: boolean;
  pa: array[0..60] of string;
begin
  fileName := FName;
  Memo1.Lines.Clear;
  isBoilerTable := false;
  tsFile := TTextStream.Create(TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite));
  tsFile.debug := DebugShow;
  try
    i := 0;
    while (tsFile.ReadLn(sLine)) and (i < 20) do      //Limit for 1000 Lines
    begin
      if pos('$105', sLine) <> 0 then
      begin
        // Memo1.Lines.Add(sLine);
        if copy(sLine, length(sline)-1, 2) = ',1' then isBoilerTable := true;
      end;
      if isBoilerTable and ((pos('#', sLine) <> 1) and (pos('$', sline) <> 1)) then
      begin
        Memo1.Lines.Add(sLine);
        x := 1; y := 0; n := 0;
        while (y < length(sLine)) and (n < 61) do
        begin
          y := pos(',', copy(sLine, x, length(sLine) - x + 1)) + x -1;   //showmessage(inttostr(x) + ' , ' + inttostr(y));
          pa[n] := copy(sline, x , y - x);
          x := y + 1; inc(n);
        end;
        inc(i);  showmessage(pa[0] + ' | ' + pa[1] + ' | ' + pa[2] + ' | ' + pa[21] + ' | ' + pa[24]);
      end;
    end;
  finally
    tsFile.Free;
  end;
end;}

procedure TForm1.ToolButton2Click(Sender: TObject);
var lineNo, linePos : integer;
begin
  lineNo := findNext(Memo1.Lines, edit1.Text);
  if lineNo <> -1 then
  begin
    with Memo1 do
    begin
      if CheckBox1.Checked then
        linePos := pos(uppercase(edit1.Text), uppercase(Memo1.Lines[lineNo]))
      else
        linePos := pos(edit1.Text, Memo1.Lines[lineNo]);
      SelStart := Perform(EM_LINEINDEX, LineNo, 0) + linePos -1;
      Memo1.SelLength := length(Edit1.Text);
      Perform(EM_SCROLLCARET, 0, 0);
      Memo1.SetFocus;
    end;
  end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  lastFound := -1;
end;

function TForm1.findNext(FindIn: TStrings; const SearchFor: string): longint;
var i: longint;
begin
  result := -1;
  For i := (lastfound + 1) to FindIn.Count - 1 do
  begin
    if CheckBox1.Checked then
    begin
      if pos(AnsiUpperCase(SearchFor), AnsiUppercase(FindIn.Strings[i]){, 1}) <> 0 then
      begin
        lastfound := i;
        result := i;
        exit;
      end;
    end
    else
    begin
      if pos(SearchFor, FindIn.Strings[i]{, 1}) <> 0 then
      begin
        lastfound := i;
        result := i;
        exit;
      end;
    end;
  end;
  if result = -1 then
  begin
    lastfound := -1;
    showmessage('No further instances of "' + searchfor + '" could be found.');
  end;
end;

procedure TForm1.WMDropFiles(var Msg: TMessage);
var
  hDrop: THandle;
  fileCount: Integer;
  nameLen: Integer;
  i: Integer;
  s: string;

begin
  hDrop := Msg.wParam;
  fileCount:= DragQueryFile (hDrop , $FFFFFFFF, nil, 0);
  for i := 0 to fileCount - 1 do begin
    nameLen := DragQueryFile(hDrop, I, nil, 0) + 1;
    SetLength(s, NameLen);
    DragQueryFile(hDrop, I, Pointer(s), nameLen);
    fileList.Add(s);
  end;
  DragFinish(hDrop);
  if fileList.Count > 0 then
  begin
    openFile(FileList.Strings[0]);
    fileList.Clear;
  end;
end;

procedure TForm1.DebugShow(const s: string);
begin
  ShowMessage(s);
end;

end.
