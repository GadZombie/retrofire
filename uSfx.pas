unit uSfx;

interface
uses
  Windows, SysUtils, Classes, Controls, Forms,
  api_func, opengl,
  directinput8,
  fmod, fmodtypes, fmoderrors, fmodpresets, glext,
  uConfig;

type

  TSoundEffect = record
    dz: PFSoundSample;
    kanal: longint;
    gra, loop: boolean;
    posv: TFSoundVector;
  end;

  TSfx = class
  private
    FMainForm: TForm;

  public
    constructor Create(AMainForm: TForm);

    procedure fmodstart;
    procedure wczytaj_dzwiek(nazwa: string; dzw: Integer; loop: boolean; czy_3d: boolean = true;
      glosnosc: Integer = 50);
    procedure graj_dzwiek(dzw: Integer; X, Y, z: real; czy_3d: boolean = true);
    procedure stop_dzwiek(dzw: Integer);
    function graj_dzwiek_kanal(dzw: Integer; X, Y, z, sx, sy, sz: real; kanal: longint): longint;
    procedure muzyke_wlacz(i: Integer; loop: boolean);
    procedure muzyke_wylacz;
  end;


var
  Sfx: TSfx;

  // -----fmod
  h, h1: THandle;
  driver: Integer;
  enm: TFSoundOutputTypes;
  caps: Cardinal;
  dzwieki: array of TSoundEffect;

  listenerpos: array [0 .. 2] of Single;
  posv, velv: TFSoundVector;

  czas_klatki: real = 0.0166667;

  muzstream: PFSoundStream;
  muzchannel: Integer;



implementation
uses
  UnitStart, unittimer;

procedure TSfx.wczytaj_dzwiek(nazwa: string; dzw: Integer; loop: boolean; czy_3d: boolean = true;
  glosnosc: Integer = 50);
var
  s: string;
begin
  if high(dzwieki) < dzw then
    setlength(dzwieki, dzw + 1);

  if czy_3d then
    dzwieki[dzw].dz := FSOUND_Sample_Load(FSOUND_FREE, pansichar(ansistring('dane\' + nazwa)), FSOUND_HW3D, 0, 0)
  else
    dzwieki[dzw].dz := FSOUND_Sample_Load(FSOUND_FREE, pansichar(ansistring('dane\' + nazwa)), FSOUND_HW2D, 0, 0);
  if dzwieki[dzw].dz = nil then
  begin
    s := 'Blad przy wczytywaniu dzieku ' + nazwa + #13#10 + FMOD_ErrorString(FSOUND_GetError());
    MessageBox(FMainForm.Handle, pchar(s), 'Blad!', MB_OK or MB_TASKMODAL);
    Application.Terminate;
    halt(0);
    exit;
  end;
  // increasing mindistance makes it louder in 3d space
  FSOUND_Sample_SetMinMaxDistance(dzwieki[dzw].dz, glosnosc, 5000.0);
  if loop then
    FSOUND_Sample_SetMode(dzwieki[dzw].dz, FSOUND_LOOP_NORMAL)
  else
    FSOUND_Sample_SetMode(dzwieki[dzw].dz, FSOUND_LOOP_OFF);

  dzwieki[dzw].gra := false;
  dzwieki[dzw].loop := loop;
  FormStart.progres.StepIt;
end;

procedure TSfx.graj_dzwiek(dzw: Integer; X, Y, z: real; czy_3d: boolean = true);
begin
  if dzwieki[dzw].gra then
  begin
    velv.X := (dzwieki[dzw].posv.X - X) / czas_klatki;
    velv.Y := (dzwieki[dzw].posv.Y - Y) / czas_klatki;
    velv.z := (dzwieki[dzw].posv.z - z) / czas_klatki;
    dzwieki[dzw].posv.X := X;
    dzwieki[dzw].posv.Y := Y;
    dzwieki[dzw].posv.z := z;
    { velv.x := 0;
      velv.y := 0;
      velv.z := 0; }
  end;
  if not dzwieki[dzw].gra then
  begin
    velv.X := 0;
    velv.Y := 0;
    velv.z := 0;
    dzwieki[dzw].posv.X := X;
    dzwieki[dzw].posv.Y := Y;
    dzwieki[dzw].posv.z := z;
    dzwieki[dzw].kanal := FSOUND_PlaySoundEx(FSOUND_FREE, dzwieki[dzw].dz, nil, true);
    if dzwieki[dzw].loop then
      dzwieki[dzw].gra := true;
  end;
  if czy_3d then
    FSOUND_3D_SetAttributes(dzwieki[dzw].kanal, @dzwieki[dzw].posv, nil);
  FSOUND_SetPaused(dzwieki[dzw].kanal, false);
end;

procedure TSfx.stop_dzwiek(dzw: Integer);
begin
  // if dzwieki[dzw].gra then begin
  FSOUND_StopSound(dzwieki[dzw].kanal);
  dzwieki[dzw].gra := false;
  // end;
end;

// do mysliwcow i rakiet dzwieki:
function TSfx.graj_dzwiek_kanal(dzw: Integer; X, Y, z, sx, sy, sz: real; kanal: longint): longint;
var
  posv: TFSoundVector;
begin
  if kanal >= 0 then
  begin
    velv.X := (sx - X) / czas_klatki;
    velv.Y := (sy - Y) / czas_klatki;
    velv.z := (sz - z) / czas_klatki;
    posv.X := X;
    posv.Y := Y;
    posv.z := z;
  end
  else
  begin
    velv.X := 0;
    velv.Y := 0;
    velv.z := 0;
    posv.X := X;
    posv.Y := Y;
    posv.z := z;

    kanal := FSOUND_PlaySoundEx(FSOUND_FREE, dzwieki[dzw].dz, nil, true);

  end;

  FSOUND_3D_SetAttributes(kanal, @posv, nil);

  FSOUND_SetPaused(kanal, false);

  result := kanal;
end;


constructor TSfx.Create(AMainForm: TForm);
begin
  inherited Create;
  FMainForm := AMainForm;
end;

procedure TSfx.fmodstart;
begin
  h := GetStdHandle(STD_INPUT_HANDLE);
  h1 := GetStdHandle(STD_OUTPUT_HANDLE);

  if FMOD_VERSION > FSOUND_GetVersion then
  begin
    WriteLn('Error: You are using FMOD version ', FSOUND_GetVersion:3:2, '.  You should be using version ',
      FMOD_VERSION:3:2);
    exit;
  end;

  if Config.Sound.Output = 1 then
    FSOUND_SetOutput(FSOUND_OUTPUT_DSOUND)
  else
    FSOUND_SetOutput(FSOUND_OUTPUT_NOSOUND);

  // FSOUND_SetOutput(FSOUND_OUTPUT_WINMM);
  // FSOUND_SetOutput(FSOUND_OUTPUT_A3D);
  // FSOUND_SetOutput(FSOUND_OUTPUT_NOSOUND);

  enm := FSOUND_GetOutput();
  FSOUND_SetDriver(0); // Select sound card (0 = default)

  FSOUND_SetMixer(FSOUND_MIXER_AUTODETECT);

  FSOUND_GetDriverCaps(FSOUND_GetDriver(), caps);

  if not FSOUND_Init(44100, 32, 0) then
  begin
    MessageBox(FMainForm.Handle, pchar('Blad przy inicjalizacji dzwieku!'#13#10 + FMOD_ErrorString(FSOUND_GetError())), 'Blad!',
      MB_OK or MB_TASKMODAL);
    FSOUND_Close();
    Application.Terminate;
    halt(0);
    exit;
  end;

  wczytaj_dzwiek('strzal.wav', 0, false);
  wczytaj_dzwiek('bum1.wav', 1, false, true, 100);
  wczytaj_dzwiek('silnik.wav', 2, true);
  wczytaj_dzwiek('kam.wav', 3, false);
  wczytaj_dzwiek('trach.wav', 4, false);
  wczytaj_dzwiek('duzebum.wav', 5, false);
  wczytaj_dzwiek('dzialko.wav', 6, false);
  wczytaj_dzwiek('kawalek2.wav', 7, false);
  wczytaj_dzwiek('czlspada.wav', 8, false);
  wczytaj_dzwiek('alarm1.wav', 9, false, false);
  // wczytaj_dzwiek('muzintro.wav', 10,false, false);
  // wczytaj_dzwiek('muzwin.wav', 11,false, false);
  // wczytaj_dzwiek('muzlost.wav', 12,false, false);
  wczytaj_dzwiek('boing.wav', 13, false);
  wczytaj_dzwiek('alarm2.wav', 14, false, false);
  wczytaj_dzwiek('alarm3.wav', 15, false, false);
  wczytaj_dzwiek('stuk.wav', 16, false);
  wczytaj_dzwiek('mysliw.wav', 17, true);
  wczytaj_dzwiek('rakieta.wav', 18, true);
  wczytaj_dzwiek('namierz.wav', 19, false, false);
  wczytaj_dzwiek('strzal1.wav', 20, false);
  wczytaj_dzwiek('rikoszet1.wav', 21, false);
  // ludzie
  wczytaj_dzwiek('wrzask1.wav', 22, false);
  wczytaj_dzwiek('wrzask2.wav', 23, false);
  wczytaj_dzwiek('wrzask3.wav', 24, false);
  wczytaj_dzwiek('wrzask4.wav', 25, false);

  // zli
  wczytaj_dzwiek('wrwrzask1.wav', 26, false);
  wczytaj_dzwiek('wrwrzask2.wav', 27, false);
  wczytaj_dzwiek('wrwrzask3.wav', 28, false);
  wczytaj_dzwiek('wrwrzask4.wav', 29, false);

  { muzstream := FSOUND_Stream_Open('dane\muz.mp3', FSOUND_LOOP_NORMAL or FSOUND_NORMAL, 0, 0);
    muzchannel := FSOUND_Stream_Play(FSOUND_FREE, muzstream);
    FSOUND_SetPaused(muzchannel, true); }

  muzstream := FSOUND_Stream_Open('dane\muzmenu.mp3', FSOUND_LOOP_NORMAL or FSOUND_NORMAL or FSOUND_HW2D, 0, 0);
  muzchannel := FSOUND_Stream_PlayEx(FSOUND_FREE, muzstream, 0, false);

  FSOUND_SetSFXMasterVolume(Config.Sound.SoundVolume);
  FSOUND_SetVolumeAbsolute(muzchannel, Config.Sound.MusicVolume);

end;

procedure TSfx.muzyke_wlacz(i: Integer; loop: boolean);
var
  s: string;
begin
  FSOUND_Stream_Stop(muzstream);
  FSOUND_Stream_Close(muzstream);

  case i of
    0:
      begin
        if gra.nazwamp3 = '' then
        begin
          s := 'muz' + inttostr(gra.planeta mod 5);
        end
        else
          s := gra.nazwamp3;
      end;
    1:
      s := 'muzmenu';
    2:
      s := 'intro';
    3:
      s := 'lost';
    4:
      s := 'win';
  end;

  if loop then
    muzstream := FSOUND_Stream_Open(pansichar(ansistring('dane\' + s + '.mp3')), FSOUND_LOOP_NORMAL or FSOUND_NORMAL or
      FSOUND_HW2D, 0, 0)
  else
    muzstream := FSOUND_Stream_Open(pansichar(ansistring('dane\' + s + '.mp3')), FSOUND_NORMAL or FSOUND_HW2D, 0, 0);
  muzchannel := FSOUND_Stream_PlayEx(FSOUND_FREE, muzstream, 0, true);
  FSOUND_SetPaused(muzchannel, false);

  FSOUND_SetSFXMasterVolume(Config.Sound.SoundVolume);
  FSOUND_SetVolumeAbsolute(muzchannel, Config.Sound.MusicVolume);
end;

procedure TSfx.muzyke_wylacz;
begin
  FSOUND_SetPaused(muzchannel, true);
end;






end.
