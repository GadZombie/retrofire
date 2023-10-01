unit GlobalTypes;

interface
uses
  GL, obj;

type
  TMainIntroLine = record
    s: string;
    i: byte;
  end;

  TUpgradeItem = record
    ile: real;
    cena: integer;
  end;

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
    mothershipTime: integer;

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
    alienSteerDirection: integer;
    alienSteerForward: boolean;
    alienSteerTime: integer;

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
    TexDiv: real;

    grawitacja: real;
    gestoscpowietrza: real;

    koltla, jestkoltla: array [0 .. 3] of GLFloat;
    skyBrightness: extended;
    widac: real;

    chmuryx, chmuryz: real;
    showStars, showClouds: boolean;
  end;

  TLightsource = record
    jest: boolean;
    x, y, z: real;
    jasnosc: real;
    szybkosc: real;
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

    weigth, size: extended;

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
    shootSide: integer;
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
    shootSide: integer;

    dzw_kanal: longint;
    dzw_slychac: boolean; // zaleznie od odleglosci od gracza
  end;

  TGame = record
    jakiemisje: byte; { 0:norma, 1:losowe, 2:dodatkowe(wyczytwane) }
    rodzajmisji: byte; { 0:zbieraj pilotow, 1:zniszcz dzialka, 2:dogfight TODO }
    ilepilotow, zginelo, zabranych, minimum, pilotowbiegniedomatki: integer;
    sandboxMode: boolean;

    iledzialek, dzialekzniszczonych, dzialekminimum: integer;
    fightersDestroyed, fightersMinimum: integer;

    poziomupgrade: array [0 .. 5] of byte;

    czas: integer;

    etap: integer; { 0:intro, 1:gra, 2:zakonczenie }

    kamera, jestkamera: array [0 .. 2, 0 .. 2] of real;
    katkamera: real;

    planeta: integer;
    difficultyLevel: integer; //connected to planet number = planeta * DIFFICULTY_MULTIPLIER

    zycia: integer;
    kasa, pkt: int64;

    (* planeta_faktyczna:integer; //to samo, co planeta, ale w normalnej grze wykorzystywane do zapamietania
      //ostatniego etapu, bo po wczytaniu etapu z pliku (niektore misje) zmienia sie
      //wartosc 'planeta' ze wzgledu na wczytany z tego poziom trudnosci
    *)
    czasdorozpoczecia: integer; { jesli>0, to sie czeka. dziala po rozwaleniu sie, zeby chwile odczekalo }
    koniecgry: boolean;
    misjawypelniona, moznakonczyc, returnToMothership: boolean;
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

    corobi: byte; { 0:winieta, 1:sklep, 2:zapis gry, 3:wczytanie gry, 4: wybór epizodu, 5: sandbox menu }

    skrol: integer;
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
    bigHeads: boolean;

    czas_od_ostatniej_litery: integer; // zmniejsza sie do 0 i jesli dojdzie, to staje, a wpisywana_litera sie zeruje
    wpisany_tekst: array of byte;
  end;

implementation

end.
