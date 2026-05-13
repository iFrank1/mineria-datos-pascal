unit Unit4;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Buttons, StdCtrls, Grids, Spin, ColorBox, TAGraph;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Chart1: TChart;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    RadioGroup1: TRadioGroup;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    procedure cargarDatosLimpios(fils, cols: integer);
    procedure calcularProbabilidadesApr();
    procedure probabilidadesAtributoNum(columna: integer);
    procedure probabilidadesAtributoNom(columna: integer);
  public

  end;

var
  Form3: TForm3;
  {Elementos para cargar los datos, de manera global debido a que todas
  las funciones van a trabajar con estos datos. Además es un módulo aparte
  así que no lo quiero saturar tanto, de igual manera quiero que se vea un poco
  más limpio y chance modular aunque va a ser un poco más complejo. Veremos.}

  {SOLO CARGA DE DATOS}
  headers: array of integer;
  noClases: integer;
  dataSetLimpio: array of array of real;
  lastColumn: array of integer;
  {============================================================================}
  {PROBABILIDADES}
  probaprXclase: array of real;
  {VEROSIMILITUD}
  matrizMedias: array of array of real;
  matrizDesviacionesE: array of array of real;


implementation


{$R *.lfm}

{ TForm3 }

{------------------------------------------------------------------------------}
{Funciones para cargar los datos al stringgrid y pasarlos a arreglos que son más
manejables.}

procedure TForm3.cargarDatosLimpios(fils, cols: integer);

var
  i,j: integer;
begin
  {Ahora no pienso guardar los headers en el mismo arreglo de dataset porque
  en este módulo debido a que se siente más complejo mejor separo todo.

  Pienso mostrar en el stringgrid los datos, sin la fila de tipo de atributo
  pero si la de clases.}

  SetLength(dataSetLimpio, fils, cols);
  SetLength(headers, cols);
  SetLength(lastColumn, fils);

  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      dataSetLimpio[i,j]:= StrToFloat(StringGrid1.Cells[j,i+1]);
    end;
  end;

  for i:=0 to cols-1 do begin
      headers[i]:= StrToInt(StringGrid1.Cells[i,0]);
  end;

  noClases:=StrToInt(StringGrid1.Cells[cols,0]); {o simplemente i-1 jaja}

  for i:=1 to fils do begin
      lastColumn[i-1]:= StrToInt(StringGrid1.Cells[cols,i]);
  end;

  stringgrid1.DeleteRow(0);



  {----------------------------------DEBUG-------------------------------------}
  {
   Imprimir tamaño de matriz y stringgrid
   Imprimir valores de dataSetLimpio para ver que únicamente mantenga
   instancias.
   Imprimir headers para ver que se guarde toda la primera fila.
   Imprimir número de clases que es la última columna de la primera fila.
   Imprimir la última columna para ver que guardamos todas.
  }
  {


  writeln('Matriz: ', fils, 'x', cols);
  writeln('StringGrid: ', stringgrid1.RowCount, 'x', stringgrid1.ColCount);


  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      writeln(dataSetLimpio[i,j]);
    end;
    writeln();
  end;

  for i:=0 to cols-1  do begin
      writeln(headers[i]);

  end;
  writeln(length(headers));

  writeln(noClases);

  for i:=0 to fils-1 do begin
      writeln(lastColumn[i]);

  end;
  writeln(length(lastColumn));
  }


end;

{------------------------------------------------------------------------------}
{Función para calcular P(Ci), las probabilidades a priori de todas las clases.}

procedure TForm3.calcularProbabilidadesApr();
var
  i,s: integer;
  c: real;
  contadores: array of integer;
begin
  contadores:=nil;

  setLength(contadores, noClases);
  setLength(probaprXclase, noClases);
  for i:=0 to noClases-1 do begin
      contadores[i]:= 0;
  end;

  for i:=0 to length(lastColumn)-1 do begin
    contadores[lastColumn[i]]:= contadores[lastColumn[i]]+1;
  end;

  for i:=0 to noClases-1 do begin
    probaprXclase[i]:= contadores[i] / length(dataSetLimpio);
  end;


  {----------------------------------DEBUG-------------------------------------}
  {
   Imprimir el conteo por clase.
   Imprimir número de filas.
   Imprimir probabilidades por clase;
  }
  {
  s:=0;
  for i:=0 to noClases-1 do begin
    s:= s+contadores[i];
    writeln(i,contadores[i]);
  end;
  writeln(s);

  s:=length(dataSetLimpio);
  writeln(s);

  c:=0;
  for i:=0 to noClases-1 do begin
    writeln('Probabilidad de la clase: ',i, '= ', probaprXclase[i]);
    c:=c +   probaprXclase[i];
  end;
  writeln('Suma de probabilidades: ',c);
  }


end;
{------------------------------------------------------------------------------}
{Funciones para calcular P(Xk | Ci), que es la verosimilitud de los atributos
son dos porque para valores numéricos requerimos de la media y desviación
estándar, sin embargo, para atributos nominales solo es una división inmediata.
Para ello se dividieron para no tener la lógica de las 2 metidas dentro de una
única función, solo requerimos ver el tipo de dato y mandar a llamar la correct-
a.}
{Vamos necesitar donde guardar todos los datos de medias y desviaciones que van
a salir de las columnas así que usaremos matrizMedias y matrizDesviacionesE}
procedure TForm3.probabilidadesAtributoNum(columna: integer);
var
  i,j: integer;
  : array of array real;
  {AGRUPA LOS VALORES FLOTANTES SEGÚN SU CLASE}
begin
  for i:=0 to length(lastColumn)-1 do begin
      contadores[lastColumn[i]]:=
  end;
  {
    for i:=0 to length(lastColumn)-1 do begin
      contadores[lastColumn[i]]:= contadores[lastColumn[i]]+1;
    end;
  }

end;

procedure TForm3.probabilidadesAtributoNom(columna: integer);
begin

end;

procedure TForm3.Label2Click(Sender: TObject);
begin
  //idea podriamos poner colores de semaforo de acuerdo al nivel de exactidud
end;

procedure TForm3.Label3Click(Sender: TObject);
begin

end;

procedure TForm3.Button5Click(Sender: TObject);
begin

end;

procedure TForm3.Button4Click(Sender: TObject);
begin

end;

{--------------Conjunto de entrenamiento de Naive Bayes--------------}
procedure TForm3.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
      StringGrid1.LoadFromCSVFile(OpenDialog1.FileName);
      cargarDatosLimpios(stringgrid1.RowCount-1, stringgrid1.ColCount-1);
      calcularProbabilidadesApr();
  end;

end;

procedure TForm3.PageControl1Change(Sender: TObject);
begin

end;

end.

