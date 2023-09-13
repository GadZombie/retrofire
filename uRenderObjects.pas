unit uRenderObjects;

interface
uses
  System.SysUtils,
  GL,
  GlobalTypes;

procedure pokaz_obiekt(var ob: Tobiekt; innatekstura: integer = -1; koloruj: boolean = false);
procedure pokaz_element_obiekt(var ob: Tobiekt; element: integer; srodek: boolean; innatekstura: integer = -1;
  beztekstur: boolean = false; zniszczony: real = 0; rrand: integer = 0);
procedure pisz_liczbe(n: int64; sx, sy, sz, sr: real; right, up: array of GLFloat);
procedure rysuj_litere(n: integer; sx, sy, sz, sr: real; right, up: array of GLFloat);
procedure rysuj_litere2d(n: integer; sx, sy, sr: real);
procedure rysuj_ikone(n: integer; sx, sy, sr: real);
procedure pisz_liczbe2d(n: int64; sx, sy, sr: real);
procedure pisz2d(s: string; sx, sy, sr: real; margines: byte = 0);
procedure pisz2d_otoczka(s: string; sx, sy, sr: real; margines: byte; kr, kg, kb, ka, kor, kog, kob, koa: single);

implementation
uses
  OpenGl, Glu, GLext,
  obj, ZGLTextures;


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
      if innatekstura <> -2 then
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
    case s[a] of
      '0'..'9':
        rysuj_litere(ord(s[a]) - 48, sx, sy, sz, sr, right, up);
      '-':
        rysuj_litere(50, sx, sy, sz, sr, right, up);
    end;
    glTranslatef(right[0] * sr * 2, right[1] * sr * 2, right[2] * sr * 2);
  end;
  glPopMatrix;
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


end.
