unit ZGLColors;

interface
uses
  Classes,
  Variants,
  ZGLMathProcsSimple;

function MakeColor(r, g, b, rndSeed: integer): Cardinal;

implementation

function MakeColor(r, g, b, rndSeed: integer): Cardinal;
var
  brightness: integer;
begin
  brightness := random(rndSeed);
  r := KeepValBetween(r + brightness, 0, 255);
  g := KeepValBetween(g + brightness, 0, 255);
  b := KeepValBetween(b + brightness, 0, 255);

  result := $FF000000 or
          r shl 16 or
          g shl 8 or
          b;
end;


end.
