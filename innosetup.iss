[Setup]
AppName=AtomicMail
AppVersion=0.7.6
DefaultDirName={pf}\AtomicMail
DefaultGroupName=AtomicMail
OutputDir=output
OutputBaseFilename=AtomicMailInstaller
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\AtomicMail"; Filename: "{app}\app.exe"
Name: "{group}\Uninstall AtomicMail"; Filename: "{uninstallexe}"