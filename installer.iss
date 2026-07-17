#define MyAppName "المتميزون"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "GIDtEAM"
#define MyAppExeName "al_mumtazun.exe"


[Setup]

AppId={{YOUR-UNIQUE-ID-HERE}

AppName={#MyAppName}

AppVersion={#MyAppVersion}

AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\{#MyAppName}

DefaultGroupName={#MyAppName}

OutputDir=installer

OutputBaseFilename=al_mumtazunSetup

Compression=lzma

SolidCompression=yes

WizardStyle=modern


SetupIconFile=app_icon.ico



[Files]

Source: "build\windows\x64\runner\Release\*"; \
DestDir: "{app}"; \
Flags: recursesubdirs createallsubdirs



[Icons]

Name: "{autodesktop}\{#MyAppName}"; \
Filename: "{app}\{#MyAppExeName}"

Name: "{group}\{#MyAppName}"; \
Filename: "{app}\{#MyAppExeName}"



[Run]

Filename: "{app}\{#MyAppExeName}"; \
Description: "Launch {#MyAppName}"; \
Flags: nowait postinstall skipifsilent