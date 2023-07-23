program LevelEditor;

uses
  Forms,
  windows,
  uEditor in 'uEditor.pas' {Form1},
  uEpisodes in 'uEpisodes.pas' {FormEpizody},
  GlobalConsts in '..\GlobalConsts.pas',
  GlobalTypes in '..\GlobalTypes.pas',
  GL in '..\Components\ZombiEGL\GL.pas',
  OBJ in '..\Components\ZombiEGL\OBJ.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Retrofire edytor map';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormEpizody, FormEpizody);
  Application.Run;
end.
