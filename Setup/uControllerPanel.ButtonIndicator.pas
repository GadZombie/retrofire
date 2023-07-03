unit uControllerPanel.ButtonIndicator;

interface
uses
  Classes, Graphics, Controls, ExtCtrls, StdCtrls, Vcl.Buttons,
  System.Generics.Collections,
  PowerInputs,
  uControllerPanel.IndicatorBase,
  uController;

type
  TButtonIndicator = class(TPanel, IIndicatorIntf)
  strict private
    shBackground: TShape;
    shPosition: TShape;
    lbName: TLabel;
    GameControl: TGameControl;
    JoyNum: integer;
    Button: integer;

  private
    procedure SetPressed(Pressed: boolean);

  public
    constructor Create(AOwner: TComponent; Input: TPowerInput);
    destructor Destroy; override;
    procedure Prepare(JoyNum: integer; Button: integer; Name: string);
    procedure UpdatePosition;
  end;


implementation

{ TButtonIndicator }

constructor TButtonIndicator.Create(AOwner: TComponent; Input: TPowerInput);
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
  shPosition.Width := shBackground.Width;
  shPosition.Height := shPosition.Width;
  shPosition.Top := 0;
  shPosition.Shape := stRoundRect;

  lbName := TLabel.Create(self);
  lbName.Parent := self;
  lbName.Align := alTop;
  lbName.AutoSize := false;
  lbName.Height := 20;
  lbName.Alignment := TAlignment.taCenter;

  self.DoubleBuffered := true;

  GameControl := TGameControl.Create(Input);
end;

destructor TButtonIndicator.Destroy;
begin
  shBackground.Free;
  shPosition.Free;
  GameControl.Free;

  inherited;
end;

procedure TButtonIndicator.Prepare(JoyNum: integer; Button: integer; Name: string);
begin
  Self.JoyNum := JoyNum;
  Self.Button := Button;
  lbName.Caption := Name;
end;

procedure TButtonIndicator.SetPressed(Pressed: boolean);
begin
  if Pressed then
    shPosition.Brush.Color := clBlack
  else
    shPosition.Brush.Color := clWhite;

  shPosition.Left := 0;
  shPosition.Width := shBackground.Width;
  shPosition.Height := shPosition.Width;
  shPosition.Top := shBackground.Top + (shBackground.Height - shPosition.Height) div 2;

end;

procedure TButtonIndicator.UpdatePosition;
var
  value: integer;
begin
  value := GameControl.GetButtonValue(JoyNum, Button);
  SetPressed(value > 0);
end;


end.

