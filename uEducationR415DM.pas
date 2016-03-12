unit uEducationR415DM;

interface

uses classes, SysUtils, Dialogs,Generics.Collections, uStationR415DM,uStationR415ViewDM,
  Windows, ExtCtrls,Forms,uAnimationDM, consoleForm, uSwitchDM;

type
  //����� ����� �������� ������
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
        //��������� ������� ���������
        property EducationState: TEducationStateEnum
          read FEducationState write FEducationState;
        //���������� ������� ������
        constructor Create(StationR415: TStationR415;StationR415View: TStationR415View);
        destructor Destroy; override;

        procedure onStationR415StateChange();
        procedure addToTextList();

    end;

implementation
  uses uStationR415Form;

  //�������� ������������
  constructor TEducationR415.Create(StationR415: TStationR415;StationR415View: TStationR415View);
  var I :integer;
  begin
    //��������� ������ �� ������ �������
    FStationR415 := StationR415;
    FStationR415View := StationR415View;
    //������������� �� ������� ���������
    FStationR415.StateChangeEvent := onStationR415StateChange;
    //�������������
    Texts := TList<string>.Create;

    //��������� ������ �������
    addToTextList();

    //�������� ������ ����� ��������(������� ������)
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

   //�������� ������������
  destructor TEducationR415.Destroy;
  begin
    //����������� ������
    Texts.Free;
    //���������� ������
    inherited;

    FStationR415.PhoneButton := false;

  end;
//------------------------------------------------------------------------------
  //����� ������� ��������� ������� �� uStationR415DM.pas
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

  //����� ������
  procedure TEducationR415.SdachaKanalov;
  var I:integer;
  begin
    if(FEducationState = Sdacha_kanalov) then
    begin
      if((FStationR415.PhoneButton = true)and(FOneShow = false)) then
      begin
        ShowMessage('�������������: "��� �����. �������� !"');
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
          //I��� - II��� = II��� �����
          if FStationR415.ControlLevelSwitch <> Phone_2_Reception then
          begin
            Inc(errors);
            ShowTextMessage(84,84);
          end;

          //I��� = 4��.��.
          if FStationR415.PhoneFirstSwitch  <> Terminal then
          begin
            Inc(errors);
            ShowTextMessage(85,85);
          end;

          //II��� = 2��.��.
          if FStationR415.PhoneSecondSwitch  <> Two_Channel_Terminal then
          begin
            Inc(errors);
            ShowTextMessage(86,86);
          end;


          //��� = II���.
          if FStationR415.PVUSwitch  <> Phone_2 then
          begin
            Inc(errors);
            ShowTextMessage(87,87);
          end;

          //I��� �����-���-����.��� = ������.
          if FStationR415.CallFirstSwitch  <> Call_Work then
          begin
            Inc(errors);
            ShowTextMessage(88,88);
          end;

          //II��� �����-���-����.��� = �����.
          if FStationR415.CallSecondSwitch  <> Channel then
          begin
            Inc(errors);
            ShowTextMessage(89,89);
          end;

          if errors = 0 then
          begin
            formConsole.console.Clear;
            ShowMessage('�������� �������� �������. ������ ������� � ����������.');
            formConsole.console.Items.Add('�������� ����. ������ ���������� � ��������� �����.');

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

  //����������� ����������� ���������, ����� 6
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

  //����������� ����������� ���������, ����� 5
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
          ShowMessage('�������������: "��� ����� !"');
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
          ShowMessage('�������������: "������ !"');
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

  //����������� ����������� ���������, ����� 4
  procedure TEducationR415.RegulOstatZatuh4;
  var I:integer;
  begin
    if(FEducationState = Regul_zatuh4) then
    begin
      if((FStationR415.PhoneButton = true)and (FOneShow = false)) then
      begin
          ShowMessage('�������������: "��� ��������� !"');
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

  //����������� ����������� ���������, ����� 3
  procedure TEducationR415.RegulOstatZatuh3;
  var I:integer;
  begin
    if(FEducationState = Regul_zatuh3) then
    begin
      if((FStationR415.PhoneButton = true)and (FOneShow = false)) then
      begin
          ShowMessage('�������������: "��� ����� !"');
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


  //����������� ����������� ���������, ����� 2
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
            ShowMessage('�������������: "��� �����!"');
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
          ShowMessage('�������������: "������ !"');
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

  //����������� ����������� ���������, ����� 1
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
        ShowMessage('�������������: "��� �����. ��� ���������."');
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

  //��������� �������� ��������� ����� �������
  procedure TEducationR415.UstanovkaSviazi();
  begin
    if(EducationState = Ust_sv) then
    begin
      if(FStationR415.PhoneButton = true) then
      begin
        ShowMessage('�������������: ����� ��� ������ !');
        EducationState := TEducationStateEnum(Regul_zatuh1);
        ShowMessage('����������� ����������� ��������� ������� ��.');
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

  //��������� �������� ������ ������� ������
  procedure TEducationR415.ProverkaRaboti();
  var I:integer;
  begin
    if(EducationState = Prov_rab2) then
    begin
      if(FStationR415.ControlReceptionBroadcastSwitch = Work) then
      begin
        FStationR415View.Animations[9].OnLamp();
        FStationR415View.Animations[11].DisplayChange(TAnimationDisplayStateEnum(d_4));
        ShowMessage('������� ��������� � ������ � ������.');
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

  //��������� �������� ������ ������� ���
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

  //��������� �������� ������ ������� ���
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

  //��������� ��������� �������
  procedure TEducationR415.Nastroika;
  var I:integer;
  begin
    if(EducationState = Nastr) then
      if(FStationR415.DownUp8Switch = Up) then
      begin
        Application.ProcessMessages;
        ShowMessage('�������� ! ���������� ��������� �������. �������� ��� ��������� � ��������� ��������� ���������!');
        //���. ������ ���. ���
        FStationR415View.Animations[7].OnLamp();
        //��� = ���
        FStationR415View.LabelsPrdPrm[0].ChangeValue(FStationR415View.LabelsPrdPrm[3].value);
        FStationR415View.LabelsPrdPrm[1].ChangeValue(FStationR415View.LabelsPrdPrm[4].value);
        FStationR415View.LabelsPrdPrm[2].ChangeValue(FStationR415View.LabelsPrdPrm[5].value);
        Delay(2000);
        //����. ������ ���. ���
        FStationR415View.Animations[7].StateToDefault();
        //���������� ������� ��� � ������������ � ���������� �������
        FStationR415View.LabelsPrdPrm[0].ChangeValue(FStationR415.PRD1);
        FStationR415View.LabelsPrdPrm[1].ChangeValue(FStationR415.PRD2);
        FStationR415View.LabelsPrdPrm[2].ChangeValue(FStationR415.PRD3);
        //���. ������ ���. ���
        FStationR415View.Animations[8].OnLamp();
        Delay(2000);
        //���. ������ ���. ���
        FStationR415View.Animations[8].StateToDefault();
        //���������� ������� ��� � ������������ � ���������� �������
        FStationR415View.LabelsPrdPrm[3].ChangeValue(FStationR415.PRM1);
        FStationR415View.LabelsPrdPrm[4].ChangeValue(FStationR415.PRM2);
        FStationR415View.LabelsPrdPrm[5].ChangeValue(FStationR415.PRM3);
        //��������� ������������� ��� ���
        FStationR415View.Animations[5].StateToDefault();

        ShowMessage('��������� ������� ��������� �������.');

        formConsole.console.Items.Clear;
        EducationState := TEducationStateEnum(Prov_rab);
        formConsole.console.Items.Add('��������� ������� ���������!');
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

  //��������� ��������� �������������� �������,
  procedure TEducationR415.VklucheniePitania();
  var I:integer;
  begin
    if EducationState = Vkl_pit then
    begin
      errors :=0;
      formConsole.console.Clear;
      //�������� +27�
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
      //��������� ��� ������������
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
        formConsole.console.Items.Add('������� ������� ��������!');
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

  //��������� ��������� ������� � �������� ���������
  procedure TEducationR415.StateToDefaultOrgan();
  var I:integer;
  begin
    if EducationState = Ust_org_v_ish_pol then
    begin
      errors := 0;
      formConsole.console.Clear;
      //Texts[7]-������� ���� � ��������� ����
      if ((FStationR415.PowerSupplyFirstSwitch = Enabled)or
        (FStationR415.PowerSupplySecondSwitch = Enabled)) then
      begin
        formConsole.console.Items.Add(Texts[7]);
        Inc(errors);
      end;

      //Texts[8]-�������� �����(����������) ���������� � ������� �������.

      if (FStationR415.Antena = Disabled) then
      begin
        formConsole.console.Items.Add(Texts[8]);
        Inc(errors);
      end;

      //Texts[11]-������������� ������-�������� � ��������� ������.
      if (FStationR415.ControlReceptionBroadcastSwitch <> Work) then
      begin
        formConsole.console.Items.Add(Texts[11]);
        Inc(errors);
      end;

      //Texts[12]-������������� ��������� � ��������� ���� ����� 60.
      if (FStationR415.IndicationSwitch <> Indication_60) then
      begin
        formConsole.console.Items.Add(Texts[12]);
        Inc(errors);
      end;


      //Texts[13]-������� ��� �����-���� � ��������� ��� �����.
      if (FStationR415.DoubleReception <> Disabled) then
      begin
        formConsole.console.Items.Add(Texts[13]);
        Inc(errors);
      end;


      //Texts[14]-������� ���� � ��������� �����.
      if (FStationR415.PowerLowNormal <> Enabled) then
      begin
        formConsole.console.Items.Add(Texts[14]);
        Inc(errors);
      end;


      //Texts[16]-������������� ����� ������ � ��������� 1-��� �����.
      if (FStationR415.ControlLevelSwitch <> Phone_1_Reception) then
      begin
        formConsole.console.Items.Add(Texts[16]);
        Inc(errors);
      end;


      //Texts[17]-������������� ��� � ��������� 1-���.
      if (FStationR415.PVUSwitch <> Phone_1) then
      begin
        formConsole.console.Items.Add(Texts[17]);
        Inc(errors);
      end;


      //Texts[18]-������������� ���-���-����.���.1��� � II��� � ��������� ���.
      if ((FStationR415.CallFirstSwitch <> Channel)
        or (FStationR415.CallSecondSwitch <> Channel)) then
      begin
        formConsole.console.Items.Add(Texts[18]);
        Inc(errors);
      end;


      //Texts[19]-������. 2�� ��-�������-4�� �� I ��� � II��� � ��������� 2�� ��.
      if ((FStationR415.PhoneFirstSwitch <> Two_Channel_Terminal)
        or(FStationR415.PhoneSecondSwitch <> Two_Channel_Terminal)) then
      begin
        formConsole.console.Items.Add(Texts[19]);
        Inc(errors);
      end;


      //Texts[20]-������������� ��� ��� ����� ��� ������� � ������� ���������.
      if ((FStationR415.EnabledBroadcastFirstSwitch <> Enabled)
        or(FStationR415.EnabledBroadcastSecondSwitch <> Enabled)) then
      begin
        formConsole.console.Items.Add(Texts[20]);
        Inc(errors);
      end;


      //Texts[22] ���.
      if ((FStationR415.BroadcastFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRD1))
        or (FStationR415.BroadcastSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRD2)) )
        or (FStationR415.BroadcastThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRD3)) then
      begin
        formConsole.console.Items.Add(Texts[23]);
        Inc(errors);
      end;

      //���.
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
        formConsole.console.Items.Add('������ ���������� � �������� ���������!');
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

  //��������� �������� ������� �������.
  procedure TEducationR415.VneshniiOsmotr();
  var I: integer;
  begin
    if EducationState = Vn_osm then
    begin
      errors := 0;
      formConsole.console.Clear;
      //��������� �� ���
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
        formConsole.console.Items.Add('������� ������ �������� !');
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

    //���������� � ������ "TList<string>" ������ ��� ������ ������������
  procedure TEducationR415.addToTextList();
  begin
    Texts.Add('1. ������� ������ '#13);                                             //0
    Texts.Add('   -��������� ���������� ��������� ������ � ������;'#13);            //1
    Texts.Add('   -��������� ���������� ����������� ���������� �������;'#13);       //2
    Texts.Add('   -��������� � ���������� ������� ������������ �����������,'#13);   //3
    Texts.Add('     � ������� ����� ��������������, � ����������� �������'#13);     //4
    Texts.Add('     ��������������� ������ (��) � ����������� �� ������ ���.   [�17]'#13);  //5

    Texts.Add('2. ���������� ������ ���������� � �������� ���������'#13);           //6
    Texts.Add('   -������� ���� � ��������� ����;'#13);                             //7
    Texts.Add('   -�������� �����(����������) ���������� � ������� �������.   [1�03]'#13);    //8
    Texts.Add(' ����������� �������� ������� ������� ��� ��������.'#13);                      //9
    Texts.Add('�� ����� �������� � ����������(���):'#13);                                     //10
    Texts.Add('   -������������� ������-�������� � ��������� ������;   [�01-1]'#13);          //11
    Texts.Add('   -������������� ��������� � ��������� ���� ����� 60;   [�01-1]'#13);         //12
    Texts.Add('   -������� ��� �����-���� � ��������� ��� �����;   [�01-1]'#13);              //13
    Texts.Add('   -������� ���� � ��������� �����.   [�01-1]'#13);                            //14
    Texts.Add('�� ����� ���������� �������(���):'#13);                                        //15
    Texts.Add('   -������������� ����� ������ � ��������� 1-��� �����;   [�-17]'#13);         //16
    Texts.Add('   -������������� ��� � ��������� 1-���;   [�-17]'#13);                        //17
    Texts.Add('   -������������� ���-���-����.���.1��� � II��� � ��������� ���;   [�-17]'#13);     //18
    Texts.Add('   -������. 2�� ��-�������-4�� �� I ��� � II��� � ��������� 2�� ��;   [�-17]'#13);  //19
    Texts.Add('   -������������� ��� ��� ����� ��� ������� � ������� ���������.   [�-17]'#13);     //20
    Texts.Add('�� ����������� ������(��):'#13);                                           //21
    Texts.Add('   -���������� ���. ������� � ������� �������������� ���./���.'#13);       //22
    Texts.Add('   -���������� ������� �������� ' + IntToStr(FStationR415.PRD1) + IntToStr(FStationR415.PRD2)+IntToStr(FStationR415.PRD3)+';   [�02]');//23
    Texts.Add('   -���������� ������� ������ '+ IntToStr(FStationR415.PRM1) + IntToStr(FStationR415.PRM2)+IntToStr(FStationR415.PRM3) + ' ;   [�02]'); //24

    Texts.Add('3.��������� �������������� �������:'#13);                                //25
    Texts.Add('   -������� ����(+27B) ���������� � ��������� ���;'#13);                 //26
    Texts.Add('4.��������� �������:'#13);                                               //27
    Texts.Add('   -������ �� ����������� ������(��) ������ ���������;   [�02]'#13);             //28
    Texts.Add('��� ��������� �������� ��������� �������� ����. "����� ��� �����"'#13);  //29
    Texts.Add('��������� ����������� �������� ��������� � ����������� �����������'#13); //30
    Texts.Add('�����. �� ��������� �������������� ��������� ��������� ���������'#13);   //31
    Texts.Add('"������ ��� �����" �� �� ������, ��������� ����������� ��������'#13);    //32
    Texts.Add('����������������� � ������������ � ����������� ��������������'#13);      //33
    Texts.Add('�������� I,II,III, ����� ���� ���������� �������������� ���������'#13);  //34
    Texts.Add('�����������, � ��� ������������� ��������� ������ ��� ��������.'#13);    //35
    Texts.Add('����� ���������� ����� ��� ������, ��� ��������������� �� ���������'#13);//36
    Texts.Add('��������� ���.'#13);                                                     //37
    Texts.Add('4.�������� ����������������� �������. �������������:'#13);               //38
    Texts.Add('   -������������� ������-����� � ��������� ����� ���;   [�01-1]'#13);              //39
    Texts.Add('   -������������� ����-��� ����� � ��������� ����;   [�01-1]'#13);                 //40
    Texts.Add('   -������������� ��������� � ���������, ��� ������� ���������   [�01-1]'#13);     //41
    Texts.Add('�� ����� 50 ��;'#13);                                                    //42
    Texts.Add('   ����������:'#13);                                                     //43
    Texts.Add('��� ����������� ��������� ������ ������������ � ������ ����� ���'#13);   //44
    Texts.Add(' �������� ��������� ��������.'#13);                                      //45
    Texts.Add('   -������������� ������-�������� � ��������� ����� ���;   [�01-1]'#13);            //46
    Texts.Add('   -������������� ��������� � ��������� ����� ���;   [�01-1]'#13);                  //47
    Texts.Add('   -������������� ���� � ��������� �����;   [�01-1]'#13);                           //48
    Texts.Add('   ����������'#13);                                                       //49
    Texts.Add('��������� ����������� ����������� ������ ������������ � ����� ���'#13);   //50
    Texts.Add(' �������� �������� ���������� ��������, � ��� �� ���������� ��������'#13);  //51
    Texts.Add(' ����������� ����� ��� ��� � ������.'#13);                                  //52
    Texts.Add('   -������������� ������-����� � ��������� ������   [�01-1]'#13);                      //53
    Texts.Add('������������ ������ ������ ���������� �� ����� -2 ��'#13);                   //54

    Texts.Add('��� ������������ ����� � ��������������� ����������:'#13);              //55
    Texts.Add('1. ��������� ��������� ������� ���������� �� ������: �����������'#13);  //56
    Texts.Add('   ������ � ����� ����������. ������ ���������� ��������� ������'#13);  //57
    Texts.Add('   ������ ���������� � ����������, ��������� � I �������.'#13);         //58
    Texts.Add('2. ��� ������� ������� ������ �� �������������� ��������� ���'#13);     //59
    Texts.Add('   � �������� ��������������� ������.'#13);                             //60
    Texts.Add('3. ������� �������������� � ������� �� ������, ��������:"1460. �'#13); //61
    Texts.Add('   1450. ��� ���� ������� ?" ��� ������ ��������������: "����� ���"'#13); //62
    Texts.Add('   ������!", ���������� ������. ( ����� - ������� ������)'#13);                  //63
    Texts.Add('����������� ����������� ��������� ������� ��.'#13);  //64
    Texts.Add('   �� ��������� "������� ��������".'#13);            //65
    Texts.Add('   ��: "1460 ��������� � ����������� �������. ����� ��������� ��'#13);//66            //65
    Texts.Add('     ������� ������"; '#13);//67
    Texts.Add('   -������������� ��� I���-II��� � ��������� ���� '#13);//68
    Texts.Add('   -�������������� ������� I��� ���������� ������� ������� � "0"'#13);//69
    Texts.Add('   -������������� ��� I���-II��� � ��������� I���.'#13);//70
    Texts.Add('   ��: "������. ��� ��� ���������."'#13);//71
    Texts.Add('   -�� ����� ��� ������ ������ �� � ���������� �� �� �������'#13);//72
    Texts.Add('     "������"'#13);//73
    Texts.Add('   ��: "������� �� 2-� �����."'#13);//74
    Texts.Add('   -�� ����� ���. I���-II��� = II���, �������������'#13);//75
    Texts.Add('     �������� ������ � ��������� II��� �����.'#13);//76
    Texts.Add('   ��: "����� ��������� �� 2-�� ������."'#13);//77
    Texts.Add('   -�������������� ������� II��� ���������� ������� ������� � "0"'#13);//78
    Texts.Add('   ��: "��� ����� !"'#13);//79
    Texts.Add('   -������������� ��� I���-II��� � ��������� II���.'#13);//80
    Texts.Add('   ��: "����� 1-� ����� �� ����� 1810 � ������ 4��.��,'#13);//81
    Texts.Add('     ������ ����� �������� ��� �������� �����"'#13);//82
    Texts.Add('���������� ������������� ����� ���������� � ����. �����.:'#13);//83
    Texts.Add('   -I��� - II��� = II��� �����'#13);//84
    Texts.Add('   -I��� = 4��.��'#13);//85
    Texts.Add('   -II��� = 2��.��'#13);//86
    Texts.Add('   -��� = II���'#13);//87
    Texts.Add('   -I��� �����-���-����.��� = ������'#13);//88
    Texts.Add('   -II��� �����-���-����.��� = �����'#13);//89
  end;

  //�������� �� �������
  procedure TEducationR415.Delay(time: Integer);
  var
    h: THandle;
  begin
    Application.ProcessMessages;
    h:=CreateEvent(nil,true,false,'');
    WaitForSingleObject(h,time);
    CloseHandle(h);
  end;

  //�������� ����� � �������
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
