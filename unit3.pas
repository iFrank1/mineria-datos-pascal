unit Unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Math;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Shape1: TShape;
    Shape10: TShape;
    Shape11: TShape;
    Shape12: TShape;
    Shape13: TShape;
    Shape14: TShape;
    Shape15: TShape;
    Shape16: TShape;
    Shape17: TShape;
    Shape18: TShape;
    Shape19: TShape;
    Shape2: TShape;
    Shape20: TShape;
    Shape21: TShape;
    Shape22: TShape;
    Shape23: TShape;
    Shape24: TShape;
    Shape25: TShape;
    Shape26: TShape;
    Shape27: TShape;
    Shape28: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Shape9: TShape;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Shape17Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

uses
  Unit1;
{$R *.lfm}

{ TForm2 }

procedure TForm2.Image1Click(Sender: TObject);
begin

end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  Self.Hide;
  Form1.Show;

end;


procedure TForm2.Button2Click(Sender: TObject);
begin

end;


procedure TForm2.Button3Click(Sender: TObject);
begin

end;



procedure TForm2.Image2Click(Sender: TObject);
begin

end;

procedure TForm2.Label1Click(Sender: TObject);
begin

end;

procedure TForm2.Label3Click(Sender: TObject);
begin

end;

procedure TForm2.Shape17Click(Sender: TObject);
begin

end;

procedure TForm2.Timer1Timer(Sender: TObject);
const
  velocidad=3;
  distanciaUnion = 100;
var
  i,j: integer;
  nodoa, nodob:TControl;
  centroAX, centroAY, centroBX, centroBY: integer;
begin
  panel1.Repaint;

  for i:=0 to self.componentCount-1 do begin

    if (self.Components[i] is TShape) and (TShape(self.components[i]).name <> 'ShapeFondo') then begin

       nodoa := TControl(self.components[i]);
      nodoa.left := nodoa.Left+randomRange(-velocidad, velocidad+1);
      nodoa.Top := nodoa.Top+randomRange(-velocidad,velocidad+1);

      if nodoa.left < 0 then nodoa.left := 0;
      if nodoa.Top < 0 then nodoa.top := 0;
      if nodoa.left > panel1.width-nodoa.Width then nodoa.left:=panel1.Width-nodoa.Width;
      if nodoa.top > panel1.height-nodoa.height then nodoa.Top:=Panel1.height-nodoa.Height;
    end;
  end;

  panel1.Canvas.Pen.Color:= $00606060;
  panel1.Canvas.Pen.Width:= 1;

  for i:=0 to self.ComponentCount-1 do begin
      if (self.Components[i] is TShape) and (TShape(self.components[i]).name <> 'ShapeFondo') then begin
        nodoa:= tcontrol(self.Components[i]);

        centroAX := nodoA.Left + (nodoA.Width div 2);
        centroAY := nodoa.Top + (nodoA.Height div 2);

        for j:=i+1 to self.componentCount-1 do begin
            if (self.Components[i] is TShape) and (TShape(self.components[i]).name <> 'ShapeFondo') then begin

              nodob:= TControl(self.components[j]);
              CentroBX:= nodoB.left+ (nodob.width div 2);
              CentroBY:= nodoB.Top+(nodob.Height div 2);

              if Hypot(CentroAX-CentroBX,CentroAY-CentroBY) < DistanciaUnion then
              begin
                panel1.Canvas.MoveTo(CentroAX, CentroAY);
                Panel1.Canvas.LineTo(CentroBX, CentroBY);
              end;

            end;
        end;


      end;
  end;
end;

end.

