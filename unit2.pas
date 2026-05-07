unit Unit2;

{$mode objfpc}{$H+}

interface

procedure QuickSort(var arr: array of real; izq, der: integer);

implementation


function Particion(var arr:array of real; izq, der: integer): integer;
var
  i, j: integer;
  pivote, temp: real;
begin
  pivote:= arr[der];
  i:= izq-1;

  for j:= izq to der-1 do
  begin
    if arr[j] <= pivote then
    begin
      Inc(i);

      temp:= arr[i];
      arr[i]:= arr[j];
      arr[j]:= temp;
    end;
  end;


  temp:=arr[i + 1];
  arr[i + 1]:= arr[der];
  arr[der]:=temp;

  Particion:= i + 1;
end;


procedure QuickSort(var arr: array of real; izq,der: integer);
var
  pivotePos: integer;
begin
  if (izq < der) then
  begin
    pivotePos := Particion(arr, izq, der);
    QuickSort(arr, izq, pivotePos-1);
    QuickSort(arr, pivotePos +1,der);
  end;
end;

end.
