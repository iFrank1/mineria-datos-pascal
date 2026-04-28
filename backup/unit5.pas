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
    procedure Label1Click(Sender: TObject);
  private

  public

  end;

var
  Form4: TForm4;

implementation

{$R *.lfm}

{ TForm4 }

procedure TForm4.Label1Click(Sender: TObject);
begin

end;

end.

