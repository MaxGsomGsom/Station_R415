unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uStationR415Form, Menus, uEducationR415DM,uTreningR415DM,
  consoleForm, navigForm, ExtCtrls, uTCPClienDM,u20normativ, uStationR415DM,
  uAnimationDM;

type
  TMainForm = class(TForm)
    mainMenu: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N11: TMenuItem;
    N3: TMenuItem;
    N12: TMenuItem;
    pnl1: TPanel;
    Label1: TLabel;
    grp1: TGroupBox;
    lbl1: TLabel;
    edt1: TEdit;
    lbl2: TLabel;
    edt2: TEdit;
    lbl3: TLabel;
    edt3: TEdit;
    btn1: TButton;
    grp2: TGroupBox;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    lbl10: TLabel;
    N13: TMenuItem;
    pnl2: TPanel;
    edt4: TEdit;
    mmo1: TMemo;
    btn2: TButton;
    lbl11: TLabel;
    lbl12: TLabel;
    lbl13: TLabel;
    lbl14: TLabel;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;

    procedure N2Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
  private
    { Private declarations }
  public
    TCPClient: TTCPClientR415;
        seconds : integer;
    procedure ChangeGenerateState20zadacha(gen:boolean);

    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.ChangeGenerateState20zadacha(gen:boolean);
begin
  StationR415Form.Zadacha20.GenerateState := gen;

  if gen = false then
    StationR415Form.StationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_2));

end;

procedure TMainForm.btn1Click(Sender: TObject);
var
  connectError, disconnectError: Integer;
begin
  if Self.btn1.Caption = '������������' then
  begin
    TCPClient := TTCPClientR415.Create;
    connectError := TCPClient.TryConnect(Self.edt3.Text,Self.edt1.Text,Self.edt2.Text);

    case connectError of
      0:
        begin
          Self.edt1.Enabled := False;
          Self.edt2.Enabled := False;
          Self.edt3.Enabled := False;

          Self.btn1.Caption := '�����������';

          Self.lbl4.Font.Color := clGreen;
          Self.lbl4.Caption := '������ � ��������';
        end;
      1:
        begin
          ShowMessage('������ �� ������.');
        end;
      2:
        begin
          ShowMessage('������ �� ��������.');
        end;
      3:
        begin
          ShowMessage('����� �������� ��� �����.');
        end
        else                                      // �� ��������������� ������
          begin
            ShowMessage('����������� ������ �����������!');
          end;
    end;
  end
  else
  begin
    disconnectError := TCPClient.TryDisconnect();

    if disconnectError = 0 then
    begin
      Self.btn1.Caption := '������������';

      self.lbl14.Caption := '-';
      self.lbl12.Caption := '-';

      Self.edt1.Enabled := true;
      Self.edt2.Enabled := true;
      Self.edt3.Enabled := true;

      Self.lbl4.Font.Color := clRed;
      Self.lbl4.Caption := '������ ���������';

      Self.btn2.Enabled := false;

      Self.n16.Visible := false;
    end;
  end;

end;

procedure TMainForm.btn2Click(Sender: TObject);
var
  text,tmp:string;
begin
    tmp := Self.edt4.Text;
//  text := StringReplace(tmp,',','.',[rfReplaceAll]);
    if Self.edt4.Enabled = true then
    begin
      if Pos(',', tmp) = 0 then
      begin
        TCPClient.SendTextMessage(text);
        Self.mmo1.Lines.Add('��: ' + tmp);
        Self.edt4.Text := '';

        StationR415Form.Zadacha20.SendMessage(tmp);
      end
      else
        ShowMessage('����������� ����� �� ����� �������.');
    end
    else
    begin
      ShowMessage('�� ���-�� ������� �� ���, ���� ����������� ������� ��� �� ���������.');
    end;

end;


//�����/���� 20 ������ �� ����
procedure TMainForm.btn3Click(Sender: TObject);
var
  prd,prm:Integer;
begin
  if Self.N16.Caption = '����������' then
  begin

      if Self.lbl10.Caption = '�������' then
      begin
        prd := Random(799);
          self.lbl14.Caption := IntToStr(prd);
        prm := Random(799);
          self.lbl12.Caption := IntToStr(prm);
        TCPClient.SendWaves(prd,prm);

        StationR415Form.Zadacha20 := TZadacha20.Create(StationR415Form.StationR415, StationR415Form.StationR415View,  TCPClient);
        StationR415Form.StationR415.DoChangeWorkType(3);
        Self.N16.Caption := '���������';
        Self.btn1.Enabled := False;

        StationR415Form.StationR415.ChangeWaves20Zadacha(StrToInt(self.lbl14.Caption),StrToInt(self.lbl12.Caption));

        formConsole.console.Clear;
        formConsole.console.items.Add('�� ����� � ����� ���������� 20 ������');
        formConsole.console.items.Add('� ������ ������ ����������� �����-���� ������...');
        formConsole.console.items.Add('������ � ����������� ������� ������� � "����->������"');

        Self.N2.Visible := false;
        Self.N11.Visible := False;
      end
      else
      begin

        if (self.lbl14.Caption = '0') and (self.lbl12.Caption = '0') then
          ShowMessage('��������� ���� ������� ������� �� ������ ������� ��� � ���.')
        else
        begin
          StationR415Form.Zadacha20 := TZadacha20.Create(StationR415Form.StationR415, StationR415Form.StationR415View, TCPClient);
          StationR415Form.StationR415.DoChangeWorkType(3);
          Self.N16.Caption := '���������';
          Self.btn1.Enabled := False;

          StationR415Form.StationR415.ChangeWaves20Zadacha(StrToInt(self.lbl14.Caption),StrToInt(self.lbl12.Caption));

          formConsole.console.Clear;
          formConsole.console.items.Add('�� ����� � ����� ���������� 20 ������');
          formConsole.console.items.Add('� ������ ������ ����������� �����-���� ������...');
          formConsole.console.items.Add('������ � ����������� ������� ������� � "����->������"');

          Self.N2.Visible := false;
          Self.N11.Visible := False;
        end;
      end;
  end
  else
  begin
    StationR415Form.Zadacha20.Destroy();
    Self.N16.Caption := '����������';
    Self.btn1.Enabled := true;
    Self.N2.Visible := true;
    Self.N11.Visible := true;
    formConsole.ShowStartMessage;
    Self.btn2.Enabled := False;
    Self.edt4.Enabled := False;

    StationR415Form.StationR415View.StateToDefaultAnimations();
    StationR415Form.StationR415.DoChangeWorkType(0);
  end;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  StationR415Form.Parent := MainForm;
  StationR415Form.Show;

  formConsole.Parent := MainForm;
  formConsole.Show;

  navigationForm.Parent := MainForm;
  navigationForm.Show;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TCPClient.TryDisconnect;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  TCPClient.TryDisconnect;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  formConsole.Left := Self.ClientWidth - formConsole.ClientWidth- 35;
  formConsole.Top := Self.ClientHeight - formConsole.ClientHeight-35;

  navigationForm.Top := Self.ClientHeight - formConsole.ClientHeight-35;
end;

procedure TMainForm.N10Click(Sender: TObject);
begin
  StationR415Form.EducationR415.EducationState := Regul_zatuh1;
  StationR415Form.EducationR415.onStationR415StateChange();
end;

procedure TMainForm.N11Click(Sender: TObject);
begin

    if MainForm.N11.Caption = '����������' then
    begin
      if (StationR415Form.StationR415.FinishTask = FEducation) or
        (StationR415Form.StationR415.FinishTask = FTreaning) or
        (StationR415Form.StationR415.FinishTask = FNormativ20) then
      begin
         //��������� ������ ����������
        MainForm.N11.Caption := '��������� ����������';
        MainForm.N2.Visible := False;
        mainform.N16.Visible := false;
        Self.Caption := '������������� ������� �-415 [����������]';

        formConsole.console.Clear;
        formConsole.console.items.Add('�� ����� � ����� ����������. ');

        StationR415Form.TreaningR415 := TTreaningR415.Create(StationR415Form.StationR415, StationR415Form.StationR415View);
        StationR415Form.StationR415.DoChangeWorkType(2);
      end
      else
        ShowMessage('��� ������ �� ����������. ������� � ���������� �������.')
    end
    else
    begin
       //���������� ������ ��������
        formConsole.console.Clear;
        StationR415Form.TreaningR415.ResetErrors();

        StationR415Form.StationR415.DoChangeWorkType(0);
        StationR415Form.TreaningR415.Destroy();
        Self.Caption := '������������� ������� �-415';

      MainForm.N11.Caption := '����������';
      MainForm.N2.Visible := true;
      mainform.N16.Visible := true;

      StationR415Form.StationR415View.StateToDefaultAnimations();
      formConsole.ShowStartMessage;
    end;

end;

procedure TMainForm.N12Click(Sender: TObject);
begin
  if self.pnl1.Visible = False then
  begin
    self.pnl1.Visible := True;
  end
  else
  begin
    self.pnl1.Visible := false;
  end;

end;

procedure TMainForm.N13Click(Sender: TObject);
begin
  if self.pnl2.Visible = False then
  begin
    self.pnl2.Visible := True;
  end
  else
  begin
    self.pnl2.Visible := false;
  end;
end;

procedure TMainForm.N14Click(Sender: TObject);
begin
  if formConsole.Visible = False then
  begin
    formConsole.Visible := True;
  end
  else
  begin
    formConsole.Visible := false;
  end;
end;

procedure TMainForm.N15Click(Sender: TObject);
begin
  if navigationForm.Visible = False then
  begin
    navigationForm.Visible := True;
  end
  else
  begin
    navigationForm.Visible := false;
  end;
end;

procedure TMainForm.N16Click(Sender: TObject);
var
  prd,prm:Integer;
begin

    if Self.N16.Caption = '����������' then
    begin
        if ((StationR415Form.StationR415.FinishTask = FTreaning) or
          (StationR415Form.StationR415.FinishTask = FNormativ20)) and (MainForm.lbl5.Caption <> '�������') then
        begin
           if Self.lbl10.Caption = '�������' then
           begin
              prd := Random(799);
                self.lbl14.Caption := IntToStr(prd);
              prm := Random(799);
                self.lbl12.Caption := IntToStr(prm);
              TCPClient.SendWaves(prd,prm);

              StationR415Form.Zadacha20 := TZadacha20.Create(StationR415Form.StationR415, StationR415Form.StationR415View, TCPClient);
              StationR415Form.StationR415.DoChangeWorkType(3);
              Self.N16.Caption := '���������';
              Self.btn1.Enabled := False;

              StationR415Form.StationR415.ChangeWaves20Zadacha(StrToInt(self.lbl14.Caption),StrToInt(self.lbl12.Caption));

              formConsole.console.Clear;
              formConsole.console.items.Add('�� ����� � ����� ���������� 20 ������');
              formConsole.console.items.Add('� ������ ������ ����������� �����-���� ������...');
              formConsole.console.items.Add('������ � ����������� ������� ������� � "����->������"');

              Self.N2.Visible := false;
              Self.N11.Visible := False;
            end
            else
            begin

              if (self.lbl14.Caption = '-') and (self.lbl12.Caption = '-') then
                ShowMessage('��������� ���� ������� ������� �� ������ ������� ��� � ���.')
              else
              begin
                StationR415Form.Zadacha20 := TZadacha20.Create(StationR415Form.StationR415, StationR415Form.StationR415View, TCPClient);
                StationR415Form.StationR415.DoChangeWorkType(3);
                Self.N16.Caption := '���������';
                Self.btn1.Enabled := False;

                StationR415Form.StationR415.ChangeWaves20Zadacha(StrToInt(self.lbl14.Caption),StrToInt(self.lbl12.Caption));

                formConsole.console.Clear;
                formConsole.console.items.Add('�� ����� � ����� ���������� 20 ������');
                formConsole.console.items.Add('� ������ ������ ����������� �����-���� ������...');
                formConsole.console.items.Add('������ � ����������� ������� ������� � "����->������"');

                Self.N2.Visible := true;
                Self.N11.Visible := true;
              end;
            end;
        end
        else
          ShowMessage('��� ������ �� ����������. ������� � ���������� �������.');

    end
    else
    begin
      StationR415Form.Zadacha20.ResetErrors();

      StationR415Form.Zadacha20.Destroy();
      Self.N16.Caption := '����������';
      Self.btn1.Enabled := true;
      Self.N2.Visible := true;
      Self.N11.Visible := true;
      formConsole.ShowStartMessage;
      Self.btn2.Enabled := False;
      Self.edt4.Enabled := False;

      self.lbl14.Caption := '-';
      self.lbl12.Caption := '-';

      StationR415Form.StationR415View.StateToDefaultAnimations();
      StationR415Form.StationR415.DoChangeWorkType(0);
    end;


end;


procedure TMainForm.N2Click(Sender: TObject);
var
  i: integer;
begin
  StationR415Form.StationR415.StateToDefaultPeriphery;

  if MainForm.N2.Caption = '��������' then
  begin
    //��������� ������ ��������
    formConsole.console.Clear;
    formConsole.console.items.Add('�� ����� � ����� ��������. ');
    StationR415Form.EducationR415 := TEducationR415.Create(StationR415Form.StationR415, StationR415Form.StationR415View);
    MainForm.N2.Caption := '��������� ��������';
    Self.Caption := '������������� ������� �-415 [��������]';

    StationR415Form.StationR415.DoChangeWorkType(1);

    ShowMessage('�� ����� � ����� ��������.'#13
      + '�������� ���������, ����������� � ������� ���������.'#13
      + '���������� ����������� ��� ���������� �������.');
    StationR415Form.StationR415View.StateToDefaultAnimations();

    MainForm.N11.Visible := false;
    mainform.N16.Visible := false;
  end
  else
    if MainForm.N2.Caption = '��������� ��������' then
    begin
      //���������� ������ ��������
      formConsole.console.Clear;
      StationR415Form.EducationR415.Destroy();
      MainForm.N2.Caption := '��������';
      Self.Caption := '������������� ������� �-415';

      StationR415Form.StationR415View.StateToDefaultAnimations();

      MainForm.N11.Visible := True;
      mainform.N16.Visible := true;

      formConsole.ShowStartMessage;

      if StationR415Form.StationR415.Level = 2 then
      begin
        MainForm.N11.Enabled := true;
      end;
      //������� ������� �� ������������� ������
      for I := 0 to StationR415Form.StationR415View.Switches.Count - 1 do
      begin
        StationR415Form.StationR415View.Switches[I].changeProperties := true;
      end;
    end;
end;

procedure TMainForm.N4Click(Sender: TObject);
begin
  StationR415Form.EducationR415.EducationState := Vn_osm;
  StationR415Form.EducationR415.onStationR415StateChange();
end;

procedure TMainForm.N5Click(Sender: TObject);
begin
  StationR415Form.EducationR415.EducationState := Ust_org_v_ish_pol;
  StationR415Form.EducationR415.onStationR415StateChange();
end;

procedure TMainForm.N6Click(Sender: TObject);
begin
  if Self.Caption = '������������� ������� �-415 [��������]' then
  begin
  StationR415Form.EducationR415.EducationState := Vkl_pit;
  StationR415Form.EducationR415.onStationR415StateChange();
  end;

  if Self.Caption = '������������� ������� �-415 [����������]' then
  begin
    StationR415Form.TreaningR415.EducationState := Vkl_pit_t;
    StationR415Form.TreaningR415.onStationR415StateChange();
  end;
end;

procedure TMainForm.N7Click(Sender: TObject);
begin
  StationR415Form.EducationR415.EducationState := Nastr;
  StationR415Form.EducationR415.onStationR415StateChange();
end;

procedure TMainForm.N8Click(Sender: TObject);
begin
  if Self.Caption = '������������� ������� �-415 [��������]' then
  begin
    StationR415Form.EducationR415.EducationState := Prov_rab;
    StationR415Form.EducationR415.onStationR415StateChange();
  end;

  if Self.Caption = '������������� ������� �-415 [����������]' then
  begin
    StationR415Form.TreaningR415.EducationState := Prov_rab_t;
    StationR415Form.TreaningR415.onStationR415StateChange();
  end;
end;

procedure TMainForm.N9Click(Sender: TObject);
begin
  StationR415Form.EducationR415.EducationState := Ust_sv;
  StationR415Form.EducationR415.onStationR415StateChange();
end;

end.
