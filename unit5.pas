unit Unit5;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids;

type

  { TForm4 }

  TForm4 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private

  public

  end;

var
  Form4: TForm4;
  F: Textfile;
implementation

{$R *.lfm}

{ TForm4 }

procedure TForm4.Label1Click(Sender: TObject);
begin

end;

procedure TForm4.Button1Click(Sender: TObject);
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

end.

