unit ZGLMathProcs;

interface
uses OpenGl, Gl, Glu,
  Classes;

//typy
type
  wek=array[0..3] of GLfloat;

  TZGLPoint = record
    x, y: extended;
  end;

  TZGLRect = record
    case integer of
      0:
        ( x1, y1, x2, y2: extended);
      1:
        ( r1, r2: TZGLPoint );
      2:
        ( LeftBottom, RightTop: TZGLPoint );
      3:
        ( Left, Bottom, Right, Top: extended);

  end;

  TVec2D = record x, y: extended; end;
  TVec3D = record
    x, y, z: extended;
    class function ToVec(Ax, Ay, Az: extended): TVec3D; static;
  end;

//constans
const
  pi180 = pi/180;

function l2t(liczba:Int64;ilosc_lit:byte):string;
procedure normalize(var vec: array of GLfloat);
procedure normalizeVec(var vec: TVec3D);
function SubtractPoints(const p1, p2: TVec3D): TVec3D;
procedure normalize2D(var x1, y1: Extended);
procedure normalize3D(var x1, y1, z1: Extended);
function cross_prod(in1,in2: wek):wek;
function cross_prodVec(in1, in2: TVec3D): TVec3D;
function Reflect(const r, n: wek): wek;
function sqrt2(v:real):real;
function deltaToAngle(dx, dy: extended): extended;
procedure angleToDelta(angle: extended; out dx: extended; out dy: extended; multiplier: extended = 1);
function Distance2D(x1, z1, x2, z2: real): real;
function Distance3D(x1, y1, z1, x2, y2, z2: double): double;
procedure ObrocSieNa(var kat: extended; kat_docelowy: extended; szybkosc: extended);
function RoznicaMiedzyKatami( k1, k2: extended): extended;
function AnimateTo(startValue, destValue: extended; speed: integer): extended;
function SetPointsOrder(var p1, p2: TZGLPoint): boolean;
procedure SwapPoints(var p1, p2: TZGLPoint);
//function RectanglesIntersects(Rect1, Rect2: TZGLRect): boolean;
function RectanglesIntersectsGL(Rect1, Rect2: TZGLRect): boolean;
function GLRect(xl, yb, xr, yt: extended): TZGLRect;
function FMod(x, y: extended): extended;
function NegModInt(Value, Modulo: integer): integer;
function NegModFloat(Value: double; Modulo: integer): double;

function KeepValBetween(val: Variant; minVal, maxVal: Variant): Variant;
function AddValUpTo(val: Variant; addVal, maxVal: Variant): Variant;
function SubValDownTo(val: Variant; subVal, minVal: Variant): Variant;
function keepValueInBounds(value, maxValue: Variant): Variant;

function IsValBetween(val: Variant; minVal, maxVal: Variant): boolean;

function ToVec(x, y: extended): TVec2D;
function VecRotate(v: TVec2D; angle: extended; vCenter: TVec2D): TVec2D;
function VecRotateS(v: TVec2D; angle: extended): TVec2D;
function VecTranslate(v, transV: TVec2D; globAngle: extended): TVec2D;

function Vec3D(x, y, z: extended): TVec3D;
function Vec3DZero(): TVec3D;

implementation

//-----------------------------------------------------------------------------
FUNCTION l2t(liczba:Int64;ilosc_lit:byte):string;
var ww:string;
begin
   str(liczba,ww);
   if ilosc_lit>0 then
      while length(ww)<ilosc_lit do insert('0',ww,1);
   l2t:=ww;
end;

//-----------------------------------------------------------------------------
procedure normalize(var vec: array of GLfloat);
var Length: real;
begin
  Length:=sqrt(vec[0]*vec[0]+vec[1]*vec[1]+vec[2]*vec[2]);
  if (Length=0.0) then Length:=1.0;
  vec[0]:=vec[0]/Length;
  vec[1]:=vec[1]/Length;
  vec[2]:=vec[2]/Length;
end;

//-----------------------------------------------------------------------------
procedure normalize2D(var x1, y1: Extended);
var
  Length: real;
begin
  Length := sqrt2(x1 * x1 + y1 * y1);
  if (Length = 0) then
    Length := 1;
  x1 := x1 / Length;
  y1 := y1 / Length;
end;

//-----------------------------------------------------------------------------
procedure normalize3D(var x1, y1, z1: Extended);
var
  Length: real;
begin
  Length := sqrt2(x1 * x1 + y1 * y1 + z1 * z1);
  if (Length = 0) then
    Length := 1;
  x1 := x1 / Length;
  y1 := y1 / Length;
  z1 := z1 / Length;
end;

procedure normalizeVec(var vec: TVec3D);
begin
  normalize3D(vec.x, vec.y, vec.z);
end;

function SubtractPoints(const p1, p2: TVec3D): TVec3D;
begin
  Result.x := p1.x - p2.x;
  Result.y := p1.y - p2.y;
  Result.z := p1.z - p2.z;
end;

//-----------------------------------------------------------------------------
function cross_prod(in1,in2: wek):wek;
var ou:wek;
begin
    ou[0]:=(in1[1]*in2[2])-(in2[1]*in1[2]);
    ou[1]:=(in1[2]*in2[0])-(in2[2]*in1[0]);
    ou[2]:=(in1[0]*in2[1])-(in2[0]*in1[1]);
    normalize(ou);

    result:=ou;
end;

function cross_prodVec(in1, in2: TVec3D): TVec3D;
var
  ou: TVec3D;
begin
  ou.x := (in1.y * in2.z) - (in2.y * in1.z);
  ou.y := (in1.z * in2.x) - (in2.z * in1.x);
  ou.z := (in1.x * in2.y) - (in2.x * in1.y);
  normalizeVec(ou);

  result := ou;
end;

function DotProduct(const a, b: wek): Real;
var
  i: Integer;
begin
  Result := 0.0;
  for i := 0 to 2 do
    Result := Result + a[i] * b[i];
end;

function Reflect(const r, n: wek): wek;
var
  vdotProduct: Real;
  scaledN: wek;
  i: Integer;
begin
  vdotProduct := DotProduct(r, n);
  scaledN := n;
  for i := 0 to 2 do
    scaledN[i] := 2 * vdotProduct * n[i];
  Result := r;
  for i := 0 to 2 do
    Result[i] := Result[i] - scaledN[i];
end;

//---------------------------------------------------------------------------
function sqrt2(v:real):real;
begin
if v=0 then result:=0
   else result:=sqrt(v);
end;

//---------------------------------------------------------------------------
function deltaToAngle(dx, dy: extended): extended;
var kk0:real;
begin
 if dx>0 then begin
    if (dy>0) then kk0:=arctan(dy/dx)+pi/2
              else kk0:=arctan(dy/dx)+pi/2;
 end else if dx<0 then begin
    if (dy>0) then kk0:=arctan(dy/dx)+(3/2)*pi
              else kk0:=arctan(dy/dx)+(3/2)*pi;
 end else begin
    if (dy>0) then kk0:=pi
              else kk0:=0;
 end;
 result:=kk0/(pi/180);
end;

//-----------------------------------------------------------------------------
{
}
procedure angleToDelta(angle: extended; out dx: extended; out dy: extended; multiplier: extended = 1);
begin
  dx := sin(angle * pi180) * multiplier;
  dy := cos(angle * pi180) * multiplier;
end;

//-----------------------------------------------------------------------------
{
}
function Distance2D(x1, z1, x2, z2: real): real;
begin
 result:= sqrt2( sqr(x2-x1) + sqr(z2-z1) );
end;

//-----------------------------------------------------------------------------
{
}
function Distance3D(x1, y1, z1, x2, y2, z2: double): double;
begin
 result:= sqrt2( sqr(x2 - x1) + sqr(y2 - y1) + sqr(z2 - z1) );
end;

//-----------------------------------------------------------------------------
{ Pozwala na plynny obrot kata w strone kata docelowego.
  Podaj jako 'kat' zmienna z obecna wartoscia kata,
  jako kat_docelowy podaj wartosc kata, jaka ma osiagnac
  szybkosc - co ile stopni ma sie obracac w kat docelowy.
  Wynik zwrocony jest w zmiennej 'kat'.
}
procedure ObrocSieNa(var kat: extended; kat_docelowy: extended; szybkosc: extended);
var
   k1, nk1: extended;
begin
  if (kat_docelowy<>kat) then
  begin
    k1 := (round(kat - kat_docelowy) + 360) mod 360;
    if (k1<=180) then begin
      kat:=kat-(szybkosc*2);
      nk1 := (round(kat - kat_docelowy) + 360) mod 360;
      if (nk1>180) then kat:=kat_docelowy;
    end else begin
    if (k1>180) then kat:=kat+(szybkosc*2);
      nk1 := (round(kat - kat_docelowy) + 360) mod 360;
      if (nk1<=180) then kat:=kat_docelowy;
    end;
  end;

  if (kat>=360) then
    kat:=kat-360
  else
  if (kat<0) then
    kat:=kat+360;

end;

//-----------------------------------------------------------------------------
{ Operator MOD dla liczb zmiennoprzecinkowych
}
function FMod(x, y: extended): extended;
begin
  result := x - trunc(x / y) * y;
end;

function NegModInt(Value, Modulo: integer): integer;
begin
  Value := Value mod Modulo;
  if Value < 0 then
  begin
    Value := Modulo + Value;
  end;
  result := Value;
end;

function NegModFloat(Value: double; Modulo: integer): double;
begin
  Result := fmod(Value, Modulo);
  if Result < 0 then
    Result := Modulo + Result;
end;

//-----------------------------------------------------------------------------
{ Sprawdza roznice miedzy dwoma katami i zwraca wynik w zakresie -180 do 180,
  gdzie:
     0  oznacza, ze katy sa rowne
    <0  oznacza, ze kat 1 jest mniejszy od kata 2 o podana ilosc stopni i nalezy
        go obrocic w prawo (strona zgodna ze wskazowkami zegara)
    >0  oznacza, ze kat 1 jest wiekszy od kata 2 o podana ilosc stopni i nalezy
        go obrocic w lewo (strona przeciwna do wskazowek zegara)

  Podawane katy powinny byc w zakresie 0-360 stopni
}
function RoznicaMiedzyKatami( k1, k2: extended): extended;
var r: extended;
begin
 r:= fmod( k1-k2+360, 360 )-180;

 if r>0 then r:=180-r
    else r:= -180-r;

 result:= r;
end;

//---------------------------------------------------------------------------
{
}
function AnimateTo(startValue, destValue: extended; speed: integer): extended;
begin
  result := (startValue * speed + destValue) / (speed + 1);
end;

//---------------------------------------------------------------------------
{
}
function SetPointsOrder(var p1, p2: TZGLPoint): boolean;

  procedure SwapX(var pt1: TZGLPoint; var pt2: TZGLPoint);
  var
    tmp: extended;
  begin
    tmp := pt1.x;
    pt1.x := pt2.x;
    pt2.x := tmp;
  end;

  procedure SwapY(var pt1: TZGLPoint; var pt2: TZGLPoint);
  var
    tmp: extended;
  begin
    tmp := pt1.y;
    pt1.y := pt2.y;
    pt2.y := tmp;
  end;

begin
  result := false;
  if (p2.x < p1.x) then
  begin
    result := true;
    SwapX(p1, p2);
  end;
  if (p2.y < p1.y) then
  begin
    result := true;
    SwapY(p1, p2);
  end;
end;

//---------------------------------------------------------------------------
{
}
procedure SwapPoints(var p1, p2: TZGLPoint);
var
  tmp: TZGLPoint;
begin
  tmp := p1;
  p1 := p2;
  p2 := tmp;
end;

//---------------------------------------------------------------------------
{ For VCL types only, where TOP is higher on screen than BOTTOM
}
{function RectanglesIntersects(Rect1, Rect2: TZGLRect): boolean;
begin
  SetPointsOrder(Rect1.TopLeft, Rect1.BottomRight);
  SetPointsOrder(Rect2.TopLeft, Rect2.BottomRight);

  result := (Rect1.Right >= Rect2.Left) and
      (Rect1.Left <= Rect2.Right) and
      (Rect1.Bottom >= Rect2.Top) and
      (Rect1.Top <= Rect2.Bottom);
end;}

//---------------------------------------------------------------------------
{ For GL types only, where TOP is lower on screen than BOTTOM
}
function RectanglesIntersectsGL(Rect1, Rect2: TZGLRect): boolean;
begin
//  SetPointsOrder(Rect1.TopLeft, Rect1.BottomRight);
//  SetPointsOrder(Rect2.TopLeft, Rect2.BottomRight);

  result := (Rect1.Right >= Rect2.Left) and
      (Rect1.Left <= Rect2.Right) and
      (Rect1.Top >= Rect2.Bottom) and
      (Rect1.Bottom <= Rect2.Top);
end;

//---------------------------------------------------------------------------
{
}
function GLRect(xl, yb, xr, yt: extended): TZGLRect;
begin
  result.x1 := xl;
  result.y1 := yb;
  result.x2 := xr;
  result.y2 := yt;
end;

//---------------------------------------------------------------------------
{
}
function KeepValBetween(val: Variant; minVal, maxVal: Variant): Variant;
begin
  if val < minVal then
    val := minVal;
  if val > maxVal then
    val := maxVal;
  result := val;
end;

//---------------------------------------------------------------------------
{
}
function IsValBetween(val: Variant; minVal, maxVal: Variant): boolean;
begin
  result := (val >= minVal) and (val <= maxVal);
end;

//---------------------------------------------------------------------------
{
}
function AddValUpTo(val: Variant; addVal, maxVal: Variant): Variant;
begin
  result := val + addVal;
  if Result > maxVal then
    Result := maxVal;
end;

//---------------------------------------------------------------------------
{
}
function SubValDownTo(val: Variant; subVal, minVal: Variant): Variant;
begin
  result := val - subVal;
  if Result < minVal then
    Result := minVal;
end;

function keepValueInBounds(value, maxValue: Variant): Variant;
begin
  if (value < 0) then
      result := fmod((maxValue - abs(value)), maxValue)
  else
      result := fmod(value, maxValue);
end;

//---------------------------------------------------------------------------
{ Vec2D math functions
}

//---------------------------------------------------------------------------
function ToVec(x, y: extended): TVec2D;
begin
  result.x := x;
  result.y := y;
end;

//---------------------------------------------------------------------------
function VecRotate(v: TVec2D; angle: extended; vCenter: TVec2D): TVec2D;
var
  leng, angleIn: extended;
begin
  v.x := v.x - vCenter.x;
  v.y := v.y - vCenter.y;

  leng := Distance2D(0, 0, v.x, v.y);
  angleIn := deltaToAngle(v.x, -v.y);
  angleIn := angleIn - angle;
  angleToDelta(angleIn, v.x, v.y, leng);

  v.x := v.x + vCenter.x;
  v.y := v.y + vCenter.y;

  result := v;
end;

//---------------------------------------------------------------------------
function VecRotateS(v: TVec2D; angle: extended): TVec2D;
begin
  result := VecRotate(v, angle, ToVec(0, 0));
end;

//---------------------------------------------------------------------------
function VecTranslate(v, transV: TVec2D; globAngle: extended): TVec2D;
begin
  transV := VecRotateS(transV, globAngle);

  v.x := v.x + transV.x;
  v.y := v.y + transV.y;

  result := v;
end;

function Vec3D(x, y, z: extended): TVec3D;
begin
  result.x := x;
  result.y := y;
  result.z := z;
end;

function Vec3DZero(): TVec3D;
begin
  result.x := 0;
  result.y := 0;
  result.z := 0;
end;

class function TVec3D.ToVec(Ax, Ay, Az: extended): TVec3D;
begin
  result.x := Ax;
  result.y := Ay;
  result.z := Az;
end;

end.
