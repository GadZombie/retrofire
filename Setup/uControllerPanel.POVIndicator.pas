unit uControllerPanel.POVIndicator;

interface
uses
  Classes, Graphics, Controls, ExtCtrls, StdCtrls, Vcl.Buttons,
  System.Generics.Collections,
  PowerInputs,
  uControllerPanel.IndicatorBase,
  uController;

type
  TPOVIndicator = class(TPanel, IIndicatorIntf)
  strict private
    shBackground: TShape;
    shPosition: TShape;
    lbName: TLabel;
    GameControl: TGameControl;
    JoyNum: integer;
    POVid: integer;

    function CenterX: integer;
    function MaxX: integer;
    procedure SetX(value: integer);
    function CenterY: integer;
    function MaxY: integer;
    procedure SetY(value: integer);

  public
    constructor Create(AOwner: TComponent; Input: TPowerInput);
    destructor Destroy; override;
    procedure Prepare(JoyNum: integer; POVid: integer; Name: string);
    procedure UpdatePosition;
  end;


implementation

{ TPOVIndicator }

function TPOVIndicator.CenterX: integer;
begin
  result := shBackground.Width div 2 + shBackground.Left;
end;

function TPOVIndicator.CenterY: integer;
begin
  result := shBackground.Height div 2 + shBackground.Top;
end;

constructor TPOVIndicator.Create(AOwner: TComponent; Input: TPowerInput);
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
end;

destructor TPOVIndicator.Destroy;
begin
  shBackground.Free;
  shPosition.Free;
  GameControl.Free;

  inherited;
end;

function TPOVIndicator.MaxX: integer;
begin
  result := shBackground.Width div 2 - shPosition.Width div 2;
end;

function TPOVIndicator.MaxY: integer;
begin
  result := shBackground.Height div 2 - shPosition.Height div 2;
end;

procedure TPOVIndicator.Prepare(JoyNum: integer; POVid: integer; Name: string);
begin
  Self.JoyNum := JoyNum;
  Self.POVid := POVid;
  lbName.Caption := Name;
end;

procedure TPOVIndicator.SetX(value: integer);
begin
  shPosition.Left := CenterX + round( value * MaxX ) - shPosition.Width div 2;
end;

procedure TPOVIndicator.SetY(value: integer);
begin
  shPosition.Top := CenterY + round( value * MaxY ) - shPosition.Height div 2;
end;

procedure TPOVIndicator.UpdatePosition;
var
  values: TPOVValues;
begin
  values := GameControl.GetPOVValues(JoyNum, POVid);

  if povRight in values then
    SetX(1)
  else
  if povLeft in values then
    SetX(-1)
  else
    SetX(0);

  if povUp in values then
    SetY(-1)
  else
  if povDown in values then
    SetY(1)
  else
    SetY(0);
end;


end.

