program R415;

uses
  Forms,
  main in 'main.pas' {MainForm},
  consoleForm in 'consoleForm.pas' {formConsole},
  uAnimationDM in 'uAnimationDM.pas',
  uEducationR415DM in 'uEducationR415DM.pas',
  uLabelDM in 'uLabelDM.pas',
  uLampDM in 'uLampDM.pas',
  uRotateImage in 'uRotateImage.pas',
  uStationR415DM in 'uStationR415DM.pas',
  uStationR415Form in 'uStationR415Form.pas' {StationR415Form},
  uStationR415ViewDM in 'uStationR415ViewDM.pas',
  uSwitchDM in 'uSwitchDM.pas',
  uTreningR415DM in 'uTreningR415DM.pas',
  navigForm in 'navigForm.pas' {navigationForm},
  uRequestDM in 'local\uRequestDM.pas',
  uKeyValueDM in 'local\uKeyValueDM.pas',
  uTCPClienDM in 'local\uTCPClienDM.pas',
  uResponseListenerDM in 'local\uResponseListenerDM.pas',
  uClientStateDM in 'local\uClientStateDM.pas',
  uConstantsDM in 'local\uConstantsDM.pas',
  u20normativ in 'u20normativ.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TStationR415Form, StationR415Form);
  Application.CreateForm(TformConsole, formConsole);
  Application.CreateForm(TStationR415Form, StationR415Form);
  Application.CreateForm(TnavigationForm, navigationForm);
  Application.Run;
end.
