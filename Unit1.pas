unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.StdCtrls, System.ImageList, Vcl.ImgList,
  TextStream, search;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    OpenTextFileDialog1: TOpenTextFileDialog;
    ImageList1: TImageList;
    ToolButton2: TToolButton;
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    CheckBox1: TCheckBox;
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FileName: string;
    procedure ToolButton3Click(Sender: TObject);
    procedure ButtonSearchClick(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  OpenTextFileDialog1.Filter := 'Text files (*.txt)|*.TXT|CSV files (*.csv)|*.CSV|Any file (*.*)|*.*';
end;

procedure TForm1.ToolButton3Click(Sender: TObject);
var
  Encoding : TEncoding;
  EncIndex : Integer;
begin
  if OpenTextFileDialog1.Execute(Form1.Handle) then
  begin
    //selecting the filename and encoding selected by the user
    Filename := OpenTextFileDialog1.FileName;

    EncIndex := OpenTextFileDialog1.EncodingIndex;
    Encoding := OpenTextFileDialog1.Encodings.Objects[EncIndex] as TEncoding;

    //checking if the file exists
    if FileExists(Filename) then
      //display the contents in a memo based on the selected encoding
      Memo1.Lines.LoadFromFile(FileName, Encoding)
    else
      raise Exception.Create('File does not exist.');
    end;;
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
var
  sLine: string;
  i: integer;
  tsFile: TTextStream;
begin
  if OpenTextFileDialog1.Execute(Form1.Handle) then
  begin
    Filename := OpenTextFileDialog1.FileName;
    Memo1.Lines.Clear;
    tsFile := TTextStream.Create(TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite));
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
end;

procedure TForm1.ToolButton2Click(Sender: TObject);
begin
  //Memo1.Lines Form2.Search(Memo1.Lines);
end;

procedure TForm1.ButtonSearchClick(Sender: TObject);
var oldpos,newpos : integer;
    newtext       : string;
begin
  memo1.selstart:=memo1.selstart+1;
  memo1.sellength:=0;
  oldpos:=memo1.selstart;
  newtext := copy(memo1.text,memo1.selstart+1,length(memo1.text));
  newpos := Pos(edit1.text,newtext)-1;
  memo1.selstart:=oldpos+newpos;
  memo1.sellength:=length(edit1.text);
  Memo1.Perform(EM_SCROLLCARET, 0, 0);
  Memo1.SetFocus;
end;

end.
