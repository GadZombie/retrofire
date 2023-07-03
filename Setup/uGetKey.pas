unit uGetKey;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PowerTimers, PowerInputs, StdCtrls, ExtCtrls, PowerTypes,
  uController, Vcl.Buttons, uControllerPanel;

type
  TGetKeyWindow = class(TForm)
    PowerTimer1: TPowerTimer;
    Panel1: TPanel;
    lbInfo: TLabel;
    lbJoyDebug: TLabel;
    PowerInput1: TPowerInput;
    btnNone: TButton;
    Panel2: TPanel;
    btnCancel: TButton;
    btnTest: TSpeedButton;
    chInverseControl: TCheckBox;
    procedure PowerTimer1Process(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure btnNoneClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PowerTimer1Render(Sender: TObject);
  private
    ControllerPanel: TControllerPanel;

    procedure CheckJoy;
    procedure CheckKey;
    procedure SetControlJoy(ControlType: TJoyControlType;
      AnalogType: TJoyAnalogType; Button, POVid, POVvalue: integer; Inverse: boolean);
    procedure CancelSetControl;
    procedure SetControlKey(key: integer);
    procedure InputFinish;
    procedure ShowHideTestPanel;
    function TestPanelVisible: boolean;
    procedure UpdateTestPanel;
    procedure CreateControllerPanel;
  public
    controlIndexChange: integer;
    controlTypeChange: integer;

    GameController: TGameController;

    procedure StartControlChange(AType, Index: integer);
  end;

var
  GetKeyWindow: TGetKeyWindow;

implementation

uses uMain;

{$R *.dfm}

procedure TGetKeyWindow.PowerTimer1Process(Sender: TObject);
var
  a: integer;
begin
  a := PowerInput1.Update;
  if a <> 0 then
    exit;

  if PowerInput1.Keys[1] then
  begin
    CancelSetControl;
    exit;
  end;

  if not TestPanelVisible then
  begin
    if controlTypeChange = 0 then
      CheckKey
    else if controlTypeChange = 1 then
      CheckJoy;
  end;

  UpdateTestPanel;
end;

procedure TGetKeyWindow.PowerTimer1Render(Sender: TObject);
begin
  UpdateTestPanel;
end;

procedure TGetKeyWindow.CheckKey;
var
  key: integer;
begin
  key := GameController.GetKeyPressed;
  if key <> 0 then
    SetControlKey(key);
end;

procedure TGetKeyWindow.InputFinish;
begin
  PowerTimer1.MayProcess := false;
  PowerInput1.Finalize;
end;

procedure TGetKeyWindow.CreateControllerPanel;
var
  a: integer;
begin
  if ControllerPanel <> nil then
    exit;

  ControllerPanel := TControllerPanel.Create(self, PowerInput1);
  ControllerPanel.Parent := Panel1;
  ControllerPanel.Left := 1;
  ControllerPanel.Top := 1;
  ControllerPanel.Width := Panel1.Width - 2;
  ControllerPanel.Height := Panel1.Height - 2;

  ControllerPanel.AddAnalog2DIndicator(0, anXAxisL, anYAxisL, 'Axis 1 XY');
  ControllerPanel.AddAnalog1DIndicator(0, anZAxisL, 'Axis 1 Z');

  ControllerPanel.AddAnalog2DIndicator(0, anXAxisR, anYAxisR, 'Axis 1R XY');
  ControllerPanel.AddAnalog1DIndicator(0, anZAxisR, 'Axis 1R Z');

  ControllerPanel.AddAnalog2DIndicator(0, anXAxisVL, anYAxisVL, 'Axis 2 XY');
  ControllerPanel.AddAnalog1DIndicator(0, anZAxisVL, 'Axis 2 Z');

  ControllerPanel.AddAnalog2DIndicator(0, anXAxisVR, anYAxisVR, 'Axis 2R XY');
  ControllerPanel.AddAnalog1DIndicator(0, anZAxisVR, 'Axis 2R Z');

  ControllerPanel.AddAnalog2DIndicator(0, anXAxisAL, anYAxisAL, 'Axis 3 XY');
  ControllerPanel.AddAnalog1DIndicator(0, anZAxisAL, 'Axis 3 Z');

  ControllerPanel.AddAnalog2DIndicator(0, anXAxisAR, anYAxisAR, 'Axis 3R XY');
  ControllerPanel.AddAnalog1DIndicator(0, anZAxisAR, 'Axis 3R Z');

  ControllerPanel.AddAnalog2DIndicator(0, anXAxisFL, anYAxisFL, 'Axis 4 XY');
  ControllerPanel.AddAnalog1DIndicator(0, anZAxisFL, 'Axis 4 Z');

  ControllerPanel.AddAnalog2DIndicator(0, anXAxisFR, anYAxisFR, 'Axis 4R XY');
  ControllerPanel.AddAnalog1DIndicator(0, anZAxisFR, 'Axis 4R Z');

  for a := 0 to GameController.GetJoyPOVCount - 1 do
    ControllerPanel.AddPOVIndicator(0, a, Format('POV %d', [a + 1]));

  for a := 0 to GameController.GetJoyButtonsCount - 1 do
    ControllerPanel.AddButtonIndicator(0, a, Format('Btn %d', [a + 1]));



end;

procedure TGetKeyWindow.FormHide(Sender: TObject);
begin
  InputFinish;
end;

procedure TGetKeyWindow.FormShow(Sender: TObject);
begin
  ShowHideTestPanel;
end;

procedure TGetKeyWindow.btnTestClick(Sender: TObject);
begin
  ShowHideTestPanel;
end;

procedure TGetKeyWindow.btnNoneClick(Sender: TObject);
begin
  if controlTypeChange = 0 then
    SetControlKey(0)
  else if controlTypeChange = 1 then
    SetControlJoy(jctNone, anXAxisL, 0, 0, 0, false);
end;

procedure TGetKeyWindow.btnCancelClick(Sender: TObject);
begin
  CancelSetControl;
end;

procedure TGetKeyWindow.CancelSetControl;
begin
  Close;
end;

procedure TGetKeyWindow.SetControlKey(key: integer);
begin
  GameController.Control(controlIndexChange).SetKey(key);
  Close;
end;

procedure TGetKeyWindow.StartControlChange(AType, Index: integer);
begin
  PowerInput1.Initialize;
  PowerInput1.Update;
  PowerTimer1.MayProcess := true;

  controlIndexChange := Index;
  controlTypeChange := AType;
  if controlTypeChange = 1 then
  begin
    if PowerInput1.JoystickCount <= 0 then
    begin
      InputFinish;
      Application.MessageBox('Joystick not found', '');
      exit;
    end;

    lbInfo.Caption := 'Move a joystick, press a button or ESC to cancel';

    chInverseControl.Checked := GameController.Control(controlIndexChange).IsAnalogInversed;
    chInverseControl.Visible := true;

  end
  else
  begin
    lbInfo.Caption := 'Press a key on the keyboard or ESC to cancel';
    chInverseControl.Visible := false;
  end;

  Showmodal;
end;

procedure TGetKeyWindow.SetControlJoy(ControlType: TJoyControlType;
  AnalogType: TJoyAnalogType; Button, POVid, POVvalue: integer; Inverse: boolean);
begin
  if ControlType = jctAnalog then
  begin
    GameController.Control(controlIndexChange).SetJoyAnalog(0, AnalogType, Inverse);
  end
  else if ControlType = jctButton then
  begin
    GameController.Control(controlIndexChange).SetJoyButton(0, Button);
  end
  else if ControlType = jctPOV then
  begin
    GameController.Control(controlIndexChange).SetJoyPOV(0, POVid, POVvalue);
  end
  else if ControlType = jctNone then
  begin
    GameController.Control(controlIndexChange).SetJoyNone(0);
  end;

  Close;
end;

procedure TGetKeyWindow.CheckJoy;
var
  j: integer;
  s: string;
var
  ControlType: TJoyControlType;
  AnalogType: TJoyAnalogType;
  Button, POVid, POVvalue: integer;
begin
  GameController.GetJoyPressed(ControlType, AnalogType, Button, POVid,
    POVvalue);

  if ControlType in [jctAnalog, jctButton, jctPOV] then
    SetControlJoy(ControlType, AnalogType, Button, POVid, POVvalue, chInverseControl.Checked);

{
  s := '';
  for j := 0 to PowerInput1.JoystickCount - 1 do
  begin
    s := Format('rglSlider 0 = %d'#13#10 + 'rglSlider 1 = %d'#13#10 +

      'rgdwPOV 0 = %d'#13#10 + 'rgdwPOV 1 = %d'#13#10 + 'rgdwPOV 2 = %d'#13#10 +
      'rgdwPOV 3 = %d'#13#10 +

      'rglVSlider 0 = %d'#13#10 + 'rglVSlider 1 = %d'#13#10 +

      'rglASlider 0 = %d'#13#10 + 'rglASlider 1 = %d'#13#10 +

      'rglFSlider 0 = %d'#13#10 + 'rglFSlider 1 = %d'#13#10 +

      'lx = %d'#13#10 + 'ly = %d'#13#10 + 'lz = %d'#13#10 + 'lRx = %d'#13#10 +
      'lRy = %d'#13#10 + 'lRz = %d'#13#10 +

      'ivX = %d'#13#10 + 'ivY = %d'#13#10 + 'ivZ = %d'#13#10 + 'ivRX = %d'#13#10
      + 'ivRY = %d'#13#10 + 'ivRZ = %d'#13#10 +

      'laX = %d'#13#10 + 'laY = %d'#13#10 + 'laZ = %d'#13#10 + 'laRX = %d'#13#10
      + 'laRY = %d'#13#10 + 'laRZ = %d'#13#10 +

      'lFX = %d'#13#10 + 'lFY = %d'#13#10 + 'lFZ = %d'#13#10 + 'lFRX = %d'#13#10
      + 'lFRY = %d'#13#10 + 'lFRZ = %d'#13#10,
      [PowerInput1.Joystick[j].DIJoyState2.rglSlider[0],
      PowerInput1.Joystick[j].DIJoyState2.rglSlider[1],
      PowerInput1.Joystick[j].DIJoyState2.rgdwPOV[0],
      PowerInput1.Joystick[j].DIJoyState2.rgdwPOV[1],
      PowerInput1.Joystick[j].DIJoyState2.rgdwPOV[2],
      PowerInput1.Joystick[j].DIJoyState2.rgdwPOV[3],

      PowerInput1.Joystick[j].DIJoyState2.rglVSlider[0],
      PowerInput1.Joystick[j].DIJoyState2.rglVSlider[1],

      PowerInput1.Joystick[j].DIJoyState2.rglASlider[0],
      PowerInput1.Joystick[j].DIJoyState2.rglASlider[1],

      PowerInput1.Joystick[j].DIJoyState2.rglFSlider[0],
      PowerInput1.Joystick[j].DIJoyState2.rglFSlider[1],

      PowerInput1.Joystick[j].DIJoyState2.lX,
      PowerInput1.Joystick[j].DIJoyState2.ly,
      PowerInput1.Joystick[j].DIJoyState2.lz,
      PowerInput1.Joystick[j].DIJoyState2.lrX,
      PowerInput1.Joystick[j].DIJoyState2.lry,
      PowerInput1.Joystick[j].DIJoyState2.lrz,

      PowerInput1.Joystick[j].DIJoyState2.lVX,
      PowerInput1.Joystick[j].DIJoyState2.lVY,
      PowerInput1.Joystick[j].DIJoyState2.lvz,
      PowerInput1.Joystick[j].DIJoyState2.lvrX,
      PowerInput1.Joystick[j].DIJoyState2.lvry,
      PowerInput1.Joystick[j].DIJoyState2.lvrz,

      PowerInput1.Joystick[j].DIJoyState2.lAX,
      PowerInput1.Joystick[j].DIJoyState2.lAY,
      PowerInput1.Joystick[j].DIJoyState2.lAz,
      PowerInput1.Joystick[j].DIJoyState2.lARx,
      PowerInput1.Joystick[j].DIJoyState2.lARy,
      PowerInput1.Joystick[j].DIJoyState2.lARz,

      PowerInput1.Joystick[j].DIJoyState2.lFX,
      PowerInput1.Joystick[j].DIJoyState2.lFY,
      PowerInput1.Joystick[j].DIJoyState2.lFz,
      PowerInput1.Joystick[j].DIJoyState2.lFrX,
      PowerInput1.Joystick[j].DIJoyState2.lFry,
      PowerInput1.Joystick[j].DIJoyState2.lFrz]);
  end;

  lbJoyDebug.Caption := s;}
end;

function TGetKeyWindow.TestPanelVisible: boolean;
begin
  result := false; //btnTest.Down;
end;

procedure TGetKeyWindow.ShowHideTestPanel;
begin
  CreateControllerPanel;
  ControllerPanel.UpdateConfig(GameController.CalculatedDeadZone);
  UpdateTestPanel;
  ControllerPanel.Visible := TestPanelVisible;
end;

procedure TGetKeyWindow.UpdateTestPanel;
begin
  if TestPanelVisible then
    ControllerPanel.Update;
end;


end.
