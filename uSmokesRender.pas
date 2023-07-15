unit uSmokesRender;

interface

uses
  system.generics.collections,
  gl, glu;

procedure rysuj_dymy;

implementation

uses
  uSmokesLogic,
  ZGLTextures,
  ZGLGraphProcs,
  uRenderConst,
  unitTimer;

// ---------------------------------------------------------------------------
procedure rysuj_dymy;
var
  a: integer;
  xod, xdo, zod, zdo, x1, z1: real;
begin
  // dym
  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glEnable(GL_COLOR_MATERIAL);
  glDisable(GL_LIGHTING);
  // glDisable(GL_FOG);
  glPolygonMode(GL_FRONT, GL_FILL);
  glEnable(GL_BLEND);
  glDepthMask(GL_FALSE);
  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);

  xod := gracz.x - widocznosc * ziemia.wlk;
  xdo := gracz.x + widocznosc * ziemia.wlk;
  zod := gracz.z - widocznosc * ziemia.wlk;
  zdo := gracz.z + widocznosc * ziemia.wlk;

  glMaterialf(GL_FRONT, GL_SHININESS, 1);
  for a := 0 to SmokesList.Count - 1 do
    if SmokesList[a].jest and (SmokesList[a].rodz <> 2) then
      with SmokesList[a] do
      begin

        if gra.etap = 1 then
        begin
          if x < xod then
            x1 := x - ziemia.px * 2
          else if x > xdo then
            x1 := x + ziemia.px * 2
          else
            x1 := x;
          if z < zod then
            z1 := z - ziemia.pz * 2
          else if z > zdo then
            z1 := z + ziemia.pz * 2
          else
            z1 := z;
        end
        else
        begin
          x1 := x;
          z1 := z;
        end;

        if ((x1 >= xod) and (x1 <= xdo) and (z1 >= zod) and (z1 <= zdo)) or (gra.etap <> 1) then
        begin
          if rodz = 0 then
            glBlendFunc(GL_SRC_ALPHA, GL_ONE)
          else
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

          glColor4f(kolr, kolg, kolb, przezr);
          wlacz_teksture(tekstura);
          glPushMatrix;
          rysuj_sprajt(x1, y, z1, rozmiar, right, up, obrot);
          glPopMatrix;
          wylacz_teksture;
        end;

      end;
  wylacz_teksture;

  glPopAttrib;
end;

end.
