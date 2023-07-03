unit uControllerPanel.Analog1DIndicator;

interface
uses
  Classes, Graphics, Controls, ExtCtrls, StdCtrls, Vcl.Buttons,
  System.Generics.Collections,
  PowerInputs,
  uControllerPanel.IndicatorBase,
  uController;

type
  TAnalog1DIndicator = class(TPanel, IIndicatorIntf)
  strict private
    shBackground: TShape;
    shPosition: TShape;
    lbName: TLabel;
    GameControl: TGameControl;
    JoyNum: integer;
    AnalogType: TJoyAnalogType;
    DeadZone: integer;

    function CenterX: integer;
    function MaxX: integer;
    procedure SetX(value, maxValue: integer);

  public
    constructor Create(AOwner: TComponent; Input: TPowerInput);
    destructor Destroy; override;
    procedure Prepare(JoyNum: integer; AnalogType: TJoyAnalogType; Name: string);
    procedure UpdatePosition;
    procedure SetConfig(DeadZone: integer);
  end;


implementation

{ TAnalog1DIndicator }

function TAnalog1DIndicator.CenterX: integer;
begin
  result := shBackground.Height div 2 + shBackground.Top;
end;

constructor TAnalog1DIndicator.Create(AOwner: TComponent; Input: TPowerInput);
begin
  inherited Create(AOwner);
  self.BevelOuter := TBevelCut.bvNone;
  self.Color := clActiveCaption;

  shBackground := TShape.Create(self);
  shBackground.Parent := self;
  shBackground.Align := alClient;
  shBackground.Shape := stRoundRect;

  shPosition := TShape.Create(self);
  shPosition.Parent := self;
  shPosition.Left := 0;
  shPosition.Top := 0;
  shPosition.Width := shBackground.Width;
  shPosition.Height := 20;
  shPosition.Brush.Color := clBlack;
  shPosition.Shape := stRoundRect;

  lbName := TLabel.Create(self);
  lbName.Parent := self;
  lbName.Align := alTop;
  lbName.AutoSize := false;
  lbName.Height := 20;
  lbName.Alignment := TAlignment.taCenter;

  self.DoubleBuffered := true;

  GameControl := TGameControl.Create(Input);
  DeadZone := 0;
end;

destructor TAnalog1DIndicator.Destroy;
begin
  shBackground.Free;
  shPosition.Free;
  GameControl.Free;

  inherited;
end;

function TAnalog1DIndicator.MaxX: integer;
begin
  result := shBackground.Height div 2 - shPosition.Height div 2;
end;

procedure TAnalog1DIndicator.Prepare(JoyNum: integer; AnalogType: TJoyAnalogType; Name: string);
begin
  Self.JoyNum := JoyNum;
  Self.AnalogType := AnalogType;
  lbName.Caption := Name;
end;

procedure TAnalog1DIndicator.SetConfig(DeadZone: integer);
begin
  Self.DeadZone := DeadZone;
end;

procedure TAnalog1DIndicator.SetX(value, maxValue: integer);
begin
  shPosition.Top := Centerx + round( (value / maxValue) * Maxx ) - shPosition.Height div 2;
end;

procedure TAnalog1DIndicator.UpdatePosition;
var
  value: integer;
begin
  value := GameControl.GetAnalogValue(JoyNum, self.AnalogType, DeadZone);
  SetX(value, high(smallint));
end;


end.

