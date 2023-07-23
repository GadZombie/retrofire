unit uEpisodes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, Buttons, ExtCtrls, Menus, Vcl.Mask;

type
  TFormEpizody = class(TForm)
    ListaMap: TListBox;
    MapyEpizodu: TListBox;
    btndodaj: TSpeedButton;
    btnusun: TSpeedButton;
    btndol: TSpeedButton;
    btngora: TSpeedButton;
    PanelListaMap: TPanel;
    PanelMapyEpizodu: TPanel;
    Tytulepizodu: TLabeledEdit;
    MainMenu1: TMainMenu;
    Epizod1: TMenuItem;
    Zapisz1: TMenuItem;
    Nowy1: TMenuItem;
    Wczytaj1: TMenuItem;
    N1: TMenuItem;
    Zamknijokno1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure odswiezpanele;
    procedure ListaMapDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure MapyEpizoduDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure MapyEpizoduDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListaMapDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btngoraClick(Sender: TObject);
    procedure btndolClick(Sender: TObject);
    procedure btndodajClick(Sender: TObject);
    procedure btnusunClick(Sender: TObject);
    procedure Nowy1Click(Sender: TObject);
    procedure Zapisz1Click(Sender: TObject);
    procedure Wczytaj1Click(Sender: TObject);
    procedure Zamknijokno1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormEpizody: TFormEpizody;

implementation

uses uEditor;

{$R *.dfm}

procedure TFormEpizody.ListaMapDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TListBox) and ((Source as TListBox).tag = 1);
end;

procedure TFormEpizody.ListaMapDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if (Sender is TListBox) and (Source is TListBox) then
  begin
    (Source as TListBox).Items.Delete((Source as TListBox).ItemIndex);
    odswiezpanele;
  end;
end;

procedure TFormEpizody.MapyEpizoduDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  Accept := (Source is TListBox) and ((Source as TListBox).tag = 0);
end;

procedure TFormEpizody.MapyEpizoduDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  w: string;
  a: Integer;
begin
  if (Sender is TListBox) and (Source is TListBox) and ((Source as TListBox).ItemIndex >= 0) and
    ((Source as TListBox).ItemIndex <= (Source as TListBox).Items.Count - 1) then
  begin
    w := (Source as TListBox).Items[(Source as TListBox).ItemIndex];
    a := 0;
    while (a < (Sender as TListBox).Items.Count) and ((Sender as TListBox).Items[a] <> w) do
      inc(a);
    if a >= (Sender as TListBox).Items.Count then
      (Sender as TListBox).Items.Add(w);
    odswiezpanele;
  end;
end;

procedure TFormEpizody.odswiezpanele;
begin
  PanelListaMap.Caption := 'Liczba map: ' + inttostr(ListaMap.Items.Count);
  PanelMapyEpizodu.Caption := 'Map w epizodzie: ' + inttostr(MapyEpizodu.Items.Count);
end;

procedure TFormEpizody.FormShow(Sender: TObject);
var
  sr: TSearchRec;
  FileAttrs: Integer;
  s: string;
begin
  ListaMap.Clear;
  FileAttrs := $7FFFFFFF;
  if FindFirst('ExtraMissions\*.map', FileAttrs, sr) = 0 then
  begin
    repeat
      if (sr.Attr and FileAttrs) = sr.Attr then
      begin
        s := sr.name;
        if pos(lowercase('.map'), s) > 0 then
          Delete(s, pos(lowercase('.map'), s), 4);
        ListaMap.Items.Add(s);
      end;
    until FindNext(sr) <> 0;
    SysUtils.FindClose(sr);
  end;
  odswiezpanele;
end;

procedure TFormEpizody.btngoraClick(Sender: TObject);
var
  s: string;
begin
  if (MapyEpizodu.Items.Count >= 1) and (MapyEpizodu.ItemIndex >= 1) then
  begin
    s := MapyEpizodu.Items[MapyEpizodu.ItemIndex];
    MapyEpizodu.Items[MapyEpizodu.ItemIndex] := MapyEpizodu.Items[MapyEpizodu.ItemIndex - 1];
    MapyEpizodu.Items[MapyEpizodu.ItemIndex - 1] := s;
    MapyEpizodu.ItemIndex := MapyEpizodu.ItemIndex - 1;
  end;
end;

procedure TFormEpizody.btndolClick(Sender: TObject);
var
  s: string;
begin
  if (MapyEpizodu.Items.Count >= 1) and (MapyEpizodu.ItemIndex >= 0) and
    (MapyEpizodu.ItemIndex <= MapyEpizodu.Items.Count - 2) then
  begin
    s := MapyEpizodu.Items[MapyEpizodu.ItemIndex];
    MapyEpizodu.Items[MapyEpizodu.ItemIndex] := MapyEpizodu.Items[MapyEpizodu.ItemIndex + 1];
    MapyEpizodu.Items[MapyEpizodu.ItemIndex + 1] := s;
    MapyEpizodu.ItemIndex := MapyEpizodu.ItemIndex + 1;
  end;
end;

procedure TFormEpizody.btndodajClick(Sender: TObject);
var
  w: string;
  a: Integer;
begin
  if (ListaMap.ItemIndex >= 0) and (ListaMap.ItemIndex <= ListaMap.Items.Count - 1) then
  begin
    w := ListaMap.Items[ListaMap.ItemIndex];
    a := 0;
    while (a < MapyEpizodu.Items.Count) and (MapyEpizodu.Items[a] <> w) do
      inc(a);
    if a >= MapyEpizodu.Items.Count then
      MapyEpizodu.Items.Add(w);
    odswiezpanele;
  end;
end;

procedure TFormEpizody.btnusunClick(Sender: TObject);
begin
  if (MapyEpizodu.ItemIndex >= 0) and (MapyEpizodu.ItemIndex <= MapyEpizodu.Items.Count - 1) then
  begin
    MapyEpizodu.Items.Delete(MapyEpizodu.ItemIndex);
    odswiezpanele;
  end;
end;

procedure TFormEpizody.Nowy1Click(Sender: TObject);
begin
  MapyEpizodu.Items.Clear;
  Tytulepizodu.Text := 'Nowy epizod';
  odswiezpanele;
end;

procedure TFormEpizody.Zapisz1Click(Sender: TObject);
var
  a, b, i: Integer;
  f: tstream;
  bt: byte;
  r: real;
begin
  odswiezpanele;
  if SaveDialog1.FileName = '' then
    SaveDialog1.FileName := trim(Tytulepizodu.Text);
  if SaveDialog1.Execute then
  begin
    f := nil;
    try
      try
        f := TFileStream.Create(SaveDialog1.FileName, fmCreate);

        zapiszstring(f, Tytulepizodu.Text);

        b := MapyEpizodu.Items.Count;
        f.WriteBuffer(b, sizeof(b));
        for a := 0 to MapyEpizodu.Items.Count - 1 do
        begin
          zapiszstring(f, MapyEpizodu.Items[a]);
        end;

        f.Free;
        f := nil;
      except
        if f <> nil then
        begin
          f.Free;
          f := nil;
        end;
        MessageBox(Handle, pchar('B³¹d podczas zapisu pliku'), 'B³¹d', MB_OK + MB_TASKMODAL + MB_ICONERROR);
      end;
    finally
      if f <> nil then
      begin
        f.Free;
        f := nil;
      end;
      OpenDialog1.FileName := SaveDialog1.FileName;
    end;
  end;

end;

procedure TFormEpizody.Wczytaj1Click(Sender: TObject);
var
  a, b, i: Integer;
  f: tstream;
  bt, br, bg, bb: byte;
  r: real;
begin
  if OpenDialog1.Execute then
  begin
    f := nil;
    try
      try
        f := TFileStream.Create(OpenDialog1.FileName, fmopenread);

        Tytulepizodu.Text := wczytajstring(f);

        MapyEpizodu.Items.Clear;

        f.ReadBuffer(b, sizeof(b));
        for a := 0 to b - 1 do
        begin
          MapyEpizodu.Items.Add(wczytajstring(f));
        end;

        f.Free;
        f := nil;
      except
        if f <> nil then
        begin
          f.Free;
          f := nil;
        end;
        MessageBox(Handle, pchar('B³¹d podczas odczytu pliku'), 'B³¹d', MB_OK + MB_TASKMODAL + MB_ICONERROR);
      end;
    finally
      if f <> nil then
      begin
        f.Free;
        f := nil;
      end;
      SaveDialog1.FileName := OpenDialog1.FileName;
    end;
  end;
  odswiezpanele;
end;

procedure TFormEpizody.Zamknijokno1Click(Sender: TObject);
begin
  close;
end;

end.
