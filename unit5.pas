unit Unit5;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, Spin,
  TAGraph, TASeries, Math;

type

  { TForm4 }

  TForm4 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    OpenDialog1: TOpenDialog;
    SpinEdit1: TSpinEdit;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    procedure dotExeAGNES(x,y, kclosters, fils: integer);
    procedure cargarDatosLimpios(fils, cols: integer);
    procedure listaXYparaDisp();
  public

  end;

var
  Form4: TForm4;
  dataSetLimpio: array of array of real;
  headers: array of integer;
  colores: array of TColor;
  ubCols: array of integer;
implementation
uses
  Unit3;
{$R *.lfm}

{ TForm4 }

{
Agradecido con el de arriba, AGNES [parece que es mucho codigo reutilizado
asi que espero que sea mas facil.
}
procedure TForm4.cargarDatosLimpios(fils, cols: integer);
{tstring para que sea mas facil cargar los datos
porque solo es con una linea, y claro, pasarlos a la matriz
limpia sin headers ni la ultima col
}
var
  i,j: integer;
begin

  {writeln(fils, ' ', cols);}
  SetLength(dataSetLimpio, fils, cols);
  SetLength(headers, cols);

  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      dataSetLimpio[i,j]:= StrToFloat(StringGrid1.Cells[j,i+1]);
    end;
  end;

  for i:=0 to cols-1 do begin
      headers[i]:= StrToInt(StringGrid1.Cells[i,0]);
  end;
  {
  Intente usar colores unicos para mi clase pero es cierto que en el modulo
  1 ya habia logrado que trataran de ser lo mas unicos posibles asi que no usare
  esto
    setlength(colores, 7);
  colores[0]:=clRed;
  colores[1]:=clNavy;
  colores[2]:=clLime;
  colores[3]:=clYellow;
  colores[4]:=clBlue;
  colores[5]:=clFuchsia;
  colores[6]:=clAqua;

  }


  listaXYparaDisp();

  stringgrid1.DeleteRow(0);

end;
{
facilito, agregar las listas de atributos que sean numericos para
ser clasificados
lo mismo, el truco es que ubcols guarda la ubicacion
real de las columnas, es de tam dinamico que es de acuerdo a
las cols numericas que halle,
entonces itemindex indica la posicion de ubcols pero lo que hay dentro es la col
real, easy
}
procedure TForm4.listaXYparaDisp();
var
   k, index, j: integer;
begin
       ubcols := nil;
       setlength(ubcols, 0);
       index:=-1;

       combobox1.Items.Clear;
       combobox2.Items.Clear;

       k:=0;
       //agregar valores para x/y
       for j:=0 to length(dataSetLimpio[0])-1 do begin
           index:=index + 1;
           //volvemos a saltar no numericos
           if headers[j] <> 0 then begin
              continue;
           end;

           setlength(ubCols, k+ 1);
           ubCols[k]:=index;
           k:=k+1;

           combobox1.items.add('Atributo X: ' + inttostr(k));
           combobox2.items.add('Atributo Y: ' + inttostr(k));
       end;
end;


procedure TForm4.Button2Click(Sender: TObject);
begin

  if (ComboBox1.ItemIndex = -1) or (ComboBox2.ItemIndex = -1) then
  begin
       ShowMessage('Por favor, elige un atributo válido. (˶º⤙º˶)');
       Exit;//no ejecuta lo de abajo
  end;

  if ComboBox1.ItemIndex = ComboBox2.ItemIndex then
  begin
       ShowMessage('Por favor, elige dos atributos distintos. (˶º⤙º˶)');
       Exit;//no ejecuta lo de abajo
  end;

  if spinedit1.Value = 1 then begin
     ShowMessage('... (˶º⤙º˶)');
  end;
  {graficaDisper(round(length(dataNorm)), combobox2.ItemIndex, combobox3.itemindex);}
  dotExeAGNES( ubCols[combobox1.ItemIndex],ubCols[ComboBox2.ItemIndex], spinedit1.Value, length(dataSetLimpio));

end;

procedure TForm4.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Form2.Show;
end;

procedure TForm4.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
      StringGrid1.LoadFromCSVFile(OpenDialog1.FileName);
      cargarDatosLimpios(stringgrid1.RowCount-1, stringgrid1.ColCount-1);
  end;
end;

{AGNESSS}
procedure TForm4.dotExeAGNES(x, y, kclosters, fils: integer);
var
  i, j: integer;
  noClustersnow: integer;
  idCluster: array of integer;
  distMin, dist,difX, difY: real;
  nodoA, nodoB, idNuevo, idPerdido: integer;
  clusterIDs: array of integer;
  totalUnicos:integer;
  yaEsta:boolean;
  nuevaSerie: TLineSeries;
  colF: real;
  r, g,b: integer;
begin

  noClustersnow:= fils;
  idCluster:= nil;
  SetLength(idCluster, noClustersnow);

  //BEGIN: aqui es donde todos empiezan siendo su propio cluster
  //todas las filas, como no se que clase es pues le asigno una n
  for i:= 0 to noClustersnow-1 do begin
    idCluster[i]:= i;
  end;

  //Ahora la fusion, mientras no lleguemos a los k clusters
  //que se quieren seguimos fusionando, con single linkage
  while noClustersnow > kclosters do begin
    {hay que ser optimistas y que esa no sea realmente la minima}
    distMin := 100000000000;
    nodoA := -1;
    nodoB := -1;

    {se buscan los puntos mas cercanos de clusters distintos

    }
    for i:=0 to fils-1 do begin
      for j:=i+1 to fils-1 do begin

        if idCluster[i] <> idCluster[j] then begin

          difx:= dataSetLimpio[i,x]-dataSetLimpio[j,x];
          difY:= dataSetLimpio[i,y]- dataSetLimpio[j,y];
          dist:=sqrt(sqr(difX)+sqr(difY));

          if dist < distMin then begin
            distMin:= dist;
            nodoA:= i;
            nodoB:= j;
          end;

        end;

      end;
    end;

    //ahora para la reasignacion de ID, que es basicamente
    //cuando encuentro los mas cercanos el del nodoA va a ser
    //representaante de grupo y se reduzcan los grupos
    //SIEMPRE nodoB toma el ID del nodoA
    idNuevo:= idCluster[nodoA];
    idPerdido:= idCluster[nodoB];
    for i:=0 to fils-1 do
      if idCluster[i] = idPerdido then begin
        idCluster[i]:= idNuevo;
      end;

    {El numero de clusters es prara saber cuando es que alcanzamos los k que
    el usuario pida}
    noClustersnow:= noClustersnow-1;
  end;

  //Aqui viene lo bueno
  //tal como lo hice en las graficas
  //de barras debo sbaer cuantas clases me quedaron
  //en este caso cuantos grupos, saber cuantos clusters reales hay
  //me permite usar la misma tecnica de colores para asignar colores que
  //traten de ser lo mas unicos posibles
  //sin embargo, los ids no son continuos sino que aparentemente se van quedando
  //como quieren asi que recorrer todo y ver si se conservo o murio
  clusterIDs:= nil;
  totalUnicos:= 0;
  for i:=0 to fils-1 do begin
    yaEsta:= False;     {}
    for j:=0 to totalUnicos-1 do
      if clusterIDs[j]=idCluster[i] then begin
        yaEsta:= True;
        break;
      end;
    if not yaEsta then begin
      SetLength(clusterIDs, totalUnicos + 1);
      clusterIDs[totalUnicos] := idCluster[i];
      totalUnicos := totalUnicos + 1;
    end;
  end;

  {Me estoy volviendo loco}


  {Todo indica que lo mejor es que para hacer los grupos
  cada grupo debe tener su propio lineseries
  }
  Chart1.ClearSeries;


  colF:= (5*3.1416/3)/Max(1,totalUnicos - 1);

  for j:= 0 to totalUnicos - 1 do begin
    // generamos el color para este cluster con tu formula
    r:=round(sin(colF*j + (3.1416/ 2)) *127+ 128);
    g:=round(sin(colF*j+ (3.1416/ 2)- (2.0*3.1416/3.0))*127+128);
    b:=round(sin(colF*j+(3.1416 /2)- (4.0*3.1416/3.0)) *127+ 128);

    //las series se agregan dinamicamente de acuerdo a los clusters
    nuevaSerie:= TLineSeries.Create(Chart1);
    {Todo el custom por aqui porque no encuentro lo que quiero en la gui}
    nuevaSerie.Title:= 'Cluster ' + IntToStr(j + 1);
    nuevaSerie.LineType:= ltNone;
    nuevaSerie.Pointer.Visible:= True;

    nuevaSerie.Pointer.Brush.Style:= bsSolid;
    nuevaSerie.Pointer.Brush.Color:= RGBToColor(r, g, b);

    nuevaSerie.Pointer.Pen.Color:= clBlack;

    Chart1.AddSeries(nuevaSerie);

    //{Los puntos que pertenecen a dicho cluster
    for i:= 0 to fils-1 do begin
      if idCluster[i] = clusterIDs[j] then
        nuevaSerie.AddXY(dataSetLimpio[i,x], dataSetLimpio[i,y]);
    end;
  end;
  {Nuevo aditamento desbloqueado, se pueden poner labels}
  Chart1.Legend.Visible := True;

  idCluster  := nil;
  clusterIDs := nil;
end;

end.

