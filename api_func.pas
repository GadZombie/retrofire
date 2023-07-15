unit api_func;

interface

uses Windows, Messages, OpenGl, Gl, Glu;

procedure GLInit(AWidth: GLsizei; AHeight: GLsizei);
procedure GLResizeScene(AWidth: GLsizei; AHeight: GLsizei);

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

uses Render, Main, Controls, unittimer;

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

end.
