unit UnitTex;

interface

uses gl, glu, glext, windows, forms;

const
  ile_tekstur = 19;

type
  Texture = record // Struktura textury
    imageData: PGLubyte; // Data
    bpp: GLuint; // Barevn� hloubka v bitech
    width: GLuint; // �ݰka
    height: GLuint; // V��ka
    texID: GLuint; // ID textury
    typ: GLuint; // Typ (GL_RGB, GL_RGBA)
  end;

  PTexture = ^Texture; // Ukazatel na strukturu textury

  TTGAHeader = record // Hlavi�ka TGA souboru
    Header: array [0 .. 11] of GLubyte; // Dvan�ct byt�
  end;

  TTGA = record // Struktura obr�zku
    Header: array [0 .. 5] of GLubyte; // �est u�ite�n�ch byt� z hlavi�ky
    bytesPerPixel: GLuint; // Barevn� hloubka v bytech
    imageSize: GLuint; // Velikost pam�ti pro obr�zek
    typ: GLuint; // Typ
    Heigh: GLuint; // V��ka
    width: GLuint; // �ݰka
    bpp: GLuint; // Barevn� hloubka v bitech
  end;

var
  texName: array [0 .. ile_tekstur - 1] of integer;

function LoadTGA(var Texture: Texture; filename: string): boolean;

var
  tgaheader: TTGAHeader; // TGA hlavi�ka
  tga: TTGA; // TGA obr�zek
  uTGAcompare: array [0 .. 11] of GLubyte = (
    0,
    0,
    2,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  ); // TGA hlavi�ka nekomprimovan�ho obr�zku
  cTGAcompare: array [0 .. 11] of GLubyte = (
    0,
    0,
    10,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  ); // TGA hlavi�ka komprimovan�ho obr�zku
  fTGA: file; // Soubor

procedure wlacz_teksture_env(numer: integer);
function wczytaj_teksture(numer: integer; nazwa: string; jaka: integer)
  : boolean;
function wczytaj_teksture3d(numer: integer; nazwa: array of string): boolean;
procedure wlacz_teksture(numer: integer);
procedure wlacz_teksture3d(numer: integer);
procedure wylacz_teksture();

implementation

uses SysUtils;

function LoadUncompressedTGA(var Texture: Texture; filename: string): boolean;
// Nahraje nekomprimovan� TGA
var
  precteno: integer; // Po�et p�e�ten�ch byt�
  i: integer; // Cyklus
  B, R: PGLubyte; // Ukazatel na prohazovan� slo�ky barev
  temp: GLubyte; // Pomocn� prom�nn�
begin
  BlockRead(fTGA, tga.Header, sizeof(tga.Header), precteno);
  // �est u�ite�n�ch byt�
  if precteno <> sizeof(tga.Header) then
  begin
    MessageBox(0, 'Could not read info header', 'ERROR', MB_OK);
    Result := false;
  end;
  Texture.width := tga.Header[1] * 256 + tga.Header[0]; // �ݰka
  Texture.height := tga.Header[3] * 256 + tga.Header[2]; // V��ka
  Texture.bpp := tga.Header[4]; // Barevn� hloubka v bitech
  tga.width := Texture.width; // Kop�rov�n� dat do struktury obr�zku
  tga.Heigh := Texture.height;
  tga.bpp := Texture.bpp;
  if (Texture.width <= 0) or (Texture.height <= 0) or // Platn� hodnoty?
    ((Texture.bpp <> 24) and (Texture.bpp <> 32)) then
  begin
    MessageBox(0, 'Invalid texture information', 'ERROR', MB_OK);
    Result := false;
  end;
  if Texture.bpp = 24 then // 24 bitov� obr�zek?
    Texture.typ := GL_RGB
  else // 32 bitov� obr�zek
    Texture.typ := GL_RGBA;
  tga.bytesPerPixel := Texture.bpp div 8; // BYTY na pixel
  tga.imageSize := tga.bytesPerPixel * tga.width * tga.Heigh; // Velikost pam�ti
  Texture.imageData := AllocMem(tga.imageSize); // Alokace pam�ti pro data
  if Texture.imageData = nil then // Alokace ne�sp��n�
  begin
    MessageBox(0, 'Could not allocate memory for image', 'ERROR', MB_OK);
    Result := false;
  end;
  BlockRead(fTGA, Texture.imageData^, tga.imageSize, precteno);
  // Pokus� se nahr�t data obr�zku
  if precteno <> tga.imageSize then
  begin
    MessageBox(0, 'Could not read image data', 'ERROR', MB_OK);
    FreeMem(Texture.imageData); // Uvoln�n� pam�ti
    Result := false;
  end;
  for i := 0 to (tga.width * tga.Heigh) - 1 do // P�evod BGR na RGB
  begin
    B := Pointer(integer(Texture.imageData) + i * tga.bytesPerPixel);
    // Ukazatel na B
    R := Pointer(integer(Texture.imageData) + i * tga.bytesPerPixel + 2);
    // Ukazatel na R
    temp := B^; // B ulo��me do pomocn� prom�nn�
    B^ := R^; // R je na spr�vn�m m�st�
    R^ := temp; // B je na spr�vn�m m�st�
  end;
  CloseFile(fTGA); // Zav�en� souboru
  Result := true; // -sp�ch
end;

function LoadCompressedTGA(var Texture: Texture; filename: string): boolean;
// Nahraje komprimovan� obr�zek
var
  precteno: integer; // Po�et p�e�ten�ch byt�
  pixelcount: GLuint; // Po�et pixel�
  currentpixel: GLuint; // Aktu�ln� na��tan� pixel
  currentbyte: GLuint; // Aktu�ln� na��tan� byte
  colorbuffer: PGLubyte; // Ukazatel na pole byt�
  chunkheader: GLubyte; // Byte hlavi�ky
  counter: integer; // Cyklus
  R, G, B, A: PGLubyte; // Ukazatel na slo�ky barev
  temp: PGLubyte; // Pomocn� prom�nn�
begin
  BlockRead(fTGA, tga.Header, sizeof(tga.Header), precteno);
  // �est u�ite�n�ch byt�
  if precteno <> sizeof(tga.Header) then
  begin
    MessageBox(0, 'Could not read info header', 'ERROR', MB_OK);
    Result := false;
  end;
  Texture.width := tga.Header[1] * 256 + tga.Header[0]; // �ݰka
  Texture.height := tga.Header[3] * 256 + tga.Header[2]; // V��ka
  Texture.bpp := tga.Header[4]; // Barevn� hloubka v bitech
  tga.width := Texture.width; // Kop�rov�n� dat do struktury obr�zku
  tga.Heigh := Texture.height;
  tga.bpp := Texture.bpp;
  if (Texture.width <= 0) or (Texture.height <= 0) or // Platn� hodnoty?
    ((Texture.bpp <> 24) and (Texture.bpp <> 32)) then
  begin
    MessageBox(0, 'Invalid texture information', 'ERROR', MB_OK);
    Result := false;
  end;
  if Texture.bpp = 24 then // 24 bitov� obr�zek?
    Texture.typ := GL_RGB
  else // 32 bitov� obr�zek
    Texture.typ := GL_RGBA;
  tga.bytesPerPixel := Texture.bpp div 8; // BYTY na pixel
  tga.imageSize := tga.bytesPerPixel * tga.width * tga.Heigh; // Velikost pam�ti
  Texture.imageData := AllocMem(tga.imageSize); // Alokace pam�ti pro data
  if Texture.imageData = nil then // Alokace ne�sp��n�
  begin
    MessageBox(0, 'Could not allocate memory for image', 'ERROR', MB_OK);
    Result := false;
  end;
  pixelcount := tga.width * tga.Heigh; // Po�et pixel�
  currentpixel := 0; // Aktu�ln� na��tan� pixel
  currentbyte := 0; // Aktu�ln� na��tan� byte
  colorbuffer := AllocMem(tga.bytesPerPixel); // Pam�� pro jeden pixel
  if colorbuffer = nil then // Alokace ne�sp��n�
  begin
    MessageBox(0, 'Could not allocate memory for color buffer', 'ERROR', MB_OK);
    FreeMem(Texture.imageData);
    Result := false;
  end;
  repeat // Proch�z� cel� soubor
    chunkheader := 0; // Byte hlavi�ky
    BlockRead(fTGA, chunkheader, sizeof(GLubyte), precteno);
    // Na�te byte hlavi�ky
    if precteno <> sizeof(GLubyte) then
    begin
      MessageBox(0, 'Could not read RLE header', 'ERROR', MB_OK);
      FreeMem(Texture.imageData);
      FreeMem(colorbuffer);
      Result := false;
    end;
    if chunkheader < 128 then // RAW ��st obr�zku
    begin
      Inc(chunkheader);
      // Po�et pixel� v sekci p�ed v�skytem dal��ho bytu hlavi�ky
      for counter := 0 to chunkheader - 1 do // Jednotliv� pixely
      begin
        BlockRead(fTGA, colorbuffer^, tga.bytesPerPixel, precteno);
        // Na��t�n� po jednom pixelu
        if precteno <> tga.bytesPerPixel then
        begin
          MessageBox(0, 'Could not read image data', 'ERROR', MB_OK);
          FreeMem(Texture.imageData);
          FreeMem(colorbuffer);
          Result := false;
        end;
        R := Pointer(integer(colorbuffer) + 2);
        // Z�pis do pam�ti, prohod� R a B slo�ku barvy
        G := Pointer(integer(colorbuffer) + 1);
        B := Pointer(integer(colorbuffer) + 0);
        temp := Pointer(integer(Texture.imageData) + currentbyte);
        temp^ := R^;
        temp := Pointer(integer(Texture.imageData) + currentbyte + 1);
        temp^ := G^;
        temp := Pointer(integer(Texture.imageData) + currentbyte + 2);
        temp^ := B^;
        if tga.bytesPerPixel = 4 then // 32 bitov� obr�zek?
        begin
          A := Pointer(integer(colorbuffer) + 3); // Kop�rov�n� alfy
          temp := Pointer(integer(Texture.imageData) + currentbyte + 3);
          temp^ := A^;
        end;
        Inc(currentbyte, tga.bytesPerPixel); // Aktualizuje byte
        Inc(currentpixel); // P�esun na dal�� pixel
        if currentpixel > pixelcount then // Jsme za hranic� obr�zku?
        begin
          MessageBox(0, 'Too many pixels read', 'ERROR', MB_OK);
          FreeMem(Texture.imageData);
          FreeMem(colorbuffer);
          Result := false;
        end;
      end;
    end
    else // RLE ��st obr�zku
    begin
      Dec(chunkheader, 127); // Po�et pixel� v sekci
      BlockRead(fTGA, colorbuffer^, tga.bytesPerPixel, precteno);
      // Na�te jeden pixel
      if precteno <> tga.bytesPerPixel then
      begin
        MessageBox(0, 'Could not read from file', 'ERROR', MB_OK);
        FreeMem(Texture.imageData);
        FreeMem(colorbuffer);
        Result := false;
      end;
      for counter := 0 to chunkheader - 1 do // Kop�rov�n� pixelu
      begin
        R := Pointer(integer(colorbuffer) + 2);
        // Z�pis do pam�ti, prohod� R a B slo�ku barvy
        G := Pointer(integer(colorbuffer) + 1);
        B := Pointer(integer(colorbuffer) + 0);
        temp := Pointer(integer(Texture.imageData) + currentbyte);
        temp^ := R^;
        temp := Pointer(integer(Texture.imageData) + currentbyte + 1);
        temp^ := G^;
        temp := Pointer(integer(Texture.imageData) + currentbyte + 2);
        temp^ := B^;
        if tga.bytesPerPixel = 4 then // 32 bitov� obr�zek?
        begin
          A := Pointer(integer(colorbuffer) + 3); // Kop�rov�n� alfy
          temp := Pointer(integer(Texture.imageData) + currentbyte + 3);
          temp^ := A^;
        end;
        Inc(currentbyte, tga.bytesPerPixel); // Aktualizuje byte
        Inc(currentpixel); // P�esun na dal�� pixel
        if currentpixel > pixelcount then // Jsme za hranic� obr�zku?
        begin
          MessageBox(0, 'Too many pixels read', 'ERROR', MB_OK);
          FreeMem(Texture.imageData);
          FreeMem(colorbuffer);
          Result := false;
        end;
      end;
    end;
  until currentpixel = pixelcount; // Pokra�uj dokud zb�vaj� pixely
  FreeMem(colorbuffer); // Uvoln�n� dynamick� pam�ti
  CloseFile(fTGA); // Zav�en� souboru
  Result := true; // -sp�ch
end;

function LoadTGA(var Texture: Texture; filename: string): boolean;
// Nahraje TGA soubor
var
  precteno: integer; // Po�et p�e�ten�ch byt�
begin
  AssignFile(fTGA, filename); // P�i�azen� souboru
{$I-}
  Reset(fTGA, 1); // Otev�e soubor
{$I+}
  if IOResult <> 0 then // Nepoda�ilo se ho otev��t?
  begin
    MessageBox(0, pchar('Nie mozna otworzyc tekstury! ' + filename),
      'ERROR', MB_OK);
    Result := false;
    exit;
  end;
  BlockRead(fTGA, tgaheader, sizeof(tgaheader), precteno);
  // Na�te hlavi�ku souboru
  if precteno <> sizeof(tgaheader) then
  begin
    MessageBox(0, 'Could not read file header', 'ERROR', MB_OK);
    CloseFile(fTGA);
    Result := false;
    exit;
  end;
  if tgaheader.Header[2]
    = 2 { CompareMem(@uTGAcompare,@tgaheader,sizeof(tgaheader)) } then
  // Nekomprimovan�
  begin
    if not LoadUncompressedTGA(Texture, filename) then
    begin
      CloseFile(fTGA);
      Result := false;
      exit;
    end;
  end
  else if tgaheader.Header[2]
    = 10 { CompareMem(@cTGAcompare,@tgaheader,sizeof(tgaheader)) } then
  // Komprimovan�
  begin
    if not LoadCompressedTGA(Texture, filename) then
    begin
      CloseFile(fTGA);
      Result := false;
      exit;
    end;
  end
  else // Ani jeden z nich
  begin
    MessageBox(0, pchar('TGA file be type 2 or type 10'#13#10'Jest=' +
      inttostr(Texture.typ)), 'Invalid Image', MB_OK);
    CloseFile(fTGA);
    Result := false;
    exit;
  end;
  Result := true; // V�e v po��dku
end;

function wczytaj_teksture(numer: integer; nazwa: string; jaka: integer)
  : boolean;
var
  tgaFile: Texture;
  A: integer;
begin
  Result := false;
  if not LoadTGA(tgaFile, 'dane\' + nazwa) then
  begin
    // messagebox(0,'Nie wczytano textury','ERROR',MB_OK);
    Application.Terminate;
    halt(0);
    exit;
  end;

  glBindTexture(GL_TEXTURE_2D, texName[numer]);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  if (jaka = 0) then
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
      GL_LINEAR_MIPMAP_LINEAR)
  else if (jaka = 1) then
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

  if (jaka = 1) then
  begin
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
    glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
  end;

  glTexImage2D(GL_TEXTURE_2D, 0, tgaFile.typ, tgaFile.width, tgaFile.height, 0,
    tgaFile.typ, GL_UNSIGNED_BYTE, tgaFile.imageData);

  Result := true;

  { for a:=1 to round(sqrt(tgaFile.width)-1) do
    glTexImage2D(GL_TEXTURE_2D, a, tgaFile.typ, tgaFile.width div (sqr(a+1)),
    tgaFile.height div (sqr(a+1)),  0, tgaFile.typ, GL_UNSIGNED_BYTE,
    tgaFile.imageData);
  }
  if (gluBuild2DMipmaps(GL_TEXTURE_2D, tgaFile.bpp div 8, tgaFile.width,
    tgaFile.height, tgaFile.typ, GL_UNSIGNED_BYTE, tgaFile.imageData) <> 0) then
  begin
    MessageBox(0, 'Nie utworzono mipmap', 'ERROR', MB_OK);
    exit;
  end;

end;

function wczytaj_teksture3d(numer: integer; nazwa: array of string): boolean;
var
  tgaFile1: Texture;
  imageDatac: PGLubyte;
  R: integer;
  A, ile: integer;
begin
  ile := length(nazwa);
  R := 0;
  imageDatac := nil;
  result := false;
  for A := 0 to ile - 1 do
  begin

    if not LoadTGA(tgaFile1, 'dane\' + nazwa[A]) then
    begin
      MessageBox(0, pchar('Nie wczytano textury'#13#10 + nazwa[A]),
        'ERROR', MB_OK);
      exit;
    end;

    if A = 0 then
    begin
      R := tgaFile1.width * tgaFile1.height * (tgaFile1.bpp div 8);
      imageDatac := AllocMem(ile * R);
    end;

    CopyMemory(imageDatac, tgaFile1.imageData, R);
    Inc(imageDatac, R);

  end;

  Dec(imageDatac, R * ile);

  glBindTexture(GL_TEXTURE_3D, texName[numer]);

  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  // glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

  { for a:=0 to 15 do
    glTexImage3D(GL_TEXTURE_3D, a, tgaFile1.typ, tgaFile1.width div (sqr(a+1)),
    tgaFile1.height div (sqr(a+1)), ile , 0, tgaFile1.typ, GL_UNSIGNED_BYTE,
    imageDatac);
  }

  glTexImage3D(GL_TEXTURE_3D, 0, tgaFile1.typ, tgaFile1.width, tgaFile1.height,
    ile, 0, tgaFile1.typ, GL_UNSIGNED_BYTE, imageDatac);

  FreeMem(imageDatac);
end;

procedure wlacz_teksture_env(numer: integer);
begin
  glBindTexture(GL_TEXTURE_2D, texName[numer]);

  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);

  glEnable(GL_TEXTURE_GEN_S);
  glEnable(GL_TEXTURE_GEN_T);
  glEnable(GL_TEXTURE_2D);
  glDisable(GL_TEXTURE_3D);
end;

procedure wlacz_teksture(numer: integer);
begin
  glBindTexture(GL_TEXTURE_2D, texName[numer]);

  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
  // glLightModeli(GL_LIGHT_MODEL_AMBIENT, GL_FALSE);
  glEnable(GL_TEXTURE_2D);
  glDisable(GL_TEXTURE_3D);
end;

procedure wlacz_teksture3d(numer: integer);
begin
  glBindTexture(GL_TEXTURE_3D, texName[numer]);

  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
  // glLightModeli(GL_LIGHT_MODEL_AMBIENT, GL_FALSE);
  glEnable(GL_TEXTURE_3D);
  glDisable(GL_TEXTURE_2D);
end;

procedure wylacz_teksture();
begin
  glDisable(GL_TEXTURE_GEN_S);
  glDisable(GL_TEXTURE_GEN_T);
  glDisable(GL_TEXTURE_2D);
  glDisable(GL_TEXTURE_3D);
end;

end.
