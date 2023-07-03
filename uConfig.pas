unit uConfig;

interface
uses
  System.IOUtils,
  System.SysUtils,
  System.JSON,
  DirectInput8,
  uConfigBase,
  uController,
  uConfigVars;

const
  ConfigHeader = 'Retrofire configuration file. (C) gadz.pl';

  GAME_CONTROL_COUNT = 18;
  ControlNames: array [0 .. GAME_CONTROL_COUNT - 1] of string = (
    'Turn left (right nozzle)',
    'Turn right (left nozzle)',
    'Go up (bottom nozzles)',
    'Go up boosted (bottom nozzles)',
    'Go down (top nozzle)',
    'Go Forward (back nozzle)',
    'Shoot a rocket',
    'Shoot from the machine guns',
    'Finish mission (on mothership)',
    'Camera 1 (from top back, close)',
    'Camera 2 (from back to top, look up)',
    'Camera 3 (from back, far)',
    'Camera 4 (from front)',
    'Camera 5 (from back, middle)',
    'Camera 6 (from top, look down)',
    'Camera 7 (from the nearest landfield)',
    'Camera 8 (cockpit, from inside)',
    'Drop off a survivor'
  );

type

  TScreenConfig = class
  public
    Width,
    Height,
    BPP,
    Hz: integer;
    FullScreen: boolean;

    function AsJson: TJSONObject;
    procedure FromJson(sourceData: TJSONValue);
  end;

  TSoundConfig = class
  public
    Output: integer;
    MusicVolume,
    SoundVolume: integer;

    function AsJson: TJSONObject;
    procedure FromJson(sourceData: TJSONValue);
    procedure SetDefaults;
  end;

  TDisplayConfig = class
  public
    Brightness,
    VisibilityRange: integer;
    DefaultCamera: integer;
    ShowGrass: boolean;

    function AsJson: TJSONObject;
    procedure FromJson(sourceData: TJSONValue);
    procedure SetDefaults;
  end;

  TConfig = class(TConfigBase)
  private
  protected
    procedure SaveData(data: TJSONObject); override;
    procedure LoadData(data: TJSONObject); override;
  public
    Screen: TScreenConfig;
    Sound: TSoundConfig;
    Display: TDisplayConfig;
    GameController: TGameController;

    constructor Create(fileName: string); override;
    destructor Destroy; override;

    procedure SetDefaults;
    procedure PrepareControls;
    procedure SetDefaultControls;
  end;

  TJSONHelper = class
    class function GetValue<T>(SourceData: TJSONValue; const APath: string; const DefaultValue: T): T;
  end;

var
  Config: TConfig;

implementation
{uses
  uGlobalConsts;}

{ TConfig }

constructor TConfig.Create(fileName: string);
begin
  inherited Create(fileName);

  screen := TScreenConfig.Create;
  sound := TSoundConfig.Create;
  display := TDisplayConfig.Create;
  GameController := TGameController.Create;
end;

destructor TConfig.Destroy;
begin
  screen.Free;
  sound.Free;
  display.Free;
  GameController.Free;

  inherited;
end;

procedure TConfig.LoadData(data: TJSONObject);
begin
  Screen.FromJson(data.GetValue('Screen'));
  Sound.FromJson(data.GetValue('Sound'));
  Display.FromJson(data.GetValue('Display'));
  GameController.FromJson(data.GetValue('GameController'));
end;

procedure TConfig.SaveData(data: TJSONObject);
begin
  data.AddPair('Screen', Screen.AsJson);
  data.AddPair('Sound', Sound.AsJson);
  data.AddPair('Display', Display.AsJson);
  data.AddPair('GameController', GameController.AsJson);
end;

procedure TConfig.PrepareControls;
var
  a: integer;
begin
  GameController.Clear;

  for a := 0 to GAME_CONTROL_COUNT - 1 do
    GameController.AddControl(ControlNames[a]);
end;

procedure TConfig.SetDefaultControls;
begin
  GameController.Control(0).SetKey(dik_left);
//  GameController.Control(0).SetJoyAnalog(0, TJoyAnalogType.anXAxisL, false);
  GameController.Control(1).SetKey(dik_right);
//  GameController.Control(1).SetJoyAnalog(0, TJoyAnalogType.anXAxisL, false);
  GameController.Control(2).SetKey(dik_z);
//  GameController.Control(2).SetJoyAnalog(0, TJoyAnalogType.anYAxisVL, false);
  GameController.Control(3).SetKey(dik_x);
//  GameController.Control(3).SetJoyAnalog(0, TJoyAnalogType.anYAxisVL, false);
  GameController.Control(4).SetKey(DIK_q);
//  GameController.Control(4).SetJoyButton(0, 1);
  GameController.Control(5).SetKey(dik_a);
//  GameController.Control(5).SetJoyNone(0);
  GameController.Control(6).SetKey(dik_s);
//  GameController.Control(6).SetJoyNone(0);
  GameController.Control(7).SetKey(dik_d);
//  GameController.Control(7).SetJoyNone(0);
  GameController.Control(8).SetKey(dik_w);
//  GameController.Control(8).SetJoyNone(0);
  GameController.Control(9).SetKey(dik_1);
//  GameController.Control(9).SetJoyNone(0);
  GameController.Control(10).SetKey(dik_2);
//  GameController.Control(10).SetJoyNone(0);
  GameController.Control(11).SetKey(DIK_3);
//  GameController.Control(11).SetJoyButton(0, 2);
  GameController.Control(12).SetKey(DIK_4);
//  GameController.Control(12).SetJoyButton(0, 5);
  GameController.Control(13).SetKey(DIK_5);
//  GameController.Control(13).SetJoyButton(0, 6);
  GameController.Control(14).SetKey(DIK_6);
  GameController.Control(15).SetKey(DIK_7);
  GameController.Control(16).SetKey(DIK_8);
  GameController.Control(17).SetKey(DIK_r);
end;

procedure TConfig.SetDefaults;
begin
  SetDefaultControls;
  Sound.SetDefaults;
  Display.SetDefaults;
end;

{ TScreenConfig }

function TScreenConfig.AsJson: TJSONObject;
begin
  result := TJSONObject.Create;
  result.AddPair('Width', TJSONNumber.Create(Width));
  result.AddPair('Height', TJSONNumber.Create(Height));
  result.AddPair('BPP', TJSONNumber.Create(BPP));
  result.AddPair('Hz', TJSONNumber.Create(Hz));
  result.AddPair('FullScreen', TJSONBool.Create(FullScreen));
end;

procedure TScreenConfig.FromJson(sourceData: TJSONValue);
begin
  Width := sourceData.GetValue<Integer>('Width');
  Height := sourceData.GetValue<Integer>('Height');
  BPP := sourceData.GetValue<Integer>('BPP');
  Hz := sourceData.GetValue<Integer>('Hz');
  FullScreen := sourceData.GetValue<Boolean>('FullScreen');
end;

{ TDisplayConfig }

function TDisplayConfig.AsJson: TJSONObject;
begin
  result := TJSONObject.Create;
  result.AddPair('Brightness', TJSONNumber.Create(Brightness));
  result.AddPair('VisibilityRange', TJSONNumber.Create(VisibilityRange));
  result.AddPair('DefaultCamera', TJSONNumber.Create(DefaultCamera));
  result.AddPair('ShowGrass', TJSONBool.Create(ShowGrass));
end;

procedure TDisplayConfig.FromJson(sourceData: TJSONValue);
begin
  Brightness := sourceData.GetValue<Integer>('Brightness');
  VisibilityRange := sourceData.GetValue<Integer>('VisibilityRange');
//  DefaultCamera := TJSONHelper.GetValue<Integer>(sourceData, 'DefaultCamera', camera_front_dynamic);
  ShowGrass := sourceData.GetValue<Boolean>('ShowGrass');
end;

procedure TDisplayConfig.SetDefaults;
begin
  Brightness := 0;
  VisibilityRange := 90;
  DefaultCamera := 1;
end;

{ TSoundConfig }

function TSoundConfig.AsJson: TJSONObject;
begin
  result := TJSONObject.Create;
  result.AddPair('Output', TJSONNumber.Create(Output));
  result.AddPair('MusicVolume', TJSONNumber.Create(MusicVolume));
  result.AddPair('SoundVolume', TJSONNumber.Create(SoundVolume));
end;

procedure TSoundConfig.FromJson(sourceData: TJSONValue);
begin
  Output := sourceData.GetValue<Integer>('Output');
  MusicVolume := sourceData.GetValue<Integer>('MusicVolume');
  SoundVolume := sourceData.GetValue<Integer>('SoundVolume');
end;

procedure TSoundConfig.SetDefaults;
begin
  Output := 1;
  MusicVolume := 250;
  SoundVolume := 250;
end;

{ TJSONHelper }

class function TJSONHelper.GetValue<T>(SourceData: TJSONValue;
  const APath: string; const DefaultValue: T): T;
begin
  try
    result := sourceData.GetValue<T>(APath);
  except
    result := DefaultValue;
  end;
end;

end.
