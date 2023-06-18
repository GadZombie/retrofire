unit UnitStart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TFormStart = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    progres: TProgressBar;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormStart: TFormStart;

implementation

{$R *.dfm}

end.
