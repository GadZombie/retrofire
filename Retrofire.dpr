program Retrofire;

uses
  Forms,
  Sysutils,
  OpenGl,
  api_func in 'api_func.pas',
  Main in 'Main.pas' {frmMain},
  unittimer in 'unittimer.pas',
  Render in 'Render.pas',
  UnitStart in 'UnitStart.pas' {FormStart},
  OBJ in 'Components\ZombiEGL\OBJ.pas',
  fmod in 'Components\FMOD_DX10.1\api\delphi\fmod.pas',
  fmoddyn in 'Components\FMOD_DX10.1\api\delphi\fmoddyn.pas',
  fmoderrors in 'Components\FMOD_DX10.1\api\delphi\fmoderrors.pas',
  fmodpresets in 'Components\FMOD_DX10.1\api\delphi\fmodpresets.pas',
  fmodtypes in 'Components\FMOD_DX10.1\api\delphi\fmodtypes.pas',
  GL in 'Components\ZombiEGL\GL.pas',
  GLext in 'Components\ZombiEGL\GLext.pas',
  GLU in 'Components\ZombiEGL\GLU.pas',
  ZGLMathProcs in 'Components\ZombiEGL\ZGLMathProcs.pas',
  ZGLGraphMath in 'Components\ZombiEGL\ZGLGraphMath.pas',
  Language in 'Language.pas',
  GlobalConsts in 'GlobalConsts.pas',
  GlobalTypes in 'GlobalTypes.pas',
  uSpecialFolders in 'Components\SpecialFolders\uSpecialFolders.pas',
  uConfig in 'uConfig.pas',
  uSfx in 'uSfx.pas',
  uSaveGame in 'uSaveGame.pas',
  uGraphicModes in 'Setup\uGraphicModes.pas',
  uSimpleLetters in 'uSimpleLetters.pas',
  uSmokesLogic in 'uSmokesLogic.pas',
  uSmokesRender in 'uSmokesRender.pas',
  uRenderConst in 'uRenderConst.pas',
  agfunit in 'Components\PowerDraw\Source\agfunit.pas',
  AGFUnitEmu in 'Components\PowerDraw\Source\AGFUnitEmu.pas',
  d3d9 in 'Components\PowerDraw\Source\d3d9.pas',
  DirectInput8 in 'Components\PowerDraw\Source\DirectInput8.pas',
  DXGCommon in 'Components\PowerDraw\Source\DXGCommon.pas',
  PDrawEx in 'Components\PowerDraw\Source\PDrawEx.pas',
  PGrafixReg in 'Components\PowerDraw\Source\PGrafixReg.pas',
  PowerDrawEmu in 'Components\PowerDraw\Source\PowerDrawEmu.pas',
  PowerInputs in 'Components\PowerDraw\Source\PowerInputs.pas',
  PowerTimers in 'Components\PowerDraw\Source\PowerTimers.pas',
  PowerTypes in 'Components\PowerDraw\Source\PowerTypes.pas',
  PStHandle in 'Components\PowerDraw\Source\PStHandle.pas',
  TGAReader in 'Components\PowerDraw\Source\TGAReader.pas',
  VTDbUnit in 'Components\PowerDraw\Source\VTDbUnit.pas',
  ZGLTextures in 'Components\ZombiEGL\ZGLTextures.pas',
  ZGLGraphProcs in 'Components\ZombiEGL\ZGLGraphProcs.pas',
  uSurvivorsLogic in 'uSurvivorsLogic.pas',
  uSurvivorsRender in 'uSurvivorsRender.pas',
  uRenderObjects in 'uRenderObjects.pas',
  uGameMath in 'uGameMath.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Retrofire';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TFormStart, FormStart);
  FormStart.Show;
  FormStart.Update;
  start;
  FormStart.close;
  Application.Run;

end.
