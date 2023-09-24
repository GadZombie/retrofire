unit uGameMath;

interface

type
  TGameMath = class
  public
    class function ToScreenX(x: extended): extended;
    class function ToScreenZ(z: extended): extended;
  end;

implementation
uses
  GlobalTypes, GlobalConsts, unittimer;


{ TGameMath }

class function TGameMath.ToScreenX(x: extended): extended;
begin
  if abs(x - gracz.x) > abs(ziemia.px) then
  begin
    if x < 0 then
      result := x + abs(ziemia.px * 2)
    else
      result := x - abs(ziemia.px * 2);
  end
    else
      result := x;
end;

class function TGameMath.ToScreenZ(z: extended): extended;
begin
  if abs(z - gracz.z) > abs(ziemia.pz) then
  begin
    if z < 0 then
      result := z + abs(ziemia.pz * 2)
    else
      result := z - abs(ziemia.pz * 2);
  end
    else
      result := z;
end;

end.
