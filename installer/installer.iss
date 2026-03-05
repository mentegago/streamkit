; Inno Setup script for StreamKit Windows installer.
; For CI use: SourceDir, OutputDir, and MyAppVersion must be passed via /D flags.
; Example:
;   ISCC.exe /DMyAppVersion=0.10.1 /DSourceDir=build\windows\x64\runner\Release /DOutputDir=installer\builds installer\installer.iss

#define MyAppName "StreamKit"
#define MyAppSubName "Chat Reader"
#define MyAppPublisher "Mentega Goreng"
#define MyAppURL "https://github.com/mentegago/streamkit"
#define MyAppExeName "streamkit.exe"

[Setup]
AppId={{FC018FFD-842E-4066-B223-2035036C6E5B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\Mentega StreamKit\{#MyAppSubName}
DisableProgramGroupPage=yes
PrivilegesRequiredOverridesAllowed=commandline
OutputDir={#OutputDir}
OutputBaseFilename=StreamKit_{#MyAppVersion}_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName} {#MyAppSubName}

[Messages]
SetupAppTitle={#MyAppName} {#MyAppVersion} Setup
SetupWindowTitle=Setup - {#MyAppName} {#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
