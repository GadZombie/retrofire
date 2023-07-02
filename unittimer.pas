unit unittimer;

interface

uses
  directinput8, OpenGl, gl, Glu, glext, unittex, obj, sysutils, classes,
  windows,
  fmod, fmodtypes, fmoderrors, fmodpresets, powerinputs, forms,
  ZGLMathProcs, ZGLGraphMath;

type
  TUpgradeItem = record
    ile: real;
    cena: integer;
  end;

const
  pi180 = pi / 180;

  ob_gracz = 0;
  ob_pilot = 1;
  ob_matka = 2;
  ob_dzialko = 3;
  ob_dzialkolufa = 4;
  ob_rakieta = 5;
  ob_dzialkokawalki = 6;
  ob_dzialkowieza = 7;
  ob_mysliwiec = 8;
  ob_dzialkowieza2 = 9;
  ob_dzialkolufa2 = 10;
  ob_kokpit = 11;
  ob_kamien = 12;

  ob_sceneria1 = 13;
  ile_obiektow_scenerii = 6;

  upgrade: array [0 .. 5, 0 .. 9] of TUpgradeItem = (
    { paliwo } ((ile: 150; cena: 0), (ile: 180; cena: 450), (ile: 200; cena: 900), (ile: 240; cena: 1395), (ile: 290;
    cena: 2070), (ile: 320; cena: 2430), (ile: 340; cena: 3150), (ile: 360; cena: 3630), (ile: 400;
    cena: 4380), (ile: 450; cena: 5100)),
    { rakiety } ((ile: 8; cena: 0), (ile: 12; cena: 270), (ile: 16; cena: 450), (ile: 20; cena: 630), (ile: 26;
    cena: 810), (ile: 32; cena: 960), (ile: 36; cena: 1140), (ile: 40; cena: 1500), (ile: 46; cena: 2250), (ile: 54;
    cena: 4140)),
    { dzialko } ((ile: 50; cena: 0), (ile: 80; cena: 240), (ile: 130; cena: 440), (ile: 160; cena: 600), (ile: 200;
    cena: 720), (ile: 250; cena: 890), (ile: 300; cena: 1100), (ile: 340; cena: 1400), (ile: 380;
    cena: 2100), (ile: 500; cena: 3950)),
    { sila } ((ile: 0.8; cena: 0), (ile: 0.9; cena: 360), (ile: 1; cena: 510), (ile: 1.2; cena: 750), (ile: 1.5;
    cena: 1140), (ile: 2; cena: 1560), (ile: 2.5; cena: 2340), (ile: 3; cena: 2700), (ile: 3.5; cena: 3450), (ile: 4;
    cena: 4820)),
    { chlodzenie } ((ile: 0.3; cena: 0), (ile: 0.5; cena: 270), (ile: 0.6; cena: 510), (ile: 0.7; cena: 690), (ile: 0.8;
    cena: 972), (ile: 1; cena: 1110), (ile: 1.5; cena: 1537), (ile: 2; cena: 1975), (ile: 2.5; cena: 2360), (ile: 3;
    cena: 2998)),
    { ladownosc } ((ile: 8; cena: 0), (ile: 9; cena: 600), (ile: 10; cena: 930), (ile: 11; cena: 1240), (ile: 12;
    cena: 1620), (ile: 14; cena: 1980), (ile: 16; cena: 2375), (ile: 18; cena: 2827), (ile: 20; cena: 4080), (ile: 24;
    cena: 6250)));

  cenazycia = 3000;
  maxoslonablysk = 1.2;
  maxcheats = 6;
  cheatcodes: array [0 .. maxcheats] of string = ('FULL', 'GOD', 'FUEL', 'WEAPON', 'LIVES', 'LOAD', 'TIME');

type
  TWektor = array [0 .. 3] of GLFloat;

  Tobiekt = record
    o: TOBJModel;
    tex: byte;
    mat_a: array [0 .. 3] of GLFloat;
    mat_d: array [0 .. 3] of GLFloat;
    mat_s: array [0 .. 3] of GLFloat;
    mat_shin: integer;
  end;

  TGraczElement = record
    obrx, obry, obrz: real;
  end;

  TPlayer = record
    x, y, z, cieny: real;
    dx, dy, dz, nacisk: real;

    kier: real; // kierunek ruchu
    szybkier: real; // szybkosc obracania sie
    szyb: real;

    wykrecsila: real;
    swiatlodol, swiatlotyl, swiatlogora, swiatlolewo, swiatloprawo: real;

    sila, maxsila: real;
    temp, chlodz: real;

    paliwo, maxpaliwa: real;
    zyje: boolean;

    stoi, namatce: boolean;

    pilotow, ladownosc, zlychpilotow: integer;

    grlot: integer; // na jakim lotnisku stoi gracz; -1=zaden

    maxrakiet, ilerakiet: integer;
    maxdzialko, iledzialko: integer;
    stronastrzalu: shortint;

    oslonablysk: real;

    namierzone, conamierzone: integer; // 0=dzialko, 1=mysliwiec

    _namierzone, _conamierzone: integer; // 0=dzialko, 1=mysliwiec

    odlegloscnamierzonegodzialka: real;

    zlywsrodku: boolean;
    elementy: array of TGraczElement;

    uszkodzenia: array [0 .. 0] of boolean; // 0=latarka
    randuszkodzenia: integer;
    silaskrzywien: real;
  end;

  TMotherShip = record
    x, y, z: real;
    cx, cz: real;

    widac: real;
    otwarcie_drzwi: real; // podawane w % od 0 do 1
  end;

  TKrzak = record
    jest: boolean;
    x, y, z: real;
    obrx, obry, obrz: integer;
    rozm: single;
    kr, kg, kb: single;
    rodzaj: byte;
  end;

  TZiemiaPunkt = record
    p: real;
    norm: TWektor;
    kr, kg, kb: real;
    tex: real;
    rodzaj: byte; { 0-nic, 1-ladowisko }

    scen: boolean;
    scen_rodz: byte;
    sckr, sckg, sckb: single;
    scen_obrx, scen_obry, scen_obrz: integer;
    scen_rozm: single;

    krzaki: array of TKrzak;
  end;

  TGround = record
    px, pz: real;
    wx, wz: integer;
    pk: array of array of TZiemiaPunkt;

    wlk: integer;

    grawitacja: real;
    gestoscpowietrza: real;

    koltla, jestkoltla: array [0 .. 3] of GLFloat;
    widac: real;

    chmuryx, chmuryz: real;
  end;

  TLightsource = record
    jest: boolean;
    x, y, z: real;
    jasnosc: real;
    szybkosc: real;
  end;

  TSmoke = record
    jest: boolean;
    x, y, z: real;
    dx, dy, dz: real;

    rozmiar: real;
    kolr, kolg, kolb: real;
    przezr, szybprzezr: real;

    rodz: byte; { 0:ogien, 1:dym; 2:tworzy dymy }
    tekstura: byte;
    obrot: real;
  end;

  TSpark = record
    jest: boolean;
    x, y, z: real;
    dx, dy, dz: real;

    rozmiar: real;
    kolr, kolg, kolb: real;
    przezr: real;
  end;

  TWind = record
    sila: real;
    kier: real;
  end;

  TTrash = record
    jest: boolean;
    x, y, z: real;
    dx, dy, dz: real;

    nobiekt: byte;
    element: byte;
    obrx, obry, obrz: real;
    palisie, dymisie: boolean;
    typ: byte;

    randuszkodzenia: integer;
    silaskrzywien: real;
    czas: integer;
  end;

  TPilot = record
    jest, zawszewidac: boolean;
    x, y, z, dy, dx, dz: real;
    kier: real;
    nalotnisku: integer;
    palisie: boolean;
    sila: real;

    zly: boolean;

    stoi: boolean;
    ani: integer;
    rodzani: byte;
    rescued: boolean;

    uciekaodgracza: integer; // ile czasu jeszcze ucieka od gracza, zamiast wsiadac; potrzebne do wysadzania ich

    miejscenamatce: real;
    // pozycja w drzwiach statku-matki, do ktorej sie celuje, kiedy do niej biegnie; jesli =0 to wylosuj nowa pozycje

    przewroc: real; { kat, pod jakim stoi/lezy ;) 0-90 }
  end;

  TLandfield = record
    x, z: integer; // pozycja w kratkach
    rx, rz: integer; // rozmiar

    dobre: boolean;
    pilotow: byte; // tylko do generowania terenu!
  end;

  TTurretGun = record
    jest, namierza: boolean;
    x, y, z: real;
    kier, kat, kier_, kat_: real;
    sila: real;

    rodzaj: byte; // 0=rakietowe, 1=pociskowe

    rozwalone: boolean;
    swiatlo: byte;
  end;

  TRocket = record
    jest: boolean;
    x, y, z, _x, _y, _z: real;
    dx, dy, dz: real;

    kier, kierdol: real;

    czyja: byte; { 0:gracz, 1:wrog }

    obrot: integer;
    paliwo: integer;

    rodzaj: byte; { 0-rakieta, 1-pocisk zwykly, niewidoczny }

    dzw_kanal: longint;
    dzw_slychac: boolean; // zaleznie od odleglosci od gracza
  end;

  TFighter = record
    jest: boolean;
    x, y, z, _x, _y, _z: real;

    kier, // kier: obrot o 360, czyli gdzie leci
    kierdol, // kierdol: skierowanie w pionie, czy w gore czy w dol
    obrot: real; // obrot: obrot wokol wlasnej osi - przy skrecaniu

    szybkosc: real;

    sila: real;
    zniszczony: boolean;
    atakuje: boolean; // czyli leci za graczem, albo w przeciwna strone

    dzw_kanal: longint;
    dzw_slychac: boolean; // zaleznie od odleglosci od gracza
  end;

  TGame = record
    jakiemisje: byte; { 0:norma, 1:losowe, 2:dodatkowe(wyczytwane) }
    rodzajmisji: byte; { 0:zbieraj pilotow, 1:zniszcz dzialka }
    ilepilotow, zginelo, zabranych, minimum, pilotowbiegniedomatki: integer;

    iledzialek, dzialekzniszczonych, dzialekminimum: integer;

    poziomupgrade: array [0 .. 5] of byte;

    czas: integer;

    etap: integer; { 0:intro, 1:gra, 2:zakonczenie }

    kamera, jestkamera: array [0 .. 2, 0 .. 2] of real;
    katkamera: real;

    planeta: integer;
    zycia: integer;
    kasa, pkt: int64;

    (* planeta_faktyczna:integer; //to samo, co planeta, ale w normalnej grze wykorzystywane do zapamietania
      //ostatniego etapu, bo po wczytaniu etapu z pliku (niektore misje) zmienia sie
      //wartosc 'planeta' ze wzgledu na wczytany z tego poziom trudnosci
    *)
    czasdorozpoczecia: integer; { jesli>0, to sie czeka. dziala po rozwaleniu sie, zeby chwile odczekalo }
    koniecgry: boolean;
    misjawypelniona, moznakonczyc: boolean;
    pauza: boolean;

    //
    nazwaplanety, tekstintro, tekstoutrowin, tekstoutrolost: string;
    pozycjaYtekstuintro: integer;

    nazwamp3: string;
  end;

  TIntro = record
    czas, czas2, scena: integer;
  end;

  TMainIntro = record
    czas, czas2, scena: integer;
    jest: boolean;
  end;

  TTitleScreen = record
    jest: boolean;
    kursor: integer;

    planetapocz: integer;

    poziomtrudnosci: integer;
    epizod, epizodmisja: integer;

    corobi: byte; { 0:winieta, 1:sklep, 2:zapis gry, 3:wczytanie gry }

    skrol: integer;
  end;

  TSaveGame = record
    jest: boolean;

    rodzajgry: byte;

    data: Tdatetime;
    poziomupgrade: array [0 .. 5] of integer;
    pkt, kasa: int64;
    planeta, zycia: integer;
    epizod: string; { nazwa epizodu w przypadku misji dodatkowych }

  end;

  TEpisode = record
    tytul: string;
    misje: array of string;
  end;

  TCheatCodes = record
    full: boolean; // full wszystkich upgradow
    god: boolean; // niezniszczalnosc
    fuel: boolean; // paliwo sie nie zmniejsza
    weapon: boolean; // caly czas max wszystkich broni
    lives: boolean; // max dodatkowych ladownikow
    load: boolean; // max ladownosci
    time: boolean; // max czasu

    czas_od_ostatniej_litery: integer; // zmniejsza sie do 0 i jesli dojdzie, to staje, a wpisywana_litera sie zeruje
    wpisany_tekst: array of byte;
  end;

var
  matka: TMotherShip;
  gracz: TPlayer;

  ziemia: TGround;

  dym: array of TSmoke;
  swiatlo: array of TLightsource;
  iskry: array of TSpark;
  wiatr: TWind;
  obiekt: array of Tobiekt;
  smiec: array of TTrash;

  kamera: integer;

  pilot: array of TPilot;
  ladowiska: array of TLandfield;
  dzialko: array of TTurretGun;
  rakieta: array of TRocket;
  mysliwiec: array of TFighter;

  gra: TGame;
  intro: TIntro;
  glowneintro: TMainIntro;
  winieta: TTitleScreen;
  zapisy: array [0 .. 9] of TSaveGame;
  epizody: array of TEpisode;
  cheaty: TCheatCodes;
  cheatcodes_n: array [0 .. maxcheats] of array of byte;

  licz: integer;

function jaki_to_kat(dx, dy: real): real;
FUNCTION l2t(liczba: int64; ilosc_lit: byte): string;
function sqrt2(v: real): real;
procedure zapiszstring(var plik: TStream; t: string);
function wczytajstring(var plik: TStream): string;

procedure normalize(var vec: array of GLFloat);
function cross_prod(in1, in2: TWektor): TWektor;

function gdzie_y(x, z, y: real): real;
procedure xznasiatce(var x: integer; var z: integer; nx, nz: real);

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

uses Render, Main, UnitStart, Language;

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
  frmMain.stop_dzwiek(2);
end;

// ---------------------------------------------------------------------------
procedure zapiszgre(numer: integer);
var
  a, b: integer;
  f: TStream;
begin
  with zapisy[numer] do
  begin
    jest := true;
    rodzajgry := gra.jakiemisje;
    data := now;
    for a := 0 to 5 do
      poziomupgrade[a] := gra.poziomupgrade[a];
    pkt := gra.pkt;
    kasa := gra.kasa;
    if gra.jakiemisje <> 2 then
    begin
      planeta := gra.planeta + 1;
      epizod := '';
    end
    else
    begin
      planeta := winieta.epizodmisja + 1;
      epizod := epizody[winieta.epizod].tytul;
    end;
    zycia := gra.zycia;
  end;

  f := nil;
  try
    try
      f := TFileStream.Create('zapisy.sav', fmCreate);

      for a := 0 to high(zapisy) do
      begin
        f.WriteBuffer(zapisy[a].jest, sizeof(zapisy[a].jest));
        f.WriteBuffer(zapisy[a].rodzajgry, sizeof(zapisy[a].rodzajgry));
        f.WriteBuffer(zapisy[a].data, sizeof(zapisy[a].data));
        for b := 0 to 5 do
          f.WriteBuffer(zapisy[a].poziomupgrade[b], sizeof(zapisy[a].poziomupgrade[b]));
        f.WriteBuffer(zapisy[a].pkt, sizeof(zapisy[a].pkt));
        f.WriteBuffer(zapisy[a].kasa, sizeof(zapisy[a].kasa));
        f.WriteBuffer(zapisy[a].planeta, sizeof(zapisy[a].planeta));
        zapiszstring(f, zapisy[a].epizod);
        f.WriteBuffer(zapisy[a].zycia, sizeof(zapisy[a].zycia));
      end;

      f.Free;
      f := nil;
    except
      if f <> nil then
      begin
        f.Free;
        f := nil;
      end;
      // MessageBox(Handle, pchar('B³¹d podczas zapisu pliku'#13#10+nazwa), 'B³¹d', MB_OK+MB_TASKMODAL+MB_ICONERROR);
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
procedure wczytajzapisy;
var
  a, b: integer;
  f: TStream;
begin
  for a := 0 to high(zapisy) do
    zapisy[a].jest := false;

  if fileexists('zapisy.sav') then
  begin
    f := nil;
    try
      try
        f := TFileStream.Create('zapisy.sav', fmOpenRead);

        for a := 0 to high(zapisy) do
        begin
          f.readBuffer(zapisy[a].jest, sizeof(zapisy[a].jest));
          f.readBuffer(zapisy[a].rodzajgry, sizeof(zapisy[a].rodzajgry));
          f.readBuffer(zapisy[a].data, sizeof(zapisy[a].data));
          for b := 0 to 5 do
            f.readBuffer(zapisy[a].poziomupgrade[b], sizeof(zapisy[a].poziomupgrade[b]));
          f.readBuffer(zapisy[a].pkt, sizeof(zapisy[a].pkt));
          f.readBuffer(zapisy[a].kasa, sizeof(zapisy[a].kasa));
          f.readBuffer(zapisy[a].planeta, sizeof(zapisy[a].planeta));
          zapisy[a].epizod := wczytajstring(f);
          f.readBuffer(zapisy[a].zycia, sizeof(zapisy[a].zycia));
        end;

        f.Free;
        f := nil;
      except
        if f <> nil then
        begin
          f.Free;
          f := nil;
        end;
        // MessageBox(Handle, pchar('B³¹d podczas zapisu pliku'#13#10+nazwa), 'B³¹d', MB_OK+MB_TASKMODAL+MB_ICONERROR);
      end;
    finally
      if f <> nil then
      begin
        f.Free;
        f := nil;
      end;
    end;
  end;

  // sprawdzenie, czy epizody z zapisanych gier istnieja
  for a := 0 to high(zapisy) do
    if (zapisy[a].jest) and (zapisy[a].rodzajgry = 2) then
    begin
      if length(epizody) >= 1 then
      begin
        b := 0;
        while (b <= high(epizody)) and (zapisy[a].epizod <> epizody[b].tytul) do
          inc(b);
        if b > high(epizody) then
          zapisy[a].jest := false;

      end
      else
        zapisy[a].jest := false;
    end;

end;

// ---------------------------------------------------------------------------
procedure wczytajgre(numer: integer);
var
  a, b: integer;
begin
  with zapisy[numer] do
  begin
    for a := 0 to 5 do
      gra.poziomupgrade[a] := poziomupgrade[a];
    gra.pkt := pkt;
    gra.kasa := kasa;
    gra.planeta := planeta - 1;
    gra.zycia := zycia;
    gra.jakiemisje := rodzajgry;
    if rodzajgry = 2 then
    begin
      b := 0;
      while (b <= high(epizody)) and (zapisy[numer].epizod <> epizody[b].tytul) do
        inc(b);
      if b <= high(epizody) then
      begin
        winieta.epizod := b;
        winieta.epizodmisja := gra.planeta;
      end
      else
        gra.jakiemisje := 0;

    end;
  end;
end;

// ---------------------------------------------------------------------------
procedure nowy_dym(sx, sy, sz, sdx, sdy, sdz: real; rozm: real; rodzaj: byte; szybprzezr_: real = 0.01);
var
  n: integer;
  r: real;
begin
  n := 0;
  while (n <= high(dym)) and (dym[n].jest) do
    inc(n);
  if n > high(dym) then
    n := random(length(dym));

  if n <= high(dym) then
    with dym[n] do
    begin
      jest := true;

      rozmiar := rozm;

      x := sx;
      y := sy;
      z := sz;
      dx := sdx;
      dy := sdy;
      dz := sdz;

      obrot := random * 360;

      szybprzezr := szybprzezr_;

      case rodzaj of
        0:
          begin // ogien
            tekstura := 2;
            przezr := 0.9 - random / 8;
            kolr := 1 - random / 9;
            kolg := 0.9 - random / 2;
            kolb := 0.3 + random / 5;
            rodz := 0;
          end;
        1:
          begin // dym
            tekstura := 2;
            przezr := 0.7 - random / 8;
            r := 0.4 - random * 0.4;
            kolr := r;
            kolg := r;
            kolb := r;
            rodz := 1;
          end;
        2:
          begin // taki, ktory robi ognie
            tekstura := 2;
            przezr := 0.9 - random / 8;
            kolr := 1 - random / 9;
            kolg := 0.9 - random / 2;
            kolb := 0.3 + random / 5;
            rodz := 2;
          end;
        3:
          begin // krew
            tekstura := 16;
            przezr := 1;
            kolr := 0.6;
            kolg := 0;
            kolb := 0;
            rodz := 3;
          end;
        4:
          begin // ziemia
            tekstura := 16;
            przezr := 0.7 - random / 8;
            r := 0.4 - random * 0.4;
            kolr := r;
            kolg := r;
            kolb := r;
            rodz := 1;
          end;
      end;

    end;
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
procedure strzel(sx, sy, sz, sdx, sdy, sdz: real; czyj: byte; rodz: byte = 0);
var
  n: integer;
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

// ---------------------------------------------------------------------------
function nowy_pilot(sx, sy, sz: real; czyzly: boolean = false; silapocz: real = 1; lotniskopocz: integer = -2;
  czasuciekaniaodgracza: integer = 0): integer;
var
  n: integer;
begin
  result := -1;
  n := 0;
  while (n <= high(pilot)) and (pilot[n].jest) do
    inc(n);
  if n <= high(pilot) then
    with pilot[n] do
    begin
      result := n;

      jest := true;

      x := sx;
      y := sy;
      z := sz;
      dy := 0;
      kier := random * 360;
      palisie := false;
      sila := silapocz;
      przewroc := 0;
      ani := random(360);
      rodzani := 0;
      stoi := false;

      uciekaodgracza := czasuciekaniaodgracza;
      rescued := false;

      miejscenamatce := -9999;

      zly := czyzly;
      if silapocz = 0 then
      begin
        dx := (random - 0.5 + gracz.dx);
        dz := (random - 0.5 + gracz.dy);
        dy := (random - 0.5 + gracz.dz);
        zawszewidac := true;
        nalotnisku := -2;
        palisie := true;
      end
      else
      begin
        dx := 0;
        dz := 0;
        zawszewidac := false;
        if lotniskopocz = -2 then
          nalotnisku := -1
        else
          nalotnisku := lotniskopocz;
      end;

    end;
end;

// ---------------------------------------------------------------------------
// zwraca pozycje Y terenu w pozycji X i Z na ekranie (wzgledem poczatku ukladu wsp.)
function gdzie_y(x, z, y: real): real;
var
  nx, nz: integer;
  rx, rz: real;
  ny1, ny2, ny11, ny22, nyz1, nyz2: real;
  nyy: real;

  dy1, dy2, dy3: real;

  nx_p1, nz_p1: integer;

begin
  if (y >= matka.y - 45) and (x >= matka.x - 530) and (x <= matka.x + 410) and
    (z >= matka.z - (x + matka.x + 530) / 2.52) and (z <= matka.z + (x + matka.x + 530) / 2.52) then
    result := matka.y
  else
  begin
    nx := trunc((x - ziemia.px) / ziemia.wlk);
    nz := trunc((z - ziemia.pz) / ziemia.wlk);

    // if (nx>=0) and (nz>=0) and (nx<=ziemia.wx-1) and (nz<=ziemia.wz-1) then begin
    rx := frac((x - ziemia.px) / ziemia.wlk);
    rz := frac((z - ziemia.pz) / ziemia.wlk);

    while nx < 0 do
      nx := nx + ziemia.wx;
    while nz < 0 do
      nz := nz + ziemia.wz;
    while nx >= ziemia.wx do
      nx := nx - ziemia.wx;
    while nz >= ziemia.wz do
      nz := nz - ziemia.wz;

    if (nz + 1 <= ziemia.wz - 1) then
      nz_p1 := nz + 1
    else
      nz_p1 := 0;
    if (nx + 1 <= ziemia.wx - 1) then
      nx_p1 := nx + 1
    else
      nx_p1 := 0;

    ny1 := ziemia.pk[nx, nz].p;
    ny11 := ziemia.pk[nx, nz_p1].p;

    ny2 := ziemia.pk[nx_p1, nz].p;
    ny22 := ziemia.pk[nx_p1, nz_p1].p;

    { nyy:= (ny1 *rx+    ny2 *(2-rx)+
      ny11*rz+    ny22*(2-rz))/4.0; }

    dy1 := ny11 - ny1;
    nyz1 := ny1 + dy1 * rz;

    dy2 := ny22 - ny2;
    nyz2 := ny2 + dy2 * rz;

    dy3 := nyz2 - nyz1;
    nyy := nyz1 + dy3 * rx;

    result := nyy;
    { end else
      result:=0; }
  end;

end;

// ---------------------------------------------------------------------------
// zwraca informacje czy podana pozycja jest nad matka czy nad zwykla ziemia
function czy_to_nad_matka(x, z, y: real): boolean;
var
  nx, nz: integer;
  rx, rz: real;
  ny1, ny2, ny11, ny22, nyz1, nyz2: real;
  nyy: real;

  dy1, dy2, dy3: real;

begin
  if (y >= matka.y - 45) and (x >= matka.x - 530) and (x <= matka.x + 410) and
    (z >= matka.z - (x + matka.x + 530) / 2.52) and (z <= matka.z + (x + matka.x + 530) / 2.52) then
    result := true
  else
  begin
    result := false;
  end;

end;

// ---------------------------------------------------------------------------
procedure xznasiatce(var x: integer; var z: integer; nx, nz: real);
begin
  x := trunc((nx - ziemia.px) / ziemia.wlk);
  z := trunc((nz - ziemia.pz) / ziemia.wlk);
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

// ---------------------------------------------------------------------------
procedure ruch_gracza;
var
  ilegrzeje: integer;
  s, moc: real;
  a, nx, nz, b: integer;

  k, k1, gx1, gz1, szybstrz: real;
  dzwiekognia: boolean;
  rodzpoc: byte;

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
      frmMain.graj_dzwiek(19, 0, 0, 0, false);
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
      if random(3) = 0 then
        gracz.sila := gracz.sila - 0.016;
      if gracz.y >= gdzie_y(gracz.x, gracz.z, gracz.y) + 8 then
      begin
        gracz.dx := gracz.dx + (random - 0.5) * 0.3;
        gracz.dz := gracz.dz + (random - 0.5) * 0.3;
        // gracz.dy:=gracz.dy+(random-0.1)*0.2;
        gracz.szybkier := gracz.szybkier + (random - 0.5) * 2.5;
      end;
    end;

    gracz.x := gracz.x + gracz.dx;
    gracz.y := gracz.y + gracz.dy;
    gracz.z := gracz.z + gracz.dz;

    if gracz.nacisk <> 0 then
    begin
      gracz.nacisk := gracz.nacisk * 0.96;
      // if gracz.nacisk<0 then gracz.nacisk:=0;
    end;
    { if gracz.nacisk<0 then begin
      gracz.nacisk:=gracz.nacisk+0.03;
      if gracz.nacisk>0 then gracz.nacisk:=0;
      end;
    }
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
      if gracz.y < matka.y - 120 then
      begin
        gracz.dx := gracz.dx + sin(wiatr.kier * pi180) * wiatr.sila;
        gracz.dz := gracz.dz - cos(wiatr.kier * pi180) * wiatr.sila;
      end;
      gracz.dy := gracz.dy - ziemia.grawitacja - gracz.pilotow * 0.0005;
    end;

    ilegrzeje := 0;
    // dopalacz do gory
    if (gracz.paliwo > 0) and ((frmMain.PwrInp.Keys[klawisze[2]]) or (frmMain.PwrInp.Keys[klawisze[3]]) or
      (gracz.zlywsrodku and (gracz.y < gdzie_y(gracz.x, gracz.z, gracz.y) + 350))) then
    begin
      if (frmMain.PwrInp.Keys[klawisze[3]]) then
      begin
        moc := 2;
        gracz.temp := gracz.temp + 1;
      end
      else
        moc := 1;
      frmMain.graj_dzwiek(2, gracz.x, gracz.y, gracz.z);
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
    if (gracz.paliwo > 0) and (frmMain.PwrInp.Keys[klawisze[4]]) then
    begin
      frmMain.graj_dzwiek(2, gracz.x, gracz.y, gracz.z);
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
    if (gracz.paliwo > 0) and ((frmMain.PwrInp.Keys[klawisze[5]]) or ((frmMain.PwrInp.Keys[klawisze[0]]) and
      (frmMain.PwrInp.Keys[klawisze[1]]))) then
    begin
      frmMain.graj_dzwiek(2, gracz.x, gracz.y, gracz.z);
      dzwiekognia := true;
      if (frmMain.PwrInp.Keys[klawisze[5]]) then
        moc := 1
      else
        moc := 0;
      if (frmMain.PwrInp.Keys[klawisze[0]]) then
        moc := moc + 0.3;
      if (frmMain.PwrInp.Keys[klawisze[1]]) then
        moc := moc + 0.3;
      gracz.szyb := gracz.szyb + 0.001 * moc;

      if gracz.szyb > 0.05 * moc then
        gracz.szyb := 0.05 * moc;

      if (frmMain.PwrInp.Keys[klawisze[5]]) then
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
    if (gracz.paliwo > 0) and (frmMain.PwrInp.Keys[klawisze[0]]) then
    begin
      frmMain.graj_dzwiek(2, gracz.x, gracz.y, gracz.z);
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
    if (gracz.paliwo > 0) and (frmMain.PwrInp.Keys[klawisze[1]]) then
    begin
      frmMain.graj_dzwiek(2, gracz.x, gracz.y, gracz.z);
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

    gracz.namatce := (gracz.y <= gdzie_y(gracz.x, gracz.z, gracz.y) + 5) and (gracz.y > matka.y - 75);

    s := sqrt2(sqr(gracz.dx) + sqr(gracz.dy) + sqr(gracz.dz));

    if (gracz.y < gdzie_y(gracz.x, gracz.z, gracz.y) + 5) or gracz.namatce then
    begin
      if abs(gracz.dy) > 0.01 then
        gracz.nacisk := gracz.nacisk + (gracz.y - (gdzie_y(gracz.x, gracz.z, gracz.y) + 5)) + gracz.dy * 0.5;
      while abs(gracz.nacisk) > 0.2 do
        gracz.nacisk := gracz.nacisk * 0.9;

      if gracz.y < gdzie_y(gracz.x, gracz.z, gracz.y) + 4.99 then
      begin
        gracz.y := gracz.y + 0.001;
        gracz.dy := gracz.dy * 0.8;
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
        or (sqrt2(sqr(gracz.dx) + sqr(gracz.dz)) > 0.1) or (gracz.dy < -0.17) or (abs(gracz.szybkier) > 0.4)

      then
      begin

        gracz.oslonablysk := maxoslonablysk;
        s := sqrt2(sqr(gracz.dx) + sqr(gracz.dz)) / 5 + abs(gracz.dy) / 3 + abs(gracz.szybkier) / 15;
        gracz.sila := gracz.sila - s;

        uszkodz(true, s * 2);

        if ((nx >= 0) and (nz >= 0) and (nx < ziemia.wx) and (nz < ziemia.wz)) and (ziemia.pk[nx, nz].rodzaj <> 1) then
        begin
          gracz.sila := gracz.sila - 0.2;
          uszkodz(true, 2);
        end;
        if (gracz.namatce and (gracz.y < matka.y - 10)) then
          gracz.dy := -abs(gracz.dy);

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

              frmMain.graj_dzwiek(16, gracz.x, gracz.y, gracz.z, false);
            end
            else if (gracz.pilotow > 0) then
            begin
              if (random(2) = 0) then
              begin
                dec(gracz.pilotow);
                nowy_pilot(gracz.x, gracz.y, gracz.z);

                frmMain.graj_dzwiek(13, gracz.x, gracz.y, gracz.z);
              end;
            end
            else if gracz.paliwo < gracz.maxpaliwa then
            begin
              gracz.paliwo := gracz.paliwo + 8;
              if gracz.paliwo > gracz.maxpaliwa then
                gracz.paliwo := gracz.maxpaliwa;

              frmMain.graj_dzwiek(16, gracz.x, gracz.y, gracz.z, false);
            end
            else if (gracz.ilerakiet < gracz.maxrakiet) then
            begin
              inc(gracz.ilerakiet, 2);
              if gracz.ilerakiet > gracz.maxrakiet then
                gracz.ilerakiet := gracz.maxrakiet;

              frmMain.graj_dzwiek(16, gracz.x, gracz.y, gracz.z, false);
            end
            else if (gracz.iledzialko < gracz.maxdzialko) then
            begin
              inc(gracz.iledzialko, 10);
              if gracz.iledzialko > gracz.maxdzialko then
                gracz.iledzialko := gracz.maxdzialko;

              frmMain.graj_dzwiek(16, gracz.x, gracz.y, gracz.z, false);
            end;
          end;
        end
        else if gracz.paliwo <= 0 then
          gracz.sila := gracz.sila - 0.02;

      end;

      if abs(gracz.dy) > 0.1 then
        frmMain.graj_dzwiek(4, gracz.x, gracz.y, gracz.z);

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
          frmMain.graj_dzwiek(4, gracz.x, gracz.y, gracz.z);
        uszkodz(false, s * 2);

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

    if ((frmMain.PwrInp.KeyPressed[klawisze[6]]) and (gracz.ilerakiet > 0)) or
      ((frmMain.PwrInp.Keys[klawisze[7]]) and (gracz.iledzialko > 0) and (licz mod 7 = 0)) then
    begin

      if (frmMain.PwrInp.KeyPressed[klawisze[6]]) and (gracz.ilerakiet > 0) then
        rodzpoc := 0
      else
        rodzpoc := 1;

      if rodzpoc = 0 then
        szybstrz := 4
      else
        szybstrz := 15; // dla rakiet = 4

      // FSOUND_PlaySoundEx(FSOUND_FREE, dzwieki[0], nil, False);
      if rodzpoc = 0 then
        frmMain.graj_dzwiek(0, gracz.x + sin((45 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu), gracz.y - 2,
          gracz.z - cos((45 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu))
      else
        frmMain.graj_dzwiek(20, gracz.x + sin((45 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu), gracz.y - 2,
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

          0, rodzpoc);

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

          -(sin(k * pi180) * cos(k1 * pi180)) * szybstrz, -sin(k1 * pi180) * szybstrz,
          -(-cos(k * pi180) * cos(k1 * pi180)) * szybstrz,

          0, rodzpoc);

      end
      else // strzel prosto
        strzel(gracz.x + sin((90 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu), gracz.y - 2,
          gracz.z - cos((90 + gracz.kier) * pi180) * (3 * gracz.stronastrzalu), sin(gracz.kier * pi180) * szybstrz +
          gracz.dx, -0.55 * szybstrz + gracz.dy, -cos(gracz.kier * pi180) * szybstrz + gracz.dz, 0, rodzpoc);

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
      frmMain.graj_dzwiek(5, gracz.x, gracz.y, gracz.z);
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
          nowy_pilot(gracz.x, gracz.y, gracz.z, false, 0);
      end;
      if gracz.zlychpilotow > 0 then
      begin
        for a := 1 to gracz.zlychpilotow do
          nowy_pilot(gracz.x, gracz.y, gracz.z, true, 0);
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
    if not gracz.namatce and (frmMain.PwrInp.KeyPressed[klawisze[17]]) and (gracz.pilotow > 0) then
    begin

{      dec(gra.kasa, 10);
      dec(gra.pkt, 110); // trzeba dawac tyle samo kasy i punktow!!!!!
      }
      dec(gracz.pilotow);

      if (gracz.grlot >= 0) then
      begin // zywy
        a := nowy_pilot(gracz.x, gracz.y, gracz.z, false, 1, gracz.grlot, 250);
        if a >= 0 then
        begin
          pilot[a].rescued := true;
        end;
      end
      else
      begin // martwy
        a := nowy_pilot(gracz.x, gracz.y, gracz.z, false, 0);
        if a >= 0 then
        begin
          frmMain.graj_dzwiek((22 + ord(pilot[a].zly) * 4 + random(4)), pilot[a].x, pilot[a].y, pilot[a].z);
          pilot[a].dy := -0.3 - random / 2;
          pilot[a].palisie := false;
          if pilot[a].zawszewidac and not pilot[a].zly then
            inc(gra.zginelo);
        end;
      end;

      frmMain.graj_dzwiek(13, gracz.x, gracz.y, gracz.z);
    end;

  end; // gracz

  if not dzwiekognia then
    frmMain.stop_dzwiek(2);
end;

// ---------------------------------------------------------------------------
procedure ruch_dymu;
var
  a, b: integer;
  s: real;
begin
  // dym

  for a := 0 to high(dym) do
    with dym[a] do
    begin
      if jest then
      begin
        x := x + dx;
        y := y + dy; // -0.3;
        z := z + dz;

        obrot := obrot + random / 2 + sqrt2(dx * dx + dy * dy + dz * dz);

        if gra.etap = 1 then
        begin
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
        end;

        // rozmiar:=rozmiar-0.1;

        if rodz = 0 then
        begin // ogien
          kolb := kolb - 0.03;
          if kolb < 0.05 then
            kolb := 0.05;
          if kolg > 0 then
          begin
            kolg := kolg - 0.031;
            if kolg < 0.07 then
              kolg := 0.07;
          end; // else
          if kolr > 0.2 then
          begin
            kolr := kolr - 0.02;
            if kolr < 0.13 then
              kolr := 0.13;
          end;
        end;

        if rodz in [0 .. 1, 4] then
        begin // ogien,dym
          przezr := przezr - szybprzezr;
          rozmiar := rozmiar + 0.06;
          if gra.etap = 1 then
          begin
            if (dy < 0) and (y <= gdzie_y(x, z, y)) then
            begin
              dy := abs(dy) / 5;
              dx := dx * 3;
              dz := dz * 3;
              while abs(dx) > 2 do
                dx := dx * 0.6;
              while abs(dz) > 2 do
                dz := dz * 0.6;

            end;
          end;
          if rodz = 4 then
            dy := dy - ziemia.grawitacja * 2;
        end
        else if rodz = 2 then
        begin // spawner ognia
          if random(3) = 0 then
            nowy_dym(x, y, z, (random - 0.5), (random - 0.5), (random - 0.5), 30 + random(10), 0, 0.005);
        end
        else if rodz = 3 then
        begin // krew
          if gra.etap = 1 then
          begin
            przezr := przezr - szybprzezr;
            rozmiar := rozmiar + 0.01;
            dy := dy - ziemia.grawitacja;
            if (dy < 0) and (y <= gdzie_y(x, z, y)) then
            begin
              jest := false;
            end;
          end
          else
            jest := false;
        end;

        if (rodz = 0) and (przezr > 0.4) and (random(20) = 0) then
        begin
          for b := 0 to high(pilot) do
            if pilot[b].jest and not pilot[b].palisie then
            begin
              s := sqrt2(sqr(pilot[b].x - x) + sqr(pilot[b].y - y) + sqr(pilot[b].z - z));
              if s <= rozmiar then
              begin
                if not pilot[b].palisie then
                  frmMain.graj_dzwiek((22 + ord(pilot[b].zly) * 4 + random(4)), pilot[b].x, pilot[b].y, pilot[b].z);
                pilot[b].palisie := true;
              end;
            end;
        end;

        if (przezr <= 0) then
        begin
          jest := false;
        end;
      end;
    end;

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
  if (nx >= 0) and (nz >= 0) and (nx < ziemia.wx) and (nz < ziemia.wz) and (not czy_to_nad_matka(x, z, y)) then
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
  s: real;
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
          if (nx >= 0) and (nz >= 0) and (nx < ziemia.wx) and (nz < ziemia.wz) and (not czy_to_nad_matka(x, z, y)) then
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

            if ustawienia.krzaki then
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
            frmMain.graj_dzwiek(1, x, y, z);
            nowe_swiatlo(x, y, z);
            for b := 0 to 9 do
            begin
              nowy_dym(x, y, z, (random - 0.5) / 3, (random) / 5, (random - 0.5) / 3, 5 + random * 10, 0,
                0.03 - random * 0.027);
            end;
          end
          else
          begin
            frmMain.graj_dzwiek(21, x, y, z);
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
                mysliwiec[b].sila := mysliwiec[b].sila - ((15 - s) / 3) / dzielsile;
                if mysliwiec[b].sila <= 0 then
                begin
                  // mysliwiec[b].sila:=0;
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

          for b := 0 to high(pilot) do
          begin
            if pilot[b].jest then
            begin
              s := sqrt2(sqr(pilot[b].x - x) + sqr(pilot[b].y - y) + sqr(pilot[b].z - z));
              if s <= 30 / ((dzielsile + 9) / 10) then
              begin

                if rodzaj = 0 then
                begin
                  pilot[b].sila := pilot[b].sila - ((30 - s) / 3);
                  pilot[b].dy := pilot[b].dy + ((30 - s) / 40);
                  pilot[b].dx := pilot[b].dx + (pilot[b].x - x) / 25;
                  pilot[b].dz := pilot[b].dz + (pilot[b].z - z) / 25;
                end
                else
                begin
                  pilot[b].sila := pilot[b].sila - ((30 - s) / 3) / 5;
                  pilot[b].dy := pilot[b].dy + ((30 - s) / 180);
                  pilot[b].dx := pilot[b].dx + (pilot[b].x - x) / 60;
                  pilot[b].dz := pilot[b].dz + (pilot[b].z - z) / 60;
                end;

                frmMain.graj_dzwiek((22 + ord(pilot[b].zly) * 4 + random(4)), pilot[b].x, pilot[b].y, pilot[b].z);
                if rodzaj = 0 then
                  pilot[b].palisie := true;
                if pilot[b].sila < 0 then
                  pilot[b].sila := 0;
              end;
            end;
          end;

          if gracz.zyje then
          begin
            s := sqrt2(sqr(gracz.x - x) + sqr(gracz.y - y) + sqr(gracz.z - z));
            if s <= 10 then
            begin
              zaiskrz;
              gracz.sila := gracz.sila - ((10 - s) / 4) / dzielsile;
              uszkodz(false, (((10 - s) / 4) / dzielsile) * 4);
              gracz.oslonablysk := maxoslonablysk;
              if gracz.sila < 0 then
                gracz.sila := 0;
              gracz.dx := gracz.dx + (dx / 3) / dzielsile;
              gracz.dy := gracz.dy + (dy / 3) / dzielsile;
              gracz.dz := gracz.dz + (dz / 3) / dzielsile;
            end;
          end;

          jest := false;
        end;

        s := sqrt2(sqr(gra.jestkamera[0, 0] - x) + sqr(gra.jestkamera[0, 1] - y) + sqr(gra.jestkamera[0, 2] - z));

        if s < 300 then
        begin
          if not dzw_slychac then
            dzw_kanal := frmMain.graj_dzwiek_kanal(18, x, y, z, _x, _y, _z, -1)
          else
            frmMain.graj_dzwiek_kanal(18, x, y, z, _x, _y, _z, dzw_kanal);
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
          frmMain.graj_dzwiek(4, x, y, z);
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
            dzw_kanal := frmMain.graj_dzwiek_kanal(17, x, y, z, _x, _y, _z, -1)
          else
            frmMain.graj_dzwiek_kanal(17, x, y, z, _x, _y, _z, dzw_kanal);
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

          if s <= 55 * szybkosc then
          begin
            if random(6) = 0 then
              atakuje := false
          end
          else if (s > 100 * szybkosc) and (s <= 1000) and (random(50) = 0) then
            atakuje := true;

          if (s > 1000) then
            atakuje := false;

          if s > 1500 then
            jest := false;

          if atakuje then
          begin // lec za graczem
            // przyspiesz
            if szybkosc < 0.9 + gra.planeta / 100 then
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

            if okstrzal and (s < 500 + gra.planeta) and (random(round(22 - gra.planeta / 7)) = 0) then
            begin

              strzel(x + (sin(kier * pi180) * cos(kierdol * pi180)) * 9, y - sin(kierdol * pi180) * 9,
                z + (-cos(kier * pi180) * cos(kierdol * pi180)) * 9, (sin(kier * pi180) * cos(kierdol * pi180)) *
                (15 + gra.planeta / 15) + (random - 0.5), -sin(kierdol * pi180) * (15 + gra.planeta / 15) +
                (random - 0.5), (-cos(kier * pi180) * cos(kierdol * pi180)) * (15 + gra.planeta / 15) +
                (random - 0.5), 1, 1);

              frmMain.graj_dzwiek(20, x, y, z);

            end;

          end;

          if s <= 10 then
          begin
            zniszczony := true; // zderzenie z graczem

            nowe_swiatlo(x, y, z);
            frmMain.graj_dzwiek(4, x, y, z);
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
          if szybkosc < 1 + gra.planeta / 100 then
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
          if kierdol < 90 then
          begin
            kierdol := kierdol + 1;
            if kierdol > 90 then
              kierdol := 90;
          end;

          obrot := obrot + szybkosc * 4;

        end;

        if wysadz then
        begin
          frmMain.graj_dzwiek(1, x, y, z);
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
procedure ruch_pilotow;
var
  a, nx, nz, k1, nk1: integer;
  k, s: real;
begin
  // piloci
  gra.pilotowbiegniedomatki := 0;

  gra.ilepilotow := 0;
  for a := 0 to high(pilot) do
    with pilot[a] do
    begin
      if jest then
      begin
        if not zly and (sila > 0) then
          inc(gra.ilepilotow);
        if nalotnisku = -1 then
          inc(gra.pilotowbiegniedomatki);

        // krew
        if (sila < 0.8) and (random(3 + round(sila * 10)) = 0) then
          nowy_dym(x + sin(kier * pi180) * sin(przewroc * pi180) * (1 + random),
            y + cos(przewroc * pi180) * (1 + random), z - cos(kier * pi180) * sin(przewroc * pi180) * (1 + random),
            (random - 0.5) * 0.1, (random - 0.3) * 0.1, (random - 0.5) * 0.1, 0.2 + random * 0.5, 3);

        x := x + dx;
        z := z + dz;
        y := y + dy;
        dx := dx * ziemia.gestoscpowietrza;
        dz := dz * ziemia.gestoscpowietrza;
        if y > gdzie_y(x, z, y) then
        begin
          if sila > 0 then
            dy := dy - ziemia.grawitacja * 3
          else
            dy := dy - ziemia.grawitacja;
        end;
        if (y < gdzie_y(x, z, y)) and (dy < 0) then
        begin
          if sila > 0 then
            dy := abs(dy / 2)
          else
          begin
            if abs(dy) > 0.1 then
              frmMain.graj_dzwiek(8, x, y, z);

            dy := abs(dy / 4);
          end;
        end;

        if uciekaodgracza > 0 then
          dec(uciekaodgracza);

        if palisie and (random(2) = 0) then
        begin
          // nowy_dym(x,y+1+random*2,z,
          nowy_dym(x + sin(kier * pi180) * sin(przewroc * pi180) * (1 + random * 1.5),
            y + cos(przewroc * pi180) * (1 + random * 1.5), z - cos(kier * pi180) * sin(przewroc * pi180) *
            (1 + random * 1.5), (random - 0.5) / 8, 0.1 + random / 6, (random - 0.5) / 8, 0.4 + random / 2, 0, 0.05);

          sila := sila - 0.008;
          if sila < 0 then
            sila := 0;
        end;

        if (sila > 0) and (przewroc = 0) then
        begin
          if not stoi then
          begin
            ani := ani + 6 + random(3);
            if ani >= 360 then
              dec(ani, 360);
            rodzani := 0;
          end
          else
          begin
            s := sqrt2(sqr(gracz.x - x) + sqr(gracz.y - y) + sqr(gracz.z - z));
            if (s >= 100) and (s <= 300) then
            begin
              if rodzani = 1 then
              begin
                ani := ani + 6 + random(3);
                if (random(20) = 0) and (y <= gdzie_y(x, z, y)) then
                begin
                  dy := 0.1 + random * 0.04;
                  y := gdzie_y(x, z, y);
                end;
                if ani >= 360 then
                begin
                  if random(2) = 0 then
                  begin
                    ani := 0;
                    rodzani := 0;
                  end
                  else
                    dec(ani, 360);
                end;
              end
              else
              begin
                ani := 0;
                if random(50) = 0 then
                  rodzani := 1;
              end;
            end
            else
            begin
              if ani > 0 then
              begin
                ani := ani + 6 + random(3);
                if ani >= 360 then
                  ani := 0;
                rodzani := 0;
              end;
            end;
          end;
        end; // else ani:=0;

        stoi := true;

        if not palisie and (sila > 0) then
        begin
          if nalotnisku >= 0 then
          begin // na ziemi
            s := sqrt2(sqr(gracz.x - x) + sqr(gracz.y - y) + sqr(gracz.z - z));
            if ((not gracz.stoi) or (uciekaodgracza > 0) or ((gracz.pilotow >= gracz.ladownosc) and (not zly))) and
              (s < 100) then
            begin // uciekaja
              if s < 93 then
                k := (180 + jaki_to_kat(gracz.x - x, gracz.z - z))
              else
                k := (jaki_to_kat(gracz.x - x, gracz.z - z));
              if k > 360 then
                k := k - 360;

              if (k <> kier) then
              begin
                k1 := (round(kier - k) + 360) mod 360;
                if (k1 <= 180) then
                begin
                  kier := kier - 2;
                  nk1 := (round(kier - k) + 360) mod 360;
                  if (nk1 > 180) then
                    kier := k;
                end
                else
                begin
                  if (k1 > 180) then
                    kier := kier + 2;
                  nk1 := (round(kier - k) + 360) mod 360;
                  if (nk1 <= 180) then
                    kier := k;
                end;
              end;

              if (kier >= 360) then
                kier := kier - 360
              else if (kier < 0) then
                kier := kier + 360;

              if s < 93 then
              begin
                if gdzie_y(x + sin(kier * pi180) / 3, z - cos(kier * pi180) / 3, y) < gdzie_y(x, z, y) + 0.25 then
                begin
                  x := x + sin(kier * pi180) / (2 + random * 3);
                  z := z - cos(kier * pi180) / (2 + random * 3);
                  stoi := false;
                end;
              end
              else
              begin
                ani := ani + 1;
                rodzani := 1;
              end;
              if y <= gdzie_y(x, z, y) then
              begin
                dy := 0.1 + random * 0.04;//0.13
                y := gdzie_y(x, z, y);
              end;
            end;


            if gracz.stoi and (gracz.grlot = nalotnisku) and ((gracz.pilotow < gracz.ladownosc) or (zly)) and
              (uciekaodgracza <= 0) then
            begin // biegna do gracza
              if (gracz.zyje) and (s < 7) then
              begin
                jest := false;
                if not zly then
                begin
                  inc(gracz.pilotow);
                  if not rescued then
                  begin
                    rescued := true;
                    inc(gra.kasa, 10);
                    // uwaga! jesli by to sie zmienilo, to przy wyrzucaniu pilotow
                    inc(gra.pkt, 110);
                    // trzeba bedzie odbierac tyle samo kasy i punktow!!!!!
                    gracz.paliwo := gracz.paliwo + 8;
                    if gracz.paliwo > gracz.maxpaliwa then
                      gracz.paliwo := gracz.maxpaliwa;
                  end;
                end
                else
                  inc(gracz.zlychpilotow);
                if zly then
                  gracz.zlywsrodku := true;
                frmMain.graj_dzwiek(13, x, y, z);
              end;
              k := (jaki_to_kat(gracz.x - x, gracz.z - z));

              if (k <> kier) then
              begin
                k1 := (round(kier - k) + 360) mod 360;
                if (k1 <= 180) then
                begin
                  kier := kier - 2;
                  nk1 := (round(kier - k) + 360) mod 360;
                  if (nk1 > 180) then
                    kier := k;
                end
                else
                begin
                  if (k1 > 180) then
                    kier := kier + 2;
                  nk1 := (round(kier - k) + 360) mod 360;
                  if (nk1 <= 180) then
                    kier := k;
                end;
              end;

              if (kier >= 360) then
                kier := kier - 360
              else if (kier < 0) then
                kier := kier + 360;

              x := x + sin(kier * pi180) / (2 + random * 3);
              z := z - cos(kier * pi180) / (2 + random * 3);
              stoi := false;
              if y <= gdzie_y(x, z, y) then
              begin
                dy := 0.11 + random * 0.04;
                y := gdzie_y(x, z, y);
              end;
            end;
          end
          else
          begin // na matce
            if miejscenamatce < -999 then
              miejscenamatce := random * 40 - 20;

            k := (jaki_to_kat(matka.cx - x, matka.cz - z + miejscenamatce));

            if (k <> kier) then
            begin
              k1 := (round(kier - k) + 360) mod 360;
              if (k1 <= 180) then
              begin
                kier := kier - 2;
                nk1 := (round(kier - k) + 360) mod 360;
                if (nk1 > 180) then
                  kier := k;
              end
              else
              begin
                if (k1 > 180) then
                  kier := kier + 2;
                nk1 := (round(kier - k) + 360) mod 360;
                if (nk1 <= 180) then
                  kier := k;
              end;
            end;

            if (kier >= 360) then
              kier := kier - 360
            else if (kier < 0) then
              kier := kier + 360;

            stoi := false;
            x := x + sin(kier * pi180) / (2 + random * 3);
            z := z - cos(kier * pi180) / (2 + random * 3);
            if y <= gdzie_y(x, z, y) then
            begin
              dy := 0.13;
              y := gdzie_y(x, z, y);
            end;

            // wsiadaja do matki
            if (sila > 0) and (sqrt2(sqr(matka.cx - x) + sqr(matka.y - y) + sqr(matka.cz - z + miejscenamatce)) < 10)
            then
            begin
              jest := false;
              inc(gra.zabranych);
              inc(gra.kasa, 15);
              inc(gra.pkt, 200);
            end;
          end;
        end
        else
        begin // palisie lub umiera (sila<0)
          stoi := false;
          if (przewroc = 0) and ((random(250) = 0) or (sila <= 0)) then
            przewroc := 1;
          if (przewroc > 0) and (przewroc < 90) then
          begin
            przewroc := przewroc + 1 + random * 3;
            if przewroc > 90 then
              przewroc := 90;
          end;
          if sila > 0 then
          begin // zywy
            if przewroc = 0 then
            begin
              kier := kier - 10 + random * 20;
              if (kier >= 360) then
                kier := kier - 360
              else if (kier < 0) then
                kier := kier + 360;
            end;
            if przewroc < 90 then
            begin
              x := x + sin(kier * pi180) / (3 + przewroc + random);
              z := z - cos(kier * pi180) / (3 + przewroc + random);
              stoi := false;
            end;
            if y <= gdzie_y(x, z, y) then
            begin
              if przewroc = 0 then
                dy := 0.13;
              if y > gdzie_y(x, z, y) - 15 then
                y := gdzie_y(x, z, y);
            end;
          end
          else
          begin // martwy
            if y > gdzie_y(x, z, y) then
            begin // ponad ziemia
              rodzani := 0;
              ani := ani - round(5 * (0.5 + sqrt2(sqr(dx) + sqr(dy) + sqr(dz))));
              if ani < 0 then
                inc(ani, 360);
              kier := kier + 2 * sqrt2(sqr(dx) + sqr(dy) + sqr(dz));
              if kier >= 360 then
                kier := kier - 360;
            end
            else
            begin // pod ziemia lub na niej
              if (abs(dy) < 0.005) and (abs(dx) < 0.005) and (abs(dz) < 0.005) and (przewroc >= 90) then
              begin
                dy := 0;
                y := y - 0.07;
                if y < gdzie_y(x, z, y) - 7 then
                begin
                  jest := false;
                  if zly then
                  begin
                    inc(gra.kasa, 5);
                    inc(gra.pkt, 25);
                  end;
                  if not zawszewidac and not zly then
                    inc(gra.zginelo);
                end;
              end;
            end;
          end;
        end;

      end;
    end;
end;

// ---------------------------------------------------------------------------
procedure ruch_dzialek;
const
  ciemno: array [0 .. 4] of record x, z: integer end = ((x: 0; z: 0), (x: 1; z: 0), (x: 0; z: 1), (x: - 1; z: 0),
    (x: 0; z: - 1));
var
  a, b, grlot, nx, nz, k1, nk1: integer;
  k, k2, s, s1, gx1, gz1: real;
  ok: boolean;
  szybruch: real;
begin
  gra.iledzialek := 0;
  gracz.namierzone := -1;
  gracz.odlegloscnamierzonegodzialka := 999999;
  szybruch := 0.8 + gra.planeta / 100;
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
              if s <= 500 + gra.planeta * 2 then
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
                if not namierza and (random(80 - round(gra.planeta * 0.7)) = 0) then
                  namierza := true;
                if namierza then
                begin
                  ok := true;
                  if rodzaj = 0 then
                  begin
                    s1 := 3 + gra.planeta / 30; // sila z jaka strzeli
                    s := sqrt2(sqr(x - gx1) + sqr(y - gracz.y) + sqr(z - gz1)) / (1.15 * s1); // odleglosc
                  end
                  else
                  begin
                    s := 0.1;
                    s1 := 15 + gra.planeta / 30; // sila z jaka strzeli
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

                  if ok and (((rodzaj = 0) and (random(round(300 - gra.planeta * 2.5)) = 0)) or
                    ((rodzaj = 1) and (random(round(70 - gra.planeta * 0.6)) = 0))) then
                  begin
                    if rodzaj = 0 then
                    begin
                      strzel(x + (sin(kier * pi180) * cos(kat * pi180)) * 9, y + sin(kat * pi180) * 9,
                        z + (-cos(kier * pi180) * cos(kat * pi180)) * 9, (sin(kier * pi180) * cos(kat * pi180)) * s1 +
                        (random - 0.5) / 3, sin(kat * pi180) * s1 + (random - 0.5) / 3,
                        (-cos(kier * pi180) * cos(kat * pi180)) * s1 + (random - 0.5) / 3, 1);

                      frmMain.graj_dzwiek(6, x, y, z);
                    end
                    else
                    begin
                      strzel(x + (sin(kier * pi180) * cos(kat * pi180)) * 9, y + sin(kat * pi180) * 9,
                        z + (-cos(kier * pi180) * cos(kat * pi180)) * 9, (sin(kier * pi180) * cos(kat * pi180)) * s1 +
                        (random - 0.5) / 3, sin(kat * pi180) * s1 + (random - 0.5) / 3,
                        (-cos(kier * pi180) * cos(kat * pi180)) * s1 + (random - 0.5) / 3, 1, 1);

                      frmMain.graj_dzwiek(20, x, y, z);

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

        if licz mod 2 = 0 then
        begin
          dx := dx * ziemia.gestoscpowietrza;
          dz := dz * ziemia.gestoscpowietrza;
        end;
        dy := dy - ziemia.grawitacja * 2;

        if { (dy>0) and } (y >= matka.y - 25) and (y <= matka.y - 75) then
        begin
          if abs(dy) > 0.16 then
            frmMain.graj_dzwiek(7, x, y, z);
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
                frmMain.graj_dzwiek(7, x, y, z);
              1:
                frmMain.graj_dzwiek(3, x, y, z);
            end;
          end;
          dy := abs(dy) / 2;
          dx := dx * 0.8;
          dz := dz * 0.8;
          if abs(dy) < 0.01 then
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
          dx := dx + sin(wiatr.kier * pi180) * wiatr.sila / 2;
          dz := dz - cos(wiatr.kier * pi180) * wiatr.sila / 2;
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
begin
  // matka
  if gra.etap = 1 then
  begin
    if gracz.y > matka.y - 250 then
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
      20.1 + random * 10, 0, 0.02);
    nowy_dym(matka.x + 400, matka.y - 20, matka.z + 205, 10 + random * 4, (random - 0.5) / 20, (random - 0.5) / 20,
      20.1 + random * 10, 0, 0.02);
  end;
end;

// ---------------------------------------------------------------------------
procedure ustaw_kolor_tla;
var
  a: integer;
begin
  for a := 0 to 2 do
  begin
    if gracz.y > matka.y - 250 then
    begin
      ziemia.jestkoltla[a] := ziemia.koltla[a] * ((matka.y - gracz.y) / 250);
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
  if (length(ladowiska) = 0) or (length(pilot) = 0) or (not gracz.zyje) or (gracz.y >= matka.y) then
    exit;

  for a := 0 to high(ladowiska) do
  begin
    b := 0;
    while (b <= high(pilot)) and ((not pilot[b].jest) or (pilot[b].zly) or (pilot[b].nalotnisku <> a)) do
      inc(b);

    if b <= high(pilot) then
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
        strzel(x1, gdzie_y(x1, z1, 0) + 10, z1, random - 0.5, 1.3 + random, random - 0.5, 0, 2);

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
        gra.jestkamera[1, 1] := gracz.dy * 1 + gracz.y - 1{ + gracz.dy * 1};
        gra.jestkamera[1, 2] := gracz.dz * 1 + gracz.z - cos((gracz.kier) * pi180) * 10;

//        gra.jestkamera[0, 0] := gracz.dx * 0.8 + gracz.x + sin((gracz.kier) * pi180);
//        gra.jestkamera[0, 1] := {gracz.dy * 0.8 + }gracz.y + 3;
//        gra.jestkamera[0, 2] := gracz.dz * 0.8 + gracz.z - cos((gracz.kier) * pi180);
//        gra.jestkamera[1, 0] := gracz.dx * 0.8 + gracz.x + sin((gracz.kier) * pi180) * 10;
//        gra.jestkamera[1, 1] := {gracz.dy * 0.8 + }gracz.y{ + gracz.dy * 1};
//        gra.jestkamera[1, 2] := gracz.dz * 0.8 + gracz.z - cos((gracz.kier) * pi180) * 10;
        {gra.jestkamera[2, 0] := gracz.dx / 6;
        gra.jestkamera[2, 1] := 1;
        gra.jestkamera[2, 2] := gracz.dz / 6;}

        kx := gracz.dx / 6;
        ky := 1;
        kz := gracz.dz / 6;
        normalize3D(kx, ky, kz);

        gra.kamera[2, 0] := kx;
        gra.kamera[2, 1] := ky;
        gra.kamera[2, 2] := kz;

        { glRotatef(gracz.dz*6, gracz.wykrecsila,0,0);
          glRotatef(-gracz.dx*6, 0,0,gracz.wykrecsila);
          glRotatef(gracz.kier,0,-1,0);
          glRotatef(180,0,1,0); }

      end;
  end;
  c := gdzie_y(gra.kamera[0, 0], gra.kamera[0, 2], gra.kamera[0, 1]) + 3;
  if gra.kamera[0, 1] < c then
    gra.kamera[0, 1] := c;

  if gracz.zyje then
  begin // alarmy!
    if (gracz.paliwo > 0) and (gracz.paliwo < 40) and (licz mod 50 = 0) then
      frmMain.graj_dzwiek(9, 0, 0, 0, false);

    if (gracz.temp >= 240) and (licz mod 20 = 0) then
      frmMain.graj_dzwiek(14, 0, 0, 0, false);

    if (gracz.zlywsrodku) and (licz mod 20 = 0) then
      frmMain.graj_dzwiek(15, 0, 0, 0, false);
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

  if frmMain.PwrInp.Keys[klawisze[9]] then
    kamera := 0;
  if frmMain.PwrInp.Keys[klawisze[10]] then
    kamera := 1;
  if frmMain.PwrInp.Keys[klawisze[11]] then
    kamera := 2;
  if frmMain.PwrInp.Keys[klawisze[12]] then
    kamera := 3;
  if frmMain.PwrInp.Keys[klawisze[13]] then
    kamera := 4;
  if frmMain.PwrInp.Keys[klawisze[14]] then
    kamera := 5;
  if frmMain.PwrInp.Keys[klawisze[15]] then
    kamera := 6;
  if frmMain.PwrInp.Keys[klawisze[16]] then
    kamera := 7;

  sprawdzaj_cheat_codes;

  wiatr.kier := wiatr.kier + (random - 0.5);

  ustaw_kolor_tla;

  if gracz.y > matka.y - 250 then
  begin
    ziemia.widac := (matka.y - gracz.y) / 250;
  end
  else
    ziemia.widac := 1;
  if ziemia.widac < 0 then
    ziemia.widac := 0;
  if ziemia.widac > 1 then
    ziemia.widac := 1;
  matka.widac := 1 - ziemia.widac;

  ziemia.chmuryx := ziemia.chmuryx - sin(wiatr.kier * pi180) * (wiatr.sila / 8);
  ziemia.chmuryz := ziemia.chmuryz - cos(wiatr.kier * pi180) * (wiatr.sila / 8);

  glFogfv(GL_FOG_COLOR, @ziemia.jestkoltla);
  glClearColor(ziemia.jestkoltla[0], ziemia.jestkoltla[1], ziemia.jestkoltla[2], ziemia.jestkoltla[3]);


  // mysliwce

  if (gracz.y <= matka.y - 150) and (gra.iledzialek > 0) and (random(1100) = 0) then
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
      b := 1 + random(gra.planeta div 21);
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
    end;

  /// /////*****
  { gra.misjawypelniona:=true;
    gra.moznakonczyc:=true; }
  /// /////*****

  // misja wypelniona
  if (gra.moznakonczyc and ((gracz.stoi and gracz.namatce) or (not gracz.zyje))) and (frmMain.PwrInp.Keys[klawisze[8]]) or
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
      end;
      inc(gra.kasa, gra.czas);
      inc(gra.pkt, gra.czas * 4);
    end;

    frmMain.TimerCzas.Enabled := false;

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
  if gra.koniecgry and (frmMain.PwrInp.KeyPressed[DIK_space]) then
  begin
    zatrzymaj_dzwieki_ciagle;
    winieta.jest := true;
    winieta.corobi := 0;
    winieta.skrol := 0;
    FSOUND_SetPaused(muzchannel, true);
    frmMain.muzyke_wlacz(1, true);
  end;
end;

// ---------------------------------------------------------------------------
procedure ruch_intro;
var
  a, b: integer;
begin
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
    // frmMain.graj_dzwiek(10,0,0,0,false);
    frmMain.muzyke_wlacz(2, false);
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
        ziemia.jestkoltla[0] := 0;
        ziemia.jestkoltla[1] := 0;
        ziemia.jestkoltla[2] := 0;
        glFogfv(GL_FOG_COLOR, @ziemia.jestkoltla);
        glClearColor(ziemia.jestkoltla[0], ziemia.jestkoltla[1], ziemia.jestkoltla[2], ziemia.jestkoltla[3]);
        if intro.czas2 = 0 then
        begin
          for a := 0 to high(dym) do
            dym[a].jest := false;
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

    // frmMain.stop_dzwiek(10);
    frmMain.muzyke_wylacz;

    frmMain.TimerCzas.Enabled := true;
    frmMain.muzyke_wlacz(0, true);
    FSOUND_SetPaused(muzchannel, false);
    FSOUND_Stream_SetTime(muzstream, 0);
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
    for a := 0 to high(dym) do
      dym[a].jest := false;
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
    if gra.misjawypelniona then // frmMain.graj_dzwiek(11,0,0,0,false)
      frmMain.muzyke_wlacz(4, false)
    else // frmMain.graj_dzwiek(12,0,0,0,false);
      frmMain.muzyke_wlacz(3, false);
  end;

  inc(intro.czas);

  inc(intro.czas2);

  if (intro.czas = 400) or (intro.czas = 600) or (intro.czas = 1300) then
  begin
    inc(intro.scena);
    intro.czas2 := 0;
  end;

  case intro.scena of
    0:
      begin
        ustaw_kolor_tla;
        matka.x := matka.x - intro.czas2 / 50;
      end;
    1:
      begin
        ziemia.jestkoltla[0] := 0;
        ziemia.jestkoltla[1] := 0;
        ziemia.jestkoltla[2] := 0;
        glFogfv(GL_FOG_COLOR, @ziemia.jestkoltla);
        glClearColor(ziemia.jestkoltla[0], ziemia.jestkoltla[1], ziemia.jestkoltla[2], ziemia.jestkoltla[3]);
        if intro.czas2 = 0 then
        begin
          for a := 0 to high(dym) do
            dym[a].jest := false;
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
          for a := 0 to high(dym) do
            dym[a].jest := false;
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
    { if gra.misjawypelniona then frmMain.stop_dzwiek(11)
      else frmMain.stop_dzwiek(12); }
    frmMain.muzyke_wylacz;
    if gra.misjawypelniona and (gra.zycia >= 1) then
    begin
      // wejdz do zapisu po wygranej
      winieta.jest := true;
      frmMain.muzyke_wlacz(1, true);
      winieta.corobi := 1;
    end
    else
    begin
      // wejdz do zapisu po przegranej i wznow niewypelniona misje
      winieta.jest := true;
      frmMain.muzyke_wlacz(1, true);
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
  case winieta.corobi of
    0:
      begin // winieta
        inc(winieta.skrol);
        if winieta.skrol >= length(titleScrollLines) * 15 * 3 + 930 {2550} then
          winieta.skrol := 0;

        if frmMain.PwrInp.KeyPressed[DIK_DOWN] then
        begin
          inc(winieta.kursor);
          frmMain.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if frmMain.PwrInp.KeyPressed[DIK_UP] then
        begin
          dec(winieta.kursor);
          frmMain.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if winieta.kursor < 0 then
          winieta.kursor := 4;
        if winieta.kursor > 4 then
          winieta.kursor := 0;

        case winieta.kursor of
          0:
            begin
              if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
              begin
                winieta.jest := false;
                frmMain.muzyke_wylacz;
                nowa_gra(-1, 0);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
              begin
                inc(winieta.planetapocz);
                if winieta.planetapocz > 99 then
                  winieta.planetapocz := 1;
                frmMain.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
              begin
                dec(winieta.planetapocz);
                if winieta.planetapocz < 1 then
                  winieta.planetapocz := 99;
                frmMain.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGDN] then
              begin
                inc(winieta.planetapocz, 10);
                if winieta.planetapocz > 99 then
                  dec(winieta.planetapocz, 99);
                frmMain.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGUP] then
              begin
                dec(winieta.planetapocz, 10);
                if winieta.planetapocz < 1 then
                  inc(winieta.planetapocz, 99);
                frmMain.graj_dzwiek(16, 0, 0, 0, false);
              end;
            end;
          1:
            begin
              if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
              begin
                winieta.jest := false;
                frmMain.muzyke_wylacz;
                nowa_gra(-1, 1);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_RIGHT] then
              begin
                inc(winieta.poziomtrudnosci);
                if winieta.poziomtrudnosci > 99 then
                  winieta.poziomtrudnosci := 1;
                frmMain.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_LEFT] then
              begin
                dec(winieta.poziomtrudnosci);
                if winieta.poziomtrudnosci < 1 then
                  winieta.poziomtrudnosci := 99;
                frmMain.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGDN] then
              begin
                inc(winieta.poziomtrudnosci, 10);
                if winieta.poziomtrudnosci > 99 then
                  dec(winieta.poziomtrudnosci, 99);
                frmMain.graj_dzwiek(16, 0, 0, 0, false);
              end;
              if frmMain.PwrInp.KeyPressed[DIK_PGUP] then
              begin
                dec(winieta.poziomtrudnosci, 10);
                if winieta.poziomtrudnosci < 1 then
                  inc(winieta.poziomtrudnosci, 99);
                frmMain.graj_dzwiek(16, 0, 0, 0, false);
              end;
            end;
          2:
            if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
            begin
              winieta.corobi := 4;
              winieta.kursor := 0;
            end;
          3:
            if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
            begin
              winieta.corobi := 3;
              winieta.kursor := 0;
            end;
          4:
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
          frmMain.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if frmMain.PwrInp.KeyPressed[DIK_UP] then
        begin
          dec(winieta.kursor);
          frmMain.graj_dzwiek(16, 0, 0, 0, false);
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
                    frmMain.muzyke_wylacz;
                    nowa_gra(winieta.kursor, 0);
                  end;
                end;
              end;
            end;
          10:
            if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
            begin
              winieta.kursor := 0;
              if winieta.corobi = 1 then
                winieta.corobi := 2
              else
              begin
                winieta.corobi := 0;
                winieta.skrol := 0;
              end;
            end;
        end;
      end;
    2:
      begin // sklep
        if frmMain.PwrInp.KeyPressed[DIK_DOWN] then
        begin
          inc(winieta.kursor);
          frmMain.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if frmMain.PwrInp.KeyPressed[DIK_UP] then
        begin
          dec(winieta.kursor);
          frmMain.graj_dzwiek(16, 0, 0, 0, false);
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
          7:
            if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) then
            begin
              if gra.jakiemisje <> 2 then
              begin
                winieta.jest := false;
                frmMain.muzyke_wylacz;
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
                  frmMain.muzyke_wylacz;
                  winieta.kursor := 0;
                  nowy_teren(epizody[winieta.epizod].misje[winieta.epizodmisja]);
                end;
              end;
            end;
        end;
      end;
    4:
      begin // wybor epizodu
        if frmMain.PwrInp.KeyPressed[DIK_DOWN] then
        begin
          inc(winieta.epizod);
          frmMain.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if frmMain.PwrInp.KeyPressed[DIK_UP] then
        begin
          dec(winieta.epizod);
          frmMain.graj_dzwiek(16, 0, 0, 0, false);
        end;
        if winieta.epizod < 0 then
          winieta.epizod := high(epizody);
        if winieta.epizod > high(epizody) then
          winieta.epizod := 0;

        if (frmMain.PwrInp.KeyPressed[DIK_space]) or (frmMain.PwrInp.KeyPressed[DIK_RETURN]) and (length(epizody) >= 1) then
        begin
          winieta.jest := false;
          frmMain.muzyke_wylacz;
          if not gra.koniecgry then
          begin
            winieta.jest := false;
            frmMain.muzyke_wylacz;
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
        end;

      end;

  end;

end;

// ---------------------------------------------------------------------------
procedure ruch_glowneintro;
var
  a, b: integer;
begin

  if glowneintro.czas = 0 then
  begin
    // frmMain.graj_dzwiek(10,0,0,0,false);
  end;

  inc(glowneintro.czas);
  inc(glowneintro.czas2);

  if (glowneintro.czas = 200) or (glowneintro.czas = 500) or (glowneintro.czas = 800) or (glowneintro.czas = 1100) or
    (glowneintro.czas = 1400) or (glowneintro.czas = 1600) // koniec
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

  if not glowneintro.jest then
  begin
    inc(licz);
    if not winieta.jest then
    begin
      case gra.etap of
        0:
          begin // intro
            ruch_dymu;
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
              ruch_pilotow;
              ruch_dzialek;
              ruch_dymu;
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
                frmMain.muzyke_wlacz(1, true);
                winieta.corobi := 0;
                winieta.skrol := 0;
                // FSOUND_SetPaused(muzchannel, true);
              end;
            end;
          end;
        2:
          begin // outro
            ruch_dymu;
            ruch_matki;
            ruch_outro;
          end;
      end;

      // tymczasowo
      // if frmMain.PwrInp.Keys[DIK_F1] then nowa_gra;
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

// ---------------------------------------------------------------------------
procedure zapiszstring(var plik: TStream; t: string);
var
  buf: shortstring;
  d: word;
  m, l: longint;
  bufa: array [0 .. 254] of byte;
begin
{$I-}
  if t = '' then
    t := #1#2;
  l := length(t);
  plik.WriteBuffer(l, sizeof(l));
  m := 1;
  while m <= length(t) do
  begin
    if length(t) - (m - 1) > 255 then
      d := 255
    else
      d := length(t) - (m - 1);
    buf := copy(t, m, d);
    move(buf[1], bufa, d);
    plik.WriteBuffer(bufa, d);
    inc(m, d);
  end;
end;

function wczytajstring(var plik: TStream): string;
var
  buf: shortstring;
  bufa: array [0 .. 254] of byte;
  d: word;
  d1: byte;
  m, dl: longint;
  t: string;
begin
  plik.readBuffer(dl, sizeof(dl)); { length(t):=dl }
  m := 1;
  t := '';
  while m <= dl do
  begin
    if dl - (m - 1) > 255 then
      d := 255
    else
      d := dl - (m - 1);
    plik.readBuffer(bufa, d);
    move(bufa, buf[1], d);
    d1 := d;
    buf[0] := ansichar(d1);

    t := t + copy(buf, 1, d);
    inc(m, d);
  end;
  if t = #1#2 then
    t := '';
  wczytajstring := t;
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
      nazwa := 'misje/' + nazwa + '.map';
    1:
      nazwa := 'dane/' + nazwa + '.dmp';
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

      setlength(pilot, 0);
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
          setlength(pilot, length(pilot) + ladowiska[a].pilotow);
          for b := high(pilot) downto high(pilot) - ladowiska[a].pilotow + 1 do
            pilot[b].nalotnisku := a;
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
  end;

end;

// ---------------------------------------------------------------------------
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

  dsz, sz, dtz, tz, sw: real;
  c, _s, _t: integer;
  najwyzszy, najnizszy, koldziel: real;
  rodzaj_gor: integer;

begin
  gra.rodzajmisji := gra.planeta mod 2;

  ziemia.wx := 154;
  ziemia.wz := 154;
  ziemia.wlk := 30;

  ziemia.px := -(ziemia.wx / 2) * ziemia.wlk; // *
  ziemia.pz := -(ziemia.wz / 2) * ziemia.wlk;

  if gra.jakiemisje = 0 then
    RandSeed := gra.planeta + 9000
  else
    randomize;

  if random(100) * random(100) < 500 then
    rodzaj_gor := 0
    // random(100)<50 zamiast random(2), bo za czesto mi losowalo 1 i byly ciagle jednego rodzaju tereny
  else
    rodzaj_gor := 1;

  a := round(20 + (random * 2 - 0.6) * ((10 + gra.planeta) / 4.5)); // 25
  ziemia.grawitacja := a / 10000;

  a := round(20 + (random * 1.7 - 0.6) * ((10 + gra.planeta) / 4.5)); // 17
  ziemia.gestoscpowietrza := (1000 - a) / 1000;

  { ziemia.gestoscpowietrza:=0.980;//0.9995-random/21;
    ziemia.grawitacja:=0.002;//0.002+(random/1000)*4; }
  matka.y := 900;

  wiatr.sila := 0.001 + (random / 1000) * 3; // 0.003

  // ustawienie rozmiaru ziemi: przy wczytywaniu jest to w funkcji wczytujacej
  setlength(ziemia.pk, ziemia.wx);
  for a := 0 to high(ziemia.pk) do
    setlength(ziemia.pk[a], ziemia.wz);

  // decyzja jakie beda kolory
  for b := 0 to 2 do
    kolory[0, b] := random;
  for a := 1 to 5 do
  begin
    for b := 0 to 2 do
    begin
      kolory[a, b] := kolory[a - 1, b] - 0.3 + random * 0.6;
      if kolory[a, b] < 0 then
        kolory[a, b] := 0;
      if kolory[a, b] > 1 then
        kolory[a, b] := 1;
    end;
  end;

  // generowanie terenu
  rozwys := 10 + random * 100;
  rozwys2 := rozwys / 2;

  case rodzaj_gor of
    0:
      begin // gory po staremu (randomowe)

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

            if ziemia.pk[a, b].p < 1 then
              ziemia.pk[a, b].p := 1;
            if ziemia.pk[a, b].p > matka.y - 100 then
              ziemia.pk[a, b].p := matka.y - 100;

          end;
        end;
      end;
    1:
      begin // gory skladane z trojkatow

        ax := random(100) - 50;
        for a := 0 to high(ziemia.pk) do
          for b := 0 to high(ziemia.pk[a]) do
          begin
            ziemia.pk[a, b].rodzaj := 0;
            ziemia.pk[a, b].p := ax;
          end;

        for a := 0 to 30 + random(35) do
        begin
          ax := random(high(ziemia.pk) * 2) - high(ziemia.pk); // od x
          bx := random(high(ziemia.pk) * 2 - ax) + ax; // do x

          sz := random(high(ziemia.pk[0]));
          tz := random(high(ziemia.pk[0]));
          dsz := random * 10 - 5;
          dtz := random * 10 - 5;

          sw := random * 270 - 130;

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
              begin
                ziemia.pk[b, c].p := ziemia.pk[b, c].p + sw;

                if ziemia.pk[b, c].p < -700 then
                  ziemia.pk[b, c].p := -700;
                if ziemia.pk[b, c].p > matka.y - 150 then
                  ziemia.pk[b, c].p := matka.y - 150;

              end;
            end;

            sz := sz + dsz;
            tz := tz + dtz;

            dsz := dsz + (random - 0.5) * 0.7;
            dtz := dtz + (random - 0.5) * 0.7;

          end;

        end;

      end;
  end;

  // wyszukaj najnizszy i najwyzszy punkt
  najnizszy := 9999;
  najwyzszy := -9999;
  for a := 0 to high(ziemia.pk) do
    for b := 0 to high(ziemia.pk[a]) do
    begin
      if ziemia.pk[a, b].p > najwyzszy then
        najwyzszy := ziemia.pk[a, b].p;
      if ziemia.pk[a, b].p < najnizszy then
        najnizszy := ziemia.pk[a, b].p;
    end;

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

      ziemia.pk[a, b].kr := kolory[trunc(r), 0];
      ziemia.pk[a, b].kg := kolory[trunc(r), 1];
      ziemia.pk[a, b].kb := kolory[trunc(r), 2];

    end;
  end;

  // znieksztalcenie gor
  for a := 1 to random(3) do
    for az := 0 to ziemia.wz - 1 do
    begin
      for ax := 0 to ziemia.wx - 1 do
      begin
        ziemia.pk[ax, az].p := ziemia.pk[ax, az].p + (random - 0.5) * 20;
        if ziemia.pk[ax, az].p < -700 then
          ziemia.pk[ax, az].p := -700;
        if ziemia.pk[ax, az].p > 700 then
          ziemia.pk[ax, az].p := 700;
      end;
    end;

  // "rozmycie" czyli wygladzenie gor
  for a := 1 to random(5) do
    for az := 0 to ziemia.wz - 1 do
    begin
      for ax := 0 to ziemia.wx - 1 do
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

  // ladowiska
  setlength(ladowiska, 1 + random(5));
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

    if gra.rodzajmisji = 1 then
      ladowiska[n].dobre := false
    else
      ladowiska[n].dobre := (random(3) <= 1) or (n = 0);
  end;

  // dzialka
  setlength(dzialko, random(10) + (ord(gra.rodzajmisji = 1) * 3) + gra.planeta div 2);
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
        // if (a=0) or (random(3-gra.planeta div 50)<>0) then begin
        if (a = 0) or (random(100) >= 30 + gra.planeta * 0.67) then
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

  a := 4 + random(20) + gra.planeta div 2;
  if a > 50 then
    a := 50;
  setlength(pilot, a);

  for a := 0 to high(pilot) do
    pilot[a].nalotnisku := random(length(ladowiska));

  ziemia.koltla[0] := random / 3;
  ziemia.koltla[1] := random / 3;
  ziemia.koltla[2] := random / 3;

  gra.czas := (60 * 7) + (gra.planeta div 5) * 30;
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

  d := 3 + random(10 - ord(r = 1) * 8); // dlugosc nazwy
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

// ---------------------------------------------------------------------------
procedure nowy_teren(wczytaj_nazwa: string = '');
const
  // lista numerow etapow, ktore sa wczytywane a nie generowane w normalnej grze
  wczytywane: array [0 .. 23] of integer = (1, 2, 3, 8, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85,
    90, 95, 98, 99);

  texladowiska = 0.35;
  texkrzakow = 0;
var
  a, az, ax, bx, bz: integer;
  vek1, vek2, vek3: TWektor;
  losowy: boolean;
  r: real;
  planetatmp: integer;
  n, an: integer;
begin
  planetatmp := gra.planeta;

  losowy := wczytaj_nazwa = '';
  gra.nazwamp3 := '';

  // rzeczy poczatkowe przymusowe--------------------------------------------------
  if gra.jakiemisje = 0 then
    RandSeed := gra.planeta + 9000
  else
    randomize;
  setlength(pilot, 0);
  matka.x := 0;
  matka.z := 0;

  setlength(mysliwiec, (gra.planeta + 5) div 14);

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
            ziemia.pk[bx, bz].p := r;
      end;

      y := 2 + gdzie_y(x, z, 0);
      sila := 1;
    end;
  end;

  // if gra.rodzajmisji=0 then begin
  // piloci
  gra.ilepilotow := 0;
  for a := 0 to high(pilot) do
  begin
    with pilot[a] do
    begin
      jest := true;
      // nalotnisku:=random(length(ladowiska));
      kier := random * 360;
      x := random * ladowiska[nalotnisku].rx * 2 * ziemia.wlk + (ladowiska[nalotnisku].x - ladowiska[nalotnisku].rx) *
        ziemia.wlk + ziemia.px; // random*ziemia.wx*ziemia.wlk+ziemia.px;
      z := random * ladowiska[nalotnisku].rz * 2 * ziemia.wlk + (ladowiska[nalotnisku].z - ladowiska[nalotnisku].rz) *
        ziemia.wlk + ziemia.pz; // random*ziemia.wz*ziemia.wlk+ziemia.pz;
      y := gdzie_y(x, z, 0);
      palisie := false;
      sila := 1;
      przewroc := 0;
      zly := not ladowiska[nalotnisku].dobre; // random(2)=0;
      if not zly then
        inc(gra.ilepilotow);
    end;
  end;
  { end else
    setlength(pilot,0); }

  gra.iledzialek := length(dzialko);
  gra.dzialekzniszczonych := 0;
  gra.zginelo := 0;
  gra.zabranych := 0;

  if losowy then
    case gra.rodzajmisji of
      0:
        begin
          gra.minimum := round(gra.ilepilotow * (0.5 + (gra.planeta / 200))
            { 0.7 } ); // = 70%
          if gra.minimum > length(pilot) then
            gra.minimum := length(pilot);
          gra.dzialekminimum := 0;
        end;
      1:
        begin
          gra.minimum := 0;
          gra.dzialekminimum := round(length(dzialko) * (0.5 + (gra.planeta / 200)));
          if gra.dzialekminimum > length(dzialko) then
            gra.dzialekminimum := length(dzialko);
        end;
    end;

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

  gra.pozycjaYtekstuintro := 50;
  for a := 1 to length(gra.tekstintro) do
    if gra.tekstintro[a] = #13 then
      inc(gra.pozycjaYtekstuintro, 10);

  // normalne terenu:
  if gra.jakiemisje <> 1 then
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

      // sceneria
      if (ziemia.pk[ax][az].rodzaj = 1) or (ax = 0) or (az = 0) or (ax = ziemia.wx - 2) or (az = ziemia.wz - 2) then
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
          ziemia.pk[ax][az].scen_rodz := random(ile_obiektow_scenerii);
          ziemia.pk[ax][az].sckr := ziemia.pk[ax][az].kr - (0.5 - random) * 0.4;
          if ziemia.pk[ax][az].sckr < 0.2 then
            ziemia.pk[ax][az].sckr := 0.2;
          if ziemia.pk[ax][az].sckr > 1 then
            ziemia.pk[ax][az].sckr := 1;
          ziemia.pk[ax][az].sckg := ziemia.pk[ax][az].kg - (0.5 - random) * 0.4;
          if ziemia.pk[ax][az].sckg < 0.2 then
            ziemia.pk[ax][az].sckg := 0.2;
          if ziemia.pk[ax][az].sckg > 1 then
            ziemia.pk[ax][az].sckg := 1;
          ziemia.pk[ax][az].sckb := ziemia.pk[ax][az].kb - (0.5 - random) * 0.4;
          if ziemia.pk[ax][az].sckb < 0.2 then
            ziemia.pk[ax][az].sckb := 0.2;
          if ziemia.pk[ax][az].sckb > 1 then
            ziemia.pk[ax][az].sckb := 1;
          ziemia.pk[ax][az].scen_obry := random(360);
          ziemia.pk[ax][az].scen_obrx := random(50) - 25;
          ziemia.pk[ax][az].scen_obrz := random(50) - 25;
          ziemia.pk[ax][az].scen_rozm := random * 4 + 0.5;

          if (ax > 0) then
            ziemia.pk[ax - 1][az].tex := texkrzakow;
          if (az > 0) then
            ziemia.pk[ax][az - 1].tex := texkrzakow;
          ziemia.pk[ax][az].tex := texkrzakow;

        end;
      end;

    end;
  end;

  if ustawienia.krzaki then
  begin
    // krzaki
    for az := 0 to ziemia.wz - 2 do
    begin
      for ax := 0 to ziemia.wx - 2 do
      begin
        if (ziemia.pk[ax][az].rodzaj = 1) or (ax = 0) or (az = 0) or (ax = ziemia.wx - 2) or (az = ziemia.wz - 2) then
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
  if gra.jakiemisje = 0 then
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

  for a := 0 to high(dym) do
    dym[a].jest := false;
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
  if gra.planeta >= 100 then
  begin
    gra.planeta := 1;
    if gra.jakiemisje = 0 then
      gra.jakiemisje := 1;
  end;
  if gra.jakiemisje = 2 then
    inc(winieta.epizodmisja);

  cheaty.czas_od_ostatniej_litery := 0;

  randomize;
  frmMain.TimerCzas.Enabled := false;
  // gracz.pilotow:=7;//*****
end;

// ---------------------------------------------------------------------------
procedure nowa_gra(wczytaj_nr: integer; jaka: integer);
begin
  gra.jakiemisje := jaka;
  case jaka of
    0:
      gra.planeta := winieta.planetapocz - 1;
    1:
      gra.planeta := winieta.poziomtrudnosci - 1;
    2:
      gra.planeta := winieta.epizodmisja - 1;
  end;
  gra.koniecgry := false;
  gra.zycia := 5;
  gra.pauza := false;
  gra.kasa := 0;
  gra.pkt := 0;

  gra.poziomupgrade[0] := 0;
  gra.poziomupgrade[1] := 0;
  gra.poziomupgrade[2] := 0;
  gra.poziomupgrade[3] := 0;
  gra.poziomupgrade[4] := 0;
  gra.poziomupgrade[5] := 0;

  if wczytaj_nr >= 0 then
  begin
    wczytajgre(wczytaj_nr);
    winieta.jest := true;
    frmMain.muzyke_wlacz(1, true);
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

  cheaty.full := false;
  cheaty.god := false;
  cheaty.fuel := false;
  cheaty.weapon := false;
  cheaty.lives := false;
  cheaty.load := false;
  cheaty.time := false;
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
      f := TFileStream.Create('misje\' + nazwa, fmOpenRead);

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
  frmMain.fmodstart;
  randomize;

  // wczytaj tekstury
  glGenTextures(ile_tekstur, @texName);
  wczytaj_teksture(0, 'font.tga', 1);
  FormStart.progres.StepIt;
  wczytaj_teksture(1, 'ziemia1.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(2, 'dym1.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(3, 'lander.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(4, 'cien.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(5, 'pilot.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(6, 'mothership.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(7, 'gwiazdy.tga', 1);
  FormStart.progres.StepIt;
  wczytaj_teksture(8, 'pilotzly.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(9, 'celownik.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(10, 'chmury.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(11, 'swiatlo.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(12, 'snop.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(13, 'ikony.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(14, 'kokpit.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(15, 'oslona.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture(16, 'krew.tga', 0);
  FormStart.progres.StepIt;
  wczytaj_teksture3d(17, ['ziemia0.tga', 'ziemia1.tga', 'ziemia2.tga', 'ziemia3.tga']);
  FormStart.progres.StepIt;
  wczytaj_teksture(18, 'krzaki.tga', 0);
  FormStart.progres.StepIt;

  // wczytaj obiekty
  setlength(obiekt, 25);

  obiekt[ob_gracz].o := TOBJModel.Create;
  obiekt[ob_gracz].o.LoadFromFile('dane\l3.obj', 5);
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
  obiekt[ob_pilot].o.LoadFromFile('dane\pilot.obj', 0.4);
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
  obiekt[ob_matka].o.LoadFromFile('dane\moth2.obj');
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
  obiekt[ob_dzialko].o.LoadFromFile('dane\dzn0.obj', 2);
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
  obiekt[ob_dzialkokawalki].o.LoadFromFile('dane\dzkaw.obj', 2);
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
  obiekt[ob_dzialkowieza].o.LoadFromFile('dane\dzn1.obj', 2);
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
  obiekt[ob_dzialkowieza2].o.LoadFromFile('dane\dzn12.obj', 2);
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
  obiekt[ob_dzialkolufa].o.LoadFromFile('dane\dzn2.obj', 2);
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
  obiekt[ob_dzialkolufa2].o.LoadFromFile('dane\dzn22.obj', 2);
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
  obiekt[ob_rakieta].o.LoadFromFile('dane\rakieta.obj', 0.3);
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
  obiekt[ob_mysliwiec].o.LoadFromFile('dane\lat.obj', 1.3);
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
  obiekt[ob_kokpit].o.LoadFromFile('dane\kokpit.obj');
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
  obiekt[ob_kamien].o.LoadFromFile('dane\kamo.obj', 2.4);
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
    obiekt[ob_sceneria1 + a].o.LoadFromFile('dane\sc' + inttostr(a + 1) + '.obj');
    obiekt[ob_sceneria1 + a].tex := 1;
    FormStart.progres.StepIt;
  end;

  setlength(swiatlo, 5);

  setlength(dym, 800);
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
  if FindFirst('misje\*.RFepz', FileAttrs, sr) = 0 then
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

  glClearColor(0, 0, 0, 0);

  frmMain.PowerTimer1.MayProcess := true;
  frmMain.PowerTimer1.MayRender := true;
end;

end.
