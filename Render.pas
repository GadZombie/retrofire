unit render;

interface

uses Windows, OpenGl, Gl, Glu, Api_Func, unitTimer, sysutils, obj;

procedure RenderScene;
procedure RenderFrame;

var
  j, t, x, y, z: real;
  i: integer;

  widocznosc: integer = 80; { dla 1300 bylo 60 }
  widocznoscpil: integer = 20; // pilotow
  widocznoscdzial: integer = 80; // dzialka
  widocznoscscen: integer = 53; // sceneria
  widocznoscscencien: integer = 25; // cien scenerii
  widocznosckrzak: integer = 10; // krzaki
  odlwidzenia: integer = 2000;

procedure tworz_obiekty;

implementation

uses unit1, unittex, Forms;

const
  katwidzenia = 70;
  skroltekst: array [0 .. 35] of string = ('POMYS£ NA GR ', 'GRZEGORZ DROZD', '', '', '', 'PROGRAM', 'GRZEGORZ DROZD',
    '', '', '', 'GRAFIKA', 'GRZEGORZ DROZD', '', '', '', 'MUZYKA W MENU', 'FATER (PRO-CREATION, THE ODOURS)',
    'WWW.PRO-CREATION.PL', 'WWW.THEODOURS.NET', '', '', '', 'T£O MUZYCZNE W GRZE I INTRO/OUTRO', 'GRZEGORZ DROZD', '',
    '', '', 'TESTOWANIE', 'KRZYSZTOF RZEPKA', 'GRZEGORZ DROZD', '', '2007 GADZ.PL', '2023 FIXES AND UPDATES',
    'WERSJA ' + PROGRAM_VERSION, 'HTTPS://GADZ.PL/', '');

type
  TMainIntroLine = record
    s: string;
    i: byte;
  end;

var
  mat_spec: array [0 .. 3] of GLFloat = (
    1.00,
    1.00,
    1.00,
    1.0
  );
  mat_1a: array [0 .. 3] of GLFloat = (
    0.70,
    0.70,
    0.70,
    1.0
  );
  mat_1d: array [0 .. 3] of GLFloat = (
    0.70,
    0.70,
    0.70,
    1.0
  );
  mat_1s: array [0 .. 3] of GLFloat = (
    1.00,
    1.00,
    1.00,
    1.0
  );

  pos1: array [0 .. 3] of GLFloat = (
    200.0,
    200.0,
    100.0,
    1.0
  );
  pos1win: array [0 .. 3] of GLFloat = (
    -4200,
    2700,
    -3000,
    1.0
  );
  light_ka0: array [0 .. 3] of GLFloat = (
    0.30,
    0.30,
    0.25,
    1.0
  );
  light_kd0: array [0 .. 3] of GLFloat = (
    0.30,
    0.30,
    0.25,
    1.0
  );
  light_ks0: array [0 .. 3] of GLFloat = (
    0.30,
    0.30,
    0.25,
    1.0
  );

  light_ka1: array [0 .. 3] of GLFloat = (
    0.80,
    0.80,
    0.75,
    1.0
  );
  light_kd1: array [0 .. 3] of GLFloat = (
    0.80,
    0.80,
    0.75,
    1.0
  );
  light_ks1: array [0 .. 3] of GLFloat = (
    1.00,
    1.00,
    0.95,
    1.0
  );

  right: array [0 .. 2] of GLFloat;
  // ={viewMatrix[0], viewMatrix[4], viewMatrix[8]};
  up: array [0 .. 2] of GLFloat;
  // ={viewMatrix[1], viewMatrix[5], viewMatrix[9]};

  // listy:
  l_dzialko, l_dzialkowieza, l_dzialkowieza2, l_dzialkolufa, l_dzialkolufa2, l_rakieta, l_mysliwiec, l_cien: GLUint;
  l_sceneria: array [0 .. ile_obiektow_scenerii - 1] of GLUint;
  l_krzaki: array [0 .. 3] of GLUint;

procedure SetGluOrtho2DForMenu(out width: integer; out height: integer);
begin
  width := trunc(currentScreenParams.MenuWidth);
  height := trunc(currentScreenParams.MenuHeight);
  gluOrtho2D(-currentScreenParams.MenuOffsetX, width + currentScreenParams.MenuOffsetX, 0,
    currentScreenParams.MenuHeight);
end;

// ---------------------------------------------------------------------------
procedure RenderScene;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  // czyszczenie buforow koloru i glebokosci
  // glClear(GL_DEPTH_BUFFER_BIT); // czyszczenie buforow koloru i glebokosci
  glLoadIdentity();
  RenderFrame;
  SwapBuffers(h_DC);
end;

// ---------------------------------------------------------------------------
procedure rysuj_sprajt(sx, sy, sz, sr: real; right, up: array of GLFloat; obrot: real = 0);
begin
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glTranslatef(0.5, 0.5, 0);
  glRotatef(obrot, 0, 0, 1);
  glTranslatef(-0.5, -0.5, 0);
  glMatrixMode(GL_MODELVIEW);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

  glBegin(GL_QUADS);
  glTexCoord2f(0.0, 0.0);
  glVertex3f((sx + (right[0] + up[0]) * -sr), (sy + (right[1] + up[1]) * -sr), (sz + (right[2] + up[2]) * -sr));
  glTexCoord2f(1.0, 0.0);
  glVertex3f((sx + (right[0] - up[0]) * sr), (sy + (right[1] - up[1]) * sr), (sz + (right[2] - up[2]) * sr));
  glTexCoord2f(1.0, 1.0);
  glVertex3f((sx + (right[0] + up[0]) * sr), (sy + (right[1] + up[1]) * sr), (sz + (right[2] + up[2]) * sr));
  glTexCoord2f(0.0, 1.0);
  glVertex3f((sx + (up[0] - right[0]) * sr), (sy + (up[1] - right[1]) * sr), (sz + (up[2] - right[2]) * sr));
  glEnd();

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();

  glMatrixMode(GL_MODELVIEW);

end;

// ---------------------------------------------------------------------------
procedure rysuj_litere(n: integer; sx, sy, sz, sr: real; right, up: array of GLFloat);

var
  mx, my, mx1, my1: real;
begin
  mx := (n mod 8) / 8;
  my := 1 - (n div 8) / 8 - (1 / 8);
  mx1 := mx + (1 / 8);
  my1 := my + (1 / 8);
  wlacz_teksture(0);
  glBegin(GL_QUADS);
  glTexCoord2f(mx, my);
  glVertex3f((sx + (right[0] + up[0]) * -sr), (sy + (right[1] + up[1]) * -sr), (sz + (right[2] + up[2]) * -sr));
  glTexCoord2f(mx1, my);
  glVertex3f((sx + (right[0] - up[0]) * sr), (sy + (right[1] - up[1]) * sr), (sz + (right[2] - up[2]) * sr));
  glTexCoord2f(mx1, my1);
  glVertex3f((sx + (right[0] + up[0]) * sr), (sy + (right[1] + up[1]) * sr), (sz + (right[2] + up[2]) * sr));
  glTexCoord2f(mx, my1);
  glVertex3f((sx + (up[0] - right[0]) * sr), (sy + (up[1] - right[1]) * sr), (sz + (up[2] - right[2]) * sr));
  glEnd();
  wylacz_teksture;
end;

// ---------------------------------------------------------------------------
procedure pisz_liczbe(n: int64; sx, sy, sz, sr: real; right, up: array of GLFloat);

var
  a: integer;
  s: string;
  x: real;
begin
  s := inttostr(n);
  x := sx - ((length(s) - 1)) * sr;
  glPushMatrix;
  for a := 1 to length(s) do
  begin
    rysuj_litere(ord(s[a]) - 48, sx, sy, sz, sr, right, up);
    glTranslatef(right[0] * sr * 2, right[1] * sr * 2, right[2] * sr * 2);
  end;
  glPopMatrix;
end;

// ---------------------------------------------------------------------------
procedure rysuj_litere2d(n: integer; sx, sy, sr: real);

var
  mx, my, mx1, my1: real;
begin
  mx := (n mod 8) / 8;
  my := 1 - (n div 8) / 8 - (1 / 8);
  mx1 := mx + (1 / 8);
  my1 := my + (1 / 8);
  wlacz_teksture(0);
  glBegin(GL_QUADS);
  glTexCoord2f(mx, my);
  glVertex2f((sx + -sr), (sy + -sr));
  glTexCoord2f(mx1, my);
  glVertex2f((sx + sr), (sy + -sr));
  glTexCoord2f(mx1, my1);
  glVertex2f((sx + sr), (sy + sr));
  glTexCoord2f(mx, my1);
  glVertex2f((sx + -sr), (sy + sr));
  glEnd();
  wylacz_teksture;
end;

// ---------------------------------------------------------------------------
procedure rysuj_ikone(n: integer; sx, sy, sr: real);

var
  mx, my, mx1, my1: real;
begin
  mx := (n mod 4) / 4;
  my := 1 - (n div 4) / 4 - (1 / 4);
  mx1 := mx + (1 / 4);
  my1 := my + (1 / 4);
  wlacz_teksture(13);
  glBegin(GL_QUADS);
  glTexCoord2f(mx, my);
  glVertex2f((sx + -sr), (sy + -sr));
  glTexCoord2f(mx1, my);
  glVertex2f((sx + sr), (sy + -sr));
  glTexCoord2f(mx1, my1);
  glVertex2f((sx + sr), (sy + sr));
  glTexCoord2f(mx, my1);
  glVertex2f((sx + -sr), (sy + sr));
  glEnd();
  wylacz_teksture;
end;

// ---------------------------------------------------------------------------
procedure pisz_liczbe2d(n: int64; sx, sy, sr: real);

var
  a: integer;
  s: string;
  x: real;
begin
  s := inttostr(n);
  x := sx - ((length(s) - 1)) * sr;
  glPushMatrix;
  for a := 1 to length(s) do
  begin
    rysuj_litere2d(ord(s[a]) - 48, sx, sy, sr);
    glTranslatef(sr * 2, 0, 0);
  end;
  glPopMatrix;
end;

// ---------------------------------------------------------------------------
procedure pisz2d(s: string; sx, sy, sr: real; margines: byte = 0);

var
  a: integer;
  px: real;
begin
  if margines = 1 then
    sx := sx - (length(s) - 1) * sr // srodek
  else if margines = 2 then
    sx := sx - (length(s) - 1) * sr * 2; // prawy

  px := 0;
  glPushMatrix;
  for a := 1 to length(s) do
  begin
    case s[a] of
      #48 .. #57:
        rysuj_litere2d(ord(s[a]) - 48, sx, sy, sr);
      #65 .. #90:
        rysuj_litere2d(ord(s[a]) - 55, sx, sy, sr);
      #97 .. #122:
        rysuj_litere2d(ord(s[a]) - 87, sx, sy, sr);
      '.':
        rysuj_litere2d(36, sx, sy, sr);
      ':':
        rysuj_litere2d(37, sx, sy, sr);
      ',':
        rysuj_litere2d(38, sx, sy, sr);
      '?':
        rysuj_litere2d(39, sx, sy, sr);
      '!':
        rysuj_litere2d(40, sx, sy, sr);
      'π', '•':
        rysuj_litere2d(41, sx, sy, sr);
      'Ê', '∆':
        rysuj_litere2d(42, sx, sy, sr);
      'Í', ' ':
        rysuj_litere2d(43, sx, sy, sr);
      '≥', '£':
        rysuj_litere2d(44, sx, sy, sr);
      'Ò', '—':
        rysuj_litere2d(45, sx, sy, sr);
      'Û', '”':
        rysuj_litere2d(46, sx, sy, sr);
      'ú', 'å':
        rysuj_litere2d(47, sx, sy, sr);
      'ü', 'è':
        rysuj_litere2d(48, sx, sy, sr);
      'ø', 'Ø':
        rysuj_litere2d(49, sx, sy, sr);
      '-':
        rysuj_litere2d(50, sx, sy, sr);
      '/':
        rysuj_litere2d(51, sx, sy, sr);
      '@':
        rysuj_litere2d(52, sx, sy, sr);
      '+':
        rysuj_litere2d(53, sx, sy, sr);
      '=':
        rysuj_litere2d(54, sx, sy, sr);
      '(':
        rysuj_litere2d(55, sx, sy, sr);
      ')':
        rysuj_litere2d(56, sx, sy, sr);
      '[':
        rysuj_litere2d(57, sx, sy, sr);
      ']':
        rysuj_litere2d(58, sx, sy, sr);
      '\':
        rysuj_litere2d(59, sx, sy, sr);
      '''':
        rysuj_litere2d(60, sx, sy, sr);
      ';':
        rysuj_litere2d(61, sx, sy, sr);
      '`':
        rysuj_litere2d(62, sx, sy, sr);
    end;
    if s[a] <> #10 then
    begin
      glTranslatef(sr * 2, 0, 0);
      px := px + sr * 2;
    end;
    if s[a] = #13 then
    begin
      glTranslatef(-px, -sr * 2, 0);
      px := 0;
    end;
  end;
  glPopMatrix;
end;

// ---------------------------------------------------------------------------
procedure pisz2d_otoczka(s: string; sx, sy, sr: real; margines: byte; kr, kg, kb, ka, kor, kog, kob, koa: single);
begin
  glColor4f(kor, kog, kob, koa);
  pisz2d(s, sx + 1, sy - 1, sr, margines);
  glColor4f(kr, kg, kb, ka);
  pisz2d(s, sx, sy, sr, margines);
end;

// ---------------------------------------------------------------------------
procedure pokaz_obiekt(var ob: Tobiekt; innatekstura: integer = -1; koloruj: boolean = false);

var
  v, f, g, o: integer;
begin
  if innatekstura = -1 then
    wlacz_teksture(ob.tex)
  else
    wlacz_teksture(innatekstura);

  if not koloruj then
    glDisable(GL_COLOR_MATERIAL);

  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);

  if not koloruj then
  begin
    glMaterialf(GL_FRONT, GL_SHININESS, ob.mat_shin);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @ob.mat_a);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @ob.mat_d);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @ob.mat_s);
  end;

  with ob.o do
  begin
    for g := 0 to High(Groups) do
    begin
      // if not lstObjects.Checked[g] then Continue;
      with Groups[g] do
      begin
        // if mnuHighlight.Checked and (g = lstObjects.ItemIndex) then
        begin
          // glBindTexture(GL_TEXTURE_2D, 0);
          // wlacz_teksture_env(3);
          { glColor3f(1, 0, 0);
            glDisable(GL_LIGHTING);
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            glBegin(GL_TRIANGLES);
            for f := 0 to High(Faces) do
            begin
            for v := 0 to 2 do
            begin
            if Faces[f].UV[v] < Length(TexCoords) then glTexCoord2fv(@TexCoords[Faces[f].UV[v]]);
            if Faces[f].Normal[v] < Length(Normals) then glNormal3fv(@Normals[Faces[f].Normal[v]]);
            if Faces[f].XYZ[v] < Length(Vertices) then glVertex3fv(@Vertices[Faces[f].XYZ[v]]);
            end;
            end;
            glEnd;
            glPolygonMode(GL_FRONT, GL_FILL);
            glColor3f(1, 1, 1);
            glEnable(GL_LIGHTING); }
        end;
        // glBindTexture(GL_TEXTURE_2D, 0);
        // else glBindTexture(GL_TEXTURE_2D, 0);
        // wlacz_teksture_env(3);
        // wlacz_teksture(ob.tex);
        glBegin(GL_TRIANGLES);
        for f := 0 to High(Faces) do
        begin
          for v := 0 to 2 do
          begin
            if Faces[f].UV[v] < length(TexCoords) then
              glTexCoord2fv(@TexCoords[Faces[f].UV[v]]);
            if Faces[f].Normal[v] < length(Normals) then
              glNormal3fv(@Normals[Faces[f].Normal[v]]);
            if Faces[f].XYZ[v] < length(Vertices) then
              glVertex3fv(@Vertices[Faces[f].XYZ[v]]);
          end;
        end;
        glEnd;

        { wylacz_teksture;
          glEnable(GL_color_material);
          glcolor3f(1,1,1);
          for f := 0 to High(Faces) do
          begin
          for v := 0 to 2 do
          begin
          glBegin(GL_LINES);
          if Faces[f].Normal[v] < Length(Normals) then begin
          glVertex3fv(@Vertices[Faces[f].XYZ[v]]);
          glVertex3f(Normals[Faces[f].Normal[v]].x*10,
          Normals[Faces[f].Normal[v]].y*10,
          Normals[Faces[f].Normal[v]].z*10);
          end;
          glEnd;
          end;
          end;
        }
      end;
    end;
  end;

end;

// ---------------------------------------------------------------------------
procedure pokaz_element_obiekt(var ob: Tobiekt; element: integer; srodek: boolean; innatekstura: integer = -1;
  beztekstur: boolean = false; zniszczony: real = 0; rrand: integer = 0);

var
  v, f, g, o: integer;
begin
  if not beztekstur then
  begin
    if innatekstura = -1 then
      wlacz_teksture(ob.tex)
    else
      wlacz_teksture(innatekstura);

    glDisable(GL_COLOR_MATERIAL);
  end;

  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);
  if not beztekstur then
  begin
    glMaterialf(GL_FRONT, GL_SHININESS, ob.mat_shin);

    glMaterialfv(GL_FRONT, GL_AMBIENT, @ob.mat_a);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @ob.mat_d);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @ob.mat_s);
  end;

  if srodek then
  begin
    with ob.o do
      with ob.o.Groups[element] do
      begin
        glBegin(GL_TRIANGLES);
        for f := 0 to High(Faces) do
        begin
          for v := 0 to 2 do
          begin
            if Faces[f].UV[v] < length(TexCoords) then
              glTexCoord2fv(@TexCoords[Faces[f].UV[v]]);
            if Faces[f].Normal[v] < length(Normals) then
              glNormal3fv(@Normals[Faces[f].Normal[v]]);
            if Faces[f].XYZ[v] < length(Vertices) then
            begin
              if zniszczony > 0 then
                RandSeed := round(Vertices[Faces[f].XYZ[v]].x + Vertices[Faces[f].XYZ[v]].y + Vertices[Faces[f].XYZ[v]]
                  .z) + rrand;
              glVertex3f(Vertices[Faces[f].XYZ[v]].x - srx + ((random - 0.5) * zniszczony),
                Vertices[Faces[f].XYZ[v]].y - sry + ((random - 0.5) * zniszczony), Vertices[Faces[f].XYZ[v]].z - srz +
                ((random - 0.5) * zniszczony));
            end;
          end;
        end;
        glEnd;
      end;
  end
  else
  begin
    with ob.o do
      with ob.o.Groups[element] do
      begin
        glBegin(GL_TRIANGLES);
        for f := 0 to High(Faces) do
        begin
          for v := 0 to 2 do
          begin
            if Faces[f].UV[v] < length(TexCoords) then
              glTexCoord2fv(@TexCoords[Faces[f].UV[v]]);
            if Faces[f].Normal[v] < length(Normals) then
              glNormal3fv(@Normals[Faces[f].Normal[v]]);
            if Faces[f].XYZ[v] < length(Vertices) then
            begin
              if zniszczony > 0 then
                RandSeed := round(Vertices[Faces[f].XYZ[v]].x + Vertices[Faces[f].XYZ[v]].y + Vertices[Faces[f].XYZ[v]]
                  .z) + rrand;
              glVertex3f(Vertices[Faces[f].XYZ[v]].x + ((random - 0.5) * zniszczony),
                Vertices[Faces[f].XYZ[v]].y + ((random - 0.5) * zniszczony),
                Vertices[Faces[f].XYZ[v]].z + ((random - 0.5) * zniszczony));
            end;
          end;
        end;
        glEnd;
      end;
  end;

  if zniszczony > 0 then
    Randomize;

end;

// ---------------------------------------------------------------------------
procedure rysuj_mapke;

var
  v, f, g, o, a, x, z, x1, z1, z11, zwz10, zwx10: integer;
  mat_2a, mat_2d, mat_2s: array [0 .. 3] of GLFloat;
  wlk, zpx, zpz: real;
begin
  glClear(GL_DEPTH_BUFFER_BIT);

  glMaterialf(GL_FRONT, GL_SHININESS, 0);
  glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_1a);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_1d);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_1s);

  glEnable(GL_COLOR_MATERIAL);
  glDisable(GL_LIGHTING);
  glDisable(GL_FOG);

  glDisable(GL_LIGHT1);
  glEnable(GL_LIGHT1);

  glDepthMask(GL_TRUE);
  glDepthFunc(GL_ALWAYS);

  glEnable(GL_BLEND);

  glPolygonMode(GL_FRONT, GL_LINE);

  wlk := 18;
  zpx := -(ziemia.wx / 2) * wlk; // *
  zpz := -(ziemia.wz / 2) * wlk;

  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glPushMatrix;
  glLoadIdentity;
  glTranslatef(23, -18, -70);
  glScalef(0.005, 0.005, 0.005);
  glRotatef(30, 1, 0, 0);
  glRotatef(licz / 2.5, 0, 1, 0);
  for z := 0 to ziemia.wz - 2 do
  begin
    z1 := z;
    z11 := z + 1;
    glBegin(GL_QUAD_STRIP);
    for x := 0 to ziemia.wx - 2 do
    begin
      x1 := x;

      glNormal3fv(@ziemia.pk[x1, z1].norm);
      glColor4f(ziemia.pk[x1, z1].kr, ziemia.pk[x1, z1].kg, ziemia.pk[x1, z1].kb, 0.3);
      glVertex3f(x * wlk + zpx, ziemia.pk[x1, z1].p, z * wlk + zpz);

      glNormal3fv(@ziemia.pk[x1, z11].norm);
      glColor4f(ziemia.pk[x1, z11].kr, ziemia.pk[x1, z11].kg, ziemia.pk[x1, z11].kb, 0.3);
      glVertex3f(x * wlk + zpx, ziemia.pk[x1, z11].p, (z + 1) * wlk + zpz);
    end;
    glEnd;
  end;
  glDisable(GL_COLOR_MATERIAL);
  glPopMatrix;
  glPopAttrib;

  glDepthFunc(GL_LEQUAL);
  glDepthMask(GL_FALSE);

end;

// ---------------------------------------------------------------------------
procedure rysuj_liczniki;

const
  dzielkaw = 20;

var
  width, height: integer;
  wartosc: real;

  radx, rady, radrx, radry, a, b: integer;
  nx, nz, wysgr: integer;
  rx, ry, px, py, jas: real;
begin

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  width := trunc(currentScreenParams.HudWidth);
  height := trunc(currentScreenParams.HudHeight);
  gluOrtho2D(0, width, 0, height);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glDisable(GL_FOG);
  glEnable(GL_BLEND);
  glDepthMask(GL_FALSE);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);
  glDisable(GL_COLOR_MATERIAL);
  glPolygonMode(GL_FRONT, GL_FILL);

  glBegin(GL_QUADS);
  glColor4f(0, 0, 0, 0.5);
  glVertex2f(-1, -1);
  glVertex2f(width + 1, -1);
  glColor4f(0, 0, 0, 0.0);
  glVertex2f(width + 1, 50);
  glVertex2f(-1, 50);
  glEnd();
  glBegin(GL_QUADS);
  glColor4f(0, 0, 0, 0);
  glVertex2f(-1, height - 25);
  glVertex2f(width + 1, height - 25);
  glColor4f(0, 0, 0, 0.5);
  glVertex2f(width + 1, height + 1);
  glVertex2f(-1, height + 1);
  glEnd();

  glColor4f(1, 1, 1, 0.5);
  case gra.rodzajmisji of
    0:
      begin
        pisz2d('jest:' + inttostr(gra.ilepilotow + gracz.pilotow), 10, height - 10, 4);
        pisz2d('na pok≥adzie:' + inttostr(gracz.pilotow) + '/' + inttostr(gracz.ladownosc), 90, height - 10, 4);
        pisz2d('zginÍ≥o:' + inttostr(gra.zginelo), currentScreenParams.HudWidth - 160, height - 10, 4, 2);
        pisz2d('uratowanych:' + inttostr(gra.zabranych) + '/' + inttostr(gra.minimum),
          currentScreenParams.HudWidth - 10, height - 10, 4, 2);
      end;
    1:
      begin
        pisz2d('jest:' + inttostr(gra.iledzialek), 10, height - 10, 4);
        pisz2d('zniszczonych:' + inttostr(gra.dzialekzniszczonych) + '/' + inttostr(gra.dzialekminimum),
          currentScreenParams.HudWidth - 10, height - 10, 4, 2);
      end;
  end;

  // cheaty
  glColor4f(0.4, 0.8, 1, 0.8);
  if cheaty.god then
    pisz2d('NIEZNISZCZALNOå∆', 5, height - 25, 3.2);
  if cheaty.fuel then
    pisz2d('MAX PALIWA', 5, height - 31, 3.2);
  if cheaty.weapon then
    pisz2d('MAX BRONI', 5, height - 37, 3.2);
  if cheaty.load then
    pisz2d('MAX £ADOWNOåCI', 5, height - 43, 3.2);
  if cheaty.time then
    pisz2d('MAX CZASU', 5, height - 49, 3.2);

  if gra.czas < 20 then
    glColor4f(1, 0.2, 0, 0.9)
  else if gra.czas < 60 then
    glColor4f(1, 0.7, 0.4, 0.7)
  else
    glColor4f(1, 1, 1, 0.7);
  pisz2d(inttostr(gra.czas div 60) + ':' + l2t(gra.czas mod 60, 2), currentScreenParams.HudWidth / 2,
    height - 12, 7, 1);

  // pisz2d('Lπdowniki:'+inttostr(gra.zycia), width-20, height-45, 4,2);

  glColor4f(1, 1, 1, 0.7);

  if gra.zycia > 3 then
  begin
    rysuj_ikone(0, 200, 18, 10);
    pisz2d(inttostr(gra.zycia), 220, 18, 7);
  end
  else
  begin
    for a := 0 to gra.zycia - 1 do
      rysuj_ikone(0, 200 + a * 17, 18, 10);
  end;

  wysgr := round(gracz.y - gdzie_y(gracz.x, gracz.z, gracz.y) - 5);

  pisz2d(inttostr(wysgr), 120, 18, 7);

  rysuj_ikone(1, 270, 18, 10);
  pisz2d(inttostr(gracz.ilerakiet), 290, 18, 7);

  rysuj_ikone(2, 340, 18, 10);
  pisz2d(inttostr(gracz.iledzialko), 360, 18, 7);

  rysuj_ikone(5, currentScreenParams.HudWidth - 220, 28, 7);
  rysuj_ikone(6, currentScreenParams.HudWidth - 220, 17, 7);
  glColor4f(0.3, 0.7, 1, 0.6);
  pisz2d(inttostr(gra.kasa), currentScreenParams.HudWidth - 200, 28, 4);
  pisz2d(inttostr(gra.pkt), currentScreenParams.HudWidth - 200, 17, 4);

  // paliwo
  { wartosc := gracz.paliwo/gracz.maxpaliwa*(height-120);
    glBegin(GL_QUADS);
    glColor4f(1.0,0.1,0.1,0.4);
    glVertex2f( width-40, 50);
    glVertex2f( width-33 , 50);
    glColor4f(1.0,1.0,0.1,0.4);
    glVertex2f( width-33 , 50+wartosc);
    glVertex2f( width-40-(gracz.maxpaliwa/20.0), 50+wartosc);
    glEnd(); }

  nx := round(gracz.maxpaliwa) div dzielkaw; // ile kawalkow
  nz := (320 div nx) - 1; // rozmiar kawalka w pionie
  b := round(gracz.paliwo) div dzielkaw;
  for a := 0 to b do
  begin
    if 95 + (a + 1) * nz - 2 <= 415 then
    begin // zeby nie wyswietlac ostatniego niepelnego kawalka
      if a < b then
        px := 0.4
      else
        px := ((round(gracz.paliwo) mod dzielkaw) / dzielkaw) * 0.4;
      py := (a / nx) * 0.9 + 0.1;
      glBegin(GL_QUADS);
      glColor4f(1.0, py, 0.1, px);
      glVertex2f(width - 10 - a, 95 + (a + 1) * nz - 2);
      glVertex2f(width - 10 - a, 95 + a * nz);
      // glColor4f(1.0,py,0.1,px);
      glVertex2f(width - 5, 95 + a * nz);
      glVertex2f(width - 5, 95 + (a + 1) * nz - 2);
      glEnd();
    end;
  end;


  // sila
  { wartosc := (gracz.sila/gracz.maxsila)*(height-120);
    glBegin(GL_QUADS);
    glColor4f(0.0,0.4,0.9,0.4);
    glVertex2f( 13, 50);
    glVertex2f( 20 , 50);
    glColor4f(0.5,0.9,1.0,0.4);
    glVertex2f( 20+(gracz.sila*5.0) , 50+wartosc);
    glVertex2f( 13, 50+wartosc);
    glEnd(); }

  nx := round(gracz.maxsila * 120) div dzielkaw; // ile kawalkow
  nz := (320 div nx) - 1; // rozmiar kawalka w pionie
  b := round(gracz.sila * 120) div dzielkaw;
  for a := 0 to b do
  begin
    if 95 + (a + 1) * nz - 2 <= 415 then
    begin // zeby nie wyswietlac ostatniego niepelnego kawalka
      if a < b then
        px := 0.4
      else
        px := ((round(gracz.sila * 120) mod dzielkaw) / dzielkaw) * 0.4;
      py := (a / nx);
      glBegin(GL_QUADS);
      glColor4f(py * 0.5, 0.4 + py * 0.5, 0.9 + py * 0.1, px);
      glVertex2f(5, 95 + (a + 1) * nz - 2);
      glVertex2f(5, 95 + a * nz);
      // glColor4f(1.0,py,0.1,px);
      glVertex2f(10 + a, 95 + a * nz);
      glVertex2f(10 + a, 95 + (a + 1) * nz - 2);
      glEnd();
    end;
  end;

  // temp
  wartosc := gracz.temp / 4.2;
  glBegin(GL_QUADS);
  if (gracz.temp >= 240) and (licz mod 20 <= 10) then
    glColor4f(0.6, 0.0, 0.0, 0.7)
  else
    glColor4f(0.0, 0.0, 0.3, 0.4);
  glVertex2f(100, 10);
  glVertex2f(110, 10);
  glColor4f(1.0, 0.3, 0.0, 0.4 + gracz.temp / 700);
  glVertex2f(110, 10 + wartosc);
  glVertex2f(100, 10 + wartosc);
  glEnd();

  // wysokosc
  xznasiatce(nx, nz, gracz.x, gracz.z);
  if ((nx >= 0) and (nz >= 0) and (nx <= high(ziemia.pk)) and (nz <= high(ziemia.pk[nx])) and
    (ziemia.pk[nx, nz].rodzaj = 1) and not gracz.namatce) or
    ((gracz.y >= matka.y - 10) and (sqrt2(sqr(gracz.x - matka.x) + sqr(gracz.z - matka.z)) <= 35)) then
    glColor4f(0.2, 1, 0.1, 0.4)
  else
    glColor4f(1, 0.2, 0.1, 0.4);

  rysuj_ikone(0, 140, 60, 10);
  if wysgr < 76 then
  begin
    glBegin(GL_LINES);
    glVertex2f(132, 50 - wysgr / 3);
    glVertex2f(148, 50 - wysgr / 3);
    glEnd;
  end;

  // radar
  radx := 10;
  rady := 10;
  radrx := 80;
  radry := 80;
  rx := radrx / ziemia.wx;
  ry := radry / ziemia.wz;

  glPushMatrix;
  glTranslatef(radx + radrx / 2, rady + radry / 2, 0);
  glRotatef(180 + gracz.kier, 0, 0, 1);
  glColor4f(0.2, 0.2, 0.4, 0.4);

  radrx := radrx div 2;
  radry := radry div 2;

  { glBegin(GL_QUADS);
    glVertex2f(radrx,-radry);
    glVertex2f(radrx,radry);
    glVertex2f(-radrx,radry);
    glVertex2f(-radrx,-radry);
    glEnd; }

  glPushMatrix;
  for a := 0 to 23 do
  begin
    glBegin(GL_TRIANGLES);
    glColor4f(0.4, 0.4, 0.7, 0.5);
    glVertex2f(0, 0);
    glColor4f(0.2, 0.2, 0.4, 0.3);
    glVertex2f(sin(15 * pi180) * radrx, cos(15 * pi180) * radry);
    glVertex2f(0, radry);
    glEnd;
    glRotatef(360 / 24, 0, 0, 1);
  end;
  glPopMatrix;

  glBegin(GL_TRIANGLES);
  glVertex2f(0, radry + 8);
  glVertex2f(-4, radry);
  glVertex2f(4, radry);
  glEnd;

  glPointSize(1);
  if licz mod 20 <= 12 then
    jas := (8 - licz mod 20) / 8
  else
    jas := 1;
  // if licz mod 20<=12 then begin
  glBegin(GL_POINTS);
  case gra.rodzajmisji of
    0:
      begin
        for a := 0 to high(pilot) do
          if pilot[a].jest and (pilot[a].nalotnisku >= 0) then
          begin
            px := radrx - ((pilot[a].x - ziemia.px - gracz.x) / ziemia.wlk) * rx;
            py := -radry + ((pilot[a].z - ziemia.pz - gracz.z) / ziemia.wlk) * ry;
            if px < -radrx then
              px := px + radrx * 2
            else if px > radrx then
              px := px - radrx * 2;
            if py < -radry then
              py := py + radry * 2
            else if py > radry then
              py := py - radry * 2;

            j := sqrt2(sqr(px) + sqr(py));
            if j <= radrx then
            begin
              glColor4f(1, 1, 1, (0.2 + ziemia.widac / 2) * jas);
              glVertex2f(px, py);
            end;
          end;
      end;
    1:
      begin
        for a := 0 to high(dzialko) do
          if dzialko[a].jest and not dzialko[a].rozwalone then
          begin
            px := radrx - ((dzialko[a].x - ziemia.px - gracz.x) / ziemia.wlk) * rx;
            py := -radry + ((dzialko[a].z - ziemia.pz - gracz.z) / ziemia.wlk) * ry;
            if px < -radrx then
              px := px + radrx * 2
            else if px > radrx then
              px := px - radrx * 2;
            if py < -radry then
              py := py + radry * 2
            else if py > radry then
              py := py - radry * 2;

            j := sqrt2(sqr(px) + sqr(py));
            if j <= radrx then
            begin
              glColor4f(1, 1, 1, (0.2 + ziemia.widac / 2) * jas);
              glVertex2f(px, py);
            end;
          end;
      end;
  end;

  glEnd;
  // end;

  glBegin(GL_TRIANGLES);
  glColor4f(0, 1.0, 0.0, 0.1 + matka.widac / 2);
  px := radrx - ((matka.x - ziemia.px - gracz.x) / ziemia.wlk) * rx;
  py := -radry + ((matka.z - ziemia.pz - gracz.z) / ziemia.wlk) * ry;
  if px < -radrx then
    px := px + radrx * 2
  else if px > radrx then
    px := px - radrx * 2;
  if py < -radry then
    py := py + radry * 2
  else if py > radry then
    py := py - radry * 2;

  glVertex2f(px + (530 / ziemia.wlk) * rx, py);
  glVertex2f(px - (410 / ziemia.wlk) * rx, py + (300 / ziemia.wlk) * ry);
  glVertex2f(px - (410 / ziemia.wlk) * rx, py - (300 / ziemia.wlk) * ry);
  glEnd;

  // if licz mod 12<=8 then begin
  if licz mod 12 <= 4 then
    glPointSize(1)
  else
    glPointSize(2);
  glBegin(GL_POINTS);
  for a := 0 to high(mysliwiec) do
    if mysliwiec[a].jest and not mysliwiec[a].zniszczony then
    begin
      px := radrx - ((mysliwiec[a].x - ziemia.px - gracz.x) / ziemia.wlk) * rx;
      py := -radry + ((mysliwiec[a].z - ziemia.pz - gracz.z) / ziemia.wlk) * ry;
      if px < -radrx then
        px := px + radrx * 2
      else if px > radrx then
        px := px - radrx * 2;
      if py < -radry then
        py := py + radry * 2
      else if py > radry then
        py := py - radry * 2;

      j := sqrt2(sqr(px) + sqr(py));
      if j <= radrx then
      begin
        glColor4f(1, 0.3, 1, 1 * jas);
        glVertex2f(px, py);
      end;
    end;
  glEnd;
  // end;

  glPointSize(3);
  glBegin(GL_POINTS);
  glcolor3f(1, 0.3, 0.1);
  glVertex2f(0, 0);
  glEnd;
  glPopMatrix;

  // wiatr
  glPushMatrix;
  glTranslatef(width - 90, 26, 0);
  pisz2d(inttostr(round(wiatr.sila * 10000)), 0, 0, 4, 1);
  glRotatef(gracz.kier - wiatr.kier, 0, 0, 1);
  glColor4f(1.0, 1.0, 0.4, 0.4);
  glBegin(GL_TRIANGLES);
  glVertex2f(-5, -15);
  glVertex2f(5, -15);
  glVertex2f(0, 15);
  glEnd;
  glPopMatrix;

  // grawitacja/gestosc powietrza
  glPushMatrix;

  glColor4f(1, 1, 1, 0.7);
  rysuj_ikone(3, currentScreenParams.HudWidth - 50, 28, 7);
  rysuj_ikone(4, currentScreenParams.HudWidth - 50, 17, 7);
  glColor4f(0.3, 0.7, 1, 0.6);
  pisz2d(inttostr(round(ziemia.grawitacja * 10000)), currentScreenParams.HudWidth - 30, 28, 4);
  pisz2d(inttostr(round(1000 - ziemia.gestoscpowietrza * 1000)), currentScreenParams.HudWidth - 30, 17, 4);

  { glcolor4f(0.7,1.0,1.0,0.4);
    glTranslatef(width-120,30,0);
    pisz2d('GR:'+inttostr(round(ziemia.grawitacja*10000)),0,0,4,1);
    pisz2d('GP:'+inttostr(round(1000-ziemia.gestoscpowietrza*1000)),0,-10,4,1); }
  glPopMatrix;

  if gracz.zyje then
  begin
    if (gracz.paliwo > 0) and (gracz.paliwo < 40) and (licz mod 50 <= 24) then
    begin
      glcolor3f(1, 0, 0);
      pisz2d('PALIWO SI  KO—CZY!', width div 2, 60, 7, 1);
    end
    else if (gracz.paliwo <= 0) then
    begin
      glcolor3f(1, 0, 0);
      pisz2d('KONIEC PALIWA', width div 2, 60, 7, 1);
    end;

    if (licz mod 20 <= 10) then
    begin
      if (gracz.temp >= 280) then
      begin
        glcolor3f(1, 1, 0);
        pisz2d('TEMPERATURA KRYTYCZNA!', width div 2, 60, 7, 1);
      end
      else if (gracz.temp >= 240) then
      begin
        glcolor3f(1, 1, 0);
        pisz2d('TEMPERATURA!', width div 2, 60, 7, 1);
      end;
    end;

    if (licz mod 20 <= 10) then
    begin
      if (gracz.y >= 2800) then
      begin
        glcolor3f(1, 1, 0);
        pisz2d('JESTEå ZA WYSOKO!', width div 2, 80, 7, 1);
      end;
    end;

    if (gra.czas > 0) and (gra.czas < 60) and (licz mod 40 <= 20) then
    begin
      glcolor3f(1, 0, 0);
      pisz2d('CZAS SI  KO—CZY!', width div 2, 90, 7, 1);
    end;
  end;

  if (gracz.zlywsrodku) and (licz mod 20 <= 13) then
  begin
    glcolor3f(1, 0.2, 0.1);
    pisz2d('ALARM! WR”G NA POK£ADZIE!', width div 2, 90, 9, 1);
  end;

  if (gra.czas = 0) then
  begin
    glcolor3f(1, 0, 0);
    pisz2d('KONIEC CZASU', width div 2, 90, 7, 1);
  end;

  if not gracz.zyje then
  begin
    glcolor3f(1, 0, 0);
    pisz2d('L•DOWNIK ZNISZCZONY!', width div 2, height - 60, 7, 1);
  end;

  { if gra.ilepilotow=0 then
    pisz2d('ZAJEBIOZA! NIE MA JUØ LUDZI DO WZI CIA!', width div 2, height-120, 9,1);
  }

  if (gracz.zyje and gracz.stoi and gracz.namatce) and (gra.pkt = 0) then
  begin
    glColor4f(1.0, 1.0, 1.0, 0.8 - abs(sin(licz / 30) * 0.6));
    pisz2d('PODNIEå L•DOWNIK I ZLE∆ NA D”£, POD STATEK-MATK ', width div 2, height - 90, 5, 1);
  end;

  if (gra.koniecgry) then
  begin
    glcolor3f(0.3, 0.8, 1);
    pisz2d('KONIEC GRY!', width div 2, height div 2, 12, 1);
  end
  else if (gra.moznakonczyc and ((gracz.stoi and gracz.namatce) or (not gracz.zyje))) then
  begin
    glColor4f(0.7, 0.3, 1.0, 0.8);
    pisz2d('MISJA ZAKO—CZONA!', width div 2, height div 2 + 70, 7, 1);
    pisz2d('WCIåNIJ -' + form1.PwrInp.KeyName[klawisze[8]] + '- BY KONTYNUOWA∆', width div 2, height div 2 + 45, 6, 1);
  end;

  if (gra.pauza) then
  begin
    glColor4f(1.0, 0.8, 0.1, 0.8);
    pisz2d('PAUZA', width div 2, height div 2 + 40, 10, 1);

    glColor4f(0.4, 0.8, 0.3, 0.8);
    pisz2d('WCIåNIJ ESC BY KONTYNUOWA∆ GR ', width div 2, height div 2, 7, 1);
    pisz2d('WCIåNIJ Q BY przerwaÊ', width div 2, height div 2 - 30, 7, 1);
  end;

  { pisz2d('czas='+inttostr(cheaty.czas_od_ostatniej_litery), 50, height -50, 5);
    for a:=0 to high(cheaty.wpisany_tekst) do
    pisz2d( Form1.PwrInp.KeyName[cheaty.wpisany_tekst[a]], 50+a*10, height -80, 5);
  }
  glPointSize(0);

  glEnable(GL_LIGHTING);
  glDepthMask(GL_TRUE);
  glDisable(GL_BLEND);
  glEnable(GL_DEPTH_TEST);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

  gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, odlwidzenia);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glEnable(GL_FOG);
end;

// ---------------------------------------------------------------------------
procedure DrawPanoramicStripes(width, height: integer);
begin
  // pasy panoramiczne
  glBegin(GL_QUADS);
  glcolor3f(0, 0, 0);
  glVertex2f(-1 - currentScreenParams.MenuOffsetX, -1);
  glVertex2f(width + 1 + currentScreenParams.MenuOffsetX, -1);
  glVertex2f(width + 1 + currentScreenParams.MenuOffsetX, 90);
  glVertex2f(-1 - currentScreenParams.MenuOffsetX, 90);
  glEnd();
  glBegin(GL_QUADS);
  glVertex2f(-1 - currentScreenParams.MenuOffsetX, height - 90);
  glVertex2f(width + 1 + currentScreenParams.MenuOffsetX, height - 90);
  glVertex2f(width + 1 + currentScreenParams.MenuOffsetX, height + 1);
  glVertex2f(-1 - currentScreenParams.MenuOffsetX, height + 1);
  glEnd();
end;

// ---------------------------------------------------------------------------
procedure rysuj_napisy_intro;

var
  width, height: integer;
  n, m: string;
  a, z: integer;
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  SetGluOrtho2DForMenu(width, height);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glDisable(GL_FOG);
  glEnable(GL_BLEND);
  glDepthMask(GL_FALSE);
  glDisable(GL_LIGHTING);
  glDisable(GL_COLOR_MATERIAL);
  glPolygonMode(GL_FRONT, GL_FILL);

  DrawPanoramicStripes(width, height);

  // glEnable(GL_LIGHTING);
  // glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // czyszczenie buforow koloru i glebokosci

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(40, currentScreenParams.Aspect, 0.2, odlwidzenia);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  rysuj_mapke;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  SetGluOrtho2DForMenu(width, height);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glDisable(GL_FOG);
  glEnable(GL_BLEND);
  glDepthMask(GL_FALSE);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);
  glDisable(GL_COLOR_MATERIAL);
  glPolygonMode(GL_FRONT, GL_FILL);

  if intro.czas >= 30 then
  begin
    glColor4f(0.2, 1, 0.3, 0.7);
    if gra.jakiemisje <> 2 then
      n := 'MISJA ' + inttostr(gra.planeta) + ', ' + gra.nazwaplanety
    else
      n := 'MISJA ' + inttostr(winieta.epizodmisja) + ', ' + gra.nazwaplanety;
    a := (intro.czas - 30) div 2;
    if a > length(n) then
      a := length(n);
    m := copy(n, 1, a);
    pisz2d(m, 40, gra.pozycjaYtekstuintro, 7);

    z := 2 * length(n) + 20;

    if intro.czas >= z then
    begin
      { case gra.rodzajmisji of
        0:n:='URATUJ CO NAJMNIEJ '+inttostr(gra.minimum)+' LUDZI Z WSZYSTKICH '+inttostr(gra.ilepilotow)+#13+
        'ZANIM WYSADZIMY PLANET . CZAS NA WYKONANIE MISJI: '+ inttostr(gra.czas div 60)+':'+l2t(gra.czas mod 60,2)+'.'#13+
        'POWODZENIA!';
        1:n:='ZNISZCZ CO NAJMNIEJ '+inttostr(gra.dzialekminimum)+' DZIA£ WROGA Z WSZYSTKICH '+inttostr(gra.iledzialek)+#13+
        'Z PLANETY. CZAS NA WYKONANIE MISJI: '+ inttostr(gra.czas div 60)+':'+l2t(gra.czas mod 60,2)+'.'#13+
        'POWODZENIA!';
        end; }
      n := gra.tekstintro;

      a := (intro.czas - z);
      if a > length(n) then
        a := length(n);
      m := copy(n, 1, a);
      { glColor4f(0.0,0.1,0.0,0.7);
        pisz2d(m, 41, gra.pozycjaYtekstuintro-20-1, 5);
        glColor4f(0.1,0.8,0.1,0.7);
        pisz2d(m, 40, gra.pozycjaYtekstuintro-20, 5); }
      pisz2d_otoczka(m, 40, gra.pozycjaYtekstuintro - 20, 5, 0, 0.1, 0.8, 0.1, 0.8, 0.0, 0.1, 0.0, 0.7);
    end;
  end;

  glEnable(GL_LIGHTING);
  glDepthMask(GL_TRUE);
  glEnable(GL_DEPTH_TEST);
  glDisable(GL_BLEND);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, odlwidzenia);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glEnable(GL_FOG);
end;

// ---------------------------------------------------------------------------
procedure rysuj_napisy_outro;

var
  width, height: integer;
  n, m: string;
  a, z: integer;
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  SetGluOrtho2DForMenu(width, height);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glDisable(GL_FOG);
  glEnable(GL_BLEND);
  glDepthMask(GL_FALSE);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);
  glDisable(GL_COLOR_MATERIAL);
  glPolygonMode(GL_FRONT, GL_FILL);

  DrawPanoramicStripes(width, height);

  if intro.czas >= 30 then
  begin
    glColor4f(0.2, 1, 0.3, 0.7);
    if gra.jakiemisje <> 2 then
    begin
      if gra.misjawypelniona then
        n := 'MISJA ' + inttostr(gra.planeta) + ' WYKONANA!'
      else
        n := 'MISJA ' + inttostr(gra.planeta) + ' STRACONA...'
    end
    else
    begin
      if gra.misjawypelniona then
        n := 'MISJA ' + inttostr(winieta.epizodmisja) + ' WYKONANA!'
      else
        n := 'MISJA ' + inttostr(winieta.epizodmisja) + ' STRACONA...'
    end;
    a := (intro.czas - 30) div 2;
    if a > length(n) then
      a := length(n);
    m := copy(n, 1, a);
    pisz2d(m, 40, height - 40, 7);

    z := 2 * length(n) + 20;

    if intro.czas >= z then
    begin
      glColor4f(0.1, 0.8, 0.1, 0.7);

      if gra.misjawypelniona then
      begin
        n := gra.tekstoutrowin;
        if gra.zycia >= 1 then // n:=n+#13'PRZYGOTUJ SI  DO NAST PNEJ...'
        else
          n := n + #13'NIESTETY ZGIN•£Eå...';

        pisz2d('PREMIA ZA POZOZSTA£Y CZAS:'#13' PKT: ' + inttostr(gra.czas * 4) + ', KASA: ' + inttostr(gra.czas),
          40, 70, 5);
        if gra.rodzajmisji = 0 then
          pisz2d('PREMIA ZA WZI CIE DODATKOWYCH PILOT”W:'#13' PKT: ' + inttostr((gra.zabranych - gra.minimum) * 350) +
            ', KASA: ' + inttostr((gra.zabranych - gra.minimum) * 30), 40, 50, 5)
        else if gra.rodzajmisji = 1 then
          pisz2d('PREMIA ZA ZNISZCZENIE DODATKOWYCH DZIA£EK:'#13' PKT: ' +
            inttostr((gra.dzialekzniszczonych - gra.dzialekminimum) * 350) + ', KASA: ' +
            inttostr((gra.dzialekzniszczonych - gra.dzialekminimum) * 30), 40, 50, 5);

      end
      else
      begin
        { case gra.rodzajmisji of
          0:begin
          n:='NIE WYKONA£Eå MISJI!'#13+
          'ZA£OGA STATKU-MATKI NIE CHCE CI  WI CEJ WIDZIE∆'#13+
          'PRZEZ TO, ØE NIE URATOWA£Eå ICH LUDZI... PRZEZ CIEBIE'#13+
          'WSZYSCY POZOSTALI NA PLANECIE ZGIN•.';
          end;
          1:begin
          n:='NIE WYKONA£Eå MISJI!'#13+
          'NASZA PLANETA ZOSTA£A OPANOWANA PRZEZ WROGA, BO'#13+
          'ZAWIOD£Eå...';
          end;
          end; }
        n := gra.tekstoutrolost;
      end;
      a := (intro.czas - z) div 2;
      if a > length(n) then
        a := length(n);
      m := copy(n, 1, a);
      pisz2d_otoczka(m, 40, height - 60, 5, 0, 0.1, 0.8, 0.1, 0.8, 0.0, 0.1, 0.0, 0.7);
    end;
  end;

  glEnable(GL_LIGHTING);
  glDepthMask(GL_TRUE);
  glEnable(GL_DEPTH_TEST);
  glDisable(GL_BLEND);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, odlwidzenia);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glEnable(GL_FOG);
end;

// ---------------------------------------------------------------------------
procedure rysuj_wode;

var
  nx, nz, w: real;

var
  kol: array [0 .. 3] of GLFloat;
begin
  w := 150;
  nx := abs(ziemia.px) * 3;
  nz := abs(ziemia.pz) * 3;

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glTranslatef(0.5 + sin(licz / 40) / 20, 0.5 + cos(licz / 51) / 20, 0);
  glMatrixMode(GL_MODELVIEW);

  glPushMatrix;
  glEnable(GL_COLOR_MATERIAL);
  kol[0] := 0.6;
  kol[1] := 0.9;
  kol[2] := 1;
  kol[3] := 0.4;

  glDepthMask(GL_FALSE);
  glEnable(GL_BLEND);
  glColor4fv(@kol);

  wlacz_teksture(1);
  glBegin(GL_QUADS);
  glTexCoord2f(3, 0);
  glVertex3f(nx, w, -nz);
  glTexCoord2f(0, 0);
  glVertex3f(-nx, w, -nz);
  glTexCoord2f(0, 3);
  glVertex3f(-nx, w, nz);
  glTexCoord2f(3, 3);
  glVertex3f(nx, w, nz);
  glEnd;

  wylacz_teksture;
  glDisable(GL_BLEND);

  glDepthMask(GL_TRUE);

  glPopMatrix;

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glMatrixMode(GL_MODELVIEW);

end;

// ---------------------------------------------------------------------------
procedure rysuj_podloze;

const
  tr = 3.5; // 7

var
  v, f, g, o, a, x, z, xod, xdo, zod, zdo, x1, z1, z11, zwz10, zwx10, xsr, zsr: integer;
  mat_2a, mat_2d, mat_2s: array [0 .. 3] of GLFloat;
  obrx, obry, obrz, odl, r, gx1, gz1: real;
  widocznosc2: integer;
begin
  if (ziemia.widac <= 0) then
    exit;

  zwz10 := ziemia.wz * 10;
  zwx10 := ziemia.wx * 10;

  glMaterialf(GL_FRONT, GL_SHININESS, 60);
  glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_1a);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_1d);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_1s);

  glEnable(GL_COLOR_MATERIAL);

  if ziemia.widac < 1 then
    glFogf(GL_FOG_DENSITY, 0.0065 - ziemia.widac * 0.005);


  // punkty

  xod := trunc((gra.jestkamera[0, 0] - ziemia.px) / ziemia.wlk) - widocznosc;
  xdo := trunc((gra.jestkamera[0, 0] - ziemia.px) / ziemia.wlk) + widocznosc;
  zod := trunc((gra.jestkamera[0, 2] - ziemia.pz) / ziemia.wlk) - widocznosc;
  zdo := trunc((gra.jestkamera[0, 2] - ziemia.pz) / ziemia.wlk) + widocznosc;
  { xod:=trunc((gracz.x-ziemia.px)/ziemia.wlk)-widocznosc;
    xdo:=trunc((gracz.x-ziemia.px)/ziemia.wlk)+widocznosc;
    zod:=trunc((gracz.z-ziemia.pz)/ziemia.wlk)-widocznosc;
    zdo:=trunc((gracz.z-ziemia.pz)/ziemia.wlk)+widocznosc;
  }
  xsr := (xdo - xod) div 2 + xod;
  zsr := (zdo - zod) div 2 + zod;

  widocznosc2 := odlwidzenia div ziemia.wlk + 2;

  glPushMatrix;
  // glPolygonMode(GL_FRONT, GL_LINE);
  wlacz_teksture3d(17);
  z := zod;
  while z <= zdo do
  begin

    if abs(z - zsr) < widocznosc2 then
    begin

      z1 := (z + zwz10) mod ziemia.wz;
      z11 := (z + 1 + zwz10) mod ziemia.wz;
      glBegin(GL_QUAD_STRIP);
      x := xod;
      while x <= xdo do
      begin

        if sqrt2(sqr(abs(x - xsr)) + sqr(abs(z - zsr))) < widocznosc2 then
        begin
          x1 := (x + zwx10) mod ziemia.wx;

          glNormal3fv(@ziemia.pk[x1, z1].norm);
          glTexCoord3f(x / tr, z / tr, ziemia.pk[x1, z1].tex);
          if (ziemia.pk[x1, z1].rodzaj = 1) and (((x1 > 0) and (ziemia.pk[x1 - 1, z1].rodzaj <> 1)) or
            ((x1 < ziemia.wx - 1) and (ziemia.pk[x1 + 1, z1].rodzaj <> 1)) or
            ((z1 > 0) and (ziemia.pk[x1, z1 - 1].rodzaj <> 1)) or
            ((z1 < ziemia.wz - 1) and (ziemia.pk[x1, z1 + 1].rodzaj <> 1))) then
            glcolor3f(1, 1, 1)
          else
            glcolor3f(ziemia.pk[x1, z1].kr, ziemia.pk[x1, z1].kg, ziemia.pk[x1, z1].kb);

          glVertex3f(x * ziemia.wlk + ziemia.px, ziemia.pk[x1, z1].p, z * ziemia.wlk + ziemia.pz);

          glNormal3fv(@ziemia.pk[x1, z11].norm);
          glTexCoord3f(x / tr, (z + 1) / tr, ziemia.pk[x1, z11].tex);
          if (ziemia.pk[x1, z1].rodzaj = 1) and (((x1 > 0) and (ziemia.pk[x1 - 1, z11].rodzaj <> 1)) or
            ((x1 < ziemia.wx - 1) and (ziemia.pk[x1 + 1, z11].rodzaj <> 1)) or
            ((z11 > 0) and (ziemia.pk[x1, z11 - 1].rodzaj <> 1)) or
            ((z11 < ziemia.wz - 1) and (ziemia.pk[x1, z11 + 1].rodzaj <> 1))) then
            glcolor3f(1, 1, 1)
          else
            glcolor3f(ziemia.pk[x1, z11].kr, ziemia.pk[x1, z11].kg, ziemia.pk[x1, z11].kb);

          glVertex3f(x * ziemia.wlk + ziemia.px, ziemia.pk[x1, z11].p, (z + 1) * ziemia.wlk + ziemia.pz);

        end;
        inc(x);
      end;
      glEnd;

    end;

    inc(z);
  end;

  (*
    for z:=zod to zdo{ziemia.wz-2} do begin
    z1:=(z+zwz10) mod ziemia.wz;
    z11:=(z+1+zwz10) mod ziemia.wz;
    glBegin(GL_QUAD_STRIP);
    for x:=xod to xdo{ziemia.wx-2} do begin
    x1:=(x+zwx10) mod ziemia.wx;

    glNormal3fv(@ziemia.pk[x1,z1].norm);
    glTexCoord3f(x/tr,z/tr, ziemia.pk[x1,z1].tex);
    if (ziemia.pk[x1,z1].rodzaj=1) and (
    ((x1>0) and (ziemia.pk[x1-1,z1].rodzaj<>1)) or
    ((x1<ziemia.wx-1) and (ziemia.pk[x1+1,z1].rodzaj<>1)) or
    ((z1>0) and (ziemia.pk[x1,z1-1].rodzaj<>1)) or
    ((z1<ziemia.wz-1) and (ziemia.pk[x1,z1+1].rodzaj<>1))) then glcolor3f(1,1,1)
    else
    glColor3f(ziemia.pk[x1,z1].kr,ziemia.pk[x1,z1].kg,ziemia.pk[x1,z1].kb);
    glVertex3f(x*ziemia.wlk+ziemia.px,ziemia.pk[x1,z1].p,z*ziemia.wlk+ziemia.pz);

    glNormal3fv(@ziemia.pk[x1,z11].norm);
    glTexCoord3f(x/tr,(z+1)/tr, ziemia.pk[x1,z11].tex);
    if (ziemia.pk[x1,z1].rodzaj=1) and (
    ((x1>0) and (ziemia.pk[x1-1,z11].rodzaj<>1)) or
    ((x1<ziemia.wx-1) and (ziemia.pk[x1+1,z11].rodzaj<>1)) or
    ((z11>0) and (ziemia.pk[x1,z11-1].rodzaj<>1)) or
    ((z11<ziemia.wz-1) and (ziemia.pk[x1,z11+1].rodzaj<>1))) then glcolor3f(1,1,1)
    else
    glColor3f(ziemia.pk[x1,z11].kr,ziemia.pk[x1,z11].kg,ziemia.pk[x1,z11].kb);
    glVertex3f(x*ziemia.wlk+ziemia.px,ziemia.pk[x1,z11].p,(z+1)*ziemia.wlk+ziemia.pz);
    end;
    glEnd;
    end;
  *)
  wylacz_teksture;
  // glPolygonMode(GL_FRONT, GL_FILL);


  // cienie scenerii

  xod := trunc((gracz.x - ziemia.px) / ziemia.wlk) - widocznoscscencien;
  xdo := trunc((gracz.x - ziemia.px) / ziemia.wlk) + widocznoscscencien;
  zod := trunc((gracz.z - ziemia.pz) / ziemia.wlk) - widocznoscscencien;
  zdo := trunc((gracz.z - ziemia.pz) / ziemia.wlk) + widocznoscscencien;

  glPushAttrib(GL_ALL_ATTRIB_BITS);
  wlacz_teksture(4);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glDepthMask(GL_FALSE);
  glEnable(GL_BLEND);
  glColor4f(1, 1, 1, 0.4);

  for z := zod to zdo { ziemia.wz-2 } do
  begin
    z1 := (z + zwz10) mod ziemia.wz;
    for x := xod to xdo { ziemia.wx-2 } do
    begin
      x1 := (x + zwx10) mod ziemia.wx;

      if ziemia.pk[x1, z1].scen then
      begin
        // glVertex3f(x*ziemia.wlk+ziemia.px,ziemia.pk[x1,z1].p,z*ziemia.wlk+ziemia.pz);
        glPushMatrix;
        glTranslatef(x * ziemia.wlk + ziemia.px, ziemia.pk[x1, z1].p, z * ziemia.wlk + ziemia.pz);
        glScalef(ziemia.pk[x1, z1].scen_rozm, ziemia.pk[x1, z1].scen_rozm, ziemia.pk[x1, z1].scen_rozm);
        glCallList(l_cien);
        glPopMatrix;
      end;

    end;
  end;
  glDepthMask(GL_TRUE);
  glDisable(GL_BLEND);
  glPopAttrib;
  wylacz_teksture;

  // sceneria
  glMaterialf(GL_FRONT, GL_SHININESS, 60);

  xod := trunc((gracz.x - ziemia.px) / ziemia.wlk) - widocznoscscen;
  xdo := trunc((gracz.x - ziemia.px) / ziemia.wlk) + widocznoscscen;
  zod := trunc((gracz.z - ziemia.pz) / ziemia.wlk) - widocznoscscen;
  zdo := trunc((gracz.z - ziemia.pz) / ziemia.wlk) + widocznoscscen;

  for z := zod to zdo { ziemia.wz-2 } do
  begin
    z1 := (z + zwz10) mod ziemia.wz;
    for x := xod to xdo { ziemia.wx-2 } do
    begin
      x1 := (x + zwx10) mod ziemia.wx;

      if ziemia.pk[x1, z1].scen then
      begin
        // glVertex3f(x*ziemia.wlk+ziemia.px,ziemia.pk[x1,z1].p,z*ziemia.wlk+ziemia.pz);
        glPushMatrix;
        wlacz_teksture(2);
        glTranslatef(x * ziemia.wlk + ziemia.px, ziemia.pk[x1, z1].p, z * ziemia.wlk + ziemia.pz);
        // pokaz_element_obiekt(obiekt[ob_sceneria1], ziemia.pk[x1,z1].scen_rodz,true);

        glcolor3f(ziemia.pk[x1, z1].sckr, ziemia.pk[x1, z1].sckg, ziemia.pk[x1, z1].sckb);

        mat_2a[0] := ziemia.pk[x1, z1].sckr;
        mat_2a[1] := ziemia.pk[x1, z1].sckg;
        mat_2a[2] := ziemia.pk[x1, z1].sckb;
        mat_2a[3] := 1;
        mat_2s[0] := ziemia.pk[x1, z1].sckr;
        mat_2s[1] := ziemia.pk[x1, z1].sckg;
        mat_2s[2] := ziemia.pk[x1, z1].sckb;
        mat_2s[3] := 1;
        glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_2a);
        glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_2a);
        glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_2s);

        glScalef(ziemia.pk[x1, z1].scen_rozm, ziemia.pk[x1, z1].scen_rozm, ziemia.pk[x1, z1].scen_rozm);
        if ziemia.pk[x1, z1].scen_rodz in [1, 5] then
        begin
          obrx := ziemia.pk[x1, z1].scen_obrx + sin(x1 + z1 + licz / (153.5 * ziemia.pk[x1, z1].scen_rozm)) * 10;
          obrz := ziemia.pk[x1, z1].scen_obrz - cos(x1 - z1 + licz / (156.3 * ziemia.pk[x1, z1].scen_rozm)) * 10;
          obry := ziemia.pk[x1, z1].scen_obry + cos(-x1 - z1 * 3 + licz / (244.3 * ziemia.pk[x1, z1].scen_rozm)) * 90;
        end
        else
        begin
          obrx := ziemia.pk[x1, z1].scen_obrx;
          obrz := ziemia.pk[x1, z1].scen_obrz;
          obry := ziemia.pk[x1, z1].scen_obry;
        end;
        glRotatef(obry, 0, 1, 0);
        glRotatef(obrx, 1, 0, 0);
        glRotatef(obrz, 0, 0, 1);
        glCallList(l_sceneria[ziemia.pk[x1, z1].scen_rodz]);

        glPopMatrix;
      end;

    end;
  end;
  glDisable(GL_COLOR_MATERIAL);
  wylacz_teksture;

  glPopMatrix;

  // rysuj_wode;

  if ziemia.widac < 1 then
    glFogf(GL_FOG_DENSITY, 0.0015);

end;

// ---------------------------------------------------------------------------
procedure rysuj_krzaki;

const
  tr = 3.5; // 7

var
  a, x, z, xod, xdo, zod, zdo, x1, z1, z11, zwz10, zwx10: integer;
  mat_2a, mat_2d, mat_2s: array [0 .. 3] of GLFloat;
  obrx, obry, obrz, odl, r, gx1, gz1: real;
begin
  if not ustawienia.krzaki then
    exit;

  if (ziemia.widac <= 0) then
    exit;

  if ziemia.widac < 1 then
    glFogf(GL_FOG_DENSITY, 0.0065 - ziemia.widac * 0.005);

  zwz10 := ziemia.wz * 10;
  zwx10 := ziemia.wx * 10;

  glPolygonMode(GL_FRONT, GL_FILL);
  glDepthMask(GL_FALSE);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  // krzaki
  glMaterialf(GL_FRONT, GL_SHININESS, 20);

  xod := trunc((gracz.x - ziemia.px) / ziemia.wlk) - widocznosckrzak;
  xdo := trunc((gracz.x - ziemia.px) / ziemia.wlk) + widocznosckrzak;
  zod := trunc((gracz.z - ziemia.pz) / ziemia.wlk) - widocznosckrzak;
  zdo := trunc((gracz.z - ziemia.pz) / ziemia.wlk) + widocznosckrzak;

  glEnable(GL_BLEND);
  glEnable(GL_COLOR_MATERIAL);
  glDisable(GL_CULL_FACE);

  wlacz_teksture(18);

  for z := zod to zdo do
  begin
    z1 := (z + zwz10) mod ziemia.wz;
    for x := xod to xdo do
    begin
      x1 := (x + zwx10) mod ziemia.wx;

      if length(ziemia.pk[x1, z1].krzaki) > 0 then
      begin
        for a := 0 to high(ziemia.pk[x1, z1].krzaki) do
          if ziemia.pk[x1, z1].krzaki[a].jest then
          begin
            { odl:=sqrt2(sqr( ziemia.pk[x1,z1].krzaki[a].x-gracz.x) +
              sqr( ziemia.pk[x1,z1].krzaki[a].y-gracz.y) +
              sqr( ziemia.pk[x1,z1].krzaki[a].z-gracz.z) ); }

            if (ziemia.pk[x1, z1].krzaki[a].x > -ziemia.px / 2) and (gra.jestkamera[0, 0] < ziemia.px / 2) then
              gx1 := gra.jestkamera[0, 0] - ziemia.px * 2
            else if (ziemia.pk[x1, z1].krzaki[a].x < ziemia.px / 2) and (gra.jestkamera[0, 0] > -ziemia.px / 2) then
              gx1 := gra.jestkamera[0, 0] + ziemia.px * 2
            else
              gx1 := gra.jestkamera[0, 0];
            if (ziemia.pk[x1, z1].krzaki[a].z > -ziemia.pz / 2) and (gra.jestkamera[0, 2] < ziemia.pz / 2) then
              gz1 := gra.jestkamera[0, 2] - ziemia.pz * 2
            else if (ziemia.pk[x1, z1].krzaki[a].z < ziemia.pz / 2) and (gra.jestkamera[0, 2] > -ziemia.pz / 2) then
              gz1 := gra.jestkamera[0, 2] + ziemia.pz * 2
            else
              gz1 := gra.jestkamera[0, 2];

            odl := sqrt2(sqr(ziemia.pk[x1, z1].krzaki[a].x - gx1) + sqr(ziemia.pk[x1, z1].krzaki[a].y -
              gra.jestkamera[0, 1]) + sqr(ziemia.pk[x1, z1].krzaki[a].z - gz1));

            r := ((widocznosckrzak * ziemia.wlk) - odl) / (ziemia.wlk * 5);
            if r > 1 then
              r := 1;

            if r > 0 then
            begin
              glColor4f(ziemia.pk[x1, z1].krzaki[a].kr, ziemia.pk[x1, z1].krzaki[a].kg,
                ziemia.pk[x1, z1].krzaki[a].kb, r);

              glPushMatrix;
              glTranslatef(ziemia.pk[x1, z1].krzaki[a].x, ziemia.pk[x1, z1].krzaki[a].y, ziemia.pk[x1, z1].krzaki[a].z);

              mat_2a[0] := ziemia.pk[x1, z1].krzaki[a].kr;
              mat_2a[1] := ziemia.pk[x1, z1].krzaki[a].kg;
              mat_2a[2] := ziemia.pk[x1, z1].krzaki[a].kb;
              mat_2a[3] := 1;
              mat_2s[0] := ziemia.pk[x1, z1].krzaki[a].kr;
              mat_2s[1] := ziemia.pk[x1, z1].krzaki[a].kg;
              mat_2s[2] := ziemia.pk[x1, z1].krzaki[a].kb;
              mat_2s[3] := 1;
              glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, @mat_2a);
              glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, @mat_2a);
              glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @mat_2s);

              glScalef(ziemia.pk[x1, z1].krzaki[a].rozm, ziemia.pk[x1, z1].krzaki[a].rozm,
                ziemia.pk[x1, z1].krzaki[a].rozm);
              obrx := ziemia.pk[x1, z1].krzaki[a].obrx;
              // +sin(x1+z1+licz/(153.5*ziemia.pk[x1,z1].krzaki[a].rozm))*10;
              obrz := -cos(x1 + { -z1+ } licz / (3 * ziemia.pk[x1, z1].krzaki[a].rozm)) * 15;
              obry := ziemia.pk[x1, z1].krzaki[a].obry;
              // +cos(-x1-z1*3+licz/(244.3*ziemia.pk[x1,z1].krzaki[a].rozm))*90;

              glRotatef(obry, 0, 1, 0);
              glRotatef(obrz, 1, 0, 0);
              // glRotatef(obrx, 1,0,0);
              glCallList(l_krzaki[ziemia.pk[x1, z1].krzaki[a].rodzaj]);

              glPopMatrix;
            end;
          end;
      end;

    end;
  end;
  glEnable(GL_CULL_FACE);
  glDisable(GL_BLEND);
  glDepthMask(GL_TRUE);
  glDisable(GL_COLOR_MATERIAL);
  wylacz_teksture;

  if ziemia.widac < 1 then
    glFogf(GL_FOG_DENSITY, 0.0015);
end;

// ---------------------------------------------------------------------------
procedure rysuj_swiatelko(x, y, z, rozmiar: real; kolr, kolg, kolb, kola: GLFloat);

var
  right, up: array [0 .. 2] of GLFloat;
  // ={viewMatrix[0], viewMatrix[4], viewMatrix[8]};
  viewMatrix: array [0 .. 15] of GLFloat;
begin
  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glEnable(GL_COLOR_MATERIAL);
  glDisable(GL_LIGHTING);
  // glDisable(GL_FOG);
  glPolygonMode(GL_FRONT, GL_FILL);
  glEnable(GL_BLEND);
  glDepthMask(GL_FALSE);
  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);
  glMaterialf(GL_FRONT, GL_SHININESS, 1);
  wlacz_teksture(11);

  glGetFloatv(GL_MODELVIEW_MATRIX, @viewMatrix);
  right[0] := viewMatrix[0];
  right[1] := viewMatrix[4];
  right[2] := viewMatrix[8];
  up[0] := viewMatrix[1];
  up[1] := viewMatrix[5];
  up[2] := viewMatrix[9];

  glColor4f(kolr, kolg, kolb, kola);
  rysuj_sprajt(x, y, z, rozmiar, right, up, viewMatrix[2]);
  wylacz_teksture;
  glPopAttrib;

end;

// ---------------------------------------------------------------------------
procedure rysuj_swiatelko_obr(x, y, z, rozmiar: real; kolr, kolg, kolb, kola: GLFloat; kat: real);

var
  right, up: array [0 .. 2] of GLFloat;
  // ={viewMatrix[0], viewMatrix[4], viewMatrix[8]};
  viewMatrix: array [0 .. 15] of GLFloat;
begin
  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glEnable(GL_COLOR_MATERIAL);
  glDisable(GL_LIGHTING);
  // glDisable(GL_FOG);
  glPolygonMode(GL_FRONT, GL_FILL);
  glEnable(GL_BLEND);
  glDepthMask(GL_FALSE);
  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);
  glMaterialf(GL_FRONT, GL_SHININESS, 1);
  wlacz_teksture(11);

  glGetFloatv(GL_MODELVIEW_MATRIX, @viewMatrix);
  right[0] := viewMatrix[0];
  right[1] := viewMatrix[4];
  right[2] := viewMatrix[8];
  up[0] := viewMatrix[1];
  up[1] := viewMatrix[5];
  up[2] := viewMatrix[9];

  glColor4f(kolr, kolg, kolb, kola);
  rysuj_sprajt(x, y, z, rozmiar, right, up, kat);
  wylacz_teksture;
  glPopAttrib;

end;

// ---------------------------------------------------------------------------
procedure rysuj_oslone_gracza(nazewnatrz: boolean = true);

const
  mata: array [0 .. 3] of GLFloat = (1, 0.2, 0.7, 1.0);
begin
  if (gracz.oslonablysk <= 0) or (gracz.sila <= 0.8) then
    exit;

  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glPushMatrix;
  glMaterialf(GL_FRONT, GL_SHININESS, 40);
  glMaterialfv(GL_FRONT, GL_AMBIENT, @mata);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mata);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mata);

  gluQuadricTexture(dupa, GLU_TRUE);
  gluQuadricNormals(dupa, GLU_SMOOTH);
  if nazewnatrz then
    gluQuadricOrientation(dupa, GLU_OUTSIDE)
  else
    gluQuadricOrientation(dupa, GLU_INSIDE);

  // glBlendFunc(GL_SRC_ALPHA, GL_DST_ALPHA);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glPolygonMode(GL_FRONT, GL_FILL);
  glEnable(GL_BLEND);
  glDepthMask(GL_FALSE);
  // glDisable(GL_CULL_FACE);
  // glCullFace(GL_BACK);

  glEnable(GL_COLOR_MATERIAL);
  glColor4f(1, 0.2 + gracz.oslonablysk * 0.6, 0.7 + gracz.oslonablysk * 0.3, gracz.oslonablysk * 0.3);
  wlacz_teksture(15);
  glTranslatef(gracz.x, gracz.y, gracz.z);
  glRotatef(gracz.kier, 0, -1, 0);
  glRotatef(licz * 27.3, 1, 0, 0);
  glRotatef(licz * 11.63, 0, 0, 1);
  gluQuadricTexture(dupa, GLU_TRUE);
  gluSphere(dupa, 7, 15, 15);
  wylacz_teksture;

  glDisable(GL_BLEND);
  glDepthMask(GL_TRUE);
  glEnable(GL_CULL_FACE);

  glPopMatrix;
  glPopAttrib;

end;

// ---------------------------------------------------------------------------
procedure rysuj_gracza;

const
  mata: array [0 .. 3] of GLFloat = (1.00, 1.00, 0.80, 1.0);

var
  g, ax: integer;
  r, zni: real;
  right, up: array [0 .. 2] of GLFloat;
  // ={viewMatrix[0], viewMatrix[4], viewMatrix[8]};
  viewMatrix: array [0 .. 15] of GLFloat;
begin
  rysuj_oslone_gracza;

  glPushMatrix;
  glTranslatef(gracz.x, gracz.y, gracz.z);
  glRotatef(gracz.dz * 6, gracz.wykrecsila, 0, 0);
  glRotatef(-gracz.dx * 6, 0, 0, gracz.wykrecsila);
  glRotatef(gracz.kier, 0, -1, 0);
  glRotatef(180, 0, 1, 0);

  zni := gracz.silaskrzywien;

  // glGetFloatv(GL_MODELVIEW_MATRIX, @ttt);

  // glScalef(5,5,5);
  // pokaz_obiekt(obiekt[ob_gracz]);

  for g := 0 to High(obiekt[ob_gracz].o.Groups) do
  begin
    with obiekt[ob_gracz].o.Groups[g] do
    begin
      glPushMatrix;
      glRotatef(gracz.elementy[g].obrx, 1, 0, 0);
      glRotatef(gracz.elementy[g].obry, 0, 1, 0);
      glRotatef(gracz.elementy[g].obrz, 0, 0, 1);
      if g in [2 .. 7] then
        pokaz_element_obiekt(obiekt[ob_gracz], g, false, -1, false, zni, gracz.randuszkodzenia)
      else
      begin
        glPushMatrix;
        glTranslatef(0, gracz.nacisk * 5, 0);
        pokaz_element_obiekt(obiekt[ob_gracz], g, false, -1, false, zni, gracz.randuszkodzenia);
        glPopMatrix;
      end;
      glPopMatrix;
    end;
  end;

  wylacz_teksture();

  if gracz.sila > 0.4 then
  begin

    wlacz_teksture_env(10);

    glDepthMask(GL_FALSE);
    glEnable(GL_BLEND);
    glEnable(GL_COLOR_MATERIAL);
    glColor4f(1, 1, 1, 0.14);
    glMaterialf(GL_FRONT, GL_SHININESS, 90.0);

    for g := 0 to High(obiekt[ob_gracz].o.Groups) do
    begin
      with obiekt[ob_gracz].o.Groups[g] do
      begin
        glPushMatrix;
        glRotatef(gracz.elementy[g].obrx, 1, 0, 0);
        glRotatef(gracz.elementy[g].obry, 0, 1, 0);
        glRotatef(gracz.elementy[g].obrz, 0, 0, 1);
        if g in [2 .. 7] then
          pokaz_element_obiekt(obiekt[ob_gracz], g, false, -1, true, zni, gracz.randuszkodzenia)
        else
        begin
          glPushMatrix;
          glTranslatef(0, gracz.nacisk * 5, 0);
          pokaz_element_obiekt(obiekt[ob_gracz], g, false, -1, true, zni, gracz.randuszkodzenia);
          glPopMatrix;
        end;
        glPopMatrix;
      end;
    end;

    glMaterialf(GL_FRONT, GL_SHININESS, 17);
    glDisable(GL_COLOR_MATERIAL);
    glDisable(GL_BLEND);
    glDepthMask(GL_TRUE);

    wylacz_teksture();
  end;

  glScalef(5, 5, 5);
  // glDepthFunc(GL_ALWAYS);
  if (gracz.swiatlodol > 0) then
    rysuj_swiatelko(0, gracz.nacisk - 0.7, 0, gracz.swiatlodol * 0.3, 1, 1, 0.9, gracz.swiatlodol * 0.4);

  if (gracz.swiatlotyl > 0) then
    rysuj_swiatelko(0, gracz.nacisk, -0.9, gracz.swiatlotyl * 0.2, 1, 1, 0.9, gracz.swiatlotyl * 0.3);

  if (gracz.swiatlolewo > 0) then
    rysuj_swiatelko(-0.7, gracz.nacisk, -0.3, gracz.swiatlolewo * 0.2, 1, 1, 0.9, gracz.swiatlolewo * 0.3);

  if (gracz.swiatloprawo > 0) then
    rysuj_swiatelko(0.7, gracz.nacisk, -0.3, gracz.swiatloprawo * 0.2, 1, 1, 0.9, gracz.swiatloprawo * 0.3);

  if (gracz.swiatlogora > 0) then
    rysuj_swiatelko(0, gracz.nacisk + 0.3, -0.7, gracz.swiatlogora * 0.2, 1, 1, 0.9, gracz.swiatlogora * 0.3);

  // glDepthFunc(GL_LEQUAL);

  if (not gracz.uszkodzenia[0]) and (((gra.etap = 0) and (intro.scena = 1) and (gracz.y >= matka.y + 4.4)) or
    ((gra.etap = 1) and (gracz.zyje))) then
  begin
    glPushAttrib(GL_ALL_ATTRIB_BITS);
    glPushMatrix;

    glRotatef(gracz.elementy[17].obrx, 1, 0, 0);
    glRotatef(gracz.elementy[17].obry, 0, 1, 0);
    glRotatef(gracz.elementy[17].obrz, 0, 0, 1);

    glTranslatef(-0.38, -0.54 + gracz.nacisk, 0.58);
    glRotatef(10, 1, 0, 0);
    glRotatef(7, 0, 1, 0);
    glEnable(GL_COLOR_MATERIAL);
    glDisable(GL_LIGHTING);
    // glDisable(GL_FOG);
    glPolygonMode(GL_FRONT, GL_FILL);
    glPolygonMode(GL_BACK, GL_FILL);
    glEnable(GL_BLEND);
    glDepthMask(GL_FALSE);
    glDisable(GL_CULL_FACE);
    glMaterialf(GL_FRONT, GL_SHININESS, 1);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mata);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mata);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mata);
    gluQuadricTexture(dupa, GLU_TRUE);
    gluQuadricNormals(dupa, GLU_SMOOTH);
    gluQuadricOrientation(dupa, GLU_INSIDE);
    wlacz_teksture(12);

    glColor4f(1, 1, 0.9, 0.15);
    gluQuadricTexture(dupa, GLU_TRUE);

    gluCylinder(dupa, 0.1, 1.5, 4, 12, 1);

    wylacz_teksture;
    glPopMatrix;
    glPopAttrib;

    glPushMatrix;
    glRotatef(gracz.elementy[17].obrx, 1, 0, 0);
    glRotatef(gracz.elementy[17].obry, 0, 1, 0);
    glRotatef(gracz.elementy[17].obrz, 0, 0, 1);
    rysuj_swiatelko(-0.38, -0.54 + gracz.nacisk, 0.58, 0.12, 1, 1, 0.8, 0.7);
    glPopMatrix;
  end;

  r := gracz.sila;
  if r > 0.7 then
    r := 0.7;
  if r > 0 then
  begin
    glPushMatrix;
    glRotatef(gracz.elementy[15].obrx, 1, 0, 0);
    glRotatef(gracz.elementy[15].obry, 0, 1, 0);
    glRotatef(gracz.elementy[15].obrz, 0, 0, 1);
    rysuj_swiatelko(0.01, 1.06 + gracz.nacisk, 0, 0.05, 1, 0.2, 0.07, r);
    glPopMatrix;
  end;

  glPopMatrix;

  { glPushMatrix;
    glTranslatef(0,100,0);
    glEnable(GL_BLEND);
    for a:=0 to 3 do
    for x:=0 to 3 do begin
    pisz_liczbe(round( ttt[a*4+x]*1000), 0+x*13,130-a*8,0, 1, right,up);
    end;
    glDisable(GL_BLEND);
    glPopMatrix;
  }
  // glPushMatrix;
  { glEnable(GL_BLEND);
    pisz_liczbe(round((gracz.x-ziemia.px)/ziemia.wlk), gracz.x,gracz.y+10,gracz.z,2, right,up);
    glDisable(GL_BLEND); }
  // glPopMatrix;

  j := (gracz.y - gracz.cieny) / 600;
  if j > 0 then
  begin
    if j > 1 then
      j := 1;
    glPushMatrix;
    // glTranslatef(gracz.x,gracz.cieny,gracz.z);
    // gluSphere(dupa,1,4,4);
    glTranslatef(gracz.x, 0, gracz.z);
    // glRotatef(gracz.kier,0,-1,0);
    wlacz_teksture(4);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    glEnable(GL_COLOR_MATERIAL);
    glColor4f(1, 1, 1, 1 - j);
    glBegin(GL_QUADS);
    glTexCoord2f(0, 1);
    glVertex3f(-4 - 7 * j, gdzie_y(gracz.x - 4 - 7 * j, gracz.z + 4 + 7 * j, gracz.y) + 0.2, +4 + 7 * j);
    glTexCoord2f(1, 1);
    glVertex3f(+4 + 7 * j, gdzie_y(gracz.x + 4 + 7 * j, gracz.z + 4 + 7 * j, gracz.y) + 0.2, +4 + 7 * j);
    glTexCoord2f(1, 0);
    glVertex3f(+4 + 7 * j, gdzie_y(gracz.x + 4 + 7 * j, gracz.z - 4 - 7 * j, gracz.y) + 0.2, -4 - 7 * j);
    glTexCoord2f(0, 0);
    glVertex3f(-4 - 7 * j, gdzie_y(gracz.x - 4 - 7 * j, gracz.z - 4 - 7 * j, gracz.y) + 0.2, -4 - 7 * j);
    glEnd;
    glDisable(GL_BLEND);
    wylacz_teksture;
    glPopMatrix;
  end;
end;

// ---------------------------------------------------------------------------
procedure rysuj_kokpit;

const
  mata: array [0 .. 3] of GLFloat = (1.00, 1.00, 0.80, 1.0);

var
  g: integer;
  r: real;
  right, up: array [0 .. 2] of GLFloat;
  // ={viewMatrix[0], viewMatrix[4], viewMatrix[8]};
  viewMatrix: array [0 .. 15] of GLFloat;
begin
  rysuj_oslone_gracza(false);
  glDisable(GL_LIGHT1);
  if gracz.swiatlodol > 0 then
    glDisable(GL_LIGHT2);

  glPushMatrix;
  glTranslatef(gracz.x, gracz.y, gracz.z);
  { glRotatef(gracz.dz*3, gracz.wykrecsila,0,0);
    glRotatef(-gracz.dx*3, 0,0,gracz.wykrecsila); }
  // glRotatef(90,0,1,0);

  glRotatef(gracz.kier, 0, -1, 0);
  glTranslatef(0, -1, -1);

  // glGetFloatv(GL_MODELVIEW_MATRIX, @ttt);

  // glScalef(5,5,5);
  pokaz_obiekt(obiekt[ob_kokpit]);

  glPopMatrix;

  if gracz.swiatlodol > 0 then
    glEnable(GL_LIGHT2);
  if not gracz.uszkodzenia[0] then
    glEnable(GL_LIGHT1);

  j := (gracz.y - gracz.cieny) / 600;
  if j > 0 then
  begin
    if j > 1 then
      j := 1;
    glPushMatrix;
    // glTranslatef(gracz.x,gracz.cieny,gracz.z);
    // gluSphere(dupa,1,4,4);
    glTranslatef(gracz.x, 0, gracz.z);
    // glRotatef(gracz.kier,0,-1,0);
    wlacz_teksture(4);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    glEnable(GL_COLOR_MATERIAL);
    glColor4f(1, 1, 1, 1 - j);
    glBegin(GL_QUADS);
    glTexCoord2f(0, 1);
    glVertex3f(-4 - 7 * j, gdzie_y(gracz.x - 4 - 7 * j, gracz.z + 4 + 7 * j, gracz.y) + 0.2, +4 + 7 * j);
    glTexCoord2f(1, 1);
    glVertex3f(+4 + 7 * j, gdzie_y(gracz.x + 4 + 7 * j, gracz.z + 4 + 7 * j, gracz.y) + 0.2, +4 + 7 * j);
    glTexCoord2f(1, 0);
    glVertex3f(+4 + 7 * j, gdzie_y(gracz.x + 4 + 7 * j, gracz.z - 4 - 7 * j, gracz.y) + 0.2, -4 - 7 * j);
    glTexCoord2f(0, 0);
    glVertex3f(-4 - 7 * j, gdzie_y(gracz.x - 4 - 7 * j, gracz.z - 4 - 7 * j, gracz.y) + 0.2, -4 - 7 * j);
    glEnd;
    glDisable(GL_BLEND);
    wylacz_teksture;
    glPopMatrix;
  end;
end;

// ---------------------------------------------------------------------------
procedure rysuj_smieci;

var
  a: integer;
  xod, xdo, zod, zdo, x1, z1: real;
begin

  xod := gracz.x - widocznosc * ziemia.wlk;
  xdo := gracz.x + widocznosc * ziemia.wlk;
  zod := gracz.z - widocznosc * ziemia.wlk;
  zdo := gracz.z + widocznosc * ziemia.wlk;

  for a := 0 to high(smiec) do
    if smiec[a].jest then
      with smiec[a] do
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

        if (x1 >= xod) and (x1 <= xdo) and (z1 >= zod) and (z1 <= zdo) then
        begin

          glPushMatrix;
          glTranslatef(x1, y, z1);

          { case nobiekt of
            //ob_gracz:glScalef(5,5,5);
            //ob_dzialkokawalki:glScalef(2,2,2);
            //ob_pilot:glScalef(0.5,0.5,0.5);
            end; }
          { glTranslatef(-obiekt[ob_gracz].o.Groups[element].srx*2 ,
            -obiekt[ob_gracz].o.Groups[element].sry*2 ,
            -obiekt[ob_gracz].o.Groups[element].srz*2 ); }
          glRotatef(obrx, 1, 0, 0);
          glRotatef(obry, 0, 1, 0);
          glRotatef(obrz, 0, 0, 1);

          { with obiekt[ob_gracz].o do
            with obiekt[ob_gracz].o.Groups[element] do }

          if nobiekt = ob_pilot then
            pokaz_obiekt(obiekt[nobiekt])
          else
            pokaz_element_obiekt(obiekt[nobiekt], element, true, -1, false, silaskrzywien, randuszkodzenia);
          glPopMatrix;
        end;
      end;
end;

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
  for a := 0 to high(dym) do
    if dym[a].jest and (dym[a].rodz <> 2) then
      with dym[a] do
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
          (* glTranslatef(x1,y,z1);
            glRotatef(licz*10,right[2] + up[2],right[1] + up[1],right[0] + up[0]{right[0] + up[0],right[1] + up[1],right[2] + up[2]});
            glTranslatef(-x1,-y,-z1); *)
          {
            glVertex3f (
            (sx + (right[0] + up[0]) * -sr),
            (sy + (right[1] + up[1]) * -sr),
            (sz + (right[2] + up[2]) * -sr)
            );
          }
          rysuj_sprajt(x1, y, z1, rozmiar, right, up, obrot);
          glPopMatrix;
          wylacz_teksture;
        end;

      end;
  wylacz_teksture;

  glPopAttrib;
end;

// ---------------------------------------------------------------------------
procedure rysuj_iskry;

var
  a: integer;
  xod, xdo, zod, zdo, x1, z1: real;
begin
  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_BLEND);
  // glDisable(GL_LIGHTING);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE);

  for a := 0 to high(iskry) do
    if iskry[a].jest then
      with iskry[a] do
      begin
        glPushMatrix;
        glTranslatef(x, y, z);

        { glRotatef(kier-90,0,-1,0);
          glRotatef(kierdol,0,0,-1);
          glRotatef(obrot,1,0,0); }

        glBegin(GL_LINES);
        glColor4f(kolr, kolg, kolb, przezr);
        glVertex3f(0, 0, 0);

        glColor4f(kolr, kolg, kolb, 0.0);
        glVertex3f(-dx * 8, -dy * 8, -dz * 8);
        glEnd();

        if przezr > 0.5 then
          rysuj_swiatelko(0, 0, 0, (0.3 + random * 0.5) * (przezr * 2), kolr, kolg, kolb, (przezr - 0.4));

        glPopMatrix;
      end;

  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  // glEnable(GL_LIGHTING);
  glDisable(GL_BLEND);
  glDisable(GL_COLOR_MATERIAL);

end;

// ---------------------------------------------------------------------------
procedure rysuj_matke;

const
  mata: array [0 .. 3] of GLFloat = (1.00, 1.00, 0.80, 1.0);

var
  a: integer;
  b, c: real;
  kr, kg, kb: real;
  kierl, posl, swi: TWektor;
  jest_swiatlo: boolean;

  tlight_ka1, tlight_kd1, tlight_ks1: array [0 .. 3] of GLFloat;

begin
  if (matka.widac <= 0) then
    exit;

  if ((gra.etap = 0) and (intro.scena = 1) and (gracz.y >= matka.y + 2.4)) or (gra.etap = 1) then
    jest_swiatlo := true
  else
    jest_swiatlo := false;

  glPushMatrix;
  glTranslatef(matka.x, matka.y + 8, matka.z);

  if jest_swiatlo and (matka.otwarcie_drzwi > 0) then
  begin
    glEnable(GL_LIGHT7);
    posl[0] := 380;
    posl[1] := 35;
    posl[2] := 0;
    posl[3] := 1;

    for a := 0 to 3 do
    begin
      tlight_ka1[a] := light_ka1[a] * matka.otwarcie_drzwi;
      tlight_kd1[a] := light_kd1[a] * matka.otwarcie_drzwi;
      tlight_ks1[a] := light_ks1[a] * matka.otwarcie_drzwi;
    end;

    glLightfv(GL_LIGHT7, GL_POSITION, @posl);
    glLightfv(GL_LIGHT7, GL_AMBIENT, @tlight_ka1);
    glLightfv(GL_LIGHT7, GL_DIFFUSE, @tlight_kd1);
    glLightfv(GL_LIGHT7, GL_SPECULAR, @tlight_ks1);
    glLightf(GL_LIGHT7, GL_CONSTANT_ATTENUATION, 0.100);
    glLightf(GL_LIGHT7, GL_LINEAR_ATTENUATION, 0.0000);
    glLightf(GL_LIGHT7, GL_QUADRATIC_ATTENUATION, 0.000002);

    kierl[0] := -1;
    kierl[1] := -0.5;
    kierl[2] := 0;
    normalize(kierl);
    glLightfv(GL_LIGHT7, GL_SPOT_DIRECTION, @kierl);
    // wektor kierunku swiecenia
    glLightf(GL_LIGHT7, GL_SPOT_CUTOFF, 60); // obciecie stozka
    glLightf(GL_LIGHT7, GL_SPOT_EXPONENT, 10); // wygaszanie na brzegach swiatla
  end;

  glRotatef(180, 0, 1, 0);

  glPushMatrix;
  glScalef(30, 30, 30);

  if matka.widac < 1 then
    // glFogf (GL_FOG_DENSITY, 0.0065);
    glFogf(GL_FOG_DENSITY, 0.0065 - matka.widac * 0.005);

  pokaz_obiekt(obiekt[ob_matka]);

  if (gra.etap <> 1) then
  begin
    rysuj_swiatelko(-14.5, -0.9, 6.5, 0.4, 1, 1, 0.9, 0.4 + random * 0.1);
    rysuj_swiatelko(-14.5, -0.9, -6.5, 0.4, 1, 1, 0.9, 0.4 + random * 0.1);
  end;

  if (gra.etap = 1) and (gra.jestkamera[0, 1] <= matka.y - 40) then
  begin

    rysuj_swiatelko(-9, -2.8, 7, 0.1, 1, 1, 0.9, 0.4 + random * 0.1);
    rysuj_swiatelko(-9, -2.8, -7, 0.1, 1, 1, 0.9, 0.4 + random * 0.1);
    rysuj_swiatelko(10.4, -2.8, 0, 0.1, 1, 1, 0.9, 0.4 + random * 0.1);
  end;

  if jest_swiatlo and (matka.otwarcie_drzwi > 0) then
  begin
    glPushAttrib(GL_ALL_ATTRIB_BITS);
    glPushMatrix;

    glTranslatef(-11.0, -0.1, 0);
    glEnable(GL_COLOR_MATERIAL);
    glDisable(GL_LIGHTING);
    glPolygonMode(GL_FRONT, GL_FILL);
    glPolygonMode(GL_BACK, GL_FILL);
    glEnable(GL_BLEND);
    glDepthMask(GL_FALSE);
    glDisable(GL_CULL_FACE);
    glMaterialf(GL_FRONT, GL_SHININESS, 1);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mata);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mata);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mata);
    wlacz_teksture(12);

    glColor4f(1, 1, 0.9, 0.01 + 0.13 * matka.otwarcie_drzwi);

    glPushMatrix;
    glTranslatef(0, -0.2, 0);
    glBegin(GL_QUADS);
    // gorna
    glTexCoord2f(1, 0);
    glVertex3f(0, 0.23 * matka.otwarcie_drzwi, 1);
    glTexCoord2f(1, 1);
    glVertex3f(10, 3 * matka.otwarcie_drzwi, 2);
    glTexCoord2f(0, 1);
    glVertex3f(10, 3 * matka.otwarcie_drzwi, -2);
    glTexCoord2f(0, 0);
    glVertex3f(0, 0.23 * matka.otwarcie_drzwi, -1);
    // lewa
    glTexCoord2f(1, 0);
    glVertex3f(0, 0 * matka.otwarcie_drzwi, 1);
    glTexCoord2f(1, 1);
    glVertex3f(10, 0 * matka.otwarcie_drzwi, 2.3);
    glTexCoord2f(0, 1);
    glVertex3f(10, 3 * matka.otwarcie_drzwi, 2);
    glTexCoord2f(0, 0);
    glVertex3f(0, 0.23 * matka.otwarcie_drzwi, 1);
    // prawa
    glTexCoord2f(1, 0);
    glVertex3f(0, 0, -1);
    glTexCoord2f(1, 1);
    glVertex3f(10, 0 * matka.otwarcie_drzwi, -2.3);
    glTexCoord2f(0, 1);
    glVertex3f(10, 3 * matka.otwarcie_drzwi, -2);
    glTexCoord2f(0, 0);
    glVertex3f(0, 0.23 * matka.otwarcie_drzwi, -1);
    glEnd;
    glPopMatrix;

    wylacz_teksture;

    glColor4f(1, 1, 0.9, 0.4);
    glTranslatef(0, -0.2, 0);
    glBegin(GL_QUADS);
    // srodek
    glTexCoord2f(1, 0);
    glVertex3f(0.15, 0.23 * matka.otwarcie_drzwi, 1);
    glTexCoord2f(1, 1);
    glVertex3f(0.25, 0.15 * matka.otwarcie_drzwi, 1);
    glTexCoord2f(0, 1);
    glVertex3f(0.25, 0.15 * matka.otwarcie_drzwi, -1);
    glTexCoord2f(0, 0);
    glVertex3f(0.15, 0.23 * matka.otwarcie_drzwi, -1);
    // srodek wyzej
    glTexCoord2f(1, 0);
    glVertex3f(0.25, 0.15 * matka.otwarcie_drzwi, 1);
    glTexCoord2f(1, 1);
    glVertex3f(0.28, 0, 1);
    glTexCoord2f(0, 1);
    glVertex3f(0.28, 0, -1);
    glTexCoord2f(0, 0);
    glVertex3f(0.25, 0.15 * matka.otwarcie_drzwi, -1);
    glEnd;

    glPopMatrix;
    glPopAttrib;
  end;

  if matka.widac < 1 then
    glFogf(GL_FOG_DENSITY, 0.0015);
  glPopMatrix;

  if matka.widac >= 1 then
  begin
    glTranslatef(1, 0, 0);
    b := (licz div 60) / 2;
    c := 34 - ((((licz div 5) * 5) mod 60) / 60) * 34;

    if (gracz.zyje and gracz.stoi and gracz.namatce) or (gra.etap = 0) then
    begin
      kr := 0;
      kg := 1;
      kb := 0;
    end
    else
    begin
      kr := 1;
      kg := 0;
      kb := 0;
    end;

    for a := 0 to 2 do
    begin
      rysuj_swiatelko(sin(b + (a * 120) * pi180) * c, -8, cos(b + (a * 120) * pi180) * c, 3, kr, kg, kb,
        ((34 - c) / 34) * 0.8);
    end;

    b := (licz div 10) mod 10;

    for a := 0 to 9 do
    begin
      rysuj_swiatelko(-35 - a * 31 - b * 3.1, -8, 8 + a * 4 + b * 0.4, 2, 1, 0, 0, 0.6);
      rysuj_swiatelko(-35 - a * 31 - b * 3.1, -8, -(8 + a * 3.7 + b * 0.37), 2, 1, 0, 0, 0.6);
    end;

  end;
  glPopMatrix;
end;

// ---------------------------------------------------------------------------
procedure rysuj_pilotow;

var
  a, g, tx: integer;
  xod, xdo, zod, zdo, x1, z1: real;
begin

  xod := gracz.x - widocznoscpil * ziemia.wlk;
  xdo := gracz.x + widocznoscpil * ziemia.wlk;
  zod := gracz.z - widocznoscpil * ziemia.wlk;
  zdo := gracz.z + widocznoscpil * ziemia.wlk;

  for a := 0 to high(pilot) do
    if pilot[a].jest then
      with pilot[a] do
      begin
        if ((nalotnisku >= 0) and (ziemia.widac > 0)) or ((nalotnisku < 0) and (matka.widac > 0)) or zawszewidac then
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

          if (x1 >= xod) and (x1 <= xdo) and (z1 >= zod) and (z1 <= zdo) then
          begin

            glPushMatrix;
            glTranslatef(x1, y + 2, z1);

            glRotatef(kier, 0, -1, 0);
            glRotatef(180, 0, 1, 0);

            glTranslatef(0, -2, 0);
            glRotatef(przewroc, 1, 0, 0);
            glTranslatef(0, 2, 0);

            // glScalef(0.4,0.4,0.4);
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
                      for g := 0 to High(Groups) do
                      begin
                        with Groups[g] do
                        begin
                          case g of
                            0 .. 2, 13, 14:
                              pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                            3 { rl-g } :
                              begin
                                glPushMatrix;
                                glTranslatef(0, 0.48, 0);
                                glRotatef(sin(ani * pi180) * 30, 1, 0, 0);
                                glTranslatef(0, -0.48, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;
                            4 { rl-d } :
                              begin
                                glPushMatrix;
                                glTranslatef(0, 0.48, 0);
                                glRotatef(sin(ani * pi180) * 30, 1, 0, 0);
                                glTranslatef(0, -0.48 - 0.2, 0);
                                glRotatef(-50 + sin(ani * pi180) * 40, 1, 0, 0);
                                glTranslatef(0, 0.2, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;

                            6 { rp-g } :
                              begin
                                glPushMatrix;
                                glTranslatef(0, 0.48, 0);
                                glRotatef(sin((180 + ani) * pi180) * 30, 1, 0, 0);
                                glTranslatef(0, -0.48, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;
                            5 { rp-d } :
                              begin
                                glPushMatrix;
                                glTranslatef(0, 0.48, 0);
                                glRotatef(sin((180 + ani) * pi180) * 30, 1, 0, 0);
                                glTranslatef(0, -0.48 - 0.2, 0);
                                glRotatef(-50 + sin((180 + ani) * pi180) * 40, 1, 0, 0);
                                glTranslatef(0, 0.2, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;

                            7 { nl-g } :
                              begin
                                glPushMatrix;
                                glRotatef(-20 + sin(ani * pi180) * 40, 1, 0, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;
                            8, 9 { nl-d } :
                              begin
                                glPushMatrix;
                                glRotatef(-20 + sin(ani * pi180) * 40, 1, 0, 0);
                                glTranslatef(0, -1.4, 0);
                                glRotatef(50 + cos((180 + ani) * pi180) * 40, 1, 0, 0);
                                glTranslatef(0, 1.4, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;

                            12 { np-g } :
                              begin
                                glPushMatrix;
                                glRotatef(-20 + sin((180 + ani) * pi180) * 40, 1, 0, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;
                            10, 11 { np-d } :
                              begin
                                glPushMatrix;
                                glRotatef(-20 + sin((180 + ani) * pi180) * 40, 1, 0, 0);
                                glTranslatef(0, -1.4, 0);
                                glRotatef(50 + cos(ani * pi180) * 40, 1, 0, 0);
                                glTranslatef(0, 1.4, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;
                          end;
                        end;
                      end;
                    end;

                  1:
                    begin // macha
                      for g := 0 to High(Groups) do
                      begin
                        with Groups[g] do
                        begin
                          case g of
                            0 .. 2, 7 .. 14:
                              pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                            3 { rl-g } :
                              begin
                                glPushMatrix;
                                glTranslatef(-0.64, 0.56, 0);
                                glRotatef(210 + sin((ani) * pi180) * 40, 0, 0, 1);
                                glTranslatef(0.64, -0.56, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;
                            4 { rl-d } :
                              begin
                                glPushMatrix;
                                glTranslatef(-0.64, 0.56, 0);
                                glRotatef(210 + sin((ani) * pi180) * 40, 0, 0, 1);
                                glTranslatef(0, -0.8, 0);
                                glRotatef(-20 + sin((ani) * pi180) * 30, 0, 0, 1);
                                glTranslatef(0.64, -0.56 + 0.8, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;

                            6 { rp-g } :
                              begin
                                glPushMatrix;
                                glTranslatef(0.64, 0.56, 0);
                                glRotatef(150 + sin((180 + ani) * pi180) * 40, 0, 0, 1);
                                glTranslatef(-0.64, -0.56, 0);
                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;
                            5 { rp-d } :
                              begin
                                glPushMatrix;
                                glTranslatef(0.64, 0.56, 0);
                                glRotatef(150 + sin((180 + ani) * pi180) * 40, 0, 0, 1);
                                glTranslatef(0, -0.8, 0);
                                glRotatef(20 + sin((180 + ani) * pi180) * 30, 0, 0, 1);
                                glTranslatef(-0.64, -0.56 + 0.8, 0);

                                pokaz_element_obiekt(obiekt[ob_pilot], g, false, tx);
                                glPopMatrix;
                              end;

                          end;
                        end;
                      end;
                    end;

                end; // case
              end;
            end
            else
            begin
              pokaz_obiekt(obiekt[ob_pilot], tx);
            end;

            glPopMatrix;

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
end;

// ---------------------------------------------------------------------------
procedure rysuj_dzialka;

var
  a: integer;
  xod, xdo, zod, zdo, x1, z1: real;
begin
  if ziemia.widac <= 0 then
    exit;

  xod := gracz.x - widocznoscdzial * ziemia.wlk;
  xdo := gracz.x + widocznoscdzial * ziemia.wlk;
  zod := gracz.z - widocznoscdzial * ziemia.wlk;
  zdo := gracz.z + widocznoscdzial * ziemia.wlk;

  for a := 0 to high(dzialko) do
    if dzialko[a].jest and not dzialko[a].rozwalone then
      with dzialko[a] do
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

        if (x1 >= xod) and (x1 <= xdo) and (z1 >= zod) and (z1 <= zdo) then
        begin

          glPushMatrix;
          glTranslatef(x1, y, z1);

          // glRotatef(180,0,1,0);

          // glScalef(0.8,0.8,0.8);
          // pokaz_obiekt(obiekt[ob_dzialko]);
          if (gracz.conamierzone = 0) and (gracz.namierzone = a) then
          begin
            glPushMatrix;
            wlacz_teksture(9);
            glPushAttrib(GL_ALL_ATTRIB_BITS);
            glColor4f(1, 0.2, 0.2, 1);
            glEnable(GL_COLOR_MATERIAL);
            glDisable(GL_LIGHTING);
            // glDisable(GL_FOG);
            glPolygonMode(GL_FRONT, GL_FILL);
            glEnable(GL_BLEND);
            // glDepthFunc(GL_ALWAYS);
            glDepthMask(GL_FALSE);
            glEnable(GL_CULL_FACE);
            glCullFace(GL_BACK);
            glMaterialf(GL_FRONT, GL_SHININESS, 1);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

            rysuj_sprajt(0, 0, 0, 30, right, up);

            // glDepthFunc(GL_LEQUAL);
            glPopAttrib;
            wylacz_teksture;
            glPopMatrix;
            // glScalef(2,10,2);
          end;
          glCallList(l_dzialko);

          glRotatef(-kier, 0, 1, 0);
          if rodzaj = 0 then
            glCallList(l_dzialkowieza)
          else
            glCallList(l_dzialkowieza2);

          if rodzaj = 0 then
          begin
            if namierza then
              rysuj_swiatelko(-2.2, 7.6, 2.8, 4 - swiatlo / 15, 0.3, 1, 0.4, 0.9 - swiatlo / 100)
            else
              rysuj_swiatelko(-2.2, 7.6, 2.8, 2 - swiatlo / 70, 1, 0.2, 0.8, 0.7 - swiatlo / 160);
          end
          else
          begin
            if namierza then
              rysuj_swiatelko(2, 6.6, 5.5, 4 - swiatlo / 15, 0.3, 1, 0.4, 0.9 - swiatlo / 100)
            else
              rysuj_swiatelko(2, 6.6, 5.5, 2 - swiatlo / 70, 1, 0.2, 0.8, 0.7 - swiatlo / 160);
          end;

          glRotatef(kat, 1, 0, 0);
          // pokaz_obiekt(obiekt[ob_dzialkolufa]);

          if rodzaj = 0 then
            glCallList(l_dzialkolufa)
          else
            glCallList(l_dzialkolufa2);

          glPopMatrix;
        end;

      end;
end;

// ---------------------------------------------------------------------------
procedure rysuj_rakiety;

var
  a, b: integer;
begin
  glDisable(GL_COLOR_MATERIAL);

  for a := 0 to high(rakieta) do
    if rakieta[a].jest then
      with rakieta[a] do
      begin

        glPushMatrix;
        glTranslatef(x, y, z);

        glRotatef(kier - 90, 0, -1, 0);
        glRotatef(kierdol, 0, 0, -1);
        glRotatef(obrot, 1, 0, 0);

        case rodzaj of
          0:
            begin
              glCallList(l_rakieta);
              if paliwo > 0 then
                rysuj_swiatelko(-2.4, 0, 0, 4 + random, 1, 1, 0.8, 0.8 + random * 0.2);
            end;
          1:
            begin
              wylacz_teksture;
              glEnable(GL_COLOR_MATERIAL);
              glEnable(GL_BLEND);
              glBegin(GL_LINES);
              glColor4f(1, 1, 1, 1.0);
              glVertex3f(0, 0, 0);

              glColor4f(1, 1, 1, 0.0);
              glVertex3f(-9, 0, 0);

              glEnd();
              glDisable(GL_BLEND);
              glDisable(GL_COLOR_MATERIAL);
            end;
          2:
            begin
              for b := 0 to 1 do
                rysuj_swiatelko(0, 0, 0, 20 + random * 20 - ord(paliwo <= 0) * 11, 1, 0.9 + random * 0.1,
                  0.8 + random * 0.2, 0.8 + random * 0.2 - ord(paliwo <= 0) * 0.5);
            end;
        end;
        glPopMatrix;

      end;
end;

// ---------------------------------------------------------------------------
procedure rysuj_mysliwce;

var
  a: integer;
  xod, xdo, zod, zdo, x1, z1: real;
begin
  xod := gracz.x - widocznosc * ziemia.wlk;
  xdo := gracz.x + widocznosc * ziemia.wlk;
  zod := gracz.z - widocznosc * ziemia.wlk;
  zdo := gracz.z + widocznosc * ziemia.wlk;

  for a := 0 to high(mysliwiec) do
    if mysliwiec[a].jest then
      with mysliwiec[a] do
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

        if (x1 >= xod) and (x1 <= xdo) and (z1 >= zod) and (z1 <= zdo) then
        begin

          glPushMatrix;
          glTranslatef(x1, y, z1);

          if (gracz.conamierzone = 1) and (gracz.namierzone = a) then
          begin
            glPushMatrix;
            wlacz_teksture(9);
            glPushAttrib(GL_ALL_ATTRIB_BITS);
            glColor4f(1, 0.2, 0.2, 1);
            glEnable(GL_COLOR_MATERIAL);
            glDisable(GL_LIGHTING);
            // glDisable(GL_FOG);
            glPolygonMode(GL_FRONT, GL_FILL);
            glEnable(GL_BLEND);
            // glDepthFunc(GL_ALWAYS);
            glDepthMask(GL_FALSE);
            glEnable(GL_CULL_FACE);
            glCullFace(GL_BACK);
            glMaterialf(GL_FRONT, GL_SHININESS, 1);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

            rysuj_sprajt(0, 0, 0, 15, right, up);

            // glDepthFunc(GL_LEQUAL);
            glPopAttrib;
            wylacz_teksture;
            glPopMatrix;
            // glScalef(2,10,2);
          end;

          glRotatef(kier - 90, 0, -1, 0);
          glRotatef(kierdol, 0, 0, -1);
          glRotatef(obrot, 1, 0, 0);
          glCallList(l_mysliwiec);

          rysuj_swiatelko(-7.2, 0.7, -3, 6, 1, 1, 0.9, 0.7 + random * 0.05);
          rysuj_swiatelko(-7.2, 0.7, 3, 6, 1, 1, 0.9, 0.7 + random * 0.05);

          glPopMatrix;

          j := (y - gdzie_y(x, z, y)) / 400;
          if j > 0 then
          begin
            if j > 0.6 then
              j := 0.6;
            glPushMatrix;
            glTranslatef(x1, 0, z1);
            wlacz_teksture(4);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glEnable(GL_BLEND);
            glEnable(GL_COLOR_MATERIAL);
            glColor4f(1, 1, 1, 1 - j);
            glBegin(GL_QUADS);
            glTexCoord2f(0, 1);
            glVertex3f(-7 - 12 * j, gdzie_y(x - 7 - 12 * j, z + 7 + 12 * j, y) + 0.2, +7 + 12 * j);
            glTexCoord2f(1, 1);
            glVertex3f(+7 + 12 * j, gdzie_y(x + 7 + 12 * j, z + 7 + 12 * j, y) + 0.2, +7 + 12 * j);
            glTexCoord2f(1, 0);
            glVertex3f(+7 + 12 * j, gdzie_y(x + 7 + 12 * j, z - 7 - 12 * j, y) + 0.2, -7 - 12 * j);
            glTexCoord2f(0, 0);
            glVertex3f(-7 - 12 * j, gdzie_y(x - 7 - 12 * j, z - 7 - 12 * j, y) + 0.2, -7 - 12 * j);
            glEnd;
            glDisable(GL_BLEND);
            wylacz_teksture;
            glPopMatrix;
          end;
        end;
      end;
end;

// ---------------------------------------------------------------------------
procedure rysuj_planete(ztylu: boolean; wielkosc: real);

const
  mata: array [0 .. 3] of GLFloat = (0.00, 0.00, 0.00, 1.0);
  mat: array [0 .. 3] of GLFloat = (0.10, 0.00, 0.00, 1.0);

var
  j: real;
begin
  glPushMatrix;
  glMaterialf(GL_FRONT, GL_SHININESS, 40);
  glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_1a);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mata);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat);

  glEnable(GL_COLOR_MATERIAL);
  wlacz_teksture(1);
  gluQuadricTexture(dupa, GLU_TRUE);

  if not winieta.jest then
  begin
    glcolor3f(ziemia.koltla[0], ziemia.koltla[1], ziemia.koltla[2]);
    if ztylu then
    begin
      if gra.rodzajmisji = 0 then
        glTranslatef(1000 + (random - 0.5) * intro.czas2 / 50, -70 + (random - 0.5) * intro.czas2 / 50,
          -50 + (random - 0.5) * intro.czas2 / 50)
      else
        glTranslatef(1000, -70, -50);
    end
    else
      glTranslatef(-5000, matka.y, matka.z);

    if ztylu then
    begin
      if (intro.czas2 < 550) or (gra.rodzajmisji <> 0) then
      begin
        glPushMatrix;
        glRotatef(intro.czas2 / 40, 0.7, 0.2, 1);
        gluSphere(dupa, 200 * wielkosc, 30, 30);
        glPopMatrix;
      end;

      if (gra.etap = 2) and (gra.rodzajmisji = 0) and (intro.czas2 >= 200) and (intro.czas2 <= 650) then
      begin
        if (intro.czas2 <= 250) then
          j := ((intro.czas2 - 200) / 50)
        else if (intro.czas2 > 500) then
          j := ((650 - intro.czas2) / 150)
        else
          j := 1;
        rysuj_swiatelko(400, 0, 0, 1400 + j * 2200 + random * 50, 1, 1, 0.8, j + random * 0.04);
      end;

      { glEnable(GL_BLEND);
        wylacz_teksture;
        glColor4f(ziemia.koltla[0],ziemia.koltla[1],ziemia.koltla[2], 0.3);
        gluSphere(dupa,230,30,30);
        glDisable(GL_BLEND); }
    end
    else
    begin
      glRotatef(intro.czas2 / 10, 0.7, 1.0, 0.1);
      gluSphere(dupa, (200 + intro.czas2 * 5) * wielkosc, 30, 30);

      { glEnable(GL_BLEND);
        wylacz_teksture;
        glColor4f(ziemia.koltla[0],ziemia.koltla[1],ziemia.koltla[2], 0.3);
        gluSphere(dupa,330+intro.czas2*5,30,30);
        glDisable(GL_BLEND); }
    end;

  end
  else
  begin
    glcolor3f(1, 0.8, 0.3);
    glTranslatef(1300, -900, 500);
    glPushMatrix;
    glRotatef(-licz / 90, 0.1, 1, 0);
    gluSphere(dupa, 2000, 50, 50);
    glPopMatrix;
    glcolor3f(0.2, 0.2, 0.12);
    glPushMatrix;
    glRotatef(40, 0, 0, -1);
    glRotatef(-licz / 80, 0, -1, 0);
    glTranslatef(-2600, 0, 0);
    glRotatef(70, 0, 0, 1);
    glRotatef(-licz / 9, 0, 1, 0);
    gluSphere(dupa, 200, 20, 20);
    glPopMatrix;

    { glEnable(GL_BLEND);
      wylacz_teksture;
      glColor4f(ziemia.koltla[0],ziemia.koltla[1],ziemia.koltla[2], 0.3);
      gluSphere(dupa,2100,30,30);
      glDisable(GL_BLEND); }

  end;

  wylacz_teksture;
  glPopMatrix;
end;

// ---------------------------------------------------------------------------
procedure rysuj_gwiazdy(pol: boolean);

const
  eqn: array [0 .. 3] of GLdouble = (0.0, 0.0, -1.0, 300.0);

var
  s: real;
begin
  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glPushMatrix;
  glMaterialf(GL_FRONT, GL_SHININESS, 0);
  glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_1s);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_1s);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_1s);

  glDisable(GL_LIGHTING);
  glDisable(GL_FOG);
  glDisable(GL_COLOR_MATERIAL);
  glcolor3f(0.5, 0.5, 0.5);
  wlacz_teksture(7);

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glScalef(2, 2, 2);

  glMatrixMode(GL_MODELVIEW);

  if gra.etap = 1 then
  begin
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, 25000.0);
    glMatrixMode(GL_MODELVIEW);

    if matka.widac < 1 then
    begin
      glEnable(GL_FOG);
      if gracz.y > matka.y - 250 then
      begin
        s := 0.0025 * ((matka.y - gracz.y) / 250);
      end
      else
        s := 0.0025;
      glFogf(GL_FOG_DENSITY, s);
    end
    else
    begin
      glDisable(GL_FOG);
    end;
  end;

  gluQuadricTexture(dupa, GLU_TRUE);
  gluQuadricNormals(dupa, GLU_SMOOTH);
  gluQuadricOrientation(dupa, GLU_INSIDE);

  glTranslatef(matka.x, matka.y, matka.z);

  glRotatef(90, 1, 0, 0);
  if gra.etap <> 1 then
    glRotatef(intro.czas2 / 100, 0.7, 0.2, 0.3);

  if pol then
  begin
    glClipPlane(GL_CLIP_PLANE0, @eqn);
    glEnable(GL_CLIP_PLANE0);
  end;

  if pol then
    gluSphere(dupa, 9000, 20, 20)
  else
    gluSphere(dupa, 5000, 20, 20);

  if pol then
  begin
    glDisable(GL_CLIP_PLANE0);
  end;

  gluQuadricOrientation(dupa, GLU_OUTSIDE);
  glEnable(GL_LIGHTING);
  glEnable(GL_FOG);
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glMatrixMode(GL_MODELVIEW);

  if gra.etap = 1 then
  begin
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, odlwidzenia);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
  end;

  wylacz_teksture;
  glPopMatrix;
  glPopAttrib;
end;

// ---------------------------------------------------------------------------
procedure rysuj_slonce;
begin
  glPushMatrix;

  if gra.etap = 1 then
  begin
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, 30000.0);
    glMatrixMode(GL_MODELVIEW);
  end;

  glDepthMask(GL_FALSE);
  glDisable(GL_FOG);
  glDepthFunc(GL_ALWAYS);
  rysuj_swiatelko_obr(-4200, 2700, -3000, 4100, 1, 0.6, 0.5, 0.23, sin(licz / 723.2) * 62);
  rysuj_swiatelko_obr(-4200, 2700, -3000, 2800, 1, 1, 0.95, 0.44, cos(licz / 591.2) * 41);
  rysuj_swiatelko_obr(-4200, 2700, -3000, 2200, 1, 1, 0.85, 0.97, sin(licz / 572) * 30);
  glDepthFunc(GL_LEQUAL);
  glEnable(GL_FOG);
  glDepthMask(GL_TRUE);

  if gra.etap = 1 then
  begin
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, odlwidzenia);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
  end;

  glPopMatrix;

end;

procedure rysuj_puste_tlo;

var
  s: real;
begin
  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glPushMatrix;
  glMaterialf(GL_FRONT, GL_SHININESS, 0);
  glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_1s);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_1s);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_1s);

  glDisable(GL_LIGHTING);
  glDisable(GL_FOG);
  glDisable(GL_COLOR_MATERIAL);
  glEnable(GL_COLOR_MATERIAL);
  glcolor3f(ziemia.jestkoltla[0], ziemia.jestkoltla[1], ziemia.jestkoltla[2]);
  glDepthMask(GL_FALSE);

  gluQuadricTexture(dupa, GLU_FALSE);
  gluQuadricNormals(dupa, GLU_SMOOTH);
  gluQuadricOrientation(dupa, GLU_INSIDE);

  glTranslatef(gracz.x, gracz.y, gracz.z);

  gluSphere(dupa, 1000, 20, 20);

  glDepthMask(GL_TRUE);

  gluQuadricOrientation(dupa, GLU_OUTSIDE);
  glEnable(GL_LIGHTING);
  glEnable(GL_FOG);

  glPopMatrix;
  glPopAttrib;
end;

// ---------------------------------------------------------------------------
procedure ustaw_kamere;

var
  viewMatrix: array [0 .. 15] of GLFloat;
  x, z, y, gy: real;
begin
  case gra.etap of
    0:
      begin // intro
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();

        gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, 9000.0);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();

        if intro.scena = 0 then
          glFogf(GL_FOG_DENSITY, 0.00001)
        else
          glFogf(GL_FOG_DENSITY, 0.0015);

        case intro.scena of
          // matka przejezdza obok kamery i leci w strone planety
          0:
            gluLookAt(matka.x - 1600 + intro.czas2 * 20, matka.y + 200 - intro.czas2 * 3, matka.z - 300 - intro.czas2,

              matka.x + intro.czas2 / 2, matka.y + 50 + intro.czas2 / 15, matka.z, 0, 1, 0);
          1:
            gluLookAt(gracz.x + sin(intro.czas * pi180) * (150 + 400 / (1 + intro.czas / 30)),
              gracz.y + 500 / (1 + intro.czas / 30), gracz.z - cos(intro.czas * pi180) *
              (150 + 400 / (1 + intro.czas / 70)), gracz.x, gracz.y, gracz.z, 0, 1, 0);
        end;
      end;
    1:
      begin // gra
        if not gra.pauza then
          gluLookAt(gra.jestkamera[0, 0], gra.jestkamera[0, 1], gra.jestkamera[0, 2], gra.jestkamera[1, 0],
            gra.jestkamera[1, 1], gra.jestkamera[1, 2], gra.jestkamera[2, 0], gra.jestkamera[2, 1],
            gra.jestkamera[2, 2])
        else
        begin
          x := gracz.x + sin((licz / 3.12) * pi180) * 100;
          z := gracz.z + cos((licz / 3.12) * pi180) * 100;
          y := gracz.y + sin((licz / 4.2) * pi180) * 30;
          gy := gdzie_y(x, z, y) + 1;
          if y < gy then
            y := gy;
          gluLookAt(x, y, z, gracz.x, gracz.y, gracz.z, 0, 1, 0)
        end;
      end;
    2:
      begin // outro
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();

        gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, 9000.0);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();

        if intro.scena <= 1 then
          glFogf(GL_FOG_DENSITY, 0.0005)
        else
          glFogf(GL_FOG_DENSITY, 0.00001);

        case intro.scena of
          // najazd dookola od spodu
          0:
            gluLookAt(matka.x + sin(intro.czas2 * 0.1 * pi180) * (550 + 1000 / (1 + intro.czas2 / 180)),
              matka.y - 200 - 500 / (1 + intro.czas2 / 60), matka.z - cos(intro.czas2 * 0.1 * pi180) *
              (550 + 1000 / (1 + intro.czas2 / 180)), matka.x, matka.y, matka.z, 0, 1, 0);
          // kamera zza matki, a matka odlatuje na wprost
          1:
            gluLookAt(-2000 + intro.czas2 / 8, matka.y - intro.czas2 / 2 - 100, matka.z + 300 + intro.czas2 / 2,

              matka.x, matka.y, matka.z, 0, 1, 0);
          // kamera sprzed matki, za nia widac planete
          2:
            gluLookAt(matka.x - 800 + intro.czas2 / 2, matka.y + 150 + intro.czas2 / 10,
              matka.z - 200 + intro.czas2 / 6,

              matka.x + intro.czas2 / 2, matka.y + 50 + intro.czas2 / 15, matka.z, 0, 1, 0);
        end;
      end;
  end;

  glGetFloatv(GL_MODELVIEW_MATRIX, @viewMatrix);
  right[0] := viewMatrix[0];
  right[1] := viewMatrix[4];
  right[2] := viewMatrix[8];
  up[0] := viewMatrix[1];
  up[1] := viewMatrix[5];
  up[2] := viewMatrix[9];
end;

// ---------------------------------------------------------------------------
procedure pokaz_winiete;

var
  width, height, a, b1, b2, b: integer;
  viewMatrix: array [0 .. 15] of GLFloat;
  s: string;
  koltla: array [0 .. 3] of GLFloat;
  r: real;
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

  gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, 9000.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  gluLookAt(sin(licz / 143) * 2, -cos(licz / 109.2) * 2, 3000 + cos(licz / 120) * 2, 0, 0, 0, 0, 1, 0);

  glGetFloatv(GL_MODELVIEW_MATRIX, @viewMatrix);
  right[0] := viewMatrix[0];
  right[1] := viewMatrix[4];
  right[2] := viewMatrix[8];
  up[0] := viewMatrix[1];
  up[1] := viewMatrix[5];
  up[2] := viewMatrix[9];

  glEnable(GL_LIGHTING);
  glEnable(GL_FOG);
  glFogf(GL_FOG_DENSITY, 0.001);
  koltla[0] := 0;
  koltla[1] := 0;
  koltla[2] := 0;
  koltla[3] := 0;
  glFogfv(GL_FOG_COLOR, @koltla);
  glClearColor(koltla[0], koltla[1], koltla[2], koltla[3]);

  rysuj_planete(false, 1);

  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glPushMatrix;
  glDisable(GL_FOG);
  glMaterialf(GL_FRONT, GL_SHININESS, 0);
  glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_1s);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_1s);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_1s);

  glDisable(GL_LIGHTING);
  glDisable(GL_COLOR_MATERIAL);
  glcolor3f(0.5, 0.5, 0.5);
  wlacz_teksture(7);

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glScalef(2, 2, 2);

  glMatrixMode(GL_MODELVIEW);

  gluQuadricTexture(dupa, GLU_TRUE);
  gluQuadricNormals(dupa, GLU_SMOOTH);
  gluQuadricOrientation(dupa, GLU_INSIDE);

  glTranslatef(matka.x, matka.y, matka.z);

  glRotatef(90, 1, 0, 0);
  glRotatef(licz / 50, 0.7, 0.7, 0.3);

  gluSphere(dupa, 5000, 20, 20);

  gluQuadricOrientation(dupa, GLU_OUTSIDE);
  wylacz_teksture;
  glPopMatrix;
  glPopAttrib;

  glPushMatrix;
  glDepthMask(GL_FALSE);
  glDisable(GL_FOG);
  glDepthFunc(GL_ALWAYS);
  rysuj_swiatelko_obr(-4200, 2700, -3000, 4100, 1, 0.6, 0.5, 0.23, sin(licz / 723.2) * 62);
  rysuj_swiatelko_obr(-4200, 2700, -3000, 2800, 1, 1, 0.95, 0.44, cos(licz / 591.2) * 41);
  rysuj_swiatelko_obr(-4200, 2700, -3000, 2200, 1, 1, 0.85, 0.97, sin(licz / 572) * 30);
  glDepthFunc(GL_LEQUAL);
  glEnable(GL_FOG);
  glDepthMask(GL_TRUE);
  glPopMatrix;

  glPushMatrix;

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

  SetGluOrtho2DForMenu(width, height);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glGetFloatv(GL_MODELVIEW_MATRIX, @viewMatrix);
  right[0] := viewMatrix[0];
  right[1] := viewMatrix[4];
  right[2] := viewMatrix[8];
  up[0] := viewMatrix[1];
  up[1] := viewMatrix[5];
  up[2] := viewMatrix[9];

  glEnable(GL_BLEND);
  glDepthMask(GL_FALSE);
  glDisable(GL_LIGHTING);
  glDisable(GL_COLOR_MATERIAL);
  glPolygonMode(GL_FRONT, GL_FILL);

  glDisable(GL_CULL_FACE);

  case winieta.corobi of
    0:
      begin // winieta
        if winieta.kursor = 0 then
          glColor4f(0.2, 1.0, 0.2, 0.7)
        else
          glColor4f(0.1, 0.6, 0.1, 0.6);
        pisz2d('nowa gra: misja poczπtkowa: ' + inttostr(winieta.planetapocz), currentScreenParams.MenuCenter,
          height - 250, 8 + ord(winieta.kursor = 0), 1);
        if winieta.kursor = 1 then
          glColor4f(0.2, 1.0, 0.2, 0.7)
        else
          glColor4f(0.1, 0.6, 0.1, 0.6);
        pisz2d('nowa gra: misje losowe: ' + inttostr(winieta.poziomtrudnosci), currentScreenParams.MenuCenter,
          height - 280, 8 + ord(winieta.kursor = 1), 1);
        if winieta.kursor = 2 then
          glColor4f(0.2, 1.0, 0.2, 0.7)
        else
          glColor4f(0.1, 0.6, 0.1, 0.6);
        pisz2d('misje dodatkowe', currentScreenParams.MenuCenter, height - 310, 8 + ord(winieta.kursor = 2), 1);
        if winieta.kursor = 3 then
          glColor4f(0.2, 1.0, 0.2, 0.7)
        else
          glColor4f(0.1, 0.6, 0.1, 0.6);
        pisz2d('wczytanie gry', currentScreenParams.MenuCenter, height - 340, 8 + ord(winieta.kursor = 3), 1);
        if winieta.kursor = 4 then
          glColor4f(0.2, 1.0, 0.2, 0.7)
        else
          glColor4f(0.1, 0.6, 0.1, 0.6);
        pisz2d('wyjúcie', currentScreenParams.MenuCenter, height - 370, 8 + ord(winieta.kursor = 4), 1);

        glColor4f(1.0, 0.2, 0.1, 0.6);
        pisz2d('WERSJA ' + PROGRAM_VERSION, currentScreenParams.MenuCenter, 57, 4, 1);
        pisz2d('2007 - 2023 gadz.pl', currentScreenParams.MenuCenter, 40, 5, 1);
        pisz2d('https://gadz.pl/', currentScreenParams.MenuCenter, 23, 5, 1);

        for a := 0 to high(skroltekst) do
        begin
          b1 := height - 270 + winieta.skrol div 3 - a * 15;

          if (b1 >= height - 220) and (b1 <= height - 180) then
            glColor4f(1.0, 1.0, 1.0, 0.4 - ((-b1 + height - 180) / 40) * 0.4)
          else if (b1 >= height - 80) and (b1 <= height - 40) then
            glColor4f(1.0, 1.0, 1.0, 0.0 + ((-b1 + height - 40) / 40) * 0.4)
          else
            glColor4f(1.0, 1.0, 1.0, 0.4);

          if (b1 >= height - 220) and (b1 <= height - 40) then
            pisz2d(skroltekst[a], currentScreenParams.MenuCenter, b1, 6, 1);

        end;

        glColor4f(0.5, 0.7, 1, 0.8);
        pisz2d('RETROFIRE', currentScreenParams.MenuCenter, height - 50 + abs(sin(licz * 0.03) * 5), 17, 1);

      end;
    1, 3:
      begin // zapis, odczyt

        glColor4f(0.5, 0.7, 1, 0.8);
        if winieta.corobi = 1 then
          pisz2d('ZAPIS GRY', currentScreenParams.MenuCenter, height - 50, 13, 1)
        else
          pisz2d('ODCZYT GRY', currentScreenParams.MenuCenter, height - 50, 13, 1);

        if winieta.kursor <= 9 then
          b1 := height - 80 - winieta.kursor * 35
        else
          b1 := height - 430;
        glBegin(GL_QUADS);
        glColor4f(0.2, 0.2, 0.3, 0.4);
        glVertex2f(20, b1);
        glVertex2f(currentScreenParams.MenuWidth - 20, b1);
        glColor4f(0, 0, 0.05, 0.2);
        glVertex2f(currentScreenParams.MenuWidth - 20, b1 - 40);
        glColor4f(0.2, 0.2, 0.3, 0.2);
        glVertex2f(20, b1 - 40);
        glEnd;

        for a := 0 to 9 do
        begin
          if zapisy[a].jest then
          begin

            case zapisy[a].rodzajgry of
              0:
                begin
                  if winieta.kursor = a then
                    glColor4f(0.2, 1.0, 0.2, 0.7)
                  else
                    glColor4f(0.1, 0.6, 0.1, 0.6);
                  pisz2d(inttostr(a) + ') NORMALNA GRA', 30, height - 90 - a * 35, 5);
                end;
              1:
                begin
                  if winieta.kursor = a then
                    glColor4f(0.2, 0.6, 1.0, 0.7)
                  else
                    glColor4f(0.1, 0.5, 0.6, 0.6);
                  pisz2d(inttostr(a) + ') MISJE LOSOWE', 30, height - 90 - a * 35, 5);
                end;
              2:
                begin
                  if winieta.kursor = a then
                    glColor4f(1.0, 0.3, 0.2, 0.7)
                  else
                    glColor4f(0.7, 0.2, 0.1, 0.6);
                  pisz2d(inttostr(a) + ') MISJE DODATKOWE', 30, height - 90 - a * 35, 4);
                  pisz2d(zapisy[a].epizod, 50, height - 99 - a * 35, 5);
                end;
            end;

            pisz2d(DateTimeToStr(zapisy[a].data), 60, height - 110 - a * 35, 5);

            pisz2d('MISJA:' + inttostr(zapisy[a].planeta), 340, height - 90 - a * 35, 5);
            pisz2d('PKT:' + inttostr(zapisy[a].pkt), 340, height - 110 - a * 35, 5);

            pisz2d('L•DOWNIKI:' + inttostr(zapisy[a].zycia), 510, height - 90 - a * 35, 5);
            pisz2d('KASA:' + inttostr(zapisy[a].kasa), 510, height - 110 - a * 35, 5);

          end
          else
          begin
            if winieta.kursor = a then
              glColor4f(0.6, 0.6, 0.6, 0.7)
            else
              glColor4f(0.4, 0.4, 0.4, 0.6);
            pisz2d('--PUSTY--', currentScreenParams.MenuCenter, height - 100 - a * 35, 8, 1);
          end;
        end;

        if winieta.kursor = 10 then
          glColor4f(0.2, 1.0, 0.2, 0.7)
        else
          glColor4f(0.1, 0.6, 0.1, 0.6);
        pisz2d('WYJåCIE', currentScreenParams.MenuCenter, height - 450, 8, 1);

      end;
    2:
      begin // sklep

        glColor4f(0.5, 0.7, 1, 0.8);
        pisz2d('SKLEP', currentScreenParams.MenuCenter, height - 50, 13, 1);

        glColor4f(0.2, 0.5, 1, 0.95);
        pisz2d('KASA: ' + inttostr(gra.kasa), 50, height - 90, 8);

        if winieta.kursor <= 6 then
          b1 := height - 120 - winieta.kursor * 40
        else
          b1 := height - 412;
        glBegin(GL_QUADS);
        glColor4f(0.2, 0.2, 0.3, 0.4);
        glVertex2f(20, b1);
        glVertex2f(currentScreenParams.MenuWidth - 20, b1);
        glColor4f(0, 0, 0.05, 0.2);
        glVertex2f(currentScreenParams.MenuWidth - 20, b1 - 35);
        glColor4f(0.2, 0.2, 0.3, 0.2);
        glVertex2f(20, b1 - 35);
        glEnd;

        for a := 0 to 5 do
        begin
          if winieta.kursor = a then
            glColor4f(0.2, 1.0, 0.2, 0.7)
          else
            glColor4f(0.1, 0.6, 0.1, 0.6);
          case a of
            0:
              begin
                r := 1;
                s := 'ZBIORNIK PALIWA';
              end;
            1:
              begin
                r := 1;
                s := 'RAKIETY';
              end;
            2:
              begin
                r := 1;
                s := 'DZIA£O MASZYNOWE';
              end;
            3:
              begin
                r := 100;
                s := 'OS£ONA';
              end;
            4:
              begin
                r := 100;
                s := 'UK£AD CH£ODZ•CY';
              end;
            5:
              begin
                r := 1;
                s := '£ADOWNOå∆';
              end;
          else
            begin
              r := 1;
              s := '';
            end;
          end;
          // pisz2d(s, currentScreenParams.MenuCenter, height-130-a*40, 8,1);
          pisz2d(s, 40, height - 130 - a * 40, 8, 0);
          pisz2d('MASZ: ' + inttostr(round(upgrade[a, gra.poziomupgrade[a]].ile * r)), 40, height - 145 - a * 40, 6);
          if gra.poziomupgrade[a] < 9 then
          begin
            if upgrade[a, gra.poziomupgrade[a] + 1].cena <= gra.kasa then
            begin
              if winieta.kursor = a then
                glColor4f(0.2, 1.0, 0.2, 0.7)
              else
                glColor4f(0.1, 0.6, 0.1, 0.6);
            end
            else
            begin
              if winieta.kursor = a then
                glColor4f(1.0, 0.2, 0.2, 0.7)
              else
                glColor4f(0.6, 0.1, 0.1, 0.6);
            end;
            pisz2d('KUP: ' + inttostr(round(upgrade[a, gra.poziomupgrade[a] + 1].ile * r)) + ', CENA: ' +
              inttostr(upgrade[a, gra.poziomupgrade[a] + 1].cena), width - 40, height - 145 - a * 40, 6, 2);
          end;

          if winieta.kursor = a then
            r := 0.7
          else
            r := 0.4;
          for b := 0 to 9 do
          begin
            b1 := height - 130 - a * 40;
            b2 := width - (20 * 11) + b * 20;
            glBegin(GL_QUADS);
            if b <= gra.poziomupgrade[a] then
              glColor4f(0.3, 1, 0.2, r)
            else
              glColor4f(0.5, 0.1, 0.05, r);
            glVertex2f(b2 - 8, b1 + 5);
            glVertex2f(b2 + 9, b1 + 5);
            if b <= gra.poziomupgrade[a] then
              glColor4f(0.2, 0.6, 0.05, r)
            else
              glColor4f(0.3, 0.05, 0.0, r);
            glVertex2f(b2 + 9, b1 - 5);
            glVertex2f(b2 - 8, b1 - 5);
            glEnd;
          end;
        end;

        if winieta.kursor = 6 then
          glColor4f(0.2, 1.0, 0.2, 0.7)
        else
          glColor4f(0.1, 0.6, 0.1, 0.6);
        pisz2d('DODATKOWY L•DOWNIK', 40, height - 370, 8, 0);
        pisz2d('MASZ: ' + inttostr(gra.zycia), 40, height - 385, 6);
        if gra.zycia < 9 then
        begin
          if cenazycia <= gra.kasa then
          begin
            if winieta.kursor = 6 then
              glColor4f(0.2, 1.0, 0.2, 0.7)
            else
              glColor4f(0.1, 0.6, 0.1, 0.6);
          end
          else
          begin
            if winieta.kursor = 6 then
              glColor4f(1.0, 0.2, 0.2, 0.7)
            else
              glColor4f(0.6, 0.1, 0.1, 0.6);
          end;
          pisz2d('KUP, CENA: ' + inttostr(cenazycia), width - 40, height - 385, 6, 2);
        end;

        a := 6;
        if winieta.kursor = a then
          r := 0.7
        else
          r := 0.4;
        for b := 1 to 9 do
        begin
          b1 := height - 130 - a * 40;
          b2 := width - (20 * 11) + b * 20;
          glBegin(GL_QUADS);
          if b <= gra.zycia then
            glColor4f(0.3, 1, 0.2, r)
          else
            glColor4f(0.5, 0.1, 0.05, r);
          glVertex2f(b2 - 8, b1 + 5);
          glVertex2f(b2 + 9, b1 + 5);
          if b <= gra.zycia then
            glColor4f(0.2, 0.6, 0.05, r)
          else
            glColor4f(0.3, 0.05, 0.0, r);
          glVertex2f(b2 + 9, b1 - 5);
          glVertex2f(b2 - 8, b1 - 5);
          glEnd;
        end;

        if winieta.kursor = 7 then
          glColor4f(0.2, 1.0, 0.2, 0.7)
        else
          glColor4f(0.1, 0.6, 0.1, 0.6);
        pisz2d('WYJåCIE', currentScreenParams.MenuCenter, height - 430, 8, 1);

      end;
    4:
      begin // wybor misji dodatkowej

        if length(epizody) >= 1 then
        begin
          b1 := 0;
          if (high(epizody) > 19) then
          begin
            b1 := winieta.epizod - 10;
            if b1 < 0 then
              b1 := 0;
            if b1 + 19 > high(epizody) then
              b1 := high(epizody) - 19;

          end;

          for a := 0 to 19 do
          begin
            if a + b1 <= high(epizody) then
            begin
              if winieta.epizod = a + b1 then
                glColor4f(0.2, 1.0, 0.2, 0.7)
              else
                glColor4f(0.1, 0.6, 0.1, 0.6);
              pisz2d(inttostr(1 + a + b1) + ': ' + epizody[a + b1].tytul + ', MISJI:' +
                inttostr(length(epizody[a + b1].misje)), 50, height - 70 - a * 15, 7);
            end;
          end;
        end
        else
        begin
          glColor4f(0.8, 0.2, 0.1, 0.6);
          pisz2d('BRAK MISJI DODATKOWYCH!', currentScreenParams.MenuCenter, width div 2, 10, 1);

        end;

        if gra.koniecgry then
        begin
          glColor4f(0.1, 0.6, 0.1, 0.6);
          pisz2d('esc - powrÛt do winiety', currentScreenParams.MenuCenter, 30, 8, 1);
        end;

      end;
  end;

  glDepthMask(GL_TRUE);

  glPopMatrix;

end;

// ---------------------------------------------------------------------------
procedure pokaz_glowneintro;

const
  teksty: array [0 .. 3] of TMainIntroLine = ((s: 'GADZ.PL'; i: 3), (s: 'PREZENTUJE'; i: 2), (s: 'GR  GRZEGORZA DROZDA';
    i: 2), (s: 'RETROFIRE'; i: 4));
  ilenapisow = 4;

var
  width, height, a, b1, b2, b: integer;
  viewMatrix: array [0 .. 15] of GLFloat;
  s: string;
  koltla: array [0 .. 3] of GLFloat;
  r: real;

  light_ka2, light_kd2, light_ks2: array [0 .. 3] of GLFloat;

begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

  gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, 9000.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  gluLookAt(0, 0, 0, 0, 0, -50, 0, 1, 0);

  glGetFloatv(GL_MODELVIEW_MATRIX, @viewMatrix);
  right[0] := viewMatrix[0];
  right[1] := viewMatrix[4];
  right[2] := viewMatrix[8];
  up[0] := viewMatrix[1];
  up[1] := viewMatrix[5];
  up[2] := viewMatrix[9];

  glEnable(GL_LIGHTING);
  glEnable(GL_FOG);
  glFogf(GL_FOG_DENSITY, 0.001);
  koltla[0] := 0;
  koltla[1] := 0;
  koltla[2] := 0;
  koltla[3] := 0;
  glFogfv(GL_FOG_COLOR, @koltla);
  glClearColor(koltla[0], koltla[1], koltla[2], koltla[3]);

  if glowneintro.czas <= 150 then
    r := glowneintro.czas / 150
  else if glowneintro.czas >= (200 + ilenapisow * 300) - 200 then
    r := ((400 + ilenapisow * 300) - glowneintro.czas) / 200
  else
    r := 1;

  light_ka2[0] := 1.00 * r;
  light_ka2[1] := 0.85 * r;
  light_ka2[2] := 0.8 * r;
  light_kd2[0] := 0.90 * r;
  light_kd2[1] := 0.90 * r;
  light_kd2[2] := 0.85 * r;
  light_ks2[0] := 1.0 * r;
  light_ks2[1] := 1.0 * r;
  light_ks2[2] := 0.91 * r;

  glLightfv(GL_LIGHT0, GL_AMBIENT, @light_ka2);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @light_kd2);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @light_ks2);

  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glPushMatrix;
  glDisable(GL_FOG);
  glMaterialf(GL_FRONT, GL_SHININESS, 0);
  glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_1s);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_1s);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_1s);

  // glDisable(GL_LIGHTING);
  glDisable(GL_COLOR_MATERIAL);
  glEnable(GL_BLEND);

  glColor4f(1, 1, 1, 1);
  wlacz_teksture(7);

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glScalef(3, 3, 3);

  glMatrixMode(GL_MODELVIEW);

  gluQuadricTexture(dupa, GLU_TRUE);
  gluQuadricNormals(dupa, GLU_SMOOTH);
  gluQuadricOrientation(dupa, GLU_INSIDE);

  // glTranslatef(matka.x,matka.y,matka.z);

  glRotatef(90, 0, 0, 1);
  glRotatef(glowneintro.czas / 57 + 90, 0, 1, 0);
  glRotatef(glowneintro.czas / 177, 0, 0, 1);

  gluSphere(dupa, 5000, 40, 40);

  gluQuadricOrientation(dupa, GLU_OUTSIDE);

  glDisable(GL_BLEND);

  wylacz_teksture;
  glPopMatrix;
  glPopAttrib;

  glPushMatrix;

  RandSeed := 561;
  for a := 0 to 39 do
  begin
    glPushMatrix;
    glTranslatef(random * 200 - 100, random * 250 - 50 - glowneintro.czas / 13,
      -30 - random * 100 + glowneintro.czas / 20);
    glRotatef(random(360) + glowneintro.czas * (a / 45), 1, 0, 0);
    glRotatef(random(360) + glowneintro.czas * ((40 - a) / 45), 0, 1, 0);
    glScalef(1.5, 1.5, 1.5);
    pokaz_element_obiekt(obiekt[ob_kamien], random(length(obiekt[ob_kamien].o.Groups)), true);
    glPopMatrix;

  end;

  glPopMatrix;

  glPushMatrix;

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  SetGluOrtho2DForMenu(width, height);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glGetFloatv(GL_MODELVIEW_MATRIX, @viewMatrix);
  right[0] := viewMatrix[0];
  right[1] := viewMatrix[4];
  right[2] := viewMatrix[8];
  up[0] := viewMatrix[1];
  up[1] := viewMatrix[5];
  up[2] := viewMatrix[9];

  glEnable(GL_BLEND);
  glDepthMask(GL_FALSE);
  glDisable(GL_LIGHTING);
  glDisable(GL_COLOR_MATERIAL);
  glPolygonMode(GL_FRONT, GL_FILL);

  glDisable(GL_CULL_FACE);

  if (glowneintro.scena >= 1) and (glowneintro.scena <= ilenapisow) then
  begin
    if glowneintro.czas2 <= 40 then
      r := glowneintro.czas2 / 40
    else if glowneintro.czas2 >= 300 - 40 then
      r := (300 - glowneintro.czas2) / 40
    else
      r := 1;

    if (glowneintro.czas2 >= 70) and (glowneintro.czas2 <= 90) then
    begin
      glColor4f(0.8, 0.8, 0.8, ((90 - glowneintro.czas2) / 20) * 0.1);
      pisz2d(teksty[glowneintro.scena - 1].s, currentScreenParams.MenuCenter, 240,
        10 + (5 * (glowneintro.czas2 - 70)), 1);
    end;

    for a := 0 to teksty[glowneintro.scena - 1].i do
    begin
      glColor4f(0.5, 1, 0.5, (r * 0.15) / ((1 + teksty[glowneintro.scena - 1].i - a) / 2));
      pisz2d(teksty[glowneintro.scena - 1].s,
        // 320-30+glowneintro.czas2/5,
        currentScreenParams.MenuCenter - sin(a * 56) * 130 + (glowneintro.czas2 / 5) * cos(a * 61),
        240 - cos(a * 61) * 20, 30, 1);
    end;

    glColor4f(0.5, 1, 0.5, r * 0.8);
    pisz2d(teksty[glowneintro.scena - 1].s, currentScreenParams.MenuCenter, 240, 10, 1);

  end;

  glDepthMask(GL_TRUE);
  glDisable(GL_BLEND);

  DrawPanoramicStripes(width, height);

  glPopMatrix;

end;

// ---------------------------------------------------------------------------
procedure rysuj_niebo;

var
  nx, nz, w: real;

var
  kol: array [0 .. 3] of GLFloat;
begin
  w := round(matka.y - 200);
  nx := abs(ziemia.px) * 3;
  nz := abs(ziemia.pz) * 3;
  // glFogf(GL_FOG_DENSITY, 0.0065-ziemia.widac*0.005);

  glDisable(GL_LIGHTING);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, 5000.0);

  glMatrixMode(GL_MODELVIEW);
  glNormal3f(0, -1, 0);
  glPushMatrix;
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glMatrixMode(GL_MODELVIEW);

  w := w + 400;
  kol[0] := 1; // ziemia.jestkoltla[0];
  kol[1] := 1; // ziemia.jestkoltla[1];
  kol[2] := 1; // ziemia.jestkoltla[2];
  kol[3] := ((w - 300) - gracz.y) / 300;
  if kol[3] > 1 then
    kol[3] := 1;
  if kol[3] < 0 then
    kol[3] := 0;

  glEnable(GL_BLEND);
  glColor4fv(@kol);
  wlacz_teksture(7);
  glBegin(GL_QUADS);
  glTexCoord2f(7, 0);
  glVertex3f(nx * 2, w, nz * 2);
  glTexCoord2f(0, 0);
  glVertex3f(-nx * 2, w, nz * 2);
  glTexCoord2f(0, 7);
  glVertex3f(-nx * 2, w, -nz * 2);
  glTexCoord2f(7, 7);
  glVertex3f(nx * 2, w, -nz * 2);
  glEnd;
  glDisable(GL_BLEND);

  wylacz_teksture;

  w := w - 400;
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glTranslatef(ziemia.chmuryx, ziemia.chmuryz, 0);
  glMatrixMode(GL_MODELVIEW);

  kol[0] := 0.7;
  kol[1] := 0.7;
  kol[2] := 0.7;
  kol[3] := (w - gracz.y) / 300;
  if kol[3] > 0.7 then
    kol[3] := 0.7;
  if kol[3] < 0 then
    kol[3] := 0;

  glFogf(GL_FOG_START, 100.0);
  glFogf(GL_FOG_END, 4800.0);
  glFogi(GL_FOG_MODE, GL_LINEAR);
  glFogfv(GL_FOG_COLOR, @ziemia.jestkoltla);

  glDepthMask(GL_FALSE);
  glEnable(GL_BLEND);
  glColor4fv(@kol);

  wlacz_teksture(10);
  glBegin(GL_QUADS);
  glTexCoord2f(6, 0);
  glVertex3f(nx, w, nz);
  glTexCoord2f(0, 0);
  glVertex3f(-nx, w, nz);
  glTexCoord2f(0, 6);
  glVertex3f(-nx, w, -nz);
  glTexCoord2f(6, 6);
  glVertex3f(nx, w, -nz);
  glEnd;

  w := w - 40;
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glTranslatef(ziemia.chmuryx * 1.5, ziemia.chmuryz * 1.5, 0);
  glMatrixMode(GL_MODELVIEW);

  kol[0] := 0.8;
  kol[1] := 0.8;
  kol[2] := 0.8;
  kol[3] := (w - gracz.y) / 250;
  if kol[3] > 0.6 then
    kol[3] := 0.6;
  if kol[3] < 0 then
    kol[3] := 0;

  { glFogf (GL_FOG_START, 100.0);
    glFogf (GL_FOG_END, 4800.0);
    glFogi (GL_FOG_MODE, GL_LINEAR);
    glFogfv(GL_FOG_COLOR, @ziemia.jestkoltla);

    glDepthMask(GL_FALSE);
    glEnable(GL_BLEND); }
  glColor4fv(@kol);

  // wlacz_teksture(10);
  glBegin(GL_QUADS);
  glTexCoord2f(3, 0);
  glVertex3f(nx, w, nz);
  glTexCoord2f(0, 0);
  glVertex3f(-nx, w, nz);
  glTexCoord2f(0, 3);
  glVertex3f(-nx, w, -nz);
  glTexCoord2f(3, 3);
  glVertex3f(nx, w, -nz);
  glEnd;

  wylacz_teksture;
  glDisable(GL_BLEND);

  glDepthMask(GL_TRUE);

  glPopMatrix;

  glFogfv(GL_FOG_COLOR, @ziemia.jestkoltla);

  glFogi(GL_FOG_MODE, GL_EXP);
  glEnable(GL_LIGHTING);

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(katwidzenia, currentScreenParams.Aspect, 0.2, odlwidzenia);
  glMatrixMode(GL_MODELVIEW);
end;

// ---------------------------------------------------------------------------
procedure Ustaw_swiatla_w_grze;

var
  kierl, posl, swi: TWektor;
  a: integer;
begin
  {
    LIGHT0 - swiatlo globalne na calosc z jednej strony, nigdy go nie wylaczam
    LIGHT1 - swiatlo z reflektora gracza
    LIGHT2 - swiatlo od dolnych dysz gracza

    nad ziemia:

    LIGHT3 - \
    LIGHT4 - |
    LIGHT5 -  > swiatla uzywane do oswietlania wybuchow
    LIGHT6 - |
    LIGHT7 - /

  }

  glEnable(GL_LIGHT0);
  pos1[3] := 0;

  glLightfv(GL_LIGHT0, GL_POSITION, @pos1);
  glLightfv(GL_LIGHT0, GL_AMBIENT, @light_ka0);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @light_kd0);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @light_ks0);

  kierl[0] := -pos1[0];
  kierl[1] := -pos1[1];
  kierl[2] := -pos1[2];
  normalize(kierl);
  glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, @kierl); // wektor kierunku swiecenia
  glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 90); // obciecie stozka
  glLightf(GL_LIGHT0, GL_SPOT_EXPONENT, 50); // wygaszanie na brzegach swiatla

  if ((gra.etap = 0) and (intro.scena = 1) and (gracz.y >= matka.y + 4.4)) or ((gra.etap = 1) and (gracz.zyje)) then
  begin

    // reflektor
    if not gracz.uszkodzenia[0] and gracz.zyje then
      glEnable(GL_LIGHT1)
    else
      glDisable(GL_LIGHT1);

    posl[0] := 0;
    posl[1] := 0;
    posl[2] := 0;
    posl[3] := 1;

    glPushMatrix;
    glTranslatef(gracz.x, gracz.y, gracz.z);
    glTranslatef(-0.38, -0.54 + gracz.nacisk, 0.58);
    glRotatef(gracz.elementy[17].obrx, 1, 0, 0);
    glRotatef(gracz.elementy[17].obry, 0, 1, 0);
    glRotatef(gracz.elementy[17].obrz, 0, 0, 1);
    glLightfv(GL_LIGHT1, GL_POSITION, @posl);
    glLightfv(GL_LIGHT1, GL_AMBIENT, @light_ka1);
    glLightfv(GL_LIGHT1, GL_DIFFUSE, @light_kd1);
    glLightfv(GL_LIGHT1, GL_SPECULAR, @light_ks1);
    glLightf(GL_LIGHT1, GL_CONSTANT_ATTENUATION, 0.500);
    glLightf(GL_LIGHT1, GL_LINEAR_ATTENUATION, 0.0000);
    glLightf(GL_LIGHT1, GL_QUADRATIC_ATTENUATION, 0.000002);

    kierl[0] := sin(gracz.kier * pi180);
    kierl[1] := -0.5;
    kierl[2] := -cos(gracz.kier * pi180);
    normalize(kierl);
    glLightfv(GL_LIGHT1, GL_SPOT_DIRECTION, @kierl);
    // wektor kierunku swiecenia
    glLightf(GL_LIGHT1, GL_SPOT_CUTOFF, 60); // obciecie stozka
    glLightf(GL_LIGHT1, GL_SPOT_EXPONENT, 10); // wygaszanie na brzegach swiatla
    glPopMatrix;

    // swiatlo ognia w dol
    if gracz.swiatlodol > 0 then
    begin
      glEnable(GL_LIGHT2);
      posl[0] := gracz.x;
      posl[1] := gracz.y;
      posl[2] := gracz.z;
      posl[3] := 1;

      glLightfv(GL_LIGHT2, GL_POSITION, @posl);
      swi[0] := 1 * gracz.swiatlodol;
      swi[1] := 0.3 * gracz.swiatlodol;
      swi[2] := 0.07 * gracz.swiatlodol;
      glLightfv(GL_LIGHT2, GL_AMBIENT, @swi);
      glLightfv(GL_LIGHT2, GL_DIFFUSE, @swi);
      glLightfv(GL_LIGHT2, GL_SPECULAR, @swi);
      glLightf(GL_LIGHT2, GL_CONSTANT_ATTENUATION, 0.00);
      glLightf(GL_LIGHT2, GL_LINEAR_ATTENUATION, 0.00);
      glLightf(GL_LIGHT2, GL_QUADRATIC_ATTENUATION, 0.0003);

      kierl[0] := 0;
      kierl[1] := -1;
      kierl[2] := 0;
      glLightfv(GL_LIGHT2, GL_SPOT_DIRECTION, @kierl);
      // wektor kierunku swiecenia
      glLightf(GL_LIGHT2, GL_SPOT_CUTOFF, 90); // obciecie stozka
      glLightf(GL_LIGHT2, GL_SPOT_EXPONENT, 2);
      // wygaszanie na brzegach swiatla
    end
    else
      glDisable(GL_LIGHT2);
  end
  else
  begin
    glDisable(GL_LIGHT1);
    glDisable(GL_LIGHT2);
  end;

  // swiatla wybuchow
  if (gra.etap = 1) then
  begin
    for a := 0 to 4 do
      glDisable(GL_LIGHT3 + a);

    for a := 0 to high(swiatlo) do
    begin
      if swiatlo[a].jest then
        with swiatlo[a] do
        begin

          glEnable(GL_LIGHT3 + a);
          posl[0] := x;
          posl[1] := y;
          posl[2] := z;
          posl[3] := 1;

          glLightfv(GL_LIGHT3 + a, GL_POSITION, @posl);
          if jasnosc > 1 then
          begin
            swi[0] := 1;
            swi[1] := 0.5 * jasnosc;
            swi[2] := 0.5 * jasnosc - 0.5;
          end
          else
          begin
            swi[0] := jasnosc;
            swi[1] := 0.5 * jasnosc;
            swi[2] := 0;
          end;
          glLightfv(GL_LIGHT3 + a, GL_AMBIENT, @swi);
          glLightfv(GL_LIGHT3 + a, GL_DIFFUSE, @swi);
          glLightfv(GL_LIGHT3 + a, GL_SPECULAR, @swi);
          glLightf(GL_LIGHT3 + a, GL_CONSTANT_ATTENUATION, 0.00);
          glLightf(GL_LIGHT3 + a, GL_LINEAR_ATTENUATION, 0.00);
          glLightf(GL_LIGHT3 + a, GL_QUADRATIC_ATTENUATION, 0.00003);

          kierl[0] := 0;
          kierl[1] := -1;
          kierl[2] := 0;
          glLightfv(GL_LIGHT3 + a, GL_SPOT_DIRECTION, @kierl);
          // wektor kierunku swiecenia
          glLightf(GL_LIGHT3 + a, GL_SPOT_CUTOFF, 90); // obciecie stozka
          glLightf(GL_LIGHT3 + a, GL_SPOT_EXPONENT, 60 - jasnosc * 28);
          // wygaszanie na brzegach swiatla

        end;
    end;
  end
  else
    for a := 0 to 4 do
      glDisable(GL_LIGHT3 + a);

end;

// ---------------------------------------------------------------------------
procedure RenderFrame;

var
  v, f, g, o, a, x, z: integer;
  kierl, posl, swi: TWektor;
  j: real;
  lmodel_ambient: array [0 .. 3] of GLFloat;
begin
  if not glowneintro.jest then
  begin
    if not winieta.jest then
    begin
      lmodel_ambient[0] := ustawienia.jasnosc;
      lmodel_ambient[1] := ustawienia.jasnosc;
      lmodel_ambient[2] := ustawienia.jasnosc;
      lmodel_ambient[3] := 1.0;
      glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient);

      ustaw_kamere;

      // rysuj_puste_tlo;

      // definicja swiatel
      glEnable(GL_LIGHTING);

      Ustaw_swiatla_w_grze;

      if gra.etap in [0, 2] then
      begin
        rysuj_gwiazdy(false);
      end;

      if (gra.etap = 1) and (matka.widac > 0) then
        rysuj_gwiazdy(true);
      // rysuj_slonce;
      if (gra.etap = 1) and (ziemia.widac > 0) then
        rysuj_niebo;

      glEnable(GL_CULL_FACE);
      glCullFace(GL_BACK);

      if gra.etap = 1 then
      begin
        rysuj_podloze;
        rysuj_krzaki;
      end;

      if (gra.etap = 2) and (intro.scena = 2) then
      begin
        if (intro.czas2 < 350) or (gra.rodzajmisji <> 0) then
          rysuj_planete(true, 1)
        else if (gra.rodzajmisji = 0) and ((intro.czas2 > 350) and (intro.czas2 < 650)) then
          rysuj_planete(true, (650 - intro.czas2) / 300);
      end
      else if (gra.etap = 0) and (intro.scena = 0) then
        rysuj_planete(false, 0.3);

      rysuj_matke;

      { if ((kamera<>7) or (gra.pauza)) and
        (((gra.etap=0) and (intro.scena=1)) or
        ((gra.etap=1) and (gracz.zyje))) then rysuj_gracza }
      if ((gra.etap = 0) and (intro.scena = 1)) or ((gra.etap = 1) and ((kamera <> 7) or gra.pauza) and gracz.zyje) then
        rysuj_gracza
      else if (gra.etap = 1) and (kamera = 7) and (gracz.zyje) then
        rysuj_kokpit;

      if gra.etap = 1 then
      begin
        rysuj_dzialka;
        rysuj_pilotow;
        rysuj_smieci;
        rysuj_rakiety;
        rysuj_mysliwce;
      end;

      if gra.etap = 1 then
      begin
        // rysuj_krzaki;
      end;

      rysuj_dymy;
      rysuj_iskry;

      case gra.etap of
        0:
          begin
            rysuj_napisy_intro;
          end;
        1:
          rysuj_liczniki;
        2:
          rysuj_napisy_outro;
      end;
    end
    else
    begin // winieta

      lmodel_ambient[0] := 0.0;
      lmodel_ambient[1] := 0.0;
      lmodel_ambient[2] := 0.0;
      lmodel_ambient[3] := 1.0;
      glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient);

      // definicja swiatel
      glEnable(GL_LIGHTING);

      glEnable(GL_LIGHT0);
      // glTranslatef(1300,-900,500);
      pos1win[0] := -300;
      pos1win[1] := -500;
      pos1win[2] := -5500;
      // pos1win[0]:=sin(licz/20)*5000;
      // pos1win[1]:=200;
      // pos1win[2]:=cos(licz/20)*5000;
      // pos1win[3]:=0;
      glDisable(GL_LIGHT1);
      glDisable(GL_LIGHT2);

      glLightfv(GL_LIGHT0, GL_POSITION, @pos1win);
      glLightfv(GL_LIGHT0, GL_AMBIENT, @light_ka0);
      glLightfv(GL_LIGHT0, GL_DIFFUSE, @light_kd0);
      glLightfv(GL_LIGHT0, GL_SPECULAR, @light_ks0);

      kierl[0] := -pos1win[0];
      kierl[1] := -pos1win[1];
      kierl[2] := -pos1win[2];
      normalize(kierl);
      glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, @kierl);
      // wektor kierunku swiecenia
      glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 30); // obciecie stozka
      glLightf(GL_LIGHT0, GL_SPOT_EXPONENT, 30);
      // wygaszanie na brzegach swiatla
      pokaz_winiete;
    end;
  end
  else
  begin // glowne intro

    lmodel_ambient[0] := 0.0;
    lmodel_ambient[1] := 0.0;
    lmodel_ambient[2] := 0.0;
    lmodel_ambient[3] := 0.0;
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient);

    glEnable(GL_LIGHTING);

    glEnable(GL_LIGHT0);
    pos1win[0] := -300;
    pos1win[1] := -500;
    pos1win[2] := -5500;
    glDisable(GL_LIGHT1);
    glDisable(GL_LIGHT2);

    glLightfv(GL_LIGHT0, GL_POSITION, @pos1win);

    pokaz_glowneintro;

  end;

end;

// ---------------------------------------------------------------------------
procedure stworz_dzialka;
begin
  l_dzialko := glGenLists(1);
  glNewList(l_dzialko, GL_COMPILE);
  glPushMatrix;
  glRotatef(180, 0, 1, 0);
  // glScalef(0.8,0.8,0.8);
  // glScalef(2,2,2);
  pokaz_obiekt(obiekt[ob_dzialko]);
  glPopMatrix;
  glEndList();

  l_dzialkowieza := glGenLists(1);
  glNewList(l_dzialkowieza, GL_COMPILE);
  glPushMatrix;
  glRotatef(180, 0, 1, 0);
  // glScalef(0.8,0.8,0.8);
  // glScalef(2,2,2);
  pokaz_obiekt(obiekt[ob_dzialkowieza]);
  glPopMatrix;
  glEndList();

  l_dzialkowieza2 := glGenLists(1);
  glNewList(l_dzialkowieza2, GL_COMPILE);
  glPushMatrix;
  glRotatef(180, 0, 1, 0);
  // glScalef(0.8,0.8,0.8);
  // glScalef(2,2,2);
  pokaz_obiekt(obiekt[ob_dzialkowieza2]);
  glPopMatrix;
  glEndList();

  l_dzialkolufa := glGenLists(1);
  glNewList(l_dzialkolufa, GL_COMPILE);
  glPushMatrix;
  glRotatef(180, 0, 1, 0);
  // glScalef(0.8,0.8,0.8);
  // glScalef(2,2,2);
  pokaz_obiekt(obiekt[ob_dzialkolufa]);
  glPopMatrix;
  glEndList();

  l_dzialkolufa2 := glGenLists(1);
  glNewList(l_dzialkolufa2, GL_COMPILE);
  glPushMatrix;
  glRotatef(180, 0, 1, 0);
  // glScalef(0.8,0.8,0.8);
  // glScalef(2,2,2);
  pokaz_obiekt(obiekt[ob_dzialkolufa2]);
  glPopMatrix;
  glEndList();

end;

// ---------------------------------------------------------------------------
procedure stworz_rakiety;
begin
  l_rakieta := glGenLists(1);
  glNewList(l_rakieta, GL_COMPILE);
  glPushMatrix;
  glRotatef(90, 0, 1, 0);
  // glScalef(0.3,0.3,0.3);
  pokaz_obiekt(obiekt[ob_rakieta]);
  glPopMatrix;
  glEndList();
end;

// ---------------------------------------------------------------------------
procedure stworz_mysliwce;
begin
  l_mysliwiec := glGenLists(1);
  glNewList(l_mysliwiec, GL_COMPILE);
  glPushMatrix;
  glRotatef(90, 0, 1, 0);
  // glScalef(1.3,1.3,1.3);
  pokaz_obiekt(obiekt[ob_mysliwiec]);
  glPopMatrix;
  glEndList();
end;

// ---------------------------------------------------------------------------
procedure stworz_scenerie;

var
  a: integer;
begin
  for a := 0 to ile_obiektow_scenerii - 1 do
  begin
    l_sceneria[a] := glGenLists(1);
    glNewList(l_sceneria[a], GL_COMPILE);
    glPushMatrix;
    pokaz_obiekt(obiekt[ob_sceneria1 + a], -1, true);
    {
      glPushAttrib(GL_ALL_ATTRIB_BITS);
      glPushMatrix;
      wlacz_teksture(4);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glEnable(GL_BLEND);
      glColor4f(1,1,1,0.5);
      glBegin(GL_QUADS);
      glTexCoord2f(0,1);
      glVertex3f(-4 -7, 0.2, +4 +7);
      glTexCoord2f(1,1);
      glVertex3f(+4 +7, 0.2, +4 +7);
      glTexCoord2f(1,0);
      glVertex3f(+4 +7, 0.2, -4 -7);
      glTexCoord2f(0,0);
      glVertex3f(-4 -7, 0.2, -4 -7);
      glEnd;
      glDisable(GL_BLEND);
      wylacz_teksture;
      glPopMatrix;
      glPopAttrib;
    }
    glPopMatrix;
    glEndList();
  end;
end;

// ---------------------------------------------------------------------------
procedure stworz_cien;
begin
  l_cien := glGenLists(1);
  glNewList(l_cien, GL_COMPILE);
  // glPushAttrib(GL_ALL_ATTRIB_BITS);
  glPushMatrix;
  // wlacz_teksture(4);
  // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  // glEnable(GL_BLEND);
  // glColor4f(1,1,1,0.4);
  glBegin(GL_QUADS);
  glTexCoord2f(0, 1);
  glVertex3f(-4 - 7, 0.2, +4 + 7);
  glTexCoord2f(1, 1);
  glVertex3f(+4 + 7, 0.2, +4 + 7);
  glTexCoord2f(1, 0);
  glVertex3f(+4 + 7, 0.2, -4 - 7);
  glTexCoord2f(0, 0);
  glVertex3f(-4 - 7, 0.2, -4 - 7);
  glEnd;
  // glDisable(GL_BLEND);
  // wylacz_teksture;
  glPopMatrix;
  // glPopAttrib;

  glEndList();
end;

// ---------------------------------------------------------------------------
procedure stworz_krzaki;

var
  a: integer;
begin
  for a := 0 to 3 do
  begin
    l_krzaki[a] := glGenLists(1);
    glNewList(l_krzaki[a], GL_COMPILE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glBegin(GL_QUADS);
    glTexCoord2f(0.25 * a, 0);
    glNormal3f(0, 0, 1);
    glVertex3f(-1, 0, 0);

    glTexCoord2f(0.25 * (a + 1), 0);
    glVertex3f(1, 0, 0);

    glTexCoord2f(0.25 * (a + 1), 1);
    glVertex3f(1, 1, 0);

    glTexCoord2f(0.25 * a, 1);
    glVertex3f(-1, 1, 0);
    glEnd;
    glEndList();
  end;
end;

// ----------------------------------------------------------------------------
procedure tworz_obiekty;
begin
  stworz_dzialka;
  stworz_rakiety;
  stworz_mysliwce;
  stworz_scenerie;
  stworz_cien;
  stworz_krzaki;
end;

end.
