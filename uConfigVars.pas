unit uConfigVars;

interface
uses
  uSpecialFolders;

const
  VendorName = 'GadzPl';
  ApplicationName = 'Retrofire';
  ApplicationDataFolder = VendorName + '\' + ApplicationName;


function GetUserDataFolder: string;
function GetConfigFilePath: string;
function GetSaveGamesFilePath: string;

implementation

const
  ConfigFileName = 'RetrofireGame.config';
  SaveGameFileName = 'RetrofireSaveGame.config';

function GetUserDataFolder: string;
begin
  result := MakeSpecialDir(FolderUser, ApplicationDataFolder);
end;

function GetConfigFilePath: string;
begin
  result := GetUserDataFolder + ConfigFileName;
end;

function GetSaveGamesFilePath: string;
begin
  result := GetUserDataFolder + SaveGameFileName;
end;

end.
