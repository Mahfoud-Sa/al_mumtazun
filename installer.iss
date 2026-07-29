#define MyAppName "المتميزون"
#define MyAppVersion "2.8.4"
#define MyAppPublisher "GIDtEAM"
#define MyAppExeName "engineering_ops_dashboard.exe"


[Setup]

AppId={{C8F6E87A-286A-4A8E-985B-3D28E0124D69}}

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


SetupIconFile=windows\runner\resources\app_icon.ico



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