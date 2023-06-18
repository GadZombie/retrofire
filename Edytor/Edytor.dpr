program Project1;

uses
  Forms,
  windows,
  Unit1 in 'Unit1.pas' {Form1},
  UnitEpizody in 'UnitEpizody.pas' {FormEpizody};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Retrofire edytor map';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormEpizody, FormEpizody);
  Application.Run;
end.
