unit uTreningR415DM;

interface
uses classes, SysUtils, Dialogs,Generics.Collections, uStationR415DM,uStationR415ViewDM,
  Windows, ExtCtrls,Forms,uAnimationDM, consoleForm, uSwitchDM;

type
  //какой пункт обучения делаем
  TTreaningStateEnum = (Vn_osm_t, Ust_org_v_ish_pol_t, Vkl_pit_t, Nastr_t, Prov_rab_t,Prov_rab1_t,
                          Prov_rab2_t,Ust_sv_t, Regul_zatuh1_t, Regul_zatuh2_t, Regul_zatuh3_t,
                          Regul_zatuh4_t,Regul_zatuh5_t,Regul_zatuh6_t,Sdacha_kanalov_t);


  TTreaningR415 = class
      private
        WorkTrue : BOOL;
        ShowsQuestion : integer;
        errors:integer;
        Texts: TList<string>;
        FStationR415 : TStationR415;
        FStationR415View: TStationR415View;

        FEducationState: TTreaningStateEnum;

        FOneShow: boolean;
        //оценки за прохождение тренировки
        FMark_osmotr,FMark_ust_v_ish,FMark_vkl_pit,FMark_Nastr,FMark_Prov_rab,
        FMark_ust_sv,FMark_regul_zatuh,FMark_sdacha_kanalov: Double;
        FMark: Double;


        procedure Delay(time: integer);
        function getErrors():integer;

        procedure ShowTextMessage(i:integer; i1: integer);
        procedure StateToDefaultOrgan();
        procedure VneshniiOsmotr();
        procedure VklucheniePitania();
        procedure Nastroika;
        procedure ProverkaRabotPRM();
        procedure ProverkaRabotiPRD();
        procedure ProverkaRaboti();
        procedure UstanovkaSviazi();
        procedure RegulOstatZatuh1();
        procedure RegulOstatZatuh2();
        procedure RegulOstatZatuh3();
        procedure RegulOstatZatuh4();
        procedure RegulOstatZatuh5();
        procedure RegulOstatZatuh6();
        procedure Finish();



      public
        //настройка области видимости
        property EducationState: TTreaningStateEnum
          read FEducationState write FEducationState;
        property Mark: double
          read FMark write FMark;
        //объявление методов класса
        constructor Create(StationR415: TStationR415;StationR415View: TStationR415View);
        destructor Destroy; override;

        procedure onStationR415StateChange();
        procedure addToTextList();
        procedure ShowQuestion();
        procedure CheckWork();
        procedure ResetErrors;


    end;

implementation
  uses uStationR415Form;

  //описание конструктора
  constructor TTreaningR415.Create(StationR415: TStationR415;StationR415View: TStationR415View);
  var I:integer;
  begin
    //сохраняем ссылку на объект станции
    FStationR415 := StationR415;
    FStationR415View := StationR415View;
    //подписываемся на событие изменения
    FStationR415.StateChangeEvent := onStationR415StateChange;
    FStationR415.Question := ShowQuestion;
    //инициализация
    Texts := TList<string>.Create;

    //заполняем массив текстом
    addToTextList();

    //включаем первый режим обучения(внешний осмотр)
    EducationState := TTreaningStateEnum(Vn_osm_t);
    ShowMessage('Вы вошли в режим тренировки. В консоли написан пункт который вы делаете. После выполнения пункта нужно нажать клавишу "Пробел" для проверки правильности выполнения. Для вывода подсказок нажмите клавишу "Q".');
    ShowTextMessage(0,0);

    FOneShow := false;

    FMark_osmotr:= 5;
    FMark_ust_v_ish:= 5;
    FMark_vkl_pit := 5;
    FMark_Nastr := 5;
    FMark_Prov_rab := 5;
    FMark_ust_sv:=5;
    FMark_regul_zatuh := 5;
    FMark_sdacha_kanalov := 5;

    ShowsQuestion := 0;

    FEducationState := Vn_osm_t;

    for I := 0 to FStationR415View.Switches.Count - 1 do
    begin
      FStationR415View.Switches[I].EducationType := ETTreaning;
      if I = 0 then
        FStationR415View.Switches[I].changeProperties := true
      else
        FStationR415View.Switches[I].changeProperties := false;
    end;

  end;

   //описание десструктора
  destructor TTreaningR415.Destroy;
  begin
    //освобождаем память
    Texts.Free;
    //уничтожаем объект
    inherited;

    FStationR415.PhoneButton := false;
    Self.WorkTrue := false;

  end;
//------------------------------------------------------------------------------
  //обрабатываем анимацию
  procedure TTreaningR415.onStationR415StateChange();
  begin
    VklucheniePitania();
    StateToDefaultOrgan();
    VneshniiOsmotr();
    Nastroika();
    ProverkaRabotPRM();
    ProverkaRabotiPRD();
    ProverkaRaboti();
    UstanovkaSviazi();
    RegulOstatZatuh1();
    RegulOstatZatuh2();
    RegulOstatZatuh3();
    RegulOstatZatuh4();
    RegulOstatZatuh5();
    RegulOstatZatuh6();
    Finish();

  end;

  procedure TTreaningR415.Finish;
  begin


  end;

  //проверка выполнения задания
  procedure TTreaningR415.CheckWork;
  var I:integer;
  begin
    errors :=0;

    {$REGION 'Сдача каналов'}
    if(FEducationState = Sdacha_kanalov_t) then
    begin
      if((FStationR415.PhoneButton = true)and(FOneShow = false)) then
      begin
        ShowMessage('Корреспондент: "Вас понял. Выполняю !"');
        FOneShow := true;
      end
      else
      begin
        //Iтлф - IIтлф = IIтлф прием
        if FStationR415.ControlLevelSwitch <> Phone_2_Reception then
          Inc(errors);
        //Iтлф = 4ПР.ОК
        if FStationR415.PhoneFirstSwitch  <> Terminal then
          Inc(errors);
        //IIтлф = 2ПР.ОК
        if FStationR415.PhoneSecondSwitch  <> Two_Channel_Terminal then
          Inc(errors);
        //ПВУ = IIтлф
        if FStationR415.PVUSwitch  <> Phone_2 then
          Inc(errors);
        //Iтлф Канал-раб-соед.лин = РАБОТА
        if FStationR415.CallFirstSwitch  <> Call_Work then
          Inc(errors);
        //IIтлф Канал-раб-соед.лин = КАНАЛ
        if FStationR415.CallSecondSwitch  <> Channel then
          Inc(errors);

        if errors = 0 then
        begin
            formConsole.console.Items.Add('Каналы сданы в работу ! Настройка станции окончена !');

            if (ShowsQuestion <= 3)and(self.getErrors = 0) then
            begin
              ShowMessage('Норматив сдан. Число подсказок: ' + IntToStr(ShowsQuestion) + ' Неверных кликов: ' + IntToStr(self.getErrors));
              formConsole.console.Items.Add('Норматив сдан. Число подсказок:' + IntToStr(ShowsQuestion) + ' Неверных кликов: ' + IntToStr(self.getErrors));
              StationR415Form.StationR415.FinishTask := FTreaning;
            end
            else
            begin
              ShowMessage('Норматив не сдан ! Число подсказок: ' + IntToStr(ShowsQuestion) + ' Неверных кликов: ' + IntToStr(self.getErrors));
              formConsole.console.Items.Add('Норматив не сдан ! Число подсказок: ' + IntToStr(ShowsQuestion)  + ' Неверных кликов: ' + IntToStr(self.getErrors));
              StationR415Form.StationR415.FinishTask := FNone;
            end;

            for I := 0 to FStationR415View.Switches.Count - 1 do
            begin
              FStationR415View.Switches[I].EducationType := ETNone;
              FStationR415View.Switches[I].changeProperties := true;
            end;
        end;
      end;
    end;
    {$ENDREGION}

    {$REGION 'Регулировка остат. затуханий'}
    if(FEducationState = Regul_zatuh6_t) then
    begin
      if(FOneShow = false) then
      begin
          FMark_osmotr:= 5;
          EducationState := TTreaningStateEnum(Sdacha_kanalov_t);
          FOneShow := true;
          formConsole.console.Clear;
          ShowTextMessage(90,90);

      end
      else
      begin
        formConsole.console.Clear;
        ShowTextMessage(79,79);
      end;
    end;

    if(FEducationState = Regul_zatuh5_t) then
    begin
      if(FStationR415.PVUSwitch = Phone_2) then
      begin
        if(FOneShow = false) then
        begin
          ShowMessage('Корреспондент: "Вас понял !"');
          FOneShow := true;

          for I := 0 to FStationR415View.Switches.Count - 1 do
          begin
            if (I = 21) then
              FStationR415View.Switches[I].changeProperties := true
            else
              FStationR415View.Switches[I].changeProperties := false;
          end;
        end;


        if((WorkTrue= true)and(FOneShow = true)) then
        begin
          ShowMessage('Корреспондент: "Готово !"');
          EducationState := TTreaningStateEnum(Sdacha_kanalov_t);
          FOneShow := false;
          FStationR415.StateToDefaultPeriphery();
          formConsole.console.Clear;
          ShowTextMessage(90,90);

          for I := 0 to FStationR415View.Switches.Count - 1 do
          begin
            if (I = 6)or(I = 5)or(I = 5)or(I = 2)or(I = 3)or(I = 1)   then
              FStationR415View.Switches[I].changeProperties := true
            else
              FStationR415View.Switches[I].changeProperties := false;
          end;
        end;
      end;
    end;

    if(FEducationState = Regul_zatuh4_t) then
    begin
      if(FOneShow = false) then
      begin
          ShowMessage('Корреспондент: "Даю генератор !"');
          FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_2));
          FOneShow := true;

          for I := 0 to FStationR415View.Switches.Count - 1 do
          begin
            if (I = 2)or(I = 32) then
              FStationR415View.Switches[I].changeProperties := true
            else
              FStationR415View.Switches[I].changeProperties := false;
          end;
      end;

      if (FOneShow = True) then
      begin
        if FStationR415.PVUSwitch <> PVU_Off then
        begin
          Inc(errors);
//          FMark_regul_zatuh := FMark_regul_zatuh - 0.5;
        end;

        if FStationR415.PVUSwitch = PVU_Off then
        begin
          if FStationR415.Level2Switch >= Indication_60 then
          begin
            if errors = 0 then
            begin
              EducationState := TTreaningStateEnum(Regul_zatuh5_t);
              FOneShow := false;
              FStationR415.StateToDefaultPeriphery();
              formConsole.console.Clear;
              ShowTextMessage(89,89);
              WorkTrue := false;
            end
          end
          else
          begin
            Inc(errors);
//            FMark_regul_zatuh := FMark_regul_zatuh - 0.5;
          end;
        end;
      end;
    end;

    if(FEducationState = Regul_zatuh3_t) then
    begin
      if(FOneShow = false) then
      begin
          ShowMessage('Корреспондент: "Вас понял !"');
          FOneShow := true;

          for I := 0 to FStationR415View.Switches.Count - 1 do
          begin
            if (I = 1)or(I = 2) then
              FStationR415View.Switches[I].changeProperties := true
            else
              FStationR415View.Switches[I].changeProperties := false;
          end;
      end
      else
        FMark_regul_zatuh := FMark_regul_zatuh - 0.5;

      if ((FStationR415.ControlLevelSwitch = Phone_2_Reception)and(FStationR415.PVUSwitch = Phone_2)) then
      begin
        formConsole.console.Clear;
        ShowTextMessage(88,88);
        FOneShow := false;
        FStationR415.StateToDefaultPeriphery();
        EducationState := TTreaningStateEnum(Regul_zatuh4_t);

      end
      else
        FMark_regul_zatuh := FMark_regul_zatuh - 0.5;
    end;

    if(FEducationState = Regul_zatuh2_t) then
    begin
      if FStationR415.PVUSwitch <> Phone_1 then
      begin
        Inc(errors);
//        FMark_regul_zatuh := FMark_regul_zatuh - 0.5;
      end
      else
      begin
        if(FOneShow = false) then
        begin
            ShowMessage('Корреспондент: "Вас понял!"');
            FOneShow := true;
        end;

        if ((FOneShow = true)and (WorkTrue = true)) then
        begin
          ShowMessage('Корреспондент: "Готово !"');
          EducationState := TTreaningStateEnum(Regul_zatuh3_t);
          FOneShow := false;
          FStationR415.StateToDefaultPeriphery();
          formConsole.console.Clear;
          ShowTextMessage(87,87);

          for I := 0 to FStationR415View.Switches.Count - 1 do
          begin
            if (I = -1) then
              FStationR415View.Switches[I].changeProperties := true
            else
              FStationR415View.Switches[I].changeProperties := false;
          end;
        end;
      end;
    end;

   if(FEducationState = Regul_zatuh1_t) then
    begin
      //---
      if(FOneShow = false) then
      begin
        FOneShow := true;
        ShowMessage('Корреспондент: "Вас понял. Даю генератор."');
        FStationR415.ImpulsGenerate := true;

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 2)or(I = 31) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;

        Inc(errors);
      end;

      //---
      if (FStationR415.ImpulsGenerate)and(FOneShow = true) then
      begin
        if FStationR415.PVUSwitch <> PVU_Off then
        begin
          Inc(errors);
        end;

        if FStationR415.Level1Switch >= Indication_60 then
        begin
          if errors = 0 then
          begin
              FStationR415.StateToDefaultPeriphery();
              EducationState := TTreaningStateEnum(Regul_zatuh2_t);
              formConsole.console.Clear;
              ShowTextMessage(86,86);
              FOneShow := false;

              for I := 0 to FStationR415View.Switches.Count - 1 do
              begin
                if (I = 2)or(I = 21) then
                  FStationR415View.Switches[I].changeProperties := true
                else
                  FStationR415View.Switches[I].changeProperties := false;
              end;
          end
          end
          else
          begin
            Inc(errors);
//            FMark_regul_zatuh := FMark_regul_zatuh - 0.5;
          end;
        end;
    end;
    {$ENDREGION}

    {$REGION 'Установка связи'}
    if(EducationState = Ust_sv_t) then
    begin
        ShowMessage('Корреспондент: Слышу Вас хорошо !');
        EducationState := TTreaningStateEnum(Regul_zatuh1_t);
        formConsole.console.Items.Add('Установка связи с корреспондентом выполнена ! ');
        formConsole.console.Clear;
        ShowTextMessage(64,64);
        FOneShow := false;
    end;
    {$ENDREGION}

    {$REGION 'Проверка работы'}
    if(EducationState = Prov_rab2_t) then
    begin
      if(FStationR415.ControlReceptionBroadcastSwitch = Work) then
      begin
        ShowMessage('Станция настроена и готова к работе.');
        EducationState := TTreaningStateEnum(Ust_sv_t);
        formConsole.console.Clear;
        formConsole.console.Items.Add('Проверка работы станции выполнена! ');
        ShowTextMessage(85,85);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = -1) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end;
    end;
    {$ENDREGION}

    {$REGION 'Проверка работы прд'}
    if(EducationState = Prov_rab1_t) then
    begin
      if((FStationR415.IndicationSwitch <> Indication_Broadcast)
        and(FStationR415.ControlReceptionBroadcastSwitch <> Broadcast))then
      begin
        Inc(errors);
        FMark_Prov_rab := FMark_Prov_rab - 2;
      end;

      if(errors = 0) then
      begin
        EducationState := TTreaningStateEnum(Prov_rab2_t);
        formConsole.console.Clear;
        ShowTextMessage(84,84);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 19) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;

      end;
    end;
    {$ENDREGION}

    {$REGION 'Проверка работы прм'}
    if(EducationState = Prov_rab_t) then
    begin
      if(FStationR415.ControlReceptionBroadcastSwitch <> Reception) then
      begin
        Inc(errors);
        FMark_Prov_rab := FMark_Prov_rab - 1;
      end;

      if(FStationR415.DoubleReception <> enabled) then
      begin
        Inc(errors);
        FMark_Prov_rab := FMark_Prov_rab - 1;
      end;

      if (FStationR415.IndicationSwitch <> Indication_60) then
      begin
        Inc(errors);
        FMark_Prov_rab := FMark_Prov_rab - 1;
      end;

      if(errors = 0) then
      begin
        EducationState := TTreaningStateEnum(Prov_rab1_t);
        formConsole.console.Clear;
        ShowTextMessage(83,83);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 19)or(I = 20) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end;
    end;
    {$ENDREGION}

    {$REGION 'Проверка настройки'}
    if(EducationState = Nastr_t) then
    begin
      if(FStationR415View.Animations[5].LampState = LAMP_OFF) then
      begin
        EducationState := TTreaningStateEnum(Prov_rab_t);
        formConsole.console.Clear;
        formConsole.console.Items.Add('Настройка станции выполнена! ');
        ShowTextMessage(82,82);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 19)or(I = 20)or(I = 17) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end
      else
        FMark_Nastr := 0;
    end;
    {$ENDREGION}

    {$REGION 'Проверка включения питания'}
    if EducationState = Vkl_pit_t then
    begin
      if(FStationR415.PowerSupplySecondSwitch <> Enabled) then
      begin
        Inc(errors);
        FMark_vkl_pit:=0;
      end;

      if(errors = 0) then
      begin
        EducationState := TTreaningStateEnum(Nastr_t);
        formConsole.console.Clear;
        formConsole.console.Items.Add('Питание станции включено! ');
        ShowTextMessage(27,27);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if I = 28 then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;

      end;
    end;
    {$ENDREGION}

    {$REGION 'проверка установки в исходное положение'}
    if EducationState = Ust_org_v_ish_pol_t then
    begin
      //Texts[7]
      if ((FStationR415.PowerSupplyFirstSwitch = Enabled)or
        (FStationR415.PowerSupplySecondSwitch = Enabled)) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;

      //Texts[8]

      if (FStationR415.Antena = Disabled) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;

      //Texts[11]
      if (FStationR415.ControlReceptionBroadcastSwitch <> Work) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;

      //Texts[12]
      if (FStationR415.IndicationSwitch <> Indication_60) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;


      //Texts[13]
      if (FStationR415.DoubleReception <> Disabled) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;


      //Texts[14]
      if (FStationR415.PowerLowNormal <> Enabled) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;


      //Texts[16]
      if (FStationR415.ControlLevelSwitch <> Phone_1_Reception) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;


      //Texts[17]
      if (FStationR415.PVUSwitch <> Phone_1) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;


      //Texts[18]
      if ((FStationR415.CallFirstSwitch <> Channel)
        or (FStationR415.CallSecondSwitch <> Channel)) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;


      //Texts[19]
      if ((FStationR415.PhoneFirstSwitch <> Two_Channel_Terminal)
        or(FStationR415.PhoneSecondSwitch <> Two_Channel_Terminal)) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;


      //Texts[20]
      if ((FStationR415.EnabledBroadcastFirstSwitch <> Enabled)
        or(FStationR415.EnabledBroadcastSecondSwitch <> Enabled)) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;

      //Texts[22] ПРД
      if ((FStationR415.BroadcastFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRD1))
        or (FStationR415.BroadcastSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRD2)) )
        or (FStationR415.BroadcastThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRD3)) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;

      //ПРМ
      if ((FStationR415.ReceptionFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRM1))
        or (FStationR415.ReceptionSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRM2))
        or (FStationR415.ReceptionThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRM3))) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;

      if(errors  = 0) then
      begin
        EducationState := TTreaningStateEnum(Vkl_pit_t);
        if FMark_ust_v_ish > 5 then FMark_ust_v_ish := 5;
        if FMark_ust_v_ish < 0 then FMark_ust_v_ish := 0;

        formConsole.console.Clear;
        formConsole.console.Items.Add('Органы выставлены в исходное положение! ');
        ShowTextMessage(25,25);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if I = 10 then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;

      end;
    end;
    {$ENDREGION}

    {$REGION 'Внений осмотр'}
    if EducationState = Vn_osm_t then
    begin
      if(FStationR415.Phone <> Enabled) then
      begin
        FMark_osmotr := 0;
        Inc(errors);
      end;

      if(errors = 0) then
      begin
        formConsole.console.Clear;
        EducationState := TTreaningStateEnum(Ust_org_v_ish_pol_t);
        formConsole.console.Items.Add('Внешний осмотр выполнен ! ');
        ShowTextMessage(6,6);
        ShowTextMessage(23,24);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 11)or(I = 12)or(I = 13)or(I = 14)or(I = 15)or(I = 16)
          or(I = 7)or(I = 8)
          or(I = 3)or(I = 4)
          or(I = 5)or(I = 6)
          or(I = 2)
          or(I = 1)
          or(I = 18)
          or(I = 17)
          or(I = 20)
          or(I = 19)
          or(I = 30)
          or(I = 9)or(I = 10)then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;

      end;
    end;
    {$ENDREGION}

  end;

  {$REGION 'Вывод подсказок на экран'}
  procedure TTreaningR415.ShowQuestion;
  begin
    errors := 0;
    formConsole.console.Clear;

    if EducationState = Vn_osm_t then
    begin
      if(FStationR415.Phone <> Enabled) then
      begin
        formConsole.console.Items.Add(Texts[3]);
        formConsole.console.Items.Add(Texts[4]);
        formConsole.console.Items.Add(Texts[5]);
        Inc(ShowsQuestion);
      end;
    end;

    if EducationState = Ust_org_v_ish_pol_t then
    begin
      if ((FStationR415.PowerSupplyFirstSwitch = Enabled)or
        (FStationR415.PowerSupplySecondSwitch = Enabled)) then
      begin
        formConsole.console.Items.Add(Texts[7]);
        Inc(ShowsQuestion);
      end;
      //Texts[8]

      if (FStationR415.Antena = Disabled) then
      begin
        formConsole.console.Items.Add(Texts[8]);
        Inc(ShowsQuestion);
      end;

      //Texts[11]
      if (FStationR415.ControlReceptionBroadcastSwitch <> Work) then
      begin
        formConsole.console.Items.Add(Texts[11]);
        Inc(ShowsQuestion);
      end;

      //Texts[12]
      if (FStationR415.IndicationSwitch <> Indication_60) then
      begin
        formConsole.console.Items.Add(Texts[12]);
        Inc(ShowsQuestion);
      end;

      //Texts[13]
      if (FStationR415.DoubleReception <> Disabled) then
      begin
        formConsole.console.Items.Add(Texts[13]);
        Inc(ShowsQuestion);
      end;


      //Texts[14]
      if (FStationR415.PowerLowNormal <> Enabled) then
      begin
        formConsole.console.Items.Add(Texts[14]);
        Inc(ShowsQuestion);
      end;


      //Texts[16]
      if (FStationR415.ControlLevelSwitch <> Phone_1_Reception) then
      begin
        formConsole.console.Items.Add(Texts[16]);
        Inc(ShowsQuestion);
      end;


      //Texts[17]
      if (FStationR415.PVUSwitch <> Phone_1) then
      begin
        formConsole.console.Items.Add(Texts[17]);
        Inc(ShowsQuestion);
      end;


      //Texts[18]
      if ((FStationR415.CallFirstSwitch <> Channel)
        or (FStationR415.CallSecondSwitch <> Channel)) then
      begin
        formConsole.console.Items.Add(Texts[18]);
        Inc(ShowsQuestion);
      end;


      //Texts[19]
      if ((FStationR415.PhoneFirstSwitch <> Two_Channel_Terminal)
        or(FStationR415.PhoneSecondSwitch <> Two_Channel_Terminal)) then
      begin
        formConsole.console.Items.Add(Texts[19]);
        Inc(ShowsQuestion);
      end;


      //Texts[20]
      if ((FStationR415.EnabledBroadcastFirstSwitch <> Enabled)
        or(FStationR415.EnabledBroadcastSecondSwitch <> Enabled)) then
      begin
        formConsole.console.Items.Add(Texts[20]);
        Inc(ShowsQuestion);
      end;


      //Texts[22] ПРД
      if ((FStationR415.BroadcastFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRD1))
        or (FStationR415.BroadcastSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRD2)) )
        or (FStationR415.BroadcastThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRD3)) then
      begin
        formConsole.console.Items.Add(Texts[23]);
        Inc(ShowsQuestion);
      end;

      //ПРМ
      if ((FStationR415.ReceptionFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRM1))
        or (FStationR415.ReceptionSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRM2))
        or (FStationR415.ReceptionThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRM3))) then
      begin
        formConsole.console.Items.Add(Texts[24]);
        Inc(ShowsQuestion);
      end;
    end;

    if EducationState = Vkl_pit_t then
    begin
      if(FStationR415.PowerSupplySecondSwitch <> Enabled) then
      begin
        formConsole.console.Items.Add(Texts[26]);
        Inc(errors);
        Inc(ShowsQuestion);
      end;
    end;

    if(EducationState = Nastr_t) then
    begin
      formConsole.console.Items.Add(Texts[28]);
      Inc(errors);
      Inc(ShowsQuestion);
    end;

    if(EducationState = Prov_rab_t) then
    begin
      if(FStationR415.ControlReceptionBroadcastSwitch <> Reception) then
      begin
        formConsole.console.Items.Add(Texts[39]);
        Inc(ShowsQuestion);
      end;

      if(FStationR415.DoubleReception <> enabled) then
      begin
        formConsole.console.Items.Add(Texts[40]);
        Inc(ShowsQuestion);
      end;

      if (FStationR415.IndicationSwitch <> Indication_60) then
      begin
        formConsole.console.Items.Add(Texts[41]);
        Inc(ShowsQuestion);
      end;
    end;

    if(EducationState = Prov_rab1_t) then
    begin
      errors := 0;

      if(FStationR415.IndicationSwitch <> Indication_Broadcast) then
      begin
        formConsole.console.Items.Add(Texts[47]);
        Inc(ShowsQuestion);
      end;

      if(FStationR415.ControlReceptionBroadcastSwitch <> Broadcast)then
      begin
        formConsole.console.Items.Add(Texts[46]);
        Inc(ShowsQuestion);
      end;

    end;

    if(EducationState = Prov_rab2_t) then
    begin
      if(FStationR415.ControlReceptionBroadcastSwitch <> Work) then
      begin
         formConsole.console.Items.Add(Texts[53]);
         Inc(ShowsQuestion);
      end;
    end;

    if(EducationState = Ust_sv_t) then
    begin
      ShowTextMessage(56,63);
      Inc(ShowsQuestion);
    end;

    if(FEducationState = Regul_zatuh1_t) then
    begin
      //---
      if(FOneShow = false) then
      begin
        ShowTextMessage(66,67);
        Inc(ShowsQuestion);
      end;
      //---
      if FStationR415.ImpulsGenerate then
      begin
        if FStationR415.PVUSwitch <> PVU_Off then
        begin
          ShowTextMessage(68,68);
          Inc(ShowsQuestion);
        end;

        if FStationR415.PVUSwitch = PVU_Off then
        begin

          if FStationR415.Level1Switch < Indication_60 then
          begin
            Inc(ShowsQuestion);
            ShowTextMessage(69,69);
          end;
        end;
      end;
      //---
    end;

    if(FEducationState = Regul_zatuh2_t) then
    begin
      if FStationR415.PVUSwitch <> Phone_1 then
      begin
        Inc(ShowsQuestion);
        ShowTextMessage(70,70);
      end
      else
      begin
        if(FOneShow = false) then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(71,71);
        end;

        if ((WorkTrue = false)and(FOneShow = true)) then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(72,73);
        end;
      end;
    end;

    if(FEducationState = Regul_zatuh3_t) then
    begin
      if(FOneShow = false) then
      begin
        Inc(ShowsQuestion);
        ShowTextMessage(74,74);
      end;

      if FStationR415.ControlLevelSwitch <> Phone_2_Reception then
      begin
        Inc(ShowsQuestion);
        ShowTextMessage(75,76);
      end;

      if FStationR415.PVUSwitch <> Phone_2 then
      begin
        Inc(ShowsQuestion);
        ShowTextMessage(75,76);
      end;
    end;

    if(FEducationState = Regul_zatuh4_t) then
    begin
      if(FOneShow = false) then
      begin
          ShowTextMessage(77,77);
          Inc(ShowsQuestion);
      end;

      if (FOneShow = True) then
      begin
        if FStationR415.PVUSwitch <> PVU_Off then
        begin
          ShowTextMessage(68,68);
          Inc(ShowsQuestion);
        end;

        if FStationR415.PVUSwitch = PVU_Off then
        begin
          if FStationR415.Level2Switch < Indication_60 then
          begin
            ShowTextMessage(78,78);
            Inc(ShowsQuestion);
          end;
        end;
      end;
    end;


    if(FEducationState = Regul_zatuh5_t) then
    begin
      if(FStationR415.PVUSwitch = Phone_2) then
      begin
        if(FOneShow = false) then
        begin
          ShowTextMessage(71,71);
          Inc(ShowsQuestion);
        end;


        if(WorkTrue = false) then
        begin
          ShowTextMessage(71,72);
          Inc(ShowsQuestion);
        end;
      end
      else
      begin
          ShowTextMessage(80,80);
      end;
    end;

    if(FEducationState = Regul_zatuh6_t) then
    begin
        ShowMessage('Вы: "Вас понял !"');
    end;

    if(FEducationState = Sdacha_kanalov_t) then
    begin
        formConsole.console.Clear;
        ShowTextMessage(91,91);
        //Iтлф - IIтлф = IIтлф прием
        if FStationR415.ControlLevelSwitch <> Phone_2_Reception then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(92,92);
        end;

        //Iтлф = 4ПР.ОК
        if FStationR415.PhoneFirstSwitch  <> Terminal then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(93,93);
        end;

        //IIтлф = 2ПР.ОК
        if FStationR415.PhoneSecondSwitch  <> Two_Channel_Terminal then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(94,94);
        end;


        //ПВУ = IIтлф
        if FStationR415.PVUSwitch  <> Phone_2 then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(95,95);
        end;

        //Iтлф Канал-раб-соед.лин = РАБОТА
        if FStationR415.CallFirstSwitch  <> Call_Work then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(96,96);
        end;

        //IIтлф Канал-раб-соед.лин = КАНАЛ
        if FStationR415.CallSecondSwitch  <> Channel then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(97,97);
        end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'Анимация'}
  //регулировка остаточного затухания, часть 6
  procedure TTreaningR415.RegulOstatZatuh6;
  begin

  end;


  //регулировка остаточного затухания, часть 5
  procedure TTreaningR415.RegulOstatZatuh5;
  begin
    if(FEducationState = Regul_zatuh5_t) then
    begin
      if(FStationR415.PVUSwitch = Phone_2) then
      begin
        FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_0));
      end;

      if(FstationR415.DownUpFirstSwitch = UP) then
      begin
        WorkTrue := true;
      end;
    end;
  end;

  //анимация остаточного затухания, часть 4
  procedure TTreaningR415.RegulOstatZatuh4;
  begin
    if(FEducationState = Regul_zatuh4_t) then
    begin
      if(FOneShow = false) then
      begin
          FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_2));
      end;

      if (FOneShow = True) then
      begin
        if FStationR415.PVUSwitch = PVU_Off then
        begin
          if FStationR415.Level2Switch = Indication_0 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_1));
          if FStationR415.Level2Switch = Indication_20 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_2));
          if FStationR415.Level2Switch = Indication_40 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_3));
          if FStationR415.Level2Switch = Indication_Broadcast then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_5));
          if FStationR415.Level2Switch = Indication_Reflection then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_6));
          if FStationR415.Level2Switch = Indication_10 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_7));
          if FStationR415.Level2Switch = Indication_Minus_5 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_8));
          if FStationR415.Level2Switch = Indication_Minus_20 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_1));
          if FStationR415.Level2Switch = Indication_Input_Device then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_2));

          if FStationR415.Level2Switch >= Indication_60 then
          begin
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_4));
          end;
        end;
      end;
    end;
  end;

  //анимация остаточного затухания, часть 3
  procedure TTreaningR415.RegulOstatZatuh3;
  begin

  end;

  //анимация и чуток логики остаточного затухания, часть 2
  procedure TTreaningR415.RegulOstatZatuh2;
  begin
    if(FEducationState = Regul_zatuh2_t) then
    begin
      if FStationR415.PVUSwitch = Phone_1 then
      begin
        FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_0));
        if (FStationR415.DownUpFirstSwitch = up) then
        begin
          WorkTrue := True;
        end;
      end;
    end;
  end;

  //анимация остаточного затухания, часть 1
  procedure TTreaningR415.RegulOstatZatuh1;
  begin

    if(FEducationState = Regul_zatuh1_t) then
    begin
      //---
      if(FOneShow = false) then
      begin
        FStationR415.ImpulsGenerate := true;
      end;
      //---
      if FStationR415.ImpulsGenerate then
      begin
        if FStationR415.PVUSwitch = PVU_Off then
        begin
          if FStationR415.Level1Switch = Indication_0 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_1));
          if FStationR415.Level1Switch = Indication_20 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_2));
          if FStationR415.Level1Switch = Indication_40 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_3));
          if FStationR415.Level1Switch = Indication_Broadcast then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_5));
          if FStationR415.Level1Switch = Indication_Reflection then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_6));
          if FStationR415.Level1Switch = Indication_10 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_7));
          if FStationR415.Level1Switch = Indication_Minus_5 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_8));
          if FStationR415.Level1Switch = Indication_Minus_20 then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_1));
          if FStationR415.Level1Switch = Indication_Input_Device then
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_2));

          if FStationR415.Level1Switch >= Indication_60 then
          begin
            FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_4));
          end;
        end;

      end;
      //---
    end;
  end;

  //анимация проверки установки связи с корреспондентом
  procedure TTreaningR415.UstanovkaSviazi();
  begin
    if(EducationState = Ust_sv_t) then
    begin
      FStationR415.Level2Switch := Indication_20;
      FStationR415.Level1Switch := Indication_20;
    end;

  end;

  //анимация проверка работы станции РАБОТА
  procedure TTreaningR415.ProverkaRaboti();
  begin
    if(EducationState = Prov_rab2_t) then
    begin
      if(FStationR415.ControlReceptionBroadcastSwitch = Work) then
      begin
        FStationR415View.Animations[9].OnLamp();
        FStationR415View.Animations[11].DisplayChange(TAnimationDisplayStateEnum(d_4));
      end;
    end;
  end;

  //анимация проверки работы станции ПРД
  procedure TTreaningR415.ProverkaRabotiPRD();
  begin
    if(EducationState = Prov_rab1_t) then
    begin
      if((FStationR415.IndicationSwitch = Indication_Broadcast)
        and(FStationR415.ControlReceptionBroadcastSwitch = Broadcast))then
      begin
        FStationR415View.Animations[9].OnLamp();
        FStationR415View.Animations[11].DisplayChange(TAnimationDisplayStateEnum(d_8));
      end
      else
      begin
        FStationR415View.Animations[9].StateToDefault();
        FStationR415View.Animations[11].StateToDefault();
      end;

      if((FStationR415.ControlReceptionBroadcastSwitch = Reception)and((FStationR415.IndicationSwitch = Indication_60))) then
      begin
        FStationR415View.Animations[9].OnLamp();
        FStationR415View.Animations[11].DisplayChange(TAnimationDisplayStateEnum(d_8));
      end;
    end;
  end;

  //анимация проверки работы станции ПРМ
  procedure TTreaningR415.ProverkaRabotPRM();
  begin
    if(EducationState = Prov_rab_t) then
    begin

      if((FStationR415.ControlReceptionBroadcastSwitch = Reception)and
        ((FStationR415.IndicationSwitch = Indication_60))) then
      begin
        FStationR415View.Animations[9].OnLamp();
        FStationR415View.Animations[11].DisplayChange(TAnimationDisplayStateEnum(d_8));
      end
      else
      begin
        FStationR415View.Animations[9].StateToDefault();
        FStationR415View.Animations[11].StateToDefault();
      end;

      if(FStationR415.DoubleReception = enabled) then
        FStationR415View.Animations[6].StateToDefault()
      else
      begin
          FStationR415View.Animations[6].OnLamp();
      end;
    end;
  end;

  //анимация настройки станции
  procedure TTreaningR415.Nastroika;
  begin
    if(EducationState = Nastr_t) then
    begin
      if(FStationR415.DownUp8Switch = Up) then
      begin
        FOneShow := true;
        //вкл. контро анф. прд
        FStationR415View.Animations[7].OnLamp();
        //прд = прм
        FStationR415View.LabelsPrdPrm[0].ChangeValue(FStationR415View.LabelsPrdPrm[3].value);
        FStationR415View.LabelsPrdPrm[1].ChangeValue(FStationR415View.LabelsPrdPrm[4].value);
        FStationR415View.LabelsPrdPrm[2].ChangeValue(FStationR415View.LabelsPrdPrm[5].value);
        Delay(2000);
        //выкл. контро анф. прд
        FStationR415View.Animations[7].StateToDefault();
        //выставляем частоту прд в соответствии с настройкой станции
        FStationR415View.LabelsPrdPrm[0].ChangeValue(FStationR415.PRD1);
        FStationR415View.LabelsPrdPrm[1].ChangeValue(FStationR415.PRD2);
        FStationR415View.LabelsPrdPrm[2].ChangeValue(FStationR415.PRD3);
        //вкл. контро анф. прм
        FStationR415View.Animations[8].OnLamp();
        Delay(2000);
        //вкл. контро анф. прм
        FStationR415View.Animations[8].StateToDefault();
        //выставляем частоту прд в соответствии с настройкой станции
        FStationR415View.LabelsPrdPrm[3].ChangeValue(FStationR415.PRM1);
        FStationR415View.LabelsPrdPrm[4].ChangeValue(FStationR415.PRM2);
        FStationR415View.LabelsPrdPrm[5].ChangeValue(FStationR415.PRM3);
        //отключаем неисправность БКУ прм
        FStationR415View.Animations[5].StateToDefault();
      end;
    end;
  end;

  //анимация включения электропитания станции,
  procedure TTreaningR415.VklucheniePitania();
  begin
    if EducationState = Vkl_pit_t then
    begin
      if(FStationR415.PowerSupplySecondSwitch = Enabled) then
      begin
         FStationR415View.Animations[0].OnLamp();
         FStationR415View.Animations[1].OnLamp();
         FStationR415View.Animations[2].OnLamp();
         FStationR415View.Animations[3].OnLamp();
         FStationR415View.Animations[4].OnLamp();
         FStationR415View.Animations[5].OnLamp();
         FStationR415View.Animations[6].OnLamp();

         FStationR415View.LabelsPrdPrm[0].Show();
         FStationR415View.LabelsPrdPrm[1].Show();
         FStationR415View.LabelsPrdPrm[2].Show();
         FStationR415View.LabelsPrdPrm[3].Show();
         FStationR415View.LabelsPrdPrm[4].Show();
         FStationR415View.LabelsPrdPrm[5].Show();
      //анимируем все происходящее
      end
      else
      begin
        FStationR415View.Animations[0].StateToDefault();
        FStationR415View.Animations[1].StateToDefault();
        FStationR415View.Animations[2].StateToDefault();
        FStationR415View.Animations[3].StateToDefault();
        FStationR415View.Animations[5].OnLamp();

        FStationR415View.LabelsPrdPrm[0].hide();
        FStationR415View.LabelsPrdPrm[1].hide();
        FStationR415View.LabelsPrdPrm[2].hide();
        FStationR415View.LabelsPrdPrm[3].hide();
        FStationR415View.LabelsPrdPrm[4].hide();
        FStationR415View.LabelsPrdPrm[5].hide();
      end;
    end;
  end;

  //анимация установки органов в исходное положение
  procedure TTreaningR415.StateToDefaultOrgan();
  begin

  end;

  //анимация внешнего осмотра станции
  procedure TTreaningR415.VneshniiOsmotr();
  begin

  end;
  {$ENDREGION}

  {$REGION 'Доп функции'}
    //закидываем в память "TList<string>" тексты для вывода пользователю
  procedure TTreaningR415.addToTextList();
  begin
    Texts.Add('1. Внешний осмотр '#13);                                             //0
    Texts.Add('   -проверить надежность крепления блоков в стойке;'#13);            //1
    Texts.Add('   -проверить надежность подключения заземления станции;'#13);       //2
    Texts.Add('   -убедиться в отсутствии внешних механических повреждений,'#13);   //3
    Texts.Add('     в наличие ручек переключателей, в целостности корпуса'#13);     //4
    Texts.Add('     микротелефонной трубки (МТ) и подключения ее гнезду МТГ.   [Б17]'#13);  //5

    Texts.Add('2. Установить органы управления в исходное положение'#13);           //6
    Texts.Add('   -тумблер СЕТЬ в положение ВЫКЛ;'#13);                             //7
    Texts.Add('   -антенный фидер(эквивалент) подключить к разъему АНТЕННА.   [1Б03]'#13);    //8
    Texts.Add(' Запрещяется включать питание станции без нагрузки.'#13);                      //9
    Texts.Add('На блоке контроля и управления(БКУ):'#13);                                     //10
    Texts.Add('   -переключатель РАБОТА-КОНТРОЛЬ в положение РАБОТА;   [Б01-1]'#13);          //11
    Texts.Add('   -переключатель ИНДИКАЦИЯ в положение ВХОД ПРИЕМ 60;   [Б01-1]'#13);         //12
    Texts.Add('   -тумблер ДЕЖ ПРИЕМ-ДУПЛ в положение ДЕЖ ПРИЕМ;   [Б01-1]'#13);              //13
    Texts.Add('   -тумблер МОЩН в положение ПОНИЖ.   [Б01-1]'#13);                            //14
    Texts.Add('На блоке уплотнения каналов(БУК):'#13);                                        //15
    Texts.Add('   -переключатель КОНТР УРОВНЯ в положение 1-ТЛФ ПРИЕМ;   [Б-17]'#13);         //16
    Texts.Add('   -переключатель ПВУ в положение 1-ТЛФ;   [Б-17]'#13);                        //17
    Texts.Add('   -переключатели КАН-РАБ-СОЕД.ЛИН.1ТЛФ и IIТЛФ в положение КАН;   [Б-17]'#13);     //18
    Texts.Add('   -перекл. 2ПР ОК-ТРАНЗИТ-4ПР ОК I ТЛФ и IIТЛФ в положение 2ПР ОК;   [Б-17]'#13);  //19
    Texts.Add('   -переключатель ВКЛ ПЕР обоих ТЛГ каналов в верхнее положение.   [Б-17]'#13);     //20
    Texts.Add('На синтезаторе частот(СЧ):'#13);                                           //21
    Texts.Add('   -установить раб. частоты с помощью переключателей ПРД./ПРМ.'#13);       //22
    Texts.Add('   -установите частоту передачи ' + IntToStr(FStationR415.PRD1) + IntToStr(FStationR415.PRD2)+IntToStr(FStationR415.PRD3)+';   [Б02]');//23
    Texts.Add('   -установить частоту приема '+ IntToStr(FStationR415.PRM1) + IntToStr(FStationR415.PRM2)+IntToStr(FStationR415.PRM3) + ' ;   [Б02]'); //24

    Texts.Add('3.Включение электропитания станции:'#13);                                //25
    Texts.Add('   -тумблер СЕТЬ(+27B) установить в положение ВКЛ;'#13);                 //26
    Texts.Add('4.Настройка станции:'#13);                                               //27
    Texts.Add('   -нажать на синтезаторе частот(СЧ) кнопку НАСТРОЙКА;   [Б02]'#13);             //28
    Texts.Add('При настройке фильтров приемника светится инди. "КОНТР АНФ ПРИЕМ"'#13);  //29
    Texts.Add('показание индикаторов ПЕРЕДАЧА совпадает с показаниями индикаторов'#13); //30
    Texts.Add('ПРИЕМ. По окончании автоматической настройки приемника индикатор'#13);   //31
    Texts.Add('"КОНТРО АНФ ПРИЕМ" на СЧ гаснет, показания индикаторов ПЕРЕДАЧА'#13);    //32
    Texts.Add('восстанавливаются в соответствии с положениями переключателей'#13);      //33
    Texts.Add('ПЕРЕДАЧА I,II,III, после чего происходит автоматическая настройка'#13);  //34
    Texts.Add('передатчика, о чем сигнализирует индикатор КОНТРО АНФ ПЕРЕДАЧА.'#13);    //35
    Texts.Add('Когда индикаторы КОНТР АНФ гаснут, это свидетельствует об окончании'#13);//36
    Texts.Add('настройки БПП.'#13);                                                     //37
    Texts.Add('4.Проверка работоспособности станции.'#13);               //38
    Texts.Add('   -переключатель РАБОТА-КОНТР в положение КОНТР ПРМ;   [Б01-1]'#13);              //39
    Texts.Add('   -переключатель ДУПЛ-ДЕЖ ПРИЕМ в положение ДУПЛ;   [Б01-1]'#13);                 //40
    Texts.Add('   -переключатель ИНДИКАЦИЯ в положение, при котором показания   [Б01-1]'#13);     //41
    Texts.Add('не менее 50 дБ;'#13);                                                    //42
    Texts.Add('   ПРИМЕЧАНИЕ:'#13);                                                     //43
    Texts.Add('При исправности приемного тракта радиостанции в режиме КОНТР ПРМ'#13);   //44
    Texts.Add(' светится индикатор ИСПРАВНО.'#13);                                      //45
    Texts.Add('   -переключатель РАБОТА-КОНТРОЛЬ в положение КОНТР ПРД;   [Б01-1]'#13);            //46
    Texts.Add('   -переключатель ИНДИКАЦИЯ в положение ВЫХОД ПРД;   [Б01-1]'#13);                  //47
    Texts.Add('   -переключатель МОЩН в положение ПОНИЖ;   [Б01-1]'#13);                           //48
    Texts.Add('   Примечание'#13);                                                       //49
    Texts.Add('Признаком исправности передающего тракта радиостанции в КОНТР ПРД'#13);   //50
    Texts.Add(' является свечение индикатора ИСПРАВНО, а так же отсутствие свечения'#13);  //51
    Texts.Add(' индикаторов СВЯЗИ НЕТ ПРД и ОТКАЗЫ.'#13);                                  //52
    Texts.Add('   -переключатель РАБОТА-КОНТР в положение РАБОТА   [Б01-1]'#13);                      //53
    Texts.Add('Индикаторный прибор должен показывать не менее -2 Дб'#13);                   //54

    Texts.Add('Для установления связи с корреспондентом необходимо:'#13);              //55
    Texts.Add('1. Проверить положение органов управления на блоках: синтезаторе'#13);  //56
    Texts.Add('   частот и блоке уплотнения. Органы управления защванных блоков'#13);  //57
    Texts.Add('   должны находиться в положениях, указанных в I разделе.'#13);         //58
    Texts.Add('2. При наличии сигнала приема от корреспондента пропадает шум'#13);     //59
    Texts.Add('   в телефоне микротелефонной трубки.'#13);                             //60
    Texts.Add('3. Вызвать корреспондента с помошью МК трубки, например:"1460. я"'#13); //61
    Texts.Add('   1450. Как меня слышите ?" При ответе корреспондента: "Слышу Вас"'#13); //62
    Texts.Add('   хорошо!", продолжить работу. ( вызов - клавиша ПРОБЕЛ)'#13);                  //63
    Texts.Add('5. а. Регулировка остаточного затухания каналов ТЧ. 1-го канала'#13);  //64
    Texts.Add('   Вы являетесь "Старшей станцией".'#13);            //65
    Texts.Add('   Вы: "1460 Приступем к регулировке каналов. Дайте генератор по'#13);//66            //65
    Texts.Add('     первому каналу"; '#13);//67
    Texts.Add('   -переключатель ПВУ IТЛФ-IIТЛФ в положение ВЫКЛ '#13);//68
    Texts.Add('   -потенциометром УРОВЕНЬ IТЛФ установить стрелку прибора в "0"'#13);//69
    Texts.Add('   -переключатель ПВУ IТЛФ-IIТЛФ в положение IТЛФ.'#13);//70
    Texts.Add('   Вы: "Готово. Даю вам генератор."'#13);//71
    Texts.Add('   -На блоке ПВУ нажать кнопку ИГ и УДЕРЖИВАТЬ ее до команды'#13);//72
    Texts.Add('     "Готово"(Появится после нажатия клавиши "Выполнил")'#13);//73
    Texts.Add('   Вы: "Перейти на 2-й канал."'#13);//74
    Texts.Add('   -На блоке ПВУ переключатель ПВУ IТЛФ-IIТЛФ, переключатель'#13);//75
    Texts.Add('     КОНТРОЛЬ УРОВНЯ в положение IIТЛФ ПРИЕМ.'#13);//76
    Texts.Add('   Вы: "Дайте генератор по 2-му каналу."'#13);//77
    Texts.Add('   -потенциометром УРОВЕНЬ IIТЛФ установить стрелку прибора в "0"'#13);//78
    Texts.Add('   Вы: "Вас понял !"'#13);//79
    Texts.Add('   -переключатель ПВУ IТЛФ-IIТЛФ в положение IIТЛФ.'#13);//80
    Texts.Add('ОБУЧЕНИЕ ПРОЙДЕНО УСПЕШНО, ОТКРЫТ РЕЖИМ ТРЕНИРОВКИ  !'#13);//81
    Texts.Add('4. a. Проверка работоспособности ПРМ'#13);//82
    Texts.Add('   b. Проверка работоспособности ПРД'#13);//83
    Texts.Add('  c. Перевод в состояние РАБОТА.'#13);//84
    Texts.Add('5. Установка связи с корреспондентом.'#13);//85
    Texts.Add('5. б. Доложить. Дать генератор.'#13);//86
    Texts.Add('5. в. Перевод на второй канал.'#13);//87
    Texts.Add('5. г. Регулировка остаточного затухания каналов ТЧ. 2-го канала'#13);  //88
    Texts.Add('5. д. Доложить. Дать генератор.'#13);//89
    Texts.Add('6. Сдать каналы.'#13);//90
    Texts.Add('Установить переключатели блока управления в след. полож.:'#13);//91
    Texts.Add('   -Iтлф - IIтлф = IIтлф прием'#13);//92
    Texts.Add('   -Iтлф = 4ПР.ОК'#13);//93
    Texts.Add('   -IIтлф = 2ПР.ОК'#13);//94
    Texts.Add('   -ПВУ = IIтлф'#13);//95
    Texts.Add('   -Iтлф Канал-раб-соед.лин = РАБОТА'#13);//96
    Texts.Add('   -IIтлф Канал-раб-соед.лин = КАНАЛ'#13);//97
  end;

  //задержка по времени
  procedure TTreaningR415.Delay(time: Integer);
  var
    h: THandle;
  begin
    Application.ProcessMessages;
    h:=CreateEvent(nil,true,false,'');
    WaitForSingleObject(h,time);
    CloseHandle(h);
  end;

  //показать текст в консоль
  procedure TTreaningR415.ShowTextMessage(i: Integer; i1: integer);
  var
   j:Integer;
  begin
    for j := i to i1 do
    begin
      formConsole.console.items.Add(Texts[j]);
    end;
  end;

  procedure TTreaningR415.ResetErrors;
  var I:integer;
  begin
    for I := 0 to FStationR415View.Switches.Count - 1 do
    begin
        FStationR415View.Switches[I].Error := 0;
    end;
  end;

  function TTreaningR415.getErrors():integer;
  var I,N:integer;
  begin
    N := 0;
    for I := 0 to FStationR415View.Switches.Count - 1 do
    begin
          N:= N+ FStationR415View.Switches[I].Error;
    end;
    Exit(N);
  end;
  {$ENDREGION}
end.
