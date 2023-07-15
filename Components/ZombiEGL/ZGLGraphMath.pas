unit ZGLGraphMath;

interface
uses
  GL, GLU,
  ZGLMathProcs;

type
  TTransformProc = reference to procedure ();


  function GetCurrentCoordsFromModelMatrix: TVec3D;

  procedure GetTransformedPosition(StartPosition, NeededPosition: TVec3D;
    out TransformedPosition: TVec3D; TransformProc: TTransformProc);


implementation


function GetCurrentCoordsFromModelMatrix: TVec3D;
var
  TransMatrix: array[0..15] of GLFloat;
begin
  glGetFloatv(GL_MODELVIEW_MATRIX, @TransMatrix);
  result.x := TransMatrix[12];
  result.y := TransMatrix[13];
  result.z := TransMatrix[14];
end;

//Wylicza pozycj� punku po dowolnej transformacji
//Dopuszczalne pierwsze przesuni�cie StartPosition lub mo�na pomin�� wstawiaj�c Cev3DZero
//NeededPosition - pozycja wzgl�dem �rodka uk�adu, kt�ra jest szukana po transformacji
//TransformedPosition - wyliczona pozycja po transformacji
//TransformProc - zwyk�a procedura z transformacjami w �rodku: glTranslate, glRotate, glScale
procedure GetTransformedPosition(StartPosition, NeededPosition: TVec3D;
  out TransformedPosition: TVec3D; TransformProc: TTransformProc);
begin
  glPushMatrix;
    glLoadIdentity;

    glTranslatef(StartPosition.x, StartPosition.y, StartPosition.z);

    TransformProc();

    glTranslatef(NeededPosition.x, NeededPosition.y, NeededPosition.z);

    TransformedPosition := GetCurrentCoordsFromModelMatrix;

  glPopMatrix;
end;



end.
