unit OBJ;

interface

uses
  Classes, SysUtils, GL, windows, forms;

type
  TOBJFace = record
    // TexCoords
    UV: array [0..2] of Cardinal;
    // Vertex normals
    Normal: array [0..2] of Cardinal;
    // Vertex coordinates
    XYZ: array [0..2] of Cardinal;
  end;

  TVector = record
    case Boolean of
      TRUE: ( x, y, z: Single; );
      FALSE: ( xyz: array [0..2] of Single; );
  end;

  TTexCoords = record
    case Boolean of
      TRUE: ( u, v: Single; );
      FALSE: ( uv: array [0..2] of Single; );
  end;

  TOBJGroup = record
    Name: String;
    Faces: array of TOBJFace;
    Texture: GLuint;
    srx,sry,srz: real;
  end;

  TOBJModel = class
  private
    FExtMin, FExtMax: TVector;
  public
    // Global vertex pool
    Vertices: array of TVector;
    // Global vertex normal pool
    Normals: array of TVector;
    // Global texcoord pool
    TexCoords: array of TTexCoords;
    // List of "groups" (objects) in the file
    Groups: array of TOBJGroup;
    procedure LoadFromFile(filename: String; skala:real=1);
    function ToDisplayList: GLuint;
    procedure CalculateBounds;
    property ExtentsMin: TVector read FExtMin;
    property ExtentsMax: TVector read FExtMax;
  end;

implementation

var
  StringToFloat: function(const S: string): Extended = nil;

function StrToFloat_sep(const S: string): Extended;
begin

  if Pos(',', S) > 0 then DecimalSeparator := ','
  else DecimalSeparator := '.';
  StringToFloat := StrToFloat;
  Result := StrToFloat(S);

end;

function GetToken(var InTxt : String; const sep: Char): String;
var
  i: Integer;
begin

  i := 1;
  while (i <= Length(InTxt)) and not (InTxt[i] = sep) do INC(i);

  Result := Copy(InTxt, 1, i-1);
  Delete(InTxt, 1, i);

  i := 1;
  while (i <= Length(InTxt)) and (InTxt[i] = sep) do INC(i);
  Delete(InTxt, 1, i-1);

end;

{ TOBJModel }

procedure TOBJModel.CalculateBounds;
var
  v, i: Integer;
begin

  // Calculate the model's bounding box.
  FExtMin := Vertices[0];
  FExtMax := FExtMin;

  for v := 0 to High(Vertices) do
  begin
    for i := 0 to 2 do
    begin
      if Vertices[v].xyz[i] < FExtMin.xyz[i] then FExtMin.xyz[i] := Vertices[v].xyz[i];
      if Vertices[v].xyz[i] > FExtMax.xyz[i] then FExtMax.xyz[i] := Vertices[v].xyz[i];
    end;
  end;

end;

function policz(gdzie:string; co:char):integer;
var a:integer;
begin
result:=0;
for a:=1 to length(gdzie) do if gdzie[a]=co then inc(result);
end;

procedure TOBJModel.LoadFromFile(filename: String; skala:real=1);
var
  f: TStringList;
  ln: String;
  lnnumber: Integer;
  token, t2: String;
  i, ile,a,b: Integer;
  groupcount: Integer;

  vx_min,vx_max, vy_min,vy_max, vz_min,vz_max :real;

begin

  StringToFloat := StrToFloat_sep;

  // Load a mesh from file.
  f := TStringList.Create;
  try
     f.LoadFromFile(filename);
  except
     messagebox(0,pchar('Nie wczytano obiektu! '+filename),'ERROR',MB_OK);
     Application.Terminate;
     halt(0);
     exit;
  end;

  SetLength(Groups, Length(Groups) + 1);
  with Groups[High(Groups)] do
  begin
    Name := 'Unnamed group';
    Texture := 0;
  end;
  groupcount := 0;

  lnnumber := 0;
  ln := f[lnnumber];
  while lnnumber < f.Count do
  begin
    // Find group header:
    token := GetToken(ln, ' ');
    if (token = '#') or (token = '') then
    begin
      INC(lnnumber);
      ln := f[lnnumber];
      Continue;
    end;

    // Get the group name.
    if token = 'g' then
    begin
      if groupcount > 0 then begin
         with Groups[High(Groups)] do
         begin
            vx_min:=Vertices[Faces[0].XYZ[0]].x;
            vx_max:=Vertices[Faces[0].XYZ[0]].x;
            vy_min:=Vertices[Faces[0].XYZ[0]].y;
            vy_max:=Vertices[Faces[0].XYZ[0]].y;
            vz_min:=Vertices[Faces[0].XYZ[0]].z;
            vz_max:=Vertices[Faces[0].XYZ[0]].z;
            for a:=0 to high(Faces) do begin
              for b:=0 to 2 do begin
                if Vertices[Faces[a].XYZ[b]].x<vx_min then vx_min:=Vertices[Faces[a].XYZ[b]].x;
                if Vertices[Faces[a].XYZ[b]].x>vx_max then vx_max:=Vertices[Faces[a].XYZ[b]].x;
                if Vertices[Faces[a].XYZ[b]].y<vy_min then vy_min:=Vertices[Faces[a].XYZ[b]].y;
                if Vertices[Faces[a].XYZ[b]].y>vy_max then vy_max:=Vertices[Faces[a].XYZ[b]].y;
                if Vertices[Faces[a].XYZ[b]].z<vz_min then vz_min:=Vertices[Faces[a].XYZ[b]].z;
                if Vertices[Faces[a].XYZ[b]].z>vz_max then vz_max:=Vertices[Faces[a].XYZ[b]].z;
              end;
            end;
            srx:=(vx_max-vx_min)/2+vx_min;
            sry:=(vy_max-vy_min)/2+vy_min;
            srz:=(vz_max-vz_min)/2+vz_min;
         end;


         SetLength(Groups, Length(Groups) + 1);
      end;
      INC(groupcount);
      with Groups[High(Groups)] do
      begin
        Name := Trim(ln);
        Texture := 0;
      end;
    end;

    with Groups[High(Groups)] do
    begin
      // Read vertices and shit.
      INC(lnnumber);
      ln := f[lnnumber];
      token := GetToken(ln, ' ');
      while (CompareText(token, 'v') = 0) or
            (CompareText(token, 'vt') = 0) or
            (CompareText(token, 'vn') = 0) or
            (CompareText(token, 'f') = 0) or
            (CompareText(token, 'usemtl') = 0) or
            (token = '#') or
            ((token = '') and (lnnumber < f.Count)) do
      begin
        // Vertex?
        if (CompareText(token, 'v') = 0) then
        begin
          SetLength(Vertices, Length(Vertices) + 1);
          with Vertices[High(Vertices)] do
          begin
            token := GetToken(ln, ' ');
            x := StringToFloat(token) * skala;
            token := GetToken(ln, ' ');
            y := StringToFloat(token) * skala;
            token := GetToken(ln, ' ');
            z := StringToFloat(token) * skala;
          end;
        end
        // Texcoord?
        else if (CompareText(token, 'vt') = 0) then
        begin
          SetLength(TexCoords, Length(TexCoords) + 1);
          with TexCoords[High(TexCoords)] do
          begin
            token := GetToken(ln, ' ');
            u := StringToFloat(token);
            token := GetToken(ln, ' ');
            v := StringToFloat(token);
          end;
        end
        // Normal?
        else if (CompareText(token, 'vn') = 0) then
        begin
          SetLength(Normals, Length(Normals) + 1);
          with Normals[High(Normals)] do
          begin
            token := GetToken(ln, ' ');
            x := StringToFloat(token);
            token := GetToken(ln, ' ');
            y := StringToFloat(token);
            token := GetToken(ln, ' ');
            z := StringToFloat(token);
          end;
        end
        // Face?
        else if (CompareText(token, 'f') = 0) then
        begin
          SetLength(Faces, Length(Faces) + 1);
          with Faces[High(Faces)] do
          begin
            for i := 0 to 2 do
            begin
              { If a face does not contain an XYZ, texcoord or normal index, the
                value $FFFFFFFF will be stored instead. Applications should
                check for this value before using the indices. }
              token := GetToken(ln, ' ');

              ile:=policz(token,'/');

              t2 := GetToken(token, '/');
              try XYZ[i] := StrToInt(t2) - 1;
                  Normal[i] := StrToInt(t2) - 1;
              except
                XYZ[i] := $FFFFFFFF;   // Let's pray that nobody creates a mesh with 2^32 vertices!
              end;

              t2 := GetToken(token, '/');
              try UV[i] := StrToInt(t2) - 1;
              except
                UV[i] := $FFFFFFFF;
              end;

              if ile>=2 then begin
                  t2 := GetToken(token, '/');
                  try Normal[i] := StrToInt(t2) - 1;
                  except
                    Normal[i] := $FFFFFFFF;
                  end;
              end;
            end;
          end;
        end;

        INC(lnnumber);
        if lnnumber < f.Count then ln := f[lnnumber];
        token := GetToken(ln, ' ');
      end;
      ln := token + ' ' + ln;
    end;
  end;

  f.Free;

end;

function TOBJModel.ToDisplayList: GLuint;
var
  lst: GLuint;
  g, f, v: Integer;
begin

  // Compile the model into a display list.
  lst := glGenLists(1);
  glNewList(lst, GL_COMPILE);
    for g := 0 to High(Groups) do
    begin
      with Groups[g] do
      begin
        glBindTexture(GL_TEXTURE_2D, Texture);
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
      end;
    end;
  glEndList;
  Result := lst;

end;

end.
