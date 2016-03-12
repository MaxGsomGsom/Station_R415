unit uTreningR415DM;

interface
uses classes, SysUtils, Dialogs,Generics.Collections, uStationR415DM,uStationR415ViewDM,
  Windows, ExtCtrls,Forms,uAnimationDM, consoleForm, uSwitchDM;

type
  //����� ����� �������� ������
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
        //������ �� ����������� ����������
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
        //��������� ������� ���������
        property EducationState: TTreaningStateEnum
          read FEducationState write FEducationState;
        property Mark: double
          read FMark write FMark;
        //���������� ������� ������
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

  //�������� ������������
  constructor TTreaningR415.Create(StationR415: TStationR415;StationR415View: TStationR415View);
  var I:integer;
  begin
    //��������� ������ �� ������ �������
    FStationR415 := StationR415;
    FStationR415View := StationR415View;
    //������������� �� ������� ���������
    FStationR415.StateChangeEvent := onStationR415StateChange;
    FStationR415.Question := ShowQuestion;
    //�������������
    Texts := TList<string>.Create;

    //��������� ������ �������
    addToTextList();

    //�������� ������ ����� ��������(������� ������)
    EducationState := TTreaningStateEnum(Vn_osm_t);
    ShowMessage('�� ����� � ����� ����������. � ������� ������� ����� ������� �� �������. ����� ���������� ������ ����� ������ ������� "������" ��� �������� ������������ ����������. ��� ������ ��������� ������� ������� "Q".');
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

   //�������� ������������
  destructor TTreaningR415.Destroy;
  begin
    //����������� ������
    Texts.Free;
    //���������� ������
    inherited;

    FStationR415.PhoneButton := false;
    Self.WorkTrue := false;

  end;
//------------------------------------------------------------------------------
  //������������ ��������
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

  //�������� ���������� �������
  procedure TTreaningR415.CheckWork;
  var I:integer;
  begin
    errors :=0;

    {$REGION '����� �������'}
    if(FEducationState = Sdacha_kanalov_t) then
    begin
      if((FStationR415.PhoneButton = true)and(FOneShow = false)) then
      begin
        ShowMessage('�������������: "��� �����. �������� !"');
        FOneShow := true;
      end
      else
      begin
        //I��� - II��� = II��� �����
        if FStationR415.ControlLevelSwitch <> Phone_2_Reception then
          Inc(errors);
        //I��� = 4��.��
        if FStationR415.PhoneFirstSwitch  <> Terminal then
          Inc(errors);
        //II��� = 2��.��
        if FStationR415.PhoneSecondSwitch  <> Two_Channel_Terminal then
          Inc(errors);
        //��� = II���
        if FStationR415.PVUSwitch  <> Phone_2 then
          Inc(errors);
        //I��� �����-���-����.��� = ������
        if FStationR415.CallFirstSwitch  <> Call_Work then
          Inc(errors);
        //II��� �����-���-����.��� = �����
        if FStationR415.CallSecondSwitch  <> Channel then
          Inc(errors);

        if errors = 0 then
        begin
            formConsole.console.Items.Add('������ ����� � ������ ! ��������� ������� �������� !');

            if (ShowsQuestion <= 3)and(self.getErrors = 0) then
            begin
              ShowMessage('�������� ����. ����� ���������: ' + IntToStr(ShowsQuestion) + ' �������� ������: ' + IntToStr(self.getErrors));
              formConsole.console.Items.Add('�������� ����. ����� ���������:' + IntToStr(ShowsQuestion) + ' �������� ������: ' + IntToStr(self.getErrors));
              StationR415Form.StationR415.FinishTask := FTreaning;
            end
            else
            begin
              ShowMessage('�������� �� ���� ! ����� ���������: ' + IntToStr(ShowsQuestion) + ' �������� ������: ' + IntToStr(self.getErrors));
              formConsole.console.Items.Add('�������� �� ���� ! ����� ���������: ' + IntToStr(ShowsQuestion)  + ' �������� ������: ' + IntToStr(self.getErrors));
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

    {$REGION '����������� �����. ���������'}
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
          ShowMessage('�������������: "��� ����� !"');
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
          ShowMessage('�������������: "������ !"');
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
          ShowMessage('�������������: "��� ��������� !"');
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
          ShowMessage('�������������: "��� ����� !"');
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
            ShowMessage('�������������: "��� �����!"');
            FOneShow := true;
        end;

        if ((FOneShow = true)and (WorkTrue = true)) then
        begin
          ShowMessage('�������������: "������ !"');
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
        ShowMessage('�������������: "��� �����. ��� ���������."');
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

    {$REGION '��������� �����'}
    if(EducationState = Ust_sv_t) then
    begin
        ShowMessage('�������������: ����� ��� ������ !');
        EducationState := TTreaningStateEnum(Regul_zatuh1_t);
        formConsole.console.Items.Add('��������� ����� � ��������������� ��������� ! ');
        formConsole.console.Clear;
        ShowTextMessage(64,64);
        FOneShow := false;
    end;
    {$ENDREGION}

    {$REGION '�������� ������'}
    if(EducationState = Prov_rab2_t) then
    begin
      if(FStationR415.ControlReceptionBroadcastSwitch = Work) then
      begin
        ShowMessage('������� ��������� � ������ � ������.');
        EducationState := TTreaningStateEnum(Ust_sv_t);
        formConsole.console.Clear;
        formConsole.console.Items.Add('�������� ������ ������� ���������! ');
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

    {$REGION '�������� ������ ���'}
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

    {$REGION '�������� ������ ���'}
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

    {$REGION '�������� ���������'}
    if(EducationState = Nastr_t) then
    begin
      if(FStationR415View.Animations[5].LampState = LAMP_OFF) then
      begin
        EducationState := TTreaningStateEnum(Prov_rab_t);
        formConsole.console.Clear;
        formConsole.console.Items.Add('��������� ������� ���������! ');
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

    {$REGION '�������� ��������� �������'}
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
        formConsole.console.Items.Add('������� ������� ��������! ');
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

    {$REGION '�������� ��������� � �������� ���������'}
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

      //Texts[22] ���
      if ((FStationR415.BroadcastFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRD1))
        or (FStationR415.BroadcastSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRD2)) )
        or (FStationR415.BroadcastThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRD3)) then
      begin
        Inc(errors);
        FMark_ust_v_ish := FMark_ust_v_ish - 0.4;
      end;

      //���
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
        formConsole.console.Items.Add('������ ���������� � �������� ���������! ');
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

    {$REGION '������ ������'}
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
        formConsole.console.Items.Add('������� ������ �������� ! ');
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

  {$REGION '����� ��������� �� �����'}
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


      //Texts[22] ���
      if ((FStationR415.BroadcastFirstSwitch <> TReceptionBroadcastEnum(FStationR415.PRD1))
        or (FStationR415.BroadcastSecondSwitch <> TReceptionBroadcastEnum(FStationR415.PRD2)) )
        or (FStationR415.BroadcastThirdSwitch <> TReceptionBroadcastEnum(FStationR415.PRD3)) then
      begin
        formConsole.console.Items.Add(Texts[23]);
        Inc(ShowsQuestion);
      end;

      //���
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
        ShowMessage('��: "��� ����� !"');
    end;

    if(FEducationState = Sdacha_kanalov_t) then
    begin
        formConsole.console.Clear;
        ShowTextMessage(91,91);
        //I��� - II��� = II��� �����
        if FStationR415.ControlLevelSwitch <> Phone_2_Reception then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(92,92);
        end;

        //I��� = 4��.��
        if FStationR415.PhoneFirstSwitch  <> Terminal then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(93,93);
        end;

        //II��� = 2��.��
        if FStationR415.PhoneSecondSwitch  <> Two_Channel_Terminal then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(94,94);
        end;


        //��� = II���
        if FStationR415.PVUSwitch  <> Phone_2 then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(95,95);
        end;

        //I��� �����-���-����.��� = ������
        if FStationR415.CallFirstSwitch  <> Call_Work then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(96,96);
        end;

        //II��� �����-���-����.��� = �����
        if FStationR415.CallSecondSwitch  <> Channel then
        begin
          Inc(ShowsQuestion);
          ShowTextMessage(97,97);
        end;
    end;
  end;
  {$ENDREGION}

  {$REGION '��������'}
  //����������� ����������� ���������, ����� 6
  procedure TTreaningR415.RegulOstatZatuh6;
  begin

  end;


  //����������� ����������� ���������, ����� 5
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

  //�������� ����������� ���������, ����� 4
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

  //�������� ����������� ���������, ����� 3
  procedure TTreaningR415.RegulOstatZatuh3;
  begin

  end;

  //�������� � ����� ������ ����������� ���������, ����� 2
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

  //�������� ����������� ���������, ����� 1
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

  //�������� �������� ��������� ����� � ���������������
  procedure TTreaningR415.UstanovkaSviazi();
  begin
    if(EducationState = Ust_sv_t) then
    begin
      FStationR415.Level2Switch := Indication_20;
      FStationR415.Level1Switch := Indication_20;
    end;

  end;

  //�������� �������� ������ ������� ������
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

  //�������� �������� ������ ������� ���
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

  //�������� �������� ������ ������� ���
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

  //�������� ��������� �������
  procedure TTreaningR415.Nastroika;
  begin
    if(EducationState = Nastr_t) then
    begin
      if(FStationR415.DownUp8Switch = Up) then
      begin
        FOneShow := true;
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
      end;
    end;
  end;

  //�������� ��������� �������������� �������,
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
      end;
    end;
  end;

  //�������� ��������� ������� � �������� ���������
  procedure TTreaningR415.StateToDefaultOrgan();
  begin

  end;

  //�������� �������� ������� �������
  procedure TTreaningR415.VneshniiOsmotr();
  begin

  end;
  {$ENDREGION}

  {$REGION '��� �������'}
    //���������� � ������ "TList<string>" ������ ��� ������ ������������
  procedure TTreaningR415.addToTextList();
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
    Texts.Add('4.�������� ����������������� �������.'#13);               //38
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
    Texts.Add('3. ������� �������������� � ������� �� ������, ��������:"1460. �"'#13); //61
    Texts.Add('   1450. ��� ���� ������� ?" ��� ������ ��������������: "����� ���"'#13); //62
    Texts.Add('   ������!", ���������� ������. ( ����� - ������� ������)'#13);                  //63
    Texts.Add('5. �. ����������� ����������� ��������� ������� ��. 1-�� ������'#13);  //64
    Texts.Add('   �� ��������� "������� ��������".'#13);            //65
    Texts.Add('   ��: "1460 ��������� � ����������� �������. ����� ��������� ��'#13);//66            //65
    Texts.Add('     ������� ������"; '#13);//67
    Texts.Add('   -������������� ��� I���-II��� � ��������� ���� '#13);//68
    Texts.Add('   -�������������� ������� I��� ���������� ������� ������� � "0"'#13);//69
    Texts.Add('   -������������� ��� I���-II��� � ��������� I���.'#13);//70
    Texts.Add('   ��: "������. ��� ��� ���������."'#13);//71
    Texts.Add('   -�� ����� ��� ������ ������ �� � ���������� �� �� �������'#13);//72
    Texts.Add('     "������"(�������� ����� ������� ������� "��������")'#13);//73
    Texts.Add('   ��: "������� �� 2-� �����."'#13);//74
    Texts.Add('   -�� ����� ��� ������������� ��� I���-II���, �������������'#13);//75
    Texts.Add('     �������� ������ � ��������� II��� �����.'#13);//76
    Texts.Add('   ��: "����� ��������� �� 2-�� ������."'#13);//77
    Texts.Add('   -�������������� ������� II��� ���������� ������� ������� � "0"'#13);//78
    Texts.Add('   ��: "��� ����� !"'#13);//79
    Texts.Add('   -������������� ��� I���-II��� � ��������� II���.'#13);//80
    Texts.Add('�������� �������� �������, ������ ����� ����������  !'#13);//81
    Texts.Add('4. a. �������� ����������������� ���'#13);//82
    Texts.Add('   b. �������� ����������������� ���'#13);//83
    Texts.Add('  c. ������� � ��������� ������.'#13);//84
    Texts.Add('5. ��������� ����� � ���������������.'#13);//85
    Texts.Add('5. �. ��������. ���� ���������.'#13);//86
    Texts.Add('5. �. ������� �� ������ �����.'#13);//87
    Texts.Add('5. �. ����������� ����������� ��������� ������� ��. 2-�� ������'#13);  //88
    Texts.Add('5. �. ��������. ���� ���������.'#13);//89
    Texts.Add('6. ����� ������.'#13);//90
    Texts.Add('���������� ������������� ����� ���������� � ����. �����.:'#13);//91
    Texts.Add('   -I��� - II��� = II��� �����'#13);//92
    Texts.Add('   -I��� = 4��.��'#13);//93
    Texts.Add('   -II��� = 2��.��'#13);//94
    Texts.Add('   -��� = II���'#13);//95
    Texts.Add('   -I��� �����-���-����.��� = ������'#13);//96
    Texts.Add('   -II��� �����-���-����.��� = �����'#13);//97
  end;

  //�������� �� �������
  procedure TTreaningR415.Delay(time: Integer);
  var
    h: THandle;
  begin
    Application.ProcessMessages;
    h:=CreateEvent(nil,true,false,'');
    WaitForSingleObject(h,time);
    CloseHandle(h);
  end;

  //�������� ����� � �������
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
