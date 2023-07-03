unit uGraphicModes;

interface

uses
  Windows,
  System.Generics.Collections,
  System.Generics.Defaults,
  Sysutils;

type
  TGraphicsMode = class
    x, y, bpp, hz: integer;
    visual: string;
  end;

  TChangeDisplaySettingsEx2 = function (lpszDeviceName: LPCWSTR; lpDevMode: PDeviceModeW;
        wnd: HWND; dwFlags: DWORD; lParam: Pointer): Longint; stdcall;

  TGraphicsModeList = TObjectList<TGraphicsMode>;

  function GetGraphicsModes: TGraphicsModeList;
  function GetCurrentDeviceName: string;

  function FullScreenOff(DeviceName: string): longint; overload;
  function FullScreenOff: longint; overload;

implementation

//function ChangeDisplaySettingsEx2; external user32 name 'ChangeDisplaySettingsW';

function GetGraphicsModes: TGraphicsModeList;
var
  a: integer;
  DevMode: TDevMode;
  tmp: TGraphicsMode;
begin

  result := TGraphicsModeList.Create;
  a := 0;
  while EnumDisplaySettings(nil, a, DevMode) do
  begin

    if DevMode.dmBitsPerPel >= 16 then
    begin
      tmp := TGraphicsMode.Create;
      tmp.x := DevMode.dmPelsWidth;
      tmp.y := DevMode.dmPelsHeight;
      tmp.bpp := DevMode.dmBitsPerPel;
      tmp.hz := DevMode.dmDisplayFrequency;
      tmp.visual := Format('%4d x %4d     %2d bpp     %3d Hz',
        [tmp.x, tmp.y, tmp.bpp, tmp.hz]);
      result.Add(tmp);
    end;

    Inc(a);
  end;

  result.Sort(tcomparer<TGraphicsMode>.construct(
    function(const L, R: TGraphicsMode): integer
    begin
      result := L.x - R.x;

      if result = 0 then
        result := L.y - R.y;

      if result = 0 then
        result := L.bpp - R.bpp;

      if result = 0 then
        result := L.hz - R.hz;

    end));

end;

function GetCurrentDeviceName: string;
var
  Dev: TDisplayDevice;
  n: integer;
begin
  fillchar(dev, sizeof(dev), 0);
  dev.cb := sizeof(dev);
  n :=0;
  if EnumDisplayDevices(nil, n, Dev, 0) then
  begin
    result := Dev.DeviceName;
    inc(n);
  end
  else
    result := '';
end;

function FullScreenOff(DeviceName: string): longint;
var
  ChangweDisplaySettingsFnc: TChangeDisplaySettingsEx2;
  dllHandle: THandle;
  dllName: string;
begin
  dllName := user32;
  dllHandle := LoadLibrary( pwidechar(dllName) );
  try
    @ChangweDisplaySettingsFnc := getprocaddress(dllHandle, 'ChangeDisplaySettingsW');
    result := ChangweDisplaySettingsFnc(nil, nil, 0, 0, nil);
  finally
    FreeLibrary(dllHandle);
  end;
end;

function FullScreenOff: longint;
begin
  result := FullScreenOff(GetCurrentDeviceName);
end;

end.
