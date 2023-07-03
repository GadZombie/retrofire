unit uControllerPanel.Analog2DIndicator;

interface
uses
  Classes, Graphics, Controls, ExtCtrls, StdCtrls, Vcl.Buttons,
  System.Generics.Collections,
  PowerInputs,
  uControllerPanel.IndicatorBase,
  uController;

type
  TAnalog2DIndicator = class(TPanel, IIndicatorIntf)
  strict private
    shBackground: TShape;
    shPosition: TShape;
    lbName: TLabel;
    GameControl: TGameControl;
    JoyNum: integer;
    AnalogTypeX, AnalogTypeY: TJoyAnalogType;
    DeadZone: integer;

    function CenterX: integer;
    function MaxX: integer;
    procedure SetX(value, maxValue: integer);
    function CenterY: integer;
    function MaxY: integer;
    procedure SetY(value, maxValue: integer);

  public
    constructor Create(AOwner: TComponent; Input: TPowerInput);
    destructor Destroy; override;
    procedure Prepare(JoyNum: integer; AnalogTypeX, AnalogTypeY: TJoyAnalogType; Name: string);
    procedure UpdatePosition;
    procedure SetConfig(DeadZone: integer);
  end;


implementation

{ TAnalog2DIndicator }

function TAnalog2DIndicator.CenterX: integer;
begin
  result := shBackground.Width div 2 + shBackground.Left;
end;

function TAnalog2DIndicator.CenterY: integer;
begin
  result := shBackground.Height div 2 + shBackground.Top;
end;

constructor TAnalog2DIndicator.Create(AOwner: TComponent; Input: TPowerInput);
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
  shPosition.Width := 20;
  shPosition.Height := 20;
  shPosition.Brush.Color := clBlack;
  shPosition.Shape := stCircle;

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

destructor TAnalog2DIndicator.Destroy;
begin
  shBackground.Free;
  shPosition.Free;
  GameControl.Free;

  inherited;
end;

function TAnalog2DIndicator.MaxX: integer;
begin
  result := shBackground.Width div 2 - shPosition.Width div 2;
end;

function TAnalog2DIndicator.MaxY: integer;
begin
  result := shBackground.Height div 2 - shPosition.Height div 2;
end;

procedure TAnalog2DIndicator.Prepare(JoyNum: integer; AnalogTypeX, AnalogTypeY: TJoyAnalogType; Name: string);
begin
  Self.JoyNum := JoyNum;
  Self.AnalogTypeX := AnalogTypeX;
  Self.AnalogTypeY := AnalogTypeY;
  lbName.Caption := Name;
end;

procedure TAnalog2DIndicator.SetConfig(DeadZone: integer);
begin
  Self.DeadZone := DeadZone;
end;

procedure TAnalog2DIndicator.SetX(value, maxValue: integer);
begin
  shPosition.Left := CenterX + round( (value / maxValue) * MaxX ) - shPosition.Width div 2;
end;

procedure TAnalog2DIndicator.SetY(value, maxValue: integer);
begin
  shPosition.Top := CenterY + round( (value / maxValue) * MaxY ) - shPosition.Height div 2;
end;

procedure TAnalog2DIndicator.UpdatePosition;
var
  value: integer;
begin
  value := GameControl.GetAnalogValue(JoyNum, self.AnalogTypeX, DeadZone);
  SetX(value, high(smallint));

  value := GameControl.GetAnalogValue(JoyNum, self.AnalogTypeY, DeadZone);
  SetY(value, high(smallint));
end;


end.
