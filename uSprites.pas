unit uSprites;

interface
uses
  GL;

procedure rysuj_sprajt(sx, sy, sz, sr: real; right, up: array of GLFloat; obrot: real = 0);

implementation

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


end.
