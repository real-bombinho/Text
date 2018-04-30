unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.StdCtrls, System.ImageList, Vcl.ImgList,
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
  OpenTextFileDialog1.Filter := 'Text files (*.txt)|*.TXT|CSV files (*.csv)|*.CSV|Any file (*.*)|*.*';
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
    openFile(OpenTextFileDialog1.FileName);
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
    while (tsFile.ReadLn(sLine)) and (i < 1000) do
    begin
      Memo1.Lines.Add(sLine);
      inc(i);
    end;
  finally
    tsFile.Free;
  end;
end;

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
      if pos(UpperCase(SearchFor), Uppercase(FindIn.Strings[i]), 1) <> 0 then
      begin
        lastfound := i;
        result := i;
        exit;
      end;
    end
    else
    begin
      if pos(SearchFor, FindIn.Strings[i], 1) <> 0 then
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
