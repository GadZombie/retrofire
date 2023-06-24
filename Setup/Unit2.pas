unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PowerTimers, PowerInputs, StdCtrls, ExtCtrls, PowerTypes;

type
  TForm2 = class(TForm)
    PowerTimer1: TPowerTimer;
    Panel1: TPanel;
    Label1: TLabel;
    PowerInput1: TPowerInput;
    procedure PowerTimer1Process(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ktoryklawisz:byte;
  end;

var
  Form2: TForm2;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm2.PowerTimer1Process(Sender: TObject);
var a:integer;
begin
 a:=PowerInput1.Update;
 if a<>0 then exit;

 if PowerInput1.Keys[1] then begin
    form2.Close;
    form2.PowerTimer1.MayProcess:=false;
    exit;
 end;

 a:=2;
 while a<=255 do begin
    if PowerInput1.Keys[a] then begin
       klawisze[ktoryklawisz]:=a;
       form1.klawisze_zmien[ktoryklawisz].caption:=PowerInput1.KeyName[klawisze[ktoryklawisz]];
       form2.Close;
       form2.PowerTimer1.MayProcess:=false;
       break;
    end;
    inc(a);
 end;

end;

procedure TForm2.FormCreate(Sender: TObject);
begin
PowerInput1.Initialize();
end;

end.
