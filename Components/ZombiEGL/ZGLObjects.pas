unit ZGLObjects;

interface
uses
  System.Generics.collections, Classes, SysUtils,
  OpenGl, Gl, Glu, ZGLTextures, ZGLMathProcs, OBJ;

type
  TMatArray = array[0..3] of GLFloat;
  TObjFileType = (oftObj, oftObjBin);

  TGLObject = class
  public
    o:        TOBJModel;
    tex:      byte;
    mat_a:    TMatArray;
    mat_d:    TMatArray;
    mat_s:    TMatArray;
    mat_shin: integer;

    glListId: GLUInt;

    procedure DrawGLObject(textureIdx: integer = -1; colorMaterial: boolean = False; noTextures: boolean = False);
    procedure DrawGLObjectElement(elementiIndex: integer; findCenter: boolean;
                                   textureIdx:integer=-1; colorMaterial:boolean=false; noTextures: boolean=false;
                                   shatterStrength:real=0; shatterRandSeed:integer=0);
    function FindGLObjectElement(elementName:string): integer;
    function GetElementCount: integer;

    procedure DrawFromList;
  end;

  TGLObjectsContainter = class
  private
    listIdxCounter: integer;
  public
    Objects: TObjectList<TGLObject>;
    GlList: TList<GLuint>;

    constructor Create;
    destructor Destroy;

    function LoadGLObject(fileName: string; objFileType: TObjFileType; sizeFactor: extended;
      textureIdx: integer; materialAmbient, materialDiffuse, materialSpecular: TMatArray;
      materialShininess: integer): integer;

    function LoadGLObjectAni(fileName: string; objFileType: TObjFileType;
      frameStart, frameEnd, digitsCount: integer;
      sizeFactor: extended;
      textureIdx: integer; materialAmbient, materialDiffuse, materialSpecular: TMatArray;
      materialShininess: integer): integer;

    function NewGlList: integer;
    procedure CallList(glListIdx: integer);
    procedure CallListAni(glListIdx, frameNumber: integer);
  end;

var
  GLObjectsContainter: TGLObjectsContainter;

function MatArray(Ar, Ag, Ab, Aa: GLFloat): TMatArray;

implementation

//-----------------------------------------------------------------------------
procedure TGLObject.DrawGLObject(textureIdx: integer = -1; colorMaterial: boolean = False; noTextures: boolean = False);
var
  v, f, g, o: integer;
begin
  if not noTextures then
  begin

    if textureIdx = -1 then
      wlacz_teksture(Self.tex)
    else
      wlacz_teksture(textureIdx);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    if not colorMaterial then
      glDisable(GL_COLOR_MATERIAL);
  end;

  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);

  if not noTextures then
  begin
    if not colorMaterial then
    begin
      glMaterialf(GL_FRONT, GL_SHININESS, Self.mat_shin);
      glMaterialfv(GL_FRONT, GL_AMBIENT, @Self.mat_a);
      glMaterialfv(GL_FRONT, GL_DIFFUSE, @Self.mat_d);
      glMaterialfv(GL_FRONT, GL_SPECULAR, @Self.mat_s);
    end;
  end;

  with Self.o do
  begin
    for g := 0 to High(Groups) do
    begin
      with Groups[g] do
      begin
        begin
        end;
        glBegin(GL_TRIANGLES);
        for f := 0 to High(Faces) do
        begin
          for v := 0 to 2 do
          begin
            if Faces[f].UV[v] < Length(TexCoords) then
              glTexCoord2fv(@TexCoords[Faces[f].UV[v]]);
            if Faces[f].Normal[v] < Length(Normals) then
              glNormal3fv(@Normals[Faces[f].Normal[v]]);
            if Faces[f].XYZ[v] < Length(Vertices) then
              glVertex3fv(@Vertices[Faces[f].XYZ[v]]);
          end;
        end;
        glEnd;
      end;
    end;
  end;

end;

//---------------------------------------------------------------------------
procedure TGLObject.DrawGLObjectElement(elementiIndex: integer; findCenter: boolean;
                               textureIdx:integer=-1; colorMaterial:boolean=false; noTextures: boolean=false;
                               shatterStrength:real=0; shatterRandSeed:integer=0);
var
  v, f: integer;
begin
  if not noTextures then
  begin
    if textureIdx = -1 then
      wlacz_teksture(Self.tex)
    else
      wlacz_teksture(textureIdx);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    if not colorMaterial then
      glDisable(GL_COLOR_MATERIAL);
  end;

  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);
  if not noTextures then
  begin
    if not colorMaterial then
    begin
      glMaterialf(GL_FRONT, GL_SHININESS, Self.mat_shin);

      glMaterialfv(GL_FRONT, GL_AMBIENT, @Self.mat_a);
      glMaterialfv(GL_FRONT, GL_DIFFUSE, @Self.mat_d);
      glMaterialfv(GL_FRONT, GL_SPECULAR, @Self.mat_s);
    end;
  end;

  if findCenter then
  begin
    with Self.o do
      with Self.o.Groups[elementiIndex] do
      begin
        glBegin(GL_TRIANGLES);
          for f := 0 to High(Faces) do
          begin
            for v := 0 to 2 do
            begin
              if Faces[f].UV[v] < Length(TexCoords) then
                glTexCoord2fv(@TexCoords[Faces[f].UV[v]]);
              if Faces[f].Normal[v] < Length(Normals) then
                glNormal3fv(@Normals[Faces[f].Normal[v]]);
              if Faces[f].XYZ[v] < Length(Vertices) then
              begin
                if shatterStrength > 0 then
                  RandSeed := round(Vertices[Faces[f].XYZ[v]].x + Vertices[Faces[f].XYZ[v]].y + Vertices[Faces[f].XYZ[v]].z) + shatterRandSeed;
                glVertex3f(Vertices[Faces[f].XYZ[v]].x - srx + ((random - 0.5) * shatterStrength),
                           Vertices[Faces[f].XYZ[v]].y - sry + ((random - 0.5) * shatterStrength),
                           Vertices[Faces[f].XYZ[v]].z - srz + ((random - 0.5) * shatterStrength) );
              end;
            end;
          end;
        glEnd;
      end;
  end
  else
  begin
    with Self.o do
      with Self.o.Groups[elementiIndex] do
      begin
        glBegin(GL_TRIANGLES);
          for f := 0 to High(Faces) do
          begin
            for v := 0 to 2 do
            begin
              if Faces[f].UV[v] < Length(TexCoords) then
                glTexCoord2fv(@TexCoords[Faces[f].UV[v]]);
              if Faces[f].Normal[v] < Length(Normals) then
                glNormal3fv(@Normals[Faces[f].Normal[v]]);
              if Faces[f].XYZ[v] < Length(Vertices) then
              begin
                if shatterStrength > 0 then
                  RandSeed := round(Vertices[Faces[f].XYZ[v]].x + Vertices[Faces[f].XYZ[v]].y + Vertices[Faces[f].XYZ[v]].z) + shatterRandSeed;
                glVertex3f(Vertices[Faces[f].XYZ[v]].x + ((random - 0.5) * shatterStrength),
                           Vertices[Faces[f].XYZ[v]].y + ((random - 0.5) * shatterStrength),
                           Vertices[Faces[f].XYZ[v]].z + ((random - 0.5) * shatterStrength) );
              end;
            end;
          end;
        glEnd;
      end;
  end;

  if shatterStrength > 0 then
    Randomize;
end;

//----------------------------------------------------------------------------
function TGLObject.FindGLObjectElement(elementName:string): integer;
var
  a: integer;
begin
  result := -1;

  elementName := uppercase(elementName);
  a := 0;
  while (a <= high(Self.o.groups)) and
      (uppercase(Self.o.groups[a].Name) <> elementName) do
    inc(a);

  if (a <= high(Self.o.groups)) then
    result := a;
end;

//----------------------------------------------------------------------------
function TGLObject.GetElementCount: integer;
begin
  result := length(Self.o.groups);
end;

//----------------------------------------------------------------------------
procedure TGLObject.DrawFromList;
begin
  GLObjectsContainter.CallList(glListId);
end;

//----------------------------------------------------------------------------
function MatArray(Ar, Ag, Ab, Aa: GLFloat): TMatArray;
begin
  result[0] := Ar;
  result[1] := Ag;
  result[2] := Ab;
  result[3] := Aa;
end;

//----------------------------------------------------------------------------
constructor TGLObjectsContainter.Create;
begin
  inherited;
  Objects := TObjectList<TGLObject>.Create;
  GlList := TList<GLuint>.Create;
  listIdxCounter := 0;
end;

//----------------------------------------------------------------------------
destructor TGLObjectsContainter.Destroy;
var
  a: integer;
begin
//  for a := 0 to GlList.Count - 1 do
//    Dispose(GlList.Items[a]);
  GlList.Free;
  Objects.Free;
  inherited;
end;

//----------------------------------------------------------------------------
function TGLObjectsContainter.LoadGLObject(fileName: string; objFileType: TObjFileType;
  sizeFactor: extended;
  textureIdx: integer; materialAmbient, materialDiffuse, materialSpecular: TMatArray;
  materialShininess: integer): integer;
var
  tmpObj: TGLObject;
begin
  tmpObj := TGLObject.Create;

  tmpObj.o := TOBJModel.Create;
  if objFileType = oftObj then
    tmpObj.o.LoadFromFile(fileName, sizeFactor)
  else
    tmpObj.o.LoadFromFileAsObjBin(fileName, sizeFactor);
  tmpObj.tex := textureIdx;
  tmpObj.mat_a := materialAmbient;
  tmpObj.mat_d := materialDiffuse;
  tmpObj.mat_s := materialSpecular;
  tmpObj.mat_shin := materialShininess;

  result := Objects.Add(tmpObj);
end;

//----------------------------------------------------------------------------
function TGLObjectsContainter.LoadGLObjectAni(fileName: string; objFileType: TObjFileType;
  frameStart, frameEnd, digitsCount: integer;
  sizeFactor: extended;
  textureIdx: integer; materialAmbient, materialDiffuse, materialSpecular: TMatArray;
  materialShininess: integer): integer;
var
  res, n: integer;
  s: string;
begin
  result := -1;
  for n := frameStart to frameEnd do
  begin
    s := StringReplace(fileName, '*', Format('%.' + IntToStr(digitsCount) + 'd', [n]), []);
    res := LoadGLObject(s, objFileType,
      sizeFactor, textureIdx, materialAmbient,
      materialDiffuse, materialSpecular, materialShininess);
    if Result = -1 then
      Result := res;
  end;
end;

//----------------------------------------------------------------------------
function TGLObjectsContainter.NewGlList: integer;
var
  g: GLuint;
begin
  inc(listIdxCounter);
  g := listIdxCounter;
  glNewList(g, GL_COMPILE);
  result := GlList.Add(g);
end;

//----------------------------------------------------------------------------
procedure TGLObjectsContainter.CallList(glListIdx: integer);
begin
  glCallList(GlList.Items[glListIdx]);
end;

//----------------------------------------------------------------------------
procedure TGLObjectsContainter.CallListAni(glListIdx, frameNumber: integer);
begin
  glCallList(GlList.Items[glListIdx + frameNumber]);
end;

end.
