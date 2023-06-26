unit api_func;

interface

uses Windows, Messages, OpenGl, Gl, Glu;

procedure GLInit(AWidth: GLsizei; AHeight: GLsizei);
procedure GLResizeScene(AWidth: GLsizei; AHeight: GLsizei);

// function WinMain(hInstance: HINST; hPrevInstance: HINST; lpCmdLine: PChar; nCmdShow: integer): integer; stdcall;

type
  TCurrentScreenParams = record
    Aspect: double;
    Width, Height: double;
    HudWidth, HudHeight: double;
    MenuWidth, MenuHeight, MenuCenter: double;
    MenuOffsetX: double;
  end;

var
  keys: array [0 .. 255] of BOOL; // tablicy klawiatury
  h_RC: HGLRC;
  h_DC: HDC; // uchwyt programu

  currentScreenParams: TCurrentScreenParams;

const
  MENU_WIDTH = 640;
  MENU_HEIGHT = 480;
  HUD_WIDTH = 640;
  HUD_HEIGHT = 480;

implementation

uses Render, unit1, Controls, unittimer;

// Inicjacja OpenGl

procedure RecalculateScreenSize(AWidth: GLsizei; AHeight: GLsizei);
var
  menuAspect, menuWidthCalc, hudAspect: double;
begin
  if AWidth <= 0 then
    AWidth := 1;
  if AHeight <= 0 then
    AHeight := 1;

  currentScreenParams.Width := AWidth;
  currentScreenParams.Height := AHeight;
  currentScreenParams.Aspect := currentScreenParams.Width / currentScreenParams.Height;

  menuAspect := MENU_WIDTH / MENU_HEIGHT;
  currentScreenParams.MenuHeight := MENU_HEIGHT;
  currentScreenParams.MenuWidth := MENU_WIDTH;

  menuWidthCalc := currentScreenParams.MenuHeight * currentScreenParams.Aspect;
  // 640;
  if (menuWidthCalc / currentScreenParams.MenuHeight) > menuAspect then
    currentScreenParams.MenuOffsetX := (menuWidthCalc - MENU_WIDTH) / 2
  else
    currentScreenParams.MenuOffsetX := 0;

  currentScreenParams.MenuCenter := currentScreenParams.MenuWidth / 2;

  //
  hudAspect := HUD_WIDTH / HUD_HEIGHT;
  currentScreenParams.HudHeight := HUD_HEIGHT;
  currentScreenParams.HudWidth := currentScreenParams.HudHeight * currentScreenParams.Aspect;
  if (currentScreenParams.HudWidth / currentScreenParams.HudHeight) < hudAspect then
    currentScreenParams.HudWidth := currentScreenParams.HudHeight * hudAspect;
end;

procedure GLInit(AWidth: GLsizei; AHeight: GLsizei);
begin
  // glEnable(GL_TEXTURE_2D); // Mapowanie tekstur 2D
  glClearColor(0, 0.3, 0.7, 0); // Kolor tla
  glClearDepth(1.0); // Czyszczenie bufora
  glEnable(GL_DEPTH_TEST); // W³¹cz testowanie g³êbokoœci
  glDepthFunc(GL_LEQUAL); // Rodzaj testowania g³êbokoœci : GL_LESS

  RecalculateScreenSize(AWidth, AHeight);

  gluPerspective(60.0, currentScreenParams.Aspect, 0.2, 1300.0);
  glMatrixMode(GL_MODELVIEW); // ustawienie widoku modelu
  glLoadIdentity(); // Reset macierzy

  glShadeModel(GL_SMOOTH);

end;

// Zmiana rozmiaru okna

procedure GLResizeScene(AWidth: GLsizei; AHeight: GLsizei);
begin
  if (AHeight = 0) then // ochrona przed blêdem wysokosci
    AHeight := 1;

  glViewport(0, 0, AWidth, AHeight); // Reset okna

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

  RecalculateScreenSize(AWidth, AHeight);
  gluPerspective(60.0, currentScreenParams.Aspect, 0.2, 1300.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
end;

(* function WndProc(hWnd: HWND;
  message: UINT;
  wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;

  var
  Screen: TRECT;
  PixelFormat: GLuint;

  const
  pfd: PIXELFORMATDESCRIPTOR = (
  nSize: sizeof(PIXELFORMATDESCRIPTOR);
  nVersion: 1;
  dwFlags: PFD_DRAW_TO_WINDOW
  or PFD_SUPPORT_OPENGL
  or PFD_DOUBLEBUFFER;
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

  begin
  Result := 0;
  case (message) of // Obsluga komunikatów
  WM_CREATE:
  begin
  end;
  WM_DESTROY, WM_CLOSE:
  begin
  ChangeDisplaySettings(DEVMODE(nil^), 0);

  wglMakeCurrent(h_DC, 0);
  wglDeleteContext(h_RC);
  ReleaseDC(hWnd, h_DC);

  PostQuitMessage(0);
  end;
  WM_KEYDOWN:
  begin
  keys[wParam] := TRUE;
  end;
  WM_KEYUP:
  begin
  keys[wParam] := FALSE;
  end;
  WM_SIZE:
  begin
  //        GLReSizeScene(LOWORD(lParam), HIWORD(lParam));
  end;
  else
  begin
  Result := DefWindowProc(hWnd, message, wParam, lParam);
  exit;
  end;
  end;
  end;
*)
(* function WinMain(hInstance: HINST; hPrevInstance: HINST; lpCmdLine: PChar; nCmdShow: integer): integer; stdcall;
  var
  msg: TMsg; // Komunikat
  wc: TWndClass; // Klasa okna
  h_Wnd: HWND; // Uchwyt
  dmScreenSettings: DEVMODE;
  kom1: shortstring;
  kom2: pchar;

  begin
  ZeroMemory(@wc, sizeof(wc));

  wc.style := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
  wc.lpfnWndProc := @WndProc;
  wc.hInstance := hInstance;
  wc.hCursor := LoadCursor(0, IDC_ARROW);
  wc.lpszClassName := 'OpenGL WinClass';

  if (RegisterClass(wc) = 0) then
  begin
  MessageBox(0, 'Wyst¹pil bl¹d podczas próby rejestracji klasy okna', 'Error', MB_OK or MB_ICONERROR);
  Result := 0;
  exit;
  end;

  h_wnd:=form1.Handle;
  {  h_Wnd := CreateWindow(
  'OpenGL WinClass',
  'basecode', // Tytul programu
  WS_POPUP or
  WS_CLIPCHILDREN or
  WS_CLIPSIBLINGS,
  0, 0, // Pozycja okna na ekranie
  800, 600, // Szerokosc i wysokosc okna
  0,
  0,
  hInstance,
  nil);}

  if (h_Wnd = 0) then
  begin
  MessageBox(0, 'Wyst¹pil bl¹d podczas próby tworzenia okna', 'Error', MB_OK or MB_ICONERROR);
  Result := 0;
  exit;
  end;

  ZeroMemory(@dmScreenSettings, sizeof(DEVMODE));
  dmScreenSettings.dmSize := sizeof(DEVMODE);
  dmScreenSettings.dmPelsWidth := 800; // Szerokosc
  dmScreenSettings.dmPelsHeight := 600; // Wysokosc
  dmScreenSettings.dmFields := DM_PELSWIDTH or DM_PELSHEIGHT; // Color Depth
  //  ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN); // Przel¹cz na pelny ekran

  ShowWindow(h_Wnd, SW_SHOW);
  UpdateWindow(h_Wnd);
  SetFocus(h_Wnd);

  while (true) do
  begin
  while (PeekMessage(msg, 0, 0, 0, PM_NOREMOVE)) do
  begin
  if (GetMessage(msg, 0, 0, 0)) then
  begin
  TranslateMessage(msg);
  DispatchMessage(msg);
  end
  else
  begin
  Result := 1;
  exit;
  end;
  end;

  RenderScene;

  if (keys[VK_ESCAPE]) then begin;
  SendMessage(h_Wnd, WM_CLOSE, 0, 0);
  end;

  end;

  end;
*)
end.
