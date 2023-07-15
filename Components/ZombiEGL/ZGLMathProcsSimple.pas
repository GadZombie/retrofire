unit ZGLMathProcsSimple;

interface

function KeepValBetween(val: Variant; minVal, maxVal: Variant): Variant;
function AddValUpTo(val: Variant; addVal, maxVal: Variant): Variant;
function SubValDownTo(val: Variant; subVal, minVal: Variant): Variant;

function IsValBetween(val: Variant; minVal, maxVal: Variant): boolean;

implementation

//---------------------------------------------------------------------------
{
}
function KeepValBetween(val: Variant; minVal, maxVal: Variant): Variant;
begin
  if val < minVal then
    val := minVal;
  if val > maxVal then
    val := maxVal;
  result := val;
end;

//---------------------------------------------------------------------------
{
}
function IsValBetween(val: Variant; minVal, maxVal: Variant): boolean;
begin
  result := (val >= minVal) and (val <= maxVal);
end;

//---------------------------------------------------------------------------
{
}
function AddValUpTo(val: Variant; addVal, maxVal: Variant): Variant;
begin
  result := val + addVal;
  if Result > maxVal then
    Result := maxVal;
end;

//---------------------------------------------------------------------------
{
}
function SubValDownTo(val: Variant; subVal, minVal: Variant): Variant;
begin
  result := val - subVal;
  if Result < minVal then
    Result := minVal;
end;

end.
