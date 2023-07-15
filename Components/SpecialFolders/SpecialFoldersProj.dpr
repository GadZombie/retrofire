program SpecialFoldersProj;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uSpecialFolders in 'uSpecialFolders.pas';

const
  VendorName = 'Zombie Mastah';
  ApplicationName = 'My SuperGame';
  ApplicationDataFolder = VendorName + '\' + ApplicationName;

begin
  try
    writeln('FolderAllUsers = ', MakeSpecialDir(FolderAllUsers, '') );
    writeln('FolderUser = ', MakeSpecialDir(FolderUser, ApplicationDataFolder) );
    writeln('FolderCommonAppdata = ', MakeSpecialDir(FolderCommonAppdata, '') );

    readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
