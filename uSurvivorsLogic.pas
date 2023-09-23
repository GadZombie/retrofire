unit uSurvivorsLogic;

interface
uses
  system.generics.collections,
  Math;

type

  TSurvivor = class
    jest, zawszewidac: boolean;
    x, y, z, dy, dx, dz: real;
    kier: extended;
    nalotnisku: integer;
    palisie, sleeps: boolean;
    sila: real;

    zly: boolean;

    stoi: boolean;
    ani: integer;
    rodzani: byte;
    rescued: boolean;

    uciekaodgracza: integer; // ile czasu jeszcze ucieka od gracza, zamiast wsiadac; potrzebne do wysadzania ich

    miejscenamatce: real;
    // pozycja w drzwiach statku-matki, do ktorej sie celuje, kiedy do niej biegnie; jesli =0 to wylosuj nowa pozycje

    runAway: boolean;
    runAwayDirection: extended;
    przewroc: real; { kat, pod jakim stoi/lezy ;) 0-90 }
    watchingObject: integer; //0: nothing, 1: lander, 2: other survivor, 3: fighter
    watchingSurvivor: TSurvivor;
    watchingSurvivorTime: integer;
    watchingFighterId: integer;

    fallingHeightStart: extended;

    headUpAngle,              // > 0 w przód/dó³, <0 w ty³/górê          MIN=-70 MAX=30
    headSideAngle: extended; //MIN=-90 MAX=90
    headUpAngleDest, headSideAngleDest: extended;
  private
    procedure UpdateHead(ALanderDist: extended);
    function CanFollowLander(ALanderDist: extended): boolean;
    function MustRunFromLander(ALanderDist: extended): boolean;
    procedure StartWatchingSurvivor(AOtherSurvivor: TSurvivor; ATime: integer);
    procedure WatchFighters;
    procedure LandOnGround;

  public
    constructor Create;
    function Awake: boolean;
    procedure Update;
    procedure WatchOtherSurvivor(AOtherSurvivor: TSurvivor);
  end;

  TSurvivorList = class(TObjectList<TSurvivor>)
  private
    procedure separateSurvivor(ASurvivor1, ASurvivor2: TSurvivor; dist: extended);
  public
    procedure survivorsInteraction;
  end;

var
  SurvivorList: TSurvivorList;

function CreateSurvivor(sx, sy, sz: real; czyzly: boolean = false; silapocz: real = 1; lotniskopocz: integer = -2;
  czasuciekaniaodgracza: integer = 0): integer;
procedure UpdateSurvivors;

implementation
uses
  GlobalTypes,
  ZGLMathProcs,
  uSfx,
  uSmokesLogic,
  unittimer;

function CreateSurvivor(sx, sy, sz: real; czyzly: boolean = false; silapocz: real = 1; lotniskopocz: integer = -2;
  czasuciekaniaodgracza: integer = 0): integer;
var
  NewSurvivor: TSurvivor;
begin
  result := -1;

  NewSurvivor := TSurvivor.Create;
  with NewSurvivor do
  begin
    jest := true;

    x := sx;
    y := sy;
    z := sz;
    dy := 0;
    fallingHeightStart := y;
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

    headUpAngle := 0;
    headSideAngle := 0;
    watchingSurvivor := nil;
    watchingObject := 0;
    watchingSurvivorTime := 0;
    watchingFighterId := -1;

  end;
  result := SurvivorList.Add(NewSurvivor);
end;


constructor TSurvivor.Create;
begin
  inherited;
  watchingSurvivor := nil;
end;

function TSurvivor.Awake: boolean;
var
  probability: integer;
begin
  if not Self.sleeps then
    exit(true);

  if watchingObject = 0 then
    probability := 70
  else
  if watchingObject = 1 then
    probability := 5
  else
    probability := 150;

  if random(probability) = 0 then
    Self.sleeps := false;

  result := not Self.sleeps;
end;

procedure TSurvivor.StartWatchingSurvivor(AOtherSurvivor: TSurvivor; ATime: integer);
begin
  Self.watchingSurvivor := AOtherSurvivor;
  Self.watchingSurvivorTime := ATime;
  Self.watchingObject := 2;
end;

procedure TSurvivor.WatchOtherSurvivor(AOtherSurvivor: TSurvivor);
begin
  if ((Self.watchingObject <> 2) or (Self.watchingSurvivorTime <= 0)) and
    (random(5) = 0) and
    ((AOtherSurvivor.sila <= 0.1) or (AOtherSurvivor.przewroc > 1) or (AOtherSurvivor.palisie) {or (random(200) = 0)}) then
  begin
    StartWatchingSurvivor(AOtherSurvivor, 100 + random(10));
  end;
end;

procedure TSurvivorList.separateSurvivor(ASurvivor1, ASurvivor2: TSurvivor; dist: extended);
const
  minDist = 4;
var
  middle: TVec3D;
begin
  if dist < minDist then
  begin
    middle := TVec3D.ToVec(
      (ASurvivor1.x + ASurvivor2.x) / 2,
      (ASurvivor1.y + ASurvivor2.y) / 2,
      (ASurvivor1.z + ASurvivor2.z) / 2);

    dist := dist / 2;
    if dist = 0 then
      dist := 0.01;
    ASurvivor1.x := middle.x + ((ASurvivor1.x - middle.x) / dist) * (minDist / 2);
//            ASurvivor1.y := middle.y + ((ASurvivor1.y - middle.y) / dist) * (minDist / 2);
    ASurvivor1.z := middle.z + ((ASurvivor1.z - middle.z) / dist) * (minDist / 2);

    ASurvivor2.x := middle.x + ((ASurvivor2.x - middle.x) / dist) * (minDist / 2);
//            ASurvivor2.y := middle.y + ((ASurvivor2.y - middle.y) / dist) * (minDist / 2);
    ASurvivor2.z := middle.z + ((ASurvivor2.z - middle.z) / dist) * (minDist / 2);

    if (random(10) = 0) then
    begin
      ASurvivor1.StartWatchingSurvivor(ASurvivor2, 10 + random(40));
      ASurvivor2.StartWatchingSurvivor(ASurvivor1, 10 + random(40));
    end;

  end;
end;

procedure TSurvivorList.survivorsInteraction;
var
  a, b: integer;
  dist, playerDest: extended;
begin
  for a := 0 to self.Count - 1 do
  begin
    if Items[a].jest then
    begin
      playerDest := Distance3D(Items[a].x, Items[a].y, Items[a].z, gracz.x, gracz.y, gracz.z);
      if playerDest > 600 then
        continue;

      for b := a + 1 to self.Count - 1 do
      begin
        if (Items[b].jest) and ((Items[a].nalotnisku = Items[b].nalotnisku) or (Items[b].nalotnisku = -2) or (Items[a].nalotnisku = -2)) then
        begin
          dist := Distance3D(Items[a].x, Items[a].y, Items[a].z, Items[b].x, Items[b].y, Items[b].z);
          if dist = 0 then
            dist := 0.01;

          separateSurvivor(Items[a], Items[b], dist);

          if dist < 100 then
          begin
            Items[b].WatchOtherSurvivor(Items[a]);
            Items[a].WatchOtherSurvivor(Items[b]);
          end;

        end;
      end;

    end;
  end;
end;

procedure TSurvivor.WatchFighters;
var
  a: integer;
  dist: extended;
begin
  if random(10) <> 0 then
    exit;

  if not ((watchingObject = 0) or (watchingObject = 1)) then
    exit;


  for a := 0 to high(mysliwiec) do
  begin
    if (mysliwiec[a].jest) then
    begin
      dist := Distance3D(x, y, z, mysliwiec[a].x, mysliwiec[a].y, mysliwiec[a].z);
      if dist <= 500 then
      begin
        watchingObject := 3;
        watchingFighterId := a;
        exit;
      end;
    end;
  end;
end;

procedure TSurvivor.UpdateHead(ALanderDist: extended);
var
  watchPoint: TVec3D;
  k, dist: extended;
begin
  if palisie and (sila > 0) then
  begin
    if random(10) = 0 then
      headUpAngleDest := -60 + random(70);
    if random(10) = 0 then
      headSideAngleDest := -50 + random(100);
  end
  else
  if (sila > 0) then
  begin
    WatchFighters;

    if (ALanderDist <= 120) and (gracz.zyje) then
    begin
      if (random(40) = 0) and (watchingObject = 0) then
        watchingObject := 1;
    end
    else
    begin
      if (watchingObject = 1) and (random(60) = 0) then
        watchingObject := 0;
    end;

    if (watchingObject = 2) and (watchingSurvivor = nil) then
    begin
      watchingObject := 0;
      watchingSurvivorTime := 0;
    end;

    if watchingObject = 2 then
    begin
      dec(watchingSurvivorTime);
      if (watchingSurvivor = nil) or not watchingSurvivor.jest then
      begin
        watchingSurvivor := nil;
        watchingObject := 0;
      end;
      if watchingSurvivorTime <= 0 then
      begin
        watchingSurvivor := nil;
        watchingObject := 0;
      end;
    end;

    if watchingObject = 3 then
    begin
      if (watchingFighterId < 0) or (watchingFighterId > High(mysliwiec)) or not mysliwiec[watchingFighterId].jest then
      begin
        watchingObject := 0;
        watchingFighterId := -1;
      end
      else
      begin
        dist := Distance3D(x, y, z, mysliwiec[watchingFighterId].x, mysliwiec[watchingFighterId].y, mysliwiec[watchingFighterId].z);
        if (dist > 500) and (random(30) = 0) then
        begin
          watchingObject := 0;
          watchingFighterId := -1;
        end
      end;

    end;

    if watchingObject > 0 then
    begin
      if (watchingObject = 2) and (watchingSurvivor <> nil) then
        watchPoint := TVec3D.ToVec(watchingSurvivor.x, watchingSurvivor.y + 2, watchingSurvivor.z)
      else
      if (watchingObject = 3) and (watchingFighterId >= 0) then
        watchPoint := TVec3D.ToVec(mysliwiec[watchingFighterId].x, mysliwiec[watchingFighterId].y, mysliwiec[watchingFighterId].z)
      else
        watchPoint := TVec3D.ToVec(gracz.x, gracz.y + 2, gracz.z);

      k := - jaki_to_kat(x - watchPoint.x, z - watchPoint.z) + kier ;
      k := keepValueInBounds(k, 360) - 180;
      if ((watchingObject = 1) and (abs(k) > 165)) or
         ((nalotnisku = -1) and (watchingObject = 1) and (abs(k) > 100)) then
        k := 0;
      k := KeepValBetween(k, -120, 120);
      headSideAngleDest := k;

      k := 90 - jaki_to_kat(
        sqrt2(sqr(watchPoint.x - x) + sqr(watchPoint.z - z)),
        (watchPoint.y - y)
      );
      k := KeepValBetween(k, -80, 30);
      headUpAngleDest := k;
    end
    else
    begin
      if random(50) = 0 then
        headUpAngleDest := -50 + random(60);
      if random(50) = 0 then
        headSideAngleDest := -70 + random(140);
    end;
  end;

  headSideAngle := AnimateTo(headSideAngle, headSideAngleDest, 5);
  headUpAngle := AnimateTo(headUpAngle, headUpAngleDest, 5);
end;

function TSurvivor.CanFollowLander(ALanderDist: extended): boolean;
const
  ALIEN_FOLLOWS_LANDER_DIST = 400;
begin
  result :=
    (uciekaodgracza <= 0) and
    gracz.stoi and
    ((gracz.grlot = nalotnisku) or (zly and (ALanderDist <= ALIEN_FOLLOWS_LANDER_DIST)) ) and
    (((abs(gracz.nacisk) < 0.05) and (gracz.pilotow < gracz.ladownosc)) or zly);
end;

function TSurvivor.MustRunFromLander(ALanderDist: extended): boolean;
const
  RUNAWAY_FROM_LANDER_DIST = 70;
begin
  result :=
    (ALanderDist < RUNAWAY_FROM_LANDER_DIST) and (
      (uciekaodgracza > 0) or
      not gracz.stoi or
      ( ((abs(gracz.nacisk) >= 0.05) or (gracz.pilotow >= gracz.ladownosc)) and (not zly))
    );
end;

procedure TSurvivor.LandOnGround;
const
  MIN_HEIGHT_TO_INJURE = 20;
var
  hitValue, minY, splashStrength: extended;
  a: integer;
begin
  if self.y <= self.fallingHeightStart - MIN_HEIGHT_TO_INJURE then
  begin
    hitValue := ((self.fallingHeightStart - self.y - MIN_HEIGHT_TO_INJURE) * abs(dy)) / 30;
    if hitValue > 2 then
      hitValue := 2;

    splashStrength := Min(hitValue / 8, 0.13);
    self.sila := self.sila - hitValue;

    minY := gdzie_y(x, z, y) + 1;
    for a := 0 to round(hitValue * 20) do
      nowy_dym(
        x + (-0.5 + random),
        minY,
        z + (-0.5 + random),
        (random - 0.5) * (0.2 + splashStrength) + dx,
        (random - 0.3) * (0.15 + splashStrength),
        (random - 0.5) * (0.2 + splashStrength) + dz,
        0.2 + random * 0.5, 3);

  end;
  self.fallingHeightStart := self.y;
end;

procedure TSurvivor.Update;
const
  RUNAWAY_FROM_LANDER_STOP_DIST = 60;
var
  nx, nz, k1, nk1: integer;
  k, s, speed: real;
  landerDist: extended;
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

    if palisie then
      sleeps := false;

    if uciekaodgracza > 0 then
      dec(uciekaodgracza);

    landerDist := Distance3D(Self.x, Self.y, Self.z, gracz.x, gracz.y, gracz.z);

    if palisie and (random(2) = 0) then
    begin
      nowy_dym(x + sin(kier * pi180) * sin(przewroc * pi180) * (1 + random * 1.5),
        y + cos(przewroc * pi180) * (1 + random * 1.5), z - cos(kier * pi180) * sin(przewroc * pi180) *
        (1 + random * 1.5), (random - 0.5) / 8, 0.1 + random / 6, (random - 0.5) / 8, 0.4 + random / 2, 0, 0.05);

      sila := sila - 0.008;
      if sila < 0 then
      begin
        sila := 0;
        headUpAngleDest := -70 + random(100);
        headSideAngleDest := -90 + random(180);
      end;
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
        if not (gracz.stoi and (gracz.grlot = nalotnisku) and ((gracz.pilotow < gracz.ladownosc) or (zly))) and
            (random(30) = 0) then
          sleeps := true;

        s := landerDist;
        if (s >= 100) and (s <= 300) then
        begin
          if rodzani = 1 then
          begin
            ani := ani + 6 + random(3);
            if (random(20) = 0) and (y <= gdzie_y(x, z, y)) then
            begin
              LandOnGround;
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
      UpdateHead(landerDist);

      if not gracz.stoi then
      begin
        //uderzenie w gracza
        s := landerDist;
        if s < 8 then
        begin
          if s <= 0 then
            s := 0.01;
          k := Distance3D(0, 0, 0, gracz.dx, gracz.dy, gracz.dz);
          if k > 2 then
            k := 2;
          x := gracz.x + ((x - gracz.x) / s) * 8;
          y := gracz.y + ((y - gracz.y) / s) * 8;
          z := gracz.z + ((z - gracz.z) / s) * 8;
          dy := dy + ((y - gracz.y) / 80)  + gracz.dy;
          dx := dx + ((x - gracz.x) / 30)  + gracz.dx;
          dz := dz + ((z - gracz.z) / 30)  + gracz.dz;

          //mocniejsze uderzenie, gdy pilot jest pod l¹downikiem
          s := sqrt2(sqr(gracz.x - x) + sqr(gracz.z - z));
          if (s <= 5) and (y < gracz.y - 1) then
            k := k * 10;
          if k > 0.1 then
          begin
            sila := sila - k / 2;
          end;
        end;
      end;

      if nalotnisku >= 0 then
      begin // na ziemi
        s := landerDist;

        if MustRunFromLander(landerDist) then
//        if (s < RUNAWAY_FROM_LANDER_DIST) and not CanFollowLander(landerDist, true{zly and (landerDist <= 500{ALIEN_FOLLOWS_LANDER_DIST)} ) then
        begin // uciekaja
          if Self.Awake then
          begin
            if s < RUNAWAY_FROM_LANDER_STOP_DIST then
            begin
              if not runAway then
              begin
                runAway := true;
                runAwayDirection := (180 + jaki_to_kat(gracz.x - x, gracz.z - z)) - 60 + random(120)
              end;
              k := runAwayDirection;
            end
            else //jak s¹ dalej, to obarcaj¹ siê przodem
            begin
              k := (jaki_to_kat(gracz.x - x, gracz.z - z));
              runAway := false;
//                  watchingLander := true;
//                  watchingPilot := -1;
            end;

            k := keepValueInBounds(k, 360);

            ObrocSieNa(kier, k, 1.5 + random * 3);

            if s < RUNAWAY_FROM_LANDER_STOP_DIST then
            begin
              if abs(gdzie_y(x + sin(kier * pi180) / 3, z - cos(kier * pi180) / 3, y) - gdzie_y(x, z, y)) < 0.2 then
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
              LandOnGround;
              if abs(sin(ani * pi180)) < 0.2 then
                dy := 0.2;
              y := gdzie_y(x, z, y);
            end;
          end;
        end
        else
        begin
          runAway := false;
        end;


        if (CanFollowLander(landerDist)) then
        begin // biegna do gracza
          if Self.Awake then
          begin
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
              Sfx.graj_dzwiek(13, x, y, z);
            end;
            k := (jaki_to_kat(gracz.x - x, gracz.z - z));
            stoi := false;

//                if (watchingPilot = -1) then
//                  watchingLander := true;
            speed := 0.25 + random * 0.25; //(2 + random * 3); //0.5 .. 0.25

            if (k <> kier) then
            begin
              k1 := (round(kier - k) + 360) mod 360;
              if k1 = 180 then
                k1 := 180 + (random(2) * 2 - 1);
              if (k1 <= 180) then
              begin
                if (abs(kier - k) < 20) then
                begin
                  kier := kier - 2;
                end
                else
                begin
                  kier := kier - (1 + random * 6);
                  speed := 0.0 + random * 0.01;
                  stoi := true;
                  ani := 0;
                end;

                nk1 := (round(kier - k) + 360) mod 360;
                if (nk1 > 180) then
                  kier := k;
              end
              else
              begin
                if (abs(kier - k) < 20) then
                begin
                  kier := kier + 2;
                end
                else
                begin
                  kier := kier + 2 + random * 4;
                  speed := 0.0 + random * 0.01;
                  ani := 0;
                  stoi := true;
                end;
                nk1 := (round(kier - k) + 360) mod 360;
                if (nk1 <= 180) then
                  kier := k;
              end;
            end;

            if (kier >= 360) then
              kier := kier - 360
            else if (kier < 0) then
              kier := kier + 360;

            k := gdzie_y(x + sin(kier * pi180) / 3, z - cos(kier * pi180) / 3, y) - gdzie_y(x, z, y); //k>0: going up
            if (k < 1) and (k > -1) then
            begin
              x := x + sin(kier * pi180) * (speed + ((random - 0.5) * 0.05)); // (2 + random * 3);
              z := z - cos(kier * pi180) * (speed + ((random - 0.5) * 0.05)); // (2 + random * 3);
            end;
            if y <= gdzie_y(x, z, y) then
            begin
              LandOnGround;
              if (speed > 0.1) and (abs(sin(ani * pi180)) < 0.2) then
                dy := 0.18 + random * 0.03;
              y := gdzie_y(x, z, y);
            end;

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
          LandOnGround;
          if abs(sin(ani * pi180)) < 0.2 then
            dy := 0.2;
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
      sleeps := false;
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
//        headUpAngle := -35 + sin((licz + 1{TODO a} * 50) * 5 * pi180) * 35; // > 0 w przód/dó³, <0 w ty³/górê          MIN=-70 MAX=30
//        headSideAngle := sin((licz + 1{TODO a} * 50) * 8 * pi180) * 50; //MIN=-90 MAX=90

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
          LandOnGround;
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
          LandOnGround;
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

    if y > gdzie_y(x, z, y) then
    begin
      if sila > 0 then
        dy := dy - 0.015 - ziemia.grawitacja * 2
      else
        dy := dy - 0.01 - ziemia.grawitacja;
    end;
    if (y < gdzie_y(x, z, y)) and (dy < 0) then
    begin
      LandOnGround;
      if sila > 0 then
        dy := abs(dy / 2)
      else
      begin
        if abs(dy) > 0.1 then
          Sfx.graj_dzwiek(8, x, y, z);

        dy := abs(dy / 4);
      end;
    end;

  end;

end;


procedure RemoveSurvivor(ASurvivor: TSurvivor);
var
  a: integer;
begin
  for a := 0 to SurvivorList.Count - 1 do
  begin
    if (SurvivorList[a].watchingSurvivor = ASurvivor) then
    begin
      SurvivorList[a].watchingObject := 0;
      SurvivorList[a].watchingSurvivor := nil;
    end;
  end;
  SurvivorList.Remove(ASurvivor);
end;

procedure UpdateSurvivors;
var
  a: integer;
begin
  gra.ilepilotow := 0;
  gra.pilotowbiegniedomatki := 0;

  a := 0;
  while a <= SurvivorList.Count - 1 do
  begin
    SurvivorList[a].Update();
    if SurvivorList[a].jest then
      inc(a)
    else
      RemoveSurvivor(SurvivorList[a]);
  end;
  SurvivorList.survivorsInteraction;
end;

end.
