program RetrofireConfiguration;

uses
  Forms,
  uMain in 'uMain.pas' {Main},
  uGetKey in 'uGetKey.pas' {GetKeyWindow},
  uGraphicModes in 'uGraphicModes.pas',
  uController in '..\uController.pas',
  uConfig in '..\uConfig.pas',
  uConfigBase in '..\uConfigBase.pas',
  uControllerPanel in 'uControllerPanel.pas',
  uControllerPanel.Analog2DIndicator in 'uControllerPanel.Analog2DIndicator.pas',
  uControllerPanel.IndicatorBase in 'uControllerPanel.IndicatorBase.pas',
  uControllerPanel.Analog1DIndicator in 'uControllerPanel.Analog1DIndicator.pas',
  uControllerPanel.ButtonIndicator in 'uControllerPanel.ButtonIndicator.pas',
  uControllerPanel.POVIndicator in 'uControllerPanel.POVIndicator.pas',
  uConfigVars in '..\uConfigVars.pas',
  PowerInputs in '..\Components\PowerDraw\Source\PowerInputs.pas',
  DirectInput8 in '..\Components\PowerDraw\Source\DirectInput8.pas',
  d3d9 in '..\Components\PowerDraw\Source\d3d9.pas',
  PowerTypes in '..\Components\PowerDraw\Source\PowerTypes.pas',
  DXGCommon in '..\Components\PowerDraw\Source\DXGCommon.pas',
  uSpecialFolders in '..\Components\SpecialFolders\uSpecialFolders.pas',
  PowerTimers in '..\Components\PowerDraw\Source\PowerTimers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Retrofire: Configuration';
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TGetKeyWindow, GetKeyWindow);
  Application.Run;
end.
