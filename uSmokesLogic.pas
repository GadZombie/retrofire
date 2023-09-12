unit uSmokesLogic;

interface

uses
  system.generics.collections;

const
  MaxSmokes = 800;

type
  TSmoke = class
  public
    jest: boolean;
    x, y, z: real;
    dx, dy, dz: real;

    rozmiar: real;
    kolr, kolg, kolb: real;
    przezr, szybprzezr: real;

    rodz: byte; { 0:ogien, 1:dym; 2:tworzy dymy }
    tekstura: byte;
    obrot, szybobr: real;
  end;

var
  SmokesList: TObjectList<TSmoke>;

procedure nowy_dym(sx, sy, sz, sdx, sdy, sdz: real; rozm: real; rodzaj: byte; szybprzezr_: real = 0.01;
  szybobr_: real = 1);
procedure ruch_dymow;
procedure SmokesClear;

implementation

uses
  unittimer, uSfx,
  uSurvivorsLogic;

// ---------------------------------------------------------------------------
procedure nowy_dym(sx, sy, sz, sdx, sdy, sdz: real; rozm: real; rodzaj: byte; szybprzezr_: real = 0.01;
  szybobr_: real = 1);
var
  n: integer;
  r: real;
var
  NewSmoke: TSmoke;
begin
  if SmokesList.Count >= MaxSmokes then
  begin
    n := random(SmokesList.Count);
    SmokesList[n].jest := false; // usuñ losowy stary
  end;

  NewSmoke := TSmoke.Create;
  with NewSmoke do
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
    szybobr := szybobr_;

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
          r := 0.1 - random * 0.1;
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
  SmokesList.Add(NewSmoke);
end;

// ---------------------------------------------------------------------------
procedure ruch_dymu(ASmoke: TSmoke);
var
  a, b: integer;
  s: real;
begin
  // dym

  with ASmoke do
  begin
    if jest then
    begin
      x := x + dx;
      y := y + dy; // -0.3;
      z := z + dz;

      obrot := obrot + (random / 2 + sqrt2(dx * dx + dy * dy + dz * dz)) * szybobr;

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
        for b := 0 to SurvivorList.Count - 1 do
          if SurvivorList[b].jest and not SurvivorList[b].palisie then
          begin
            s := sqrt2(sqr(SurvivorList[b].x - x) + sqr(SurvivorList[b].y - y) + sqr(SurvivorList[b].z - z));
            if s <= rozmiar then
            begin
              if not SurvivorList[b].palisie then
                Sfx.graj_dzwiek((22 + ord(SurvivorList[b].zly) * 4 + random(4)), SurvivorList[b].x, SurvivorList[b].y, SurvivorList[b].z);
              SurvivorList[b].palisie := true;
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

procedure ruch_dymow;
var
  a: integer;
begin
  a := 0;
  while a <= SmokesList.Count - 1 do
  begin
    ruch_dymu(SmokesList[a]);
    if SmokesList[a].jest then
      inc(a)
    else
      SmokesList.Delete(a);
  end;
end;

procedure SmokesClear;
begin
  SmokesList.Clear;
end;

end.
