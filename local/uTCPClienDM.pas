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

  //отправляет сообщение о положении кнопки генератора
  procedure TTCPClientR415.setFinish(OnOff: integer);
  var
    Request: TRequest;
  begin
    Request := TRequest.Create;                       // Создаём новый запрос
    Request.Name := REQ_NAME_FINISH_ACT;
    Request.AddKeyValue(KEY_TYPE, 'r415');            // тип клиента
    if OnOff = 1 then
      Request.AddKeyValue(KEY_FINISH, 'on')
    else
      Request.AddKeyValue(KEY_FINISH, 'off');

    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;
  end;

  //отправляет сообщение о положении кнопки генератора
  procedure TTCPClientR415.setGenerateActivation(OnOff: integer);
  var
    Request: TRequest;
  begin
    Request := TRequest.Create;                       // Создаём новый запрос
    Request.Name := REQ_NAME_GEN_ACT;
    Request.AddKeyValue(KEY_TYPE, 'r415');            // тип клиента
    if OnOff = 1 then
      Request.AddKeyValue(KEY_GENERATE, 'on')
    else
      Request.AddKeyValue(KEY_GENERATE, 'off');

    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;
  end;

  //сообщаем о том что нам доступна связь
  procedure TTCPClientR415.setSvaz();
  var
    Request: TRequest;
  begin
    Request := TRequest.Create;                       // Создаём новый запрос
    Request.Name := REQ_NAME_UST_SVAZI;
    Request.AddKeyValue(KEY_TYPE, 'r415');            // тип клиента
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
      Exit(1);  //хз может ли такое быть, но на всякий)
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
      Exit(1);                            // Не удалось соединиться с сервером
    end;

    Request := TRequest.Create;                       // Создаём новый запрос
    Request.Name := REQ_NAME_REGISTRATION;
    Request.AddKeyValue(KEY_NAME, Name);              // Включаем в запрос имя
                                                      // пользователя
    Request.AddKeyValue(KEY_TYPE, 'r415');            // и тип клиента
    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;

    try
      strResponse := TCPClient.IOHandler.ReadLn();
    except
      strResponse := '';                              // Когда долго нет ответа
    end;

    if strResponse = '' then
    begin
      TCPClient.Disconnect;                           // Серв не отвечает
      Exit(2);
    end;

    Request := TRequest.Create;
    Request.ConvertToKeyValueList(strResponse);       // Переводим ответ сервера
                                                      // в объектный вид
    if Request.Name <> REQ_NAME_OK  then
    begin                                             // Если серв не принял имя,
      TCPClient.Disconnect;                           // то считаем, что оно не
      Request.Free;                                   // уникально
      Exit(3);
    end;

    Request.Free;                                     // Не забываем убрать мусор

    ResponseListener :=                               // Запускаем слушателя
      TResponseListener.Create(TCPClient);
    ResponseListener.ResponseEvent := OnResponse;     // Подписываемся на событие
                                                      // "Ответ сервера"

  end;

  /// <summary>
  ///   Обрабатывает событие 'Пришёл ответ сервера'
  /// </summary>
  procedure TTCPClientR415.OnResponse(strResponse: string);
  begin
//    MainForm.mmo1.Lines.Add('От сервера: '+ strResponse);
    ProcessMessage(strResponse);
  end;

  /// <summary>
  ///  Обрабатывает сообщение, полученное от сервера
  /// <param name = 'strMessage'> Полученное от сервера сообщение </param>
  /// </summary>
  procedure TTCPClientR415.ProcessMessage(strMessage: string);
  var
    Request: TRequest;
    strValue: string;
    kvRecord: TKeyValue;
    i: Integer;
  begin
    Request := TRequest.Create;
    Request.ConvertToKeyValueList(strMessage);       // Парсим сообщение сервера

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

    //принимаем от сопр. станции сигнал о том что дошли до установки связи
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

    //принимаем волны от сопряженной станции
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

    //принимаем текстовое сообщение от сопряженной станции
    if Request.Name = REQ_NAME_MESSAGE then
    begin
      strValue := Request.GetValue(KEY_TYPE);
      if strValue = 'r415' then
      begin
        strValue := Request.GetValue(KEY_TEXT);
        MainForm.mmo1.Lines.Add(MainForm.lbl8.Caption + ' (Р415): ' + strValue);

        if StationR415Form.Zadacha20 <> nil then
        begin
          StationR415Form.Zadacha20.GetMessage(strValue);
        end;
      end;
    end
    else

    if Request.Name = REQ_NAME_PARAMS then            {TODO: вынести тело в инлайн функцию }
    begin
      strValue := Request.GetValue(KEY_TYPE);
      if strValue = 'server' then
      begin
        strValue := Request.GetValue(KEY_STATUS); // Станция у данного пользователя
                                                  // главная или подчинённая
        if strValue = 'main' then
        begin
          ClientState.MainStation := true;
          MainForm.lbl10.Caption := 'Главная';
        end
        else
        begin
          ClientState.MainStation := false;
          MainForm.lbl10.Caption := 'Подчиненная';
        end;

      end else
      if strValue = 'r415' then
      begin
        for i := 0 to Request.GetCountKeys - 1 do
        try
          kvRecord := Request.GetKeyValue(i);
          if kvRecord.Key = KEY_NAME then             // Если связанная станция
          begin                                       // прислала своё имя, то
                                                      // она отключилась или подключилась
            strValue := Request.GetValue(KEY_CONNECTED);

            if strToBool(strValue) then               // Если connected = true
            begin
              ClientState.LinkedR415Connected := True;
              ClientState.LinkedR415UserName := kvRecord.Value;

              MainForm.lbl8.Caption := ClientState.LinkedR415UserName;
              MainForm.lbl5.Font.Color := clGreen;
              MainForm.lbl5.Caption := 'Онлайн';

//              MainForm.N16.Visible := True;

            end
            else                                      // connected = false
            begin
//              ClientState.TransmitterWave := 0;
//              ClientState.ReceiverWave := 0;
//              ClientState.TaskID := ttNull;           // Заглушка, х.з., что сейчас ставить

              ClientState.LinkedR415Connected := False;
              ClientState.LinkedR415UserName := '';

              MainForm.lbl8.Caption := 'Нет данных';
              MainForm.lbl5.Font.Color := clRed;
              MainForm.lbl5.Caption := 'Оффлайн';
              MainForm.lbl10.Caption := 'Нет данных';

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
          if kvRecord.Key = KEY_TYPE then;      // эта строчка просто пример того,
                                                // как писать дальше
        except
          on E: Exception do;                   //Залогать, что серв прислал херню
        end;                                    // (Ошибка конвертации strValue);
      end;
    end else
    if Request.Name = REQ_NAME_MESSAGE then
    begin

    end;
    Request.Free;                                  // Убираем мусор
  end;

  /// <summary>
  ///  Отправляем текстовое сообщение сопряженной станции
  /// <param name = 'txtMessage'> Сообщение</param>
  /// </summary>

  procedure TTCPClientR415.SendTextMessage(txtMessage: string);
  var
    Request: TRequest;
    tempText : string;
  begin
    Request := TRequest.Create;                       // Создаём новый запрос
    Request.Name := REQ_NAME_MESSAGE;
    Request.AddKeyValue(KEY_TYPE, 'r415');            // Тип клиента
    tempText := MainForm.edt4.Text;
    Request.AddKeyValue(KEY_TEXT, tempText);            // Наши ключ и значение
    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;
  end;


  /// <summary>
  ///  Отправляем наши волни сопряженной станции
  /// <param name = 'prd'> Частота передачи </param>
  /// <param name = 'prm'> Частота приема </param>
  /// </summary>
  procedure TTCPClientR415.SendWaves(prd : integer;  prm: Integer);
  var
    Request: TRequest;
  begin
    Request := TRequest.Create;                         // Создаём новый запрос
    Request.Name := REQ_NAME_WAVES;
    Request.AddKeyValue(KEY_TYPE, 'r415');              // Тип клиента
    Request.AddKeyValue(KEY_TRANSMITTER_WAVE_A, IntToStr(prd));   //передаем частоты
    Request.AddKeyValue(KEY_RECEIVER_WAVE_A, IntToStr(prm));
    TCPClient.IOHandler.WriteLn(Request.ConvertToText);
    Request.Free;
  end;

end.
