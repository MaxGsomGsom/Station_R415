unit uStationR415DM;

interface
uses Math,Dialogs,SysUtils;

type

  //событие изменения параметров
  TGenerateActive = procedure() of object;
  //событие изменения параметров
  TStateChangeEvent = procedure() of object;
  //событие на показ подсказок
  TStateQestion = procedure() of object;
  //событие на проверку данных
  TCheckWork = procedure() of object;

  //тип работы станции(Обучение)
  TWorkType = (None, Education, Treaning, Normativ20);

  //тип работы станции(Обучение)
  TFinishTask = (FNone, FEducation, FTreaning, FNormativ20);

  //константы положения переключателей
  TControlLevelSwitchEnum = (Phone_1_35, Phone_1_20, Phone_1_Reception,
    Phone_1_Broadcast,Control_Level_Off, Phone_2_Broadcast,
    Phone_2_Reception,Phone_2_20, Phone_2_35);

  TPVUEnum = (Phone_1, PVU_Off, Phone_2);

  TPhoneFirstEnum = (Two_Channel_Terminal, Transit, Terminal);

  TCallEnum = (Channel, Call_Work, Coupling_Line);

  TEnabledDisabledEnum = (Disabled, Enabled);

  TReceptionBroadcastEnum = (Zero, One, Two, There, Four, Five, Six, Seven,
    Eight, Nine);

  TControlReceptionBroadcastEnum = (Work, Reception, Broadcast);

  TIndicationEnum = (Indication_0, Indication_20, Indication_40,
    Indication_60, Indication_Broadcast, Indication_Reflection,
    Indication_10, Indication_Minus_5, Indication_Minus_20,
    Indication_Input_Device);


  TDownUpEnum = (Down, Up); //отжимная кнопка-


  TStationR415 = class
    private
      FControlLevelSwitch: TControlLevelSwitchEnum;
      FPVUSwitch: TPVUEnum;
      FPhoneFirstSwitch: TPhoneFirstEnum;
      FPhoneSecondSwitch: TPhoneFirstEnum;
      FCallFirstSwitch: TCallEnum;
      FCallSecondSwitch: TCallEnum;
      FEnabledBroadcastFirstSwitch: TEnabledDisabledEnum;
      FEnabledBroadcastSecondSwitch: TEnabledDisabledEnum;
      FPowerSupplyFirstSwitch: TEnabledDisabledEnum;
      FPowerSupplySecondSwitch: TEnabledDisabledEnum;
      FReceptionFirstSwitch: TReceptionBroadcastEnum;
      FBroadcastFirstSwitch: TReceptionBroadcastEnum;
      FReceptionSecondSwitch: TReceptionBroadcastEnum;
      FBroadcastSecondSwitch: TReceptionBroadcastEnum;
      FReceptionThirdSwitch: TReceptionBroadcastEnum;
      FBroadcastThirdSwitch: TReceptionBroadcastEnum;
      FDoubleReception: TEnabledDisabledEnum;
      FPowerLowNormal: TEnabledDisabledEnum;
      FControlReceptionBroadcastSwitch: TControlReceptionBroadcastEnum;
      FIndicationSwitch: TIndicationEnum;
      FLevel1Switch: TIndicationEnum;
      FLevel2Switch: TIndicationEnum;
      FDownUpFirstSwitch: TDownUpEnum;//-
      FDownUpSecondSwitch: TDownUpEnum;
      FDownUpThirdSwitch: TDownUpEnum;
      FDownUpForthSwitch: TDownUpEnum;
      FDownUpFifthSwitch: TDownUpEnum;
      FDownUp6Switch: TDownUpEnum;
      FDownUp7Switch: TDownUpEnum;
      FDownUp8Switch: TDownUpEnum;
      FDownUp9Switch: TDownUpEnum;
      FGenerateActive: TGenerateActive;
      FStateChangeEvent: TStateChangeEvent;
      FQuestion : TStateQestion;
      FCheckWork : TCheckWork;
      FWorkType: TWorkType;
      FPhone: TEnabledDisabledEnum;
      FAntena: TEnabledDisabledEnum;
      FPRD1,FPRD2,FPRD3: integer;
      FPRM1,FPRM2,FPRM3: integer;
      FPhoneButton: boolean;
      FImpulsGenerate: boolean;
      FLevel: Integer;
      FFinishTask: TFinishTask;


    public
      constructor Create();
      property ControlLevelSwitch: TControlLevelSwitchEnum
        read FControlLevelSwitch write FControlLevelSwitch;
      property PVUSwitch: TPVUEnum
        read FPVUSwitch write FPVUSwitch;
      property PhoneFirstSwitch: TPhoneFirstEnum
        read FPhoneFirstSwitch write FPhoneFirstSwitch;
      property PhoneSecondSwitch: TPhoneFirstEnum
        read FPhoneSecondSwitch write FPhoneSecondSwitch;
      property CallFirstSwitch: TCallEnum
        read FCallFirstSwitch write FCallFirstSwitch;
      property CallSecondSwitch: TCallEnum
        read FCallSecondSwitch write FCallSecondSwitch;
      property EnabledBroadcastFirstSwitch: TEnabledDisabledEnum
        read FEnabledBroadcastFirstSwitch write FEnabledBroadcastFirstSwitch;
      property EnabledBroadcastSecondSwitch: TEnabledDisabledEnum
        read FEnabledBroadcastSecondSwitch write FEnabledBroadcastSecondSwitch;
      property PowerSupplyFirstSwitch: TEnabledDisabledEnum
        read FPowerSupplyFirstSwitch write FPowerSupplyFirstSwitch;
      property PowerSupplySecondSwitch: TEnabledDisabledEnum
        read FPowerSupplySecondSwitch write FPowerSupplySecondSwitch;
      property ReceptionFirstSwitch: TReceptionBroadcastEnum
        read FReceptionFirstSwitch write FReceptionFirstSwitch;
      property BroadcastFirstSwitch: TReceptionBroadcastEnum
        read FBroadcastFirstSwitch write FBroadcastFirstSwitch;
      property ReceptionSecondSwitch: TReceptionBroadcastEnum
        read FReceptionSecondSwitch write FReceptionSecondSwitch;
      property BroadcastSecondSwitch: TReceptionBroadcastEnum
        read FBroadcastSecondSwitch write FBroadcastSecondSwitch;
      property ReceptionThirdSwitch: TReceptionBroadcastEnum
        read FReceptionThirdSwitch write FReceptionThirdSwitch;
      property BroadcastThirdSwitch: TReceptionBroadcastEnum
        read FBroadcastThirdSwitch write FBroadcastThirdSwitch;
      property DoubleReception:TEnabledDisabledEnum
        read FDoubleReception write FDoubleReception;
      property PowerLowNormal: TEnabledDisabledEnum
        read FPowerLowNormal write FPowerLowNormal;
      property ControlReceptionBroadcastSwitch: TControlReceptionBroadcastEnum
        read FControlReceptionBroadcastSwitch
        write FControlReceptionBroadcastSwitch;
      property IndicationSwitch: TIndicationEnum
        read FIndicationSwitch write FIndicationSwitch;
      //-
      property DownUpFirstSwitch: TDownUpEnum
        read FDownUpFirstSwitch write FDownUpFirstSwitch;
      property DownUpSecondSwitch: TDownUpEnum
        read FDownUpSecondSwitch write FDownUpSecondSwitch;
      property DownUpThirdSwitch: TDownUpEnum
        read FDownUpThirdSwitch write FDownUpThirdSwitch;
      property DownUpForthSwitch: TDownUpEnum
        read FDownUpForthSwitch write FDownUpForthSwitch;
      property DownUpFifthSwitch: TDownUpEnum
        read FDownUpFifthSwitch write FDownUpFifthSwitch;
      property DownUp6Switch: TDownUpEnum
        read FDownUp6Switch write FDownUp6Switch;
      property DownUp7Switch: TDownUpEnum
        read FDownUp7Switch write FDownUp7Switch;
      property DownUp8Switch: TDownUpEnum
        read FDownUp8Switch write FDownUp8Switch;
      property DownUp9Switch: TDownUpEnum
        read FDownUp9Switch write FDownUp9Switch;

      property GenerateActive: TGenerateActive
        read FGenerateActive write FGenerateActive;

      property StateChangeEvent: TStateChangeEvent
        read FStateChangeEvent write FStateChangeEvent;
      property WorkType: TWorkType
        read FWorkType write FWorkType;
      property Phone: TEnabledDisabledEnum
        read FPhone write FPhone;
      property Antena: TEnabledDisabledEnum
        read FAntena write FAntena;
      property PRD1: integer
        read FPRD1 write FPRD1;
      property PRD2: integer
        read FPRD2 write FPRD2;
      property PRD3: integer
        read FPRD3 write FPRD3;

      property CheckWork : TCheckWork
        read FCheckWork write FCheckWork;
      property Question : TStateQestion
        read FQuestion write FQuestion;
      property PRM1: integer
        read FPRM1 write FPRM1;
      property PRM2: integer
        read FPRM2 write FPRM2;
      property PRM3: integer
        read FPRM3 write FPRM3;
      property PhoneButton: boolean
        read FPhoneButton write FPhoneButton;
      property ImpulsGenerate: boolean
        read FImpulsGenerate write FImpulsGenerate;
      property Level1Switch: TIndicationEnum
        read FLevel1Switch write FLevel1Switch;
       property Level2Switch: TIndicationEnum
        read FLevel2Switch write FLevel2Switch;
       property Level: integer
        read FLevel write FLevel;

       property  FinishTask: TFinishTask
        read FFinishTask write FFinishTask;

      //
      procedure DoChangeControlLelevSwitch(State: Integer);
      procedure DoChangePVUSwitch(State: Integer);
      procedure DoPhoneFirstSwitch(State: Integer);
      procedure DoPhoneSecondSwitch(State: Integer);
      procedure DoCallFirstSwitch(State: Integer);
      procedure DoCallSecondSwitch(State: Integer);
      procedure DoEnabledBroadcastFirstSwitch(State: Integer);
      procedure DoEnabledBroadcastSecondSwitch(State: Integer);
      procedure DoPowerSupplyFirstSwitch(State: Integer);
      procedure DoPowerSupplySecondSwitch(State: Integer);
      procedure DoReceptionFirstSwitch(State: Integer);
      procedure DoBroadcastFirstSwitch(State: Integer);
      procedure DoReceptionSecondSwitch(State: Integer);
      procedure DoBroadcastSecondSwitch(State: Integer);
      procedure DoReceptionThirdSwitch(State: Integer);
      procedure DoBroadcastThirdSwitch(State: Integer);
      procedure DoDoubleReception(State: Integer);
      procedure DoPowerLowNormal(State: Integer);
      procedure DoControlReceptionBroadcastSwitch(State: Integer);
      procedure DoIndicationSwitch(State: Integer);
      procedure DoDownUpFirstSwitch(State: Integer); //-
      procedure DoDownUpSecondSwitch(State: Integer);
      procedure DoDownUpThirdSwitch(State: Integer);
      procedure DoDownUpForthSwitch(State: Integer);
      procedure DoDownUpFifthSwitch(State: Integer);
      procedure DoDownUp6Switch(State: Integer);
      procedure DoDownUp7Switch(State: Integer);
      procedure DoDownUp8Switch(State: Integer);
      procedure DoDownUp9Switch(State: Integer);
      procedure DoChangeWorkType(State: Integer);
      procedure DoChangePhone(State: Integer);
      procedure StateToDefaultPeriphery();
      procedure DoLevel1Switch(State: Integer);
      procedure DoLevel2Switch(State: Integer);
      procedure DoChangeAntena(State: Integer);
      procedure RandomSet();
      procedure ChangeWaves20Zadacha(prd: integer; prm: integer);
      //
  end;
implementation

  constructor TStationR415.Create();
  begin
    RandomSet();

    PhoneButton := false;
    ImpulsGenerate := false;

    Level := 1;

    self.FinishTask := FNone;
  end;

  procedure TStationR415.ChangeWaves20Zadacha(prd: integer; prm: integer);
  begin
    PRD1 := prd div 100;
    PRD3 := prd mod 10;
    PRD2 := (prd - PRD1*100 - PRD3) div 10;

    PRM1 := prm div 100;
    PRM3 := prm mod 10;
    PRM2 := (prm - PRM1*100 - PRM3) div 10;

  end;

  procedure TStationR415.RandomSet;
  begin
    PRD1 := random(7);
    PRD2 := random(9);
    PRD3 := random(9);

    PRM1 := random(7);
    PRM2 := random(9);
    PRM3 := random(9);
  end;

  procedure TStationR415.StateToDefaultPeriphery;
  begin
    PhoneButton := false;
    ImpulsGenerate := false;
    Level2Switch := Indication_0;
    Level1Switch := Indication_0;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Контроль уровня ДБ".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoChangeControlLelevSwitch(State: Integer);
  begin
    ControlLevelSwitch := TControlLevelSwitchEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "ПВУ".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoChangePVUSwitch(State: Integer);
  begin
    PVUSwitch := TPVUEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "1 ТЛФ на блоке Б17-1".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoPhoneFirstSwitch(State: Integer);
  begin
    PhoneFirstSwitch := TPhoneFirstEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "1 ТЛФ на блоке ББ17-1"(2).
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoPhoneSecondSwitch(State: Integer);
  begin
    PhoneSecondSwitch := TPhoneFirstEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Вызов".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoCallFirstSwitch(State: Integer);
  begin
    CallFirstSwitch := TCallEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Вызов"(1).
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoCallSecondSwitch(State: Integer);
  begin
    CallSecondSwitch := TCallEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Вкл. Пер.".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoEnabledBroadcastFirstSwitch(State: Integer);
  begin
    EnabledBroadcastFirstSwitch := TEnabledDisabledEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Вкл. Пер."(1).
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoEnabledBroadcastSecondSwitch(State: Integer);
  begin
    EnabledBroadcastSecondSwitch := TEnabledDisabledEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Сеть ~220В Вкл.".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoPowerSupplyFirstSwitch(State: Integer);
  begin
    PowerSupplyFirstSwitch := TEnabledDisabledEnum(State);
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Сеть +27В Вкл.".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoPowerSupplySecondSwitch(State: Integer);
  begin
    PowerSupplySecondSwitch := TEnabledDisabledEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Настройка Прием 1".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoReceptionFirstSwitch(State: Integer);
  begin
    ReceptionFirstSwitch := TReceptionBroadcastEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Настройка Передача 1".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoBroadcastFirstSwitch(State: Integer);
  begin
    BroadcastFirstSwitch := TReceptionBroadcastEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Настройка Прием 2".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoReceptionSecondSwitch(State: Integer);
  begin
    ReceptionSecondSwitch := TReceptionBroadcastEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Настройка Передача 2".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoBroadcastSecondSwitch(State: Integer);
  begin
    BroadcastSecondSwitch := TReceptionBroadcastEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Настройка Прием 3".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoReceptionThirdSwitch(State: Integer);
  begin
    ReceptionThirdSwitch := TReceptionBroadcastEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Настройка Передача 3".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoBroadcastThirdSwitch(State: Integer);
  begin
    BroadcastThirdSwitch := TReceptionBroadcastEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Дупл./Деж. Прием".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoDoubleReception(State: Integer);
  begin
    DoubleReception := TEnabledDisabledEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Мощн. Пониж./Норм.".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoPowerLowNormal(State: Integer);
  begin
    PowerLowNormal := TEnabledDisabledEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Работа/Прм./Прд.".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoControlReceptionBroadcastSwitch(State: Integer);
  begin
    ControlReceptionBroadcastSwitch := TControlReceptionBroadcastEnum(State);

    if WorkType <> None then
    begin
      StateChangeEvent();
    end;


  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Индикация".
  /// </summary>
  /// <param name="State">Состояние объекта (переключателя).</param>
  procedure TStationR415.DoIndicationSwitch(State: Integer);
  begin
    IndicationSwitch := TIndicationEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;

  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "ИГ.".
  /// </summary>
  /// <param name="State">Состояние объекта (ИГ.).</param>
  //-
  procedure TStationR415.DoDownUpFirstSwitch(State: Integer);
  begin
    DownUpFirstSwitch := TDownUpEnum(State);
    if WorkType <> None then
    begin
      if WorkType = Normativ20 then
      begin
        GenerateActive();
      end;
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Опер.".
  /// </summary>
  /// <param name="State">Состояние объекта (Опер.).</param>
  procedure TStationR415.DoDownUpSecondSwitch(State: Integer);
  begin
    DownUpSecondSwitch := TDownUpEnum(State);
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Сл.".
  /// </summary>
  /// <param name="State">Состояние объекта (Сл.).</param>
  procedure TStationR415.DoDownUpThirdSwitch(State: Integer);
  begin
    DownUpThirdSwitch := TDownUpEnum(State);
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Тлг1.тчк".
  /// </summary>
  /// <param name="State">Состояние объекта (Тлг1.тчк).</param>
  procedure TStationR415.DoDownUpForthSwitch(State: Integer);
  begin
    DownUpThirdSwitch := TDownUpEnum(State);
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Тлг1.контр".
  /// </summary>
  /// <param name="State">Состояние объекта (Тлг1.контр).</param>
  procedure TStationR415.DoDownUpFifthSwitch(State: Integer);
  begin
    DownUpFifthSwitch := TDownUpEnum(State);
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Тлг2.тчк".
  /// </summary>
  /// <param name="State">Состояние объекта (Тлг2.тчк).</param>
  procedure TStationR415.DoDownUp6Switch(State: Integer);
  begin
    DownUp6Switch := TDownUpEnum(State);
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Тлг2.контр".
  /// </summary>
  /// <param name="State">Состояние объекта (Тлг2.контр).</param>
  procedure TStationR415.DoDownUp7Switch(State: Integer);
  begin
    DownUp7Switch := TDownUpEnum(State);
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Настройка".
  /// </summary>
  /// <param name="State">Состояние объекта (Настройка).</param>
  procedure TStationR415.DoDownUp8Switch(State: Integer);
  begin
    DownUp8Switch := TDownUpEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния переключателя "Настройка".
  /// </summary>
  /// <param name="State">Состояние объекта (Настройка).</param>
  procedure TStationR415.DoDownUp9Switch(State: Integer);
  begin
    DownUp9Switch := TDownUpEnum(State);
  end;

  /// <summary>
  /// Обработчик изменения типа работы станции(Просто потыкать, тренировка...).
  /// </summary>
  /// <param name="State">Состояние объекта (Тип работы станции).</param>
  procedure TStationR415.DoChangeWorkType(State: Integer);
  begin
    WorkType := TWorkType(State);
  end;

  /// <summary>
  /// Обработчик гнезда телефонной трубки.
  /// </summary>
  /// <param name="State">Состояние объекта (гнездо телефонной трубки).</param>
  procedure TStationR415.DoChangePhone(State: Integer);
  begin
    Phone := TEnabledDisabledEnum(State);

    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик гнезда антенны
  /// </summary>
  /// <param name="State">Состояние объекта (гнездо антенны).</param>
  procedure TStationR415.DoChangeAntena(State: Integer);
  begin
    Antena := TEnabledDisabledEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния уровня "Уровень ТЛФ1".
  /// </summary>
  /// <param name="State">Состояние объекта (Уровень ТЛФ1).</param>
  procedure TStationR415.DoLevel1Switch(State: Integer);
  begin
    Level1Switch := TIndicationEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;

  /// <summary>
  /// Обработчик изменения состояния уровня "Уровень ТЛФ2".
  /// </summary>
  /// <param name="State">Состояние объекта (Уровень ТЛФ2).</param>
  procedure TStationR415.DoLevel2Switch(State: Integer);
  begin
    Level2Switch := TIndicationEnum(State);
    if WorkType <> None then
    begin
      StateChangeEvent();
    end;
  end;


end.
