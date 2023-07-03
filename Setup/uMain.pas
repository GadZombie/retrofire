unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, PowerInputs, Buttons, directinput8, ComCtrls,
  uGraphicModes, Vcl.ExtCtrls,
  uController, uConfig;

type
  TMain = class(TForm)
    Panel1: TPanel;
    btnanuluj: TButton;
    btnok: TButton;
    pgcMain: TPageControl;
    tabGraphics: TTabSheet;
    tabSound: TTabSheet;
    tabControls: TTabSheet;
    ButPrzywrocDomyslne: TSpeedButton;
    Label5: TLabel;
    klawskrol: TScrollBox;
    ControlsHeader: THeaderControl;
    trDeadZone: TTrackBar;
    cbGraphicsMode: TComboBox;
    chfullscreen: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    TrJasnosc: TTrackBar;
    TrWidocznosc: TTrackBar;
    cbdzwiek: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    TrVolDzw: TTrackBar;
    TrVolMuz: TTrackBar;
    Label6: TLabel;
    tabReadMe: TTabSheet;
    memReadMe: TMemo;
    chGrass: TCheckBox;
    procedure btnanulujClick(Sender: TObject);
    procedure wczytajkfg;
    procedure zapiszkfg;
    procedure btnokClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KlawiszClick(Sender: TObject);
    procedure ButPrzywrocDomyslneClick(Sender: TObject);
    procedure klawskrolMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    GraphicsModes: TGraphicsModeList;
    GameController: TGameController;

    procedure GetGraphicsModeList;
    procedure CopyFromUIToConfig;
    procedure CopyFromConfigToUI;
    procedure CopyControlsFromConfigToUI;
    procedure LoadReadMe;
  public
    { Public declarations }
    klawisze_labele: array [0 .. GAME_CONTROL_COUNT - 1] of TLabel;
    klawisze_zmien: array [0..1, 0 .. GAME_CONTROL_COUNT - 1] of TSpeedButton;

    Config: TConfig;
  end;

var
  Main: TMain;

implementation

uses
  uGetKey,
  uConfigVars;

{$R *.dfm}

procedure TMain.btnanulujClick(Sender: TObject);
begin
  close;
end;

procedure TMain.wczytajkfg;
begin
  try
    Config.LoadConfig;
  except
    on E: Exception do
    begin
      Config.SetDefaults;
//      Application.MessageBox(PWideChar(E.Message), PWideChar('Error while loading config file'));
    end;
  end;
  CopyFromConfigToUI;
end;

procedure TMain.zapiszkfg;
begin
  try
    CopyFromUIToConfig;
    Config.SaveConfig;
  except
    on E: Exception do
      Application.MessageBox(PWideChar(E.Message), PWideChar('Error while saving config file'));
  end;
end;

procedure TMain.CopyFromUIToConfig;
var
  tmpGM: TGraphicsMode;
begin
  tmpGM := GraphicsModes.Items[cbGraphicsMode.ItemIndex];
  Config.Screen.Width := tmpGM.x;
  Config.Screen.Height := tmpGM.y;
  Config.Screen.BPP := tmpGM.bpp;
  Config.Screen.Hz := tmpGM.hz;
  Config.Screen.FullScreen := chfullscreen.checked;

  Config.Sound.Output := cbdzwiek.ItemIndex;
  Config.Sound.SoundVolume := TrVolDzw.Position * 10;
  Config.Sound.MusicVolume := TrVolMuz.Position * 10;

  Config.Display.VisibilityRange := TrWidocznosc.Position * 10;
  Config.Display.Brightness := TrJasnosc.Position;
  Config.Display.ShowGrass := chGrass.Checked;

  Config.GameController.DeadZone := trDeadZone.Position;
end;

procedure TMain.CopyFromConfigToUI;

  procedure FindGraphicsMode;
  var
    a, x, y: integer;
    bpp, hz: integer;
  begin
    x := Config.Screen.Width;
    y := Config.Screen.Height;
    bpp := Config.Screen.BPP;
    hz := Config.Screen.Hz;

    a := 0;
    while (a <= GraphicsModes.Count - 1) and
      not((x = GraphicsModes[a].x) and (y = GraphicsModes[a].y) and
      (bpp = GraphicsModes[a].bpp) and (hz = GraphicsModes[a].hz)) do
      inc(a);

    if a > GraphicsModes.Count - 1 then
    begin // nie znaleziono
      cbGraphicsMode.ItemIndex := GraphicsModes.Count - 1;
    end
    else // znaleziono
      cbGraphicsMode.ItemIndex := a;
  end;

begin
  FindGraphicsMode;
  chfullscreen.checked := Config.Screen.FullScreen;
  cbdzwiek.ItemIndex := Config.Sound.Output;
  chGrass.checked := Config.Display.ShowGrass;

  TrVolDzw.Position := Config.Sound.SoundVolume div 10;
  TrVolMuz.Position := Config.Sound.MusicVolume div 10;
  TrWidocznosc.Position := Config.Display.VisibilityRange div 10;
  TrJasnosc.Position := Config.Display.Brightness;
  trDeadZone.Position := Config.GameController.DeadZone;

  CopyControlsFromConfigToUI;
end;

procedure TMain.btnokClick(Sender: TObject);
begin
  zapiszkfg;
  close;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  GetGraphicsModeList;
end;

procedure TMain.FormShow(Sender: TObject);
const
  rowSpacing = 28;
  rowHeight = 24;
  rmargin = 15;
  columnWidth = 200;
  buttonMargin = 5;
  tMargin = 5;
var
  a, b, topMargin: integer;
begin
  Config := TConfig.Create(GetConfigFilePath);
  Config.JsonHeader := ConfigHeader;

  GameController := Config.GameController;
  GameController.SetInput(GetKeyWindow.PowerInput1);

  Config.PrepareControls;
  Config.SetDefaults;

  wczytajkfg;

  ControlsHeader.Sections[0].Width := klawskrol.width - rmargin - columnWidth * (1 + 1);
  ControlsHeader.Sections[1].Width := columnWidth;
  ControlsHeader.Sections[2].Width := columnWidth;
  ControlsHeader.Sections[1].Text := ''; // na razie nie u¿ywam joysticka

  topMargin := tMargin + ControlsHeader.Height;

  for a := 0 to GameController.Count - 1 do
  begin
    klawisze_labele[a] := TLabel.Create(Main);
    with klawisze_labele[a] do
    begin
      parent := klawskrol;
      visible := true;
      left := 10;
      top := topMargin + a * rowSpacing;
      caption := GameController.Control(a).name;
      AutoSize := false;
      height := rowHeight;
      width := ControlsHeader.Sections[0].Width - 2;
      Layout := tlCenter;
    end;

    for b := 0 to 0 do
    begin
      klawisze_zmien[b, a] := TSpeedButton.Create(Main);
      with klawisze_zmien[b, a] do
      begin
        parent := klawskrol;
        visible := true;
        left := parent.width - rmargin - columnWidth * (b + 1);
        width := columnWidth - buttonMargin;
        height := rowHeight;
        top := topMargin + a * rowSpacing;
        if b = 1 then
          caption := GameController.Control(a).GetJoyAsString
        else
          caption := GameController.Control(a).GetKeyAsString;
        font.Style := [fsbold];
        flat := true;
        tag := a + 1000 * b;
        OnClick := KlawiszClick;
      end;
    end;
  end;

  LoadReadMe;
  pgcMain.ActivePage := tabReadMe;
end;

procedure TMain.GetGraphicsModeList;
var
  a: integer;
begin
  GraphicsModes := GetGraphicsModes;
  cbGraphicsMode.Clear;
  for a := 0 to GraphicsModes.Count - 1 do
    cbGraphicsMode.Items.Add(GraphicsModes.Items[a].visual);
end;

procedure TMain.KlawiszClick(Sender: TObject);
begin
  CopyFromUIToConfig;
  GetKeyWindow.GameController := GameController;
  GetKeyWindow.StartControlChange((Sender as TSpeedButton).tag div 1000, (Sender as TSpeedButton).tag mod 1000);
  CopyControlsFromConfigToUI;
end;

procedure TMain.klawskrolMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  (Sender as TScrollBox).VertScrollBar.Position := (Sender as TScrollBox).VertScrollBar.Position - WheelDelta;
end;

procedure TMain.ButPrzywrocDomyslneClick(Sender: TObject);
begin
  Config.SetDefaultControls;
  CopyControlsFromConfigToUI;
end;

procedure TMain.CopyControlsFromConfigToUI;
var
  a: integer;
begin
  for a := 0 to GAME_CONTROL_COUNT - 1 do
  begin
    klawisze_zmien[0, a].caption := GameController.Control(a).GetKeyAsString;
    klawisze_zmien[1, a].caption := GameController.Control(a).GetJoyAsString;
  end;

end;

procedure TMain.LoadReadMe;
var
  s: string;
begin
  try
    memReadMe.Lines.LoadFromFile('ReadMe.txt');

  except
    on e: Exception do
    begin
      s := 'There should be the ReadMe file in here but it looks like someone removed it or ' +
        'there is no privilige to load it from current directory.'#13#10 +
        'Loading error: ' + e.Message;
      memReadMe.Lines.Text := s;
    end;
  end;
end;

end.
