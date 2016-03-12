unit uStationR415Form;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  pngimage,
  Menus,
  uSwitchDM,
  Generics.Collections,
  uStationR415ViewDM,
  uStationR415DM,
  uEducationR415DM,
  uTreningR415DM,
  u20normativ,
  StdCtrls,
  uAnimationDM, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient;

type
  TStationR415Form = class(TForm)
    imgStationR415: TImage;
    imgControlLevelSwitch: TImage;
    imgPVUSwitch: TImage;
    imgFirstPhoneFirstSwitch: TImage;
    imgFirstPhoneSecondSwitch: TImage;
    imgCallFirstSwitch: TImage;
    imgCallSecondSwitch: TImage;
    imgEnabledDisabledFirst: TImage;
    imgEnabledDisabledSecond: TImage;
    imgBroadcastFirstSwitch: TImage;
    imgReceptionFirstSwitch: TImage;
    imgBroadcastSecondSwitch: TImage;
    imgReceptionSecondSwitch: TImage;
    imgBroadcastThridSwitch: TImage;
    imgReceptionThridSwitch: TImage;
    imgWorkReceptionBroadcastSwitch: TImage;
    imgIndicationSwitch: TImage;
    imgEnabledDisabledDoubleReception: TImage;
    imgEnabledDisabledPowerLowNormal: TImage;
    imgSupplyFirstSwitch: TImage;
    imgSupplySecondSwitch: TImage;

    imgDownUpFirstSwitch: TImage;
    imgDownUpSecondSwitch: TImage;
    imgDownUpThirdSwitch: TImage;
    imgDownUpForthSwitch: TImage;
    imgDownUpFifthSwitch: TImage;
    imgDownUp6Switch: TImage;
    imgDownUp7Switch: TImage;
    imgDownUp8Switch: TImage;
    imgDownUp9Switch: TImage;
    prd1: TLabel;
    prd2: TLabel;
    prd3: TLabel;
    prm1: TLabel;
    prm2: TLabel;
    prm3: TLabel;
    imgPhone: TImage;
    imgLamp1: TImage;
    imgLamp2: TImage;
    imgLamp3: TImage;
    imgLamp4: TImage;
    imgLamp5: TImage;
    imgLamp6: TImage;
    imgLamp7: TImage;
    imgLamp8: TImage;
    imgLamp9: TImage;
    imgLamp10: TImage;
    imgDisplay2: TImage;
    imgDisplay1: TImage;
    imgLevel1: TImage;
    imgLevel2: TImage;
    imgAntena: TImage;//-
    procedure FormCreate(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure btn1Click(Sender: TObject);
    procedure imgStationR415Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  private

  public
    StationR415: TStationR415;
    StationR415View: TStationR415View;
    EducationR415: TEducationR415;
    TreaningR415: TTreaningR415;
    Zadacha20: TZadacha20;


    procedure InitSwitches;
  end;

var
  StationR415Form: TStationR415Form;

implementation

uses navigForm;

{$R *.dfm}


  /// <summary>
  /// �����������. ���������� ����� ������������� "��������������".
  /// </summary>
procedure TStationR415Form.btn1Click(Sender: TObject);
begin

end;

//���������� ��������� ��������� ��������� � �������
procedure TStationR415Form.FormCreate(Sender: TObject);
  begin
    StationR415 := TStationR415.Create();
    StationR415View := TStationR415View.Create;
    InitSwitches;

  end;


procedure TStationR415Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = 32 then
  begin
    StationR415.PhoneButton := true;
    if StationR415.WorkType = Education then
      EducationR415.onStationR415StateChange();
    if StationR415.WorkType = Treaning then
      TreaningR415.CheckWork();
  end;

  if Key = 81 then
  begin
    if StationR415.WorkType = Treaning then
      TreaningR415.ShowQuestion;
  end;
end;

procedure TStationR415Form.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Key = 32 then
  begin
    StationR415.PhoneButton := false;
  end;
end;

procedure TStationR415Form.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if WheelDelta < 0 then
  begin
    StationR415Form.VertScrollBar.Position := StationR415Form.VertScrollBar.Position +  50;
  end
  else
  begin
    StationR415Form.VertScrollBar.Position := StationR415Form.VertScrollBar.Position -  50;
  end;


end;

procedure TStationR415Form.imgStationR415Click(Sender: TObject);
begin
  self.SetFocus;
end;

/// <summary>
  /// ���������� ������������� "��������������" � �������� �� �������
  /// ������������ (��������� ���������) ���������.
  /// </summary>
procedure TStationR415Form.InitSwitches;
  var
    Event: TSwitchChangeStateEvent;
  begin
    //0. ���
    Event := StationR415.DoChangePhone;
    StationR415View.AddSwitch(imgPhone, 'Disabled,Enabled',SwitchType_Phone,Event);
    //1. I���-II���. ����� ������ ��
    Event := StationR415.DoChangeControlLelevSwitch;
    StationR415View.AddSwitch(imgControlLevelSwitch,
        '225,270,292.5,337.5,0,22.5,67.5,90,135', SwitchType_Switch, Event);
    //2. ���
    Event := StationR415.DoChangePVUSwitch;
    StationR415View.AddSwitch(imgPVUSwitch,
        '315,0,45', SwitchType_Switch, Event);
    //3. I���
    Event := StationR415.DoPhoneFirstSwitch;
    StationR415View.AddSwitch(imgFirstPhoneFirstSwitch,
        '315,0,45', SwitchType_Switch, Event);
    //4. II���
    Event := StationR415.DoPhoneSecondSwitch;
    StationR415View.AddSwitch(imgFirstPhoneSecondSwitch,
        '315,0,45', SwitchType_Switch, Event);
    //5. �����. ���. ���� ���1
    Event := StationR415.DoCallFirstSwitch;
    StationR415View.AddSwitch(imgCallFirstSwitch,
        '315,0,45', SwitchType_Switch, Event);
    //6. �����. ���. ���� ���2
    Event := StationR415.DoCallSecondSwitch;
    StationR415View.AddSwitch(imgCallSecondSwitch,
        '315,0,45', SwitchType_Switch, Event);
    //7. ���.���(��� I��� ������������)
    Event := StationR415.DoEnabledBroadcastFirstSwitch;
    StationR415View.AddSwitch(imgEnabledDisabledFirst,
        'Bottom,Top', SwitchType_EnabledDisabled, Event);
    //8. ���.���
    Event := StationR415.DoEnabledBroadcastSecondSwitch;
    StationR415View.AddSwitch(imgEnabledDisabledSecond,
        'Bottom,Top', SwitchType_EnabledDisabled, Event);
    //9. 220 ���������
    Event := StationR415.DoPowerSupplyFirstSwitch;
    StationR415View.AddSwitch(imgSupplyFirstSwitch,
      'SupplyOff,SupplyOn', SwitchType_EnabledDisabled, Event);
    //10. 27� ���������
    Event := StationR415.DoPowerSupplySecondSwitch;
    StationR415View.AddSwitch(imgSupplySecondSwitch,
      'SupplyOff,SupplyOn', SwitchType_EnabledDisabled, Event);
    //11. ��������1
    Event := StationR415.DoBroadcastFirstSwitch;
    StationR415View.AddSwitch(imgBroadcastFirstSwitch,
      '210,240,270,330,350,30,60,90', SwitchType_Switch, Event);
    //12. �����1
    Event := StationR415.DoReceptionFirstSwitch;
    StationR415View.AddSwitch(imgReceptionFirstSwitch,
      '210,240,270,330,350,30,60,90', SwitchType_Switch, Event);
    //13. ��������2
    Event := StationR415.DoBroadcastSecondSwitch;
    StationR415View.AddSwitch(imgBroadcastSecondSwitch,
      '210,240,270,330,350,30,60,90,120,150', SwitchType_Switch, Event);
    //14. �����2
    Event := StationR415.DoReceptionSecondSwitch;
    StationR415View.AddSwitch(imgReceptionSecondSwitch,
      '210,240,270,330,350,30,60,90,120,150', SwitchType_Switch, Event);
    //15. ��������3
    Event := StationR415.DoBroadcastThirdSwitch;
    StationR415View.AddSwitch(imgBroadcastThridSwitch,
      '210,240,270,330,350,30,60,90,120,150', SwitchType_Switch, Event);
    //16. �����3
    Event := StationR415.DoReceptionThirdSwitch;
    StationR415View.AddSwitch(imgReceptionThridSwitch,
      '210,240,270,330,350,30,60,90,120,150', SwitchType_Switch, Event);
    //17. ����� ��
    Event := StationR415.DoDoubleReception;
    StationR415View.AddSwitch(imgEnabledDisabledDoubleReception,
      'Bottom,Top', SwitchType_EnabledDisabled, Event);
    //18. ����
    Event := StationR415.DoPowerLowNormal;
    StationR415View.AddSwitch(imgEnabledDisabledPowerLowNormal,
      'Bottom,Top', SwitchType_EnabledDisabled, Event);
    //19. ������, ���, ���, �����
    Event := StationR415.DoControlReceptionBroadcastSwitch;
    StationR415View.AddSwitch(imgWorkReceptionBroadcastSwitch,
      '0,30,60', SwitchType_Switch, Event);
    //20. ���������
    Event := StationR415.DoIndicationSwitch;
    StationR415View.AddSwitch(imgIndicationSwitch,
      '225,260,300,330,0,30,45,75,90', SwitchType_Switch, Event);
    //21. ��
    Event := StationR415.DoDownUpFirstSwitch;
    StationR415View.AddSwitch(imgDownUpFirstSwitch,'Up,Down',SwitchType_DownUp,Event);
    //22. �����, ����
    Event := StationR415.DoDownUpSecondSwitch;
    StationR415View.AddSwitch(imgDownUpSecondSwitch,'Up,Down',SwitchType_DownUp,Event);
    //23. ����� ��.
    Event := StationR415.DoDownUpThirdSwitch;
    StationR415View.AddSwitch(imgDownUpThirdSwitch,'Up,Down',SwitchType_DownUp,Event);
    //24. ��� ��� I���
    Event := StationR415.DoDownUpForthSwitch;
    StationR415View.AddSwitch(imgDownUpForthSwitch,'Up,Down',SwitchType_DownUp,Event);
    //25. ����� ��� I���
    Event := StationR415.DoDownUpFifthSwitch;
    StationR415View.AddSwitch(imgDownUpFifthSwitch,'Up,Down',SwitchType_DownUp,Event);
    //26. ���  ��� II���
    Event := StationR415.DoDownUp6Switch;
    StationR415View.AddSwitch(imgDownUp6Switch,'Up,Down',SwitchType_DownUp,Event);
    //27. ����� ��� II���
    Event := StationR415.DoDownUp7Switch;
    StationR415View.AddSwitch(imgDownUp7Switch,'Up,Down',SwitchType_DownUp,Event);
    //28. ���������
    Event := StationR415.DoDownUp8Switch;
    StationR415View.AddSwitch(imgDownUp8Switch,'Up,Down',SwitchType_DownUp,Event);
    //29. ���.���
    Event := StationR415.DoDownUp9Switch;
    StationR415View.AddSwitch(imgDownUp9Switch,'Up,Down',SwitchType_DownUp,Event);
    //30. �������
    Event := StationR415.DoChangeAntena;
    StationR415View.AddSwitch(imgAntena, 'Disabled,Enabled',SwitchType_Antena,Event);
    //31. ������� 1
    Event := StationR415.DoLevel1Switch;
    StationR415View.AddSwitch(imgLevel1,'1,2,3,4,5,6', SwitchType_Level, Event);
    //32. ������� 2
    Event := StationR415.DoLevel2Switch;
    StationR415View.AddSwitch(imgLevel2, '1,2,3,4,5,6', SwitchType_Level, Event);

    StationR415View.AddAnimation(imgLamp1,'Off,On',LAMP);     //������ � ����� 0 ������� ����� ����������
    StationR415View.AddAnimation(imgLamp2,'Off,On',LAMP);     //1 ������� 1�03
    StationR415View.AddAnimation(imgLamp3,'Off,On',LAMP);     //2 ������� �04
    StationR415View.AddAnimation(imgLamp4,'Off,On',LAMP);     //3 +27 ����� �04
    StationR415View.AddAnimation(imgLamp5,'Off,On',LAMP);     //4 ������� �01-1
    StationR415View.AddAnimation(imgLamp6,'Off,OnRed',LAMP);  //5 ����� ��� ���
    StationR415View.AddAnimation(imgLamp7,'Off,OnRed',LAMP);  //6 ����� ��� ���
    StationR415View.AddAnimation(imgLamp8,'Off,On',LAMP);     //7 �����.���. ��������
    StationR415View.AddAnimation(imgLamp9,'Off,On',LAMP);     //8 �����.���. �����
    StationR415View.AddAnimation(imgLamp10,'Off,On',LAMP);    //9 �����.���. �����

    StationR415View.AddAnimation(imgDisplay1,'_0,_1,_2,_3,_4,_5,_6,_7,_8',DISPLAY);   //10 ������� ���������
    StationR415View.AddAnimation(imgDisplay2,'_0,_1,_2,_3,_4,_5,_6,_7,_8',DISPLAY);   //11 ������ ���������

    StationR415View.AddLabel(prd1,random(7));
    StationR415View.AddLabel(prd2,random(9));
    StationR415View.AddLabel(prd3,random(9));

    StationR415View.AddLabel(prm1,random(7));
    StationR415View.AddLabel(prm2,random(9));
    StationR415View.AddLabel(prm3,random(9));

  end;

end.
