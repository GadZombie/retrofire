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

//Wylicza pozycjê punku po dowolnej transformacji
//Dopuszczalne pierwsze przesuniêcie StartPosition lub mo¿na pomin¹æ wstawiaj¹c Cev3DZero
//NeededPosition - pozycja wzglêdem œrodka uk³adu, która jest szukana po transformacji
//TransformedPosition - wyliczona pozycja po transformacji
//TransformProc - zwyk³a procedura z transformacjami w œrodku: glTranslate, glRotate, glScale
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
