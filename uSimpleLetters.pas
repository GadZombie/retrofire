unit uSimpleLetters;

interface
uses
  System.Generics.Collections;

type
  TSimpleLine = record
    x1, y1, x2, y2: extended;
  end;

  TSimpleLetter = class
  private
    FLines: TList<TSimpleLine>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddLine(x1, y1, x2, y2: extended);
    function GetLength: integer;
    property Lines: TList<TSimpleLine> read FLines;
  end;

  TSimpleLetters = class
  private
    FList: TObjectList<TSimpleLetter>;

    procedure CreateE;
    procedure CreateN;
    procedure CreateS;
    procedure CreateW;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw(AChar: Char; x, y, z, size: extended);
  end;

implementation
uses
  GL;

constructor TSimpleLetters.Create;
var
  i: integer;
begin
  inherited Create;

  FList := TObjectList<TSimpleLetter>.Create;

  for i := 1 to 4 do
    FList.Add(nil);
  CreateE;
  for i := 6 to 13 do
    FList.Add(nil);
  CreateN;
  for i := 15 to 18 do
    FList.Add(nil);
  CreateS;
  for i := 20 to 22 do
    FList.Add(nil);
  CreateW;
  for i := 24 to 26 do
    FList.Add(nil);
end;

{ TSimpleLetter }

procedure TSimpleLetter.AddLine(x1, y1, x2, y2: extended);
var
  pt: TSimpleLine;
begin
  pt.x1 := x1;
  pt.y1 := y1;
  pt.x2 := x2;
  pt.y2 := y2;
  FLines.Add(pt);
end;

constructor TSimpleLetter.Create;
begin
  inherited;
  FLines := TList<TSimpleLine>.Create;
end;

destructor TSimpleLetter.Destroy;
begin
  FLines.Free;
  inherited;
end;

function TSimpleLetter.GetLength: integer;
begin
  result := FLines.Count;
end;

procedure TSimpleLetters.CreateE;
var
  letter: TSimpleLetter;
begin
  letter := TSimpleLetter.Create;
  letter.AddLine(1, 1, 0, 1);
  letter.AddLine(0, 1, 0, 0);
  letter.AddLine(0, 0, 1, 0);
  letter.AddLine(0, 0.5, 0.6, 0.5);
  FList.Add(letter);
end;

procedure TSimpleLetters.CreateN;
var
  letter: TSimpleLetter;
begin
  letter := TSimpleLetter.Create;
  letter.AddLine(0, 0, 0, 1);
  letter.AddLine(0, 1, 1, 0);
  letter.AddLine(1, 0, 1, 1);
  FList.Add(letter);
end;

procedure TSimpleLetters.CreateS;
var
  letter: TSimpleLetter;
begin
  letter := TSimpleLetter.Create;
  letter.AddLine(1, 1, 0.2, 1);
  letter.AddLine(0.2, 1, 0, 0.75);
  letter.AddLine(0, 0.75, 0.2, 0.5);
  letter.AddLine(0.2, 0.5, 0.8, 0.5);
  letter.AddLine(0.8, 0.5, 1, 0.25);
  letter.AddLine(1, 0.25, 0.8, 0);
  letter.AddLine(0.8, 0, 0, 0);
  FList.Add(letter);
end;

procedure TSimpleLetters.CreateW;
var
  letter: TSimpleLetter;
begin
  letter := TSimpleLetter.Create;
  letter.AddLine(0, 1, 0.2, 0);
  letter.AddLine(0.2, 0, 0.5, 0.8);
  letter.AddLine(0.5, 0.8, 0.8, 0);
  letter.AddLine(0.8, 0, 1, 1);
  FList.Add(letter);
end;

destructor TSimpleLetters.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TSimpleLetters.Draw(AChar: Char; x, y, z, size: extended);
var
  letter: TSimpleLetter;
  n, a: integer;
begin
  n := Ord(AChar) - 65;
  if (n < 0) or (n >= FList.Count) then
    exit;

  letter := FList.Items[n];

  for a := 0 to letter.GetLength - 1 do
  begin
    glBegin(GL_LINES);
      glVertex3f(x + (letter.Lines[a].x1 - 0.5) * size, y + (letter.Lines[a].y1 - 0.5) * size, z);
      glVertex3f(x + (letter.Lines[a].x2 - 0.5) * size, y + (letter.Lines[a].y2 - 0.5) * size, z);
    glEnd();
  end;

end;

end.
