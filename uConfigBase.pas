unit uConfigBase;

interface
uses
  System.IOUtils,
  System.SysUtils,
  System.JSON;

type
  TConfigBase = class
  protected
    fileName: string;
    procedure SaveData(data: TJSONObject); virtual; abstract;
    procedure LoadData(data: TJSONObject); virtual; abstract;
  public
    JsonHeader: string;

    constructor Create(fileName: string); virtual;
    destructor Destroy; override;

    procedure SaveConfig;
    procedure LoadConfig;
  end;


implementation

{ TConfigBase }

constructor TConfigBase.Create(fileName: string);
begin
  inherited Create;
  self.fileName := fileName;
end;

destructor TConfigBase.Destroy;
begin

  inherited;
end;

procedure TConfigBase.LoadConfig;
var
  data: TJSONObject;
  s: string;
begin
  data := TJSONObject.Create;
  try
    s := TFile.ReadAllText(fileName);
    data.Parse(BytesOf(s), 0);
    if s <> '' then
      LoadData(data);
  finally
    data.Free;
  end;
end;

procedure TConfigBase.SaveConfig;
var
  data: TJSONObject;
begin
  data := TJSONObject.Create;
  try
    if JsonHeader <> '' then
      data.AddPair('Header', TJSONString.Create(JsonHeader));
    SaveData(data);
    ForceDirectories(ExtractFileDir(fileName));
    TFile.WriteAllText(fileName, data.ToString);
  finally
    data.Free;
  end;
end;


end.
