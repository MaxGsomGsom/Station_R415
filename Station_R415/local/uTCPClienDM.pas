unit uTCPClienDM;

interface

uses
 IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,IdGlobal, uRequestDM,
 SysUtils, uResponseListenerDM,Dialogs,uKeyValueDM,uClientStateDM,Graphics;

type

  TTCPClientR415 = class
    private
      TCPClient: TIdTCPClient;
      ResponseListener: TResponseListener;
      FClientState: TClientState;

      FUstSvazi: Boolean;

    public
      property ClientState: TClientState read FClientState write FClientState;
      property UstSvazi: Boolean read FUstSvazi write FUstSvazi;

      constructor Create();
      function TryConnect(Name: string; HName: string; HPort: string): integer;
      function TryDisconnect():Integer;
      procedure OnResponse(strResponse: string);
      procedure ProcessMessage(strMessage: string);
      procedure SendTextMessage(txtMessage: string);
      procedure SendWaves(prd : integer;  prm: Integer);
      function  returnConnected():boolean;
      procedure setToDefaultMarkers();
      procedure setFinish(OnOff: integer);

      procedure setSvaz();
      procedure setGenerateActivation(OnOff: integer);


  end;

implementation
  uses
    main, uStationR415Form;

  constructor TTCPClientR415.Create;
  begin
    Inherited;
    TCPClient := TIdTCPClient.Create(nil);
    ClientState := TClientState.Create;
  end;

  //���������� ��������� � ��������� ������ ����������
  procedure TTCPClientR415.setFinish(OnOff: integer);
  var
    Request: TRequest;
  begin
    Request := TRequest.Create;                       // ������ ����� ������
    Request.Name := REQ_NAME_FINISH_ACT;
    Request.AddKeyValue(KEY_TYPE, 'r415');            // ��� �������
    if OnOff = 1 then
      Request.AddKeyValue(KEY_FINISH, 'on')
    else
      Request.AddKeyValue(KEY_FINISH, 'off');

    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;
  end;

  //���������� ��������� � ��������� ������ ����������
  procedure TTCPClientR415.setGenerateActivation(OnOff: integer);
  var
    Request: TRequest;
  begin
    Request := TRequest.Create;                       // ������ ����� ������
    Request.Name := REQ_NAME_GEN_ACT;
    Request.AddKeyValue(KEY_TYPE, 'r415');            // ��� �������
    if OnOff = 1 then
      Request.AddKeyValue(KEY_GENERATE, 'on')
    else
      Request.AddKeyValue(KEY_GENERATE, 'off');

    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;
  end;

  //�������� � ��� ��� ��� �������� �����
  procedure TTCPClientR415.setSvaz();
  var
    Request: TRequest;
  begin
    Request := TRequest.Create;                       // ������ ����� ������
    Request.Name := REQ_NAME_UST_SVAZI;
    Request.AddKeyValue(KEY_TYPE, 'r415');            // ��� �������
    Request.AddKeyValue(KEY_SVAZ_SET, 'on');
    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;
  end;

  procedure TTCPClientR415.setToDefaultMarkers();
  begin
    FUstSvazi := false;
  end;

  function TTCPClientR415.returnConnected;
  begin
    if TCPClient.Connected then
      Exit(True);

    Exit(False);

  end;

  function TTCPClientR415.TryDisconnect():integer;
  begin
    Result := 0;
    try
      TCPClient.Disconnect;
      ResponseListener.Free;
    except
      Exit(1);  //�� ����� �� ����� ����, �� �� ������)
    end;
  end;

  function TTCPClientR415.TryConnect(Name: string; HName: string; HPort: string):Integer;
  var
    Request: TRequest;
    strResponse: String;
  begin
    Result := 0;

    try
      TCPClient.Host := HName;
      TCPClient.Port := StrToInt(HPort);
      TCPClient.Connect;
      TCPClient.IOHandler.DefStringEncoding := TIdTextEncoding.UTF8;
    except
      Exit(1);                            // �� ������� ����������� � ��������
    end;

    Request := TRequest.Create;                       // ������ ����� ������
    Request.Name := REQ_NAME_REGISTRATION;
    Request.AddKeyValue(KEY_NAME, Name);              // �������� � ������ ���
                                                      // ������������
    Request.AddKeyValue(KEY_TYPE, 'r415');            // � ��� �������
    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;

    try
      strResponse := TCPClient.IOHandler.ReadLn();
    except
      strResponse := '';                              // ����� ����� ��� ������
    end;

    if strResponse = '' then
    begin
      TCPClient.Disconnect;                           // ���� �� ��������
      Exit(2);
    end;

    Request := TRequest.Create;
    Request.ConvertToKeyValueList(strResponse);       // ��������� ����� �������
                                                      // � ��������� ���
    if Request.Name <> REQ_NAME_OK  then
    begin                                             // ���� ���� �� ������ ���,
      TCPClient.Disconnect;                           // �� �������, ��� ��� ��
      Request.Free;                                   // ���������
      Exit(3);
    end;

    Request.Free;                                     // �� �������� ������ �����

    ResponseListener :=                               // ��������� ���������
      TResponseListener.Create(TCPClient);
    ResponseListener.ResponseEvent := OnResponse;     // ������������� �� �������
                                                      // "����� �������"

  end;

  /// <summary>
  ///   ������������ ������� '������ ����� �������'
  /// </summary>
  procedure TTCPClientR415.OnResponse(strResponse: string);
  begin
//    MainForm.mmo1.Lines.Add('�� �������: '+ strResponse);
    ProcessMessage(strResponse);
  end;

  /// <summary>
  ///  ������������ ���������, ���������� �� �������
  /// <param name = 'strMessage'> ���������� �� ������� ��������� </param>
  /// </summary>
  procedure TTCPClientR415.ProcessMessage(strMessage: string);
  var
    Request: TRequest;
    strValue: string;
    kvRecord: TKeyValue;
    i: Integer;
  begin
    Request := TRequest.Create;
    Request.ConvertToKeyValueList(strMessage);       // ������ ��������� �������

    if Request.Name = REQ_NAME_OK then begin    end else
    if Request.Name = REQ_NAME_ERROR then begin     end else
    if Request.Name = REQ_NAME_REGISTRATION then begin    end else

    if Request.Name = REQ_NAME_GEN_ACT then
    begin
      strValue := Request.GetValue(KEY_TYPE);

      if strValue = 'r415' then
      begin
        strValue := Request.GetValue(KEY_GENERATE);
        if strValue = 'on' then
        begin
          MainForm.ChangeGenerateState20zadacha(true);
        end
        else
          MainForm.ChangeGenerateState20zadacha(false);
      end;

    end
    else

    //��������� �� ����. ������� ������ � ��� ��� ����� �� ��������� �����
    if Request.Name = REQ_NAME_UST_SVAZI then
    begin
      strValue := Request.GetValue(KEY_TYPE);
      if strValue = 'r415' then
      begin
        strValue := Request.GetValue(KEY_SVAZ_SET);
        if strValue = 'on' then
        begin
          MainForm.edt4.Enabled := True;
        end;
      end;
    end
    else

    //��������� ����� �� ����������� �������
    if Request.Name = REQ_NAME_WAVES then
    begin
      strValue := Request.GetValue(KEY_TYPE);
      if strValue = 'r415' then
      begin
        strValue := Request.GetValue(KEY_TRANSMITTER_WAVE_A);
        MainForm.lbl12.Caption := strValue;
        strValue := Request.GetValue(KEY_RECEIVER_WAVE_A);
        MainForm.lbl14.Caption := strValue;
      end;
    end
    else

    //��������� ��������� ��������� �� ����������� �������
    if Request.Name = REQ_NAME_MESSAGE then
    begin
      strValue := Request.GetValue(KEY_TYPE);
      if strValue = 'r415' then
      begin
        strValue := Request.GetValue(KEY_TEXT);
        MainForm.mmo1.Lines.Add(MainForm.lbl8.Caption + ' (�415): ' + strValue);

        if StationR415Form.Zadacha20 <> nil then
        begin
          StationR415Form.Zadacha20.GetMessage(strValue);
        end;
      end;
    end
    else

    if Request.Name = REQ_NAME_PARAMS then            {TODO: ������� ���� � ������ ������� }
    begin
      strValue := Request.GetValue(KEY_TYPE);
      if strValue = 'server' then
      begin
        strValue := Request.GetValue(KEY_STATUS); // ������� � ������� ������������
                                                  // ������� ��� ����������
        if strValue = 'main' then
        begin
          ClientState.MainStation := true;
          MainForm.lbl10.Caption := '�������';
        end
        else
        begin
          ClientState.MainStation := false;
          MainForm.lbl10.Caption := '�����������';
        end;

      end else
      if strValue = 'r415' then
      begin
        for i := 0 to Request.GetCountKeys - 1 do
        try
          kvRecord := Request.GetKeyValue(i);
          if kvRecord.Key = KEY_NAME then             // ���� ��������� �������
          begin                                       // �������� ��� ���, ��
                                                      // ��� ����������� ��� ������������
            strValue := Request.GetValue(KEY_CONNECTED);

            if strToBool(strValue) then               // ���� connected = true
            begin
              ClientState.LinkedR415Connected := True;
              ClientState.LinkedR415UserName := kvRecord.Value;

              MainForm.lbl8.Caption := ClientState.LinkedR415UserName;
              MainForm.lbl5.Font.Color := clGreen;
              MainForm.lbl5.Caption := '������';

//              MainForm.N16.Visible := True;

            end
            else                                      // connected = false
            begin
//              ClientState.TransmitterWave := 0;
//              ClientState.ReceiverWave := 0;
//              ClientState.TaskID := ttNull;           // ��������, �.�., ��� ������ �������

              ClientState.LinkedR415Connected := False;
              ClientState.LinkedR415UserName := '';

              MainForm.lbl8.Caption := '��� ������';
              MainForm.lbl5.Font.Color := clRed;
              MainForm.lbl5.Caption := '�������';
              MainForm.lbl10.Caption := '��� ������';

//              MainForm.N16.Visible := false;
              MainForm.btn1.Enabled := true;

            end;
            break;
          end else
          if kvRecord.Key = KEY_TRANSMITTER_WAVE_A then
          begin
//            ClientState.TransmitterWave := StrToInt(kvRecord.Value);
          end else
          if kvRecord.Key = KEY_TRANSMITTER_WAVE_B then
          begin
//            ClientState.TransmitterWave := StrToInt(kvRecord.Value);
          end else
          if kvRecord.Key = KEY_RECEIVER_WAVE_A then
          begin
//            ClientState.ReceiverWave := StrToInt(kvRecord.Value);
          end else
          if kvRecord.Key = KEY_RECEIVER_WAVE_B then
          begin
//            ClientState.ReceiverWave := StrToInt(kvRecord.Value);
          end else
          if kvRecord.Key = KEY_TYPE then;      // ��� ������� ������ ������ ����,
                                                // ��� ������ ������
        except
          on E: Exception do;                   //��������, ��� ���� ������� �����
        end;                                    // (������ ����������� strValue);
      end;
    end else
    if Request.Name = REQ_NAME_MESSAGE then
    begin

    end;
    Request.Free;                                  // ������� �����
  end;

  /// <summary>
  ///  ���������� ��������� ��������� ����������� �������
  /// <param name = 'txtMessage'> ���������</param>
  /// </summary>

  procedure TTCPClientR415.SendTextMessage(txtMessage: string);
  var
    Request: TRequest;
    tempText : string;
  begin
    Request := TRequest.Create;                       // ������ ����� ������
    Request.Name := REQ_NAME_MESSAGE;
    Request.AddKeyValue(KEY_TYPE, 'r415');            // ��� �������
    tempText := MainForm.edt4.Text;
    Request.AddKeyValue(KEY_TEXT, tempText);            // ���� ���� � ��������
    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;
  end;


  /// <summary>
  ///  ���������� ���� ����� ����������� �������
  /// <param name = 'prd'> ������� �������� </param>
  /// <param name = 'prm'> ������� ������ </param>
  /// </summary>
  procedure TTCPClientR415.SendWaves(prd : integer;  prm: Integer);
  var
    Request: TRequest;
  begin
    Request := TRequest.Create;                         // ������ ����� ������
    Request.Name := REQ_NAME_WAVES;
    Request.AddKeyValue(KEY_TYPE, 'r415');              // ��� �������
    Request.AddKeyValue(KEY_TRANSMITTER_WAVE_A, IntToStr(prd));   //�������� �������
    Request.AddKeyValue(KEY_RECEIVER_WAVE_A, IntToStr(prm));
    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;
  end;

end.
