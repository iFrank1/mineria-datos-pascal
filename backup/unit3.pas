unit Unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;
  F: Textfile;

implementation
uses
  Unit1;

{$R *.lfm}

{ TForm2 }

procedure TForm2.Button1Click(Sender: TObject);
var
  i: integer;
begin
  if savedialog1.Execute then begin
    AssignFile(F,Savedialog1.FileName);

    {$I-}
         rewrite(F);  //crear archivo...si existe Sobre escribe y destruye
    {$I+}

    if IOResult=0 then
    begin

      for i:= 0 to stringgrid1.RowCount-1 do begin

        Writeln(F,stringgrid1.Rows[i].CommaText);

      end;
      closefile(F);
    end;
  end;

end;

procedure TForm2.FormCreate(Sender: TObject);
begin

end;

end.

