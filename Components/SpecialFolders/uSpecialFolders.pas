unit uSpecialFolders;

interface

const
  FolderAllUsers = '$AllUsers';
  FolderUser = '$User';
  FolderCommonAppdata = '$CommonAppData';

function GetSpecialFolderPath(folder: integer): string;
function MakeSpecialDir(specialfolder, subfolder: string): string;

implementation

uses
  SysUtils,
  Winapi.ShlObj;

// -----------------------------------------------------------------------------
{
  //[Current User]\My Documents
  0: specialFolder := CSIDL_PERSONAL;
  //All Users\Application Data
  1: specialFolder := CSIDL_COMMON_APPDATA;
  //[User Specific]\Application Data
  2: specialFolder := CSIDL_LOCAL_APPDATA;
  //Program Files
  3: specialFolder := CSIDL_PROGRAM_FILES;
  //All Users\Documents
  4: specialFolder := CSIDL_COMMON_DOCUMENTS;

}
function GetSpecialFolderPath(folder: integer): string;
const
  SHGFP_TYPE_CURRENT = 0;
  MAX_PATH = 1024;
var
  path: array [0 .. MAX_PATH] of char;
begin
  if SHGetFolderPath(0, folder, 0, SHGFP_TYPE_CURRENT, @path[0]) = 0 then
  begin
    Result := path;
    if length(Result) >= 1 then
      Result := IncludeTrailingPathDelimiter(Result);
  end
  else
    Result := '';
end;

function MakeSpecialDir(specialfolder, subfolder: string): string;
begin
  if specialfolder = FolderAllUsers then
    specialfolder := GetSpecialFolderPath(CSIDL_COMMON_APPDATA)
  else
  if specialfolder = FolderUser then
    specialfolder := GetSpecialFolderPath(CSIDL_APPDATA)
  else
  if specialfolder = FolderCommonAppdata then
    specialfolder := GetSpecialFolderPath(CSIDL_COMMON_APPDATA);

  specialfolder := IncludeTrailingPathDelimiter(specialfolder);
  specialfolder := IncludeTrailingPathDelimiter(specialfolder + subfolder);

  Result := specialfolder;
end;

end.
