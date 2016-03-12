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
  /// Конструктор. Производит вызов инициализации "Переключателей".
  /// </summary>
procedure TStationR415Form.btn1Click(Sender: TObject);
begin

end;

//показывает стартовое текстовое сообщение в консоли
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
  /// Производит инициализацию "Переключателей" и подписку на событие
  /// переключение (изменение состояния) положения.
  /// </summary>
procedure TStationR415Form.InitSwitches;
  var
    Event: TSwitchChangeStateEvent;
  begin
    //0. ТЛФ
    Event := StationR415.DoChangePhone;
    StationR415View.AddSwitch(imgPhone, 'Disabled,Enabled',SwitchType_Phone,Event);
    //1. IТлф-IIТлф. контр уровня дб
    Event := StationR415.DoChangeControlLelevSwitch;
    StationR415View.AddSwitch(imgControlLevelSwitch,
        '225,270,292.5,337.5,0,22.5,67.5,90,135', SwitchType_Switch, Event);
    //2. ПВУ
    Event := StationR415.DoChangePVUSwitch;
    StationR415View.AddSwitch(imgPVUSwitch,
        '315,0,45', SwitchType_Switch, Event);
    //3. Iтлф
    Event := StationR415.DoPhoneFirstSwitch;
    StationR415View.AddSwitch(imgFirstPhoneFirstSwitch,
        '315,0,45', SwitchType_Switch, Event);
    //4. IIтлф
    Event := StationR415.DoPhoneSecondSwitch;
    StationR415View.AddSwitch(imgFirstPhoneSecondSwitch,
        '315,0,45', SwitchType_Switch, Event);
    //5. канал. раб. соед лин1
    Event := StationR415.DoCallFirstSwitch;
    StationR415View.AddSwitch(imgCallFirstSwitch,
        '315,0,45', SwitchType_Switch, Event);
    //6. канал. раб. соед лин2
    Event := StationR415.DoCallSecondSwitch;
    StationR415View.AddSwitch(imgCallSecondSwitch,
        '315,0,45', SwitchType_Switch, Event);
    //7. вкл.пер(под Iтлф преобладание)
    Event := StationR415.DoEnabledBroadcastFirstSwitch;
    StationR415View.AddSwitch(imgEnabledDisabledFirst,
        'Bottom,Top', SwitchType_EnabledDisabled, Event);
    //8. вкл.пер
    Event := StationR415.DoEnabledBroadcastSecondSwitch;
    StationR415View.AddSwitch(imgEnabledDisabledSecond,
        'Bottom,Top', SwitchType_EnabledDisabled, Event);
    //9. 220 переменка
    Event := StationR415.DoPowerSupplyFirstSwitch;
    StationR415View.AddSwitch(imgSupplyFirstSwitch,
      'SupplyOff,SupplyOn', SwitchType_EnabledDisabled, Event);
    //10. 27В постоянка
    Event := StationR415.DoPowerSupplySecondSwitch;
    StationR415View.AddSwitch(imgSupplySecondSwitch,
      'SupplyOff,SupplyOn', SwitchType_EnabledDisabled, Event);
    //11. передача1
    Event := StationR415.DoBroadcastFirstSwitch;
    StationR415View.AddSwitch(imgBroadcastFirstSwitch,
      '210,240,270,330,350,30,60,90', SwitchType_Switch, Event);
    //12. прием1
    Event := StationR415.DoReceptionFirstSwitch;
    StationR415View.AddSwitch(imgReceptionFirstSwitch,
      '210,240,270,330,350,30,60,90', SwitchType_Switch, Event);
    //13. передача2
    Event := StationR415.DoBroadcastSecondSwitch;
    StationR415View.AddSwitch(imgBroadcastSecondSwitch,
      '210,240,270,330,350,30,60,90,120,150', SwitchType_Switch, Event);
    //14. прием2
    Event := StationR415.DoReceptionSecondSwitch;
    StationR415View.AddSwitch(imgReceptionSecondSwitch,
      '210,240,270,330,350,30,60,90,120,150', SwitchType_Switch, Event);
    //15. передача3
    Event := StationR415.DoBroadcastThirdSwitch;
    StationR415View.AddSwitch(imgBroadcastThridSwitch,
      '210,240,270,330,350,30,60,90,120,150', SwitchType_Switch, Event);
    //16. прием3
    Event := StationR415.DoReceptionThirdSwitch;
    StationR415View.AddSwitch(imgReceptionThridSwitch,
      '210,240,270,330,350,30,60,90,120,150', SwitchType_Switch, Event);
    //17. канал ДУ
    Event := StationR415.DoDoubleReception;
    StationR415View.AddSwitch(imgEnabledDisabledDoubleReception,
      'Bottom,Top', SwitchType_EnabledDisabled, Event);
    //18. мощн
    Event := StationR415.DoPowerLowNormal;
    StationR415View.AddSwitch(imgEnabledDisabledPowerLowNormal,
      'Bottom,Top', SwitchType_EnabledDisabled, Event);
    //19. работа, прм, прд, контр
    Event := StationR415.DoControlReceptionBroadcastSwitch;
    StationR415View.AddSwitch(imgWorkReceptionBroadcastSwitch,
      '0,30,60', SwitchType_Switch, Event);
    //20. индикация
    Event := StationR415.DoIndicationSwitch;
    StationR415View.AddSwitch(imgIndicationSwitch,
      '225,260,300,330,0,30,45,75,90', SwitchType_Switch, Event);
    //21. ИГ
    Event := StationR415.DoDownUpFirstSwitch;
    StationR415View.AddSwitch(imgDownUpFirstSwitch,'Up,Down',SwitchType_DownUp,Event);
    //22. вызов, опер
    Event := StationR415.DoDownUpSecondSwitch;
    StationR415View.AddSwitch(imgDownUpSecondSwitch,'Up,Down',SwitchType_DownUp,Event);
    //23. вызов сл.
    Event := StationR415.DoDownUpThirdSwitch;
    StationR415View.AddSwitch(imgDownUpThirdSwitch,'Up,Down',SwitchType_DownUp,Event);
    //24. ТЧК под IТЛГ
    Event := StationR415.DoDownUpForthSwitch;
    StationR415View.AddSwitch(imgDownUpForthSwitch,'Up,Down',SwitchType_DownUp,Event);
    //25. Контр под IТЛГ
    Event := StationR415.DoDownUpFifthSwitch;
    StationR415View.AddSwitch(imgDownUpFifthSwitch,'Up,Down',SwitchType_DownUp,Event);
    //26. ТЧК  под IIТЛГ
    Event := StationR415.DoDownUp6Switch;
    StationR415View.AddSwitch(imgDownUp6Switch,'Up,Down',SwitchType_DownUp,Event);
    //27. Контр под IIТЛГ
    Event := StationR415.DoDownUp7Switch;
    StationR415View.AddSwitch(imgDownUp7Switch,'Up,Down',SwitchType_DownUp,Event);
    //28. настройка
    Event := StationR415.DoDownUp8Switch;
    StationR415View.AddSwitch(imgDownUp8Switch,'Up,Down',SwitchType_DownUp,Event);
    //29. Прд.ВКЛ
    Event := StationR415.DoDownUp9Switch;
    StationR415View.AddSwitch(imgDownUp9Switch,'Up,Down',SwitchType_DownUp,Event);
    //30. антенна
    Event := StationR415.DoChangeAntena;
    StationR415View.AddSwitch(imgAntena, 'Disabled,Enabled',SwitchType_Antena,Event);
    //31. уровень 1
    Event := StationR415.DoLevel1Switch;
    StationR415View.AddSwitch(imgLevel1,'1,2,3,4,5,6', SwitchType_Level, Event);
    //32. уровень 2
    Event := StationR415.DoLevel2Switch;
    StationR415View.AddSwitch(imgLevel2, '1,2,3,4,5,6', SwitchType_Level, Event);

    StationR415View.AddAnimation(imgLamp1,'Off,On',LAMP);     //индекс в листе 0 питание блока уплотнения
    StationR415View.AddAnimation(imgLamp2,'Off,On',LAMP);     //1 питание 1Б03
    StationR415View.AddAnimation(imgLamp3,'Off,On',LAMP);     //2 питание Б04
    StationR415View.AddAnimation(imgLamp4,'Off,On',LAMP);     //3 +27 вольт Б04
    StationR415View.AddAnimation(imgLamp5,'Off,On',LAMP);     //4 питание Б01-1
    StationR415View.AddAnimation(imgLamp6,'Off,OnRed',LAMP);  //5 связи нет прм
    StationR415View.AddAnimation(imgLamp7,'Off,OnRed',LAMP);  //6 связи нет прд
    StationR415View.AddAnimation(imgLamp8,'Off,On',LAMP);     //7 контр.анф. передача
    StationR415View.AddAnimation(imgLamp9,'Off,On',LAMP);     //8 контр.анф. прием
    StationR415View.AddAnimation(imgLamp10,'Off,On',LAMP);    //9 контр.анф. прием

    StationR415View.AddAnimation(imgDisplay1,'_0,_1,_2,_3,_4,_5,_6,_7,_8',DISPLAY);   //10 верхний индикатор
    StationR415View.AddAnimation(imgDisplay2,'_0,_1,_2,_3,_4,_5,_6,_7,_8',DISPLAY);   //11 нижний индикатор

    StationR415View.AddLabel(prd1,random(7));
    StationR415View.AddLabel(prd2,random(9));
    StationR415View.AddLabel(prd3,random(9));

    StationR415View.AddLabel(prm1,random(7));
    StationR415View.AddLabel(prm2,random(9));
    StationR415View.AddLabel(prm3,random(9));

  end;

end.
