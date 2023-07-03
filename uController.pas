unit uController;

interface
uses
  System.Generics.Collections,
  SysUtils,
  PowerInputs,
  System.JSON;

const
  JoyPOV_Up = 0;
  JoyPOV_UpRight = 4500;
  JoyPOV_Right = 9000;
  JoyPOV_DownRight = 9000 + 4500;
  JoyPOV_Down = 18000;
  JoyPOV_DownLeft = 18000 + 4500;
  JoyPOV_Left = 27000;
  JoyPOV_UpLeft = 27000 + 4500;

type
  TJoyAnalogType = (
    anNotUsed,

    anXAxisL,
    anYAxisL,
    anZAxisL,
    anXAxisR,
    anYAxisR,
    anZAxisR, //pierwsza ga³ka

    anXAxisVL,
    anYAxisVL,
    anZAxisVL,
    anXAxisVR,
    anYAxisVR,
    anZAxisVR, //druga ga³ka V

    anXAxisAL,
    anYAxisAL,
    anZAxisAL,
    anXAxisAR,
    anYAxisAR,
    anZAxisAR, //trzecia ga³ka A

    anXAxisFL,
    anYAxisFL,
    anZAxisFL,
    anXAxisFR,
    anYAxisFR,
    anZAxisFR  //czwarta ga³ka F
    );

  TJoyControlType = (jctNone, jctAnalog, jctButton, jctPOV);

  TAnalogActiveType = (aatBoth, aatPositive, aatNegative);

  TPOVValue = (povUp, povRight, povDown, povLeft);
  TPOVValues = set of TPOVValue;

  TControlValue = record
    Value: integer;
    Analog: boolean;
  end;

  TGameControlJoy = class
  public
    JoyNum: integer;
    AnalogType: TJoyAnalogType;
    ControlType: TJoyControlType;
    Button: integer;
    POVid: integer;
    POVValue: integer;
    Inverse: boolean;

    procedure SetJoyAnalog(joyNum: integer; JoyAnalogControl: TJoyAnalogType; Inverse: boolean);
    procedure SetJoyButton(joyNum: integer; JoyButton: integer);
    procedure SetJoyPOV(joyNum: integer; POVid, POVvalue: integer);
    procedure SetJoyNone(joyNum: integer);

    function AsJson: TJSONObject;
    procedure FromJson(sourceData: TJSONValue);
  end;

  TGameControl = class
  private
    Input: TPowerInput;
    key: byte;
    joy: TGameControlJoy;
    DeadZone: integer;

    function IsPOVValue(testValue, neededValue: integer): boolean;
    function GetPOVValue(JoyNum, POVid: integer): integer;
  public
    name: string;

    constructor Create(Input: TPowerInput);
    destructor Destroy; override;

    procedure SetKey(key: byte);
    procedure SetJoyAnalog(joyNum: integer; JoyAnalogControl: TJoyAnalogType; Inverse: boolean);
    procedure SetJoyButton(joyNum: integer; JoyButton: integer);
    procedure SetJoyPOV(joyNum: integer; POVid, POVvalue: integer);
    procedure SetJoyNone(joyNum: integer);

    function GetKeyAsString: string;
    function GetJoyAsString: string;
    function GetAsString: string;

    function Active(AnalogActiveType: TAnalogActiveType = aatBoth): boolean;
    function Value: TControlValue;
    function IsAnalog: boolean;
    function Pressed: boolean;

    function GetAnalogValue(JoyNum: integer; AnalogType: TJoyAnalogType; DeadZone: integer): integer;
    function GetPOVValues(JoyNum, POVid: integer): TPOVValues;
    function GetButtonValue(JoyNum, Button: integer): integer;
    function JoyAvailable(JoyNum: integer): boolean;
    function IsAnalogInversed: boolean;

    function AsJson: TJSONObject;
    procedure FromJson(sourceData: TJSONValue);

    function JoyNum: integer;
    procedure SetDeadZone(DeadZone: integer);
  end;

  TGameController = class
  private
    ControlList: TObjectList<TGameControl>;
    FDeadZone: integer;
    Input: TPowerInput;

    function ControlListAsJson: TJSONArray;
    procedure ControlListFromJson(sourceData: TJSONArray);
    procedure SetDeadZone(Value: integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetInput(input: TPowerInput);
    procedure Clear;
    procedure AddControl(name: string);

    function Control(index: integer): TGameControl;
    function Count: integer;

    function GetKeyPressed: byte;
    procedure GetJoyPressed(out ControlType: TJoyControlType; out AnalogType: TJoyAnalogType; out Button: integer; out POVid, POVvalue: integer);

    function JoyAvailable(JoyNum: integer): boolean;
    function GetJoyCount: integer;
    function GetJoyButtonsCount: integer;
    function GetJoyPOVCount: integer;

    function AsJson: TJSONObject;
    procedure FromJson(sourceData: TJSONValue);

    property DeadZone: integer read FDeadZone write SetDeadZone;
    function CalculatedDeadZone: integer;
  end;

implementation

{ TGameControl }

function TGameControl.Active(AnalogActiveType: TAnalogActiveType = aatBoth): boolean;
var
  cval: TControlValue;
begin
  result := false;
  cval := Value;
  if cval.Analog then
  begin
    case AnalogActiveType of
      aatBoth:
        result := cval.Value <> 0;
      aatPositive:
        result := cval.Value > 0;
      aatNegative:
        result := cval.Value < 0;
    end;
  end
  else
  begin
    result := cval.Value <> 0;
  end;
end;

function TGameControl.AsJson: TJSONObject;
begin
  result := TJSONObject.Create;
  result.AddPair('Key', TJSONNumber.Create(key));
  result.AddPair('Joy', joy.AsJson);
end;

constructor TGameControl.Create(Input: TPowerInput);
begin
  inherited Create;
  key := 0;
  joy := TGameControlJoy.Create;
  self.Input := Input;
  self.joy.SetJoyNone(0);
end;

destructor TGameControl.Destroy;
begin
  joy.Free;

  inherited;
end;

procedure TGameControl.FromJson(sourceData: TJSONValue);
begin
//  result := TJSONObject.Create;
//  result.AddPair('Key', TJSONNumber.Create(key));
//  result.AddPair('Joy', joy.AsJson);
  key := sourceData.GetValue<Integer>('Key');
  joy.FromJson(sourceData.GetValue<TJSONValue>('Joy'));
end;

function TGameControl.GetJoyAsString: string;
var
  s: string;
begin
  case joy.controlType of
    jctAnalog:
    begin
      case joy.analogType of
        anXAxisL: result := 'X-Axis position';
        anYAxisL: result := 'Y-Axis position';
        anZAxisL: result := 'Z-Axis position';

        anXAxisR: result := 'X-Axis rotation';
        anYAxisR: result := 'Y-Axis rotation';
        anZAxisR: result := 'Z-Axis rotation';

        anXAxisVL: result := 'X-Axis velocity';
        anYAxisVL: result := 'Y-Axis velocity';
        anZAxisVL: result := 'Z-Axis velocity';

        anXAxisVR: result := 'X-Axis angular velocity';
        anYAxisVR: result := 'Y-Axis angular velocity';
        anZAxisVR: result := 'Z-Axis angular velocity';

        anXAxisAL: result := 'X-Axis acceleration';
        anYAxisAL: result := 'Y-Axis acceleration';
        anZAxisAL: result := 'Z-Axis acceleration';

        anXAxisAR: result := 'X-Axis angular acceleration';
        anYAxisAR: result := 'Y-Axis angular acceleration';
        anZAxisAR: result := 'Z-Axis angular acceleration';

        anXAxisFL: result := 'X-Axis force';
        anYAxisFL: result := 'Y-Axis force';
        anZAxisFL: result := 'Z-Axis force';

        anXAxisFR: result := 'X-Axis torque';
        anYAxisFR: result := 'Y-Axis torque';
        anZAxisFR: result := 'Z-Axis torque';
      end;

      if joy.Inverse then
        result := result + ' (inverse)';

    end;
    jctButton:
    begin
      result := Format('Button %d', [joy.button + 1]);
    end;
    jctPOV:
    begin
      case joy.POVValue of
        JoyPOV_Up: s := 'Up';
        JoyPOV_Down: s := 'Down';
        JoyPOV_Right: s := 'Right';
        JoyPOV_Left: s := 'Left';
        else
          s := '?';
      end;
      result := Format('POV %d: %s', [joy.POVid + 1, s]);
    end;
    jctNone:
    begin
      result := 'Not used';
    end;
  end;
end;

function TGameControl.GetKeyAsString: string;
begin
  if key = 0 then
    result := 'Not used'
  else
    result := Input.KeyName[key];
end;

function TGameControl.GetAsString: string;
begin
  if key <> 0 then
    result := GetKeyAsString
  else
    result := '';

  if joy.controlType <> jctNone then
  begin
    if result <> '' then
      result := result + ' or ';
    result := result + GetJoyAsString;
  end;
end;


procedure TGameControl.SetDeadZone(DeadZone: integer);
begin
  self.DeadZone := DeadZone;
end;

procedure TGameControl.SetJoyAnalog(joyNum: integer;
  JoyAnalogControl: TJoyAnalogType; Inverse: boolean);
begin
  joy.SetJoyAnalog(joyNum, JoyAnalogControl, Inverse);
end;

procedure TGameControl.SetJoyButton(joyNum, JoyButton: integer);
begin
  joy.SetJoyButton(joyNum, JoyButton);
end;

procedure TGameControl.SetJoyNone(joyNum: integer);
begin
  joy.SetJoyNone(joyNum);
end;

procedure TGameControl.SetJoyPOV(joyNum, POVid, POVvalue: integer);
begin
  joy.SetJoyPOV(joyNum, POVid, POVvalue);
end;

procedure TGameControl.SetKey(key: byte);
begin
  Self.key := key;
end;

function TGameControl.IsAnalog: boolean;
var
  valResult: TControlValue;
begin
  valResult := Value;
  result := (joy.JoyNum < Input.JoystickCount) and (joy.ControlType = jctAnalog) and (valResult.Value <> 0) and (valResult.Analog);
end;

function TGameControl.IsAnalogInversed: boolean;
begin
  result := joy.Inverse;
end;

function TGameControl.IsPOVValue(testValue, neededValue: integer): boolean;
begin
  if (neededValue = JoyPOV_Up) and
      ((testValue = JoyPOV_Up) or (testValue = JoyPOV_UpRight) or (testValue = JoyPOV_UpLeft)) then
    result := true
  else
  if (neededValue = JoyPOV_Right) and
      ((testValue = JoyPOV_Right) or (testValue = JoyPOV_UpRight) or (testValue = JoyPOV_DownRight)) then
    result := true
  else
  if (neededValue = JoyPOV_Down) and
      ((testValue = JoyPOV_Down) or (testValue = JoyPOV_DownRight) or (testValue = JoyPOV_DownLeft)) then
    result := true
  else
  if (neededValue = JoyPOV_Left) and
      ((testValue = JoyPOV_Left) or (testValue = JoyPOV_UpLeft) or (testValue = JoyPOV_DownLeft)) then
    result := true
  else
    result := false;
end;

function TGameControl.JoyAvailable(JoyNum: integer): boolean;
begin
  result := Input.JoystickCount >= JoyNum + 1;
end;

function TGameControl.JoyNum: integer;
begin
  result := joy.JoyNum;
end;

function TGameControl.Pressed: boolean;
begin
  result := false;
  if key > 0 then
    result := Input.KeyPressed[key];
end;

function TGameControl.Value: TControlValue;
begin
  result.Value := 0;
  result.Analog := false;

  if key > 0 then
  begin
    if Input.Keys[key] then
    begin
      result.Value := 1;
      result.Analog := false;
      exit;
    end;
  end;

  if joy.JoyNum < Input.JoystickCount then
  begin
    case joy.ControlType of
      jctNone: ;
      jctAnalog:
      begin
        result.Analog := true;
        result.Value := GetAnalogValue(joy.JoyNum, joy.analogType, DeadZone);
        if joy.Inverse then
          result.Value := -result.Value;
      end;
      jctButton:
      begin
        result.Value := GetButtonValue(joy.JoyNum, joy.Button);
        result.Analog := false;
      end;
      jctPOV:
      begin
        if IsPOVValue(GetPOVValue(joy.JoyNum, joy.POVid), joy.POVValue) then
        begin
          result.Value := 1;
          result.Analog := false;
        end;
      end;

    end;

    exit;
  end;

end;

function TGameControl.GetPOVValue(JoyNum: integer; POVid: integer): integer;
begin
  if not JoyAvailable(JoyNum) then
    exit(0);

  result := Input.Joystick[JoyNum].DIJoyState2.rgdwPOV[POVid];
end;

function TGameControl.GetPOVValues(JoyNum, POVid: integer): TPOVValues;
var
  tmpValue: integer;
begin
  if not JoyAvailable(JoyNum) then
    exit([]);

  tmpValue := GetPOVValue(JoyNum, POVid);

  result := [];

  if IsPOVValue(tmpValue, JoyPOV_Up) then
    result := result + [TPOVValue.povUp];
  if IsPOVValue(tmpValue, JoyPOV_Right) then
    result := result + [TPOVValue.povRight];
  if IsPOVValue(tmpValue, JoyPOV_Down) then
    result := result + [TPOVValue.povDown];
  if IsPOVValue(tmpValue, JoyPOV_Left) then
    result := result + [TPOVValue.povLeft];
end;

function TGameControl.GetButtonValue(JoyNum: integer; Button: integer): integer;
begin
  result := Input.Joystick[JoyNum].DIJoyState2.rgbButtons[Button];
end;

function TGameControl.GetAnalogValue(JoyNum: integer; AnalogType: TJoyAnalogType; DeadZone: integer): integer;
var
  maxValue: integer;
begin
  result := 0;
  if not JoyAvailable(JoyNum) then
    exit(0);

  case AnalogType of
    anNotUsed: result := 0;

    anXAxisL: result := Input.Joystick[JoyNum].DIJoyState2.lX;
    anYAxisL: result := Input.Joystick[JoyNum].DIJoyState2.lY;
    anZAxisL: result := Input.Joystick[JoyNum].DIJoyState2.lZ;

    anXAxisR: result := Input.Joystick[JoyNum].DIJoyState2.lRx;
    anYAxisR: result := Input.Joystick[JoyNum].DIJoyState2.lRy;
    anZAxisR: result := Input.Joystick[JoyNum].DIJoyState2.lRz;

    anXAxisVL: result := Input.Joystick[JoyNum].DIJoyState2.lVX;
    anYAxisVL: result := Input.Joystick[JoyNum].DIJoyState2.lVY;
    anZAxisVL: result := Input.Joystick[JoyNum].DIJoyState2.lVZ;

    anXAxisVR: result := Input.Joystick[JoyNum].DIJoyState2.lVRx;
    anYAxisVR: result := Input.Joystick[JoyNum].DIJoyState2.lVRy;
    anZAxisVR: result := Input.Joystick[JoyNum].DIJoyState2.lVRz;

    anXAxisAL: result := Input.Joystick[JoyNum].DIJoyState2.lAX;
    anYAxisAL: result := Input.Joystick[JoyNum].DIJoyState2.lAY;
    anZAxisAL: result := Input.Joystick[JoyNum].DIJoyState2.lAZ;

    anXAxisAR: result := Input.Joystick[JoyNum].DIJoyState2.lARx;
    anYAxisAR: result := Input.Joystick[JoyNum].DIJoyState2.lARy;
    anZAxisAR: result := Input.Joystick[JoyNum].DIJoyState2.lARz;

    anXAxisFL: result := Input.Joystick[JoyNum].DIJoyState2.lFX;
    anYAxisFL: result := Input.Joystick[JoyNum].DIJoyState2.lFY;
    anZAxisFL: result := Input.Joystick[JoyNum].DIJoyState2.lFZ;

    anXAxisFR: result := Input.Joystick[JoyNum].DIJoyState2.lFRx;
    anYAxisFR: result := Input.Joystick[JoyNum].DIJoyState2.lFRy;
    anZAxisFR: result := Input.Joystick[JoyNum].DIJoyState2.lFRz;
  end;

  if DeadZone > 0 then
  begin
    if abs(result) < DeadZone then
      result := 0
    else
    begin
      maxValue := High(SmallInt);
    // deadzone = 10000
    // maxval = (32768 - 10000) = 22768
    // value = 16000 //odczytana pozycja
    // value = value * (32768 / maxval) =
      if result >= 0 then
        result := trunc((result - DeadZone) * (maxValue / (maxValue - DeadZone)))
      else
        result := - abs(trunc( (abs(result) - DeadZone) * (maxValue / (maxValue - DeadZone))) );
    end;
  end;
end;

{ TGameController }

procedure TGameController.AddControl(name: string);
var
  tmp: TGameControl;
begin
  tmp := TGameControl.Create(Input);
  tmp.name := name;
  tmp.DeadZone := CalculatedDeadZone;
  ControlList.Add(tmp);
end;

function TGameController.AsJson: TJSONObject;
begin
  result := TJSONObject.Create;
  result.AddPair('ControlList', ControlListAsJson);
  result.AddPair('DeadZone', TJSONNumber.Create(DeadZone));
end;

procedure TGameController.FromJson(sourceData: TJSONValue);
begin
  ControlListFromJson(sourceData.GetValue<TJSONArray>('ControlList'));
  DeadZone := sourceData.GetValue<Integer>('DeadZone');
end;

function TGameController.CalculatedDeadZone: integer;
var
  maxDeadZone: integer;
begin
  maxDeadZone := high(smallint);
  result := (FDeadZone * maxDeadZone) div 100;
end;

procedure TGameController.Clear;
begin
  ControlList.Clear;
end;

function TGameController.Control(index: integer): TGameControl;
begin
  if (index >= 0) and (index <= ControlList.Count - 1) then
    result := ControlList.Items[index]
  else
    raise Exception.Create('Control index not found');
end;

function TGameController.ControlListAsJson: TJSONArray;
var
  element: TGameControl;
begin
  result := TJSONArray.Create;
  for element in ControlList do
  begin
    result.AddElement(element.AsJson);
  end;
end;

procedure TGameController.ControlListFromJson(sourceData: TJSONArray);
var
  a: integer;
  element: TGameControl;
begin
  for a := 0 to ControlList.Count - 1 do
  begin
    element := ControlList.Items[a];
    if a <= sourceData.Count - 1 then
      element.FromJson(sourceData.Items[a]);
  end;
end;

function TGameController.Count: integer;
begin
  result := ControlList.Count;
end;

constructor TGameController.Create;
begin
  inherited;
  ControlList := TObjectList<TGameControl>.Create;
end;

destructor TGameController.Destroy;
begin
  ControlList.Free;
  inherited;
end;

function TGameController.GetKeyPressed: byte;
var
  a: integer;
begin
  result := 0;
  a := 2; //0 = brak, 1 = esc
  while a <= 255 do
  begin
    if Input.Keys[a] then
    begin
      result := a;
      break;
    end;
    inc(a);
  end;
end;

function TGameController.GetJoyButtonsCount: integer;
var
  joyNum: integer;
begin
  joyNum := 0;
  if not JoyAvailable(joyNum) then
    exit(0);
  result := Input.Joystick[joyNum].ButtonCount;
end;

function TGameController.GetJoyPOVCount: integer;
var
  joyNum: integer;
begin
  joyNum := 0;
  if not JoyAvailable(joyNum) then
    exit(0);
  result := Input.Joystick[joyNum].POVCount;
end;

function TGameController.GetJoyCount: integer;
begin
  result := Input.JoystickCount;
end;

function TGameController.JoyAvailable(JoyNum: integer): boolean;
begin
  result := Input.JoystickCount >= JoyNum + 1;
end;

procedure TGameController.GetJoyPressed(out ControlType: TJoyControlType; out AnalogType: TJoyAnalogType; out Button: integer; out POVid, POVvalue: integer);
var
  a, joyNum, tmpPovValue: integer;
begin
  joyNum := 0;

  ControlType := jctNone;

  if not JoyAvailable(joyNum) then
    exit;

  if abs(Input.Joystick[joyNum].DIJoyState2.lX) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anXAxisL;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lY) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anYAxisL;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lZ) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anZAxisL;
  end
  else

  if abs(Input.Joystick[joyNum].DIJoyState2.lrX) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anXAxisR;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lrY) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anYAxisR;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lrZ) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anZAxisR;
  end
  else

  if abs(Input.Joystick[joyNum].DIJoyState2.lVX) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anXAxisVL;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lVY) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anYAxisVL;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lVZ) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anZAxisVL;
  end
  else

  if abs(Input.Joystick[joyNum].DIJoyState2.lvrX) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anXAxisVR;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lvrY) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anYAxisVR;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lvrZ) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anZAxisVR;
  end
  else

  if abs(Input.Joystick[joyNum].DIJoyState2.lAX) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anXAxisAL;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lAY) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anYAxisAL;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lAZ) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anZAxisAL;
  end
  else


  if abs(Input.Joystick[joyNum].DIJoyState2.lARx) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anXAxisAR;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lARy) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anYAxisAR;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lARZ) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anZAxisAR;
  end
  else

  if abs(Input.Joystick[joyNum].DIJoyState2.lFX) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anXAxisFL;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lFY) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anYAxisFL;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lFz) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anZAxisFL;
  end
  else

  if abs(Input.Joystick[joyNum].DIJoyState2.lFrX) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anXAxisFR;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lFry) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anYAxisFR;
  end
  else
  if abs(Input.Joystick[joyNum].DIJoyState2.lFrz) > CalculatedDeadZone then
  begin
    ControlType := jctAnalog;
    AnalogType := anZAxisFR;
  end
  else
  begin
    for a := 0 to Input.Joystick[joyNum].ButtonCount - 1 do
      if Input.Joystick[joyNum].DIJoyState2.rgbButtons[a] > 0 then
      begin
        ControlType := jctButton;
        Button := a;
      end;
  end;

  if ControlType = jctNone then
  begin
    for a := 0 to Input.Joystick[joyNum].POVCount - 1 do
    begin
      if a > 3 then //zabezpieczenie
        break;

      tmpPovValue := Input.Joystick[joyNum].DIJoyState2.rgdwPOV[a];
      if (tmpPovValue = JoyPOV_Up) or (tmpPovValue = JoyPOV_Right) or (tmpPovValue = JoyPOV_Down) or (tmpPovValue = JoyPOV_Left) then
      begin
        ControlType := jctPOV;
        POVid := a;
        POVvalue := tmpPovValue;
      end;
    end;
  end;

end;

procedure TGameController.SetDeadZone(Value: integer);
var
  GameControl: TGameControl;
begin
  FDeadZone := Value;
  for GameControl in ControlList do
    GameControl.SetDeadZone(CalculatedDeadZone);
end;

procedure TGameController.SetInput(input: TPowerInput);
begin
  self.Input := input;
end;

{ TGameControlJoy }

function TGameControlJoy.AsJson: TJSONObject;
begin
  result := TJSONObject.Create;
  result.AddPair('JoyNum', TJSONNumber.Create(JoyNum));
  result.AddPair('AnalogType', TJSONNumber.Create(Integer(AnalogType)));
  result.AddPair('ControlType', TJSONNumber.Create(Integer(ControlType)));
  result.AddPair('Button', TJSONNumber.Create(Button));
  result.AddPair('POVid', TJSONNumber.Create(POVid));
  result.AddPair('POVValue', TJSONNumber.Create(POVValue));
  result.AddPair('Inverse', TJSONBool.Create(Inverse));
end;

procedure TGameControlJoy.FromJson(sourceData: TJSONValue);
begin
  JoyNum := sourceData.GetValue<Integer>('JoyNum');
  AnalogType := TJoyAnalogType(sourceData.GetValue<Integer>('AnalogType'));
  ControlType := TJoyControlType(sourceData.GetValue<Integer>('ControlType'));
  Button := sourceData.GetValue<Integer>('Button');
  POVid := sourceData.GetValue<Integer>('POVid');
  POVValue := sourceData.GetValue<Integer>('POVValue');
  Inverse := sourceData.GetValue<Boolean>('Inverse');
end;

procedure TGameControlJoy.SetJoyAnalog(joyNum: integer;
  JoyAnalogControl: TJoyAnalogType; Inverse: boolean);
begin
  controlType := jctAnalog;
  self.joyNum := joyNum;
  Self.analogType := JoyAnalogControl;
  Self.Inverse := Inverse;
  Self.button := -1;
  Self.POVid := -1;
  Self.POVValue := -1;
end;

procedure TGameControlJoy.SetJoyButton(joyNum, JoyButton: integer);
begin
  controlType := jctButton;
  self.joyNum := joyNum;
  Self.AnalogType := TJoyAnalogType.anNotUsed;
  Self.button := JoyButton;
  Self.POVid := -1;
  Self.POVValue := -1;
end;

procedure TGameControlJoy.SetJoyNone(joyNum: integer);
begin
  controlType := jctNone;
  self.joyNum := joyNum;
  Self.AnalogType := TJoyAnalogType.anNotUsed;
  Self.button := -1;
  Self.POVid := -1;
  Self.POVValue := -1;
end;

procedure TGameControlJoy.SetJoyPOV(joyNum, POVid, POVvalue: integer);
begin
  controlType := jctPOV;
  self.joyNum := joyNum;
  self.POVid := POVid;
  Self.POVValue := POVvalue;
  Self.button := -1;
  Self.AnalogType := TJoyAnalogType.anNotUsed;
end;

end.
