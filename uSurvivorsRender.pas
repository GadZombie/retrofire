unit uSurvivorsRender;

interface

uses
  GL,
  uSurvivorsLogic;

type
  TSurvivorsRenderer = class
  private
    xod, xdo, zod, zdo: extended;

    procedure RenderHead(ASurvivor: TSurvivor);
    procedure RenderSurvivor(ASurvivor: TSurvivor);
    procedure RenderObject(AId, ATexture: integer);
    procedure RenderBody(ASurvivor: TSurvivor);
    procedure RotateBody(ASurvivor: TSurvivor);
  public
    procedure RenderSurvivors;
  end;

var
  SurvivorsRenderer: TSurvivorsRenderer;
  l_survivors: array [0 .. 14] of GLUint;

implementation

uses
  OpenGl, Glu, GLext,
  uRenderObjects,
  uRenderConst,
  ZGLTextures,
  unittimer,
  GlobalConsts;

procedure TSurvivorsRenderer.RenderObject(AId: integer; ATexture: integer);
begin
  wlacz_teksture(ATexture);
  glCallList(l_survivors[AId]);
end;

// ---------------------------------------------------------------------------
procedure TSurvivorsRenderer.RenderHead(ASurvivor: TSurvivor);
const
  HEAD_TRANS_Y = 0.7;
  HEAD_TRANS_Z = -0.1;
var
  tx: integer;
begin
  if not ASurvivor.zly then
    tx := 5
  else
    tx := 8;

  glPushMatrix;

  if cheaty.bigHeads then
  begin
    glTranslatef(0, -1.5, 0);
    glScalef(4, 4, 4)
  end
  else
  begin
    glTranslatef(0, -0.15, 0);
    glScalef(1.5, 1.5, 1.5);
  end;

  glTranslatef(0, HEAD_TRANS_Y, HEAD_TRANS_Z);
  glRotatef(ASurvivor.headSideAngle, 0, 1, 0);
  glRotatef(ASurvivor.headUpAngle, 1, 0, 0);
  glTranslatef(0, -HEAD_TRANS_Y, -HEAD_TRANS_Z);

  RenderObject(2, tx);
  RenderObject(14, tx);
  glPopMatrix;

end;

procedure TSurvivorsRenderer.RotateBody(ASurvivor: TSurvivor);
var
  angle: extended;
begin
  if abs(ASurvivor.headSideAngle) > 40 then
  begin
    if ASurvivor.headSideAngle > 0 then
      angle := (ASurvivor.headSideAngle - 40) / 1.5
    else
      angle := (ASurvivor.headSideAngle + 40) / 1.5;
  end
    else
      angle := 0;
  glRotatef(angle, 0, 1, 0);
end;

procedure TSurvivorsRenderer.RenderBody(ASurvivor: TSurvivor);
var
  tx: integer;
begin
  if not ASurvivor.zly then
    tx := 5
  else
    tx := 8;

  glPushMatrix;
  RotateBody(ASurvivor);
  RenderObject(0, tx);
  RenderObject(1, tx);
  RenderObject(13, tx);
  glPopMatrix;
end;

procedure TSurvivorsRenderer.RenderSurvivor(ASurvivor: TSurvivor);

var
  a, g, tx, a1: integer;
  x1, z1: real;
begin
  with ASurvivor do
  begin
    if not(((nalotnisku >= 0) and (ziemia.widac > 0)) or ((nalotnisku < 0) and (matka.widac > 0)) or zawszewidac) then
      exit;

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

    if (x1 >= xod) and (x1 <= xdo) and (z1 >= zod) and (z1 <= zdo) then
    begin

{debug      if watchingObject = 2 then
      begin
        glColor4f(1, 0.2, 0.2, 1);
        glBegin(GL_LINES);
        glVertex3f(x1, y, z1);
        glVertex3f(watchingSurvivor.x, watchingSurvivor.y, watchingSurvivor.z);
        glEnd;
      end;}

      glPushMatrix;
      glTranslatef(x1, y + 2, z1);

      { debug only
      glEnable(GL_BLEND);
      glColor4f(1, 1, 1, 1);
      pisz_liczbe(round(headSideAngle), 0, 10, 0, 1, right, up);
      pisz_liczbe(round(kier), 0, 8, 0, 1, right, up);
      glDisable(GL_BLEND);
      }

      glRotatef(kier, 0, -1, 0);
      glRotatef(180, 0, 1, 0);

      glTranslatef(0, -2, 0);
      glRotatef(przewroc, 1, 0, 0);
      glTranslatef(0, 2, 0);

      if not zly then
        tx := 5
      else
        tx := 8;

      if (not stoi) or (ani <> 0) then
      begin
        with obiekt[ob_pilot].o do
        begin
          case rodzani of
            0:
              begin // biegnie
                RenderHead(ASurvivor);
                RenderBody(ASurvivor);
                for g := 0 to High(Groups) do
                begin
                  with Groups[g] do
                  begin
                    case g of
                      0, 1, 13: begin
                      end;
                      2, 14: // glowa
                        begin
                        end;
                      3 { rl-g } :
                        begin
                          glPushMatrix;
                          RotateBody(ASurvivor);
                          glTranslatef(0, 0.48, 0);
                          glRotatef(sin(ani * pi180) * 30, 1, 0, 0);
                          glTranslatef(0, -0.48, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;
                      4 { rl-d } :
                        begin
                          glPushMatrix;
                          RotateBody(ASurvivor);
                          glTranslatef(0, 0.48, 0);
                          glRotatef(sin(ani * pi180) * 30, 1, 0, 0);
                          glTranslatef(0, -0.48 - 0.2, 0);
                          glRotatef(-50 + sin(ani * pi180) * 40, 1, 0, 0);
                          glTranslatef(0, 0.2, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;

                      6 { rp-g } :
                        begin
                          glPushMatrix;
                          RotateBody(ASurvivor);
                          glTranslatef(0, 0.48, 0);
                          glRotatef(sin((180 + ani) * pi180) * 30, 1, 0, 0);
                          glTranslatef(0, -0.48, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;
                      5 { rp-d } :
                        begin
                          glPushMatrix;
                          RotateBody(ASurvivor);
                          glTranslatef(0, 0.48, 0);
                          glRotatef(sin((180 + ani) * pi180) * 30, 1, 0, 0);
                          glTranslatef(0, -0.48 - 0.2, 0);
                          glRotatef(-50 + sin((180 + ani) * pi180) * 40, 1, 0, 0);
                          glTranslatef(0, 0.2, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;

                      7 { nl-g } :
                        begin
                          glPushMatrix;
                          glRotatef(-20 + sin(ani * pi180) * 40, 1, 0, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;
                      8, 9 { nl-d } :
                        begin
                          glPushMatrix;
                          glRotatef(-20 + sin(ani * pi180) * 40, 1, 0, 0);
                          glTranslatef(0, -1.4, 0);
                          glRotatef(50 + cos((180 + ani) * pi180) * 40, 1, 0, 0);
                          glTranslatef(0, 1.4, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;

                      12 { np-g } :
                        begin
                          glPushMatrix;
                          glRotatef(-20 + sin((180 + ani) * pi180) * 40, 1, 0, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;
                      10, 11 { np-d } :
                        begin
                          glPushMatrix;
                          glRotatef(-20 + sin((180 + ani) * pi180) * 40, 1, 0, 0);
                          glTranslatef(0, -1.4, 0);
                          glRotatef(50 + cos(ani * pi180) * 40, 1, 0, 0);
                          glTranslatef(0, 1.4, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;
                    else
                      RenderObject(g, tx);
                    end;
                  end;
                end;
              end;

            1:
              begin // macha
                RenderHead(ASurvivor);
                RenderBody(ASurvivor);
                for g := 0 to High(Groups) do
                begin
                  with Groups[g] do
                  begin
                    case g of
                      0, 1, 13: begin
                      end;
                      2, 14: // glowa
                        begin
                        end;
                      3 { rl-g } :
                        begin
                          glPushMatrix;
                          RotateBody(ASurvivor);
                          glTranslatef(-0.64, 0.56, 0);
                          glRotatef(210 + sin((ani) * pi180) * 40, 0, 0, 1);
                          glTranslatef(0.64, -0.56, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;
                      4 { rl-d } :
                        begin
                          glPushMatrix;
                          RotateBody(ASurvivor);
                          glTranslatef(-0.64, 0.56, 0);
                          glRotatef(210 + sin((ani) * pi180) * 40, 0, 0, 1);
                          glTranslatef(0, -0.8, 0);
                          glRotatef(-20 + sin((ani) * pi180) * 30, 0, 0, 1);
                          glTranslatef(0.64, -0.56 + 0.8, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;

                      6 { rp-g } :
                        begin
                          glPushMatrix;
                          RotateBody(ASurvivor);
                          glTranslatef(0.64, 0.56, 0);
                          glRotatef(150 + sin((180 + ani) * pi180) * 40, 0, 0, 1);
                          glTranslatef(-0.64, -0.56, 0);
                          RenderObject(g, tx);
                          glPopMatrix;
                        end;
                      5 { rp-d } :
                        begin
                          glPushMatrix;
                          RotateBody(ASurvivor);
                          glTranslatef(0.64, 0.56, 0);
                          glRotatef(150 + sin((180 + ani) * pi180) * 40, 0, 0, 1);
                          glTranslatef(0, -0.8, 0);
                          glRotatef(20 + sin((180 + ani) * pi180) * 30, 0, 0, 1);
                          glTranslatef(-0.64, -0.56 + 0.8, 0);

                          RenderObject(g, tx);
                          glPopMatrix;
                        end;
                    else
                      RenderObject(g, tx);

                    end;
                  end;
                end;
              end;

          end; // case
        end;
      end
      else
      begin
        // stoi

        // pokaz_obiekt(obiekt[ob_pilot], tx);

        with obiekt[ob_pilot].o do
        begin
          RenderHead(ASurvivor);
          RenderBody(ASurvivor);
          for g := 0 to High(Groups) do
          begin
            with Groups[g] do
            begin
              case g of
                0, 1, 13: begin
                end;
                3, 4, 5, 6: begin
                  glPushMatrix;
                  RotateBody(ASurvivor);
                  RenderObject(g, tx);
                  glPopMatrix;
                end;
                2, 14: // glowa
                  begin
                  end;
              else
                RenderObject(g, tx);

              end;
            end;
          end;
        end;

      end;

      glPopMatrix;

      //cien
      glPushMatrix;
      glTranslatef(x1, 0, z1);
      wlacz_teksture(4);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glEnable(GL_BLEND);
      glEnable(GL_COLOR_MATERIAL);
      glColor4f(1, 1, 1, 0.4);
      glBegin(GL_QUADS);
      glTexCoord2f(0, 1);
      glVertex3f(-1, gdzie_y(x1 - 1, z1 + 1, y) + 0.2, +1);
      glTexCoord2f(1, 1);
      glVertex3f(+1, gdzie_y(x1 + 1, z1 + 1, y) + 0.2, +1);
      glTexCoord2f(1, 0);
      glVertex3f(+1, gdzie_y(x1 + 1, z1 - 1, y) + 0.2, -1);
      glTexCoord2f(0, 0);
      glVertex3f(-1, gdzie_y(x1 - 1, z1 - 1, y) + 0.2, -1);
      glEnd;
      glDisable(GL_BLEND);
      wylacz_teksture;
      glPopMatrix;
    end;
  end;
end;

procedure TSurvivorsRenderer.RenderSurvivors;
var
  a: integer;
begin
  xod := gracz.x - widocznoscpil * ziemia.wlk;
  xdo := gracz.x + widocznoscpil * ziemia.wlk;
  zod := gracz.z - widocznoscpil * ziemia.wlk;
  zdo := gracz.z + widocznoscpil * ziemia.wlk;

  for a := 0 to SurvivorList.Count - 1 do
    if SurvivorList[a].jest then
      RenderSurvivor(SurvivorList[a]);

end;

end.
