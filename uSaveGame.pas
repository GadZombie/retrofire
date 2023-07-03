unit uSaveGame;

interface
uses
  System.Classes, System.Sysutils;

type
  TSaveGame = record
    jest: boolean;

    rodzajgry: byte;

    data: Tdatetime;
    poziomupgrade: array [0 .. 5] of integer;
    pkt, kasa: int64;
    planeta, zycia: integer;
    epizod: string; { nazwa epizodu w przypadku misji dodatkowych }

  end;

var
  zapisy: array [0 .. 9] of TSaveGame;

procedure zapiszstring(var plik: TStream; t: string);
function wczytajstring(var plik: TStream): string;

procedure zapiszgre(numer: integer);
procedure wczytajzapisy;
procedure wczytajgre(numer: integer);

implementation
uses
  unittimer,
  uConfigVars;

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
      f := TFileStream.Create(GetSaveGamesFilePath, fmCreate);

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

  if fileexists(GetSaveGamesFilePath) then
  begin
    f := nil;
    try
      try
        f := TFileStream.Create(GetSaveGamesFilePath, fmOpenRead);

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


end.
