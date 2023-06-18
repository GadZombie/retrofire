unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, api_func, opengl, ExtCtrls, render, gl, glu, PowerTimers,
  unittex, PowerInputs, PowerTypes,
  fmod, fmodtypes, fmoderrors, fmodpresets, glext,

  directinput8;

type
  TForm1 = class(TForm)
    PowerTimer1: TPowerTimer;
    PwrInp: TPowerInput;
    TimerCzas: TTimer;
    procedure wczytajkfg;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PowerTimer1Render(Sender: TObject);
    procedure PowerTimer1Process(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TimerCzasTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure fmodstart;
    procedure wczytaj_dzwiek(nazwa:string; dzw:integer; loop:boolean;czy_3d:boolean=true;glosnosc:integer=50);
    procedure graj_dzwiek(dzw:integer; x,y,z:real;czy_3d:boolean=true);
    procedure stop_dzwiek(dzw:integer);
    function graj_dzwiek_kanal(dzw:integer; x,y,z, sx,sy,sz:real; kanal:longint):longint;
    procedure muzyke_wlacz(i:integer; loop:boolean);
    procedure muzyke_wylacz;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  pfd: PIXELFORMATDESCRIPTOR = (
    nSize: sizeof(PIXELFORMATDESCRIPTOR);
    nVersion: 1;
    dwFlags: PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    iPixelType: PFD_TYPE_RGBA;
    cColorBits: 32;
    cRedBits: 0;
    cRedShift: 0;
    cGreenBits: 0;
    cBlueBits: 0;
    cBlueShift: 0;
    cAlphaBits: 0;
    cAlphaShift: 0;
    cAccumBits: 0;
    cAccumRedBits: 0;
    cAccumGreenBits: 0;
    cAccumBlueBits: 0;
    cAccumAlphaBits: 0;
    cDepthBits: 32;
    cStencilBits: 0;
    cAuxBuffers: 0;
    iLayerType: PFD_MAIN_PLANE;
    bReserved: 0;
    dwLayerMask: 0;
    dwVisibleMask: 0;
    dwDamageMask: 0);

var
  Form1: TForm1;

  ustawienia:record
     rozdzx,rozdzy,bity,hz:integer;
     fullscreen:boolean;
     dzwiek:integer;
     voldzw, volmuz, widocznosc: integer;
     jasnosc:real;
     krzaki: boolean;
  end;
  klawisze:array[0..49] of byte;

  dupa:PGLUquadricObj;

  myszsx,myszsy: integer;
  myszguzikl,myszguzikp:boolean;

  fullscreen:boolean;
  dmScreenSettings: DEVMODE;                                       // Device mode

  //-----fmod
  h, h1: THandle;
  driver: Integer;
  enm: TFSoundOutputTypes;
  caps: Cardinal;
  dzwieki: array of record
           dz:PFSoundSample;
           kanal:longint;
           gra,
           loop:boolean;
           posv: TFSoundVector;
           end;
  listenerpos: array[0..2] of Single;
  posv,velv: TFSoundVector;

  czas_klatki:real= 0.0166667;

  muzstream: PFSoundStream;
  muzchannel: Integer;

implementation
uses unittimer, UnitStart;

{$R *.dfm}

procedure tform1.wczytajkfg;
var f:tstream; a,x,y:integer;b:boolean;
begin
f:=nil;
try
  try
     f:=TFileStream.Create('Retrofire.kfg', fmopenread);
     f.ReadBuffer(ustawienia.rozdzx,sizeof(ustawienia.rozdzx));
     f.ReadBuffer(ustawienia.rozdzy,sizeof(ustawienia.rozdzy));
     f.ReadBuffer(ustawienia.bity,sizeof(ustawienia.bity));
     f.ReadBuffer(ustawienia.hz,sizeof(ustawienia.hz));
     f.ReadBuffer(ustawienia.fullscreen,sizeof(ustawienia.fullscreen));
     f.ReadBuffer(ustawienia.dzwiek,sizeof(ustawienia.dzwiek));

     for a:=0 to 49 do f.ReadBuffer(klawisze[a],sizeof(klawisze[a]));

     f.ReadBuffer(ustawienia.voldzw,sizeof(ustawienia.voldzw));
     f.ReadBuffer(ustawienia.volmuz,sizeof(ustawienia.volmuz));

     f.ReadBuffer(ustawienia.widocznosc,sizeof(ustawienia.widocznosc));

     widocznosc:=ustawienia.widocznosc;
     widocznoscpil:=20;
     if widocznoscpil>widocznosc-5 then widocznoscpil:=widocznosc-5;


     if widocznoscscen>widocznosc-2 then widocznoscscen:=widocznosc-2;
     if widocznoscscen>40 then widocznoscscen:=40;

     if widocznoscscencien>widocznoscscen-10 then widocznoscscencien:=widocznoscscen-10;

     if widocznoscdzial>widocznosc then widocznoscdzial:=widocznosc;
     if widocznoscdzial>50 then widocznoscdzial:=50;


     odlwidzenia:=widocznosc*24;

     f.ReadBuffer(a,sizeof(a));
     ustawienia.jasnosc:=a/10;

     f.ReadBuffer(a,sizeof(a));
     ustawienia.krzaki:=boolean(a);

  except
     if f<>nil then begin
        f.Free;
        f:=nil;
     end;
     MessageBox(Handle, pchar('Brak pliku konfiguracji lub jest w nim b³¹d! Uruchom konfiguracjê gry!'), 'B³¹d', MB_OK+MB_TASKMODAL+MB_ICONERROR);
     Application.Terminate;
     halt(0);
     exit;
  end;
finally
   if f<>nil then begin
      f.Free;
      f:=nil;
   end;
end;

end;

procedure TForm1.wczytaj_dzwiek(nazwa:string; dzw:integer; loop:boolean;czy_3d:boolean=true;glosnosc:integer=50);
var s:string;
begin
if high(dzwieki)<dzw then setlength(dzwieki,dzw+1);

  if czy_3d then
     dzwieki[dzw].dz := FSOUND_Sample_Load(FSOUND_FREE, pansichar(ansistring('dane\'+nazwa)), FSOUND_HW3D, 0, 0)
  else
     dzwieki[dzw].dz := FSOUND_Sample_Load(FSOUND_FREE, pansichar(ansistring('dane\'+nazwa)), FSOUND_HW2D, 0, 0);
  if dzwieki[dzw].dz = nil then begin
    s:='Blad przy wczytywaniu dzieku '+nazwa+#13#10+FMOD_ErrorString(FSOUND_GetError());
    MessageBox(handle,pchar(s),'Blad!',MB_OK or MB_TASKMODAL);
    Application.Terminate;
    halt(0);
    Exit;
  end;
 // increasing mindistance makes it louder in 3d space
  FSOUND_Sample_SetMinMaxDistance(dzwieki[dzw].dz, glosnosc, 5000.0);
  if loop then FSOUND_Sample_SetMode(dzwieki[dzw].dz, FSOUND_LOOP_NORMAL)
          else FSOUND_Sample_SetMode(dzwieki[dzw].dz, FSOUND_LOOP_OFF);

  dzwieki[dzw].gra:=false;
  dzwieki[dzw].loop:=loop;
  FormStart.progres.StepIt;
end;

procedure TForm1.graj_dzwiek(dzw:integer; x,y,z:real;czy_3d:boolean=true);
begin
  if dzwieki[dzw].gra then begin
     velv.x := (dzwieki[dzw].posv.x-x)/czas_klatki;
     velv.y := (dzwieki[dzw].posv.y-y)/czas_klatki;
     velv.z := (dzwieki[dzw].posv.z-z)/czas_klatki;
     dzwieki[dzw].posv.x := x;
     dzwieki[dzw].posv.y := y;
     dzwieki[dzw].posv.z := z;
{     velv.x := 0;
     velv.y := 0;
     velv.z := 0;}
  end;
  if not dzwieki[dzw].gra then begin
     velv.x := 0;
     velv.y := 0;
     velv.z := 0;
     dzwieki[dzw].posv.x := x;
     dzwieki[dzw].posv.y := y;
     dzwieki[dzw].posv.z := z;
     dzwieki[dzw].kanal := FSOUND_PlaySoundEx(FSOUND_FREE, dzwieki[dzw].dz, nil,true);
     if dzwieki[dzw].loop then dzwieki[dzw].gra:=true;
  end;
  if czy_3d then
     FSOUND_3D_SetAttributes(dzwieki[dzw].kanal, @dzwieki[dzw].posv, nil);
  FSOUND_SetPaused(dzwieki[dzw].kanal, False);
end;

procedure TForm1.stop_dzwiek(dzw:integer);
begin
//  if dzwieki[dzw].gra then begin
     FSOUND_StopSound(dzwieki[dzw].kanal);
     dzwieki[dzw].gra:=false;
//  end;
end;

//do mysliwcow i rakiet dzwieki:
function TForm1.graj_dzwiek_kanal(dzw:integer; x,y,z, sx,sy,sz:real; kanal:longint):longint;
var
 posv: TFSoundVector;
begin
  if kanal>=0 then begin
     velv.x := (sx-x)/czas_klatki;
     velv.y := (sy-y)/czas_klatki;
     velv.z := (sz-z)/czas_klatki;
     posv.x := x;
     posv.y := y;
     posv.z := z;
  end else begin
     velv.x := 0;
     velv.y := 0;
     velv.z := 0;
     posv.x := x;
     posv.y := y;
     posv.z := z;

     kanal := FSOUND_PlaySoundEx(FSOUND_FREE, dzwieki[dzw].dz, nil,true);

  end;

  FSOUND_3D_SetAttributes(kanal, @posv, nil);

  FSOUND_SetPaused(kanal, False);

  result:=kanal;
end;


procedure TForm1.fmodstart;
begin
  h := GetStdHandle(STD_INPUT_HANDLE);
  h1 := GetStdHandle(STD_OUTPUT_HANDLE);

  if FMOD_VERSION > FSOUND_GetVersion then
  begin
    WriteLn('Error: You are using FMOD version ', FSOUND_GetVersion: 3: 2, '.  You should be using version ', FMOD_VERSION: 3: 2);
    Exit;
  end;

  if ustawienia.dzwiek=1 then FSOUND_SetOutput(FSOUND_OUTPUT_DSOUND)
     else FSOUND_SetOutput(FSOUND_OUTPUT_NOSOUND);
     
//  FSOUND_SetOutput(FSOUND_OUTPUT_WINMM);
//      FSOUND_SetOutput(FSOUND_OUTPUT_A3D);
//      FSOUND_SetOutput(FSOUND_OUTPUT_NOSOUND);

  enm := FSOUND_GetOutput();
  FSOUND_SetDriver(0); // Select sound card (0 = default)

  FSOUND_SetMixer(FSOUND_MIXER_AUTODETECT);

  FSOUND_GetDriverCaps(FSOUND_GetDriver(), caps);

  if not FSOUND_Init(44100, 32, 0) then
  begin
    MessageBox(handle,pchar('Blad przy inicjalizacji dzwieku!'#13#10+FMOD_ErrorString(FSOUND_GetError())),'Blad!',MB_OK or MB_TASKMODAL);
    FSOUND_Close();
    Application.Terminate;
    halt(0);
    Exit;
  end;


  wczytaj_dzwiek('strzal.wav', 0,false);
  wczytaj_dzwiek('bum1.wav', 1,false,true,100);
  wczytaj_dzwiek('silnik.wav', 2,true);
  wczytaj_dzwiek('kam.wav', 3,false);
  wczytaj_dzwiek('trach.wav', 4,false);
  wczytaj_dzwiek('duzebum.wav', 5,false);
  wczytaj_dzwiek('dzialko.wav', 6,false);
  wczytaj_dzwiek('kawalek2.wav', 7,false);
  wczytaj_dzwiek('czlspada.wav', 8,false);
  wczytaj_dzwiek('alarm1.wav', 9,false, false);
//  wczytaj_dzwiek('muzintro.wav', 10,false, false);
//  wczytaj_dzwiek('muzwin.wav', 11,false, false);
//  wczytaj_dzwiek('muzlost.wav', 12,false, false);
  wczytaj_dzwiek('boing.wav', 13,false);
  wczytaj_dzwiek('alarm2.wav', 14,false, false);
  wczytaj_dzwiek('alarm3.wav', 15,false, false);
  wczytaj_dzwiek('stuk.wav', 16,false);
  wczytaj_dzwiek('mysliw.wav', 17,true);
  wczytaj_dzwiek('rakieta.wav', 18,true);
  wczytaj_dzwiek('namierz.wav', 19,false,false);
  wczytaj_dzwiek('strzal1.wav', 20,false);
  wczytaj_dzwiek('rikoszet1.wav', 21,false);
  //ludzie
  wczytaj_dzwiek('wrzask1.wav', 22,false);
  wczytaj_dzwiek('wrzask2.wav', 23,false);
  wczytaj_dzwiek('wrzask3.wav', 24,false);
  wczytaj_dzwiek('wrzask4.wav', 25,false);

  //zli
  wczytaj_dzwiek('wrwrzask1.wav', 26,false);
  wczytaj_dzwiek('wrwrzask2.wav', 27,false);
  wczytaj_dzwiek('wrwrzask3.wav', 28,false);
  wczytaj_dzwiek('wrwrzask4.wav', 29,false);

{  muzstream := FSOUND_Stream_Open('dane\muz.mp3', FSOUND_LOOP_NORMAL or FSOUND_NORMAL, 0, 0);
  muzchannel := FSOUND_Stream_Play(FSOUND_FREE, muzstream);
  FSOUND_SetPaused(muzchannel, true);}


  muzstream := FSOUND_Stream_Open('dane\muzmenu.mp3', FSOUND_LOOP_NORMAL or FSOUND_NORMAL or FSOUND_HW2D, 0, 0);
  muzchannel := FSOUND_Stream_PlayEx(FSOUND_FREE, muzstream, 0, false);

  FSOUND_SetSFXMasterVolume(ustawienia.voldzw);
  FSOUND_SetVolumeAbsolute(muzchannel, ustawienia.volmuz);

end;

procedure TForm1.muzyke_wlacz(i:integer; loop:boolean);
var s:string;
begin
  FSOUND_Stream_Stop(muzstream);
  FSOUND_Stream_Close(muzstream);

  case i of
     0:begin
       if gra.nazwamp3='' then begin
          s:='muz'+inttostr(gra.planeta mod 5);
       end
          else s:=gra.nazwamp3;
       end;
     1:s:='muzmenu';
     2:s:='intro';
     3:s:='lost';
     4:s:='win';
  end;

  if loop then
      muzstream := FSOUND_Stream_Open(pansichar(ansistring('dane\'+s+'.mp3')), FSOUND_LOOP_NORMAL or FSOUND_NORMAL or FSOUND_HW2D, 0, 0)
  else
      muzstream := FSOUND_Stream_Open(pansichar(ansistring('dane\'+s+'.mp3')), FSOUND_NORMAL or FSOUND_HW2D, 0, 0);
  muzchannel := FSOUND_Stream_PlayEx(FSOUND_FREE, muzstream, 0, true);
  FSOUND_SetPaused(muzchannel, false);

  FSOUND_SetSFXMasterVolume(ustawienia.voldzw);
  FSOUND_SetVolumeAbsolute(muzchannel, ustawienia.volmuz);
end;

procedure TForm1.muzyke_wylacz;
begin
   FSOUND_SetPaused(muzchannel, true);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  PixelFormat: GLuint;
  rectScreen: TRECT;
  width,height,bits,freq:integer;
begin
  ChDir(ExtractFilePath(Application.ExeName));

  wczytajkfg;

  width:=ustawienia.rozdzx;
  height:=ustawienia.rozdzy;
  bits:=ustawienia.bity;
  freq:=ustawienia.hz;
  fullscreen:=ustawienia.fullscreen;

   //if (ParamCount>=1) and (ParamStr(1)='f') then fullscreen:=true;

	if (fullscreen) then        // Attempt fullscreen mode?
	begin
        fillchar(dmScreenSettings, sizeof(dmScreenSettings),0);
		dmScreenSettings.dmSize         := sizeof(dmScreenSettings);     // Size of the devmode structure
		dmScreenSettings.dmPelsWidth	:= width;                        // Selected screen width
		dmScreenSettings.dmPelsHeight	:= height;                       // Selected screen height
		dmScreenSettings.dmBitsPerPel	:= bits;	                        // Selected bits per pixel
        dmScreenSettings.dmDisplayFrequency := freq;
		dmScreenSettings.dmFields       := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT or DM_DISPLAYFREQUENCY;

		// Try to set selected mode and get results. NOTE: CDS_FULLSCREEN gets rid of start bar.
		if (ChangeDisplaySettings(dmScreenSettings,CDS_FULLSCREEN) <> DISP_CHANGE_SUCCESSFUL) then
		begin
			// If the mode fails, offer two options. Quit or use windowed mode.
			if (MessageBox(handle,'The requested fullscreen mode is not supported by\nyour video card. Use windowed mode instead?','NeHe GL',MB_YESNO or MB_ICONEXCLAMATION) = IDYES) then
			begin
				fullscreen := false;       // Windowed mode selected. Fullscreen = false
			end
			else
			begin
				// Pop up a message box letting user know the program is closing.
				MessageBox(handle,'Program will now close.','ERROR',MB_OK or MB_ICONSTOP);
				//return false;           // Return false
			end
		end;

      FormStyle := fsStayOnTop;
      BorderStyle := bsNone;
      WindowState := wsMaximized;

      ShowCursor(false);
	end else begin
      Form1.clientWidth:=ustawienia.rozdzx;
      Form1.clientHeight:=ustawienia.rozdzy;
    end;

  h_DC := GetDC(Form1.Handle);
  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  if (PixelFormat = 0) then
  begin
    MessageBox(0, 'Cant''t Find A Suitable PixelFormat.', 'Error', MB_OK or MB_ICONERROR);
    PostQuitMessage(0); // komunikat zamyka program
    exit;
  end;

  if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
  begin
    MessageBox(0, 'Can''t Set The PixelFormat.', 'Error', MB_OK or MB_ICONERROR);
    PostQuitMessage(0);
    exit;
  end;

  h_RC := wglCreateContext(h_DC);
  if (h_RC = 0) then
  begin
    MessageBox(0, 'Can''t Create A GL Rendering Context.', 'Error', MB_OK or MB_ICONERROR);
    PostQuitMessage(0);
    exit;
  end;

  if (not wglMakeCurrent(h_DC, h_RC)) then
  begin
    MessageBox(0, 'Can''t activate GLRC.', 'Error', MB_OK or MB_ICONERROR);
    PostQuitMessage(0);
    exit;
  end;

  rectScreen:=GetClientRect();
  GLInit(rectScreen.right, rectScreen.bottom);

  if not glext_LoadExtension('GL_version_1_2') then begin
    MessageBox(0, 'Wymagany jest OpenGL w wersji 1.2', 'Error', MB_OK or MB_ICONERROR);
    PostQuitMessage(0);
    exit;
  end;


  
  dupa:=gluNewQuadric();

end;

procedure TForm1.FormResize(Sender: TObject);
begin
GLResizeScene( Form1.clientWidth, Form1.clientHeight);
end;

procedure TForm1.PowerTimer1Render(Sender: TObject);
begin
  RenderScene;
end;

procedure TForm1.PowerTimer1Process(Sender: TObject);
begin
  FrameMath;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button=mbleft then myszguzikl:=true
else if button=mbright then myszguzikp:=true;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button=mbleft then myszguzikl:=false
else if button=mbright then myszguzikp:=false;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
myszsx:=x;
myszsy:=y;
end;

procedure TForm1.TimerCzasTimer(Sender: TObject);
begin
dec(gra.czas);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
if fullscreen then begin
   FormStyle := fsNormal;
   BorderStyle := bsSingle;
   WindowState := wsNormal;
   ShowCursor(true);
end;

{  FSOUND_Sample_Free(samp1);
  FSOUND_Sample_Free(samp2);
  FSOUND_Sample_Free(samp3);
}
  FSOUND_Close();

end;

end.
