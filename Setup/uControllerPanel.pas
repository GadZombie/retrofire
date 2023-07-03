unit uControllerPanel;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  System.Generics.Collections,
  PowerTimers, PowerInputs, StdCtrls, ExtCtrls, PowerTypes,
  uController, Vcl.Buttons,
  uControllerPanel.IndicatorBase,
  uControllerPanel.Analog1DIndicator,
  uControllerPanel.Analog2DIndicator,
  uControllerPanel.ButtonIndicator,
  uControllerPanel.POVIndicator;

type
  TControllerPanel = class(TPanel)
  private
    Input: TPowerInput;
    Indicators: TList<IIndicatorIntf>;
    procedure Arrange;
  public
    indicator2DWidth, indicatorHeight, indicator1DWidth,
    spacing: integer;

    constructor Create(AOwner: TComponent; Input: TPowerInput);
    destructor Destroy; override;

    procedure AddAnalog1DIndicator(JoyNum: integer; AnalogType: TJoyAnalogType; Name: string);
    procedure AddAnalog2DIndicator(JoyNum: integer; AnalogTypeX, AnalogTypeY: TJoyAnalogType; Name: string);
    procedure AddButtonIndicator(JoyNum, Button: integer; Name: string);
    procedure AddPOVIndicator(JoyNum, POVid: integer; Name: string);

    procedure UpdateConfig(DeadZone: integer);

    procedure Update;
  end;

implementation

{ TControllerPanel }

procedure TControllerPanel.AddAnalog1DIndicator(JoyNum: integer; AnalogType: TJoyAnalogType; Name: string);
var
  Indicator: IIndicatorIntf;
begin
  Indicator := TAnalog1DIndicator.Create(self, Input);
  Indicators.Add(Indicator);

  (Indicator as TAnalog1DIndicator).Prepare(JoyNum, AnalogType, Name);
  (Indicator as TAnalog1DIndicator).Parent := self;
  (Indicator as TAnalog1DIndicator).Width := indicator1DWidth;
  (Indicator as TAnalog1DIndicator).Height := indicatorHeight;

  Arrange;
end;

procedure TControllerPanel.AddAnalog2DIndicator(JoyNum: integer; AnalogTypeX, AnalogTypeY: TJoyAnalogType; Name: string);
var
  Indicator: IIndicatorIntf;
begin
  Indicator := TAnalog2DIndicator.Create(self, Input);
  Indicators.Add(Indicator);

  (Indicator as TAnalog2DIndicator).Prepare(JoyNum, AnalogTypeX, AnalogTypeY, Name);
  (Indicator as TAnalog2DIndicator).Parent := self;
  (Indicator as TAnalog2DIndicator).Width := indicator2DWidth;
  (Indicator as TAnalog2DIndicator).Height := indicatorHeight;

  Arrange;
end;

procedure TControllerPanel.AddButtonIndicator(JoyNum, Button: integer; Name: string);
var
  Indicator: IIndicatorIntf;
begin
  Indicator := TButtonIndicator.Create(self, Input);
  Indicators.Add(Indicator);

  (Indicator as TButtonIndicator).Prepare(JoyNum, Button, Name);
  (Indicator as TButtonIndicator).Parent := self;
  (Indicator as TButtonIndicator).Width := indicator1DWidth;
  (Indicator as TButtonIndicator).Height := indicatorHeight;

  Arrange;
end;

procedure TControllerPanel.AddPOVIndicator(JoyNum, POVid: integer; Name: string);
var
  Indicator: IIndicatorIntf;
begin
  Indicator := TPOVIndicator.Create(self, Input);
  Indicators.Add(Indicator);

  (Indicator as TPOVIndicator).Prepare(JoyNum, POVid, Name);
  (Indicator as TPOVIndicator).Parent := self;
  (Indicator as TPOVIndicator).Width := indicator2DWidth;
  (Indicator as TPOVIndicator).Height := indicatorHeight;

  Arrange;

end;

procedure TControllerPanel.Arrange;
var
  Indicator: IIndicatorIntf;
  x, y: integer;
  element: TPanel;
begin
  x := 0;
  y := 0;
  for Indicator in Indicators do
  begin
    element := (Indicator as TPanel);
    if x + element.Width > self.Width then
    begin
      x := 0;
      y := y + indicatorHeight + spacing;
    end;
    element.Left := x;
    element.Top := y;

    x := x + element.Width + spacing;
  end;

end;

constructor TControllerPanel.Create(AOwner: TComponent; Input: TPowerInput);
begin
  inherited Create(AOwner);

  self.Input := Input;
  Indicators := TList<IIndicatorIntf>.Create;

  indicator1DWidth := 40;
  indicatorHeight := 120;
  indicator2DWidth := 120;
  spacing := 10;
end;

destructor TControllerPanel.Destroy;
begin
  Indicators.Free;
  inherited;
end;

procedure TControllerPanel.Update;
var
  Indicator: IIndicatorIntf;
begin
  for Indicator in Indicators do
    Indicator.UpdatePosition;
end;


procedure TControllerPanel.UpdateConfig(DeadZone: integer);
var
  Indicator: IIndicatorIntf;
begin
  for Indicator in Indicators do
  begin
    if (Indicator is TAnalog1DIndicator) then
      (Indicator as TAnalog1DIndicator).SetConfig(DeadZone)
    else
    if (Indicator is TAnalog2DIndicator) then
      (Indicator as TAnalog2DIndicator).SetConfig(DeadZone);
  end;
end;

end.
