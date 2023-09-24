unit unittimer;

interface

uses
  System.Generics.Collections,
  Math,
  directinput8, OpenGl, gl, Glu, glext, ZGLTextures, obj, sysutils, classes,
  windows,
  fmod, fmodtypes, fmoderrors, fmodpresets, powerinputs, forms,
  ZGLMathProcs, ZGLGraphMath,
  GlobalConsts, GlobalTypes;

var
  matka: TMotherShip;
  gracz: TPlayer;

  ziemia: TGround;

  swiatlo: array of TLightsource;
  iskry: array of TSpark;
  wiatr: TWind;
  obiekt: array of Tobiekt;
  smiec: array of TTrash;

  kamera: integer;

  ladowiska: array of TLandfield;
  dzialko: array of TTurretGun;
  rakieta: array of TRocket;
  mysliwiec: array of TFighter;

  gra: TGame;
  intro: TIntro;
  glowneintro: TMainIntro;
  winieta: TTitleScreen;
  epizody: array of TEpisode;
  cheaty: TCheatCodes;
  cheatcodes_n: array [0 .. maxcheats] of array of byte;

  licz: integer;

{$IFDEF DEBUG_AUTO_START}
  headTransY, headTransZ: extended;
{$Endif}

function jaki_to_kat(dx, dy: real): real;
FUNCTION l2t(liczba: int64; ilosc_lit: byte): string;
function sqrt2(v: real): real;

procedure normalize(var vec: array of GLFloat);
function cross_prod(in1, in2: TWektor): TWektor;

function gdzie_y(x, z, y: extended): extended;
procedure xznasiatce(var x: integer; var z: integer; nx, nz: extended);

function czy_zawadza_o_scenerie(x, y, z: real; var gx, gz: integer): boolean;
procedure rozjeb_scenerie(gx, gz: integer);

procedure ustaw_gracza_namatce;
procedure nowy_teren(wczytaj_nazwa: string = '');
procedure nowa_gra(wczytaj_nr: integer; jaka: integer);

procedure start;
procedure FrameMath;

procedure PlayerObjectTransform;
procedure FighterObjectTransform(FighterId: integer);
function FighterObjectTransformProc(FighterId: integer): TTransformProc;

implementation

uses
  Render, Main, UnitStart, Language, uSfx, uConfig, uSaveGame,
  uSmokesLogic, uRenderConst,
  uSurvivorsLogic;

// ---------------------------------------------------------------------------
FUNCTION l2t(liczba: int64; ilosc_lit: byte): string;
var
  ww: string;
begin
  str(liczba, ww);
  if ilosc_lit > 0 then
    while length(ww) < ilosc_lit do
      insert('0', ww, 1);
  l2t := ww;
end;

// ---------------------------------------------------------------------------
procedure normalize(var vec: array of GLFloat);
var
  length: real;
begin
  length := sqrt(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2]);
  if (length = 0.0) then
    length := 1.0;
  vec[0] := vec[0] / length;
  vec[1] := vec[1] / length;
  vec[2] := vec[2] / length;
end;

// ---------------------------------------------------------------------------
function cross_prod(in1, in2: TWektor): TWektor;
var
  ou: TWektor;
begin
  ou[0] := (in1[1] * in2[2]) - (in2[1] * in1[2]);
  ou[1] := (in1[2] * in2[0]) - (in2[2] * in1[0]);
  ou[2] := (in1[0] * in2[1]) - (in2[0] * in1[1]);
  normalize(ou);

  result := ou;
end;

// ---------------------------------------------------------------------------
function jaki_to_kat(dx, dy: real): real;
var
  kk0: real;
begin
  if dx > 0 then
  begin
    if (dy > 0) then
      kk0 := arctan(dy / dx) + pi / 2
    else
      kk0 := arctan(dy / dx) + pi / 2;
  end
  else if dx < 0 then
  begin
    if (dy > 0) then
      kk0 := arctan(dy / dx) + (3 / 2) * pi
    else
      kk0 := arctan(dy / dx) + (3 / 2) * pi;
  end
  else
  begin
    if (dy > 0) then
      kk0 := pi
    else
      kk0 := 0;
  end;
  result := kk0 / (pi / 180);
end;

// ---------------------------------------------------------------------------
function sqrt2(v: real): real;
begin
  if v = 0 then
    result := 0
  else
    result := sqrt(v);
end;

// ---------------------------------------------------------------------------
procedure zatrzymaj_dzwieki_ciagle;
var
  a: integer;
begin
  for a := 0 to high(rakieta) do
  begin
    if rakieta[a].dzw_slychac then
    begin
      FSOUND_StopSound(rakieta[a].dzw_kanal);
      rakieta[a].dzw_slychac := false;
    end;
  end;
  for a := 0 to high(mysliwiec) do
  begin
    if mysliwiec[a].dzw_slychac then
    begin
      FSOUND_StopSound(mysliwiec[a].dzw_kanal);
      mysliwiec[a].dzw_slychac := false;
    end;
  end;
  Sfx.stop_dzwiek(2);
end;

// ---------------------------------------------------------------------------
procedure nowa_iskra(sx, sy, sz, sdx, sdy, sdz: real);
var
  n: integer;
  r: real;
begin
  n := 0;
  while (n <= high(iskry)) and (iskry[n].jest) do
    inc(n);
  if n > high(iskry) then
    n := random(length(iskry));

  if n <= high(iskry) then
    with iskry[n] do
    begin
      jest := true;

      rozmiar := 2;

      x := sx;
      y := sy;
      z := sz;
      dx := sdx;
      dy := sdy;
      dz := sdz;

      przezr := 0.9 - random / 8;
      kolr := 1 - random / 9;
      kolg := 1 - random / 8;
      kolb := 0.6 + random * 0.4;

    end;
end;

// ---------------------------------------------------------------------------
procedure nowe_swiatlo(sx, sy, sz: real; sjasnosc: real = 2; sszybkosc: real = 0.02);
var
  n: integer;
  r: real;
begin
  n := 0;
  while (n <= high(swiatlo)) and (swiatlo[n].jest) do
    inc(n);
  if n > high(swiatlo) then
    n := random(length(swiatlo));

  if n <= high(swiatlo) then
    with swiatlo[n] do
    begin
      jest := true;

      x := sx;
      y := sy + 20;
      z := sz;

      jasnosc := sjasnosc;
      szybkosc := sszybkosc;
    end;
end;

// ---------------------------------------------------------------------------
procedure nowy_smiec(sx, sy, sz, sdx, sdy, sdz: real; rodzaj, obiekt_: byte; typ_: byte = 0; randuszkodz: integer = 0;
  silaskrzyw: real = 0);
var
  n: integer;
begin
  n := 0;
  while (n <= high(smiec)) and (smiec[n].jest) do
    inc(n);
  if n <= high(smiec) then
    with smiec[n] do
    begin
      jest := true;

      x := sx;
      y := sy;
      z := sz;
      dx := sdx;
      dy := sdy;
      dz := sdz;

      czas := 1500;

      randuszkodzenia := randuszkodz;
      silaskrzywien := silaskrzyw;

      element := rodzaj;
      nobiekt := obiekt_;
      typ := typ_;
      dymisie := true;
      case typ of
        0:
          palisie := true;
        1:
          palisie := false;
      end;
    end;
end;

// ---------------------------------------------------------------------------
procedure strzel(sx, sy, sz, sdx, sdy, sdz: real; czyj: byte; rodz: byte;
  size: extended; baseDelta: TVec3D);
var
  n: integer;
  deltaVec: TVec3D;
  deltaDiv, fade: extended;
begin
  n := 0;
  while (n <= high(rakieta)) and (rakieta[n].jest) do
    inc(n);
  if n <= high(rakieta) then
    with rakieta[n] do
    begin
      jest := true;

      x := sx;
      y := sy;
      z := sz;
      dx := sdx;
      dy := sdy;
      dz := sdz;

      rodzaj := rodz;

      case rodz of
        0:
          paliwo := 100; // rakieta
        1:
          paliwo := 150; // pocisk
        2:
          paliwo := 170; // flara
      end;

      obrot := random(360);

      czyja := czyj;

      //
      if rodz <> 2 then
      begin
        deltaVec := TVec3D.ToVec(sdx, sdy, sdz);
        normalizeVec(deltaVec);
        deltaDiv := 7;
        if size < 1 then
          fade := 0.07
        else
          fade := 0.01;

        nowy_dym(sx, sy, sz,
          baseDelta.x + deltaVec.x / deltaDiv,
          baseDelta.y + deltaVec.y / deltaDiv,
          baseDelta.z + deltaVec.z / deltaDiv,
          size, 0, fade);
      end;
    end;
end;

// ---------------------------------------------------------------------------
procedure nowy_mysliwiec(sx, sy, sz: real);
var
  n: integer;
begin
  n := 0;
  while (n <= high(mysliwiec)) and (mysliwiec[n].jest) do
    inc(n);
  if n <= high(mysliwiec) then
    with mysliwiec[n] do
    begin
      jest := true;

      x := sx;
      y := sy;
      z := sz;

      _x := sx;
      _y := sy;
      _z := sz;

      szybkosc := 0.5;

      kier := (jaki_to_kat(gracz.x - x, gracz.z - z));

      // kier:=random(360);
      kierdol := 0;
      sila := 1;

      obrot := 0;
      zniszczony := false;

      atakuje := true;

      dzw_slychac := false;

    end;
end;

function IsPointOverMothership(x, y, z: extended): boolean;
begin
  result :=
    (y >= matka.y - 60) and (x >= matka.x - 530) and (x <= matka.x + 410) and
    (z >= matka.z - (x + matka.x + 530) / 2.52) and (z <= matka.z + (x + matka.x + 530) / 2.52);
end;

procedure xznasiatce(var x: integer; var z: integer; nx, nz: extended);
begin
  x := trunc((nx - ziemia.px) / ziemia.wlk);
  z := trunc((nz - ziemia.pz) / ziemia.wlk);
end;

function gdzie_y(x, z, y: extended): extended;
var
  intX, intZ: integer;
  fracX, fracZ,
  resizedX, resizedZ: extended;

  ny1, ny2, ny11, ny22, nyz1, nyz2: extended;
  distY1, distY2, distY3: extended;

  intXplus1, intZplus1: integer;
begin
  if IsPointOverMothership(x, y, z) then
    result := matka.y
  else
  begin
	  resizedX := (x - ziemia.px) / ziemia.wlk;
	  resizedZ := (z - ziemia.pz) / ziemia.wlk;

	  intX := trunc(resizedX);
	  intZ := trunc(resizedZ);

	  fracX := frac(resizedX);
	  fracZ := frac(resizedZ);

	  intX := intX mod ziemia.wx;
	  if intX < 0 then
	  begin
	    intX := ziemia.wx - 1 + intX;
	    fracX := 1 + fracX;
	  end;

	  intZ := intZ mod ziemia.wz;
	  if intZ < 0 then
	  begin
	    intZ := ziemia.wz - 1 + intZ;
	    fracZ := 1 + fracZ;
	  end;

	  if (intX + 1 <= ziemia.wx - 1) then
	    intXplus1 := intX + 1
	  else
	    intXplus1 := 0;

	  if (intZ + 1 <= ziemia.wz - 1) then
	    intZplus1 := intZ + 1
	  else
	    intZplus1 := 0;

	  ny1 := ziemia.pk[intX, intZ].p;
	  ny11 := ziemia.pk[intX, intZplus1].p;

	  ny2 := ziemia.pk[intXplus1, intZ].p;
	  ny22 := ziemia.pk[intXplus1, intZplus1].p;

	  distY1 := ny11 - ny1;
	  nyz1 := ny1 + distY1 * fracZ;

	  distY2 := ny22 - ny2;
	  nyz2 := ny2 + distY2 * fracZ;

	  distY3 := nyz2 - nyz1;
	  result := nyz1 + distY3 * fracX;
  end;

end;

// ---------------------------------------------------------------------------
procedure uszkodz(odspodu: boolean; sila: real);
type
  TObjElement = record
    nr, // nr elementu
    przyp: integer; // przyporzadkuj do elementu o numerze; -1=zaden
    x, y, z: real; // max odchylenia w osi
    spod: boolean;
  end;
const
  el: array [0 .. 12] of TObjElement = ((nr: 2; przyp: - 1; x: 10; y: 10; z: 10; spod: true), (nr: 3; przyp: 2), (nr: 4;
    przyp: - 1; x: 10; y: 10; z: 10; spod: true), (nr: 5; przyp: 4), (nr: 6; przyp: - 1; x: 10; y: 10; z: 10;
    spod: true), (nr: 7; przyp: 6), (nr: 8; przyp: - 1; x: 10; y: 0; z: 0), (nr: 9; przyp: - 1; x: 10; y: 0; z: 0),
    (nr: 15; przyp: - 1; x: 16; y: 16; z: 16), (nr: 16; przyp: - 1; x: 40; y: 40; z: 40; spod: true), (nr: 17;
    przyp: 16), (nr: 18; przyp: - 1; x: 10; y: 0; z: 0), (nr: 19; przyp: - 1; x: 10; y: 0; z: 0));

var
  a: integer;
begin
  if cheaty.god then
    exit;

  if sila > 1.7 then
    gracz.randuszkodzenia := random(99999);
  gracz.silaskrzywien := gracz.silaskrzywien + sila / 90;
  if gracz.silaskrzywien > 1.0 then
    gracz.silaskrzywien := 1.0;

  sila := abs(sila) * 10;
  { for a:=0 to high(gracz.elementy) do begin
    gracz.elementy[a].obrx:=random*60-30;
    gracz.elementy[a].obry:=random*60-30;
    gracz.elementy[a].obrz:=random*60-30;
    end;
  }
  // 0 - tylna dysza w dol
  // 1 - kula
  // 2* - noga                  XYZ
  // 3X - stopa
  // 4* - noga                  XYZ
  // 5X - stopa
  // 6* - noga                  XYZ
  // 7X - stopa
  // 8* - lewa dysza            X
  // 9* - prawa dysza           X
  // 10 - szyba
  // 11 - tylna dysza
  // 12 - dolna dysza 1
  // 13 - dolna dysza 2
  // 14 - dolna dysza 3
  // 15* - antena               XYZ
  // 16* - raczka latarki       XYZ
  // 17X - glowka latarki
  // 18* - prawe rakiety        X
  // 19* - lewe rakiety         X

  if (random(15) = 0) and (sila >= 3) then
    gracz.uszkodzenia[0] := true;

  for a := 0 to high(el) do
  begin
    if (random(4) > 0) and (el[a].przyp = -1) and ((not odspodu) or (el[a].spod = odspodu)) then
    begin

      if (el[a].x <> 0) then
      begin
        gracz.elementy[el[a].nr].obrx := gracz.elementy[el[a].nr].obrx + (random - 0.5) * sila;
        if gracz.elementy[el[a].nr].obrx < -el[a].x then
          gracz.elementy[el[a].nr].obrx := -el[a].x;
        if gracz.elementy[el[a].nr].obrx > el[a].x then
          gracz.elementy[el[a].nr].obrx := el[a].x;
      end;
      if (el[a].y <> 0) then
      begin
        gracz.elementy[el[a].nr].obry := gracz.elementy[el[a].nr].obry + (random - 0.5) * sila;
        if gracz.elementy[el[a].nr].obry < -el[a].y then
          gracz.elementy[el[a].nr].obry := -el[a].y;
        if gracz.elementy[el[a].nr].obry > el[a].y then
          gracz.elementy[el[a].nr].obry := el[a].y;
      end;
      if (el[a].z <> 0) then
      begin
        gracz.elementy[el[a].nr].obrz := gracz.elementy[el[a].nr].obrz + (random - 0.5) * sila;
        if gracz.elementy[el[a].nr].obrz < -el[a].z then
          gracz.elementy[el[a].nr].obrz := -el[a].z;
        if gracz.elementy[el[a].nr].obrz > el[a].z then
          gracz.elementy[el[a].nr].obrz := el[a].z;
      end;

    end;

  end;

  for a := 0 to high(el) do
  begin
    if el[a].przyp >= 0 then
    begin
      gracz.elementy[el[a].nr].obrx := gracz.elementy[el[a].przyp].obrx;
      gracz.elementy[el[a].nr].obry := gracz.elementy[el[a].przyp].obry;
      gracz.elementy[el[a].nr].obrz := gracz.elementy[el[a].przyp].obrz;
    end;
  end;

  (* //nogi
    gracz.elementy[3]:=gracz.elementy[2];
    gracz.elementy[5]:=gracz.elementy[4];
    gracz.elementy[7]:=gracz.elementy[6];

    //latarka
    gracz.elementy[17]:=gracz.elementy[16];
  *)
end;


procedure PlayerObjectTransform;
begin
  glRotatef(gracz.dz * 4 * gracz.wykrecsila, 1, 0, 0);
  glRotatef(-gracz.dx * 4 * gracz.wykrecsila, 0, 0, 1);
  glRotatef(gracz.kier, 0, -1, 0);
{
  glRotatef(gracz.dz * 6, gracz.wykrecsila, 0, 0);
  glRotatef(-gracz.dx * 6, 0, 0, gracz.wykrecsila);
  glRotatef(gracz.kier, 0, -1, 0);
}
  glRotatef(180, 0, 1, 0);
end;

procedure GetTransformedPositionAndDirectionVector(
  BeginPosition,
  DirectionVec: TVec3D;
  out BeginPositionTransformed: TVec3D;
  out DirectionVecTransformed: TVec3D;
  TransformProc: TTransformProc);
begin
  DirectionVec.x := BeginPosition.x + DirectionVec.x;
  DirectionVec.y := BeginPosition.y + DirectionVec.y;
  DirectionVec.z := BeginPosition.z + DirectionVec.z;

  GetTransformedPosition(Vec3DZero, BeginPosition, BeginPositionTransformed, TransformProc);
  GetTransformedPosition(Vec3DZero, DirectionVec, DirectionVecTransformed, TransformProc);

  DirectionVecTransformed.x := DirectionVecTransformed.x - BeginPositionTransformed.x;
  DirectionVecTransformed.y := DirectionVecTransformed.y - BeginPositionTransformed.y;
  DirectionVecTransformed.z := DirectionVecTransformed.z - BeginPositionTransformed.z;
end;

procedure MakeFire(SourcePosition, SourceSpeed, Offset: TVec3D; power: extended; DirectionVector: TVec3D; TransformProc: TTransformProc;
  size: double; fadeSpeed: double = 0.01);
var
  a: integer;
  s1: real;
  enginePosition, fireDirectionVec: TVec3D;
begin
  normalizeVec(DirectionVector);
  GetTransformedPositionAndDirectionVector(
    Vec3D(SourcePosition.x, SourcePosition.y, SourcePosition.z), DirectionVector,
    enginePosition, fireDirectionVec, TransformProc);

  nowy_dym(
    Offset.x + enginePosition.x - SourceSpeed.x,
    Offset.y + enginePosition.y - SourceSpeed.y,
    Offset.z + enginePosition.z - SourceSpeed.z,

    fireDirectionVec.x * power + SourceSpeed.x + (random - 0.5) * 0.02,
    fireDirectionVec.y * power + SourceSpeed.y + (random - 0.5) * 0.02,
    fireDirectionVec.z * power + SourceSpeed.z + (random - 0.5) * 0.02,

    size,
    0, fadeSpeed);
end;

procedure ShootDir(SourcePosition, SourceSpeed, Offset: TVec3D; power: extended; DirectionVector: TVec3D; TransformProc: TTransformProc;
  czyj: byte; rodz: byte; size: extended; randomDirFactor: extended);
var
  a: integer;
  s1: real;
  enginePosition, fireDirectionVec: TVec3D;
begin
  normalizeVec(DirectionVector);
  GetTransformedPositionAndDirectionVector(
    Vec3D(SourcePosition.x, SourcePosition.y, SourcePosition.z), DirectionVector,
    enginePosition, fireDirectionVec, TransformProc);

  strzel(
    Offset.x + enginePosition.x - SourceSpeed.x,
    Offset.y + enginePosition.y - SourceSpeed.y,
    Offset.z + enginePosition.z - SourceSpeed.z,

    fireDirectionVec.x * power + SourceSpeed.x + (random - 0.5) * randomDirFactor,
    fireDirectionVec.y * power + SourceSpeed.y + (random - 0.5) * randomDirFactor,
    fireDirectionVec.z * power + SourceSpeed.z + (random - 0.5) * randomDirFactor,

    czyj, rodz, size, SourceSpeed);
end;

function Bounce(position, delta: TVec3D): TVec3D;
var
  resizedX, resizedZ: extended;
  intX, intZ: integer;
  deltaw, refVec, normalw: wek;
  intXplus1, intZplus1: integer;
  P1, P2, P3, normV: TVec3D;
begin
  if IsPointOverMothership(position.x, position.y, position.z) then
  begin
    normalw[0] := 0;
    normalw[1] := 1;
    normalw[2] := 0;
  end
  else
  begin
    xznasiatce(intX, intZ, position.x, position.z);

    intX := intX mod ziemia.wx;
    if intX < 0 then
    begin
      intX := ziemia.wx - 1 + intX;
    end;

    intZ := intZ mod ziemia.wz;
    if intZ < 0 then
    begin
      intZ := ziemia.wz - 1 + intZ;
    end;

    if (intX + 1 <= ziemia.wx - 1) then
      intXplus1 := intX + 1
    else
      intXplus1 := 0;

    if (intZ + 1 <= ziemia.wz - 1) then
      intZplus1 := intZ + 1
    else
      intZplus1 := 0;

    P1.x := intX * ziemia.wlk + ziemia.px;
    P1.y := ziemia.pk[intX, intZ].p;
    P1.z := intZ * ziemia.wlk + ziemia.pz;

    P2.x := intX * ziemia.wlk + ziemia.px;
    P2.y := ziemia.pk[intX, intZplus1].p;
    P2.z := intZplus1 * ziemia.wlk + ziemia.pz;

    P3.x := intXplus1 * ziemia.wlk + ziemia.px;
    P3.y := ziemia.pk[intXplus1, intZ].p;
    P3.z := intZ * ziemia.wlk + ziemia.pz;

    normV := cross_prodVec(SubtractPoints(P2, P1), SubtractPoints(P3, P1));

    normalw[0] := normV.x;
    normalw[1] := normV.y;
    normalw[2] := normV.z;

    normalize(normalw);
  end;

  deltaw[0] := delta.x;
  deltaw[1] := delta.y;
  deltaw[2] := delta.z;

  refVec := Reflect(deltaw, normalw);

  result.x := refVec[0];
  result.y := abs(refVec[1]);
  result.z := refVec[2];
end;


// ---------------------------------------------------------------------------
procedure ruch_gracza;
var
  ilegrzeje: integer;
  s, moc, kickStrength: real;
  a, nx, nz, b, c: integer;

  k, k1, gx1, gz1, szybstrz: real;
  dzwiekognia: boolean;
  rodzpoc: byte;
  newDelta, oldDelta: TVec3D;
  underGround, alien: boolean;
begin
  gracz.grlot := -1;

  { if frmMain.PwrInp.KeyPressed[dIK_R] then
    strzel(gracz.x-250,gracz.y,gracz.z, random-0.5,3+random,random-0.5, 0,2); }

  dzwiekognia := false;
  if gracz.zyje then
  begin
    if (gracz.namierzone >= 0) and ((gracz.namierzone <> gracz._namierzone) or
      (gracz.conamierzone <> gracz._conamierzone)) then
    begin
      Sfx.graj_dzwiek(19, 0, 0, 0, false);
    end;
    gracz._namierzone := gracz.namierzone;
    gracz._conamierzone := gracz.conamierzone;

    if (gracz.sila <= 0) or (not gracz.zyje) then
      gracz.oslonablysk := 0;

    if gracz.oslonablysk > 0 then
    begin
      gracz.oslonablysk := gracz.oslonablysk - 0.05;
      if gracz.oslonablysk < 0 then
        gracz.oslonablysk := 0;
    end;

    if gracz.zlywsrodku then
    begin
//      if random(3) = 0 then
//        gracz.sila := gracz.sila - 0.016;
      if random(40) = 0 then
      begin
        kickStrength := 0.5 + random * 0.5;
        uszkodz(false, 5 * kickStrength);
        gracz.sila := gracz.sila - 0.2 * kickStrength;
        gracz.dx := gracz.dx + (random - 0.5) * 2 * kickStrength;
        gracz.dz := gracz.dz + (random - 0.5) * 2 * kickStrength;
        gracz.dy := gracz.dy + (random - 0.5) * 0.8 * kickStrength;
      end;

      if (gracz.alienSteerTime <= 0) then
      begin
        gracz.alienSteerDirection := random(3) - 1;
        gracz.alienSteerTime := 3 + random(80);
        gracz.alienSteerForward := boolean(random(2));
      end
      else
        dec(gracz.alienSteerTime);

{      if gracz.y >= gdzie_y(gracz.x, gracz.z, gracz.y) + 8 then
      begin
        gracz.dx := gracz.dx + (random - 0.5) * 0.3;
        gracz.dz := gracz.dz + (random - 0.5) * 0.3;
        // gracz.dy:=gracz.dy+(random-0.1)*0.2;
        gracz.szybkier := gracz.szybkier + (random - 0.5) * 2.5;
      end;}
    end;

    underGround :=
      (gracz.y < gdzie_y(gracz.x, gracz.z, gracz.y) + 4.99) and
      ((gracz.y < matka.y - 70) or //tylko na ziemi
       (gracz.y > matka.y - 10)); //tylko na matce, ale nie pod matk¹


    gracz.x := gracz.x + gracz.dx;
    gracz.y := gracz.y + gracz.dy;
    gracz.z := gracz.z + gracz.dz;

    if gracz.nacisk <> 0 then
    begin
      gracz.nacisk := gracz.nacisk * 0.96;
    end;

    if gracz.x < ziemia.px then
    begin
      gracz.x := abs(ziemia.px);
      gra.jestkamera[0, 0] := gra.jestkamera[0, 0] + ziemia.wx * ziemia.wlk;
      gra.jestkamera[1, 0] := gra.jestkamera[1, 0] + ziemia.wx * ziemia.wlk;
      gra.kamera[0, 0] := gra.kamera[0, 0] + ziemia.wx * ziemia.wlk;
      gra.kamera[1, 0] := gra.kamera[1, 0] + ziemia.wx * ziemia.wlk;
    end;
    if gracz.x > -ziemia.px then
    begin
      gracz.x := -abs(ziemia.px);
      gra.jestkamera[0, 0] := gra.jestkamera[0, 0] - ziemia.wx * ziemia.wlk;
      gra.jestkamera[1, 0] := gra.jestkamera[1, 0] - ziemia.wx * ziemia.wlk;
      gra.kamera[0, 0] := gra.kamera[0, 0] - ziemia.wx * ziemia.wlk;
      gra.kamera[1, 0] := gra.kamera[1, 0] - ziemia.wx * ziemia.wlk;
    end;
    if gracz.z < ziemia.pz then
    begin
      gracz.z := abs(ziemia.pz);
      gra.jestkamera[0, 2] := gra.jestkamera[0, 2] + ziemia.wz * ziemia.wlk;
      gra.jestkamera[1, 2] := gra.jestkamera[1, 2] + ziemia.wz * ziemia.wlk;
      gra.kamera[0, 2] := gra.kamera[0, 2] + ziemia.wz * ziemia.wlk;
      gra.kamera[1, 2] := gra.kamera[1, 2] + ziemia.wz * ziemia.wlk;
    end;
    if gracz.z > -ziemia.pz then
    begin
      gracz.z := -abs(ziemia.pz);
      gra.jestkamera[0, 2] := gra.jestkamera[0, 2] - ziemia.wz * ziemia.wlk;
      gra.jestkamera[1, 2] := gra.jestkamera[1, 2] - ziemia.wz * ziemia.wlk;
      gra.kamera[0, 2] := gra.kamera[0, 2] - ziemia.wz * ziemia.wlk;
      gra.kamera[1, 2] := gra.kamera[1, 2] - ziemia.wz * ziemia.wlk;
    end;

    if not gracz.stoi then
    begin
      if (gracz.y < matka.y - 120) and (gracz.y > gdzie_y(gracz.x, gracz.z, gracz.y) + 5) then
      begin
        gracz.dx := gracz.dx + sin(wiatr.kier * pi180) * wiatr.sila;
        gracz.dz := gracz.dz - cos(wiatr.kier * pi180) * wiatr.sila;
      end;

      c := Min(gracz.pilotow, 30);
      if gracz.y < gdzie_y(gracz.x, gracz.z, gracz.y) + 5 then
        moc := - ziemia.grawitacja / 2 - c * 0.0001
      else
        moc := - ziemia.grawitacja - c * 0.0004;
      gracz.dy := gracz.dy + moc;
    end;

    ilegrzeje := 0;
    // dopalacz do gory
    if (gracz.paliwo > 0) and ((GameController.Control(2).Active) or (GameController.Control(3).Active) or
      (gracz.zlywsrodku and (gracz.y < gdzie_y(gracz.x, gracz.z, gracz.y) + 350))) then
    begin
      if (GameController.Control(3).Active) then
      begin
        moc := 2;
        gracz.temp := gracz.temp + 1;
      end
      else
        moc := 1;
      Sfx.graj_dzwiek(2, gracz.x, gracz.y, gracz.z);
      dzwiekognia := true;

      inc(ilegrzeje, 3);
      if gracz.dy < 1 * moc then
        gracz.dy := gracz.dy + 0.01 * moc;

      //right
      MakeFire(
        Vec3D(1.1, gracz.nacisk * 5 - 3, -1.0),
        Vec3D(gracz.dx, gracz.dy, gracz.dz),
        Vec3D(gracz.x, gracz.y, gracz.z),
        0.9,
        Vec3D((random - 0.5) * 0.05 + 0.1, -1, (random - 0.5) * 0.05 - 0.05),
        PlayerObjectTransform,
        (0.7 + random / 2) * moc,
        0.01 - (moc - 1) * 0.003);

      //left
      MakeFire(
        Vec3D(-1.1, gracz.nacisk * 5 - 3, -1.0),
        Vec3D(gracz.dx, gracz.dy, gracz.dz),
        Vec3D(gracz.x, gracz.y, gracz.z),
        0.9,
        Vec3D((random - 0.5) * 0.05 - 0.1, -1, (random - 0.5) * 0.05 - 0.05),
        PlayerObjectTransform,
        (0.7 + random / 2) * moc,
        0.01 - (moc - 1) * 0.003);

      //front
      MakeFire(
        Vec3D(0, gracz.nacisk * 5 - 3, 1.1),
        Vec3D(gracz.dx, gracz.dy, gracz.dz),
        Vec3D(gracz.x, gracz.y, gracz.z),
        0.9,
        Vec3D((random - 0.5) * 0.05, -1, (random - 0.5) * 0.05 + 0.15),
        PlayerObjectTransform,
        (0.7 + random / 2) * moc,
        0.01 - (moc - 1) * 0.003);

      gracz.swiatlodol := gracz.swiatlodol + 0.1;
      if gracz.swiatlodol > 1 then
        gracz.swiatlodol := 1;

      gracz.paliwo := gracz.paliwo - 0.03;
      if moc > 1 then
        gracz.paliwo := gracz.paliwo - 0.04;

      if gracz.paliwo < 0 then
        gracz.paliwo := 0;
    end
    else
    begin
      if gracz.swiatlodol > 0 then
      begin
        gracz.swiatlodol := gracz.swiatlodol - 0.05;
        if gracz.swiatlodol < 0 then
          gracz.swiatlodol := 0;
      end;
    end;

    // dopalacz w dol
    if (gracz.paliwo > 0) and (GameController.Control(4).Active) then
    begin
      Sfx.graj_dzwiek(2, gracz.x, gracz.y, gracz.z);
      dzwiekognia := true;

      inc(ilegrzeje, 1);
      if gracz.dy > -1 then
        gracz.dy := gracz.dy - 0.01;

      MakeFire(
        Vec3D(0, gracz.nacisk * 5 + 0.9, -3),
        Vec3D(gracz.dx, gracz.dy, gracz.dz),
        Vec3D(gracz.x, gracz.y, gracz.z),
        0.7,
        Vec3D((random - 0.5) * 0.05, 1, (random - 0.5) * 0.05),
        PlayerObjectTransform,
        0.4 + random / 2, 0.015);

      gracz.swiatlogora := gracz.swiatlogora + 0.1;
      if gracz.swiatlogora > 1 then
        gracz.swiatlogora := 1;

      gracz.paliwo := gracz.paliwo - 0.01;
      if gracz.paliwo < 0 then
        gracz.paliwo := 0;
      inc(ilegrzeje);

    end
    else
    begin
      if gracz.swiatlogora > 0 then
      begin
        gracz.swiatlogora := gracz.swiatlogora - 0.05;
        if gracz.swiatlogora < 0 then
          gracz.swiatlogora := 0;
      end;
    end;

    // dopalacz do przodu
    if (gracz.paliwo > 0) and ((GameController.Control(5).Active) or ((GameController.Control(0).Active) and
      ((gracz.zlywsrodku and (gracz.alienSteerForward)) or GameController.Control(1).Active))) then
    begin
      Sfx.graj_dzwiek(2, gracz.x, gracz.y, gracz.z);
      dzwiekognia := true;
      if (GameController.Control(5).Active) then
        moc := 1
      else
        moc := 0;
      if (GameController.Control(0).Active) then
        moc := moc + 0.3;
      if (GameController.Control(1).Active) then
        moc := moc + 0.3;
      gracz.szyb := gracz.szyb + 0.001 * moc;

      if gracz.szyb > 0.05 * moc then
        gracz.szyb := 0.05 * moc;

      if (GameController.Control(5).Active) then
        MakeFire(
          Vec3D(0, gracz.nacisk * 5 + 0.05, -3.2),
          Vec3D(gracz.dx, gracz.dy, gracz.dz),
          Vec3D(gracz.x, gracz.y, gracz.z),
          0.9, Vec3D((random - 0.5) * 0.05, (random - 0.5) * 0.05, -1),
          PlayerObjectTransform,
          0.7 + random / 2);

      gracz.swiatlotyl := gracz.swiatlotyl + 0.1;
      if gracz.swiatlotyl > 1 then
        gracz.swiatlotyl := 1;

      gracz.paliwo := gracz.paliwo - 0.01;
      if gracz.paliwo < 0 then
        gracz.paliwo := 0;
      inc(ilegrzeje);
    end
    else
    begin
      if gracz.swiatlotyl > 0 then
      begin
        gracz.swiatlotyl := gracz.swiatlotyl - 0.05;
        if gracz.swiatlotyl < 0 then
          gracz.swiatlotyl := 0;
      end;
      if gracz.szyb > 0 then
      begin
        gracz.szyb := gracz.szyb - ziemia.gestoscpowietrza;
        if gracz.szyb < 0 then
          gracz.szyb := 0;
      end;
    end;

    if gracz.szyb > 0 then
    begin
      gracz.dx := gracz.dx + sin(gracz.kier * pi180) * gracz.szyb;
      gracz.dz := gracz.dz - cos(gracz.kier * pi180) * gracz.szyb;
    end;

    // dopalacz w lewo
    if (gracz.paliwo > 0) and ((gracz.zlywsrodku and (gracz.alienSteerDirection = -1)) or GameController.Control(0).Active) then
    begin
      Sfx.graj_dzwiek(2, gracz.x, gracz.y, gracz.z);
      dzwiekognia := true;
      if (gracz.szybkier > -6) then
        gracz.szybkier := gracz.szybkier - 0.04;

      MakeFire(
        Vec3D(-3.6, gracz.nacisk * 5, -0.5),
        Vec3D(gracz.dx, gracz.dy, gracz.dz),
        Vec3D(gracz.x, gracz.y, gracz.z),
        0.5,
        Vec3D((random - 0.5) * 0.03, (random - 0.5) * 0.03, -1),
        PlayerObjectTransform,
        0.7 + random / 2);

      gracz.swiatlolewo := gracz.swiatlolewo + 0.1;
      if gracz.swiatlolewo > 1 then
        gracz.swiatlolewo := 1;

      gracz.paliwo := gracz.paliwo - 0.01;
      if gracz.paliwo < 0 then
        gracz.paliwo := 0;
      inc(ilegrzeje);

    end
    else
    begin
      if gracz.swiatlolewo > 0 then
      begin
        gracz.swiatlolewo := gracz.swiatlolewo - 0.05;
        if gracz.swiatlolewo < 0 then
          gracz.swiatlolewo := 0;
      end;
    end;
    // dopalacz w prawo
    if (gracz.paliwo > 0) and ((gracz.zlywsrodku and (gracz.alienSteerDirection = 1)) or GameController.Control(1).Active) then
    begin
      Sfx.graj_dzwiek(2, gracz.x, gracz.y, gracz.z);
      dzwiekognia := true;
      if (gracz.szybkier < 6) then
        gracz.szybkier := gracz.szybkier + 0.04;

      MakeFire(
        Vec3D(3.6, gracz.nacisk * 5, -0.5),
        Vec3D(gracz.dx, gracz.dy, gracz.dz),
        Vec3D(gracz.x, gracz.y, gracz.z),
        0.5,
        Vec3D((random - 0.5) * 0.03, (random - 0.5) * 0.03, -1),
        PlayerObjectTransform,
        0.7 + random / 2);

      gracz.swiatloprawo := gracz.swiatloprawo + 0.1;
      if gracz.swiatloprawo > 1 then
        gracz.swiatloprawo := 1;

      gracz.paliwo := gracz.paliwo - 0.01;
      if gracz.paliwo < 0 then
        gracz.paliwo := 0;
      inc(ilegrzeje);

    end
    else
    begin
      if gracz.swiatloprawo > 0 then
      begin
        gracz.swiatloprawo := gracz.swiatloprawo - 0.05;
        if gracz.swiatloprawo < 0 then
          gracz.swiatloprawo := 0;
      end;
    end;

    if gracz.temp > 0 then
    begin
      gracz.temp := gracz.temp - gracz.chlodz / (1 + ilegrzeje);
      if gracz.temp < 0 then
        gracz.temp := 0;
      if gracz.temp > 330 then
      begin
        gracz.sila := gracz.sila - 0.07;
        if gracz.sila < 0 then
          gracz.sila := 0;
      end;
    end;

    if gracz.y > 3000 then
    begin
      if cheaty.god then
        cheaty.god := false;
      gracz.sila := gracz.sila - 0.07;
      if gracz.sila < 0 then
        gracz.sila := 0;
    end;

    gracz.kier := gracz.kier + gracz.szybkier;
    if gracz.kier >= 360 then
      gracz.kier := gracz.kier - 360;
    if gracz.kier < 0 then
      gracz.kier := gracz.kier + 360;
    gracz.szybkier := gracz.szybkier * ziemia.gestoscpowietrza;

    gracz.dx := gracz.dx * ziemia.gestoscpowietrza;
    gracz.dz := gracz.dz * ziemia.gestoscpowietrza;

    gracz.wykrecsila := sqrt2(sqr(gracz.dx) + sqr(gracz.dz));
    if gracz.wykrecsila > 2 then
      gracz.wykrecsila := 2;

    gracz.namatce := (gracz.y <= gdzie_y(gracz.x, gracz.z, gracz.y) + 5) and (gracz.y > matka.y - 60);
    if gracz.namatce then
    begin
      if gracz.mothershipTime < 1000 then
        inc(gracz.mothershipTime);
    end
    else
      gracz.mothershipTime := 0;

    s := sqrt2(sqr(gracz.dx) + sqr(gracz.dy) + sqr(gracz.dz));

    if (gracz.y < gdzie_y(gracz.x, gracz.z, gracz.y) + 5) or gracz.namatce then
    begin
      if abs(gracz.dy) > 0.01 then
        gracz.nacisk := gracz.nacisk + (gracz.y - (gdzie_y(gracz.x, gracz.z, gracz.y) + 5)) + gracz.dy * 0.5;
      while abs(gracz.nacisk) > 0.2 do
        gracz.nacisk := gracz.nacisk * 0.9;

      oldDelta := TVec3D.ToVec(gracz.dx, gracz.dy, gracz.dz);
      if gracz.y < gdzie_y(gracz.x, gracz.z, gracz.y) + 4.99 then
      begin
{        gracz.y := gracz.y + 0.001;
        gracz.dy := gracz.dy * 0.8;}

        newDelta := Bounce(TVec3D.ToVec(gracz.x, gracz.y, gracz.z), TVec3D.ToVec(oldDelta.x, oldDelta.y, oldDelta.z));//        TVec3D.ToVec(gracz.dx, gracz.dy, gracz.dz));
        gracz.x := gracz.x - oldDelta.x;
        gracz.y := gracz.y - oldDelta.y;
        gracz.z := gracz.z - oldDelta.z;
        gracz.dx := newDelta.x * 0.6;
        gracz.dy := newDelta.y * 0.6;
        gracz.dz := newDelta.z * 0.6;

      end;
      // gracz.y:=gdzie_y(gracz.x,gracz.z)+0.001+5+5;

      if (abs(gracz.dx) > 0.01) or (abs(gracz.dz) > 0.01) or (abs(gracz.dy) > 0.05) or (abs(gracz.szybkier) > 0.1) then
      begin
        s := gdzie_y(gracz.x, gracz.z, gracz.y) + 0.002;
        for b := 0 to 2 do
        begin
          nowa_iskra(gracz.x + sin((gracz.kier + 60 + b * 120) * pi180) * 2.5, s,
            gracz.z - cos((gracz.kier + 60 + b * 120) * pi180) * 2.5, (random - 0.5) * (0.2 + abs(gracz.dx * 2)),
            (random) * (abs(gracz.dy * 2) + 0.2), (random - 0.5) * (0.2 + abs(gracz.dz * 2)));
        end;

      end;

      xznasiatce(nx, nz, gracz.x, gracz.z);
      if ((nx >= 0) and (nz >= 0) and (nx < ziemia.wx) and (nz < ziemia.wz) and (ziemia.pk[nx, nz].rodzaj <> 1) and
        not gracz.namatce) or
        (gracz.namatce and ((gracz.y < matka.y - 10) or (sqrt2(sqr(gracz.x - matka.x) + sqr(gracz.z - matka.z)) > 35)))
        or (sqrt2(sqr(oldDelta.x) + sqr(oldDelta.z)) > 0.1) or (oldDelta.y < -0.17) or (abs(gracz.szybkier) > 0.4)

      then
      begin

        gracz.oslonablysk := maxoslonablysk;
//        s := (sqrt2(sqr(oldDelta.x) + sqr(oldDelta.z)) / 3 + abs(oldDelta.y) / 2 + abs(gracz.szybkier) / 10);
        s := (sqrt2(sqr(oldDelta.x) + sqr(oldDelta.z) + sqr(oldDelta.y)) / 2 + abs(gracz.szybkier) / 10);

        //odbicie siê od matki w dó³
        if (gracz.namatce and (gracz.y < matka.y - 20)) then
        begin
          gracz.dy := -abs(gracz.dy) - 0.1;;
          gracz.y := matka.y - 60.5;
          s := s * 2 + 0.2;
        end;

        if ((nx >= 0) and (nz >= 0) and (nx < ziemia.wx) and (nz < ziemia.wz)) and (ziemia.pk[nx, nz].rodzaj <> 1) then
        begin
          s := s * 2;
{          gracz.sila := gracz.sila - 0.2;
          uszkodz(true, 2);}
        end;
        gracz.sila := gracz.sila - s;

        uszkodz(true, s * 4);

      end
      else
      begin

        gracz.stoi := true;
        if gracz.namatce then
        begin // ladowanie na matce

          if (ilegrzeje = 0) then
          begin // naprawianie fizyczne
            for a := 0 to high(gracz.elementy) do
            begin
              if gracz.elementy[a].obrx > 0 then
              begin
                gracz.elementy[a].obrx := gracz.elementy[a].obrx - 0.1;
                if gracz.elementy[a].obrx < 0 then
                  gracz.elementy[a].obrx := 0;
              end;
              if gracz.elementy[a].obrx < 0 then
              begin
                gracz.elementy[a].obrx := gracz.elementy[a].obrx + 0.1;
                if gracz.elementy[a].obrx > 0 then
                  gracz.elementy[a].obrx := 0;
              end;
              if gracz.elementy[a].obry > 0 then
              begin
                gracz.elementy[a].obry := gracz.elementy[a].obry - 0.1;
                if gracz.elementy[a].obry < 0 then
                  gracz.elementy[a].obry := 0;
              end;
              if gracz.elementy[a].obry < 0 then
              begin
                gracz.elementy[a].obry := gracz.elementy[a].obry + 0.1;
                if gracz.elementy[a].obry > 0 then
                  gracz.elementy[a].obry := 0;
              end;
              if gracz.elementy[a].obrz > 0 then
              begin
                gracz.elementy[a].obrz := gracz.elementy[a].obrz - 0.1;
                if gracz.elementy[a].obrz < 0 then
                  gracz.elementy[a].obrz := 0;
              end;
              if gracz.elementy[a].obrz < 0 then
              begin
                gracz.elementy[a].obrz := gracz.elementy[a].obrz + 0.1;
                if gracz.elementy[a].obrz > 0 then
                  gracz.elementy[a].obrz := 0;
              end;
            end;

            if (gracz.uszkodzenia[0]) and (licz mod 10 = 0) and (random(3) = 0) then
              gracz.uszkodzenia[0] := false;

            if (gracz.silaskrzywien > 0) and (licz mod 5 = 0) then
            begin

              gracz.silaskrzywien := gracz.silaskrzywien - 0.005;
              if gracz.silaskrzywien < 0 then
                gracz.silaskrzywien := 0;

            end;
          end;

          if (licz mod 5 = 0) and (ilegrzeje = 0) then
          begin
            if gracz.sila < gracz.maxsila then
            begin
              gracz.sila := gracz.sila + 0.05;
              if gracz.sila > gracz.maxsila then
                gracz.sila := gracz.maxsila;

              Sfx.graj_dzwiek(16, gracz.x, gracz.y, gracz.z, false);
            end
            else if (gracz.pilotow > 0) then
            begin
              if (random(2) = 0) then
              begin
                dec(gracz.pilotow);
                CreateSurvivor(gracz.x, gracz.y, gracz.z);

                Sfx.graj_dzwiek(13, gracz.x, gracz.y, gracz.z);
              end;
            end
            else if gracz.paliwo < gracz.maxpaliwa then
            begin
              gracz.paliwo := gracz.paliwo + 8;
              if gracz.paliwo > gracz.maxpaliwa then
                gracz.paliwo := gracz.maxpaliwa;

              Sfx.graj_dzwiek(16, gracz.x, gracz.y, gracz.z, false);
            end
            else if (gracz.ilerakiet < gracz.maxrakiet) then
            begin
              inc(gracz.ilerakiet, 2);
              if gracz.ilerakiet > gracz.maxrakiet then
                gracz.ilerakiet := gracz.maxrakiet;

              Sfx.graj_dzwiek(16, gracz.x, gracz.y, gracz.z, false);
            end
            else if (gracz.iledzialko < gracz.maxdzialko) then
            begin
              inc(gracz.iledzialko, 10);
              if gracz.iledzialko > gracz.maxdzialko then
                gracz.iledzialko := gracz.maxdzialko;

              Sfx.graj_dzwiek(16, gracz.x, gracz.y, gracz.z, false);
            end;
          end;
        end
        else if gracz.paliwo <= 0 then
          gracz.sila := gracz.sila - 0.02;

      end;

      if abs(gracz.dy) > 0.1 then
        Sfx.graj_dzwiek(4, gracz.x, gracz.y, gracz.z);

      gracz.dx := gracz.dx * 0.7;
      gracz.dz := gracz.dz * 0.7;
      gracz.szybkier := gracz.szybkier * 0.8;
      gracz.dy := abs(gracz.dy / 3.4);

    end
    else
      gracz.stoi := false;

    if (gracz.y <= gdzie_y(gracz.x, gracz.z, gracz.y) + 50) then
    begin
      if czy_zawadza_o_scenerie(gracz.x, gracz.y, gracz.z, nx, nz) then
      begin
        rozjeb_scenerie(nx, nz);

        gracz.oslonablysk := maxoslonablysk;
        s := sqrt2(sqr(gracz.dx) + sqr(gracz.dz) + sqr(gracz.dy)) / 2;
        gracz.sila := gracz.sila - s;
        if abs(s) > 0.5 then
          Sfx.graj_dzwiek(4, gracz.x, gracz.y, gracz.z);
        uszkodz(false, s * 4);

        gracz.dx := -gracz.dx * 0.5;
        gracz.dy := gracz.dy * 0.5;
        gracz.dz := -gracz.dz * 0.5;
      end;
    end;

    if gracz.sila < 0.8 then
    begin
      s := (sqrt2(sqr(gracz.dx) + sqr(gracz.dy) + sqr(gracz.dz)));
      if (random(round(gracz.sila * 7)) = 0) and (s < 1) then
        nowy_dym(gracz.x, gracz.y + ord(kamera = 7) * 4, gracz.z, 0, 0.3, 0, 6 - gracz.sila * 3, 1, 0.02 * (1 + s * 2));
      if gracz.sila < 0.5 then
      begin
        if random(round(gracz.sila * 10)) = 0 then
          nowy_dym(gracz.x, gracz.y + ord(kamera = 7) * 4, gracz.z, (random - 0.5) / 4, 0.4 + random / 2,
            (random - 0.5) / 4, 4 - gracz.sila * 3, 0, (0.03 + (gracz.sila * 0.05)) * (1 + s));
      end;
    end;

    if ((GameController.Control(6).Pressed) and (gracz.ilerakiet > 0)) or
      ((GameController.Control(7).Active) and (gracz.iledzialko > 0) and (licz mod 7 = 0)) then
    begin

      if (GameController.Control(6).Pressed) and (gracz.ilerakiet > 0) then
        rodzpoc := 0
      else
        rodzpoc := 1;

      if rodzpoc = 0 then
        szybstrz := 4
      else
        szybstrz := 15; // dla rakiet = 4

      // FSOUND_PlaySoundEx(FSOUND_FREE, dzwieki[0], nil, False);
      if rodzpoc = 0 then
        Sfx.graj_dzwiek(0, gracz.x + sin((45 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu), gracz.y - 2,
          gracz.z - cos((45 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu))
      else
        Sfx.graj_dzwiek(20, gracz.x + sin((45 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu), gracz.y - 2,
          gracz.z - cos((45 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu));

      if (gracz.conamierzone = 0) and (gracz.namierzone >= 0) then
      begin // strzel w dzialko
        if (dzialko[gracz.namierzone].x > -ziemia.px / 2) and (gracz.x < ziemia.px / 2) then
          gx1 := gracz.x - ziemia.px * 2
        else if (dzialko[gracz.namierzone].x < ziemia.px / 2) and (gracz.x > -ziemia.px / 2) then
          gx1 := gracz.x + ziemia.px * 2
        else
          gx1 := gracz.x;
        if (dzialko[gracz.namierzone].z > -ziemia.pz / 2) and (gracz.z < ziemia.pz / 2) then
          gz1 := gracz.z - ziemia.pz * 2
        else if (dzialko[gracz.namierzone].z < ziemia.pz / 2) and (gracz.z > -ziemia.pz / 2) then
          gz1 := gracz.z + ziemia.pz * 2
        else
          gz1 := gracz.z;

        k := (jaki_to_kat(gx1 - dzialko[gracz.namierzone].x, gz1 - dzialko[gracz.namierzone].z));

        k1 := 90 - jaki_to_kat(sqrt2(sqr(dzialko[gracz.namierzone].x - gx1) + sqr(dzialko[gracz.namierzone].z - gz1)),
          (dzialko[gracz.namierzone].y + 4) - gracz.y);

        if (k1 < -45) then
          k1 := -45;
        if (k1 > 70) then
          k1 := 70;

        strzel(gracz.x + sin((90 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu), gracz.y - 2,
          gracz.z - cos((90 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu),

          -(sin(k * pi180) * cos(k1 * pi180)) * szybstrz, -sin(k1 * pi180) * szybstrz,
          -(-cos(k * pi180) * cos(k1 * pi180)) * szybstrz,

          0, rodzpoc, 0.3, Vec3D(gracz.dx, gracz.dy, gracz.dz));

      end
      else if (gracz.conamierzone = 1) and (gracz.namierzone >= 0) then
      begin // strzel w mysliwiec
        if (mysliwiec[gracz.namierzone].x > -ziemia.px / 2) and (gracz.x < ziemia.px / 2) then
          gx1 := gracz.x - ziemia.px * 2
        else if (mysliwiec[gracz.namierzone].x < ziemia.px / 2) and (gracz.x > -ziemia.px / 2) then
          gx1 := gracz.x + ziemia.px * 2
        else
          gx1 := gracz.x;
        if (mysliwiec[gracz.namierzone].z > -ziemia.pz / 2) and (gracz.z < ziemia.pz / 2) then
          gz1 := gracz.z - ziemia.pz * 2
        else if (mysliwiec[gracz.namierzone].z < ziemia.pz / 2) and (gracz.z > -ziemia.pz / 2) then
          gz1 := gracz.z + ziemia.pz * 2
        else
          gz1 := gracz.z;

        k := (jaki_to_kat(gx1 - mysliwiec[gracz.namierzone].x, gz1 - mysliwiec[gracz.namierzone].z));

        k1 := 90 - jaki_to_kat(sqrt2(sqr(mysliwiec[gracz.namierzone].x - gx1) + sqr(mysliwiec[gracz.namierzone].z - gz1)
          ), (mysliwiec[gracz.namierzone].y + 4) - gracz.y);

        if (k1 < -45) then
          k1 := -45;
        if (k1 > 70) then
          k1 := 70;

        strzel(gracz.x + sin((90 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu), gracz.y - 2,
          gracz.z - cos((90 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu),

          -(sin(k * pi180) * cos(k1 * pi180)) * szybstrz,
          -sin(k1 * pi180) * szybstrz,
          -(-cos(k * pi180) * cos(k1 * pi180)) * szybstrz,

          0, rodzpoc, 0.3, Vec3D(gracz.dx, gracz.dy, gracz.dz));

      end
      else // strzel prosto

        strzel(gracz.x + sin((90 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu), gracz.y - 2,
          gracz.z - cos((90 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu),

          sin(gracz.kier * pi180) * szybstrz + gracz.dx,
          -0.55 * szybstrz + gracz.dy - Distance2D(0, 0, gracz.dx, gracz.dz) * 0.5,
          -cos(gracz.kier * pi180) * szybstrz + gracz.dz, 0,

          rodzpoc, 0.3, Vec3D(gracz.dx, gracz.dy, gracz.dz));

{        ShootDir(
          Vec3D(gracz.stronastrzalu * 3, -2, 2),
          Vec3D(gracz.dx, gracz.dy, gracz.dz),
          Vec3D(gracz.x, gracz.y, gracz.z),

          szybstrz,
          Vec3D(0, -0.55 + Distance2D(0, 0, gracz.dx, gracz.dz) * 0.125, 1),
          PlayerObjectTransform,
          0, rodzpoc, 0.3,
          0);}

{ debug:
        szybstrz := 1;
        nowy_smiec(gracz.x + sin((90 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu), gracz.y - 2,
          gracz.z - cos((90 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu),
          sin(gracz.kier * pi180) * szybstrz + gracz.dx,
          -0.55 * szybstrz + gracz.dy - Distance2D(0, 0, gracz.dx, gracz.dz) * 0.5,
          -cos(gracz.kier * pi180) * szybstrz + gracz.dz,
          0, 0);}

      if rodzpoc = 0 then
      begin
        gracz.dx := gracz.dx - sin(gracz.kier * pi180) * 0.3;
        gracz.dz := gracz.dz + cos(gracz.kier * pi180) * 0.3;
        gracz.szybkier := gracz.szybkier + gracz.stronastrzalu * 0.5;
      end;

      gracz.stronastrzalu := -gracz.stronastrzalu;
      if rodzpoc = 0 then
        dec(gracz.ilerakiet)
      else
        dec(gracz.iledzialko);
    end;

    if (gracz.sila <= 0) and (not cheaty.god) then
    begin
      Sfx.graj_dzwiek(5, gracz.x, gracz.y, gracz.z);
      if gracz.sila < 0 then
        gracz.sila := 0;

      nowe_swiatlo(gracz.x, gracz.y, gracz.z);
      for a := 0 to 39 do
      begin
        nowy_dym(gracz.x, gracz.y, gracz.z, (random - 0.5) * 0.15 * s, random * 0.15 * s, (random - 0.5) * 0.15 * s,
          3 + random * 20, 0, 0.01 - random / 110);
      end;

      for a := 0 to High(obiekt[ob_gracz].o.Groups) do
        nowy_smiec(gracz.x, gracz.y, gracz.z, (random - 0.5) * 1 + gracz.dx, (random - 0.5) * 1 + gracz.dy,
          (random - 0.5) * 1 + gracz.dz, a, ob_gracz, 0, gracz.randuszkodzenia, gracz.silaskrzywien);
      if gracz.pilotow > 0 then
      begin
        for a := 1 to gracz.pilotow do
          CreateSurvivor(gracz.x, gracz.y, gracz.z, false, 0);
      end;
      if gracz.zlychpilotow > 0 then
      begin
        for a := 1 to gracz.zlychpilotow do
          CreateSurvivor(gracz.x, gracz.y, gracz.z, true, 0);
      end;

      gracz.zyje := false;
      dec(gra.zycia);
      inc(gra.zginelo, gracz.pilotow);
      gracz.pilotow := 0;

    end;

    gracz.cieny := gdzie_y(gracz.x, gracz.z, gracz.y);

    if gracz.stoi then
    begin // sprawdz na jakim lotnisku stoi gracz
      xznasiatce(nx, nz, gracz.x, gracz.z);
      for a := 0 to high(ladowiska) do
      begin
        if (nx >= ladowiska[a].x - ladowiska[a].rx) and (nz >= ladowiska[a].z - ladowiska[a].rz) and
          (nx <= ladowiska[a].x + ladowiska[a].rx) and (nz <= ladowiska[a].z + ladowiska[a].rz) then
        begin
          gracz.grlot := a;
        end;
      end;
    end;

    // wysokosc gracza:       round(gracz.y-gdzie_y(gracz.x,gracz.z,gracz.y)-5);

    // wyrzucanie pilotow z ladownika
    if ( (not gracz.namatce and (GameController.Control(18).Pressed)) or
         (gracz.zlywsrodku and (gracz.pilotow > 0) and (random(50) = 0)) )
        and
        ((gracz.pilotow > 0) or (gracz.zlychpilotow > 0)) then
    begin

      if gracz.pilotow = 0 then
      begin
        alien := true;
        dec(gracz.zlychpilotow);
        if gracz.zlychpilotow <= 0 then
          gracz.zlywsrodku := false;
      end
      else
      begin
        alien := false;
        dec(gracz.pilotow);
      end;

      if (gracz.grlot >= 0) then
      begin // zywy
        a := CreateSurvivor(gracz.x - 1 + random * 2, gracz.y, gracz.z - 1 + random * 2, false, 1, gracz.grlot, 250);
        if a >= 0 then
        begin
          SurvivorList[a].rescued := true;
          SurvivorList[a].zly := alien;
        end;
      end
      else
      begin // martwy
        a := CreateSurvivor(gracz.x - 1 + random * 2, gracz.y, gracz.z - 1 + random * 2, alien, 0{, 1, 0, 250});
        if a >= 0 then
        begin
//          SurvivorList[a].rescued := true;
          SurvivorList[a].dy := -0.3 - random / 2;
          SurvivorList[a].palisie := false;
          Sfx.graj_dzwiek((22 + ord(SurvivorList[a].zly) * 4 + random(4)), SurvivorList[a].x, SurvivorList[a].y, SurvivorList[a].z);
          if SurvivorList[a].zawszewidac and not SurvivorList[a].zly then
            inc(gra.zginelo);
        end;
      end;

      Sfx.graj_dzwiek(13, gracz.x, gracz.y, gracz.z);
    end;

    if underGround then
      gracz.y := gdzie_y(gracz.x, gracz.z, gracz.y) + 4.99;

  end; // gracz

  if not dzwiekognia then
    Sfx.stop_dzwiek(2);
end;

// ---------------------------------------------------------------------------
procedure ruch_iskier;
var
  a, b: integer;
  s: real;
begin
  // iskry

  for a := 0 to high(iskry) do
    with iskry[a] do
    begin
      if jest then
      begin
        x := x + dx;
        y := y + dy; // -0.3;
        z := z + dz;

        dx := dx * ziemia.gestoscpowietrza;
        dz := dz * ziemia.gestoscpowietrza;

        if x < ziemia.px then
        begin
          x := abs(ziemia.px);
        end;
        if x > -ziemia.px then
        begin
          x := -abs(ziemia.px);
        end;
        if z < ziemia.pz then
        begin
          z := abs(ziemia.pz);
        end;
        if z > -ziemia.pz then
        begin
          z := -abs(ziemia.pz);
        end;

        kolb := kolb - 0.03;
        if kolb < 0.05 then
          kolb := 0.05;
        if kolg > 0.4 then
        begin
          kolg := kolg - 0.01;
          if kolg < 0.4 then
            kolg := 0.4;
        end
        else if kolr > 0.4 then
        begin
          kolr := kolr - 0.01;
          if kolr < 0.4 then
            kolr := 0.4;
        end;

        przezr := przezr - 0.01 * random;

        if (dy < 0) and (y <= gdzie_y(x, z, y)) then
        begin
          dy := abs(dy) / 2;
          if random(2) = 0 then
            dx := -dx;
          if random(2) = 0 then
            dz := -dz;

          while abs(dx) > 2 do
            dx := dx * 0.6;
          while abs(dz) > 2 do
            dz := dz * 0.6;
        end;
        dy := dy - ziemia.grawitacja * 4;

        if (przezr <= 0) or (sqrt2(sqr(dx) + sqr(dy) + sqr(dz)) <= 0.002) then
        begin
          jest := false;
        end;
      end;
    end;

end;

// ---------------------------------------------------------------------------
procedure ruch_swiatel;
var
  a, b: integer;
begin
  for a := 0 to high(swiatlo) do
    with swiatlo[a] do
      if jest then
      begin
        jasnosc := jasnosc - szybkosc;

        if jasnosc < 0 then
          jest := false;
      end;
end;

// ---------------------------------------------------------------------------
function czy_zawadza_o_scenerie(x, y, z: real; var gx, gz: integer): boolean;
var
  nx, nz: integer;
begin
  result := false;

  xznasiatce(nx, nz, x, z);
  gx := 0;
  gz := 0;
  if (nx >= 0) and (nz >= 0) and (nx < ziemia.wx) and (nz < ziemia.wz) and (not IsPointOverMothership(x, y, z)) then
  begin

    if (ziemia.pk[nx][nz].scen) and (y < gdzie_y(x, z, y) + ziemia.pk[nx][nz].scen_rozm * 13) and
      (sqrt2(sqr(x - (nx * ziemia.wlk + ziemia.px)) + sqr(z - (nz * ziemia.wlk + ziemia.pz))) < ziemia.pk[nx][nz]
      .scen_rozm * 8) then
    begin
      result := true;
      gx := nx;
      gz := nz;
    end
    else if (nx < ziemia.wx - 1) and (ziemia.pk[nx + 1][nz].scen) and
      (y < gdzie_y(x, z, y) + ziemia.pk[nx + 1][nz].scen_rozm * 13) and
      (sqrt2(sqr(x - ((nx + 1) * ziemia.wlk + ziemia.px)) + sqr(z - (nz * ziemia.wlk + ziemia.pz))) < ziemia.pk[nx + 1]
      [nz].scen_rozm * 8) then
    begin
      result := true;
      gx := nx + 1;
      gz := nz;
    end
    else if (nz < ziemia.wz - 1) and (ziemia.pk[nx][nz + 1].scen) and
      (y < gdzie_y(x, z, y) + ziemia.pk[nx][nz + 1].scen_rozm * 13) and
      (sqrt2(sqr(x - (nx * ziemia.wlk + ziemia.px)) + sqr(z - ((nz + 1) * ziemia.wlk + ziemia.pz))) <
      ziemia.pk[nx][nz + 1].scen_rozm * 8) then
    begin
      result := true;
      gx := nx;
      gz := nz + 1;
    end
    else if (nx < ziemia.wx - 1) and (nz < ziemia.wz - 1) and (ziemia.pk[nx + 1][nz + 1].scen) and
      (y < gdzie_y(x, z, y) + ziemia.pk[nx + 1][nz + 1].scen_rozm * 13) and
      (sqrt2(sqr(x - ((nx + 1) * ziemia.wlk + ziemia.px)) + sqr(z - ((nz + 1) * ziemia.wlk + ziemia.pz))) <
      ziemia.pk[nx + 1][nz + 1].scen_rozm * 8) then
    begin
      result := true;
      gx := nx + 1;
      gz := nz + 1;
    end;

  end;
end;

// ---------------------------------------------------------------------------
procedure rozjeb_scenerie(gx, gz: integer);
var
  s, zx, zz: real;
  b: integer;
begin
  ziemia.pk[gx][gz].scen := false;

  zx := (gx) * ziemia.wlk + ziemia.px;
  zz := (gz) * ziemia.wlk + ziemia.pz;

  for b := 0 to 4 + round(ziemia.pk[gx][gz].scen_rozm * 7) do
  begin
    nowy_dym(zx, ziemia.pk[gx][gz].p + ziemia.pk[gx][gz].scen_rozm, zz, (random - 0.5) / 2, (random) / 3,
      (random - 0.5) / 2, (5 + random * 13) * ziemia.pk[gx][gz].scen_rozm, 1, 0.02 - random * 0.018);
  end;

  for b := 0 to 4 + round(ziemia.pk[gx][gz].scen_rozm * 4) do
    nowy_smiec(zx, ziemia.pk[gx][gz].p + 0.5 + random * ziemia.pk[gx][gz].scen_rozm * 4, zz, (random - 0.5) * 1.4,
      (random - 0.2) * 0.8, (random - 0.5) * 1.4, random(length(obiekt[ob_kamien].o.Groups)), ob_kamien, 1,
      random(99999), random);

  s := 0.1;
  ziemia.pk[gx, gz].kr := ziemia.pk[gx, gz].kr * s;
  ziemia.pk[gx, gz].kg := ziemia.pk[gx, gz].kg * s;
  ziemia.pk[gx, gz].kb := ziemia.pk[gx, gz].kb * s;
end;

// ---------------------------------------------------------------------------
procedure ruch_rakiet;
var
  a, b, a1, nx, nz, gx, gz: integer;
  s, oldVal: real;
  wysadz: boolean;
  dzielsile, mn: real;

  procedure zaiskrz;
  var
    b: integer;
  begin
    with rakieta[a] do
    begin
      if rodzaj = 1 then
        for b := 0 to random(4) do
          nowa_iskra(x, y, z, (random - 0.5) * 0.3 + (0.15 * dx), (random - 0.5) * 0.3 + (0.15 * dy),
            (random - 0.5) * 0.3 + (0.15 * dz));
    end;
  end;

begin
  for a := 0 to high(rakieta) do
    with rakieta[a] do
    begin
      if jest then
      begin
        wysadz := false;

        case rodzaj of
          0:
            dzielsile := 1;
          1:
            dzielsile := 40;
          2:
            dzielsile := 40;
        else
          dzielsile := 1;
        end;

        _x := x;
        _y := y;
        _z := z;

        x := x + dx;
        y := y + dy;
        z := z + dz;

        if x < ziemia.px then
        begin
          x := abs(ziemia.px);
        end;
        if x > -ziemia.px then
        begin
          x := -abs(ziemia.px);
        end;
        if z < ziemia.pz then
        begin
          z := abs(ziemia.pz);
        end;
        if z > -ziemia.pz then
        begin
          z := -abs(ziemia.pz);
        end;

        if y > 3000 then
          jest := false;

        // rozwalenie o scenerie
        if not wysadz and (y <= gdzie_y(x, z, y) + 50) then
        begin

          if czy_zawadza_o_scenerie(x, y, z, gx, gz) then
          begin
            wysadz := true;
            if (rodzaj = 0) then
            begin
              if (random(round(ziemia.pk[gx][gz].scen_rozm * 2)) = 0) then
                rozjeb_scenerie(gx, gz)
              else
              begin
                ziemia.pk[gx][gz].scen_obrx := ziemia.pk[gx][gz].scen_obrx + random(2) * 2 - 1;
                ziemia.pk[gx][gz].scen_obrz := ziemia.pk[gx][gz].scen_obrz + random(2) * 2 - 1;
              end;
            end;

          end;
        end;

        // rozwalenie o ziemie
        if (y <= gdzie_y(x, z, y)) then
        begin
          wysadz := true;
          xznasiatce(nx, nz, x, z);
          if (nx >= 0) and (nz >= 0) and (nx < ziemia.wx) and (nz < ziemia.wz) and (not IsPointOverMothership(x, y, z)) then
          begin
            case rodzaj of
              // stopien zaciemnienia terenu zalezny od rodzaju pocisku
              0, 2:
                s := 0.1;
              1:
                s := 0.98;
            else
              s := 1;
            end;
            if rodzaj = 1 then
              nowy_dym(x, y + 0.1, z, (random - 0.5) * 0.3, 0.1 + (random * 0.2), (random - 0.5) * 0.3,
                0.5 + random / 2, 4, 0.03);

            if rodzaj = 0 then
              ziemia.pk[nx, nz].p := ziemia.pk[nx, nz].p - 1 - random;
            ziemia.pk[nx, nz].kr := ziemia.pk[nx, nz].kr * s;
            ziemia.pk[nx, nz].kg := ziemia.pk[nx, nz].kg * s;
            ziemia.pk[nx, nz].kb := ziemia.pk[nx, nz].kb * s;

            if Config.Display.ShowGrass then
            begin
              if length(ziemia.pk[nx, nz].krzaki) > 0 then
                for a1 := 0 to high(ziemia.pk[nx, nz].krzaki) do
                  if ziemia.pk[nx, nz].krzaki[a1].jest then
                  begin
                    if random(3) <= 1 then
                      ziemia.pk[nx, nz].krzaki[a1].jest := false
                    else
                      ziemia.pk[nx, nz].krzaki[a1].y := gdzie_y(ziemia.pk[nx, nz].krzaki[a1].x,
                        ziemia.pk[nx, nz].krzaki[a1].z, ziemia.pk[nx, nz].krzaki[a1].y);
                  end;
            end;
          end;
        end;

        if paliwo > 0 then
        begin
          dec(paliwo);
          if rodzaj = 0 then
            nowy_dym(x, y, z, 0, 0, 0, 0.5 + random / 2, 0, 0.05);
        end;

        if (rodzaj <> 2) and (paliwo <= 0) then
        begin
          dx := dx * 0.997;
          dz := dz * 0.997;
          dy := dy - ziemia.grawitacja;
          if rodzaj = 1 then
            jest := false;
        end;

        if rodzaj = 2 then
        begin
          dy := dy - ziemia.grawitacja * 3;
          if paliwo > 0 then
          begin
            nowy_dym(x, y, z, (random - 0.5) * 0.04 + sin(obrot * pi180) * 0.05, (random - 0.5) * 0.04,
              (random - 0.5) * 0.04 - cos(obrot * pi180) * 0.05, 1 + random * 2, 0, 0.002 + random * 0.004);

          end
          else
          begin
            if random(50) = 0 then
              jest := false;
            dy := dy - ziemia.grawitacja * 4;
          end;
        end;

        kier := jaki_to_kat(dx, dz);
        kierdol := 90 - jaki_to_kat(sqrt2(sqr(dx) + sqr(dz)), dy);

        obrot := obrot + 15;
        if obrot >= 360 then
          obrot := obrot - 360;

        { if (rodz=0) and (przezr>0.4) and (random(20)=0) then begin
          for b:=0 to high(pilot) do if pilot[b].jest and not pilot[b].palisie then begin
          s:=sqrt2(sqr(pilot[b].x-x)+sqr(pilot[b].y-y)+sqr(pilot[b].z-z));
          if s<=10 then pilot[b].palisie:=true;
          end;
          end; }

        if czyja = 0 then
          for b := 0 to high(dzialko) do
          begin
            if dzialko[b].jest then
            begin
              s := sqrt2(sqr(dzialko[b].x - x) + sqr(dzialko[b].y - y) + sqr(dzialko[b].z - z));
              if s <= 15 then
              begin
                wysadz := true;
                zaiskrz;
              end;
            end;
          end;

        for b := 0 to high(mysliwiec) do
        begin
          if mysliwiec[b].jest then
          begin
            s := sqrt2(sqr(mysliwiec[b].x - x) + sqr(mysliwiec[b].y - y) + sqr(mysliwiec[b].z - z));
            if s <= 10 then
            begin
              wysadz := true;
              zaiskrz;
            end;
          end;
        end;

        if czyja = 1 then
          if gracz.zyje then
          begin
            s := sqrt2(sqr(gracz.x - x) + sqr(gracz.y - y) + sqr(gracz.z - z));
            if s <= 10 then
              wysadz := true;
          end;

        if wysadz then
        begin
          if rodzaj = 0 then
          begin
            Sfx.graj_dzwiek(1, x, y, z);
            nowe_swiatlo(x, y, z);
            for b := 0 to 9 do
            begin
              nowy_dym(x, y, z, (random - 0.5) / 3, (random) / 5, (random - 0.5) / 3, 5 + random * 10, 0,
                0.03 - random * 0.027);
            end;
          end
          else
          begin
            Sfx.graj_dzwiek(21, x, y, z);
            nowy_dym(x, y, z, (random - 0.5) / 3, (random) / 5, (random - 0.5) / 3, 1 + random * 2, 0,
              0.05 - random * 0.03);
          end;

          for b := 0 to high(dzialko) do
          begin
            if dzialko[b].jest then
            begin
              s := sqrt2(sqr(dzialko[b].x - x) + sqr(dzialko[b].y - y) + sqr(dzialko[b].z - z));
              if s <= 15 then
              begin
                dzialko[b].sila := dzialko[b].sila - ((15 - s) / 3) / dzielsile;
                if dzialko[b].sila <= 0 then
                begin
                  dzialko[b].sila := 0;
                  if czyja = 0 then
                  begin
                    inc(gra.kasa, 10);
                    inc(gra.pkt, 100);
                  end;
                end;
                if czyja = 0 then
                begin
                  if rodzaj = 0 then
                    mn := 10
                  else
                    mn := 0.5;
                  inc(gra.kasa, round((15 - s) * mn));
                  inc(gra.pkt, round((15 - s) * 10 * mn));
                end;
              end;
            end;
          end;

          for b := 0 to high(mysliwiec) do
          begin
            if mysliwiec[b].jest then
            begin
              s := sqrt2(sqr(mysliwiec[b].x - x) + sqr(mysliwiec[b].y - y) + sqr(mysliwiec[b].z - z));
              if s <= 15 then
              begin
                oldVal := mysliwiec[b].sila;
                mysliwiec[b].sila := mysliwiec[b].sila - ((15 - s) / 3) / dzielsile;
                if mysliwiec[b].sila <= 0 then
                begin
                  // mysliwiec[b].sila:=0;
                  if (czyja = 0) and (oldVal > 0) then
                  begin
                    if mysliwiec[b].sila = 0 then
                      mysliwiec[b].sila := -0.01;
                    inc(gra.kasa, 10);
                    inc(gra.pkt, 100);
                    inc(gra.fightersDestroyed);
                  end;
                end;
                if czyja = 0 then
                begin
                  if rodzaj = 0 then
                    mn := 10
                  else
                    mn := 0.5;
                  inc(gra.kasa, round((15 - s) * mn));
                  inc(gra.pkt, round((15 - s) * 10 * mn));
                end;
              end;
            end;
          end;

          for b := 0 to SurvivorList.Count - 1 do
          begin
            if SurvivorList[b].jest then
            begin
              s := sqrt2(sqr(SurvivorList[b].x - x) + sqr(SurvivorList[b].y - y) + sqr(SurvivorList[b].z - z));
              if s <= 30 / ((dzielsile + 9) / 10) then
              begin

                if rodzaj = 0 then
                begin
                  SurvivorList[b].sila := SurvivorList[b].sila - ((30 - s) / 3);
                  SurvivorList[b].dy := SurvivorList[b].dy + ((30 - s) / 40);
                  SurvivorList[b].dx := SurvivorList[b].dx + (SurvivorList[b].x - x) / 25;
                  SurvivorList[b].dz := SurvivorList[b].dz + (SurvivorList[b].z - z) / 25;
                end
                else
                begin
                  SurvivorList[b].sila := SurvivorList[b].sila - ((30 - s) / 3) / 5;
                  SurvivorList[b].dy := SurvivorList[b].dy + ((30 - s) / 180);
                  SurvivorList[b].dx := SurvivorList[b].dx + (SurvivorList[b].x - x) / 60;
                  SurvivorList[b].dz := SurvivorList[b].dz + (SurvivorList[b].z - z) / 60;
                end;

                Sfx.graj_dzwiek((22 + ord(SurvivorList[b].zly) * 4 + random(4)), SurvivorList[b].x, SurvivorList[b].y, SurvivorList[b].z);
                if rodzaj = 0 then
                  SurvivorList[b].palisie := true;
                if SurvivorList[b].sila < 0 then
                  SurvivorList[b].sila := 0;
              end;
            end;
          end;

//          {$IFNDEF DEBUG_AUTO_START}
          if gracz.zyje then
          begin
            s := sqrt2(sqr(gracz.x - x) + sqr(gracz.y - y) + sqr(gracz.z - z));
            if s <= 10 then
            begin
              zaiskrz;
              gracz.sila := gracz.sila - ((10 - s) / 4) / dzielsile;
              uszkodz(false, (((10 - s) / 4) / dzielsile) * 8);
              gracz.oslonablysk := maxoslonablysk;
              if gracz.sila < 0 then
                gracz.sila := 0;
              gracz.dx := gracz.dx + (dx / 3) / dzielsile;
              gracz.dy := gracz.dy + (dy / 3) / dzielsile;
              gracz.dz := gracz.dz + (dz / 3) / dzielsile;
            end;
          end;
//          {$ENDIF}

          jest := false;
        end;

        s := sqrt2(sqr(gra.jestkamera[0, 0] - x) + sqr(gra.jestkamera[0, 1] - y) + sqr(gra.jestkamera[0, 2] - z));

        if s < 300 then
        begin
          if not dzw_slychac then
            dzw_kanal := Sfx.graj_dzwiek_kanal(18, x, y, z, _x, _y, _z, -1)
          else
            Sfx.graj_dzwiek_kanal(18, x, y, z, _x, _y, _z, dzw_kanal);
          dzw_slychac := true;
        end
        else
        begin
          if dzw_slychac then
          begin
            FSOUND_StopSound(dzw_kanal);
            dzw_slychac := false;
          end;

        end;

      end;

      if not jest and dzw_slychac then
      begin
        FSOUND_StopSound(dzw_kanal);
        dzw_slychac := false;
      end;
    end;

end;

// ---------------------------------------------------------------------------

procedure FighterObjectTransform(FighterId: integer);
begin
  glRotatef(mysliwiec[FighterId].kier - 90, 0, -1, 0);
  glRotatef(mysliwiec[FighterId].kierdol, 0, 0, -1);
  glRotatef(mysliwiec[FighterId].obrot, 1, 0, 0);
end;

function FighterObjectTransformProc(FighterId: integer): TTransformProc;
begin
  result := procedure()
  begin
    FighterObjectTransform(FighterId);
  end;
end;


// ---------------------------------------------------------------------------
procedure ruch_mysliwcow;
var
  a, b, nx, nz: integer;
  s, gx1, gz1,
  dx, dy, dz: real;
  wysadz: boolean;
  k, k2: real;
  k1, nk1: integer;
  skreca, okstrzal: boolean;
  distStopAttack: integer;

begin
  for a := 0 to high(mysliwiec) do
    with mysliwiec[a] do
    begin
      if jest then
      begin
        wysadz := false;
        skreca := false;

        _x := x;
        _y := y;
        _z := z;

        dx := sin(kier * pi180) * szybkosc;
        dy := - sin(kierdol * pi180) * szybkosc;
        dz := - cos(kier * pi180) * szybkosc;

        x := x + dx;
        y := y + dy;
        z := z + dz;

        if x < ziemia.px then
        begin
          x := abs(ziemia.px);
        end;
        if x > -ziemia.px then
        begin
          x := -abs(ziemia.px);
        end;
        if z < ziemia.pz then
        begin
          z := abs(ziemia.pz);
        end;
        if z > -ziemia.pz then
        begin
          z := -abs(ziemia.pz);
        end;

        if ((sila <= 0) and not zniszczony and (random(8) = 0)) or (sila < -7) then
        begin
          wysadz := true;
        end;

        if sila <= 0 then
          zniszczony := true;
        if (sila < 1) and (random(round(sila * 7)) = 0) then
          nowy_dym(x, y, z, 0, 0.3, 0, 5 - sila * 3, 1);
        if sila < 0.5 then
        begin
          if sila >= 0 then
            k := sila
          else
            k := 0;
          if random(round(k * 10)) = 0 then
            nowy_dym(x, y, z, (random - 0.5) / 4, 0.4 + random / 2, (random - 0.5) / 4, 4 - k * 3, 0);
        end;

        if (y <= gdzie_y(x, z, y)) then
        begin
          wysadz := true;
          zniszczony := true;
          xznasiatce(nx, nz, x, z);
          Sfx.graj_dzwiek(4, x, y, z);
          if (nx >= 0) and (nz >= 0) and (nx < ziemia.wx) and (nz < ziemia.wz) then
          begin
            ziemia.pk[nx, nz].p := ziemia.pk[nx, nz].p - 1 - random;
            ziemia.pk[nx, nz].kr := ziemia.pk[nx, nz].kr * 0.1;
            ziemia.pk[nx, nz].kg := ziemia.pk[nx, nz].kg * 0.1;
            ziemia.pk[nx, nz].kb := ziemia.pk[nx, nz].kb * 0.1;
          end;
        end;

        MakeFire(
          Vec3D(-5.5, 0.5, 2.5),
          Vec3D(dx, dy, dz),
          Vec3D(x, y, z),
          2,
          Vec3D(-1, (random - 0.5) * 0.05, (random - 0.5) * 0.05),//Vec3D((random - 0.5) * 0.05, (random - 0.5) * 0.05, -1),
          FighterObjectTransformProc(a),
          1 + random / 1.9, 0.06);

        MakeFire(
          Vec3D(-5.5, 0.5, -2.5),
          Vec3D(dx, dy, dz),
          Vec3D(x, y, z),
          2,
          Vec3D(-1, (random - 0.5) * 0.05, (random - 0.5) * 0.05),//Vec3D((random - 0.5) * 0.05, (random - 0.5) * 0.05, -1),
          FighterObjectTransformProc(a),
          1 + random / 1.9, 0.06);

        if (x > -ziemia.px / 2) and (gra.jestkamera[0, 0] < ziemia.px / 2) then
          gx1 := gra.jestkamera[0, 0] - ziemia.px * 2
        else if (x < ziemia.px / 2) and (gra.jestkamera[0, 0] > -ziemia.px / 2) then
          gx1 := gra.jestkamera[0, 0] + ziemia.px * 2
        else
          gx1 := gra.jestkamera[0, 0];
        if (z > -ziemia.pz / 2) and (gra.jestkamera[0, 2] < ziemia.pz / 2) then
          gz1 := gra.jestkamera[0, 2] - ziemia.pz * 2
        else if (z < ziemia.pz / 2) and (gra.jestkamera[0, 2] > -ziemia.pz / 2) then
          gz1 := gra.jestkamera[0, 2] + ziemia.pz * 2
        else
          gz1 := gra.jestkamera[0, 2];

        s := sqrt2(sqr(gx1 - x) + sqr(gra.jestkamera[0, 1] - y) + sqr(gz1 - z));

        if s < 600 then
        begin
          if not dzw_slychac then
            dzw_kanal := Sfx.graj_dzwiek_kanal(17, x, y, z, _x, _y, _z, -1)
          else
            Sfx.graj_dzwiek_kanal(17, x, y, z, _x, _y, _z, dzw_kanal);
          dzw_slychac := true;
        end
        else
        begin
          if dzw_slychac then
          begin
            FSOUND_StopSound(dzw_kanal);
            dzw_slychac := false;
          end;

        end;

        if gracz.zyje and not zniszczony then
        begin
          if (x > -ziemia.px / 2) and (gracz.x < ziemia.px / 2) then
            gx1 := gracz.x - ziemia.px * 2
          else if (x < ziemia.px / 2) and (gracz.x > -ziemia.px / 2) then
            gx1 := gracz.x + ziemia.px * 2
          else
            gx1 := gracz.x;
          if (z > -ziemia.pz / 2) and (gracz.z < ziemia.pz / 2) then
            gz1 := gracz.z - ziemia.pz * 2
          else if (z < ziemia.pz / 2) and (gracz.z > -ziemia.pz / 2) then
            gz1 := gracz.z + ziemia.pz * 2
          else
            gz1 := gracz.z;

          s := sqrt2(sqr(gx1 - x) + sqr(gracz.y - y) + sqr(gz1 - z));

          if s <= 600 then
          begin // gracz namierza mysliwca
            k := (jaki_to_kat(gx1 - x, gz1 - z) + 180) - gracz.kier;
            if k > 180 then
              k := k - 360;

            k2 := jaki_to_kat(sqrt2(sqr(gx1 - x) + sqr(gz1 - z)), gracz.y - y) - 90;

            if (abs(k) < 20) and (abs(k2) < 150) and (s < gracz.odlegloscnamierzonegodzialka) then
            begin
              gracz.namierzone := a;
              gracz.conamierzone := 1;
              gracz.odlegloscnamierzonegodzialka := s;
            end;
          end;

          distStopAttack := 1000 + gra.difficultyLevel * 5;
          if s <= 55 * szybkosc then
          begin
            if random(6) = 0 then
              atakuje := false
          end
          else if (s > 100 * szybkosc) and (s <= distStopAttack) and (random(50) = 0) then
            atakuje := true;

          if (s > distStopAttack) then
            atakuje := false;

          if s > 1500 then
            jest := false;

          if atakuje then
          begin // lec za graczem
            // przyspiesz
            if szybkosc < 0.9 + gra.difficultyLevel / 75 then
              szybkosc := szybkosc + 0.1;

            okstrzal := false;
            // skrec w jego strone
            if s <= 220 then
              k := (jaki_to_kat(gx1 - x, gz1 - z))
            else
              k := (jaki_to_kat(gx1 - x, gz1 - z)) + sin(licz / (25 + a * 2)) * 40;

            if (round(k) <> round(kier)) then
            begin
              k := k - 5 + random(10);
              k1 := (round(kier - k) + 360) mod 360;
              if (k1 <= 180) then
              begin
                kier := kier - 1;
                if obrot > -45 then
                  obrot := obrot - 2;
                nk1 := (round(kier - k) + 360) mod 360;
                if (nk1 > 180) then
                  kier := k;
                skreca := true;
              end
              else
              begin
                if (k1 > 180) then
                  kier := kier + 1;
                nk1 := (round(kier - k) + 360) mod 360;
                if obrot < 45 then
                  obrot := obrot + 2;
                if (nk1 <= 180) then
                  kier := k;
                skreca := true;
              end;
              if (k1 < 30) or (k1 > 330) then
                okstrzal := true;
            end
            else
              { if (round(k)=round(kier)) then } okstrzal := true;

            if (kier >= 360) then
              kier := kier - 360
            else if (kier < 0) then
              kier := kier + 360;

            // lec w gore lub dol
            { x:=x+sin(kier*pi180)*szybkosc;
              y:=y-sin(kierdol*pi180)*szybkosc;
              z:=z-cos(kier*pi180)*szybkosc; }
            if (gdzie_y(x, z, y) > y - 25) or // zeby sie w ziemie nie jebnal
              (gdzie_y(x + sin(kier * pi180) * szybkosc * 15, z - cos(kier * pi180) * szybkosc * 15, y) > y - 25) or
              (gdzie_y(x + sin(kier * pi180) * szybkosc * 30, z - cos(kier * pi180) * szybkosc * 30, y) > y - 30) or
              (gdzie_y(x + sin(kier * pi180) * szybkosc * 50, z - cos(kier * pi180) * szybkosc * 50, y) > y - 40) or
              (gdzie_y(x + sin(kier * pi180) * szybkosc * 65, z - cos(kier * pi180) * szybkosc * 65, y) > y - 45) then
              k := -85
            else
              k := jaki_to_kat(sqrt2(sqr(x - gx1) + sqr(z - gz1)), y - gracz.y) - 90;

            if (k < -50) then
              k := -50;
            if (k > 50) then
              k := 50;

            if (round(k) <> round(kierdol)) then
            begin
              k1 := round(k); // round(kierdol - k);

              if kierdol > k1 then
                kierdol := kierdol - 2;
              if kierdol < k1 then
                kierdol := kierdol + 2;

              if okstrzal and (abs(kierdol - k) > 20) then
                okstrzal := false;

            end;

            if okstrzal and (s < 500 + gra.difficultyLevel) and (random(round(22 - gra.difficultyLevel / 7)) = 0) then
            begin
              if shootSide = 1 then
                shootSide := -1
              else
                shootSide := 1;

              ShootDir(
                Vec3D(9, -1, shootSide * 3.6),
                Vec3D(dx, dy, dz),
                Vec3D(x, y, z),

                (15 + gra.difficultyLevel / 15),
                Vec3D(1, 0, 0),
                FighterObjectTransformProc(a),
                1, 1, 0.6,
                0.4);

              Sfx.graj_dzwiek(20, x, y, z);

            end;

          end;

          if s <= 10 then
          begin
            zniszczony := true; // zderzenie z graczem

            nowe_swiatlo(x, y, z);
            Sfx.graj_dzwiek(4, x, y, z);
            for b := 0 to 9 do
            begin
              nowy_dym(x, y, z, (random - 0.5) / 3, (random) / 5, (random - 0.5) / 3, 5 + random * 10, 0,
                0.03 - random * 0.027);
            end;

            gracz.sila := gracz.sila - ((10 - s) / 4) * 3;
            gracz.oslonablysk := maxoslonablysk;
            if gracz.sila < 0 then
              gracz.sila := 0;
            { gracz.dx:=gracz.dx+(dx);
              gracz.dy:=gracz.dy+(dy);
              gracz.dz:=gracz.dz+(dz); }

          end;
        end
        else
          atakuje := false;

        if not atakuje and not zniszczony then
        begin // lec w druga strone niz gracz
          // przyspiesz
          if szybkosc < 1 + gra.difficultyLevel / 100 then
            szybkosc := szybkosc + 0.1;

          // skrec w przeciwna strone niz gracz
          // k:=180+(jaki_to_kat(gx1-x,gz1-z));
          if (s > 350) or (s < 100) then
            k := 180 + (jaki_to_kat(gx1 - x, gz1 - z))
          else
            k := 180 + (jaki_to_kat(gx1 - x, gz1 - z)) + sin(licz / (25 + a * 2)) * 40;
          if k > 360 then
            k := k - 360;

          if (round(k) <> round(kier)) then
          begin
            k1 := (round(kier - k) + 360) mod 360;
            if (k1 <= 180) then
            begin
              kier := kier - 1;
              if obrot > -45 then
                obrot := obrot - 2;
              nk1 := (round(kier - k) + 360) mod 360;
              if (nk1 > 180) then
                kier := k;
              skreca := true;
            end
            else
            begin
              if (k1 > 180) then
                kier := kier + 1;
              nk1 := (round(kier - k) + 360) mod 360;
              if obrot < 45 then
                obrot := obrot + 2;
              if (nk1 <= 180) then
                kier := k;
              skreca := true;
            end;
          end;

          if (kier >= 360) then
            kier := kier - 360
          else if (kier < 0) then
            kier := kier + 360;

          // lec w gore lub dol
          if gdzie_y(x, z, y) > y - 50 then
            k := -50
          else if (gdzie_y(x + sin(kier * pi180) * szybkosc * 15, z - cos(kier * pi180) * szybkosc * 15, y) > y - 50) or
            (gdzie_y(x + sin(kier * pi180) * szybkosc * 30, z - cos(kier * pi180) * szybkosc * 30, y) > y - 50) or
            (gdzie_y(x + sin(kier * pi180) * szybkosc * 50, z - cos(kier * pi180) * szybkosc * 50, y) > y - 50) or
            (gdzie_y(x + sin(kier * pi180) * szybkosc * 65, z - cos(kier * pi180) * szybkosc * 65, y) > y - 50) then
            k := -85
          else
            k := 0;

          if (round(k) <> round(kierdol)) then
          begin
            k1 := round(k); // round(kierdol - k);

            if kierdol > k1 then
              kierdol := kierdol - 2;
            if kierdol < k1 then
              kierdol := kierdol + 2;

          end;

        end;

        if not zniszczony then
        begin
          if not skreca then
          begin
            if obrot > 0 then
            begin
              obrot := obrot - 2;
              if obrot < 0 then
                obrot := 0;
            end;
            if obrot < 0 then
            begin
              obrot := obrot + 2;
              if obrot > 0 then
                obrot := 0;
            end;
          end;
        end;

        if zniszczony then
        begin
          if szybkosc < 1 then
            szybkosc := szybkosc + 0.1
          else if szybkosc < 2.2 then
            szybkosc := szybkosc + 0.01;
          if kierdol < 60 then
          begin
            kierdol := kierdol + 1;
            if kierdol > 60 then
              kierdol := 60;
          end;

          obrot := obrot + szybkosc * 4;

        end;

        if wysadz then
        begin
          Sfx.graj_dzwiek(1, x, y, z);
          nowe_swiatlo(x, y, z, 2, 0.003);
          for b := 0 to 9 do
          begin
            nowy_dym(x, y, z, (random - 0.5) / 3, (random) / 5, (random - 0.5) / 3, 5 + random * 10, 0,
              0.03 - random * 0.027);
          end;

          for b := 0 to High(obiekt[ob_dzialkokawalki].o.Groups) do
            nowy_smiec(x, y, z, (random - 0.5) * 1.4, (random - 0.5) * 1.4, (random - 0.5) * 1.4, b, ob_dzialkokawalki,
              0, random(99999), random);

          (* if gracz.zyje then begin
            s:=sqrt2(sqr(gracz.x-x)+sqr(gracz.y-y)+sqr(gracz.z-z));
            if s<=10 then begin
            gracz.sila:=gracz.sila-((10-s)/4);
            if gracz.sila<0 then gracz.sila:=0;
            {gracz.dx:=gracz.dx+dx/3;
            gracz.dy:=gracz.dy+dy/3;
            gracz.dz:=gracz.dz+dz/3;}
            end;
            end; *)

          jest := false;
        end;

      end;

      if not jest and dzw_slychac then
      begin
        FSOUND_StopSound(dzw_kanal);
        dzw_slychac := false;
      end;

    end;
end;

// ---------------------------------------------------------------------------
procedure ruch_dzialek;
const
  ciemno: array [0 .. 4] of record x, z: integer end = ((x: 0; z: 0), (x: 1; z: 0), (x: 0; z: 1), (x: - 1; z: 0),
    (x: 0; z: - 1));
  BARREL_LENGTH = 13;
var
  a, b, grlot, nx, nz, k1, nk1: integer;
  k, k2, s, s1, gx1, gz1: real;
  ok: boolean;
  szybruch: real;
begin
  gra.iledzialek := 0;
  gracz.namierzone := -1;
  gracz.odlegloscnamierzonegodzialka := 999999;
  szybruch := 0.8 + gra.difficultyLevel / 100;
  // szybkosc ruchu dzialka zalezna od planety
  for a := 0 to high(dzialko) do
    with dzialko[a] do
    begin
      if jest then
      begin
        if not rozwalone then
        begin
          inc(gra.iledzialek);

          { if palisie and (random(4)=0) then begin
            nowy_dym(x,y+1+random*2,z, (random-0.5)/4,0.2+random/3,(random-0.5)/4, 0.4+random/2,0, 0.05);
            sila:=sila-0.008;
            end; }

          inc(swiatlo);
          if namierza and (swiatlo > 30) then
            swiatlo := 0;
          if not namierza and (swiatlo > 70) then
            swiatlo := 0;

          if (sila > 0) then
          begin
            if (sila < 1) and (random(round(sila * 7)) = 0) then
              nowy_dym(x, y, z, 0, 0.3, 0, 5 - sila * 3, 1);
            if gracz.zyje then
            begin
              if (x > -ziemia.px / 2) and (gracz.x < ziemia.px / 2) then
                gx1 := gracz.x - ziemia.px * 2
              else if (x < ziemia.px / 2) and (gracz.x > -ziemia.px / 2) then
                gx1 := gracz.x + ziemia.px * 2
              else
                gx1 := gracz.x;
              if (z > -ziemia.pz / 2) and (gracz.z < ziemia.pz / 2) then
                gz1 := gracz.z - ziemia.pz * 2
              else if (z < ziemia.pz / 2) and (gracz.z > -ziemia.pz / 2) then
                gz1 := gracz.z + ziemia.pz * 2
              else
                gz1 := gracz.z;

              s := sqrt2(sqr(gx1 - x) + sqr(gracz.y - y) + sqr(gz1 - z));
              if s <= 500 + gra.difficultyLevel * 2 then
              begin

                // gracz namierza dzialko:
                k := (jaki_to_kat(gx1 - x, gz1 - z) + 180) - gracz.kier;
                if k > 180 then
                  k := k - 360;

                k2 := jaki_to_kat(sqrt2(sqr(gx1 - x) + sqr(gz1 - z)), gracz.y - y) - 90;

                if (abs(k) < 20) and (abs(k2) < 130) and (s < gracz.odlegloscnamierzonegodzialka) then
                begin
                  gracz.conamierzone := 0;
                  gracz.namierzone := a;
                  gracz.odlegloscnamierzonegodzialka := s;
                end;

                // namierzanie w gracza
                if not namierza and (random(80 - round(gra.difficultyLevel * 0.7)) = 0) then
                  namierza := true;
                if namierza then
                begin
                  ok := true;
                  if rodzaj = 0 then
                  begin
                    s1 := 3 + gra.difficultyLevel / 30; // sila z jaka strzeli
                    s := sqrt2(sqr(x - gx1) + sqr(y - gracz.y) + sqr(z - gz1)) / (1.15 * s1); // odleglosc
                  end
                  else
                  begin
                    s := 0.1;
                    s1 := 15 + gra.difficultyLevel / 30; // sila z jaka strzeli
                  end;

                  k := (jaki_to_kat((gx1 + gracz.dx * s) - x, (gz1 + gracz.dz * s) - z));

                  kier_ := k;
                  if (k <> kier) then
                  begin
                    k1 := (round(kier - k) + 360) mod 360;
                    if (k1 <= 180) then
                    begin
                      kier := kier - (szybruch * 2);
                      nk1 := (round(kier - k) + 360) mod 360;
                      if (nk1 > 180) then
                        kier := k;
                    end
                    else
                    begin
                      if (k1 > 180) then
                        kier := kier + (szybruch * 2);
                      nk1 := (round(kier - k) + 360) mod 360;
                      if (nk1 <= 180) then
                        kier := k;
                    end;
                  end;

                  if abs(k - kier) > 6 then
                    ok := false;

                  if (kier >= 360) then
                    kier := kier - 360
                  else if (kier < 0) then
                    kier := kier + 360;

                  k := 90 - jaki_to_kat(sqrt2(sqr(x - (gx1 + gracz.dx * s)) + sqr(z - (gz1 + gracz.dz * s))),
                    y - (gracz.y + gracz.dy * s));

                  if (k < 10) then
                    k := 10;
                  if (k > 89) then
                    k := 89;

                  kat_ := k;

                  if (k <> kat) then
                  begin
                    if kat > k then
                    begin
                      kat := kat - szybruch;
                      if kat < k then
                        kat := k;
                    end
                    else if kat < k then
                    begin
                      kat := kat + szybruch;
                      if kat > k then
                        kat := k;
                    end;
                  end;

                  if abs(k - kat) > 6 then
                    ok := false;

                  if ok and (((rodzaj = 0) and (random(round(300 - gra.difficultyLevel * 2.5)) = 0)) or
                    ((rodzaj = 1) and (random(round(70 - gra.difficultyLevel * 0.6)) = 0))) then
                  begin
                    if rodzaj = 0 then
                    begin
                      strzel(
                        x + (sin(kier * pi180) * cos(kat * pi180)) * BARREL_LENGTH,
                        y + sin(kat * pi180) * BARREL_LENGTH,
                        z + (-cos(kier * pi180) * cos(kat * pi180)) * BARREL_LENGTH,
                        (sin(kier * pi180) * cos(kat * pi180)) * s1 +
                        (random - 0.5) / 3, sin(kat * pi180) * s1 + (random - 0.5) / 3,
                        (-cos(kier * pi180) * cos(kat * pi180)) * s1 + (random - 0.5) / 3, 1, 0, 2.3, Vec3d(0, 0, 0));

                      Sfx.graj_dzwiek(6, x, y, z);
                    end
                    else
                    begin
                      if shootSide = 1 then
                        shootSide := -1
                      else
                        shootSide := 1;
                      strzel(
                        x + (sin(kier * pi180) * cos(kat * pi180)) * BARREL_LENGTH  + sin((90 + gracz.kier) * pi180) * (1.9 * shootSide),
                        y + sin(kat * pi180) * BARREL_LENGTH,
                        z + (-cos(kier * pi180) * cos(kat * pi180)) * BARREL_LENGTH  - cos((90 + gracz.kier) * pi180) *  (1.9 * shootSide),
                        (sin(kier * pi180) * cos(kat * pi180)) * s1 +
                        (random - 0.5) / 3, sin(kat * pi180) * s1 + (random - 0.5) / 3,
                        (-cos(kier * pi180) * cos(kat * pi180)) * s1 + (random - 0.5) / 3, 1, 1, 0.99, Vec3d(0, 0, 0));

                      Sfx.graj_dzwiek(20, x, y, z);

                    end;
                  end;
                end;

              end
              else
                namierza := false;
            end
            else
              namierza := false;

            if not namierza then
            begin

              if (kier_ <> kier) then
              begin
                k1 := (round(kier - kier_) + 360) mod 360;
                if (k1 <= 180) then
                begin
                  kier := kier - 1;
                  nk1 := (round(kier - kier_) + 360) mod 360;
                  if (nk1 > 180) then
                    kier := kier_;
                end
                else
                begin
                  if (k1 > 180) then
                    kier := kier + 1;
                  nk1 := (round(kier - kier_) + 360) mod 360;
                  if (nk1 <= 180) then
                    kier := kier_;
                end;
              end;

              if (kier >= 360) then
                kier := kier - 360
              else if (kier < 0) then
                kier := kier + 360;

              if kat < kat_ then
              begin
                kat := kat + 0.4;
                if kat > kat_ then
                  kat := kat_;
              end;
              if kat > kat_ then
              begin
                kat := kat - 0.4;
                if kat < kat_ then
                  kat := kat_;
              end;

              if (round(kat) = round(kat_)) and (round(kier) = round(kier_)) and (random(100) = 0) then
              begin
                kat_ := 10 + random(40);
                kier_ := random(360);
              end;

            end;
          end
          else
          begin
            nowe_swiatlo(x, y, z, 2, 0.004);
            for b := 0 to 39 do
            begin
              nowy_dym(x, y, z, (random - 0.5) / 3, (random) / 5, (random - 0.5) / 3, 12 + random * 30, 0,
                0.02 - random * 0.018);
            end;

            for b := 0 to High(obiekt[ob_dzialkokawalki].o.Groups) do
              nowy_smiec(x, y, z, (random - 0.5) * 1.4, (random - 0.2) * 0.8, (random - 0.5) * 1.4, b,
                ob_dzialkokawalki, 0, random(99999), random);

            xznasiatce(nx, nz, x, z);

            for b := 0 to high(ciemno) do
            begin
              if (nx + ciemno[b].x >= 0) and (nx + ciemno[b].x <= ziemia.wx - 1) and (nz + ciemno[b].z >= 0) and
                (nz + ciemno[b].z <= ziemia.wz - 1) then
              begin
                ziemia.pk[nx + ciemno[b].x, nz + ciemno[b].z].p := ziemia.pk[nx + ciemno[b].x, nz + ciemno[b].z].p - 2 -
                  random * 2;
                ziemia.pk[nx + ciemno[b].x, nz + ciemno[b].z].kr := ziemia.pk[nx + ciemno[b].x, nz + ciemno[b].z]
                  .kr * 0.05;
                ziemia.pk[nx + ciemno[b].x, nz + ciemno[b].z].kg := ziemia.pk[nx + ciemno[b].x, nz + ciemno[b].z]
                  .kg * 0.05;
                ziemia.pk[nx + ciemno[b].x, nz + ciemno[b].z].kb := ziemia.pk[nx + ciemno[b].x, nz + ciemno[b].z]
                  .kb * 0.05;
              end;
            end;
            rozwalone := true;
            inc(gra.dzialekzniszczonych);
          end;
        end
        else
        begin // rozwalone
          if random(700) = 0 then
            jest := false;
          if random(6) = 0 then
            nowy_dym(x, y, z, (random - 0.5) * 0.06, 0.3, (random - 0.5) * 0.06, 3 + random * 3, 1, 0.003);

        end;
      end;
    end;
end;

// ---------------------------------------------------------------------------
procedure ruch_smieci;
var
  a, b: integer;
  newDelta: TVec3D;
begin
  for a := 0 to high(smiec) do
    with smiec[a] do
    begin
      if jest then
      begin
        x := x + dx;
        y := y + dy; // -0.3;
        z := z + dz;

        dec(czas);
        if czas <= 0 then
          jest := false;

        if licz mod 8 = 0 then
        begin
          dx := dx * ziemia.gestoscpowietrza;
          dz := dz * ziemia.gestoscpowietrza;
        end;
        dy := dy - ziemia.grawitacja * 2;

        if { (dy>0) and } (y >= matka.y - 25) and (y <= matka.y - 75) then
        begin
          if abs(dy) > 0.16 then
            Sfx.graj_dzwiek(7, x, y, z);
          if dy > 0 then
            dy := -abs(dy) / 2;
          dx := dx * 0.8;
          dz := dz * 0.8;
          if sqrt2(sqr(dx) + sqr(dy) + sqr(dz)) > 0.1 then
            for b := 0 to 5 + random(10) do
              nowa_iskra(x, y, z, (random - 0.5) * (0.2 + dx * 2), (random) * (abs(dy * 2) + 0.15),
                (random - 0.5) * (0.2 + dz * 2));
        end
        else if (dy <= 0) and (y <= gdzie_y(x, z, y)) then
        begin
          if abs(dy) > 0.16 then
          begin
            case typ of
              0:
                Sfx.graj_dzwiek(7, x, y, z);
              1:
                Sfx.graj_dzwiek(3, x, y, z);
            end;
          end;

          newDelta := Bounce(TVec3D.ToVec(x, y, z), TVec3D.ToVec(dx, dy, dz));
          x := x - dx;
          y := y - dy;
          z := z - dz;
          dx := newDelta.x * 0.6;
          dy := newDelta.y * 0.6;
          dz := newDelta.z * 0.6;

          if abs(dy) < 0.02 then
          begin
            y := y - 0.1;
            if y <= gdzie_y(x, z, y) - 8 then
              jest := false;
          end;
          if (typ = 0) and (sqrt2(sqr(dx) + sqr(dy) + sqr(dz)) > 0.2) then
            for b := 0 to 5 + random(10) do
              nowa_iskra(x, y, z, (random - 0.5) * (0.2 + dx * 2), (random) * (abs(dy) + 0.15),
                (random - 0.5) * (0.2 + dz * 2));

        end
        else
        begin
          dx := dx + sin(wiatr.kier * pi180) * wiatr.sila / 4;
          dz := dz - cos(wiatr.kier * pi180) * wiatr.sila / 4;
        end;

        obrx := obrx + dx * 30;
        obry := obry + dy * 30;
        obrz := obrz + dz * 30;

        if (dymisie) and (sqrt2(dx * dx + dy * dy + dz * dz) > 0.1) and (random(3) = 0) then
        begin
          nowy_dym(x, y, z, 0, 0.3 + random * 0.07, 0, 1.0, 1);
          if (typ = 1) and (random(50) = 0) then
            dymisie := false;
        end;

        if palisie and (random(2) = 0) then
        begin
          nowy_dym(x, y, z, 0, 0.05 + random / 8, 0, 0.3 + random / 4, 0);
          if random(70) = 0 then
            palisie := false;
        end;

      end;
    end;
end;

// ---------------------------------------------------------------------------
procedure ruch_matki;
const
  FIRE_SIZE = 60; // 20.1 + random * 10
  FIRE_FADE_OUT_SPEED = 0.01; //0.02
begin
  // matka
  if gra.etap = 1 then
  begin
    if gracz.y > matka.y - 500 then
    begin
      if random(3) = 0 then
        nowy_dym(matka.x - 315, matka.y - 70, matka.z, (random - 0.5) / 20, -0.9, (random - 0.5) / 20,
          24.1 + random * 10, 0, 0.06);
      if random(3) = 0 then
        nowy_dym(matka.x + 277, matka.y - 70, matka.z + 195, (random - 0.5) / 20, -0.9, (random - 0.5) / 20,
          24.1 + random * 10, 0, 0.06);
      if random(3) = 0 then
        nowy_dym(matka.x + 277, matka.y - 70, matka.z - 195, (random - 0.5) / 20, -0.9, (random - 0.5) / 20,
          24.1 + random * 10, 0, 0.06);
    end;
  end
  else
  begin
    nowy_dym(matka.x + 400, matka.y - 20, matka.z - 205, 10 + random * 4, (random - 0.5) / 20, (random - 0.5) / 20,
      FIRE_SIZE + random * 10, 0, FIRE_FADE_OUT_SPEED);
    nowy_dym(matka.x + 400, matka.y - 20, matka.z + 205, 10 + random * 4, (random - 0.5) / 20, (random - 0.5) / 20,
      FIRE_SIZE + random * 10, 0, FIRE_FADE_OUT_SPEED);
  end;
end;

// ---------------------------------------------------------------------------
procedure ustaw_kolor_tla;
var
  a: integer;
begin
  for a := 0 to 2 do
  begin
    if gra.jestkamera[0, 1] > matka.y - 350 then
    begin
      ziemia.jestkoltla[a] := ziemia.koltla[a] * ((matka.y - 100 - gra.jestkamera[0, 1]) / 250);
    end
    else
      ziemia.jestkoltla[a] := ziemia.koltla[a];
  end;

  if ziemia.jestkoltla[0] > ziemia.koltla[0] then
    ziemia.jestkoltla[0] := ziemia.koltla[0];
  if ziemia.jestkoltla[0] < 0 then
    ziemia.jestkoltla[0] := 0;
  if ziemia.jestkoltla[1] > ziemia.koltla[1] then
    ziemia.jestkoltla[1] := ziemia.koltla[1];
  if ziemia.jestkoltla[1] < 0 then
    ziemia.jestkoltla[0] := 0;
  if ziemia.jestkoltla[2] > ziemia.koltla[2] then
    ziemia.jestkoltla[2] := ziemia.koltla[2];
  if ziemia.jestkoltla[2] < 0 then
    ziemia.jestkoltla[2] := 0;
  glFogfv(GL_FOG_COLOR, @ziemia.jestkoltla);
  glClearColor(ziemia.jestkoltla[0], ziemia.jestkoltla[1], ziemia.jestkoltla[2], ziemia.jestkoltla[3]);
end;

// ---------------------------------------------------------------------------
procedure ruch_ladowisk;
var
  a, b: integer;
  x1, z1, c, c1, gx1, gz1: real;
begin
  if (length(ladowiska) = 0) or (SurvivorList.Count = 0) or (not gracz.zyje) or (gracz.y >= matka.y) then
    exit;

  for a := 0 to high(ladowiska) do
  begin
    b := 0;
    while (b <= SurvivorList.Count - 1) and ((not SurvivorList[b].jest) or (SurvivorList[b].zly) or (SurvivorList[b].nalotnisku <> a)) do
      inc(b);

    if b <= SurvivorList.Count - 1 then
    begin

      x1 := ladowiska[a].x * ziemia.wlk + ziemia.px;
      z1 := ladowiska[a].z * ziemia.wlk + ziemia.pz;

      if (x1 > -ziemia.px / 2) and (gracz.x < ziemia.px / 2) then
        gx1 := gracz.x - ziemia.px * 2
      else if (x1 < ziemia.px / 2) and (gracz.x > -ziemia.px / 2) then
        gx1 := gracz.x + ziemia.px * 2
      else
        gx1 := gracz.x;
      if (z1 > -ziemia.pz / 2) and (gracz.z < ziemia.pz / 2) then
        gz1 := gracz.z - ziemia.pz * 2
      else if (z1 < ziemia.pz / 2) and (gracz.z > -ziemia.pz / 2) then
        gz1 := gracz.z + ziemia.pz * 2
      else
        gz1 := gracz.z;

      c := sqrt2(sqr(gx1 - x1) + sqr(gz1 - z1));
      c1 := sqrt2(sqr((gx1 - gracz.dx) - x1) + sqr((gz1 - gracz.dz) - z1));

      if ((c < 900) and (c1 >= 900)) and (random(4) = 0) then
        strzel(x1, gdzie_y(x1, z1, 0) + 10, z1, random - 0.5, 1.3 + random, random - 0.5, 0, 2, 1, Vec3D(0, 0, 0));

    end;

  end;

end;

// ---------------------------------------------------------------------------
procedure sprawdzaj_cheat_codes;
const
  litery: array [0 .. 25] of byte = (30, 48, 46, 32, 18, 33, 34, 35, 23, 36, 37, 38, 50, 49, 24, 25, 16, 19, 31, 20, 22,
    47, 17, 45, 21, 44);
var
  a, b, c: integer;
  pasuje: boolean;
begin
  if cheaty.czas_od_ostatniej_litery > 0 then
  begin
    dec(cheaty.czas_od_ostatniej_litery);
    if cheaty.czas_od_ostatniej_litery <= 0 then
      setlength(cheaty.wpisany_tekst, 0);
  end;

  // sprawdz czy jakas litera nie zostala wcisnieta
  for a := 0 to high(litery) do
  begin
    if frmMain.PwrInp.KeyPressed[litery[a]] then
    begin // jesli tak
      cheaty.czas_od_ostatniej_litery := 100;
      // dodaj litere do wpisywanego tekstu:
      setlength(cheaty.wpisany_tekst, length(cheaty.wpisany_tekst) + 1);
      cheaty.wpisany_tekst[high(cheaty.wpisany_tekst)] := litery[a];

      // i sprawdz czy ten tekst pasuje do ktoregos z kodow:
      pasuje := false;
      for b := 0 to high(cheatcodes_n) do
      begin
        c := 0;
        while (c <= high(cheaty.wpisany_tekst)) and (c <= high(cheatcodes_n[b])) and
          (cheaty.wpisany_tekst[c] = cheatcodes_n[b][c]) do
          inc(c);

        if c > high(cheatcodes_n[b]) then
        begin // jesli jest caly dobry:
          case b of
            0:
              cheaty.full := not cheaty.full;
            1:
              begin
                cheaty.god := not cheaty.god;
                if cheaty.god and not gracz.zyje then
                  cheaty.god := false; // nie wlaczaj GOD jesli gracz juz zginal
              end;
            2:
              cheaty.fuel := not cheaty.fuel;
            3:
              cheaty.weapon := not cheaty.weapon;
            4:
              cheaty.lives := not cheaty.lives;
            5:
              cheaty.load := not cheaty.load;
            6:
              cheaty.time := not cheaty.time;
            7:
              begin
                gra.misjawypelniona := true;
                gra.moznakonczyc := true;
                gra.returnToMothership := true;
              end;
            8:
              begin
                gracz.x := matka.x;
                gracz.z := matka.z;
                gracz.y := matka.y + 5;
                gracz.dx := 0;
                gracz.dy := 0;
                gracz.dz := 0;
              end;
            9:
              begin
                gracz.x := matka.x;
                gracz.z := matka.z;
                gracz.y := matka.y - 200;
                gracz.dx := 0;
                gracz.dy := 0;
                gracz.dz := 0;

                if gracz.y < gdzie_y(gracz.x, gracz.z, gracz.y) + 30 then
                  gracz.y := gdzie_y(gracz.x, gracz.z, gracz.y) + 30;
              end;
            10:
              begin
                cheaty.bigHeads := not cheaty.bigHeads;
              end;
          end;

          setlength(cheaty.wpisany_tekst, 0);
          exit;
        end
        else
        begin // jesli tylko kawalek dobry, to pozwol pisac dalej:
          if (c >= 1) and (c > high(cheaty.wpisany_tekst)) and (c <= high(cheatcodes_n[b])) and
            (cheaty.wpisany_tekst[c - 1] = cheatcodes_n[b][c - 1]) then
            pasuje := true;

        end;
      end;

      if not pasuje then
        // jesli nie pasuje do zadnego kodu, to wyczysc pole wpisywania
        setlength(cheaty.wpisany_tekst, 0);

    end;
  end;

  if cheaty.full then
  begin
    for a := 0 to high(gra.poziomupgrade) do
      gra.poziomupgrade[a] := 9;

    gracz.maxsila := upgrade[3, gra.poziomupgrade[3]].ile; // 1
    gracz.maxpaliwa := upgrade[0, gra.poziomupgrade[0]].ile; // 200;
    gracz.maxrakiet := round(upgrade[1, gra.poziomupgrade[1]].ile); // 10;
    gracz.maxdzialko := round(upgrade[2, gra.poziomupgrade[2]].ile); // 10;
    gracz.chlodz := upgrade[4, gra.poziomupgrade[4]].ile; // 0.5;
    gracz.ladownosc := round(upgrade[5, gra.poziomupgrade[5]].ile);

    gracz.sila := gracz.maxsila;
    gracz.paliwo := gracz.maxpaliwa;
    gracz.ilerakiet := gracz.maxrakiet;
    gracz.iledzialko := gracz.maxdzialko;

    cheaty.full := false;
  end;
  if cheaty.god then
  begin
    gracz.sila := gracz.maxsila;
    gracz.zyje := true;
    gracz.temp := 0;
    gracz.uszkodzenia[0] := false;
    if kamera <> 7 then
      gracz.oslonablysk := 0.4;
  end;
  if cheaty.fuel then
  begin
    gracz.paliwo := gracz.maxpaliwa;
  end;
  if cheaty.weapon then
  begin
    gracz.ilerakiet := gracz.maxrakiet;
    gracz.iledzialko := gracz.maxdzialko;
  end;
  if cheaty.lives then
  begin
    gra.zycia := 9;
    cheaty.lives := false;
  end;
  if cheaty.load then
  begin
    gracz.ladownosc := 99;
  end;
  if cheaty.time then
  begin
    gra.czas := 99 * 60;
  end;

end;

function canCreateFighters: boolean;
begin
  if not gra.sandboxMode and (gra.rodzajmisji in [0, 1]) then
  begin
    result := (gracz.y <= matka.y - 150) and
      (gra.iledzialek > 0) and
      (random(1100 - gra.difficultyLevel * 5) = 0);
  end
  else
  begin
    result :=
      (random(1100 - gra.difficultyLevel * 10) = 0);
  end;
end;

// ---------------------------------------------------------------------------
procedure ruch_w_czasie_gry;
const
  ka = 10;
  kb = 1;
var
  a, b: integer;
  c, c1, x1, z1: real;
  kx, ky, kz: extended;
  bylakamera: array [0 .. 2] of real;
begin
  bylakamera[0] := gra.jestkamera[0, 0];
  bylakamera[1] := gra.jestkamera[0, 1];
  bylakamera[2] := gra.jestkamera[0, 2];
  for a := 0 to 2 do
    for b := 0 to 2 do
    begin
      if gra.jestkamera[a, b] <> gra.kamera[a, b] then
      begin
        if ((not gra.pauza) and (kamera = 7)) or (kamera <> 7) then
          gra.jestkamera[a, b] := (gra.jestkamera[a, b] * ka + gra.kamera[a, b]) / (ka + 1)
        else
          gra.jestkamera[a, b] := (gra.jestkamera[a, b] * kb + gra.kamera[a, b]) / (kb + 1);
      end;
    end;

  case kamera of
    0:
      begin
        gra.jestkamera[0, 0] := gracz.x - sin((gracz.kier - gracz.szybkier * 2) * pi180) * 7;
        gra.jestkamera[0, 1] := gracz.y + 10;
        gra.jestkamera[0, 2] := gracz.z + cos((gracz.kier - gracz.szybkier * 2) * pi180) * 7;
        gra.jestkamera[1, 0] := gracz.x;
        gra.jestkamera[1, 1] := gracz.y + 9;
        gra.jestkamera[1, 2] := gracz.z;
        gra.kamera[2, 0] := 0;
        gra.kamera[2, 1] := 1;
        gra.kamera[2, 2] := 0;
      end;
    1:
      begin
        gra.kamera[0, 0] := gracz.x - sin((gracz.kier - gracz.szybkier * 2) * pi180) * 30;
        gra.kamera[0, 1] := gracz.y - 30;
        gra.kamera[0, 2] := gracz.z + cos((gracz.kier - gracz.szybkier * 2) * pi180) * 30;
        gra.kamera[1, 0] := gracz.x;
        gra.kamera[1, 1] := gracz.y;
        gra.kamera[1, 2] := gracz.z;
        gra.kamera[2, 0] := 0;
        gra.kamera[2, 1] := 1;
        gra.kamera[2, 2] := 0;
      end;
    2:
      begin
        kx := {gracz.dx + }sin((gracz.kier) * pi180);
        ky := -0.5 +  gracz.dy / 2;
        kz := {gracz.dz }- cos((gracz.kier) * pi180);
        normalize3D(kx, ky, kz);

        gra.kamera[0, 0] := gracz.x - kx * 60;
        gra.kamera[0, 1] := gracz.y - ky * 60;
        gra.kamera[0, 2] := gracz.z - kz * 60;

        gra.kamera[1, 0] := gracz.x + kx * 50;
        gra.kamera[1, 1] := gracz.y + ky * 50;
        gra.kamera[1, 2] := gracz.z + kz * 50;

        c := Distance2D(0, 0, gracz.dx, gracz.dz);
        kx := gracz.dx;
        ky := 1 + c;
        kz := gracz.dz;
        normalize3D(kx, ky, kz);

        gra.kamera[2, 0] := kx;
        gra.kamera[2, 1] := ky;
        gra.kamera[2, 2] := kz;
      end;
    3:
      begin
        gra.kamera[0, 0] := gracz.x + sin((gracz.kier - gracz.szybkier * 2) * pi180) * 30;
        gra.kamera[0, 1] := gracz.y + 10;
        gra.kamera[0, 2] := gracz.z - cos((gracz.kier - gracz.szybkier * 2) * pi180) * 30;
        gra.kamera[1, 0] := gracz.x;
        gra.kamera[1, 1] := gracz.y + 5;
        gra.kamera[1, 2] := gracz.z;
        gra.kamera[2, 0] := 0;
        gra.kamera[2, 1] := 1;
        gra.kamera[2, 2] := 0;
      end;
    4:
      begin
        gra.kamera[0, 0] := gracz.x - sin((gracz.kier - gracz.szybkier * 2) * pi180) * 30;
        gra.kamera[0, 1] := gracz.y + 10;
        gra.kamera[0, 2] := gracz.z + cos((gracz.kier - gracz.szybkier * 2) * pi180) * 30;
        gra.kamera[1, 0] := gracz.x;
        gra.kamera[1, 1] := gracz.y + 5;
        gra.kamera[1, 2] := gracz.z;
        gra.kamera[2, 0] := 0;
        gra.kamera[2, 1] := 1;
        gra.kamera[2, 2] := 0;
      end;
    5:
      begin
        gra.kamera[0, 0] := gracz.x - sin((gracz.kier - gracz.szybkier * 2) * pi180) * 15;
        gra.kamera[0, 1] := gracz.y + 170;
        gra.kamera[0, 2] := gracz.z + cos((gracz.kier - gracz.szybkier * 2) * pi180) * 15;
        gra.kamera[1, 0] := gracz.x;
        gra.kamera[1, 1] := gracz.y;
        gra.kamera[1, 2] := gracz.z;
        gra.kamera[2, 0] := 0;
        gra.kamera[2, 1] := 1;
        gra.kamera[2, 2] := 0;
      end;
    6:
      begin
        { gra.kamera[0,0]:=gracz.x-sin((gracz.kier-gracz.szybkier*2)*pi180)*15;
          gra.kamera[0,1]:=gracz.y+170;
          gra.kamera[0,2]:=gracz.z+cos((gracz.kier-gracz.szybkier*2)*pi180)*15; }

        c1 := 999999;
        b := -1;

        if length(ladowiska) >= 1 then
        begin
          c1 := -1;
          b := 0;
          for a := 0 to high(ladowiska) do
          begin
            x1 := ladowiska[a].x * ziemia.wlk + ziemia.px;
            z1 := ladowiska[a].z * ziemia.wlk + ziemia.pz;
            c := sqrt2(sqr(gracz.x - x1) + sqr(gracz.z - z1) + sqr(gracz.y - gdzie_y(x1, z1, 0)));
            if (a = 0) or (c < c1) then
            begin
              b := a;
              c1 := c;
            end;
          end;
        end;

        c := sqrt2(sqr(gracz.x - matka.x + 5) + sqr(gracz.z - matka.z) + sqr(gracz.y - matka.y + 6));
        if (c < c1) then
        begin
          b := -1;
          c1 := c;
        end;

        if { (length(ladowiska)>=1) and } (c1 <= 500) then
        begin
          if b >= 0 then
          begin
            gra.kamera[0, 0] := ladowiska[b].x * ziemia.wlk + ziemia.px;
            gra.kamera[0, 1] := gdzie_y(ladowiska[b].x * ziemia.wlk + ziemia.px,
              ladowiska[b].z * ziemia.wlk + ziemia.pz, 0) + 5;
            gra.kamera[0, 2] := ladowiska[b].z * ziemia.wlk + ziemia.pz;
          end
          else
          begin
            gra.kamera[0, 0] := matka.x + 5;
            gra.kamera[0, 1] := matka.y + 6;
            gra.kamera[0, 2] := matka.z;
          end;
        end
        else
        begin
          gra.kamera[0, 0] := gracz.x - sin((gracz.kier - gracz.szybkier * 2) * pi180) * 40;
          gra.kamera[0, 1] := gracz.y;
          gra.kamera[0, 2] := gracz.z + cos((gracz.kier - gracz.szybkier * 2) * pi180) * 40;
        end;

        gra.kamera[1, 0] := gracz.x;
        gra.kamera[1, 1] := gracz.y;
        gra.kamera[1, 2] := gracz.z;
        gra.kamera[2, 0] := 0;
        gra.kamera[2, 1] := 1;
        gra.kamera[2, 2] := 0;
      end;
    7:
      begin // ze srodka
        gra.jestkamera[0, 0] := gracz.dx * 1 + gracz.x + sin((gracz.kier) * pi180);
        gra.jestkamera[0, 1] := gracz.dy * 1 + gracz.y + 3;
        gra.jestkamera[0, 2] := gracz.dz * 1 + gracz.z - cos((gracz.kier) * pi180);
        gra.jestkamera[1, 0] := gracz.dx * 1 + gracz.x + sin((gracz.kier) * pi180) * 10;
        gra.jestkamera[1, 1] := gracz.dy * 1 + gracz.y - 1 - Distance2D(0, 0, gracz.dx, gracz.dz) * 0.5;
        gra.jestkamera[1, 2] := gracz.dz * 1 + gracz.z - cos((gracz.kier) * pi180) * 10;

        kx := gracz.dx / 6;
        ky := 1;
        kz := gracz.dz / 6;
        normalize3D(kx, ky, kz);

        gra.kamera[2, 0] := kx;
        gra.kamera[2, 1] := ky;
        gra.kamera[2, 2] := kz;

      end;
    8: //watching
      begin
        c := Distance3D(gracz.x, gracz.y, gracz.z, gra.kamera[0, 0], gra.kamera[0, 1], gra.kamera[0, 2]);

        if c < 30 then
        begin
          if c = 0 then
            c := 0.1;
          gra.kamera[0, 0] := gracz.x + ((-gracz.x + gra.kamera[0, 0]) / c) * 30;
          gra.kamera[0, 1] := gracz.y + ((-gracz.y + gra.kamera[0, 1]) / c) * 30;
          gra.kamera[0, 2] := gracz.z + ((-gracz.z + gra.kamera[0, 2]) / c) * 30;
        end
        else
        if c > 400 then
        begin
          c := gracz.kier + (random - 0.5) * 60;
          c1 := 400 - random(100);

          gra.kamera[0, 0] := gracz.x + sin(c * pi180) * c1;
          gra.kamera[0, 1] := gracz.y + (random - 0.5) * 70;
          gra.kamera[0, 2] := gracz.z - cos(c * pi180) * c1;
          kx := gdzie_y(gra.kamera[0, 0], gra.kamera[0, 1], gra.kamera[0, 2]);
          if gra.kamera[0, 1] < kx + 20 then
            gra.kamera[0, 1] := kx + 20 + random(30);
        end
        else
          if c > 100 then
          begin
            gra.kamera[0, 0] := AnimateTo(gra.kamera[0, 0], gracz.x, 500);
            gra.kamera[0, 1] := AnimateTo(gra.kamera[0, 1], gracz.y, 500);
            gra.kamera[0, 2] := AnimateTo(gra.kamera[0, 2], gracz.z, 500);
          end;

        gra.kamera[1, 0] := gracz.x;
        gra.kamera[1, 1] := gracz.y;
        gra.kamera[1, 2] := gracz.z;
        gra.kamera[2, 0] := 0;
        gra.kamera[2, 1] := 1;
        gra.kamera[2, 2] := 0;
      end;
  end;
  c := gdzie_y(gra.kamera[0, 0], gra.kamera[0, 2], gra.kamera[0, 1]) + 3;
  if gra.kamera[0, 1] < c then
    gra.kamera[0, 1] := c;

  if gracz.zyje then
  begin // alarmy!
    if (gracz.paliwo > 0) and (gracz.paliwo < 40) and (licz mod 50 = 0) then
      Sfx.graj_dzwiek(9, 0, 0, 0, false);

    if (gracz.temp >= 240) and (licz mod 20 = 0) then
      Sfx.graj_dzwiek(14, 0, 0, 0, false);

    if (gracz.zlywsrodku) and (licz mod 20 = 0) then
      Sfx.graj_dzwiek(15, 0, 0, 0, false);
  end;

  gra.katkamera := jaki_to_kat(gra.jestkamera[0, 0] - gra.jestkamera[1, 0],
    gra.jestkamera[0, 2] - gra.jestkamera[1, 2]);

  listenerpos[0] := gra.jestkamera[0, 0];
  listenerpos[1] := gra.jestkamera[0, 1];
  listenerpos[2] := gra.jestkamera[0, 2];
  velv.x := (gra.jestkamera[0, 0] - bylakamera[0]) / (czas_klatki * 2);
  velv.y := (gra.jestkamera[0, 1] - bylakamera[1]) / (czas_klatki * 2);
  velv.z := (gra.jestkamera[0, 2] - bylakamera[2]) / (czas_klatki * 2);
  FSOUND_3D_Listener_SetAttributes(@listenerpos[0], @velv, sin(gra.katkamera * pi180) * 0.03, 0,
    -cos(gra.katkamera * pi180) * 0.03, 0.0, 0.03, 0);

  if GameController.Control(9).Pressed then
    kamera := 0;
  if GameController.Control(10).Pressed then
    kamera := 1;
  if GameController.Control(11).Pressed then
    kamera := 2;
  if GameController.Control(12).Pressed then
    kamera := 3;
  if GameController.Control(13).Pressed then
    kamera := 4;
  if GameController.Control(14).Pressed then
    kamera := 5;
  if GameController.Control(15).Pressed then
    kamera := 6;
  if GameController.Control(16).Pressed then
    kamera := 7;
  if GameController.Control(17).Pressed then
    kamera := 8;

  sprawdzaj_cheat_codes;

  wiatr.kier := wiatr.kier + (random - 0.5);

  ustaw_kolor_tla;

  if gra.jestkamera[0, 1] > matka.y - 350 then
  begin
    ziemia.widac := KeepValBetween((matka.y - 100 - gra.jestkamera[0, 1]) / 250, 0, 1);
  end
  else
    ziemia.widac := 1;

  if ziemia.showStars then
    matka.widac := 1
  else
    matka.widac := KeepValBetween(1 - (matka.y - 100 - gra.jestkamera[0, 1]) / 400, 0, 1);

  ziemia.chmuryx := ziemia.chmuryx - sin(wiatr.kier * pi180) * (wiatr.sila / 20) + gracz.dx * 0.0001;
  ziemia.chmuryz := ziemia.chmuryz - cos(wiatr.kier * pi180) * (wiatr.sila / 20) - gracz.dz * 0.0001;

  glFogfv(GL_FOG_COLOR, @ziemia.jestkoltla);
  glClearColor(ziemia.jestkoltla[0], ziemia.jestkoltla[1], ziemia.jestkoltla[2], ziemia.jestkoltla[3]);


  // mysliwce

  if canCreateFighters then
  begin
    c := random * 360; // kierunek, skad przyleci
    c1 := 900; // odleglosc od gracza
    if c1 > (ziemia.wx * ziemia.wlk) / 2 then
      c1 := (ziemia.wx * ziemia.wlk) / 2;
    if c1 > (ziemia.wz * ziemia.wlk) / 2 then
      c1 := (ziemia.wz * ziemia.wlk) / 2;
    b := 1;
    if (high(mysliwiec) >= 1) then
    begin
      b := 1 + random(gra.difficultyLevel div 21);
    end;
    for a := 1 to b do
      nowy_mysliwiec(gracz.x + sin((c + a * 3) * pi180) * (c1 + a * 30),
        gdzie_y(gracz.x + sin((c + a * 3) * pi180) * (c1 + a * 30), gracz.z - cos((c + a * 3) * pi180) * (c1 + a * 30),
        0) + 50 + random(150), gracz.z - cos((c + a * 3) * pi180) * (c1 + a * 30));
  end;

  // rozbicie gracza i nowe zycie
  if gra.czasdorozpoczecia > 0 then
  begin
    dec(gra.czasdorozpoczecia);
    if (frmMain.PwrInp.KeyPressed[DIK_space]) or (gra.zycia <= 0) then
      gra.czasdorozpoczecia := 0;
    if gra.czasdorozpoczecia = 0 then
    begin
      gra.czasdorozpoczecia := -1;
      if gra.zycia > 0 then
      begin
        ustaw_gracza_namatce;
      end
      else
      begin
        gra.koniecgry := true;
        frmMain.TimerCzas.Enabled := false;
      end;
    end;
  end;

  if not gracz.zyje and (gra.czasdorozpoczecia = -1) then
  begin
    gra.czasdorozpoczecia := 1000;
  end;

  // swiatlo z statku-matki
  if ((gracz.stoi) and (gracz.namatce)) or (gra.pilotowbiegniedomatki > 0) then
  begin
    if matka.otwarcie_drzwi < 1 then
    begin
      matka.otwarcie_drzwi := matka.otwarcie_drzwi + 0.01;
      if matka.otwarcie_drzwi > 1 then
        matka.otwarcie_drzwi := 1;
    end;
  end
  else
  begin
    if matka.otwarcie_drzwi > 0 then
    begin
      matka.otwarcie_drzwi := matka.otwarcie_drzwi - 0.01;
      if matka.otwarcie_drzwi < 0 then
        matka.otwarcie_drzwi := 0;
    end;

  end;

  // zakonczenie etapu
  if not gra.koniecgry then
  begin
    case gra.rodzajmisji of
      0:
        gra.returnToMothership :=
          (gra.zabranych + gracz.pilotow + gra.pilotowbiegniedomatki >= gra.minimum) or (gra.ilepilotow = 0);
      1:
        gra.returnToMothership :=
          (gra.dzialekzniszczonych >= gra.dzialekminimum) or (gra.iledzialek = 0);
      2:
        gra.returnToMothership :=
          (gra.fightersDestroyed >= gra.fightersMinimum);
    end;


    case gra.rodzajmisji of
      0:
        begin
          if (gra.czas <= 0) or (((gra.zabranych >= gra.minimum) or (gra.ilepilotow = 0)) and (gracz.pilotow = 0) and
            (gra.pilotowbiegniedomatki <= 0) and (((gracz.zyje) and (gracz.stoi) and (gracz.namatce)) or
            (not gracz.zyje and (gra.zycia >= 1)))) then
          begin
            gra.misjawypelniona := gra.zabranych >= gra.minimum;
            gra.moznakonczyc := true;
          end;
        end;
      1:
        begin
          if (gra.czas <= 0) or (((gra.dzialekzniszczonych >= gra.dzialekminimum) or (gra.iledzialek = 0)) and
            ((gracz.zyje and gracz.stoi and gracz.namatce) or (not gracz.zyje and (gra.zycia >= 1)))) then
          begin
            gra.misjawypelniona := gra.dzialekzniszczonych >= gra.dzialekminimum;
            gra.moznakonczyc := true;
          end;
        end;
      2:
        begin
          if (gra.czas <= 0) or ((gra.fightersDestroyed >= gra.fightersMinimum) and
            ((gracz.zyje and gracz.stoi and gracz.namatce) or (not gracz.zyje and (gra.zycia >= 1)))) then
          begin
            gra.misjawypelniona := gra.fightersDestroyed >= gra.fightersMinimum;
            gra.moznakonczyc := true;
          end;
        end;
    end;
  end;

  if gra.sandboxMode then
  begin
    gra.misjawypelniona := false;
    gra.moznakonczyc := false;
    gra.returnToMothership := false;
  end;

  // misja wypelniona
  if (gra.moznakonczyc and ((gracz.stoi and gracz.namatce) or (not gracz.zyje))) and (GameController.Control(8).Active) or
    (gra.czas <= 0) then
  begin
    if gra.misjawypelniona then
    begin
      case gra.rodzajmisji of
        0:
          begin
            inc(gra.kasa, (gra.zabranych - gra.minimum) * 30);
            inc(gra.pkt, (gra.zabranych - gra.minimum) * 350);
          end;
        1:
          begin
            inc(gra.kasa, (gra.dzialekzniszczonych - gra.dzialekminimum) * 30);
            inc(gra.pkt, (gra.dzialekzniszczonych - gra.dzialekminimum) * 350);
          end;
        2:
          begin
            inc(gra.kasa, (gra.fightersDestroyed - gra.fightersMinimum) * 30);
            inc(gra.pkt, (gra.fightersDestroyed - gra.fightersMinimum) * 350);
          end;
      end;
      inc(gra.kasa, gra.czas);
      inc(gra.pkt, gra.czas * 4);
    end;

    frmMain.TimerCzas.Enabled := false;

    if gra.sandboxMode then
    begin
      gra.koniecgry := true;
    end
    else
    if (gra.czas <= 0) and (not gracz.stoi and not gracz.namatce) then
    begin
      gracz.sila := 0;
      if gra.zycia <= 1 then
        gra.koniecgry := true
      else
      begin
        gra.etap := 2;
        intro.czas := 0;
        intro.czas2 := 0;
        intro.scena := 0;

      end;

    end
    else
    begin
      gra.etap := 2;
      intro.czas := 0;
      intro.czas2 := 0;
      intro.scena := 0;
    end;
    FSOUND_SetPaused(muzchannel, true);
  end;

  // przegrana z braku czasu
  { if (gra.czas<=0) and (not gracz.stoi and not gracz.namatce and not gra.misjawypelniona) then begin
    frmMain.TimerCzas.Enabled:=false;
    gra.czas:=0;
    gracz.sila:=0;
    end;
  }
  if gra.koniecgry and ((frmMain.PwrInp.KeyPressed[DIK_space]) or gra.sandboxMode) then
  begin
    zatrzymaj_dzwieki_ciagle;
    winieta.jest := true;
    winieta.skrol := 0;
    if gra.sandboxMode then
      winieta.corobi := 5
    else
      winieta.corobi := 0;
    FSOUND_SetPaused(muzchannel, true);
    Sfx.muzyke_wlacz(1, true);
  end;
end;

procedure setFogAndBackgroundForSpace;
begin
  ziemia.jestkoltla[0] := 0;
  ziemia.jestkoltla[1] := 0;
  ziemia.jestkoltla[2] := 0;
  ziemia.jestkoltla[3] := 1;
  glFogfv(GL_FOG_COLOR, @ziemia.jestkoltla);
  glClearColor(ziemia.jestkoltla[0], ziemia.jestkoltla[1], ziemia.jestkoltla[2], ziemia.jestkoltla[3]);
  glFogi(GL_FOG_MODE, GL_EXP);
  glFogf(GL_FOG_DENSITY, 0.0005);
end;

// ---------------------------------------------------------------------------
procedure ruch_intro;
var
  a, b: integer;
begin
{$IFDEF DEBUG_AUTO_START}
  intro.scena := 3;
{$ENDIF}

  { inc(intro.czas);

    ustaw_kolor_tla;

    if intro.czas>=200 then begin
    gra.etap:=1;
    frmMain.TimerCzas.Enabled:=true;
    end; }

  if intro.czas = 0 then
  begin
    matka.widac := 1;
    matka.otwarcie_drzwi := 0;
    ziemia.widac := 0;
    // Sfx.graj_dzwiek(10,0,0,0,false);
    Sfx.muzyke_wlacz(2, false);
  end;

  inc(intro.czas);

  inc(intro.czas2);

  if (intro.czas = 300) or (intro.czas = 1500) then
  begin
    inc(intro.scena);
    intro.czas2 := 0;
  end;

  case intro.scena of
    0:
      begin
        if intro.czas2 = 0 then
        begin
          SmokesClear;
          for a := 0 to high(iskry) do
            iskry[a].jest := false;
          matka.x := 0;
          matka.y := 0;
          matka.z := 0;
        end;
        matka.x := matka.x - 6;
      end;
    1:
      begin
        if intro.czas2 = 0 then
        begin
          matka.x := gracz.x;
          // gracz sie nie ruszyl, mozna matke postawic tam, gdzie on byl [czyli nad ziemia]
          matka.z := gracz.z;
          gracz.y := matka.y - 10;
        end;
        if gracz.y < matka.y + 5 then
        begin
          gracz.y := gracz.y + 0.1;
          if gracz.y > matka.y + 5 then
            gracz.y := matka.y + 5;

        end;
        ustaw_kolor_tla;

        if (gracz.y >= matka.y + 2.4) then
        begin
          if matka.otwarcie_drzwi < 1 then
          begin
            matka.otwarcie_drzwi := matka.otwarcie_drzwi + 0.01;
            if matka.otwarcie_drzwi > 1 then
              matka.otwarcie_drzwi := 1;
          end;
        end;

      end;
  end;

  setFogAndBackgroundForSpace;

  if (frmMain.PwrInp.KeyPressed[DIK_space]) and (intro.scena < 2) and (intro.czas >= 20) then
    intro.scena := 2;

  if intro.scena >= 2 then
  begin
    gra.etap := 1;

    gra.kamera[0, 0] := matka.x - 650;
    // gracz.x-sin((gracz.kier-gracz.szybkier*2)*pi180)*30;
    gra.kamera[0, 1] := matka.y + 3; // gracz.y+30;
    gra.kamera[0, 2] := matka.z;
    // gracz.z+cos((gracz.kier-gracz.szybkier*2)*pi180)*30;
    gra.kamera[1, 0] := gracz.x;
    gra.kamera[1, 1] := gracz.y;
    gra.kamera[1, 2] := gracz.z;
    gra.kamera[2, 0] := 0;
    gra.kamera[2, 1] := 1;
    gra.kamera[2, 2] := 0;

    for a := 0 to 2 do
      for b := 0 to 2 do
        gra.jestkamera[a, b] := gra.kamera[a, b];

    matka.x := gracz.x;
    matka.z := gracz.z;
    gracz.y := matka.y + 5;

    // Sfx.stop_dzwiek(10);
    Sfx.muzyke_wylacz;

    frmMain.TimerCzas.Enabled := true;
    Sfx.muzyke_wlacz(0, true);
    FSOUND_SetPaused(muzchannel, false);
    FSOUND_Stream_SetTime(muzstream, 0);

    {$IFDEF DEBUG_AUTO_START}
      cheaty.full := true;
      cheaty.god := true;
      cheaty.weapon := true;
      gracz.y := matka.y - 200;
      kamera := 4;
    {$ENDIF}

  end;

end;

// ---------------------------------------------------------------------------
procedure ruch_outro;
var
  a: integer;
begin
  if intro.czas = 0 then
  begin
    matka.widac := 1;
    ziemia.widac := 0;
    SmokesClear;
    for a := 0 to high(iskry) do
      iskry[a].jest := false;
    for a := 0 to high(smiec) do
      smiec[a].jest := false;
    zatrzymaj_dzwieki_ciagle;
    for a := 0 to high(rakieta) do
    begin
      { if rakieta[a].dzw_slychac then begin
        FSOUND_StopSound(rakieta[a].dzw_kanal);
        rakieta[a].dzw_slychac:=false;
        end; }
      rakieta[a].jest := false;
    end;
    for a := 0 to high(mysliwiec) do
    begin
      { if mysliwiec[a].dzw_slychac then begin
        FSOUND_StopSound(mysliwiec[a].dzw_kanal);
        mysliwiec[a].dzw_slychac:=false;
        end; }
      mysliwiec[a].jest := false;
    end;
    if gra.misjawypelniona then // Sfx.graj_dzwiek(11,0,0,0,false)
      Sfx.muzyke_wlacz(4, false)
    else // Sfx.graj_dzwiek(12,0,0,0,false);
      Sfx.muzyke_wlacz(3, false);
  end;

  inc(intro.czas);

  inc(intro.czas2);

  if (intro.czas = 400) or (intro.czas = 600) or (intro.czas = 1730) then
  begin
    inc(intro.scena);
    intro.czas2 := 0;
  end;

  setFogAndBackgroundForSpace;

  case intro.scena of
    0:
      begin
        ustaw_kolor_tla;
        matka.x := matka.x - intro.czas2 / 50;
      end;
    1:
      begin
        if intro.czas2 = 0 then
        begin
          SmokesClear;
          for a := 0 to high(iskry) do
            iskry[a].jest := false;
          matka.x := 0;
        end;
        matka.x := matka.x - intro.czas2 / 4;
        // matka.y:=matka.y+8;
      end;
    2:
      begin
        if intro.czas2 = 0 then
        begin
          SmokesClear;
          for a := 0 to high(iskry) do
            iskry[a].jest := false;
          matka.x := 0;
          matka.y := 0;
          matka.z := 0;
        end;
        matka.x := matka.x - 4;

        if gra.rodzajmisji = 0 then
        begin
          /// ********************
          if (intro.czas2 <= 580) then
          begin
            nowy_dym(900, -70, -50, (random - 0.5) * (1 + intro.czas2 / 400), (random - 0.5) * 1, (random - 0.5) * 1,
              -40 + random * 100 + intro.czas2 * 2 + (0.5 + random * 1.4) * abs(sin(intro.czas2 / (6 + intro.czas2 / 14)
              ) * 340), 0, 0.001 + random / 50);

            if (intro.czas2 > 100) and (random(20) = 0) then
              nowy_dym(900, -70, -50, (random - 0.5) * 11, (random - 0.5) * 11, (random - 0.5) * 11, 30, 2, 0.003);
          end;
        end;
      end;
  end;

  if (frmMain.PwrInp.KeyPressed[DIK_space]) and (intro.scena < 3) and (intro.czas >= 20) then
    intro.scena := 3;

  if intro.scena >= 3 then
  begin
    { if gra.misjawypelniona then Sfx.stop_dzwiek(11)
      else Sfx.stop_dzwiek(12); }
    Sfx.muzyke_wylacz;
    matka.x := 0;
    matka.y := 0;
    matka.z := 0;
    if gra.misjawypelniona and (gra.zycia >= 1) then
    begin
      // wejdz do zapisu po wygranej
      winieta.jest := true;
      Sfx.muzyke_wlacz(1, true);
      winieta.corobi := 1;
    end
    else
    begin
      // wejdz do zapisu po przegranej i wznow niewypelniona misje
      winieta.jest := true;
      Sfx.muzyke_wlacz(1, true);
      winieta.corobi := 1;
      dec(gra.planeta);
      if gra.jakiemisje = 2 then
        dec(winieta.epizodmisja);
    end;
  end;
end;

// ---------------------------------------------------------------------------
procedure obsluga_winiety;
begin
{$IFDEF DEBUG_AUTO_START}
  winieta.kursor := 1;
  winieta.planetapocz := 20;
  winieta.poziomtrudnosci := 20;
  winieta.jest := false;
  Config.SandboxSettings.mapSize := 0;
  Config.SandboxSettings.terrainHeight := 3;
  Config.SandboxSettings.difficultyLevel := 5;
  Config.SandboxSettings.windStrength := 0;
  Config.SandboxSettings.gravity := 2;
  Config.SandboxSettings.airDensity := 1;
  Config.SandboxSettings.fightersCount := 0;
  Config.SandboxSettings.landfieldsCount := 1;
  Config.SandboxSettings.survivorsCount := 3;
  Config.SandboxSettings.turretsCount := 0;
  Sfx.muzyke_wylacz;
  nowa_gra(-1, 3);
{$ENDIF}

  case winieta.corobi of
    0:
      begin // winieta
        inc(winieta.skrol);
        if winieta.skrol >= length(titleScrollLines) * 15 * 3 + 930 {2550} then
          winieta.skrol := 0;

        if frmMain.PwrInp.KeyPressed[DIK_DOWN] then
        begin
          inc(winieta.kursor);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if frmMain.PwrInp.KeyPressed[DIK_UP] then
        begin
          dec(winieta.kursor);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if winieta.kursor < 0 then
          winieta.kursor := 6;
        if winieta.kursor > 6 then
          winieta.kursor := 0;

        case winieta.kursor of
          0:
            begin
              if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
              begin
                winieta.jest := false;
                Sfx.muzyke_wylacz;
                nowa_gra(-1, 0);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
              begin
                inc(winieta.planetapocz);
                if winieta.planetapocz > MAIN_SCENARIO_MAX_LEVELS then
                  winieta.planetapocz := 1;
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
              begin
                dec(winieta.planetapocz);
                if winieta.planetapocz < 1 then
                  winieta.planetapocz := MAIN_SCENARIO_MAX_LEVELS;
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGDN] then
              begin
                inc(winieta.planetapocz, 10);
                if winieta.planetapocz > MAIN_SCENARIO_MAX_LEVELS then
                  dec(winieta.planetapocz, MAIN_SCENARIO_MAX_LEVELS);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGUP] then
              begin
                dec(winieta.planetapocz, 10);
                if winieta.planetapocz < 1 then
                  inc(winieta.planetapocz, MAIN_SCENARIO_MAX_LEVELS);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
            end;
          1:
            begin
              if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
              begin
                winieta.jest := false;
                Sfx.muzyke_wylacz;
                nowa_gra(-1, 1);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
              begin
                inc(winieta.poziomtrudnosci);
                if winieta.poziomtrudnosci > RANDOM_GAME_MAX_LEVELS then
                  winieta.poziomtrudnosci := 1;
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
              begin
                dec(winieta.poziomtrudnosci);
                if winieta.poziomtrudnosci < 1 then
                  winieta.poziomtrudnosci := RANDOM_GAME_MAX_LEVELS;
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGDN] then
              begin
                inc(winieta.poziomtrudnosci, 10);
                if winieta.poziomtrudnosci > RANDOM_GAME_MAX_LEVELS then
                  dec(winieta.poziomtrudnosci, RANDOM_GAME_MAX_LEVELS);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGUP] then
              begin
                dec(winieta.poziomtrudnosci, 10);
                if winieta.poziomtrudnosci < 1 then
                  inc(winieta.poziomtrudnosci, RANDOM_GAME_MAX_LEVELS);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
            end;
          2:
            begin
              if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
              begin
                winieta.corobi := 5;
                winieta.kursor := 10;
              end;
            end;
          3:
            if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
            begin
              winieta.corobi := 4;
              winieta.kursor := 0;
            end;
          4:
            if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
            begin
              winieta.corobi := 3;
              winieta.kursor := 0;
            end;
          5:
            if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
            begin
              winieta.corobi := 6;
              winieta.kursor := 0;
            end;
          6:
            if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
            begin
              frmMain.close;
            end;
        end;
      end;
    1, 3:
      begin // zapis, odczyt
        if frmMain.PwrInp.KeyPressed[DIK_DOWN] then
        begin
          inc(winieta.kursor);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if frmMain.PwrInp.KeyPressed[DIK_UP] then
        begin
          dec(winieta.kursor);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if winieta.kursor < 0 then
          winieta.kursor := 10;
        if winieta.kursor > 10 then
          winieta.kursor := 0;

        case winieta.kursor of
          0 .. 9:
            begin
              if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
              begin
                if winieta.corobi = 1 then
                  zapiszgre(winieta.kursor)
                else
                begin
                  if zapisy[winieta.kursor].jest then
                  begin
                    winieta.jest := false;
                    Sfx.muzyke_wylacz;
                    nowa_gra(winieta.kursor, 0);
                  end;
                end;
              end;
            end;
        end;

        if frmMain.PwrInp.KeyPressed[DIK_ESCAPE] or (
            (frmMain.PwrInp.KeyPressed[DIK_space] or frmMain.PwrInp.KeyPressed[DIK_RETURN]) and (winieta.kursor = 10)
        ) then
        begin
          winieta.kursor := 4;
          if winieta.corobi = 1 then
            winieta.corobi := 2
          else
          begin
            winieta.corobi := 0;
            winieta.skrol := 0;
          end;
        end;

      end;
    2:
      begin // sklep
        if frmMain.PwrInp.KeyPressed[DIK_DOWN] then
        begin
          inc(winieta.kursor);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if frmMain.PwrInp.KeyPressed[DIK_UP] then
        begin
          dec(winieta.kursor);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if winieta.kursor < 0 then
          winieta.kursor := 7;
        if winieta.kursor > 7 then
          winieta.kursor := 0;

        case winieta.kursor of
          0 .. 5:
            begin
              if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
              begin
                if (gra.poziomupgrade[winieta.kursor] < 9) and
                  (gra.kasa >= upgrade[winieta.kursor, gra.poziomupgrade[winieta.kursor] + 1].cena) then
                begin
                  dec(gra.kasa, upgrade[winieta.kursor, gra.poziomupgrade[winieta.kursor] + 1].cena);
                  inc(gra.poziomupgrade[winieta.kursor]);
                end;
              end;
            end;
          6:
            begin
              if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
              begin
                if (gra.zycia < 9) and (gra.kasa >= cenazycia) then
                begin
                  dec(gra.kasa, cenazycia);
                  inc(gra.zycia);
                end;
              end;
            end;
        end;

        if frmMain.PwrInp.KeyPressed[DIK_ESCAPE] or (
            (frmMain.PwrInp.KeyPressed[DIK_space] or frmMain.PwrInp.KeyPressed[DIK_RETURN]) and (winieta.kursor = 7)
        ) then
        begin
          if gra.jakiemisje <> 2 then
          begin
            winieta.jest := false;
            Sfx.muzyke_wylacz;
            winieta.kursor := 0;
            nowy_teren;
          end
          else
          begin
            if winieta.epizodmisja > high(epizody[winieta.epizod].misje) then
              winieta.corobi := 4
            else
            begin
              winieta.jest := false;
              Sfx.muzyke_wylacz;
              winieta.kursor := 0;
              nowy_teren(epizody[winieta.epizod].misje[winieta.epizodmisja]);
            end;
          end;
        end;

      end;
    4:
      begin // wybor epizodu
        if frmMain.PwrInp.KeyPressed[DIK_DOWN] then
        begin
          inc(winieta.epizod);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if frmMain.PwrInp.KeyPressed[DIK_UP] then
        begin
          dec(winieta.epizod);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if winieta.epizod < 0 then
          winieta.epizod := high(epizody);
        if winieta.epizod > high(epizody) then
          winieta.epizod := 0;

        if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) and (length(epizody) >= 1) then
        begin
          winieta.jest := false;
          Sfx.muzyke_wylacz;
          if not gra.koniecgry then
          begin
            winieta.jest := false;
            Sfx.muzyke_wylacz;
            winieta.kursor := 0;
            winieta.epizodmisja := 0;
            nowy_teren(epizody[winieta.epizod].misje[0]);
          end
          else
            nowa_gra(-1, 2)
        end;

        if gra.koniecgry and frmMain.PwrInp.KeyPressed[DIK_ESCAPE] then
        begin
          winieta.corobi := 0;
          winieta.skrol := 0;
          winieta.kursor := 3;
        end;

      end;

    5:
      begin // sandbox menu
        if frmMain.PwrInp.KeyPressed[DIK_DOWN] then
        begin
          inc(winieta.kursor);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if frmMain.PwrInp.KeyPressed[DIK_UP] then
        begin
          dec(winieta.kursor);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if winieta.kursor < 0 then
          winieta.kursor := 11;
        if winieta.kursor > 11 then
          winieta.kursor := 0;

        case winieta.kursor of

          0:
          begin
            if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
            begin
              inc(Config.SandboxSettings.difficultyLevel);
              if Config.SandboxSettings.difficultyLevel > RANDOM_GAME_MAX_LEVELS then
                Config.SandboxSettings.difficultyLevel := 1;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
            begin
              dec(Config.SandboxSettings.difficultyLevel);
              if Config.SandboxSettings.difficultyLevel < 1 then
                Config.SandboxSettings.difficultyLevel := RANDOM_GAME_MAX_LEVELS;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_PGDN] then
            begin
              inc(Config.SandboxSettings.difficultyLevel, 10);
              if Config.SandboxSettings.difficultyLevel > RANDOM_GAME_MAX_LEVELS then
                dec(Config.SandboxSettings.difficultyLevel, RANDOM_GAME_MAX_LEVELS);
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_PGUP] then
            begin
              dec(Config.SandboxSettings.difficultyLevel, 10);
              if Config.SandboxSettings.difficultyLevel < 1 then
                inc(Config.SandboxSettings.difficultyLevel, RANDOM_GAME_MAX_LEVELS);
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
          end;

          1:
          begin
            if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
            begin
              inc(Config.SandboxSettings.mapSize);
              if Config.SandboxSettings.mapSize > 3 then
                Config.SandboxSettings.mapSize := 0;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
            begin
              dec(Config.SandboxSettings.mapSize);
              if Config.SandboxSettings.mapSize < 0 then
                Config.SandboxSettings.mapSize := 3;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
          end;

          2:
          begin
            if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
            begin
              inc(Config.SandboxSettings.terrainHeight);
              if Config.SandboxSettings.terrainHeight > 4 then
                Config.SandboxSettings.terrainHeight := 0;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
            begin
              dec(Config.SandboxSettings.terrainHeight);
              if Config.SandboxSettings.terrainHeight < 0 then
                Config.SandboxSettings.terrainHeight := 4;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
          end;

          3:
          begin
            if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
            begin
              inc(Config.SandboxSettings.windStrength);
              if Config.SandboxSettings.windStrength > 3 then
                Config.SandboxSettings.windStrength := 0;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
            begin
              dec(Config.SandboxSettings.windStrength);
              if Config.SandboxSettings.windStrength < 0 then
                Config.SandboxSettings.windStrength := 3;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
          end;

          4:
          begin
            if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
            begin
              inc(Config.SandboxSettings.gravity);
              if Config.SandboxSettings.gravity > 3 then
                Config.SandboxSettings.gravity := 0;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
            begin
              dec(Config.SandboxSettings.gravity);
              if Config.SandboxSettings.gravity < 0 then
                Config.SandboxSettings.gravity := 3;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
          end;

          5:
          begin
            if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
            begin
              inc(Config.SandboxSettings.airDensity);
              if Config.SandboxSettings.airDensity > 3 then
                Config.SandboxSettings.airDensity := 0;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
            begin
              dec(Config.SandboxSettings.airDensity);
              if Config.SandboxSettings.airDensity < 0 then
                Config.SandboxSettings.airDensity := 3;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
          end;

          6:
          begin
            if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
            begin
              inc(Config.SandboxSettings.landfieldsCount);
              if Config.SandboxSettings.landfieldsCount > 3 then
                Config.SandboxSettings.landfieldsCount := 0;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
            begin
              dec(Config.SandboxSettings.landfieldsCount);
              if Config.SandboxSettings.landfieldsCount < 0 then
                Config.SandboxSettings.landfieldsCount := 3;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
          end;

          7:
          begin
            if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
            begin
              inc(Config.SandboxSettings.survivorsCount);
              if Config.SandboxSettings.survivorsCount > 3 then
                Config.SandboxSettings.survivorsCount := 0;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
            begin
              dec(Config.SandboxSettings.survivorsCount);
              if Config.SandboxSettings.survivorsCount < 0 then
                Config.SandboxSettings.survivorsCount := 3;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
          end;

          8:
          begin
            if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
            begin
              inc(Config.SandboxSettings.turretsCount);
              if Config.SandboxSettings.turretsCount > 3 then
                Config.SandboxSettings.turretsCount := 0;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
            begin
              dec(Config.SandboxSettings.turretsCount);
              if Config.SandboxSettings.turretsCount < 0 then
                Config.SandboxSettings.turretsCount := 3;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
          end;

          9:
          begin
            if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
            begin
              inc(Config.SandboxSettings.fightersCount);
              if Config.SandboxSettings.fightersCount > 3 then
                Config.SandboxSettings.fightersCount := 0;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
            if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
            begin
              dec(Config.SandboxSettings.fightersCount);
              if Config.SandboxSettings.fightersCount < 0 then
                Config.SandboxSettings.fightersCount := 3;
              Sfx.graj_dzwiek(16, 0, 0, 0, false);
            end;
          end;

          10:
          begin
            if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
            begin
              winieta.jest := false;
              Sfx.muzyke_wylacz;
              nowa_gra(-1, 3);
            end;
          end;

        end;

        if frmMain.PwrInp.KeyPressed[DIK_ESCAPE] or (
            (frmMain.PwrInp.KeyPressed[DIK_space] or frmMain.PwrInp.KeyPressed[DIK_RETURN]) and (winieta.kursor = 11)
        ) then
        begin
          winieta.corobi := 0;
          winieta.skrol := 0;
          winieta.kursor := 2;
        end;

      end;


    6:
      begin // settings
        if frmMain.PwrInp.KeyPressed[DIK_DOWN] then
        begin
          inc(winieta.kursor);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if frmMain.PwrInp.KeyPressed[DIK_UP] then
        begin
          dec(winieta.kursor);
          Sfx.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if winieta.kursor < 0 then
          winieta.kursor := 2;
        if winieta.kursor > 2 then
          winieta.kursor := 0;

        case winieta.kursor of
          0:
            begin
              if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
              begin
                inc(Config.Sound.SoundVolume, 10);
                if Config.Sound.SoundVolume > 255 then
                  Config.Sound.SoundVolume := 255;
                FSOUND_SetSFXMasterVolume(Config.Sound.SoundVolume);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
              begin
                dec(Config.Sound.SoundVolume, 10);
                if Config.Sound.SoundVolume < 0 then
                  Config.Sound.SoundVolume := 0;
                FSOUND_SetSFXMasterVolume(Config.Sound.SoundVolume);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGDN] then
              begin
                inc(Config.Sound.SoundVolume, 100);
                if Config.Sound.SoundVolume > 255 then
                  Config.Sound.SoundVolume := 255;
                FSOUND_SetSFXMasterVolume(Config.Sound.SoundVolume);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGUP] then
              begin
                dec(Config.Sound.SoundVolume, 100);
                if Config.Sound.SoundVolume < 0 then
                  Config.Sound.SoundVolume := 0;
                FSOUND_SetSFXMasterVolume(Config.Sound.SoundVolume);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
            end;
          1:
            begin
              if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
              begin
                inc(Config.Sound.MusicVolume, 10);
                if Config.Sound.MusicVolume > 255 then
                  Config.Sound.MusicVolume := 255;
                FSOUND_SetVolumeAbsolute(muzchannel, Config.Sound.MusicVolume);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
              begin
                dec(Config.Sound.MusicVolume, 10);
                if Config.Sound.MusicVolume < 0 then
                  Config.Sound.MusicVolume := 0;
                FSOUND_SetVolumeAbsolute(muzchannel, Config.Sound.MusicVolume);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGDN] then
              begin
                inc(Config.Sound.MusicVolume, 100);
                if Config.Sound.MusicVolume > 255 then
                  Config.Sound.MusicVolume := 255;
                FSOUND_SetVolumeAbsolute(muzchannel, Config.Sound.MusicVolume);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGUP] then
              begin
                dec(Config.Sound.MusicVolume, 100);
                if Config.Sound.MusicVolume < 0 then
                  Config.Sound.MusicVolume := 0;
                FSOUND_SetVolumeAbsolute(muzchannel, Config.Sound.MusicVolume);
                Sfx.graj_dzwiek(16, 0, 0, 0, false);
              end;
            end;
        end;

        if frmMain.PwrInp.KeyPressed[DIK_ESCAPE] or (
            (frmMain.PwrInp.KeyPressed[DIK_space] or frmMain.PwrInp.KeyPressed[DIK_RETURN]) and (winieta.kursor = 2)
        ) then
        begin
          if gra.koniecgry then
          begin
            winieta.corobi := 0;
            winieta.skrol := 0;
            winieta.kursor := 5;
          end
          else
          begin
            winieta.jest := false;
          end;
        end;

      end;

  end;

end;

// ---------------------------------------------------------------------------
procedure ruch_glowneintro;
var
  a, b: integer;
begin
{$IFDEF DEBUG_AUTO_START}
  glowneintro.scena := 6;
  glowneintro.czas := 1600;
{$ENDIF}

  if glowneintro.czas = 0 then
  begin
    // Sfx.graj_dzwiek(10,0,0,0,false);
  end;

  inc(glowneintro.czas);
  inc(glowneintro.czas2);

  if (glowneintro.czas = 200) or (glowneintro.czas = 500) or (glowneintro.czas = 800) or (glowneintro.czas = 1100) or
    (glowneintro.czas = 1400) or (glowneintro.czas >= 1600) // koniec
  then
  begin
    inc(glowneintro.scena);
    glowneintro.czas2 := 0;
    if glowneintro.scena >= 6 then
      glowneintro.jest := false;
  end;

  if ((frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) or
    (frmMain.PwrInp.KeyPressed[DIK_ESCAPE])) and (glowneintro.czas >= 5) then
    glowneintro.jest := false;

  gra.kamera[0, 0] := 0;
  gra.kamera[0, 1] := 0;
  gra.kamera[0, 2] := 0;
  gra.kamera[1, 0] := 0;
  gra.kamera[1, 1] := 0;
  gra.kamera[1, 2] := -50;
  gra.kamera[2, 0] := 0;
  gra.kamera[2, 1] := 1;
  gra.kamera[2, 2] := 0;

end;

// ---------------------------------------------------------------------------
procedure FrameMath;
begin
  frmMain.PwrInp.Update;

{$IFDEF DEBUG_AUTO_START}
{  if frmMain.PwrInp.KeyPressed[DIK_I] then
    headTransY := headTransY + 0.05;
  if frmMain.PwrInp.KeyPressed[DIK_K] then
    headTransY := headTransY - 0.05;
  if frmMain.PwrInp.KeyPressed[DIK_J] then
    headTransZ := headTransZ - 0.05;
  if frmMain.PwrInp.KeyPressed[DIK_L] then
    headTransZ := headTransZ + 0.05;}
{$ENDIF}

  if not glowneintro.jest then
  begin
    inc(licz);
    if not winieta.jest then
    begin
      case gra.etap of
        0:
          begin // intro
            ruch_dymow;
            ruch_matki;
            ruch_intro;
          end;
        1:
          begin // gra
            if not gra.pauza then
            begin
              if frmMain.PwrInp.KeyPressed[DIK_ESCAPE] then
              begin
                frmMain.TimerCzas.Enabled := false;
                gra.pauza := true;
              end;
              ruch_w_czasie_gry;
              ruch_swiatel;
              ruch_gracza;
              UpdateSurvivors;
              ruch_dzialek;
              ruch_dymow;
              ruch_iskier;
              ruch_smieci;
              ruch_rakiet;
              ruch_mysliwcow;
              ruch_matki;
              ruch_ladowisk;
              if frmMain.PwrInp.KeyPressed[DIK_ESCAPE] then
              begin
                zatrzymaj_dzwieki_ciagle;
              end;
              if winieta.jest then
                zatrzymaj_dzwieki_ciagle;
            end
            else
            begin
              if (frmMain.PwrInp.KeyPressed[DIK_ESCAPE]) then
              begin
                frmMain.TimerCzas.Enabled := true;
                gra.pauza := false;
              end;
              if (frmMain.PwrInp.KeyPressed[DIK_Q]) then
              begin
                zatrzymaj_dzwieki_ciagle;
                gra.koniecgry := true;
                gracz.sila := 0;
                gracz.zyje := false;
                gra.pauza := false;
                frmMain.TimerCzas.Enabled := false;
                winieta.jest := true;
                Sfx.muzyke_wlacz(1, true);
                if gra.sandboxMode then
                  winieta.corobi := 5
                else
                  winieta.corobi := 0;
                winieta.skrol := 0;
              end;
              if (frmMain.PwrInp.KeyPressed[DIK_S]) then
              begin
                winieta.jest := true;
                winieta.corobi := 6;
                winieta.kursor := 0;
              end;
            end;
          end;
        2:
          begin // outro
            ruch_dymow;
            ruch_matki;
            ruch_outro;
          end;
      end;

    end
    else
    begin
      obsluga_winiety;
    end;
  end
  else
  begin

    ruch_glowneintro;

  end;

  FSOUND_Update();

end;

// ---------------------------------------------------------------------------
procedure ustaw_gracza_namatce;
var
  a: integer;
begin
  gracz.dx := 0;
  gracz.dy := 0;
  gracz.dz := 0;
  gracz.kier := 90;
  gracz.szybkier := 0;
  gracz.wykrecsila := 0;
  gracz.maxsila := upgrade[3, gra.poziomupgrade[3]].ile; // 1
  gracz.sila := gracz.maxsila;
  gracz.maxpaliwa := upgrade[0, gra.poziomupgrade[0]].ile; // 200;
  gracz.paliwo := gracz.maxpaliwa;
  gracz.zyje := true;
  gracz.pilotow := 0;
  gracz.temp := 0;
  gracz.x := matka.x;
  gracz.z := matka.z;
  gracz.y := matka.y + 5;
  gracz.maxrakiet := round(upgrade[1, gra.poziomupgrade[1]].ile); // 10;
  gracz.ilerakiet := gracz.maxrakiet;
  gracz.maxdzialko := round(upgrade[2, gra.poziomupgrade[2]].ile); // 10;
  gracz.iledzialko := gracz.maxdzialko;
  gracz.stronastrzalu := 1;
  gracz.chlodz := upgrade[4, gra.poziomupgrade[4]].ile; // 0.5;
  gracz.ladownosc := round(upgrade[5, gra.poziomupgrade[5]].ile);
  gracz.zlywsrodku := false;
  gracz.oslonablysk := 0;
  gracz.alienSteerTime := 0;
  gracz.alienSteerDirection := 0;
  gracz.alienSteerForward := false;
  
  for a := 0 to high(gracz.elementy) do
  begin
    gracz.elementy[a].obrx := 0;
    gracz.elementy[a].obry := 0;
    gracz.elementy[a].obrz := 0;
  end;

  for a := 0 to high(gracz.uszkodzenia) do
    gracz.uszkodzenia[a] := false;
  gracz.randuszkodzenia := random(99999);
  gracz.silaskrzywien := 0;
end;

procedure setDifficultyLevel;
begin
  gra.difficultyLevel := gra.planeta * DIFFICULTY_MULTIPLIER;
end;

procedure wczytaj_teren(nazwa: string; gdzie: byte = 0);
var
  a, b, i, a1: integer;
  f: TStream;
  bt, bt2, br, bg, bb: byte;
  r, r2: real;
  mi, ma: real;
begin
  case gdzie of
    0:
      nazwa := EXTRA_MISSIONS_FOLDER + nazwa + '.map';
    1:
      nazwa := DATA_FOLDER + nazwa + '.dmp';
  end;
  f := nil;
  try
    try
      f := TFileStream.Create(nazwa, fmOpenRead);

      f.readBuffer(ziemia.wx, sizeof(ziemia.wx));
      f.readBuffer(ziemia.wz, sizeof(ziemia.wz));
      f.readBuffer(ziemia.wlk, sizeof(ziemia.wlk));

      ziemia.px := -(ziemia.wx / 2) * ziemia.wlk; // *
      ziemia.pz := -(ziemia.wz / 2) * ziemia.wlk;

      { setlength(ziemia.pk,ziemia.wx);
        for a:=0 to high(ziemia.pk) do
        setlength(ziemia.pk[a],ziemia.wz);

        for b:=0 to ziemia.wz-1 do
        for a:=0 to ziemia.wx-1 do begin
        f.ReadBuffer(ziemia.pk[a,b].p,sizeof(ziemia.pk[a,b].p));
        f.ReadBuffer(ziemia.pk[a,b].rodzaj,sizeof(ziemia.pk[a,b].rodzaj));
        end; }

      // typ misji
      f.readBuffer(bt, sizeof(bt));
      gra.rodzajmisji := bt;

      f.readBuffer(i, sizeof(i));
      case bt of
        0:
          begin
            gra.minimum := i;
            gra.dzialekminimum := 0;
          end;
        1:
          begin
            gra.minimum := 0;
            gra.dzialekminimum := i;
          end;
      end;

      // poziom trudnosci
      f.readBuffer(bt, sizeof(bt));
      f.readBuffer(bt2, sizeof(bt2));
      gra.planeta := bt + random(bt2) - 1;
      gra.difficultyLevel := gra.planeta; //bez mno¿enia po wczytaniu z pliku
      // grawitacja
      f.readBuffer(r, sizeof(r));
      f.readBuffer(r2, sizeof(r2));
      ziemia.grawitacja := r + random * r2;
      // gestosc powietrza
      f.readBuffer(r, sizeof(r));
      f.readBuffer(r2, sizeof(r2));
      ziemia.gestoscpowietrza := r - random * (1 - r2);
      // wiatr
      f.readBuffer(r, sizeof(r));
      f.readBuffer(r2, sizeof(r2));
      wiatr.sila := r + random * r2;
      // max mysliwcow
      f.readBuffer(bt, sizeof(bt));
      f.readBuffer(bt2, sizeof(bt2));
      setlength(mysliwiec, bt + random(bt2));
      // wys matki
      f.readBuffer(i, sizeof(i));
      matka.y := i;
      // czas
      f.readBuffer(i, sizeof(i));
      gra.czas := i;

      // kolor nieba
      f.readBuffer(br, sizeof(br));
      f.readBuffer(bg, sizeof(bg));
      f.readBuffer(bb, sizeof(bb));
      ziemia.koltla[0] := br / 256;
      ziemia.koltla[1] := bg / 256;
      ziemia.koltla[2] := bb / 256;

      ziemia.showStars := (ziemia.koltla[0] <= 0.1) and (ziemia.koltla[1] <= 0.1) and (ziemia.koltla[2] <= 0.1);
      ziemia.showClouds := not ziemia.showStars;
      ziemia.skyBrightness := 1.5;

      gra.nazwaplanety := wczytajstring(f);
      gra.tekstintro := wczytajstring(f);
      gra.tekstoutrowin := wczytajstring(f);
      gra.tekstoutrolost := wczytajstring(f);

      setlength(ziemia.pk, ziemia.wx);
      for a := 0 to high(ziemia.pk) do
        setlength(ziemia.pk[a], ziemia.wz);

      for b := 0 to ziemia.wz - 1 do
        for a := 0 to ziemia.wx - 1 do
        begin
          f.readBuffer(ziemia.pk[a, b].p, sizeof(ziemia.pk[a, b].p));
          f.readBuffer(br, sizeof(br));
          f.readBuffer(bg, sizeof(bg));
          f.readBuffer(bb, sizeof(bb));
          ziemia.pk[a, b].kr := br / 256;
          ziemia.pk[a, b].kg := bg / 256;
          ziemia.pk[a, b].kb := bb / 256;
          ziemia.pk[a, b].rodzaj := 0;
          f.readBuffer(ziemia.pk[a, b].scen, sizeof(ziemia.pk[a, b].scen));
        end;

      f.readBuffer(b, sizeof(b));
      setlength(dzialko, b);
      for a := 0 to high(dzialko) do
      begin
        f.readBuffer(i, sizeof(i));
        dzialko[a].x := i * ziemia.wlk + ziemia.px + ziemia.wlk / 2;
        f.readBuffer(i, sizeof(i));
        dzialko[a].z := i * ziemia.wlk + ziemia.pz + ziemia.wlk / 2;
        f.readBuffer(bt, sizeof(bt));
        dzialko[a].rodzaj := bt;
      end;

      SurvivorList.Clear;
      f.readBuffer(b, sizeof(b));
      setlength(ladowiska, b);
      for a := 0 to high(ladowiska) do
      begin
        f.readBuffer(ladowiska[a].x, sizeof(ladowiska[a].x));
        f.readBuffer(ladowiska[a].z, sizeof(ladowiska[a].z));
        f.readBuffer(ladowiska[a].rx, sizeof(ladowiska[a].rx));
        f.readBuffer(ladowiska[a].rz, sizeof(ladowiska[a].rz));
        f.readBuffer(ladowiska[a].pilotow, sizeof(ladowiska[a].pilotow));
        f.readBuffer(ladowiska[a].dobre, sizeof(ladowiska[a].dobre));

        mi := ziemia.pk[ladowiska[a].x, ladowiska[a].z].p;
        ma := ziemia.pk[ladowiska[a].x, ladowiska[a].z].p;
        for a1 := ladowiska[a].x - ladowiska[a].rx to ladowiska[a].x + ladowiska[a].rx do
          for b := ladowiska[a].z - ladowiska[a].rz to ladowiska[a].z + ladowiska[a].rz do
          begin
            if ziemia.pk[a1, b].p < mi then
              mi := ziemia.pk[a1, b].p;
            if ziemia.pk[a1, b].p > ma then
              ma := ziemia.pk[a1, b].p;
          end;

        for a1 := ladowiska[a].x - ladowiska[a].rx to ladowiska[a].x + ladowiska[a].rx do
          for b := ladowiska[a].z - ladowiska[a].rz to ladowiska[a].z + ladowiska[a].rz do
          begin
            ziemia.pk[a1, b].p := (ma - mi) / 2 + mi;
            ziemia.pk[a1, b].rodzaj := 1;
          end;

        if ladowiska[a].pilotow > 0 then
        begin
//          setlength(pilot, length(pilot) + ladowiska[a].pilotow);
//          for b := high(pilot) downto high(pilot) - ladowiska[a].pilotow + 1 do
//            pilot[b].nalotnisku := a;
          for b := 0 to ladowiska[a].pilotow - 1 do
          begin
            CreateSurvivor(0, 0, 0, false, 1, a);
          end;
        end;
      end;

      // wczytaj muzyke jesli jest

      gra.nazwamp3 := wczytajstring(f);

      f.Free;
      f := nil;
    except
      if f <> nil then
      begin
        f.Free;
        f := nil;
      end;
      MessageBox(frmMain.Handle, pchar(Format(STR_APP_ERROR_OPENING_FILE, [nazwa])), STR_APP_ERROR,
        MB_OK + MB_TASKMODAL + MB_ICONERROR);
    end;
  finally
    if f <> nil then
    begin
      f.Free;
      f := nil;
    end;
    ziemia.TexDiv := 7 / 3;
  end;

end;

// ---------------------------------------------------------------------------
procedure softenTerrain;
var
  a, az, ax: integer;
  ax1, axm1, az1, azm1: integer;
  fromX, toX, fromZ, toZ: integer;
begin
  for a := 1 to random(30) do
  begin
    fromZ := random(ziemia.wz - 1);
    toZ := fromZ + random(ziemia.wz - fromZ);
    fromX := random(ziemia.wx - 1);
    toX := fromX + random(ziemia.wx - fromX);
    for az := fromZ to toZ do
    begin
      for ax := fromX to toX do
      begin
        ax1 := ax + 1;
        axm1 := ax - 1;
        az1 := az + 1;
        azm1 := az - 1;
        if ax1 >= ziemia.wx then
          dec(ax1, ziemia.wx);
        if az1 >= ziemia.wz then
          dec(az1, ziemia.wz);
        if axm1 < 0 then
          inc(axm1, ziemia.wx);
        if azm1 < 0 then
          inc(azm1, ziemia.wz);

        ziemia.pk[ax, az].p := (ziemia.pk[ax, az].p + ziemia.pk[ax1, az].p + ziemia.pk[ax, az1].p + ziemia.pk[axm1,
          az].p + ziemia.pk[ax, azm1].p) / 5
      end;
    end;
  end;

end;

procedure DrawCircle(centerX, centerZ, radius, height: integer);
var
  x, z, fx, fz: integer;
  w: extended;
begin
  for fz := centerZ - radius to centerZ + radius do
    for fx := centerX - radius to centerX + radius do
    begin
      x := fx mod ziemia.wx;
      if x < 0 then
        x := ziemia.wx - 1 + x;
      z := fz mod ziemia.wz;
      if z < 0 then
        z := ziemia.wz - 1 + z;

      if (x >= 0) and (z >= 0) and (x < ziemia.wx) and (z < ziemia.wz) then
      begin
        if (fx - centerX = 0) and (fz - centerZ = 0) then
          w := ((radius + 1) - sqrt2(sqr(1) + sqr(0))) / radius
        else
          w := ((radius + 1) - sqrt2(sqr(fx - centerX) + sqr(fz - centerZ))) / radius;

        if w < 0 then
          w := 0;

        ziemia.pk[x, z].p := ziemia.pk[x, z].p + height * w;

      end;
    end;
end;

// ---------------------------------------------------------------------------
procedure MakeCraters;
var
  a, centerx, centerz, radius, height: integer;
begin
  for a := 0 to 1 + random(50) do
  begin
    centerx := random(high(ziemia.pk) * 2);
    centerz := random(high(ziemia.pk[0]) * 2 - centerx) + centerx;

    radius := 5 + random(40);
    height := 50 + random(300);

    DrawCircle(centerx, centerz, radius, height);
    DrawCircle(centerx, centerz, radius - 5 - random(10), -round(height * (1 + random)) );
  end;

end;

procedure GetMinMaxGroundHeight(out minHeight: extended; out maxHeight: extended);
var
  a, b: integer;
begin
  minHeight := ziemia.pk[0, 0].p;
  maxHeight := ziemia.pk[0, 0].p;
  for a := 0 to high(ziemia.pk) do
    for b := 0 to high(ziemia.pk[a]) do
    begin
      if ziemia.pk[a, b].p > maxHeight then
        maxHeight := ziemia.pk[a, b].p;
      if ziemia.pk[a, b].p < minHeight then
        minHeight := ziemia.pk[a, b].p;
    end;
end;

procedure generuj_losowy;
var
  a, b, n, az, ax, bx, bz: integer;
  vek1, vek2, vek3: TWektor;
  mi, ma: real;
  rozwys, rozwys2, r: real;
  kolory: array [0 .. 5, 0 .. 2] of real;
  { 0..5 to wysokosci, gdzie jest dany kolor }
  ax1, axm1, az1, azm1: integer;
  ok: boolean;

  dsz, sz, dtz, tz, sw,
  k1: real;
  c, _s, _t: integer;
  najwyzszy, najnizszy, koldziel: extended;
  rodzaj_gor: integer;
  minHeight, maxHeight: integer;

begin
  ziemia.TexDiv := 7 / 3;
  setDifficultyLevel;
  gra.rodzajmisji := gra.planeta mod 3;

  if not gra.sandboxMode then
  begin
    if gra.planeta <= 9 then
    begin
      ziemia.wx := 119 + random(4) * 7;
      ziemia.wz := ziemia.wx;
      ziemia.wlk := 30 + random(5);
    end
    else
    begin
      ziemia.wx := 147 + random(10) * 7;
      ziemia.wz := ziemia.wx;
      ziemia.wlk := 30 + random(25);
    end;
  end
  else
  begin
    ziemia.wx := 105 + (Config.SandboxSettings.mapSize * 7) * 10;
    ziemia.wz := ziemia.wx;
    ziemia.wlk := 30 + Config.SandboxSettings.mapSize;
  end;

  ziemia.px := -(ziemia.wx / 2) * ziemia.wlk; // *
  ziemia.pz := -(ziemia.wz / 2) * ziemia.wlk;

  if gra.jakiemisje = 0 then
    RandSeed := gra.planeta + 9000
  else
    randomize;

  rodzaj_gor := 1;//random(2); nie ma ju¿ innego algorytmu ni¿ 1

  if not gra.sandboxMode then
  begin
    a := round(20 + (random * 2 - 0.6) * ((10 + gra.planeta) / 4.5)); // 18.53 .. 30.88
    ziemia.grawitacja := a / 10000;

    a := round(20 + (random * 1.7 - 0.6) * ((10 + gra.planeta) / 4.5)); // 18.53 .. 28.55
    ziemia.gestoscpowietrza := (1000 - a) / 1000;

    wiatr.sila := 0.001 + (random / 1000) * 3; // 0 .. 0.004
  end
  else
  begin
    a := round(6 + Config.SandboxSettings.gravity * 8 + random * 3);
    ziemia.grawitacja := a / 10000;

    a := round(12 + Config.SandboxSettings.airDensity * 5 + random * 3);
    ziemia.gestoscpowietrza := (1000 - a) / 1000;

    if Config.SandboxSettings.windStrength = 0 then
      wiatr.sila := 0
    else
      wiatr.sila := Config.SandboxSettings.windStrength * 0.001 + (random / 1000); // 0 .. 0.004
  end;

  matka.y := 900;

  // ustawienie rozmiaru ziemi: przy wczytywaniu jest to w funkcji wczytujacej
  setlength(ziemia.pk, ziemia.wx);
  for a := 0 to high(ziemia.pk) do
    setlength(ziemia.pk[a], ziemia.wz);

  // decyzja jakie beda kolory
 { kolory[0, 0] := random;
  for b := 1 to 2 do
  begin
    kolory[0, b] := KeepValBetween(kolory[0, b - 1] + (random - 0.5) * 0.1, 0.05, 0.7);
  end;

  for a := 1 to 5 do
  begin
    for b := 0 to 2 do
    begin
      kolory[a, b] := KeepValBetween(kolory[a - 1, b] + (random - 0.5) * 0.3, 0.05, 0.7);
    end;
  end;
}

  for a := 0 to 5 do
  begin
    n := random(GROUND_COLORS_MAX + 1);
    k1 := 0.7 + (random * 0.4);
    for b := 0 to 2 do
    begin
      kolory[a, b] := KeepValBetween(groundColors[n][b] * k1, 0.05, 0.7);
    end;
  end;



  // generowanie terenu
  minHeight := 1;
  maxHeight := round(matka.y - 400);
  case rodzaj_gor of
    0:
      begin // gory po staremu (randomowe)
(* stary algorytm usuniêty, by³ s³aby
       rozwys := 10 + random * 50;
        rozwys2 := rozwys / 2;
        minHeight := 1;
        maxHeight := round(matka.y - 200);

        for a := 0 to high(ziemia.pk) do
        begin
          for b := 0 to high(ziemia.pk[a]) do
          begin
            ziemia.pk[a, b].rodzaj := 0;
            if (a = 0) and (b = 0) then
              ziemia.pk[a, b].p := random * 130
            else if b = 0 then
              ziemia.pk[a, b].p := ziemia.pk[a - 1, b].p + random * rozwys - rozwys2
            else if a = 0 then
              ziemia.pk[a, b].p := ziemia.pk[a, b - 1].p + random * rozwys - rozwys2
            else
            begin
              case random(3) of
                0:
                  ziemia.pk[a, b].p := (ziemia.pk[a, b - 1].p + ziemia.pk[a - 1, b].p) / 2 + random * rozwys - rozwys2;
                1:
                  ziemia.pk[a, b].p := ziemia.pk[a, b - 1].p + random * rozwys - rozwys2;
                2:
                  ziemia.pk[a, b].p := ziemia.pk[a - 1, b].p + random * rozwys - rozwys2;
              end;
            end;

            ziemia.pk[a, b].p := KeepValBetween(ziemia.pk[a, b].p, minHeight, maxHeight);
          end;
        end;*)
      end;
    1:
      begin // gory skladane z trojkatow
        if not gra.sandboxMode then
        begin
          rozwys := 100 + random * 500;
          maxHeight := round(matka.y - 400);
          minHeight := maxHeight - 700 - random(1500)
        end
        else
        begin
          if Config.SandboxSettings.terrainHeight = 0 then
            rozwys := 10 + random * 50
          else
            rozwys := 100 + random * 500;
          maxHeight := round(matka.y - 400 - (4 - Config.SandboxSettings.terrainHeight) * 80 + random(200) );
          minHeight := maxHeight - 100 - Config.SandboxSettings.terrainHeight * 600;
        end;

        ax := round(minHeight + (maxHeight - minHeight) / 2);
        for a := 0 to high(ziemia.pk) do
          for b := 0 to high(ziemia.pk[a]) do
          begin
            ziemia.pk[a, b].rodzaj := 0;
            ziemia.pk[a, b].p := ax;
          end;

        for a := 0 to 30 + random(135) do
        begin
          ax := random(high(ziemia.pk) * 2) - high(ziemia.pk); // od x
          bx := random(high(ziemia.pk) * 2 - ax) + ax; // do x

          sz := random(high(ziemia.pk[0]));
          tz := random(high(ziemia.pk[0]));
          dsz := random * 10 - 5;
          dtz := random * 10 - 5;

          sw := (random - 0.5) * rozwys;

          for b := ax to bx do
          begin
            if sz <= tz then
            begin
              _s := round(sz);
              _t := round(tz);
            end
            else
            begin
              _s := round(tz);
              _t := round(sz);
            end;

            for c := _s to _t do
            begin
              if (b >= 0) and (b <= high(ziemia.pk)) and (c >= 0) and (c <= high(ziemia.pk[0])) then
                ziemia.pk[b, c].p := KeepValBetween(ziemia.pk[b, c].p + sw, minHeight, maxHeight);
            end;

            sz := sz + dsz;
            tz := tz + dtz;

            dsz := dsz + (random - 0.5) * 0.7;
            dtz := dtz + (random - 0.5) * 0.7;

          end;

        end;

      end;
  end;

  GetMinMaxGroundHeight(najnizszy, najwyzszy);
  koldziel := (najwyzszy - najnizszy) / 5;

  // kolorowanie
  for a := 0 to high(ziemia.pk) do
  begin
    for b := 0 to high(ziemia.pk[a]) do
    begin

      // r:=ziemia.pk[a,b].p/200;
      r := (ziemia.pk[a, b].p - najnizszy) / koldziel;
      if (frac(r) < 0.05) then
        r := r - random * 0.1
      else if (frac(r) > 0.95) then
        r := r + random * 0.1;

      if r < 0 then
        r := 0;
      if r > 5 then
        r := 5;

      k1 := (random - 0.5) * 0.03;
      ziemia.pk[a, b].kr := KeepValBetween(kolory[trunc(r), 0] + k1, 0, 1);
      ziemia.pk[a, b].kg := KeepValBetween(kolory[trunc(r), 1] + k1, 0, 1);
      ziemia.pk[a, b].kb := KeepValBetween(kolory[trunc(r), 2] + k1, 0, 1);

    end;
  end;

  // znieksztalcenie gor
  for a := 1 to random(3) do
    for az := 0 to ziemia.wz - 1 do
      for ax := 0 to ziemia.wx - 1 do
      begin
        ziemia.pk[ax, az].p := KeepValBetween(ziemia.pk[ax, az].p + (random - 0.5) * 20, minHeight, maxHeight);
      end;

  softenTerrain;

  MakeCraters;

  for az := 0 to ziemia.wz - 1 do
    for ax := 0 to ziemia.wx - 1 do
    begin
      ziemia.pk[ax, az].p := KeepValBetween(ziemia.pk[ax, az].p, minHeight, maxHeight);
    end;

  // ladowiska
  if not gra.sandboxMode then //#
    setlength(ladowiska, 1 + random(5))
  else
  begin
    if Config.SandboxSettings.landfieldsCount > 0 then
      setlength(ladowiska, Config.SandboxSettings.landfieldsCount * 5 + random(2))
    else
      setlength(ladowiska, 0)
  end;
  for n := 0 to high(ladowiska) do
  begin
    // rozmiar ladowiska
    ladowiska[n].rx := 1 + random(4);
    ladowiska[n].rz := 1 + random(4);

    // pozycja ladowiska
    ladowiska[n].x := random(ziemia.wx - ladowiska[n].rx * 2) + ladowiska[n].rx;
    ladowiska[n].z := random(ziemia.wz - ladowiska[n].rz * 2) + ladowiska[n].rz;

    // obliczanie sredniej wysokosci:                                      //*
    mi := ziemia.pk[ladowiska[n].x, ladowiska[n].z].p;
    ma := ziemia.pk[ladowiska[n].x, ladowiska[n].z].p;
    for a := ladowiska[n].x - ladowiska[n].rx to ladowiska[n].x + ladowiska[n].rx do
      for b := ladowiska[n].z - ladowiska[n].rz to ladowiska[n].z + ladowiska[n].rz do
      begin
        if ziemia.pk[a, b].p < mi then
          mi := ziemia.pk[a, b].p;
        if ziemia.pk[a, b].p > ma then
          ma := ziemia.pk[a, b].p;
      end;

    for a := ladowiska[n].x - ladowiska[n].rx to ladowiska[n].x + ladowiska[n].rx do
      for b := ladowiska[n].z - ladowiska[n].rz to ladowiska[n].z + ladowiska[n].rz do
      begin
        ziemia.pk[a, b].p := (ma - mi) / 2 + mi;
        ziemia.pk[a, b].kr := 0.8;
        ziemia.pk[a, b].kg := 0.8;
        ziemia.pk[a, b].kb := 0.8;
        ziemia.pk[a, b].rodzaj := 1;
      end;

    ladowiska[n].pilotow := random(4);

    if (gra.rodzajmisji = 0) or gra.sandboxMode then
      ladowiska[n].dobre := (random(3) <= 1) or (n = 0)
    else
      ladowiska[n].dobre := false;
  end;

  // dzialka
  if not gra.sandboxMode then
    a := random(10) + (ord(gra.rodzajmisji = 1) * 3) + gra.difficultyLevel div 2
  else
  begin
    if Config.SandboxSettings.turretsCount = 0 then
      a := 0
    else
      a := 4 + sqr(Config.SandboxSettings.turretsCount) * 13 + random(10); //13 | 52 | 117
  end;
  setlength(dzialko, a);

  for a := 0 to high(dzialko) do
    with dzialko[a] do
    begin
      x := 0;
      z := 0;
      y := 0;
    end;

  for a := 0 to high(dzialko) do
  begin
    with dzialko[a] do
    begin
      rodzaj := random(2);
      repeat
        if (a = 0) or (random(100) >= 30 + gra.difficultyLevel * 0.67) then
        begin
          ax := (2 + random(ziemia.wx - 4));
          az := (2 + random(ziemia.wz - 4));
        end
        else
        begin
          repeat
            ok := false;
            ax := (2 + random(ziemia.wx - 4));
            az := (2 + random(ziemia.wz - 4));
            for b := 0 to high(dzialko) do
            begin
              r := sqrt2(sqr((ax * ziemia.wlk + ziemia.px - ziemia.wlk / 2) - dzialko[b].x) +
                sqr((az * ziemia.wlk + ziemia.pz - ziemia.wlk / 2) - dzialko[b].z));
              if (b <> a) and (r >= ziemia.wlk * 1.5) and (r <= ziemia.wlk * 3) then
                ok := true;
            end;
          until ok;
        end;

        ok := true;
        for bx := ax - 2 to ax + 2 do
          for bz := az - 2 to az + 2 do
          begin
            if ziemia.pk[bx, bz].rodzaj <> 0 then
              ok := false;
          end;

        x := ax * ziemia.wlk + ziemia.px - ziemia.wlk / 2;
        z := az * ziemia.wlk + ziemia.pz - ziemia.wlk / 2;

        if a >= 1 then
          for b := 0 to a - 1 do
            if (dzialko[b].x >= x - ziemia.wlk) and (dzialko[b].x <= x + ziemia.wlk) and
              (dzialko[b].z >= z - ziemia.wlk) and (dzialko[b].z <= z + ziemia.wlk) then
              ok := false;

      until ok;

    end;
  end;

  if not gra.sandboxMode then
  begin
    a := 4 + random(20) + gra.difficultyLevel div 2;
    if a > 50 then
      a := 50;
  end
  else
  begin
    if Config.SandboxSettings.survivorsCount = 0 then
      a := 0
    else
      a := 5 + sqr(Config.SandboxSettings.survivorsCount) * 15 + random(10); //20 | 60 | 135
  end;

  if length(ladowiska) = 0 then
    a := 0;
  SurvivorList.Clear;
  for b := 0 to a - 1 do
    CreateSurvivor(0, 0, 0);

  for a := 0 to SurvivorList.Count - 1 do
    SurvivorList[a].nalotnisku := random(length(ladowiska));

  ziemia.showStars := random(12) = 0;
  ziemia.showClouds := random(12) > 0;

  if not ziemia.showStars then
  begin
    k1 := random * 0.9;
    ziemia.skyBrightness := 1.5 + random * 0.5;
    ziemia.koltla[0] := KeepValBetween(k1 + (random - 0.5) * 0.2, 0, 1);
    ziemia.koltla[1] := KeepValBetween(k1 + (random - 0.5) * 0.2, 0, 1);
    ziemia.koltla[2] := KeepValBetween(k1 + (random - 0.5) * 0.2, 0, 1);
  end
  else
  begin
    ziemia.koltla[0] := 0;
    ziemia.koltla[1] := 0;
    ziemia.koltla[2] := 0;
    ziemia.skyBrightness := 1;
  end;
  gra.czas := (60 * 7) + (gra.difficultyLevel div 5) * 30;
end;

// ---------------------------------------------------------------------------
function losujnazwe: string;
const
  sam: array [0 .. 5] of char = ('A', 'E', 'I', 'O', 'U', 'Y');
var
  s: string;
  d: integer;
  a, r: integer;
begin
  s := '';
  r := random(2); // rodzaj: 0-dowolna nazwa, 1-symbol XXX-numer

  d := 3 + random(7 - ord(r = 1) * 5); // dlugosc nazwy
  for a := 1 to d do
  begin
    if a mod 2 = 0 then
      s := s + sam[random(length(sam))]
    else
      s := s + chr(65 + random(26));
  end;
  if r = 1 then
    s := s + '-' + inttostr(random(99) + 1);

  result := s;
end;


procedure MakeSceneryRegions;
  type
    TIntArray = array of integer;

  function getRandomSceneryArray: TIntArray;
  var
    n: integer;
  begin
    setlength(result, 1 + random(2));
    result[0] := random(ile_obiektow_scenerii);
    if length(result) > 0 then
    begin
      repeat
        result[1] := random(ile_obiektow_scenerii);
      until result[1] <> result[0];
    end;
  end;

  procedure MakeRegion(centerX, centerZ, radius: integer; sceneryArray: TIntArray);
  var
    x, z, fx, fz: integer;
    w: extended;
  begin
    for fz := centerZ - radius to centerZ + radius do
      for fx := centerX - radius to centerX + radius do
      begin
        x := fx mod ziemia.wx;
        if x < 0 then
          x := ziemia.wx - 1 + x;
        z := fz mod ziemia.wz;
        if z < 0 then
          z := ziemia.wz - 1 + z;

        if (x >= 0) and (z >= 0) and (x < ziemia.wx) and (z < ziemia.wz) then
        begin
          if (fx - centerX = 0) and (fz - centerZ = 0) then
            w := ((radius + 1) - sqrt2(sqr(1) + sqr(0))) / radius
          else
            w := ((radius + 1) - sqrt2(sqr(fx - centerX) + sqr(fz - centerZ))) / radius;

          if (w >= 0) and ziemia.pk[x][z].scen then
            ziemia.pk[x][z].scen_rodz := sceneryArray[random(length(sceneryArray))];

        end;
      end;
  end;

var
  n, count, size: integer;
  centerx, centerz: integer;
begin
  count := round(5 + (ziemia.wx * ziemia.wz) / 1000);
  for n := 0 to count do
  begin
    size := round(1 + Max(ziemia.wx, ziemia.wz) * 0.3);
    centerx := random(ziemia.wx);
    centerz := random(ziemia.wz);
    MakeRegion(centerx, centerz, 20 + random(size), getRandomSceneryArray);
  end;

end;

procedure SetSceneryObjects(losowy: boolean);
const
  texladowiska = 0.35;
  texkrzakow = 0;
var
  az, ax: integer;
  col1: real;
begin
  for az := 0 to ziemia.wz - 1 do
  begin
    for ax := 0 to ziemia.wx - 1 do
    begin
      if (ziemia.pk[ax][az].rodzaj = 1) or (ax = 0) or (az = 0) or (ax >= ziemia.wx - 2) or (az >= ziemia.wz - 2) then
      begin

        ziemia.pk[ax][az].scen := false;
        ziemia.pk[ax][az].tex := texladowiska;

      end
      else
      begin
        ziemia.pk[ax][az].tex := ziemia.pk[ax][az].p / 500;

        if losowy then
        begin
          ziemia.pk[ax][az].scen := random(8) = 0;

          if (abs(ziemia.pk[ax][az].p - ziemia.pk[ax + 1][az].p) > 8) or
            (abs(ziemia.pk[ax][az].p - ziemia.pk[ax - 1][az].p) > 8) or
            (abs(ziemia.pk[ax][az].p - ziemia.pk[ax][az + 1].p) > 8) or
            (abs(ziemia.pk[ax][az].p - ziemia.pk[ax][az - 1].p) > 8) then
            ziemia.pk[ax][az].scen := false;
        end;

        if ziemia.pk[ax][az].scen then
        begin
          col1 := (0.5 - random) * 0.4 - 0.2;
          ziemia.pk[ax][az].scen_rodz := random(ile_obiektow_scenerii);
          ziemia.pk[ax][az].sckr := KeepValBetween(ziemia.pk[ax][az].kr + (random - 0.5) * 0.1 + col1, 0.1, 0.7);
          ziemia.pk[ax][az].sckg := KeepValBetween(ziemia.pk[ax][az].kg + (random - 0.5) * 0.1 + col1, 0.1, 0.7);
          ziemia.pk[ax][az].sckb := KeepValBetween(ziemia.pk[ax][az].kb + (random - 0.5) * 0.1 + col1, 0.1, 0.7);
          ziemia.pk[ax][az].scen_obry := random(360);
          ziemia.pk[ax][az].scen_obrx := random(50) - 25;
          ziemia.pk[ax][az].scen_obrz := random(50) - 25;
          ziemia.pk[ax][az].scen_rozm := random * 5 + 0.5;

          if (ax > 0) then
            ziemia.pk[ax - 1][az].tex := texkrzakow;
          if (az > 0) then
            ziemia.pk[ax][az - 1].tex := texkrzakow;
          ziemia.pk[ax][az].tex := texkrzakow;

        end;
      end;

    end;
  end;

  MakeSceneryRegions;
end;

// ---------------------------------------------------------------------------
procedure nowy_teren(wczytaj_nazwa: string = '');
const
  // lista numerow etapow, ktore sa wczytywane a nie generowane w normalnej grze
  wczytywane: array [0 .. 23] of integer = (1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25);
var
  a, az, ax, bx, bz, mapx, mapz: integer;
  vek1, vek2, vek3: TWektor;
  losowy: boolean;
  r: real;
  planetatmp: integer;
  n, an: integer;
  minHeight, maxHeight: extended;
  fightersCount: integer;
begin
  planetatmp := gra.planeta;

  losowy := wczytaj_nazwa = '';
  gra.nazwamp3 := '';

  // rzeczy poczatkowe przymusowe--------------------------------------------------
  if gra.jakiemisje = 0 then
    RandSeed := gra.planeta + 9000
  else
    randomize;
  SurvivorList.Clear;
  matka.x := 0;
  matka.z := 0;

  // rzeczy losowane (generowanie terenu)------------------------------------------
  if gra.jakiemisje = 0 then
  begin // normalna gra
    a := 0;

    while (a <= high(wczytywane)) and (wczytywane[a] <> gra.planeta + 1) do
      inc(a);
    losowy := a > high(wczytywane);

    if losowy then
      generuj_losowy
    else
      wczytaj_teren(inttostr(gra.planeta + 1), 1);

    gra.planeta := planetatmp;
  end
  else
  begin // losowe etapy i epizody dodatkowe
    if losowy then
      generuj_losowy
    else
      wczytaj_teren(wczytaj_nazwa);
  end;

  // rzeczy koncowe przymusowe-----------------------------------------------------
  GetMinMaxGroundHeight(minHeight, maxHeight);
  if matka.y < maxHeight + 450 then
    matka.y := maxHeight + 450;


  if gra.jakiemisje = 0 then
    RandSeed := gra.planeta + 12357
  else
    randomize;

  matka.cx := matka.x + 335;
  matka.cz := matka.z;

  // wyczysc scenerie na krawedziach
  for az := 0 to ziemia.wz - 1 do
    ziemia.pk[ziemia.wx - 1][az].scen := false;
  for ax := 0 to ziemia.wx - 1 do
    ziemia.pk[ax][ziemia.wz - 1].scen := false;

  // tu byly normalne terenu, ale przenioslem je na koniec:

  wiatr.kier := random(360);
  ziemia.koltla[3] := 1.0;

  glFogfv(GL_FOG_COLOR, @ziemia.koltla);
  glClearColor(ziemia.koltla[0], ziemia.koltla[1], ziemia.koltla[2], ziemia.koltla[3]);

  for a := 0 to high(dzialko) do
  begin
    with dzialko[a] do
    begin
      jest := true;
      rozwalone := false;
      kier := random * 360;
      kat := random * 80 + 10;

      if losowy then
      begin
        ax := round((x + ziemia.wlk / 2 - ziemia.px) / ziemia.wlk);
        az := round((z + ziemia.wlk / 2 - ziemia.pz) / ziemia.wlk);

        r := gdzie_y(x, z, 0) + 5 + random * 30;

        for bx := ax - 1 to ax do
          for bz := az - 1 to az do
          begin
            mapx := bx mod ziemia.wx;
            if mapx < 0 then
              mapx := ziemia.wx - 1 + mapx;
            mapz := bz mod ziemia.wz;
            if mapz < 0 then
              mapz := ziemia.wz - 1 + mapz;
            ziemia.pk[mapx, mapz].p := r;
          end;
      end;

      y := 2 + gdzie_y(x, z, 0);
      sila := 1;
    end;
  end;

  // piloci
  gra.ilepilotow := 0;
  for a := 0 to SurvivorList.Count - 1 do
  begin
    with SurvivorList[a] do
    begin
      jest := true;
      // nalotnisku:=random(length(ladowiska));
      kier := random * 360;
      x := random * ladowiska[nalotnisku].rx * 2 * ziemia.wlk + (ladowiska[nalotnisku].x - ladowiska[nalotnisku].rx) *
        ziemia.wlk + ziemia.px; // random*ziemia.wx*ziemia.wlk+ziemia.px;
      z := random * ladowiska[nalotnisku].rz * 2 * ziemia.wlk + (ladowiska[nalotnisku].z - ladowiska[nalotnisku].rz) *
        ziemia.wlk + ziemia.pz; // random*ziemia.wz*ziemia.wlk+ziemia.pz;
      y := gdzie_y(x, z, 0);
      fallingHeightStart := y;
      palisie := false;
      sila := 1;
      przewroc := 0;
      zly := not ladowiska[nalotnisku].dobre; // random(2)=0;
      if not zly and (gra.difficultyLevel >= 25) and (random(400) < gra.difficultyLevel) then
        zly := not zly;

      if not zly then
        inc(gra.ilepilotow);
    end;
  end;

  if not gra.sandboxMode then //#
  begin
    if gra.rodzajmisji <> 2 then
      fightersCount := (gra.difficultyLevel + 5) div 14
    else
      fightersCount := 2 + (gra.difficultyLevel + 5) div 17;
  end
  else
    fightersCount := round(Config.SandboxSettings.fightersCount * 3.5);

  setlength(mysliwiec, fightersCount);


  gra.iledzialek := length(dzialko);
  gra.dzialekzniszczonych := 0;
  gra.zginelo := 0;
  gra.zabranych := 0;
  gra.fightersDestroyed := 0;
  gra.fightersMinimum := 0;

  if losowy then
    case gra.rodzajmisji of
      0:
        begin
          gra.minimum := round(gra.ilepilotow * (0.5 + (gra.difficultyLevel / 200))
            { 0.7 } ); // = 70%
          gra.dzialekminimum := 0;
        end;
      1:
        begin
          gra.minimum := 0;
          gra.dzialekminimum := round(length(dzialko) * (0.5 + (gra.difficultyLevel / 200)));
          if gra.dzialekminimum > length(dzialko) then
            gra.dzialekminimum := length(dzialko);
        end;
      2:
        begin
          gra.minimum := 0;
          gra.fightersMinimum := round(3 + gra.difficultyLevel / 3);
        end;
    end;

  if gra.minimum > gra.ilepilotow then
    gra.minimum := gra.ilepilotow;

  if gra.sandboxMode then
  begin
    gra.nazwaplanety := '';
    gra.tekstintro := STR_MISSION_SANDBOX_TASK;
    gra.tekstoutrowin := '';
    gra.tekstoutrolost := '';
  end
  else
  if not MISSIONS_USE_STORYLINE or losowy then
    case gra.rodzajmisji of
      0:
        begin
          gra.nazwaplanety := STR_MISSION_PLANET + ' ' + losujnazwe;
          gra.tekstintro := STR_MISSION_RESCUE_TASK;
          gra.tekstoutrowin := STR_MISSION_RESCUE_WIN;
          gra.tekstoutrolost := STR_MISSION_RESCUE_LOST;
        end;
      1:
        begin
          gra.nazwaplanety := STR_MISSION_PLANET + ' ' + losujnazwe;
          gra.tekstintro := STR_MISSION_DESTROY_TASK;
          gra.tekstoutrowin := STR_MISSION_DESTROY_WIN;
          gra.tekstoutrolost := STR_MISSION_DESTROY_LOST;
        end;
      2:
        begin
          gra.nazwaplanety := STR_MISSION_PLANET + ' ' + losujnazwe;
          gra.tekstintro := STR_MISSION_DOGFIGHT_TASK;
          gra.tekstoutrowin := STR_MISSION_DESTROY_WIN;
          gra.tekstoutrolost := STR_MISSION_DESTROY_LOST;
        end;
    end;



  while pos('%1', gra.tekstintro) > 0 do
  begin
    a := pos('%1', gra.tekstintro);
    delete(gra.tekstintro, a, 2);
    insert(inttostr(gra.minimum), gra.tekstintro, a);
  end;
  while pos('%2', gra.tekstintro) > 0 do
  begin
    a := pos('%2', gra.tekstintro);
    delete(gra.tekstintro, a, 2);
    insert(inttostr(gra.ilepilotow), gra.tekstintro, a);
  end;
  while pos('%3', gra.tekstintro) > 0 do
  begin
    a := pos('%3', gra.tekstintro);
    delete(gra.tekstintro, a, 2);
    insert(inttostr(gra.dzialekminimum), gra.tekstintro, a);
  end;
  while pos('%4', gra.tekstintro) > 0 do
  begin
    a := pos('%4', gra.tekstintro);
    delete(gra.tekstintro, a, 2);
    insert(inttostr(gra.iledzialek), gra.tekstintro, a);
  end;
  while pos('%5', gra.tekstintro) > 0 do
  begin
    a := pos('%5', gra.tekstintro);
    delete(gra.tekstintro, a, 2);
    insert(inttostr(gra.czas div 60) + ':' + l2t(gra.czas mod 60, 2), gra.tekstintro, a);
  end;
  while pos('%6', gra.tekstintro) > 0 do
  begin
    a := pos('%6', gra.tekstintro);
    delete(gra.tekstintro, a, 2);
    insert(inttostr(gra.fightersMinimum), gra.tekstintro, a);
  end;

  gra.pozycjaYtekstuintro := 50;
  for a := 1 to length(gra.tekstintro) do
    if gra.tekstintro[a] = #13 then
      inc(gra.pozycjaYtekstuintro, 10);

  // normalne terenu:
  if (gra.jakiemisje <> 1) and not gra.sandboxMode then
    RandSeed := 43000
    // zawsze jednakowe ustawienie scenerii w normalnej grze i wczytywanej
  else
    randomize; // lub losowe w misjach losowych

  for az := 0 to ziemia.wz - 2 do
  begin
    for ax := 0 to ziemia.wx - 2 do
    begin
      vek1[0] := 1.0;
      vek1[1] := (ziemia.pk[ax + 1][az].p - ziemia.pk[ax][az].p);
      vek1[2] := 0.0;

      vek2[0] := 0.0;
      vek2[1] := (ziemia.pk[ax][az + 1].p - ziemia.pk[ax][az].p);
      vek2[2] := 1.0;

      vek3 := cross_prod(vek2, vek1);
      normalize(vek3);

      ziemia.pk[ax][az].norm[0] := vek3[0];
      ziemia.pk[ax][az].norm[1] := vek3[1];
      ziemia.pk[ax][az].norm[2] := vek3[2];

      // "oswietlenie" terenu z jednej strony
      ziemia.pk[ax][az].kr := ziemia.pk[ax][az].kr + (ziemia.pk[ax + 1][az].p - ziemia.pk[ax][az].p) / 400;
      if ziemia.pk[ax][az].kr < 0 then
        ziemia.pk[ax][az].kr := 0;
      if ziemia.pk[ax][az].kr > 1 then
        ziemia.pk[ax][az].kr := 1;
      ziemia.pk[ax][az].kg := ziemia.pk[ax][az].kg + (ziemia.pk[ax + 1][az].p - ziemia.pk[ax][az].p) / 400;
      if ziemia.pk[ax][az].kg < 0 then
        ziemia.pk[ax][az].kg := 0;
      if ziemia.pk[ax][az].kg > 1 then
        ziemia.pk[ax][az].kg := 1;
      ziemia.pk[ax][az].kb := ziemia.pk[ax][az].kb + (ziemia.pk[ax + 1][az].p - ziemia.pk[ax][az].p) / 400;
      if ziemia.pk[ax][az].kb < 0 then
        ziemia.pk[ax][az].kb := 0;
      if ziemia.pk[ax][az].kb > 1 then
        ziemia.pk[ax][az].kb := 1;

    end;
  end;

  SetSceneryObjects(losowy);

  if Config.Display.ShowGrass then
  begin
    // krzaki
    for az := 0 to ziemia.wz - 1 do
    begin
      for ax := 0 to ziemia.wx - 1 do
      begin
        if (ziemia.pk[ax][az].rodzaj = 1) or (ax = 0) or (az = 0) or (ax >= ziemia.wx - 2) or (az >= ziemia.wz - 2) then
        begin
          setlength(ziemia.pk[ax][az].krzaki, 0);
        end
        else
        begin

          n := random(9);

          setlength(ziemia.pk[ax][az].krzaki, n);

          { if losowy then begin
            ziemia.pk[ax][az].scen:=random(8)=0;

            if (abs(ziemia.pk[ax][az].p-ziemia.pk[ax+1][az].p)>8) or
            (abs(ziemia.pk[ax][az].p-ziemia.pk[ax-1][az].p)>8) or
            (abs(ziemia.pk[ax][az].p-ziemia.pk[ax][az+1].p)>8) or
            (abs(ziemia.pk[ax][az].p-ziemia.pk[ax][az-1].p)>8) then ziemia.pk[ax][az].scen:=false;
            end; }

          if n > 0 then
          begin
            for an := 0 to n - 1 do
            begin
              ziemia.pk[ax][az].krzaki[an].jest := true;
              ziemia.pk[ax][az].krzaki[an].rodzaj := random(4);

              ziemia.pk[ax][az].krzaki[an].x := ax * ziemia.wlk + ziemia.px + random * ziemia.wlk;
              ziemia.pk[ax][az].krzaki[an].z := az * ziemia.wlk + ziemia.pz + random * ziemia.wlk;
              ziemia.pk[ax][az].krzaki[an].y := gdzie_y(ziemia.pk[ax][az].krzaki[an].x,
                ziemia.pk[ax][az].krzaki[an].z, 0);

              r := ((0.5 + random) * 0.2);
              ziemia.pk[ax][az].krzaki[an].kr := ziemia.pk[ax][az].kr - r;
              if ziemia.pk[ax][az].krzaki[an].kr < 0.1 then
                ziemia.pk[ax][az].krzaki[an].kr := 0.1;
              if ziemia.pk[ax][az].krzaki[an].kr > 1 then
                ziemia.pk[ax][az].krzaki[an].kr := 1;
              ziemia.pk[ax][az].krzaki[an].kg := ziemia.pk[ax][az].kg - r;
              if ziemia.pk[ax][az].krzaki[an].kg < 0.1 then
                ziemia.pk[ax][az].krzaki[an].kg := 0.1;
              if ziemia.pk[ax][az].krzaki[an].kg > 1 then
                ziemia.pk[ax][az].krzaki[an].kg := 1;
              ziemia.pk[ax][az].krzaki[an].kb := ziemia.pk[ax][az].kb - r;
              if ziemia.pk[ax][az].krzaki[an].kb < 0.1 then
                ziemia.pk[ax][az].krzaki[an].kb := 0.1;
              if ziemia.pk[ax][az].krzaki[an].kb > 1 then
                ziemia.pk[ax][az].krzaki[an].kb := 1;
              ziemia.pk[ax][az].krzaki[an].obry := random(360);
              ziemia.pk[ax][az].krzaki[an].obrx := random(30) - 15;
              ziemia.pk[ax][az].krzaki[an].obrz := random(30) - 15;
              ziemia.pk[ax][az].krzaki[an].rozm := random * 6 + 3;
            end;
          end;
        end;
      end;
    end;
  end;

  for az := 0 to ziemia.wz - 1 do
    ziemia.pk[ziemia.wx - 1][az].tex := ziemia.pk[0][az].tex;

  for ax := 0 to ziemia.wx - 1 do
    ziemia.pk[ax][ziemia.wz - 1].tex := ziemia.pk[ax][0].tex;


  // nizej juz nie wolno robic NIC randomowego, co mialoby byc jednakowe w danych misjach (tak jak dziala normalna gra)

  // przywrocenie generatora l.losowych tak, aby byl ustalony dla misji normalnych, a dla pozostalych losowy
  if (gra.jakiemisje = 0) and not gra.sandboxMode then
    RandSeed := gra.planeta + 15000
  else
    randomize;

  matka.widac := 1;
  ziemia.widac := 0;
  matka.otwarcie_drzwi := 0;

  gra.czasdorozpoczecia := -1;
  licz := 0;
  gra.misjawypelniona := false;
  gra.moznakonczyc := false;
  gra.returnToMothership := false;

  SmokesClear;
  for a := 0 to high(iskry) do
    iskry[a].jest := false;
  for a := 0 to high(smiec) do
    smiec[a].jest := false;
  for a := 0 to high(rakieta) do
  begin
    if rakieta[a].dzw_slychac then
    begin
      FSOUND_StopSound(rakieta[a].dzw_kanal);
      rakieta[a].dzw_slychac := false;
    end;
    rakieta[a].jest := false;
  end;
  for a := 0 to high(mysliwiec) do
  begin
    if mysliwiec[a].dzw_slychac then
    begin
      FSOUND_StopSound(mysliwiec[a].dzw_kanal);
      mysliwiec[a].dzw_slychac := false;
    end;
    mysliwiec[a].jest := false;
  end;

  ustaw_gracza_namatce;
  gra.etap := 0;
  intro.czas := 0;
  intro.czas2 := 0;
  intro.scena := 0;
  inc(gra.planeta);

  if (gra.jakiemisje = 0) then
  begin
    if gra.planeta > MAIN_SCENARIO_MAX_LEVELS then
    begin
      gra.planeta := 1;
      gra.jakiemisje := 1;
    end;
  end
  else
  if (gra.jakiemisje = 1) then
  begin
    if gra.planeta > RANDOM_GAME_MAX_LEVELS then
      gra.planeta := 1;
  end
  else
  if gra.jakiemisje = 2 then
    inc(winieta.epizodmisja);

  cheaty.czas_od_ostatniej_litery := 0;

  randomize;
  frmMain.TimerCzas.Enabled := false;
end;

// ---------------------------------------------------------------------------
procedure nowa_gra(wczytaj_nr: integer; jaka: integer);
var
  startingUpgradeLevel: byte;
begin
  gra.sandboxMode := jaka = 3;
  if not gra.sandboxMode then
    gra.jakiemisje := jaka
  else
    gra.jakiemisje := 1;

  case jaka of
    0:
      gra.planeta := winieta.planetapocz - 1;
    1:
      gra.planeta := winieta.poziomtrudnosci - 1;
    2:
      gra.planeta := winieta.epizodmisja - 1;
    3:
      gra.planeta := Config.SandboxSettings.difficultyLevel - 1;
  end;
  gra.koniecgry := false;
  gra.zycia := 5;
  gra.pauza := false;
  gra.kasa := 0;
  gra.pkt := 0;

  startingUpgradeLevel := KeepValBetween(gra.planeta div 2, 0, 9);

  gra.poziomupgrade[0] := startingUpgradeLevel;
  gra.poziomupgrade[1] := startingUpgradeLevel;
  gra.poziomupgrade[2] := startingUpgradeLevel;
  gra.poziomupgrade[3] := startingUpgradeLevel;
  gra.poziomupgrade[4] := startingUpgradeLevel;
  gra.poziomupgrade[5] := startingUpgradeLevel;

  if wczytaj_nr >= 0 then
  begin
    wczytajgre(wczytaj_nr);
    winieta.jest := true;
    Sfx.muzyke_wlacz(1, true);
    winieta.corobi := 2;
  end
  else
  begin
    winieta.epizodmisja := 0;
    if gra.jakiemisje <> 2 then
      nowy_teren
    else
      nowy_teren(epizody[winieta.epizod].misje[0]);
  end;

  cheaty.full := gra.sandboxMode;
  cheaty.god := gra.sandboxMode;
  cheaty.fuel := gra.sandboxMode;
  cheaty.weapon := gra.sandboxMode;
  cheaty.lives := gra.sandboxMode;
  cheaty.load := gra.sandboxMode;
  cheaty.time := gra.sandboxMode;
  setlength(cheaty.wpisany_tekst, 0);

  // gracz.pilotow:=10;
end;

// ---------------------------------------------------------------------------
function wczytajepizod(nr: integer; nazwa: string): boolean;
var
  a, b, i: integer;
  f: TStream;
  bt, br, bg, bb: byte;
  r: real;
begin
  result := true;

  f := nil;
  try
    try
      f := TFileStream.Create(EXTRA_MISSIONS_FOLDER + nazwa, fmOpenRead);

      epizody[nr].tytul := wczytajstring(f);

      setlength(epizody[nr].misje, 0);

      f.readBuffer(b, sizeof(b));
      for a := 0 to b - 1 do
      begin
        setlength(epizody[nr].misje, length(epizody[nr].misje) + 1);
        epizody[nr].misje[high(epizody[nr].misje)] := wczytajstring(f);
      end;

      f.Free;
      f := nil;
    except
      if f <> nil then
      begin
        f.Free;
        f := nil;
      end;
      result := false;
    end;
  finally
    if f <> nil then
    begin
      f.Free;
      f := nil;
    end;
  end;

end;

// ---------------------------------------------------------------------------
procedure start;
var
  lmodel_ambient: array [0 .. 3] of GLFloat;
  sr: TSearchRec;
  FileAttrs: integer;
  s: string;
  a, b, c: integer;
  ch: char;

begin
  Sfx.fmodstart;
  randomize;

  // wczytaj tekstury
  glGenTextures(ile_tekstur, @texName);
  wczytaj_teksture(0, DATA_FOLDER + 'font.tga', 1);
  FormStart.progres.StepIt;
  wczytaj_teksture(1, DATA_FOLDER + 'ziemia1.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(2, DATA_FOLDER + 'dym1.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(3, DATA_FOLDER + 'lander.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(4, DATA_FOLDER + 'cien.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(5, DATA_FOLDER + 'pilot.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(6, DATA_FOLDER + 'mothership.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(7, DATA_FOLDER + 'gwiazdy.tga', 1);
  FormStart.progres.StepIt;
  wczytaj_teksture(8, DATA_FOLDER + 'pilotzly.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(9, DATA_FOLDER + 'celownik.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(10, DATA_FOLDER + 'chmury.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(11, DATA_FOLDER + 'swiatlo.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(12, DATA_FOLDER + 'snop.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(13, DATA_FOLDER + 'ikony.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(14, DATA_FOLDER + 'kokpit.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(15, DATA_FOLDER + 'oslona.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(16, DATA_FOLDER + 'krew.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture3d(17, [DATA_FOLDER + 'ziemia0.tga', DATA_FOLDER + 'ziemia1.tga', DATA_FOLDER + 'ziemia2.tga', DATA_FOLDER + 'ziemia3.tga']);
  FormStart.progres.StepIt;
  wczytaj_teksture(18, DATA_FOLDER + 'krzaki.tga', 0);
  FormStart.progres.StepIt;

  // wczytaj obiekty
  setlength(obiekt, 25);

  obiekt[ob_gracz].o := TOBJModel.Create;
  obiekt[ob_gracz].o.LoadFromFile(DATA_FOLDER + 'l3.obj', 5);
  obiekt[ob_gracz].tex := 3;
  obiekt[ob_gracz].mat_a[0] := 0.2;
  obiekt[ob_gracz].mat_a[1] := 0.2;
  obiekt[ob_gracz].mat_a[2] := 0.2;
  obiekt[ob_gracz].mat_a[3] := 1.0;
  obiekt[ob_gracz].mat_d[0] := 0.8;
  obiekt[ob_gracz].mat_d[1] := 0.8;
  obiekt[ob_gracz].mat_d[2] := 0.8;
  obiekt[ob_gracz].mat_d[3] := 1.0;
  obiekt[ob_gracz].mat_s[0] := 1.0;
  obiekt[ob_gracz].mat_s[1] := 1.0;
  obiekt[ob_gracz].mat_s[2] := 1.0;
  obiekt[ob_gracz].mat_s[3] := 1.0;
  obiekt[ob_gracz].mat_shin := 20;
  FormStart.progres.StepIt;
  setlength(gracz.elementy, length(obiekt[ob_gracz].o.Groups));

  obiekt[ob_pilot].o := TOBJModel.Create;
  obiekt[ob_pilot].o.LoadFromFile(DATA_FOLDER + 'pilot.obj', 0.4);
  obiekt[ob_pilot].tex := 5;
  obiekt[ob_pilot].mat_a[0] := 0.3;
  obiekt[ob_pilot].mat_a[1] := 0.3;
  obiekt[ob_pilot].mat_a[2] := 0.3;
  obiekt[ob_pilot].mat_a[3] := 0.4;
  obiekt[ob_pilot].mat_d[0] := 0.5;
  obiekt[ob_pilot].mat_d[1] := 0.5;
  obiekt[ob_pilot].mat_d[2] := 0.5;
  obiekt[ob_pilot].mat_d[3] := 0.6;
  obiekt[ob_pilot].mat_s[0] := 1.0;
  obiekt[ob_pilot].mat_s[1] := 1.0;
  obiekt[ob_pilot].mat_s[2] := 1.0;
  obiekt[ob_pilot].mat_s[3] := 1.0;
  obiekt[ob_pilot].mat_shin := 100;
  FormStart.progres.StepIt;

  obiekt[ob_matka].o := TOBJModel.Create;
  obiekt[ob_matka].o.LoadFromFile(DATA_FOLDER + 'moth2.obj');
  obiekt[ob_matka].tex := 6;
  obiekt[ob_matka].mat_a[0] := 0.3;
  obiekt[ob_matka].mat_a[1] := 0.3;
  obiekt[ob_matka].mat_a[2] := 0.3;
  obiekt[ob_matka].mat_a[3] := 0.4;
  obiekt[ob_matka].mat_d[0] := 0.5;
  obiekt[ob_matka].mat_d[1] := 0.5;
  obiekt[ob_matka].mat_d[2] := 0.5;
  obiekt[ob_matka].mat_d[3] := 0.6;
  obiekt[ob_matka].mat_s[0] := 1.0;
  obiekt[ob_matka].mat_s[1] := 1.0;
  obiekt[ob_matka].mat_s[2] := 1.0;
  obiekt[ob_matka].mat_s[3] := 1.0;
  obiekt[ob_matka].mat_shin := 100;
  FormStart.progres.StepIt;

  obiekt[ob_dzialko].o := TOBJModel.Create;
  obiekt[ob_dzialko].o.LoadFromFile(DATA_FOLDER + 'dzn0.obj', 2);
  obiekt[ob_dzialko].tex := 8;
  obiekt[ob_dzialko].mat_a[0] := 0.3;
  obiekt[ob_dzialko].mat_a[1] := 0.3;
  obiekt[ob_dzialko].mat_a[2] := 0.3;
  obiekt[ob_dzialko].mat_a[3] := 0.4;
  obiekt[ob_dzialko].mat_d[0] := 0.5;
  obiekt[ob_dzialko].mat_d[1] := 0.5;
  obiekt[ob_dzialko].mat_d[2] := 0.5;
  obiekt[ob_dzialko].mat_d[3] := 0.6;
  obiekt[ob_dzialko].mat_s[0] := 1.0;
  obiekt[ob_dzialko].mat_s[1] := 1.0;
  obiekt[ob_dzialko].mat_s[2] := 1.0;
  obiekt[ob_dzialko].mat_s[3] := 1.0;
  obiekt[ob_dzialko].mat_shin := 70;
  FormStart.progres.StepIt;

  obiekt[ob_dzialkokawalki].o := TOBJModel.Create;
  obiekt[ob_dzialkokawalki].o.LoadFromFile(DATA_FOLDER + 'dzkaw.obj', 2);
  obiekt[ob_dzialkokawalki].tex := 8;
  obiekt[ob_dzialkokawalki].mat_a[0] := 0.3;
  obiekt[ob_dzialkokawalki].mat_a[1] := 0.3;
  obiekt[ob_dzialkokawalki].mat_a[2] := 0.3;
  obiekt[ob_dzialkokawalki].mat_a[3] := 0.4;
  obiekt[ob_dzialkokawalki].mat_d[0] := 0.5;
  obiekt[ob_dzialkokawalki].mat_d[1] := 0.5;
  obiekt[ob_dzialkokawalki].mat_d[2] := 0.5;
  obiekt[ob_dzialkokawalki].mat_d[3] := 0.6;
  obiekt[ob_dzialkokawalki].mat_s[0] := 1.0;
  obiekt[ob_dzialkokawalki].mat_s[1] := 1.0;
  obiekt[ob_dzialkokawalki].mat_s[2] := 1.0;
  obiekt[ob_dzialkokawalki].mat_s[3] := 1.0;
  obiekt[ob_dzialkokawalki].mat_shin := 70;
  FormStart.progres.StepIt;

  obiekt[ob_dzialkowieza].o := TOBJModel.Create;
  obiekt[ob_dzialkowieza].o.LoadFromFile(DATA_FOLDER + 'dzn1.obj', 2);
  obiekt[ob_dzialkowieza].tex := 8;
  obiekt[ob_dzialkowieza].mat_a[0] := 0.3;
  obiekt[ob_dzialkowieza].mat_a[1] := 0.4;
  obiekt[ob_dzialkowieza].mat_a[2] := 0.3;
  obiekt[ob_dzialkowieza].mat_a[3] := 1.0;
  obiekt[ob_dzialkowieza].mat_d[0] := 0.3;
  obiekt[ob_dzialkowieza].mat_d[1] := 0.4;
  obiekt[ob_dzialkowieza].mat_d[2] := 0.3;
  obiekt[ob_dzialkowieza].mat_d[3] := 1.0;
  obiekt[ob_dzialkowieza].mat_s[0] := 1.0;
  obiekt[ob_dzialkowieza].mat_s[1] := 1.0;
  obiekt[ob_dzialkowieza].mat_s[2] := 1.0;
  obiekt[ob_dzialkowieza].mat_s[3] := 1.0;
  obiekt[ob_dzialkowieza].mat_shin := 120;
  FormStart.progres.StepIt;

  obiekt[ob_dzialkowieza2].o := TOBJModel.Create;
  obiekt[ob_dzialkowieza2].o.LoadFromFile(DATA_FOLDER + 'dzn12.obj', 2);
  obiekt[ob_dzialkowieza2].tex := 8;
  obiekt[ob_dzialkowieza2].mat_a[0] := 0.3;
  obiekt[ob_dzialkowieza2].mat_a[1] := 0.4;
  obiekt[ob_dzialkowieza2].mat_a[2] := 0.3;
  obiekt[ob_dzialkowieza2].mat_a[3] := 1.0;
  obiekt[ob_dzialkowieza2].mat_d[0] := 0.3;
  obiekt[ob_dzialkowieza2].mat_d[1] := 0.4;
  obiekt[ob_dzialkowieza2].mat_d[2] := 0.3;
  obiekt[ob_dzialkowieza2].mat_d[3] := 1.0;
  obiekt[ob_dzialkowieza2].mat_s[0] := 0.8;
  obiekt[ob_dzialkowieza2].mat_s[1] := 0.8;
  obiekt[ob_dzialkowieza2].mat_s[2] := 0.8;
  obiekt[ob_dzialkowieza2].mat_s[3] := 0.8;
  obiekt[ob_dzialkowieza2].mat_shin := 120;
  FormStart.progres.StepIt;

  obiekt[ob_dzialkolufa].o := TOBJModel.Create;
  obiekt[ob_dzialkolufa].o.LoadFromFile(DATA_FOLDER + 'dzn2.obj', 2);
  obiekt[ob_dzialkolufa].tex := 8;
  obiekt[ob_dzialkolufa].mat_a[0] := 0.3;
  obiekt[ob_dzialkolufa].mat_a[1] := 0.3;
  obiekt[ob_dzialkolufa].mat_a[2] := 0.3;
  obiekt[ob_dzialkolufa].mat_a[3] := 0.4;
  obiekt[ob_dzialkolufa].mat_d[0] := 0.5;
  obiekt[ob_dzialkolufa].mat_d[1] := 0.5;
  obiekt[ob_dzialkolufa].mat_d[2] := 0.5;
  obiekt[ob_dzialkolufa].mat_d[3] := 0.6;
  obiekt[ob_dzialkolufa].mat_s[0] := 1.0;
  obiekt[ob_dzialkolufa].mat_s[1] := 1.0;
  obiekt[ob_dzialkolufa].mat_s[2] := 1.0;
  obiekt[ob_dzialkolufa].mat_s[3] := 1.0;
  obiekt[ob_dzialkolufa].mat_shin := 100;
  FormStart.progres.StepIt;

  obiekt[ob_dzialkolufa2].o := TOBJModel.Create;
  obiekt[ob_dzialkolufa2].o.LoadFromFile(DATA_FOLDER + 'dzn22.obj', 2);
  obiekt[ob_dzialkolufa2].tex := 8;
  obiekt[ob_dzialkolufa2].mat_a[0] := 0.3;
  obiekt[ob_dzialkolufa2].mat_a[1] := 0.3;
  obiekt[ob_dzialkolufa2].mat_a[2] := 0.3;
  obiekt[ob_dzialkolufa2].mat_a[3] := 0.4;
  obiekt[ob_dzialkolufa2].mat_d[0] := 0.5;
  obiekt[ob_dzialkolufa2].mat_d[1] := 0.5;
  obiekt[ob_dzialkolufa2].mat_d[2] := 0.5;
  obiekt[ob_dzialkolufa2].mat_d[3] := 0.6;
  obiekt[ob_dzialkolufa2].mat_s[0] := 1.0;
  obiekt[ob_dzialkolufa2].mat_s[1] := 1.0;
  obiekt[ob_dzialkolufa2].mat_s[2] := 1.0;
  obiekt[ob_dzialkolufa2].mat_s[3] := 1.0;
  obiekt[ob_dzialkolufa2].mat_shin := 120;
  FormStart.progres.StepIt;

  obiekt[ob_rakieta].o := TOBJModel.Create;
  obiekt[ob_rakieta].o.LoadFromFile(DATA_FOLDER + 'rakieta.obj', 0.3);
  obiekt[ob_rakieta].tex := 5;
  obiekt[ob_rakieta].mat_a[0] := 0.3;
  obiekt[ob_rakieta].mat_a[1] := 0.3;
  obiekt[ob_rakieta].mat_a[2] := 0.3;
  obiekt[ob_rakieta].mat_a[3] := 0.4;
  obiekt[ob_rakieta].mat_d[0] := 0.5;
  obiekt[ob_rakieta].mat_d[1] := 0.5;
  obiekt[ob_rakieta].mat_d[2] := 0.5;
  obiekt[ob_rakieta].mat_d[3] := 0.6;
  obiekt[ob_rakieta].mat_s[0] := 1.0;
  obiekt[ob_rakieta].mat_s[1] := 1.0;
  obiekt[ob_rakieta].mat_s[2] := 1.0;
  obiekt[ob_rakieta].mat_s[3] := 1.0;
  obiekt[ob_rakieta].mat_shin := 100;
  FormStart.progres.StepIt;

  obiekt[ob_mysliwiec].o := TOBJModel.Create;
  obiekt[ob_mysliwiec].o.LoadFromFile(DATA_FOLDER + 'lat.obj', 1.3);
  obiekt[ob_mysliwiec].tex := 8;
  obiekt[ob_mysliwiec].mat_a[0] := 0.3;
  obiekt[ob_mysliwiec].mat_a[1] := 0.3;
  obiekt[ob_mysliwiec].mat_a[2] := 0.3;
  obiekt[ob_mysliwiec].mat_a[3] := 0.4;
  obiekt[ob_mysliwiec].mat_d[0] := 0.5;
  obiekt[ob_mysliwiec].mat_d[1] := 0.5;
  obiekt[ob_mysliwiec].mat_d[2] := 0.5;
  obiekt[ob_mysliwiec].mat_d[3] := 0.6;
  obiekt[ob_mysliwiec].mat_s[0] := 1.0;
  obiekt[ob_mysliwiec].mat_s[1] := 1.0;
  obiekt[ob_mysliwiec].mat_s[2] := 1.0;
  obiekt[ob_mysliwiec].mat_s[3] := 1.0;
  obiekt[ob_mysliwiec].mat_shin := 100;
  FormStart.progres.StepIt;

  obiekt[ob_kokpit].o := TOBJModel.Create;
  obiekt[ob_kokpit].o.LoadFromFile(DATA_FOLDER + 'kokpit.obj');
  obiekt[ob_kokpit].tex := 14;
  obiekt[ob_kokpit].mat_a[0] := 0.3;
  obiekt[ob_kokpit].mat_a[1] := 0.3;
  obiekt[ob_kokpit].mat_a[2] := 0.3;
  obiekt[ob_kokpit].mat_a[3] := 0.4;
  obiekt[ob_kokpit].mat_d[0] := 0.5;
  obiekt[ob_kokpit].mat_d[1] := 0.5;
  obiekt[ob_kokpit].mat_d[2] := 0.5;
  obiekt[ob_kokpit].mat_d[3] := 0.6;
  obiekt[ob_kokpit].mat_s[0] := 1.0;
  obiekt[ob_kokpit].mat_s[1] := 1.0;
  obiekt[ob_kokpit].mat_s[2] := 1.0;
  obiekt[ob_kokpit].mat_s[3] := 1.0;
  obiekt[ob_kokpit].mat_shin := 100;
  FormStart.progres.StepIt;

  obiekt[ob_kamien].o := TOBJModel.Create;
  obiekt[ob_kamien].o.LoadFromFile(DATA_FOLDER + 'kamo.obj', 2.4);
  obiekt[ob_kamien].tex := 1;
  obiekt[ob_kamien].mat_a[0] := 0.3;
  obiekt[ob_kamien].mat_a[1] := 0.3;
  obiekt[ob_kamien].mat_a[2] := 0.3;
  obiekt[ob_kamien].mat_a[3] := 0.4;
  obiekt[ob_kamien].mat_d[0] := 0.5;
  obiekt[ob_kamien].mat_d[1] := 0.5;
  obiekt[ob_kamien].mat_d[2] := 0.5;
  obiekt[ob_kamien].mat_d[3] := 0.6;
  obiekt[ob_kamien].mat_s[0] := 1.0;
  obiekt[ob_kamien].mat_s[1] := 1.0;
  obiekt[ob_kamien].mat_s[2] := 1.0;
  obiekt[ob_kamien].mat_s[3] := 1.0;
  obiekt[ob_kamien].mat_shin := 100;
  FormStart.progres.StepIt;

  for a := 0 to ile_obiektow_scenerii - 1 do
  begin
    obiekt[ob_sceneria1 + a].o := TOBJModel.Create;
    obiekt[ob_sceneria1 + a].o.LoadFromFile(DATA_FOLDER + 'sc' + inttostr(a + 1) + '.obj');
    obiekt[ob_sceneria1 + a].tex := 1;
    FormStart.progres.StepIt;
  end;

  setlength(swiatlo, 5);

  SmokesList := TObjectList<TSmoke>.Create; //  setlength(dym, 800);
  SurvivorList := TSurvivorList.Create;
  setlength(iskry, 500);
  setlength(smiec, 250);
  setlength(rakieta, 400);
  setlength(mysliwiec, 1);

  glEnable(GL_FOG);
  glFogf(GL_FOG_START, 400.0);
  glFogf(GL_FOG_END, 1180.0);
  glFogi(GL_FOG_MODE, GL_EXP);
  glFogf(GL_FOG_DENSITY, 0.0015);
  glHint(GL_FOG_HINT, GL_NICEST);

  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_LINE_SMOOTH);
  glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);

  glPointSize(0);
  glLineWidth(1);
  glEdgeFlag(GL_FALSE);

  glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, 1);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  lmodel_ambient[0] := 0.3;
  lmodel_ambient[1] := 0.3;
  lmodel_ambient[2] := 0.3;
  lmodel_ambient[3] := 1.0;
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient);

  tworz_obiekty;
  InitRenderers;

  frmMain.PwrInp.Initialize;

  // zapiszgre(1);
  winieta.jest := true;
  winieta.corobi := 0;
  winieta.skrol := 0;
  winieta.kursor := 0;
  winieta.planetapocz := 1;
  winieta.poziomtrudnosci := 1;
  winieta.epizod := 0;
  winieta.epizodmisja := 0;
  gra.koniecgry := true;

  kamera := 2;

  glowneintro.jest := true;


  FormStart.progres.StepIt;

  FileAttrs := faReadOnly or faArchive or faAnyFile;
  if FindFirst(EXTRA_MISSIONS_FOLDER + '*.RFepz', FileAttrs, sr) = 0 then
  begin
    repeat
      if (sr.Attr and FileAttrs) = sr.Attr then
      begin
        setlength(epizody, length(epizody) + 1);
        s := sr.name;
        { if pos(lowercase('.rfepz'),lowercase(s))>0 then
          delete(s,pos(lowercase('.rfepz'),lowercase(s)),4); }
        if not wczytajepizod(high(epizody), s) then
          setlength(epizody, length(epizody) - 1);
      end;
    until FindNext(sr) <> 0;
    sysutils.FindClose(sr);
  end;

  FormStart.progres.StepIt;
  wczytajzapisy;
  FormStart.progres.StepIt;

  for a := 0 to high(cheatcodes) do
  begin
    setlength(cheatcodes_n[a], length(cheatcodes[a]));
    for b := 1 to length(cheatcodes[a]) do
    begin
      for c := 1 to 200 do
      begin
        s := frmMain.PwrInp.KeyName[c];
        if length(s) = 1 then
          ch := s[1]
        else
          ch := #0;

        if ch = cheatcodes[a][b] then
        begin
          cheatcodes_n[a][b - 1] := c;
          break;
        end;

      end;
    end;
  end;

  cheaty := Default(TCheatCodes);

  RenderInit;

  glClearColor(0, 0, 0, 0);

  frmMain.PowerTimer1.MayProcess := true;
  frmMain.PowerTimer1.MayRender := true;
end;

end.
