unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, api_func, opengl, ExtCtrls, render, gl, glu, glext,
  PowerTimers,
  //ZGLTextures,
  PowerInputs, PowerTypes,
  directinput8,
  uConfig, uConfigVars, uController,
  uSfx;

type
  TfrmMain = class(TForm)
    PowerTimer1: TPowerTimer;
    PwrInp: TPowerInput;
    TimerCzas: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PowerTimer1Render(Sender: TObject);
    procedure PowerTimer1Process(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerCzasTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EnableFullscreenOGL(ScreenConfig: TScreenConfig);
    procedure DisableFullscreenOGL(ScreenConfig: TScreenConfig);
    procedure FormDestroy(Sender: TObject);
  public
    procedure wczytajkfg;
  end;

const
  pfd: PIXELFORMATDESCRIPTOR = (nSize: sizeof(PIXELFORMATDESCRIPTOR); nVersion: 1;
    dwFlags: PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER; iPixelType: PFD_TYPE_RGBA; cColorBits: 32;
    cRedBits: 0; cRedShift: 0; cGreenBits: 0; cBlueBits: 0; cBlueShift: 0; cAlphaBits: 0; cAlphaShift: 0; cAccumBits: 0;
    cAccumRedBits: 0; cAccumGreenBits: 0; cAccumBlueBits: 0; cAccumAlphaBits: 0; cDepthBits: 32; cStencilBits: 0;
    cAuxBuffers: 0; iLayerType: PFD_MAIN_PLANE; bReserved: 0; dwLayerMask: 0; dwVisibleMask: 0; dwDamageMask: 0);

{  pfd: PIXELFORMATDESCRIPTOR = (
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
    cAlphaBits: 0; //! bylo 0
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
 }
var
  frmMain: TfrmMain;

  GameController: TGameController;

  dupa: PGLUquadricObj;

  myszsx, myszsy: Integer;
  myszguzikl, myszguzikp: boolean;

  fullscreen: boolean;
  dmScreenSettings: DEVMODE; // Device mode

procedure EnableFullscreen(AForm: TForm; ScreenConfig: TScreenConfig);
procedure DisableFullscreen(AForm: TForm; ScreenConfig: TScreenConfig);
procedure InitOGL(AForm: TForm);

  function ChangeDisplaySettingsEx3(lpszDeviceName: LPCWSTR; lpDevMode: PDeviceModeW;
        wnd: HWND; dwFlags: DWORD; lParam: Pointer): Longint; stdcall;

implementation

uses
  unittimer, UnitStart,
  //uFBOUtils,
  //uRenderGlobal,
//  uSoundFX,
//  uSoundFXStealth,
  uGraphicModes;

{$R *.dfm}

function ChangeDisplaySettingsEx3; external user32 name 'ChangeDisplaySettingsW';

procedure TfrmMain.wczytajkfg;
var
  a, X, Y: Integer;
  b: boolean;
begin
  try
    Config := TConfig.Create(GetConfigFilePath);
    Config.JsonHeader := ConfigHeader;
    GameController := Config.GameController;
    GameController.SetInput(PwrInp);
    Config.PrepareControls;
    Config.SetDefaults;
    Config.LoadConfig;

    widocznosc := Config.Display.VisibilityRange;
    widocznoscpil := 20;
    if widocznoscpil > widocznosc - 5 then
      widocznoscpil := widocznosc - 5;

    if widocznoscscen > widocznosc - 2 then
      widocznoscscen := widocznosc - 2;
    if widocznoscscen > 40 then
      widocznoscscen := 40;

    if widocznoscscencien > widocznoscscen - 10 then
      widocznoscscencien := widocznoscscen - 10;

    if widocznoscdzial > widocznosc then
      widocznoscdzial := widocznosc;
    if widocznoscdzial > 50 then
      widocznoscdzial := 50;

    odlwidzenia := widocznosc * 24;

  except
    on e: Exception do
    begin
      MessageBox(Handle,
        pwidechar('No config file or file is corrupted. Please, run the configuration first.'#13#10 + e.Message),
        'Configuration error', MB_OK or MB_TASKMODAL or MB_ICONERROR);
      Application.Terminate;
      halt(0);
      exit;
    end;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  width, height, bits, freq: Integer;
  reslt: longint;

  s: string;
  a: integer;
begin
  Sfx := TSfx.Create(self);

  wczytajkfg;

  if Config.Screen.fullscreen then
    EnableFullscreenOGL(Config.Screen)
  else
    DisableFullscreenOGL(Config.Screen);

  dupa := gluNewQuadric();

//  useFBO := true;
//  UseMainFBOTexture := false;
//
//  MainFBOTexture := TFBOTexture.Create;
//  MainFBOTexture.SetTextureSize
//    ( { frmMain.clientWidth, frmMain.clientHeight } 160, 192);
//  MainFBOTexture.SetViewportSize
//    ( { frmMain.clientWidth, frmMain.clientHeight } 160, 192);
//  MainFBOTexture.Initialize;
//
//  SFX := TSFX.Create;
//  SFXGame := TSFXGame.Create;

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Sfx.Free;
  Sfx := nil;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  GLResizeScene(frmMain.clientWidth, frmMain.clientHeight);
end;

procedure TfrmMain.PowerTimer1Render(Sender: TObject);
begin
//  RenderTextureTitleObjects;
  glLoadIdentity();
  GLResizeScene(frmMain.clientWidth, frmMain.clientHeight);
  RenderScene;
end;

procedure TfrmMain.PowerTimer1Process(Sender: TObject);
begin
  FrameMath;
end;

procedure TfrmMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
{  if Button = mbleft then
  begin
    EnableFullscreen(self, Config.Screen);
    LoadTextures;
  end;
  if Button = mbright then
  begin
    DisableFullscreen(self, Config.Screen);
    LoadTextures;
  end;}

  if Button = mbleft then
    myszguzikl := true
  else if Button = mbright then
    myszguzikp := true;
end;

procedure TfrmMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbleft then
    myszguzikl := false
  else if Button = mbright then
    myszguzikp := false;
end;

procedure TfrmMain.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  myszsx := X;
  myszsy := Y;
end;

procedure TfrmMain.DisableFullscreenOGL(ScreenConfig: TScreenConfig);
begin
  DisableFullscreen(self, ScreenConfig);
  InitOGL(Self);
end;

procedure TfrmMain.EnableFullscreenOGL(ScreenConfig: TScreenConfig);
begin
  EnableFullscreen(self, ScreenConfig);
  InitOGL(Self);
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if fullscreen then
  begin
    DisableFullscreen(self, Config.Screen);
  end;
//  SFX.Cleanup;
end;

procedure TfrmMain.TimerCzasTimer(Sender: TObject);
begin
  inc(gra.czas);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  // WindowState := wsMaximized;
  BringWindowToTop(Handle);
end;

procedure EnableFullscreen(AForm: TForm; ScreenConfig: TScreenConfig);
begin
//  frmMain.PowerTimer1.MayRender := false;
//  frmMain.PowerTimer1.MayProcess := false;
  if (ScreenConfig.FullScreen) then // Attempt fullscreen mode?
  begin
    fillchar(dmScreenSettings, sizeof(dmScreenSettings), 0);
    dmScreenSettings.dmSize := sizeof(dmScreenSettings);

    dmScreenSettings.dmPelsWidth := ScreenConfig.Width; // Selected screen width
    dmScreenSettings.dmPelsHeight := ScreenConfig.Height; // Selected screen height
    dmScreenSettings.dmBitsPerPel := ScreenConfig.BPP; // Selected bits per pixel
    dmScreenSettings.dmDisplayFrequency := ScreenConfig.Hz;
    dmScreenSettings.dmFields := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT or DM_DISPLAYFREQUENCY;

//    reslt := ChangeDisplaySettingsEx(PWideChar(GetCurrentDeviceName), dmScreenSettings, 0, CDS_FULLSCREEN, nil);
    // Try to set selected mode and get results. NOTE: CDS_FULLSCREEN gets rid of start bar.
//    if reslt <>
//      DISP_CHANGE_SUCCESSFUL then
    if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) <> DISP_CHANGE_SUCCESSFUL) then
    begin
      // If the mode fails, offer two options. Quit or use windowed mode.
      if (MessageBox(AForm.Handle,
        'The requested fullscreen mode is not supported by your video card. Use windowed mode instead?',
        'Stealth Remake', MB_YESNO or MB_ICONEXCLAMATION) = IDYES) then
      begin
        DisableFullscreen(AForm, ScreenConfig);
      end
      else
      begin
        // Pop up a message box letting user know the program is closing.
        MessageBox(AForm.Handle, 'Program will now close.', 'ERROR',
          MB_OK or MB_ICONSTOP);
        PostQuitMessage(0); // komunikat zamyka program
        exit;
      end
    end
    else
    begin
      AForm.FormStyle := fsStayOnTop;
      AForm.BorderStyle := bsNone;
      AForm.WindowState := wsMaximized;

      ShowCursor(false);
      fullscreen := true;
    end;
  end
  else
    DisableFullscreen(AForm, ScreenConfig);
end;

procedure InitOGL(AForm: TForm);
var
  PixelFormat: GLuint;
  rectScreen: TRECT;
begin
  h_DC := GetDC(frmMain.Handle);
  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  if (PixelFormat = 0) then
  begin
    MessageBox(0, 'Cant''t Find A Suitable PixelFormat.', 'Error',
      MB_OK or MB_ICONERROR);
    PostQuitMessage(0); // komunikat zamyka program
    exit;
  end;

  if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
  begin
    MessageBox(0, 'Can''t Set The PixelFormat.', 'Error',
      MB_OK or MB_ICONERROR);
    PostQuitMessage(0);
    exit;
  end;

  h_RC := wglCreateContext(h_DC);
  if (h_RC = 0) then
  begin
    MessageBox(0, 'Can''t Create A GL Rendering Context.', 'Error',
      MB_OK or MB_ICONERROR);
    PostQuitMessage(0);
    exit;
  end;

  if (not wglMakeCurrent(h_DC, h_RC)) then
  begin
    MessageBox(0, 'Can''t activate GLRC.', 'Error', MB_OK or MB_ICONERROR);
    PostQuitMessage(0);
    exit;
  end;

  Windows.GetClientRect(AForm.Handle, rectScreen);
  GLInit(rectScreen.right, rectScreen.bottom);

  if not glext_LoadExtension('GL_version_1_2') then
  begin
    MessageBox(0, 'Wymagany jest OpenGL w wersji 1.2', 'Error', MB_OK or MB_ICONERROR);
    PostQuitMessage(0);
    exit;
  end;

//  frmMain.PowerTimer1.MayRender := true;
//  frmMain.PowerTimer1.MayProcess := true;
end;

procedure DisableFullscreen(AForm: TForm; ScreenConfig: TScreenConfig);
begin
  FullScreenOff;
  fullscreen := false;
//  frmMain.PowerTimer1.MayRender := false;
//  frmMain.PowerTimer1.MayProcess := false;
  AForm.FormStyle := fsNormal;
  AForm.WindowState := wsNormal;
{$IFDEF DEBUG_FEATURE}
  AForm.BorderStyle := bsSizeable;
  AForm.BorderIcons := [biSystemMenu, biMinimize, biMaximize];
{$ELSE}
  AForm.BorderStyle := bsSingle;
  AForm.BorderIcons := [biSystemMenu, biMinimize];
{$ENDIF}
  AForm.clientWidth := ScreenConfig.width;
  AForm.clientHeight := ScreenConfig.height;

  ShowCursor(true);
end;



end.
