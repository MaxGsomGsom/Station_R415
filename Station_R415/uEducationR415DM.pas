unit uEducationR415DM;

interface

uses classes, SysUtils, Dialogs,Generics.Collections, uStationR415DM,uStationR415ViewDM,
  Windows, ExtCtrls,Forms,uAnimationDM, consoleForm, uSwitchDM;

type
  //какой пункт обучения делаем
  TEducationStateEnum = (Vn_osm, Ust_org_v_ish_pol, Vkl_pit, Nastr, Prov_rab,Prov_rab1,
                          Prov_rab2,Ust_sv, Regul_zatuh1, Regul_zatuh2, Regul_zatuh3,
                          Regul_zatuh4,Regul_zatuh5,Regul_zatuh6, Sdacha_kanalov,
                          Konec_obuch);


  TEducationR415 = class
      private
        errors:integer;
        Texts: TList<string>;
        FStationR415 : TStationR415;
        FStationR415View: TStationR415View;

        FEducationState: TEducationStateEnum;

        FOneShow: boolean;

        procedure Delay(time: integer);

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
        procedure SdachaKanalov();



      public
        //настройка области видимости
        property EducationState: TEducationStateEnum
          read FEducationState write FEducationState;
        //объявление методов класса
        constructor Create(StationR415: TStationR415;StationR415View: TStationR415View);
        destructor Destroy; override;

        procedure onStationR415StateChange();
        procedure addToTextList();

    end;

implementation
  uses uStationR415Form;

  //описание конструктора
  constructor TEducationR415.Create(StationR415: TStationR415;StationR415View: TStationR415View);
  var I :integer;
  begin
    //сохраняем ссылку на объект станции
    FStationR415 := StationR415;
    FStationR415View := StationR415View;
    //подписываемся на событие изменения
    FStationR415.StateChangeEvent := onStationR415StateChange;
    //инициализация
    Texts := TList<string>.Create;

    //заполняем массив текстом
    addToTextList();

    //включаем первый режим обучения(внешний осмотр)
    EducationState := TEducationStateEnum(Vn_osm);
    ShowTextMessage(0,5);

    FOneShow := false;


    for I := 0 to FStationR415View.Switches.Count - 1 do
    begin
      FStationR415View.Switches[I].EducationType := ETEducation;
      if I = 0 then
        FStationR415View.Switches[I].changeProperties := true
      else
        FStationR415View.Switches[I].changeProperties := false;
    end;


  end;

   //описание десструктора
  destructor TEducationR415.Destroy;
  begin
    //освобождаем память
    Texts.Free;
    //уничтожаем объект
    inherited;

    FStationR415.PhoneButton := false;

  end;
//------------------------------------------------------------------------------
  //ловим событие изменения станции из uStationR415DM.pas
  procedure TEducationR415.onStationR415StateChange();
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
    SdachaKanalov();

  end;

  //сдаем каналы
  procedure TEducationR415.SdachaKanalov;
  var I:integer;
  begin
    if(FEducationState = Sdacha_kanalov) then
    begin
      if((FStationR415.PhoneButton = true)and(FOneShow = false)) then
      begin
        ShowMessage('Корреспондент: "Вас понял. Выполняю !"');
        FOneShow := true;
        SdachaKanalov();

      end
      else
      begin
        if FOneShow = true then
        begin
          errors := 0;

          formConsole.console.Clear;
          ShowTextMessage(83,83);
          //Iтлф - IIтлф = IIтлф прием
          if FStationR415.ControlLevelSwitch <> Phone_2_Reception then
          begin
            Inc(errors);
            ShowTextMessage(84,84);
          end;

          //Iтлф = 4ПР.ОК.
          if FStationR415.PhoneFirstSwitch  <> Terminal then
          begin
            Inc(errors);
            ShowTextMessage(85,85);
          end;

          //IIтлф = 2ПР.ОК.
          if FStationR415.PhoneSecondSwitch  <> Two_Channel_Terminal then
          begin
            Inc(errors);
            ShowTextMessage(86,86);
          end;


          //ПВУ = IIтлф.
          if FStationR415.PVUSwitch  <> Phone_2 then
          begin
            Inc(errors);
            ShowTextMessage(87,87);
          end;

          //Iтлф Канал-раб-соед.лин = РАБОТА.
          if FStationR415.CallFirstSwitch  <> Call_Work then
          begin
            Inc(errors);
            ShowTextMessage(88,88);
          end;

          //IIтлф Канал-раб-соед.лин = КАНАЛ.
          if FStationR415.CallSecondSwitch  <> Channel then
          begin
            Inc(errors);
            ShowTextMessage(89,89);
          end;

          if errors = 0 then
          begin
            formConsole.console.Clear;
            ShowMessage('Обучение пройдено успешно. Можете перейти к тренировке.');
            formConsole.console.Items.Add('Норматив сдан. Можете переходить в следуюший режим.');

            StationR415Form.StationR415.FinishTask := FEducation;

            for I := 0 to FStationR415View.Switches.Count - 1 do
            begin
              FStationR415View.Switches[I].EducationType := ETNone;
              FStationR415View.Switches[I].changeProperties := true;
            end;
          end;

        end;
      end;
    end;
  end;

  //регулировка остаточного затухания, часть 6
  procedure TEducationR415.RegulOstatZatuh6;
  var I:integer;
  begin
    if(FEducationState = Regul_zatuh6) then
    begin
      if((FStationR415.PhoneButton = true)and(FOneShow = false)) then
      begin
          EducationState := TEducationStateEnum(Sdacha_kanalov);
          FOneShow := false;
          FStationR415.StateToDefaultPeriphery();
          formConsole.console.Clear;
          ShowTextMessage(81,82);

          for I := 0 to FStationR415View.Switches.Count - 1 do
          begin
            if (I = 6)or(I = 5)or(I = 5)or(I = 2)or(I = 3)or(I = 1)   then
              FStationR415View.Switches[I].changeProperties := true
            else
              FStationR415View.Switches[I].changeProperties := false;
          end;

      end
      else
      begin
        formConsole.console.Clear;
        ShowTextMessage(79,79);
      end;
    end;
  end;

  //регулировка остаточного затухания, часть 5
  procedure TEducationR415.RegulOstatZatuh5;
  var I:integer;
  begin
    if(FEducationState = Regul_zatuh5) then
    begin


      if(FStationR415.PVUSwitch = Phone_2) then
      begin
        FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_0));

        if((FStationR415.PhoneButton = true)and (FOneShow = false)) then
        begin
          ShowMessage('Корреспондент: "Вас понял !"');
          FOneShow := true;
          formConsole.console.Clear;
          ShowTextMessage(72,73);

          for I := 0 to FStationR415View.Switches.Count - 1 do
          begin
            if (I = 21)  then
              FStationR415View.Switches[I].changeProperties := true
            else
              FStationR415View.Switches[I].changeProperties := false;
          end;
        end
        else
        begin
          formConsole.console.Clear;
          ShowTextMessage(71,71);
        end;


        if((FstationR415.DownUpFirstSwitch = UP)and(FOneShow = true)) then
        begin
          ShowMessage('Корреспондент: "Готово !"');
          EducationState := TEducationStateEnum(Regul_zatuh6);
          FOneShow := false;
          FStationR415.StateToDefaultPeriphery();
          formConsole.console.Clear;

          for I := 0 to FStationR415View.Switches.Count - 1 do
          begin
            if (I = -1)  then
              FStationR415View.Switches[I].changeProperties := true
            else
              FStationR415View.Switches[I].changeProperties := false;
          end;
        end;
      end
      else
      begin
        formConsole.console.Clear;
        ShowTextmessage(80,80);
      end;
    end;
  end;

  //регулировка остаточного затухания, часть 4
  procedure TEducationR415.RegulOstatZatuh4;
  var I:integer;
  begin
    if(FEducationState = Regul_zatuh4) then
    begin
      if((FStationR415.PhoneButton = true)and (FOneShow = false)) then
      begin
          ShowMessage('Корреспондент: "Даю генератор !"');
          FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_2));
          FOneShow := true;
          formConsole.console.Clear;

          for I := 0 to FStationR415View.Switches.Count - 1 do
          begin
            if (I = 2)or(I = 32)  then
              FStationR415View.Switches[I].changeProperties := true
            else
              FStationR415View.Switches[I].changeProperties := false;
          end;
      end;

      if (FOneShow = True) then
      begin
        if FStationR415.PVUSwitch <> PVU_Off then
        begin
          ShowTextMessage(68,68);
          Inc(errors);
        end;

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
            if errors = 0 then
            begin
              EducationState := TEducationStateEnum(Regul_zatuh5);
              FOneShow := false;
              FStationR415.StateToDefaultPeriphery();
              formConsole.console.Clear;
              ShowTextMessage(71,71);


              for I := 0 to FStationR415View.Switches.Count - 1 do
              begin
                if (I = 2)  then
                  FStationR415View.Switches[I].changeProperties := true
                else
                  FStationR415View.Switches[I].changeProperties := false;
              end;

            end
          end
          else
          begin
            Inc(errors);
            formConsole.console.Clear;
            ShowTextMessage(78,78);
          end;
        end;
      end;
    end;
  end;

  //регулировка остаточного затухания, часть 3
  procedure TEducationR415.RegulOstatZatuh3;
  var I:integer;
  begin
    if(FEducationState = Regul_zatuh3) then
    begin
      if((FStationR415.PhoneButton = true)and (FOneShow = false)) then
      begin
          ShowMessage('Корреспондент: "Вас понял !"');
          FOneShow := true;
      end;

      if ((FStationR415.ControlLevelSwitch = Phone_2_Reception) and (FStationR415.PVUSwitch = Phone_2)) then
      begin
        formConsole.console.Clear;
        ShowTextMessage(77,77);
        FOneShow := false;
        FStationR415.StateToDefaultPeriphery();
        EducationState := TEducationStateEnum(Regul_zatuh4);

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


  //регулировка остаточного затухания, часть 2
  procedure TEducationR415.RegulOstatZatuh2;
  var I:integer;
  begin
    if(FEducationState = Regul_zatuh2) then
    begin
      formConsole.console.Clear;

      if FStationR415.PVUSwitch <> Phone_1 then
      begin
        Inc(errors);
        ShowTextMessage(70,70);
      end
      else
      begin
        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 21) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;

        FStationR415View.Animations[10].DisplayChange(TAnimationDisplayStateEnum(d_0));
        ShowTextMessage(71,73);
        if((FStationR415.PhoneButton = true)and (FOneShow = false)) then
        begin
            ShowMessage('Корреспондент: "Вас понял!"');
            FOneShow := true;

            for I := 0 to FStationR415View.Switches.Count - 1 do
            begin
              if (I = 21) then
                FStationR415View.Switches[I].changeProperties := true
              else
                FStationR415View.Switches[I].changeProperties := false;
            end;
        end;
        if ((FOneShow = true)and (FStationR415.DownUpFirstSwitch = up)) then
        begin
          ShowMessage('Корреспондент: "Готово !"');
          EducationState := TEducationStateEnum(Regul_zatuh3);
          FOneShow := false;
          FStationR415.StateToDefaultPeriphery();
          formConsole.console.Clear;
          ShowTextMessage(74,76);

            for I := 0 to FStationR415View.Switches.Count - 1 do
            begin
              if (I = 1)or(I = 2) then
                FStationR415View.Switches[I].changeProperties := true
              else
                FStationR415View.Switches[I].changeProperties := false;
            end;
        end;


      end;
    end;
  end;

  //регулировка остаточного затухания, часть 1
  procedure TEducationR415.RegulOstatZatuh1;
  var I:integer;
  begin
    errors := 0;
    if(FEducationState = Regul_zatuh1) then
    begin
      formConsole.console.Clear;
      //---------------------------------------------
      if((FStationR415.PhoneButton = true)and (FOneShow = false)) then
      begin
        ShowMessage('Корреспондент: "Вас понял. Даю генератор."');
        FOneShow := true;
        FStationR415.ImpulsGenerate := true;

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 2)or(I = 31) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end
      else
      begin
        if(FOneShow = false) then
          ShowTextMessage(66,67);
      end;
      //---------------------------------------------
      if FStationR415.ImpulsGenerate then
      begin
        if FStationR415.PVUSwitch <> PVU_Off then
        begin
          ShowTextMessage(68,68);
          Inc(errors);
        end;

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

            if errors = 0 then
            begin
              FStationR415.StateToDefaultPeriphery();
              EducationState := TEducationStateEnum(Regul_zatuh2);
              FOneShow := false;

              for I := 0 to FStationR415View.Switches.Count - 1 do
              begin
                if (I = 2) then
                  FStationR415View.Switches[I].changeProperties := true
                else
                  FStationR415View.Switches[I].changeProperties := false;
              end;
            end
          end
          else
          begin
            Inc(errors);
            ShowTextMessage(69,69);
          end;
        end;

      end;
      //---
    end;
  end;

  //обработка проверки установки связи станции
  procedure TEducationR415.UstanovkaSviazi();
  begin
    if(EducationState = Ust_sv) then
    begin
      if(FStationR415.PhoneButton = true) then
      begin
        ShowMessage('Корреспондент: Слышу Вас хорошо !');
        EducationState := TEducationStateEnum(Regul_zatuh1);
        ShowMessage('Регулировка остаточного затухания каналов ТЧ.');
        formConsole.console.Clear;
        ShowTextMessage(64,65);
        FStationR415.StateToDefaultPeriphery();
      end
      else
      begin
         formConsole.console.Clear;
         ShowTextMessage(55,63);
      end;
    end;

  end;

  //обработка проверка работы станции РАБОТА
  procedure TEducationR415.ProverkaRaboti();
  var I:integer;
  begin
    if(EducationState = Prov_rab2) then
    begin
      if(FStationR415.ControlReceptionBroadcastSwitch = Work) then
      begin
        FStationR415View.Animations[9].OnLamp();
        FStationR415View.Animations[11].DisplayChange(TAnimationDisplayStateEnum(d_4));
        ShowMessage('Станция настроена и готова к работе.');
        EducationState := TEducationStateEnum(Ust_sv);
        formConsole.console.Clear;
        ShowTextMessage(55,63);

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

  //обработка проверки работы станции ПРД
  procedure TEducationR415.ProverkaRabotiPRD();
  var I:integer;
  begin
    if(EducationState = Prov_rab1) then
    begin
      errors := 0;

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
        formConsole.console.Clear;
        Inc(errors);
        ShowTextMessage(46,52);
      end;

      if((FStationR415.ControlReceptionBroadcastSwitch = Reception)and((FStationR415.IndicationSwitch = Indication_60))) then
      begin
        FStationR415View.Animations[9].OnLamp();
        FStationR415View.Animations[11].DisplayChange(TAnimationDisplayStateEnum(d_8));
      end;

      if(errors = 0) then
      begin
        formConsole.console.Clear;
        ShowTextMessage(53,54);
        EducationState := TEducationStateEnum(Prov_rab2);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 19) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end;

    end;


  end;

  //обработка проверки работы станции ПРМ
  procedure TEducationR415.ProverkaRabotPRM();
  var I:integer;
  begin
    if(EducationState = Prov_rab) then
    begin
      errors := 0;
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
        inc(errors);
      end;

      if(FStationR415.DoubleReception = enabled) then
        FStationR415View.Animations[6].StateToDefault()
      else
      begin
          FStationR415View.Animations[6].OnLamp();
          inc(errors);
          formConsole.console.Clear;
          ShowTextMessage(38,45);
      end;


      if(errors = 0) then
      begin
        formConsole.console.Clear;
        ShowTextMessage(46,52);
        EducationState := TEducationStateEnum(Prov_rab1);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 19)or(I = 20) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end;

    end;
  end;

  //обработка настройки станции
  procedure TEducationR415.Nastroika;
  var I:integer;
  begin
    if(EducationState = Nastr) then
      if(FStationR415.DownUp8Switch = Up) then
      begin
        Application.ProcessMessages;
        ShowMessage('Внимание ! Происходит настройка станции. Закройте это сообщение и дождитесь окончания настройки!');
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

        ShowMessage('Настройка станции проведена успешно.');

        formConsole.console.Items.Clear;
        EducationState := TEducationStateEnum(Prov_rab);
        formConsole.console.Items.Add('Настройка станции выполнена!');
        ShowTextMessage(38,45);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 19)or(I = 20)or(I = 17) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end
      else
      begin
        formConsole.console.Clear;
        ShowTextMessage(27,37);
      end;
  end;

  //обработка включения электропитания станции,
  procedure TEducationR415.VklucheniePitania();
  var I:integer;
  begin
    if EducationState = Vkl_pit then
    begin
      errors :=0;
      formConsole.console.Clear;
      //включаем +27В
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

        formConsole.console.Items.Add(Texts[26]);
        Inc(errors);
      end;

      if(errors = 0) then
      begin
        EducationState := TEducationStateEnum(Nastr);
        formConsole.console.Items.Add('Питание станции включено!');
        ShowTextMessage(27,37);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if I = 28 then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end;

    end;
  end;

  //обработка установки органов в исходное положение
  procedure TEducationR415.StateToDefaultOrgan();
  var I:integer;
  begin
    if EducationState = Ust_org_v_ish_pol then
    begin
      errors := 0;
      formConsole.console.Clear;
      //Texts[7]-тумблер СЕТЬ в положение ВЫКЛ
      if ((FStationR415.PowerSupplyFirstSwitch = Enabled)or
        (FStationR415.PowerSupplySecondSwitch = Enabled)) then
      begin
        formConsole.console.Items.Add(Texts[7]);
        Inc(errors);
      end;

      //Texts[8]-антенный фидер(эквивалент) подключить к разъему АНТЕННА.

      if (FStationR415.Antena = Disabled) then
      begin
        formConsole.console.Items.Add(Texts[8]);
        Inc(errors);
      end;

      //Texts[11]-переключатель РАБОТА-КОНТРОЛЬ в положение РАБОТА.
      if (FStationR415.ControlReceptionBroadcastSwitch <> Work) then
      begin
        formConsole.console.Items.Add(Texts[11]);
        Inc(errors);
      end;

      //Texts[12]-переключатель ИНДИКАЦИЯ в положение ВХОД ПРИЕМ 60.
      if (FStationR415.IndicationSwitch <> Indication_60) then
      begin
        formConsole.console.Items.Add(Texts[12]);
        Inc(errors);
      end;


      //Texts[13]-тумблер ДЕЖ ПРИЕМ-ДУПЛ в положение ДЕЖ ПРИЕМ.
      if (FStationR415.DoubleReception <> Disabled) then
      begin
        formConsole.console.Items.Add(Texts[13]);
        Inc(errors);
      end;


      //Texts[14]-тумблер МОЩН в положение ПОНИЖ.
      if (FStationR415.PowerLowNormal <> Enabled) then
      begin
        formConsole.console.Items.Add(Texts[14]);
        Inc(errors);
      end;


      //Texts[16]-переключатель КОНТР УРОВНЯ в положение 1-ТЛФ ПРИЕМ.
      if (FStationR415.ControlLevelSwitch <> Phone_1_Reception) then
      begin
        formConsole.console.Items.Add(Texts[16]);
        Inc(errors);
      end;


      //Texts[17]-переключатель ПВУ в положение 1-ТЛФ.
      if (FStationR415.PVUSwitch <> Phone_1) then
      begin
        formConsole.console.Items.Add(Texts[17]);
        Inc(errors);
      end;


      //Texts[18]-переключатели КАН-РАБ-СОЕД.ЛИН.1ТЛФ и IIТЛФ в положение КАН.
      if ((FStationR415.CallFirstSwitch <> Channel)
        or (FStationR415.CallSecondSwitch <> Channel)) then
      begin
        formConsole.console.Items.Add(Texts[18]);
        Inc(errors);
      end;


      //Texts[19]-перекл. 2ПР ОК-ТРАНЗИТ-4ПР ОК I ТЛФ и IIТЛФ в положение 2ПР ОК.
      if ((FStationR415.PhoneFirstSwitch <> Two_Channel_Terminal)
        or(FStationR415.PhoneSecondSwitch <> Two_Channel_Terminal)) then
      begin
        formConsole.console.Items.Add(Texts[19]);
        Inc(errors);
      end;


      //Texts[20]-переключатель ВКЛ ПЕР обоих ТЛГ каналов в верхнее положение.
      if ((FStationR415.EnabledBroadcastFirstSwitch <> Enabled)
        or(FStationR415.EnabledBroadcastSecondSwitch <> Enabled)) then
      begin
        formConsole.console.Items.Add(Texts[20]);
        Inc(errors);
      end;


      //Texts[22] ПРД.
      if ((FStationR415.BroadcastFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRD1))
        or (FStationR415.BroadcastSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRD2)) )
        or (FStationR415.BroadcastThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRD3)) then
      begin
        formConsole.console.Items.Add(Texts[23]);
        Inc(errors);
      end;

      //ПРМ.
      if ((FStationR415.ReceptionFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRM1))
        or (FStationR415.ReceptionSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRM2))
        or (FStationR415.ReceptionThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRM3))) then
      begin
        formConsole.console.Items.Add(Texts[24]);
        Inc(errors);
      end;

      if(errors = 0) then
      begin
        EducationState := TEducationStateEnum(Vkl_pit);
        formConsole.console.Items.Add('Органы выставлены в исходное положение!');
        ShowTextMessage(25,26);

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if I = 10 then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;

      end;
    end;
  end;

  //обработка внешнего осмотра станции.
  procedure TEducationR415.VneshniiOsmotr();
  var I: integer;
  begin
    if EducationState = Vn_osm then
    begin
      errors := 0;
      formConsole.console.Clear;
      //подключен ли тлф
      if(FStationR415.Phone <> Enabled) then
      begin
        formConsole.console.Items.Add(Texts[3]);
        formConsole.console.Items.Add(Texts[4]);
        formConsole.console.Items.Add(Texts[5]);
        Inc(errors);
      end;

      if(errors = 0) then
      begin
        formConsole.console.Clear;
        EducationState := TEducationStateEnum(Ust_org_v_ish_pol);
        formConsole.console.Items.Add('Внешний осмотр выполнен !');
        ShowTextMessage(6,24);

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
  end;

    //закидываем в память "TList<string>" тексты для вывода пользователю
  procedure TEducationR415.addToTextList();
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
    Texts.Add('4.Проверка работоспособности станции. Устанавливаем:'#13);               //38
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
    Texts.Add('3. Вызвать корреспондента с помошью МК трубки, например:"1460. я'#13); //61
    Texts.Add('   1450. Как меня слышите ?" При ответе корреспондента: "Слышу Вас"'#13); //62
    Texts.Add('   хорошо!", продолжить работу. ( вызов - клавиша ПРОБЕЛ)'#13);                  //63
    Texts.Add('Регулировка остаточного затухания каналов ТЧ.'#13);  //64
    Texts.Add('   Вы являетесь "Старшей станцией".'#13);            //65
    Texts.Add('   Вы: "1460 Приступем к регулировке каналов. Дайте генератор по'#13);//66            //65
    Texts.Add('     первому каналу"; '#13);//67
    Texts.Add('   -переключатель ПВУ IТЛФ-IIТЛФ в положение ВЫКЛ '#13);//68
    Texts.Add('   -потенциометром УРОВЕНЬ IТЛФ установить стрелку прибора в "0"'#13);//69
    Texts.Add('   -переключатель ПВУ IТЛФ-IIТЛФ в положение IТЛФ.'#13);//70
    Texts.Add('   Вы: "Готово. Даю вам генератор."'#13);//71
    Texts.Add('   -На блоке ПВУ нажать кнопку ИГ и УДЕРЖИВАТЬ ее до команды'#13);//72
    Texts.Add('     "Готово"'#13);//73
    Texts.Add('   Вы: "Перейти на 2-й канал."'#13);//74
    Texts.Add('   -На блоке ПВУ. IТЛФ-IIТЛФ = IIТЛФ, переключатель'#13);//75
    Texts.Add('     КОНТРОЛЬ УРОВНЯ в положение IIТЛФ ПРИЕМ.'#13);//76
    Texts.Add('   Вы: "Дайте генератор по 2-му каналу."'#13);//77
    Texts.Add('   -потенциометром УРОВЕНЬ IIТЛФ установить стрелку прибора в "0"'#13);//78
    Texts.Add('   Вы: "Вас понял !"'#13);//79
    Texts.Add('   -переключатель ПВУ IТЛФ-IIТЛФ в положение IIТЛФ.'#13);//80
    Texts.Add('   Вы: "Сдать 1-й канал на пульт 1810 в режиме 4ПР.ОК,'#13);//81
    Texts.Add('     второй канал оставить для дежурной связи"'#13);//82
    Texts.Add('Установить переключатели блока управления в след. полож.:'#13);//83
    Texts.Add('   -Iтлф - IIтлф = IIтлф прием'#13);//84
    Texts.Add('   -Iтлф = 4ПР.ОК'#13);//85
    Texts.Add('   -IIтлф = 2ПР.ОК'#13);//86
    Texts.Add('   -ПВУ = IIтлф'#13);//87
    Texts.Add('   -Iтлф Канал-раб-соед.лин = РАБОТА'#13);//88
    Texts.Add('   -IIтлф Канал-раб-соед.лин = КАНАЛ'#13);//89
  end;

  //задержка по времени
  procedure TEducationR415.Delay(time: Integer);
  var
    h: THandle;
  begin
    Application.ProcessMessages;
    h:=CreateEvent(nil,true,false,'');
    WaitForSingleObject(h,time);
    CloseHandle(h);
  end;

  //показать текст в консоль
  procedure TEducationR415.ShowTextMessage(i: Integer; i1: integer);
  var
   j:Integer;
  begin
    for j := i to i1 do
    begin
      formConsole.console.items.Add(Texts[j]);
    end;
  end;

end.
