unit UnitStart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TFormStart = class(TForm)
    pnlBack: TPanel;
    lbTitle: TLabel;
    progres: TProgressBar;
    lbLoading: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormStart: TFormStart;

implementation
uses
  Language, GlobalConsts;

{$R *.dfm}

procedure TFormStart.FormCreate(Sender: TObject);
begin
  lbTitle.Caption := PROGRAM_TITLE + ' ' + STR_PROGRAM_VER + ' ' + PROGRAM_VERSION;
  lbLoading.Caption := STR_APP_LOADING;
end;

end.
