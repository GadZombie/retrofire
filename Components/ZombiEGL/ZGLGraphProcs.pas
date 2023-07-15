unit ZGLGraphProcs;

interface

uses OpenGl, Gl, Glu, ZGLTextures, ZGLMathProcs, OBJ;

procedure rysuj_sprajt(sx, sy, sz, sr:real; right, up:array of GLfloat; obrot:real=0);
procedure DrawSprite(n: integer; sx, sy, srx, sry: real;
  tekstura: integer = 0;
  ilex: integer = 8; iley: integer = 8;
  reverseX: boolean = false; reverseY: boolean = false);
procedure rysuj_litere2d(n: integer; sx, sy, sr: real; tekstura: integer = 0;
  ilex: integer = 8; iley: integer = 8);
procedure pisz2d(s:string; sx, sy,  sr:real; margines:byte=0);


implementation

procedure rysuj_sprajt(sx, sy, sz, sr:real; right, up:array of GLfloat; obrot:real=0);
begin
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glTranslatef(0.5,0.5,0);
  glRotatef(obrot,0,0,1);
  glTranslatef(-0.5,-0.5,0);
  glMatrixMode(GL_MODELVIEW);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

 glBegin(GL_QUADS);
   glTexCoord2f(0.0, 0.0);
   glVertex3f ((sx + (right[0] + up[0]) * -sr),(sy + (right[1] + up[1]) * -sr),(sz + (right[2] + up[2]) * -sr));
   glTexCoord2f(1.0, 0.0);
   glVertex3f ((sx + (right[0] - up[0]) * sr),(sy + (right[1] - up[1]) * sr),(sz + (right[2] - up[2]) * sr));
   glTexCoord2f(1.0, 1.0);
   glVertex3f ((sx + (right[0] + up[0]) * sr),(sy + (right[1] + up[1]) * sr),(sz + (right[2] + up[2]) * sr));
   glTexCoord2f(0.0, 1.0);
   glVertex3f ((sx + (up[0] - right[0]) * sr),(sy + (up[1] - right[1]) * sr),(sz + (up[2] - right[2]) * sr));
 glEnd();

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();

  glMatrixMode(GL_MODELVIEW);

end;

//---------------------------------------------------------------------------
procedure DrawSprite(n: integer; sx, sy, srx, sry: real;
  tekstura: integer = 0;
  ilex: integer = 8; iley: integer = 8;
  reverseX: boolean = false; reverseY: boolean = false);
var
  mx,my, mx1,my1, tmp: real;
  poltex_w, poltex_h: real;
begin
  poltex_w := 1 / ((ilex * 32) * 2); //pol teksela w szerokosci tekstury
  poltex_h := 1 / ((iley * 32) * 2); //pol teksela w wysokosci tekstury

  mx := (n mod ilex) / ilex + poltex_w;
  my := 1 - (n div ilex) / iley - (1 / iley) + poltex_h;
  mx1 := mx + (1 / ilex) - poltex_w * 2;
  my1 := my + (1 / iley) - poltex_h * 2;

  if reverseX then
  begin
    tmp := mx;
    mx := mx1;
    mx1 := tmp;
  end;
  if reverseY then
  begin
    tmp := my;
    my := my1;
    my1 := tmp;
  end;

  wlacz_teksture(tekstura);
  glNormal3f(0, 0, 1);
  glBegin(GL_QUADS);
    glTexCoord2f(mx , my );
    glVertex3f ((sx + -srx),(sy + -sry),0);
    glTexCoord2f(mx1, my );
    glVertex3f ((sx +  srx),(sy + -sry),0);
    glTexCoord2f(mx1, my1);
    glVertex3f ((sx +  srx),(sy +  sry),0);
    glTexCoord2f(mx , my1);
    glVertex3f ((sx + -srx),(sy +  sry),0);
  glEnd();
  wylacz_teksture;

end;

//---------------------------------------------------------------------------
procedure rysuj_litere2d(n: integer; sx, sy, sr: real; tekstura: integer = 0;
  ilex: integer = 8; iley: integer = 8);
var
  mx,my, mx1,my1: real;
  poltex_w, poltex_h: real;
begin
  poltex_w := 1 / ((ilex * 32) * 2); //pol teksela w szerokosci tekstury
  poltex_h := 1 / ((iley * 32) * 2); //pol teksela w wysokosci tekstury

  mx := (n mod ilex) / ilex + poltex_w;
  my := 1 - (n div ilex) / iley - (1 / iley) + poltex_h;
  mx1 := mx + (1 / ilex) - poltex_w * 2;
  my1 := my + (1 / iley) - poltex_h * 2;

  wlacz_teksture(tekstura);
  glBegin(GL_QUADS);
    glTexCoord2f(mx , my );
    glVertex2f ((sx + -sr),(sy + -sr));
    glTexCoord2f(mx1, my );
    glVertex2f ((sx +  sr),(sy + -sr));
    glTexCoord2f(mx1, my1);
    glVertex2f ((sx +  sr),(sy +  sr));
    glTexCoord2f(mx , my1);
    glVertex2f ((sx + -sr),(sy +  sr));
  glEnd();
  wylacz_teksture;

end;

procedure pisz2d(s: string; sx, sy, sr: real; margines: byte = 0);
const
  ilex = 8;
  iley = 16;
var
  a:  integer;
  px: real;
begin
  if margines = 1 then
    sx := sx - (length(s) - 1) * sr //srodek
  else
  if margines = 2 then
    sx := sx - (length(s) - 1) * sr * 2; //prawy

  px := 0;
  glPushMatrix;
  for a := 1 to length(s) do
  begin
    case s[a] of
      #48..#57: rysuj_litere2d(Ord(s[a]) - 48, sx, sy, sr, 0, ilex, iley);
      #65..#90: rysuj_litere2d(Ord(s[a]) - 55, sx, sy, sr, 0, ilex, iley);
      #97..#122: rysuj_litere2d(Ord(s[a]) - 87, sx, sy, sr, 0, ilex, iley);
      '.': rysuj_litere2d(36, sx, sy, sr, 0, ilex, iley);
      ':': rysuj_litere2d(37, sx, sy, sr, 0, ilex, iley);
      ',': rysuj_litere2d(38, sx, sy, sr, 0, ilex, iley);
      '?': rysuj_litere2d(39, sx, sy, sr, 0, ilex, iley);
      '!': rysuj_litere2d(40, sx, sy, sr, 0, ilex, iley);
      'π', '•': rysuj_litere2d(41, sx, sy, sr, 0, ilex, iley);
      'Ê', '∆': rysuj_litere2d(42, sx, sy, sr, 0, ilex, iley);
      'Í', ' ': rysuj_litere2d(43, sx, sy, sr, 0, ilex, iley);
      '≥', '£': rysuj_litere2d(44, sx, sy, sr, 0, ilex, iley);
      'Ò', '—': rysuj_litere2d(45, sx, sy, sr, 0, ilex, iley);
      'Û', '”': rysuj_litere2d(46, sx, sy, sr, 0, ilex, iley);
      'ú', 'å': rysuj_litere2d(47, sx, sy, sr, 0, ilex, iley);
      'ü', 'è': rysuj_litere2d(48, sx, sy, sr, 0, ilex, iley);
      'ø', 'Ø': rysuj_litere2d(49, sx, sy, sr, 0, ilex, iley);
      '-': rysuj_litere2d(50, sx, sy, sr, 0, ilex, iley);
      '/': rysuj_litere2d(51, sx, sy, sr, 0, ilex, iley);
      '@': rysuj_litere2d(52, sx, sy, sr, 0, ilex, iley);
      '+': rysuj_litere2d(53, sx, sy, sr, 0, ilex, iley);
      '=': rysuj_litere2d(54, sx, sy, sr, 0, ilex, iley);
      '(': rysuj_litere2d(55, sx, sy, sr, 0, ilex, iley);
      ')': rysuj_litere2d(56, sx, sy, sr, 0, ilex, iley);
      '[': rysuj_litere2d(57, sx, sy, sr, 0, ilex, iley);
      ']': rysuj_litere2d(58, sx, sy, sr, 0, ilex, iley);
      '\': rysuj_litere2d(59, sx, sy, sr, 0, ilex, iley);
      '''': rysuj_litere2d(60, sx, sy, sr, 0, ilex, iley);
      ';': rysuj_litere2d(61, sx, sy, sr, 0, ilex, iley);
      '©': rysuj_litere2d(62, sx, sy, sr, 0, ilex, iley);     //znak diamentu; zeby go napisac zrob alt+0169

      '#': rysuj_litere2d(64, sx, sy, sr, 0, ilex, iley);
      '$': rysuj_litere2d(65, sx, sy, sr, 0, ilex, iley);
      '%': rysuj_litere2d(66, sx, sy, sr, 0, ilex, iley);
      '^': rysuj_litere2d(67, sx, sy, sr, 0, ilex, iley);
      '&': rysuj_litere2d(68, sx, sy, sr, 0, ilex, iley);
      '*': rysuj_litere2d(69, sx, sy, sr, 0, ilex, iley);
      '_': rysuj_litere2d(70, sx, sy, sr, 0, ilex, iley);
      '`': rysuj_litere2d(71, sx, sy, sr, 0, ilex, iley);
      '~': rysuj_litere2d(72, sx, sy, sr, 0, ilex, iley);
      '"': rysuj_litere2d(73, sx, sy, sr, 0, ilex, iley);
      '<': rysuj_litere2d(74, sx, sy, sr, 0, ilex, iley);
      '>': rysuj_litere2d(75, sx, sy, sr, 0, ilex, iley);
      '|': rysuj_litere2d(76, sx, sy, sr, 0, ilex, iley);

     #129: rysuj_litere2d(77, sx, sy, sr, 0, ilex, iley);
     #130: rysuj_litere2d(78, sx, sy, sr, 0, ilex, iley);

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

//-----------------------------------------------------------------------------
{procedure Recalculate2DView;
begin
  glGetFloatv(GL_MODELVIEW_MATRIX, @viewMatrix);
  View2DRight[0] := viewMatrix[0];
  View2DRight[1] := viewMatrix[4];
  View2DRight[2] := viewMatrix[8];
  View2DUp[0] := viewMatrix[1];
  View2DUp[1] := viewMatrix[5];
  View2DUp[2] := viewMatrix[9];
end;
}

end.

