program Project1;

uses
  Forms,
  Sysutils,
  OpenGl,
  api_func in 'api_func.pas',
  Unit1 in 'Unit1.pas' {Form1},
  unittimer in 'unittimer.pas',
  Render in 'Render.pas',
  UnitTex in 'UnitTex.pas',
  UnitStart in 'UnitStart.pas' {FormStart},
  OBJ in '..\..\KomponentyBiblioteki\ZombiEGL\OBJ.pas',
  fmod in '..\..\KomponentyBiblioteki\FMOD_DX10.1\api\delphi\fmod.pas',
  fmoddyn in '..\..\KomponentyBiblioteki\FMOD_DX10.1\api\delphi\fmoddyn.pas',
  fmoderrors in '..\..\KomponentyBiblioteki\FMOD_DX10.1\api\delphi\fmoderrors.pas',
  fmodpresets in '..\..\KomponentyBiblioteki\FMOD_DX10.1\api\delphi\fmodpresets.pas',
  fmodtypes in '..\..\KomponentyBiblioteki\FMOD_DX10.1\api\delphi\fmodtypes.pas',
  GL in '..\..\KomponentyBiblioteki\ZombiEGL\GL.pas',
  GLext in '..\..\KomponentyBiblioteki\ZombiEGL\GLext.pas',
  GLU in '..\..\KomponentyBiblioteki\ZombiEGL\GLU.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Retrofire';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormStart, FormStart);
  FormStart.Show;
  FormStart.Update;
  start;
  FormStart.close;
  Application.Run;

end.
