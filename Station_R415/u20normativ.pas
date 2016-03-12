unit u20normativ;

interface
uses classes, SysUtils, Dialogs,Generics.Collections, uStationR415DM,uStationR415ViewDM,
  Windows, ExtCtrls,Forms,uAnimationDM, consoleForm,uTCPClienDM, uSwitchDM;

type
  //какой пункт обучения делаем
  T20ZadachaStateEnum = (Vn_osm_20, Ust_org_v_ish_pol_20, Vkl_pit_20, Nastr_20,
    Prov_rab_prm_20,Prov_rab_prd_20,Prov_rab_rab_20, Ust_sv_20, Regul_zat1_20,
    Regul_zat2_20, Regul_zat3_20,Regul_zat4_20, Regul_zat5_20, Regul_zat6_20,
    Regul_zat7_20,Regul_zat8_20,Regul_zat9_20,Regul_zat10_20, Regul_zat10_21,
    Regul_zat9_22, Regul_zat10_22, Regul_zat9_23, Regul_zat9_24,Regul_zat9_25,
    Regul_zat9_26, Regul_zat9_27, Regul_zat9_28, Sdacha_kanala1_20, Sdacha_kanala2_20,
    Finish_20);

  TYPE_MESSAGE = (NONE, OK,NEXT, HOW_VOICE, VOICE_OK, GET_GENERATE, GENERATE,
    SDAT_KANAL);

  TZadacha20 = class
    private

       errors:integer;
       FStationR415 : TStationR415;
       FStationR415View: TStationR415View;
       FEducationState: T20ZadachaStateEnum;
       TSM: TYPE_MESSAGE;
       TGM: TYPE_MESSAGE;

       FOneShow: boolean;
       GetMsg : boolean;

       TCP415:TTCPClientR415;

       today: TDateTime;
       hourS,minutsS,secondsS, miliSecondsS
       ,hourF,minutsF,secondsF, miliSecondsF
       ,hour,minuts,seconds, miliSeconds  : Word;


      //оценки за прохождение тренировки
      FMark_osmotr,FMark_ust_v_ish,FMark_vkl_pit,FMark_Nastr,FMark_Prov_rab,
      FMark_ust_sv,FMark_regul_zatuh: Double;

    public
      GenerateState : Boolean;

      constructor Create(StationR415: TStationR415;StationR415View: TStationR415View;
        TCP415tmp:TTCPClientR415);
      procedure CheckWork();

      procedure DelayForAnimations(time: Integer);
      procedure AnimationVklucheniePitania();
      procedure AnimationNastroika();
      procedure AnimationProverkaRabotPRM();
      procedure AnimationProverkaRabotiPRD();
      procedure AnimationProverkaRaboti();
      procedure AnimationRegulOstatZatuh3();
      procedure AnimationRegulOstatZatuh4();

      procedure GetMessage(str: string);
      procedure SendMessage(str: string);

      procedure GenerateActive();
      procedure ResetErrors;
      function getErrors():integer;

      procedure OnTime(Sender: TObject);

      procedure DefTypeMessages();

  end;

implementation

uses main, uStationR415Form;

constructor TZadacha20.Create(StationR415: TStationR415;StationR415View: TStationR415View;
   TCP415tmp:TTCPClientR415);
var I:integer;
begin
    hour := 0; hourS := 0; hourF := 0;
    minuts := 0; minutsS := 0; minutsF := 0;
    //сохраняем ссылку на объект станции
    FStationR415 := StationR415;
    FStationR415View := StationR415View;
    //подписываемся на событие изменения
    FStationR415.StateChangeEvent := CheckWork;

    FStationR415.GenerateActive := GenerateActive;

    //включаем первый режим обучения(внешний осмотр)
    FEducationState := T20ZadachaStateEnum(Vn_osm_20);

    TCP415 := TCP415tmp;

    FOneShow := false;
    GetMsg := False;

    FMark_osmotr:= 5;
    FMark_ust_v_ish:= 5;
    FMark_vkl_pit := 5;
    FMark_Nastr := 5;
    FMark_Prov_rab := 5;
    FMark_ust_sv:=5;
    FMark_regul_zatuh := 5;
    TSM := NONE;
    TGM := NONE;
    //выставляем пункт для работы
    FEducationState := Vn_osm_20;
    //создаем таймер

    for I := 0 to FStationR415View.Switches.Count - 1 do
    begin
      FStationR415View.Switches[I].EducationType := ETnormativ;
      if I = 0 then
        FStationR415View.Switches[I].changeProperties := true
      else
        FStationR415View.Switches[I].changeProperties := false;
    end;

    today := Time;
    DecodeTime(today, hourS,minutsS,secondsS, miliSecondsS);
end;

procedure TZadacha20.OnTime(Sender: TObject);
begin

end;


procedure TZadacha20.DefTypeMessages;
begin
  TSM := NONE;
  TGM := NONE;
end;

//сообщаем о состоянии кнопки генератора
procedure TZadacha20.GenerateActive;
begin
  if FStationR415.DownUpFirstSwitch = Up then
    MainForm.TCPClient.setGenerateActivation(1)
  else
    MainForm.TCPClient.setGenerateActivation(0);
end;

//отправленное сообщение, определяем его тип
procedure TZadacha20.SendMessage(str: string);
begin
  if ((Pos('Готово',str) <> 0)or(Pos('готово',str) <> 0)
        or(Pos('Понял',str) <> 0) or (Pos('понял',str) <> 0)) then
  begin
    TSM := OK;
  end
  else
  if ((Pos('Перейти',str) <> 0) or (Pos('перейти',str) <> 0) ) then
  begin
    TSM := NEXT
  end
  else
  if (((Pos('Как',str) <> 0) or (Pos('как',str) <> 0) )and ((Pos('Слышите',str) <> 0) or (Pos('слышите',str) <> 0) )) then
    TSM := HOW_VOICE
  else
  if (Pos('Хорошо',str) <> 0)or(Pos('хорошо',str) <> 0) then
  begin
    TSM := VOICE_OK
  end
  else
  if (((Pos('Дайте',str) <> 0)or(Pos('дайте',str) <> 0))and ((Pos('Генератор',str) <> 0)or(Pos('генератор',str) <> 0)) ) then
  begin
    TSM := GET_GENERATE
  end
  else
  if (((Pos('Даю',str) <> 0)or(Pos('даю',str) <> 0))and ((Pos('Генератор',str) <> 0)or(Pos('генератор',str) <> 0)) ) then
  begin
    TSM := GENERATE
  end
  else
  if (((Pos('Сдать',str) <> 0)or(Pos('сдать',str) <> 0))and ((Pos('Канал',str) <> 0)or(Pos('канал',str) <> 0)) ) then
  begin
    TSM := SDAT_KANAL
  end
  else
    TSM := NONE;

  CheckWork;

end;

//узнаем о том что пришло сообщение и выполняем проверку работы
procedure TZadacha20.GetMessage(str: string);
begin
  if ((Pos('Готово',str) <> 0)or(Pos('готово',str) <> 0)
        or(Pos('Понял',str) <> 0) or (Pos('понял',str) <> 0)) then
  begin
    TGM := OK;
  end
  else
  if (((Pos('Как',str) <> 0) or (Pos('как',str) <> 0) )and ((Pos('Слышите',str) <> 0) or (Pos('слышите',str) <> 0) )) then
    TGM := HOW_VOICE
  else
  if (Pos('Хорошо',str) <> 0)or(Pos('хорошо',str) <> 0) then
  begin
    TGM := VOICE_OK
  end
  else
  if ((Pos('Перейти',str) <> 0) or (Pos('перейти',str) <> 0) ) then
  begin
    TGM := NEXT
  end
  else
  if (((Pos('Дайте',str) <> 0)or(Pos('дайте',str) <> 0))and ((Pos('Генератор',str) <> 0)or(Pos('генератор',str) <> 0)) ) then
  begin
    TGM := GET_GENERATE
  end
  else
  if (((Pos('Даю',str) <> 0)or(Pos('даю',str) <> 0))and ((Pos('Генератор',str) <> 0)or(Pos('генератор',str) <> 0)) ) then
  begin
    TGM := GENERATE
  end
  else
  if (((Pos('Сдать',str) <> 0)or(Pos('сдать',str) <> 0))and ((Pos('Канал',str) <> 0)or(Pos('канал',str) <> 0)) ) then
  begin
    TGM := SDAT_KANAL
  end
  else
    TGM := NONE;

  GetMsg := true;
  CheckWork();
end;

  //проверка выполнения задания
procedure TZadacha20.CheckWork;
var I:integer;
    mark:integer;
begin
    errors :=0;

  {$REGION 'Проверка сдачи каналов'}

    if FEducationState = Sdacha_kanala2_20 then
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

        today := Time;
        DecodeTime(today, hourF,minutsF,secondsF, miliSecondsF);

        hour := abs(hourF - hourS);
        minuts := abs(minutsF - minutsS);
        seconds := abs(secondsF - secondsS);

        if minuts <= 15 then
          mark := 5;
        if (minuts > 15)and(minuts <= 17) then
          mark := 4;
        if (mark > 17) and (mark <= 19) then
          mark := 3;

        if (self.getErrors = 0)and(minuts <= 19)and(hour = 0) then
            begin
              ShowMessage(' !!! Норматив сдан !!! Оценка: ' + IntToStr(mark) + ' Неверных кликов: ' + IntToStr(self.getErrors) + ' Время выполнения: ' + IntToStr(hour) + ':' + IntToStr(minuts) + ':' + IntToStr(seconds));
              formConsole.console.Items.Add(' !!! Норматив сдан !!! Оценка: ' + IntToStr(mark) + ' Неверных кликов: ' + IntToStr(self.getErrors) + ' Время выполнения: ' + IntToStr(hour) + ':' + IntToStr(minuts) + ':' + IntToStr(seconds));
              TCP415.setFinish(1);
              StationR415Form.StationR415.FinishTask := FEducation;
            end
            else
            begin
              ShowMessage('Норматив НЕ сдан. Неверных кликов: ' + IntToStr(self.getErrors) + ' Время выполнения: ' + IntToStr(hour) + ':' + IntToStr(minuts) + ':' + IntToStr(seconds));
              formConsole.console.Items.Add('Норматив НЕ сдан. Неверных кликов: ' + IntToStr(self.getErrors) + ' Время выполнения: ' + IntToStr(hour) + ':' + IntToStr(minuts) + ':' + IntToStr(seconds));
              TCP415.setFinish(0);
              StationR415Form.StationR415.FinishTask := FEducation;
            end;

            for I := 0 to FStationR415View.Switches.Count - 1 do
            begin
              FStationR415View.Switches[I].EducationType := ETNone;
              FStationR415View.Switches[I].changeProperties := true;
            end;
      end
      else
        TCP415.setFinish(0);

    end;
  {$ENDREGION}

  {$REGION 'Сообщение о сдачи каналов на 414'}
    if FEducationState = Sdacha_kanala1_20 then
    begin
      if MainForm.lbl10.Caption = 'Главная' then
      begin
        //пришло ли подтверждение о выполнении
        if TGM <> OK then
          Inc(errors);
        //смотрим отправлено ли "Сдать каналы"
        if TSM <> SDAT_KANAL then
          Inc(errors);

      end
      else
      begin
        //пришло ли "Сдать каналы"
        if TGM <> SDAT_KANAL then
          Inc(errors);
        //смотрим отправлено ли подтверждение о выполнении
        if TSM <> OK then
          Inc(errors);
      end;

      if errors = 0 then
      begin
        FEducationState := T20ZadachaStateEnum(Sdacha_kanala2_20);
        formConsole.console.Items.Add('Сообщение о сдачи канала обработано(удалить)! ');
        DefTypeMessages();

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 6)or(I = 5)or(I = 5)or(I = 2)or(I = 3)or(I = 1)   then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end;

    end;
  {$ENDREGION}

    //регулировка КТЧ-----------------------------------------------------------

  {$REGION 'доклад о готовности(п) отжатие кнопки ИГ(г)'}
    if (FEducationState =  Regul_zat9_27) then
    begin
      if MainForm.lbl10.Caption = 'Подчиненная' then
      begin
        //ПВУ IТЛФ
        if FStationR415.PVUSwitch <> Phone_2 then
          Inc(errors);
        //смотрим отправлено ли "Готово"
        if TSM <> OK then
          Inc(errors);

      end
      else
      begin
        //пришло ли подтверждение о выполнении
        if TGM <> OK then
          Inc(errors);
        //отпустил ли ИГ
        if FStationR415.DownUpFirstSwitch <> down then
          Inc(errors);
      end;

      if errors = 0 then
      begin
        FEducationState := T20ZadachaStateEnum(Sdacha_kanala1_20);
        formConsole.console.Items.Add('2 канал ТЧ отрегулирован! ');
        DefTypeMessages();

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

  {$REGION 'регулировка КТЧ второго канала(п) и нажатие кнопки ИГ(г)'}
    if (FEducationState =  Regul_zat9_26) then
    begin
      if MainForm.lbl10.Caption = 'Подчиненная' then
      begin
        //дают ли генератор
        if GenerateState <> true then
          Inc(errors);
        //ПВУ выключить
        if FStationR415.PVUSwitch <> PVU_Off then
          Inc(errors);
        //индикация в ноль
        if FStationR415.Level2Switch < Indication_60 then
          Inc(errors);
      end
      else
      begin
        //нажата ли у него кнопка генератора
        if FStationR415.DownUpFirstSwitch <> up then
          Inc(errors);
      end;

      AnimationRegulOstatZatuh4();

      if errors = 0 then
      begin
        FEducationState := T20ZadachaStateEnum(Regul_zat9_27);
        DefTypeMessages();
      end;
    end;
    {$ENDREGION}

  {$REGION 'проверка отправки сообщения о даче Главной станцией ИГ'}
    if(FEducationState = Regul_zat9_25) then
    begin
      if MainForm.lbl10.Caption = 'Главная' then
      begin
        //пришло ли "Дайте генератор"
        if TGM <> GET_GENERATE then
          Inc(errors);
        //смотрим отправлено ли "Вас понял. Даю гену"
        if TSM <> OK then
          Inc(errors);
      end
      else
      begin
        //смотрим отправлено ли "Дайте генератор"
        if TSM <> GET_GENERATE then
          Inc(errors);
        //смотрим пришло ли "Вас понял. Даю гену"
        if TGM <> OK then
          Inc(errors);

      end;

      if errors = 0 then
      begin
        FEducationState := T20ZadachaStateEnum(Regul_zat9_26);
        formConsole.console.Items.Add('Про генератор договорились(УДалить ) ');
        DefTypeMessages();

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 2)or(I = 32)or(I = 21) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end;
    end;
    {$ENDREGION}

  {$REGION 'доклад о готовности(г) отжатие кнопки ИГ(п)'}
    if (FEducationState =  Regul_zat9_24) then
    begin
      if MainForm.lbl10.Caption = 'Главная' then
      begin
        //ПВУ IIТЛФ
        if FStationR415.PVUSwitch <> Phone_2 then
          Inc(errors);
        //смотрим отправлено ли "Готово"
        if TSM <> OK then
          Inc(errors);

      end
      else
      begin
        //пришло ли подтверждение о выполнении
        if TGM <> OK then
          Inc(errors);
        //отпустил ли ИГ
        if FStationR415.DownUpFirstSwitch <> down then
          Inc(errors);
      end;

      if errors = 0 then
      begin
        FEducationState := T20ZadachaStateEnum(Regul_zat9_25);
        formConsole.console.Items.Add('2 канал ТЧ отрегулирован! ');
        DefTypeMessages();

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if  (I = -1) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end;

    end;
    {$ENDREGION}

  {$REGION 'регулировка КТЧ второго канала(г) и нажатие кнопки ИГ(п)'}
    if (FEducationState =  Regul_zat9_23) then
    begin
      if MainForm.lbl10.Caption = 'Главная' then
      begin
        //дают ли генератор
        if GenerateState <> true then
          Inc(errors);
        //ПВУ выключить
        if FStationR415.PVUSwitch <> PVU_Off then
          Inc(errors);
        //индикация в ноль
        if FStationR415.Level2Switch < Indication_60 then
          Inc(errors);
      end
      else
      begin
        //нажата ли у него кнопка генератора
        if FStationR415.DownUpFirstSwitch <> up then
          Inc(errors);
      end;

      AnimationRegulOstatZatuh4();

      if errors = 0 then
      begin
        FEducationState := T20ZadachaStateEnum(Regul_zat9_24);
        DefTypeMessages();
      end;
    end;
    {$ENDREGION}

  {$REGION 'Запрос генератора по второму каналу'}
    if (FEducationState = Regul_zat10_22) then
    begin
      if MainForm.lbl10.Caption = 'Главная' then
      begin
        //смотрим отправлено ли "Дайте генератор по второму каналу"
        if TSM <> GET_GENERATE then
          Inc(errors);
        //смотрим пришло ли  "Вас понял, даю генератор"
        if TGM <> OK then
          Inc(errors);
      end
      else
      begin
         //смотрим пришло ли "Дайте генератор по второму каналу"
        if TGM <> GET_GENERATE then
          Inc(errors);
        //смотрим отправлено ли "Вас понял, даю генератор"
        if TSM <> OK then
          Inc(errors);
      end;

      if errors = 0 then
      begin
        FEducationState := T20ZadachaStateEnum(Regul_zat9_23);
        formConsole.console.Items.Add('Запросы генератора получены(удалить) ');
        DefTypeMessages();

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 2)or(I = 32)or(I = 21) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end;
    end;
  {$ENDREGION}

  {$REGION 'Проверка установки связи по 2-му каналу'}
    if (FEducationState = Regul_zat10_21) then
    begin
      if MainForm.lbl10.Caption = 'Главная' then
      begin
        //смотрим отправлено ли "Как меня слышите"
        if TSM <> HOW_VOICE then
          Inc(errors);
        //смотрим пришло ли  "Слышу вас хорошо"
        if TGM <> VOICE_OK then
          Inc(errors);
      end
      else
      begin
         //смотрим пришло ли "Как меня слышите"
        if TGM <> HOW_VOICE then
          Inc(errors);
        //смотрим отправлено ли "Слышу вас хорошо"
        if TSM <> VOICE_OK then
          Inc(errors);
      end;

      if errors = 0 then
      begin
        FEducationState := T20ZadachaStateEnum(Regul_zat10_22);
        formConsole.console.Items.Add('Связь работает нормально(удалить) ');
        DefTypeMessages();
      end;
    end;
  {$ENDREGION}

  {$REGION 'ПВУ = 2тлф'}
  if(FEducationState = Regul_zat9_20) then
  begin
    //ПВУ = 2тлф
    if FStationR415.PVUSwitch <> Phone_2 then
        Inc(errors);
    //IТлф-IIТлф. контр уровня дб
    if FStationR415.ControlLevelSwitch <> Phone_2_Reception  then
      Inc(errors);


    if errors = 0 then
    begin
      FEducationState := T20ZadachaStateEnum(Regul_zat10_21);
      formConsole.console.Items.Add('ПВУ = 2 тлф (удалить) ');
      DefTypeMessages();

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

  {$REGION 'Перейти на 2-й канал(г), Вас понял, выполняю(п)'}
  if (FEducationState = Regul_zat8_20) then
  begin
    //ПВУ IТЛФ
    if FStationR415.PVUSwitch <> Phone_1 then
        Inc(errors);

    if MainForm.lbl10.Caption = 'Главная' then
    begin
      //смотрим отправлено ли "Перейти на 2й канал"
      if TSM <> NEXT then
        Inc(errors);
      //пришло "вас понял, выполняю"
      if TGM <> OK then
        Inc(errors);
    end
    else
    begin
       //смотрим пришло ли "Перейти на 2й канал"
      if TGM <> NEXT then
        Inc(errors);
      //отправлено "вас понял, выполняю"
      if TSM <> OK then
        Inc(errors);
    end;

    if errors = 0 then
    begin
      FEducationState := T20ZadachaStateEnum(Regul_zat9_20);
      formConsole.console.Items.Add('Сообщения обработаны(удалить) ');
      DefTypeMessages();

      for I := 0 to FStationR415View.Switches.Count - 1 do
      begin
        if (I = 2)or(I = 1) then
          FStationR415View.Switches[I].changeProperties := true
        else
          FStationR415View.Switches[I].changeProperties := false;
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'доклад о готовности(п) отжатие кнопки ИГ(г)'}
  if (FEducationState =  Regul_zat7_20) then
  begin
    if MainForm.lbl10.Caption = 'Подчиненная' then
    begin
      //ПВУ IТЛФ
      if FStationR415.PVUSwitch <> Phone_1 then
        Inc(errors);
      //смотрим отправлено ли "Готово"
      if TSM <> OK then
        Inc(errors);

    end
    else
    begin
      //пришло ли подтверждение о выполнении
      if TGM <> OK then
        Inc(errors);
      //отпустил ли ИГ
//      if FStationR415.DownUpFirstSwitch <> down then
//        Inc(errors);
    end;

    if errors = 0 then
    begin
      FEducationState := T20ZadachaStateEnum(Regul_zat8_20);
      formConsole.console.Items.Add('1 канал ТЧ отрегулирован! ');
      DefTypeMessages();

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

  {$REGION 'регулировка КТЧ первого канала(п) и нажатие кнопки ИГ(г)'}
  if (FEducationState =  Regul_zat6_20) then
  begin
    if MainForm.lbl10.Caption = 'Подчиненная' then
    begin
      //дают ли генератор
      if GenerateState <> true then
        Inc(errors);
      //ПВУ выключить
      if FStationR415.PVUSwitch <> PVU_Off then
        Inc(errors);
      //индикация в ноль
      if FStationR415.Level1Switch < Indication_60 then
        Inc(errors);
    end
    else
    begin
      //нажата ли у него кнопка генератора
      if FStationR415.DownUpFirstSwitch <> up then
        Inc(errors);
    end;

    AnimationRegulOstatZatuh3();

    if errors = 0 then
    begin
      FEducationState := T20ZadachaStateEnum(Regul_zat7_20);
      formConsole.console.Items.Add('регулировка КТЧ первого канала(удалить)');
      DefTypeMessages();
    end;
  end;
  {$ENDREGION}

  {$REGION 'проверка приема сообщения о даче Главной станцией ИГ'}
  if(FEducationState = Regul_zat5_20) then
  begin
    if GetMsg <> true then
    begin
      Inc(errors);
    end;

    if errors = 0 then
    begin
      GetMsg := false;
      FEducationState := T20ZadachaStateEnum(Regul_zat6_20);
      formConsole.console.Items.Add('Даю генератор (удалить)');
      DefTypeMessages();

      for I := 0 to FStationR415View.Switches.Count - 1 do
      begin
        if (I = 2)or(I = 31)or(I = 21) then
          FStationR415View.Switches[I].changeProperties := true
        else
          FStationR415View.Switches[I].changeProperties := false;
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'доклад о готовности(г) отжатие кнопки ИГ(п)'}
  if (FEducationState =  Regul_zat4_20) then
  begin
    if MainForm.lbl10.Caption = 'Главная' then
    begin
      //ПВУ IТЛФ
      if FStationR415.PVUSwitch <> Phone_1 then
        Inc(errors);
      //смотрим отправлено ли "Готово"
      if TSM <> OK then
        Inc(errors);

    end
    else
    begin
      //пришло ли подтверждение о выполнении
      if TGM <> OK then
        Inc(errors);

//      //отпустил ли ИГ
//      if FStationR415.DownUpFirstSwitch <> down then
//        Inc(errors);
    end;

    if errors = 0 then
    begin
      FEducationState := T20ZadachaStateEnum(Regul_zat5_20);
      formConsole.console.Items.Add('1 канал ТЧ отрегулирован! ');
      DefTypeMessages();

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

  {$REGION 'регулировка КТЧ первого канала(г) и нажатие кнопки ИГ(п)'}
  if (FEducationState =  Regul_zat3_20) then
  begin
    if MainForm.lbl10.Caption = 'Главная' then
    begin
      //дают ли генератор
      if GenerateState <> true then
        Inc(errors);
      //ПВУ выключить
      if FStationR415.PVUSwitch <> PVU_Off then
        Inc(errors);
      //индикация в ноль
      if FStationR415.Level1Switch < Indication_60 then
        Inc(errors);
    end
    else
    begin
      //нажата ли у него кнопка генератора
      if FStationR415.DownUpFirstSwitch <> up then
        Inc(errors);
    end;

    AnimationRegulOstatZatuh3();

    if errors = 0 then
    begin
      FEducationState := T20ZadachaStateEnum(Regul_zat4_20);
      DefTypeMessages();
    end;
  end;
  {$ENDREGION}

  {$REGION 'проверка приема сообщения о начале регулировки и запросе генератора'}
  if(FEducationState = Regul_zat1_20) then
    begin
      if MainForm.lbl10.Caption = 'Главная' then
      begin
        //смотрим отправлено ли "Дайте генератор"
        if TSM <> GET_GENERATE then
          Inc(errors);
        //смотрим пришло ли "Вас понял. Даю гену"
        if TGM <> OK then
          Inc(errors);
      end
      else
      begin
        //пришло ли "Дайте генератор"
        if TGM <> GET_GENERATE then
          Inc(errors);
        //смотрим отправлено ли "Вас понял. Даю гену"
        if TSM <> OK then
          Inc(errors);
      end;

      if errors = 0 then
      begin
        GetMsg := false;
        FEducationState := T20ZadachaStateEnum(Regul_zat3_20);
        formConsole.console.Items.Add('Сообщение о запросе генератора принято ! ');
        DefTypeMessages();

        for I := 0 to FStationR415View.Switches.Count - 1 do
        begin
          if (I = 2)or(I = 31)or(I = 21) then
            FStationR415View.Switches[I].changeProperties := true
          else
            FStationR415View.Switches[I].changeProperties := false;
        end;
      end;

    end;
  {$ENDREGION}

  {$REGION 'проверка установки связи с корреспондентом'}
    if(FEducationState = Ust_sv_20) then
    begin
      if MainForm.lbl10.Caption = 'Главная' then
      begin
        //смотрим отправлено ли "Как меня слышите"
        if TSM <> HOW_VOICE then
          Inc(errors);
        //смотрим пришло ли "Слышу вас хорошо"
        if TGM <> VOICE_OK then
          Inc(errors);

      end
      else
      begin
        //пришло ли "Как меня слышите"
        if TGM <> HOW_VOICE then
          Inc(errors);
        //смотрим отправлено ли "Как меня слышите"
        if TSM <> VOICE_OK then
          Inc(errors);
      end;

      if errors = 0 then
      begin
        GetMsg := false;
        FEducationState := T20ZadachaStateEnum(Regul_zat1_20);
        formConsole.console.Items.Add('Установка связи с корреспондентом выполнена ! ');
        DefTypeMessages();
      end;
    end;
    {$ENDREGION}

  //----------------------------------------------------------------------------

  {$REGION 'проверка проверки работы'}
  if(FEducationState = Prov_rab_rab_20) then
  begin
    if(FStationR415.ControlReceptionBroadcastSwitch <> Work) then
    begin
      Inc(errors);
    end;

    AnimationProverkaRaboti();

    if errors = 0 then
    begin
      FEducationState := T20ZadachaStateEnum(Ust_sv_20);
      formConsole.console.Items.Add('Проверка работы станции выполнена! ');
      MainForm.btn2.Enabled := True;
      //сообщаем сопряженной станции что мы дошли до установик связи
      MainForm.TCPClient.setSvaz();

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

  {$REGION 'проверка работы передатчика'}
  if(FEducationState = Prov_rab_prd_20) then
  begin

    //переключатель ИНДИКАЦИЯ в положение ВЫХОД ПРД
    if(FStationR415.IndicationSwitch <> Indication_Broadcast) then
    begin
      Inc(errors);
    end;

    //переключатель РАБОТА-КОНТРОЛЬ в положение КОНТР ПРД
    if (FStationR415.ControlReceptionBroadcastSwitch <> Broadcast)then
    begin
      Inc(errors);
    end;

    AnimationProverkaRabotiPRD();

    if(errors = 0) then
    begin
      FEducationState := T20ZadachaStateEnum(Prov_rab_rab_20);
      formConsole.console.Items.Add('Передатчик проверен! ');

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

  {$REGION 'проверка работы приемника'}
  if(FEducationState = Prov_rab_prm_20) then
  begin
    //переключатель РАБОТА-КОНТР в положение КОНТР ПРМ
    if(FStationR415.ControlReceptionBroadcastSwitch <> Reception) then
    begin
      Inc(errors);
    end;

    //переключатель ДУПЛ-ДЕЖ ПРИЕМ в положение ДУПЛ
    if(FStationR415.DoubleReception <> enabled) then
    begin
      Inc(errors);
    end;

    //переключатель ИНДИКАЦИЯ в положение, при котором показания не менее 50 дБ
    if (FStationR415.IndicationSwitch <> Indication_60) then
    begin
      Inc(errors);
    end;

    AnimationProverkaRabotPRM();

    if(errors = 0) then
    begin
      FEducationState := T20ZadachaStateEnum(Prov_rab_prd_20);
      formConsole.console.Items.Add('Приемник проверен! ');

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

  {$REGION 'проверяем настройку станции'}
  if(FEducationState = Nastr_20) then
  begin
    //нажата ли кнопка настройки
    if (FStationR415.DownUp8Switch <> Up) then
    begin
      Inc(errors);
    end;

    if (errors = 0) then
    begin
      AnimationNastroika();
      FEducationState := T20ZadachaStateEnum(Prov_rab_prm_20);
      formConsole.console.Items.Add('Настройка станции выполнена! ');

      for I := 0 to FStationR415View.Switches.Count - 1 do
      begin
        if (I = 19)or(I = 20)or(I = 17) then
          FStationR415View.Switches[I].changeProperties := true
        else
          FStationR415View.Switches[I].changeProperties := false;
      end;

    end;
  end;
  {$ENDREGION}

  {$REGION 'проверяем включение питания станции'}
  if FEducationState = Vkl_pit_20 then
  begin
    //тумблер питания ВКЛ
    if(FStationR415.PowerSupplySecondSwitch <> Enabled) then
    begin
      Inc(errors);
    end;

    if(errors = 0) then
    begin
      AnimationVklucheniePitania();
      FEducationState := T20ZadachaStateEnum(Nastr_20);
      formConsole.console.Items.Add('Питание станции включено! ');

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

  {$REGION 'проверяем установку органов в исходное положение'}
  if FEducationState = Ust_org_v_ish_pol_20 then
  begin
    //тумблер СЕТЬ в положение ВЫКЛ;
    if ((FStationR415.PowerSupplyFirstSwitch = Enabled)or
      (FStationR415.PowerSupplySecondSwitch = Enabled)) then
    begin
      Inc(errors);
    end;

    //антенный фидер(эквивалент) подключить к разъему АНТЕННА.
    if (FStationR415.Antena = Disabled) then
    begin
      Inc(errors);
    end;

    //переключатель РАБОТА-КОНТРОЛЬ в положение РАБОТА
    if (FStationR415.ControlReceptionBroadcastSwitch <> Work) then
    begin
      Inc(errors);
    end;

    //переключатель ИНДИКАЦИЯ в положение ВХОД ПРИЕМ 60
    if (FStationR415.IndicationSwitch <> Indication_60) then
    begin
      Inc(errors);
    end;

    //тумблер ДЕЖ ПРИЕМ-ДУПЛ в положение ДЕЖ ПРИЕМ
    if (FStationR415.DoubleReception <> Disabled) then
    begin
      Inc(errors);
    end;

    //тумблер МОЩН в положение ПОНИЖ
    if (FStationR415.PowerLowNormal <> Enabled) then
    begin
      Inc(errors);
    end;

     //переключатель КОНТР УРОВНЯ в положение 1-ТЛФ ПРИЕМ
    if (FStationR415.ControlLevelSwitch <> Phone_1_Reception) then
    begin
      Inc(errors);
    end;

    //переключатель ПВУ в положение 1-ТЛФ
    if (FStationR415.PVUSwitch <> Phone_1) then
    begin
      Inc(errors);
    end;

    //переключатели КАН-РАБ-СОЕД.ЛИН.1ТЛФ и IIТЛФ в положение КАН
    if ((FStationR415.CallFirstSwitch <> Channel)
      or (FStationR415.CallSecondSwitch <> Channel)) then
    begin
      Inc(errors);
    end;

    //перекл. 2ПР ОК-ТРАНЗИТ-4ПР ОК I ТЛФ и IIТЛФ в положение 2ПР ОК
    if ((FStationR415.PhoneFirstSwitch <> Two_Channel_Terminal)
      or(FStationR415.PhoneSecondSwitch <> Two_Channel_Terminal)) then
    begin
      Inc(errors);
    end;

    //переключатель ВКЛ ПЕР обоих ТЛГ каналов в верхнее положение
    if ((FStationR415.EnabledBroadcastFirstSwitch <> Enabled)
      or(FStationR415.EnabledBroadcastSecondSwitch <> Enabled)) then
    begin
      Inc(errors);
    end;

    //проверяем волны передачи
    if ((FStationR415.BroadcastFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRD1))
      or (FStationR415.BroadcastSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRD2)) )
      or (FStationR415.BroadcastThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRD3)) then
    begin
      Inc(errors);
    end;

    //проверяем волны приема
    if ((FStationR415.ReceptionFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRM1))
      or (FStationR415.ReceptionSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRM2))
      or (FStationR415.ReceptionThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRM3))) then
    begin
      Inc(errors);
    end;

    if(errors  = 0) then
    begin
      FEducationState := T20ZadachaStateEnum(Vkl_pit_20);
      formConsole.console.Items.Add('Органы выставлены в исходное положение! ');

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

  {$REGION 'проверяем выполнение внешнего осмотра'}
    if FEducationState = Vn_osm_20 then
    begin
      //воткнута ли телефонная трубка
      if(FStationR415.Phone <> Enabled) then
      begin
        Inc(errors);
      end;

      if(errors = 0) then
      begin
        FEducationState := T20ZadachaStateEnum(Ust_org_v_ish_pol_20);
        formConsole.console.Items.Add('Внешний осмотр выполнен ! ');

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

{$REGION 'анимация регулировки ТЧ 2 канал '}

procedure TZadacha20.AnimationRegulOstatZatuh4;
  begin
    if((FEducationState = Regul_zat9_23) or (FEducationState = Regul_zat9_26)) then
    begin
      if GenerateState then
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
{$ENDREGION}

{$REGION 'анимация регулировки ТЧ 1 канал '}

  procedure TZadacha20.AnimationRegulOstatZatuh3();
  begin

    if((FEducationState = Regul_zat3_20) or (FEducationState = Regul_zat6_20)) then
    begin
      //---
      if GenerateState then
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
{$ENDREGION}

{$REGION 'анимация включения электропитания станции'}
  procedure TZadacha20.AnimationVklucheniePitania();
  begin
    if FEducationState = Vkl_pit_20 then
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
{$ENDREGION}

{$REGION 'анимация настройки станции'}
  procedure TZadacha20.AnimationNastroika();
  begin
    if(FEducationState = Nastr_20) then
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
        DelayForAnimations(2000);
        //выкл. контро анф. прд
        FStationR415View.Animations[7].StateToDefault();
        //выставляем частоту прд в соответствии с настройкой станции
        FStationR415View.LabelsPrdPrm[0].ChangeValue(FStationR415.PRD1);
        FStationR415View.LabelsPrdPrm[1].ChangeValue(FStationR415.PRD2);
        FStationR415View.LabelsPrdPrm[2].ChangeValue(FStationR415.PRD3);
        //вкл. контро анф. прм
        FStationR415View.Animations[8].OnLamp();
        DelayForAnimations(2000);
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
{$ENDREGION}

{$REGION 'анимация проверки работы станции ПРМ'}
  procedure TZadacha20.AnimationProverkaRabotPRM();
  begin
    if(FEducationState = Prov_rab_prm_20) then
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
{$ENDREGION}

{$REGION 'анимация проверки работы станции ПРД'}
  procedure TZadacha20.AnimationProverkaRabotiPRD();
  begin
    if(FEducationState = Prov_rab_prd_20) then
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
{$ENDREGION}

{$REGION 'анимация проверка работы станции РАБОТА'}
  procedure TZadacha20.AnimationProverkaRaboti();
  begin
    if(FEducationState = Prov_rab_rab_20) then
    begin
      if(FStationR415.ControlReceptionBroadcastSwitch = Work) then
      begin
        FStationR415View.Animations[9].OnLamp();
        FStationR415View.Animations[11].DisplayChange(TAnimationDisplayStateEnum(d_4));
      end;
    end;
  end;
{$ENDREGION}

  procedure TZadacha20.ResetErrors;
  var I:integer;
  begin
    for I := 0 to FStationR415View.Switches.Count - 1 do
    begin
        FStationR415View.Switches[I].Error := 0;
    end;
  end;

  function TZadacha20 .getErrors():integer;
  var I,N:integer;
  begin
    N := 0;
    for I := 0 to FStationR415View.Switches.Count - 1 do
    begin
          N:= N+ FStationR415View.Switches[I].Error;
    end;
    Exit(N);
  end;

//вынести в поток
{$REGION 'задержка по времени для анимации настройка станции'}
  procedure TZadacha20.DelayForAnimations(time: Integer);
  var
    h: THandle;
  begin
    Application.ProcessMessages;
    h:=CreateEvent(nil,true,false,'');
    WaitForSingleObject(h,time);
    CloseHandle(h);
  end;
{$ENDREGION}


end.
