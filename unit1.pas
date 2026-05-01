unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, Grids, StdCtrls,
  RTTICtrls, DateTimePicker, TASeries, TAGraph, Math;

type
  matrizDatos = array of array of real;
  arrayDatos = array of real;
  { TForm1 }

  TForm1 = class(TForm)
    Chart1: TChart;
    Chart1BarSeries1: TBarSeries;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);

    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
  private


  public
    procedure cargarDatos(fils, cols: integer);


    procedure calMedXCol(fils, cols: integer);
    procedure calDesvXCol(fils, cols: integer);

    //metodos de normalizacion de datos numericos vistos en clase


    procedure normZscore(fils, cols: integer);

    procedure minMax(fils, cols: integer);
    function minimoColumna(fils, j: integer): real;
    function maximoColumna(fils, j: integer): real;
    function nuevoMin(): string;
    function nuevoMax(): string;

    procedure escDecimal(fils, cols: integer);
    function obtenerJ(maxA: real): real;
    function obtValAbsMax(fils, j: integer): real;

    //graficas
    procedure graficaBarras(fils, cols, clases: integer);
  end;

var
  Form1: TForm1;
  dataSet: matrizDatos;

  F:Textfile;

implementation

uses
  Unit3, Unit4, Unit5;

{$R *.lfm}

{ TForm1 }

procedure TForm1.cargarDatos(fils, cols: integer);
//datos en visualización y almacenados en una matriz para operar
var
  i,j: integer;
begin
  SetLength(dataSet, fils, cols);
  //showmessage(inttostr(StringGrid1.RowCount)+ ' ' +  inttostr(StringGrid1.ColCount));
  //primero cargo todos los datos por si necesito las cabeceras y las clases
//que seguramente m[as adelante
  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      dataSet[i,j]:= StrToFloat(StringGrid1.Cells[j,i]);

    end;
  end;
  //showmessage(floattostr(dataSet[0,cols-1]));

  //luego en un nuevo string grid que probablemente sea el 1 de nuevo?
  //lo dimensiono quitando la primera fila y la ultima columna porque
  //ahora mismo no quiero qu ese muestren
  StringGrid1.RowCount:=fils-1;
  StringGrid1.ColCount:= cols-1;

  //showmessage(inttostr(StringGrid1.RowCount)+ ' ' +  inttostr(StringGrid1.ColCount));
  //showmessage(inttostr(fils)+ ' ' +  inttostr(cols));
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

//calculo de la media + desviacion


//calculo de la media por columna
procedure TForm1.calMedXCol(fils, cols: integer);
var
  i,j: integer;
  sum: real;

begin
  //ajustar al stringgrid para que concuerde a todas las columnas
  StringGrid2.ColCount:= cols;

  for j:=0 to cols-1 do begin
    sum:= 0;

    for i:=0 to fils-1 do begin
      //cuando el encabezado indique que no es numerico simplemente saltamos esa
      //columna, no le calculamos la media (se tendran 0s)
      if dataSet[0,j] <> 0 then begin
        continue;
      end;
      //se reinician por columna a 0, cada uno tiene media y desv aparte
      sum:= sum + dataSet[i+1,j];
    end;
    //luego de recorrer una columna y tener la sumatoria, obtengo la media
    stringgrid2.Cells[j,0]:= FloatToStr(sum/Real(fils));
  end;

end;

//calculo de la desviacion estandar por columna
procedure TForm1.calDesvXCol(fils, cols: integer);
var
  i,j: integer;
  sumC: real;

begin
  //ajustar al stringgrid para que concuerde a todas las columnas
  StringGrid2.ColCount:= cols;

  for j:=0 to cols-1 do begin
    sumC:= 0;
    for i:=0 to fils-1 do begin
      //cuando el encabezado indique que no es numerico simplemente saltamos esa
      //columna, no le calculamos la media (se tendran 0s)
      if dataSet[0,j] <> 0 then begin
        continue;
      end;
      //se reinician por columna a 0, cada uno tiene media y desv aparte
      sumC:= sumC + power((dataSet[i+1,j] - strToFloat(stringgrid2.Cells[j,0])), 2);
    end;
    //luego de recorrer una columna y tener la sumatoria, obtengo la desvEst
    stringgrid2.Cells[j,1]:= FloatToStr(sqrt(sumC/Real(fils)));
  end;
end;

//normalizacion Z-Score
procedure TForm1.normZscore(fils, cols: integer);
var
  i,j: integer;
  norm: real;
begin

  Form2.StringGrid1.RowCount:=fils;
  Form2.StringGrid1.ColCount:=cols;

  //calcularMediaDS(fils, cols);
  //calcularDesvEstDS(fils, cols);

  //showmessage(floattostr(desvEstG)  + ' ' + floattostr(mediaG) );

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

//normalizacion min max y sus funciones necesarias para lograrlo
function TForm1.minimoColumna(fils, j: integer): real;
var
  i, b: integer;
  min: real;

begin
     b:=0;
       for i:=0 to fils-1 do begin
           if dataSet[0,j] <> 0 then begin
              continue;
           end;
           if (b = 0) then begin
              min:= dataSet[i+1,j];
              b:= 1;
           end;
           if (dataSet[i+1,j] < min) then begin
              min:= dataSet[i+1,j];
           end;
       end;
     minimoColumna:= min;
     //showMessage(floattostr(min));
end;

function TForm1.maximoColumna(fils, j: integer): real;
var
  i, b: integer;
  max: real;

begin
     b:= 0;
       for i:=0 to fils-1 do begin
           if dataSet[0,j] <> 0 then begin
              continue;
           end;
           if (b = 0) then begin
              max:= dataSet[i+1,j];
              b:= 1;
           end;

           if (dataSet[i+1,j] > max) then begin
              max:= dataSet[i+1,j];
           end;
       end;
     maximoColumna := max;
     //showMessage(floattostr(max));
end;

function TForm1.nuevoMin(): string;
begin

     nuevoMin:=inputBox('Configuración Min-Max', 'Nuevo mínimo:', '0');
end;

function TForm1.nuevoMax(): string;
begin
     nuevoMax:= inputBox('Configuración Min-Max', 'Nuevo máximo:', '1');

end;

procedure TForm1.minMax(fils, cols: integer);
var
   i,j: integer;
   norm, minA, maxA, newMax, newMin, v: real;

begin
     //resize del nuevo grid para mostrar datos normalizados
     Form3.StringGrid1.RowCount:=fils;
     Form3.StringGrid1.ColCount:=cols;

     newMax:= StrToFloat(nuevoMax());
     newMin:= StrToFloat(nuevoMin());


     for j:=0 to cols-1 do begin
         maxA:= maximoColumna(fils, j);
         minA:= minimoColumna(fils, j);
         for i:=0 to fils-1 do begin

         //saltar no numericos
                  if dataSet[0,j] <> 0 then begin
                     form3.StringGrid1.Cells[j,i] := FloatToStr(0);
                     continue;
                  end;

         //min max
         v:= dataSet[i+1,j];
         //showMessage(floattostr(v));
         norm := (((v - minA) / (maxA - minA))*(newMax - newMin)) + newMin;
         form3.StringGrid1.Cells[j,i] := FloatToStr(norm);

         end;

     end;

end;

//normalizacion escalado decimal y sus funciones necesarias para lograrlo

function TForm1.obtValAbsMax(fils, j: integer): real;
var
  i, b: integer;
  max: real;

begin
     b:= 0;

       for i:=0 to fils-1 do begin
           if dataSet[0,j] <> 0 then begin
              continue;
           end;
           if (b = 0) then begin
              max:= abs(dataSet[i+1,j]);
              b:= 1;
           end;

           if (abs(dataSet[i+1,j]) > max) then begin
              max:= abs(dataSet[i+1,j]);
           end;
       end;

     obtValAbsMax := max;
     //showMessage(floattostr(max));
end;

function TForm1.obtenerJ(maxA: real): real;
var
   j, aux: real;
begin
     //j  entero mas pequeño tal que maxAbs de v' sea < 1
     aux:= maxA;
     j:= 0;
     //divido al max hasta que sea < 1 con el 10^j correspondiente
     while maxA > 1 do begin
           j:= j + 1;
           maxA:= aux;
           maxA:= maxA / power(10.0, j);

     end;
     obtenerJ:= j;
end;

procedure TForm1.escDecimal(fils, cols: integer);
var
   i, k: integer;
   norm, maxA, j, v: real;
begin

     Form4.StringGrid1.RowCount:=fils;
     Form4.StringGrid1.ColCount:=cols;

     for k:=0 to cols-1 do begin

       maxA:= obtValAbsMax(fils, k);
       //showMessage(floatToStr(obtenerJ(maxA)));
       j:= obtenerJ(maxA);

       for i:=0 to fils-1 do begin

         //saltar no numericos
         if dataSet[0,k] <> 0 then begin
           form4.StringGrid1.Cells[k,i] := FloatToStr(0);
           continue;
         end;
         //escalado decimal
         v:= dataSet[i+1,k];
         //showMessage(floattostr(v));
         norm := v / power(10.0, j);
         form4.StringGrid1.Cells[k,i] := FloatToStr(norm);

       end;
     end;

end;

procedure TForm1.graficaBarras(fils, cols, clases: integer);
var
   i, r, g, b: integer;
   colF: real;
   contadores: array of integer;
begin
     contadores := nil;//solo para quitar la advertencia de abajo
     //showmessage(inttostr(fils) + ' ' + inttostr(cols) + ' ' + inttostr(clases));
     setLength(contadores, clases);
     for i:=0 to clases-1 do begin
         contadores[i]:= 0;
     end;

     //salto la primera fila
     for i:=1 to fils-1 do begin
         //showmessage(inttostr(round(dataset[i, cols-1])));
         contadores[round(dataset[i, cols-1])]:= contadores[round(dataset[i, cols-1])] + 1;
     end;

     //graficando
     //rgb propuesto para que cada una de las clases en teoria tenga un unico
     //color
     chart1barseries1.Clear;
     colF:= (5 * 3.1416 / 3) / (clases-1);
     for i:=0 to clases-1 do begin
         r:= Round(Sin(colF * i + (3.1416 / 2)) * 127 + 128);
         g := Round(Sin(colF * i + (3.1416 / 2) - (2.0 * 3.1416 / 3.0)) * 127 + 128);
         b := Round(Sin(colF * i + (3.1416 / 2) - (4.0 * 3.1416 / 3.0)) * 127 + 128);
         Chart1BarSeries1.Add(contadores[i], 'Clase: ' + inttostr(i), RGBToColor(r, g, b));
     end;



end;

//interaccion de elementos de la gui con funciones

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    StringGrid1.LoadFromCSVFile(OpenDialog1.FileName);
    cargarDatos(stringgrid1.RowCount, stringgrid1.ColCount);
    calMedXCol(stringgrid1.RowCount, stringgrid1.ColCount);
    calDesvXCol(stringgrid1.RowCount, stringgrid1.ColCount);
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.MenuItem10Click(Sender: TObject);
var
   clases: integer;
begin
  //showmessage(floattostr(dataset[0,stringgrid1.ColCount+1]));
  clases:= round(dataset[0,length(dataset[0])-1]);
  label4.Caption:='Distribución de clases';
  graficaBarras(round(length(dataset)), round(length(dataset[0])), clases);



end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin

end;



procedure TForm1.MenuItem4Click(Sender: TObject);
begin

end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
     normZscore(stringgrid1.RowCount, stringgrid1.ColCount);
     Form2.Show;

end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin

  minMax(stringgrid1.RowCount, stringgrid1.ColCount);
  Form3.Show;
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  escDecimal(stringgrid1.RowCount, stringgrid1.ColCount);
  Form4.Show;
end;

end.

