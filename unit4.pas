unit Unit4;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;
  F: Textfile;
implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.Button1Click(Sender: TObject);
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

