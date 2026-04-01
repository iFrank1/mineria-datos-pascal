unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, Grids, StdCtrls,
  RTTICtrls;

type
  matrizDatos = array of array of real;

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure MenuItem2Click(Sender: TObject);

    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
  private


  public
    procedure cargarDatos(fils, cols: integer);

    procedure calMed(fils, cols: integer);

    procedure normZscore(fils, cols: integer);

  end;

var
  Form1: TForm1;
  dataSet: matrizDatos;
  F:Textfile;

implementation

uses
  Unit3;

{$R *.lfm}

{ TForm1 }

procedure TForm1.cargarDatos(fils, cols: integer);
//datos en visualización y almacenados en una matriz para operar
var
  i,j: integer;
begin
  SetLength(dataSet, fils, cols);

  //primero cargo todos los datos por si necesito las cabeceras y las clases
//que seguramente m[as adelante
  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      dataSet[i,j]:= StrToFloat(StringGrid1.Cells[j,i]);

    end;
  end;

  //luego en un nuevo string grid que probablemente sea el 1 de nuevo?
  //lo dimensiono quitando la primera fila y la ultima columna porque
  //ahora mismo no quiero qu ese muestren
  StringGrid1.RowCount:=fils-1;
  StringGrid1.ColCount:= cols-1;

  //cargo los datos en mi nuevo grid ya sin la cabecera y ultima columna
  for i:=0 to stringgrid1.RowCount-1 do begin
    for j:=0 to stringgrid1.ColCount-1 do begin
      StringGrid1.Cells[j,i]:= FloatToStr(dataSet[i+1,j]);
    end;
  end;

  {
  pruebas con un grid aparte en el que iba viendo que no me saltara datos
  StringGrid2.RowCount:=fils-1;
  StringGrid2.ColCount:= cols-1;

  //cargo los datos en mi nuevo grid ya sin la cabecera y ultima columna
  for i:=0 to stringgrid2.RowCount-1 do begin
    for j:=0 to stringgrid2.ColCount-1 do begin
      StringGrid2.Cells[j,i]:= FloatToStr(dataSet[i+1,j]);
    end;
  end;

  }

end;

//calculo de la mediana
procedure TForm1.calMed(fils, cols: integer);
var
  i,j: integer;
  sum: real;
  med: real;
  sumC: real;

  //tengo la matriz del form y se cuantas columnas
  //que corresponde al stringgrid1
begin
  //ajustar al stringgrid para que concuerde a todas las columnas
  StringGrid2.ColCount:= cols;



  for j:=0 to cols-1 do begin
    sum:= 0;
    sumC:= 0;

    for i:=0 to fils-1 do begin
      //cuando el encabezado indique que no es numerico simplemente saltamos esa
      //columna, no le calculamos la media (se tendran 0s)
      if dataSet[0,j] <> 0 then begin
        continue;
      end;
      sum:= sum + dataSet[i+1,j];
      sumC:= sumC + sqr(dataSet[i+1,j]);
    end;

    //luego de recorrer una columna y tener la sumatoria, obtengo la media
    stringgrid2.Cells[j,0]:= FloatToStr(sum/Real(fils));
    med:=sum/Real(fils);
    //como ya tengo la media hago la desviacion estandar
    stringgrid2.Cells[j,1]:= FloatToStr(sqrt((sumC/Real(fils))-sqr(med)));
  end;

end;

procedure TForm1.normZscore(fils, cols: integer);
var
  i,j: integer;
  norm: real;
begin

  Form2.StringGrid1.RowCount:=fils;
  Form2.StringGrid1.ColCount:=cols;

  for j:=0 to cols-1 do begin
    for i:=0 to fils-1 do begin

      //seguimos saltando no numericos
      if dataSet[0,j] <> 0 then begin
        form2.StringGrid1.Cells[j,i] := FloatToStr(0);
        continue;
      end;
      //z score
      norm := (dataSet[i+1,j] - StrToFloat(StringGrid2.Cells[j,0])) / StrToFloat(StringGrid2.Cells[j,1]);
      form2.StringGrid1.Cells[j,i] := FloatToStr(norm);

    end;
  end;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    StringGrid1.LoadFromCSVFile(OpenDialog1.FileName);
    cargarDatos(stringgrid1.RowCount, stringgrid1.ColCount);
    calMed(stringgrid1.RowCount, stringgrid1.ColCount);

  end;

end;



procedure TForm1.MenuItem4Click(Sender: TObject);
begin

end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
     normZscore(stringgrid1.RowCount, stringgrid1.ColCount);
     Form2.Show;

end;

end.

