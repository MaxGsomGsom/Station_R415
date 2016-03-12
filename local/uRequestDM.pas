unit uRequestDM;

interface
uses
  uKeyValueDM,
  Generics.Collections;

const
  REQ_NAME_OK = 'ok';
  REQ_NAME_ERROR = 'error';
  REQ_NAME_REGISTRATION = 'registration';
  REQ_NAME_PARAMS = 'params';
  REQ_NAME_MESSAGE = 'message';   //передача текстовых сообщений
  REQ_NAME_WAVES = 'wave';        //передача волн станции

  REQ_NAME_UST_SVAZI = 'svaz';    //для сообщения о наличии связи
  REQ_NAME_GEN_ACT = 'gener';
  REQ_NAME_FINISH_ACT = 'finish';

  KEY_NAME = 'username';          // Позывной станции
  KEY_TYPE = 'type';              // Тип станции (cross/r414/r415/server)
  KEY_STATUS = 'status';          // Станция является подч-й или главной
  KEY_CONNECTED = 'connected';    // Статус подключения (true / false - при дисконнекте)
  KEY_TEXT = 'txt';
  KEY_SVAZ_SET = 'set';
  KEY_GENERATE = 'state';
  KEY_FINISH = 'finish';

  KEY_TRANSMITTER_WAVE_A = 'twavea';
  KEY_TRANSMITTER_WAVE_B = 'twaveb';
  KEY_RECEIVER_WAVE_A = 'rwavea';
  KEY_RECEIVER_WAVE_B = 'rwaveb';
  KEY_TASK_ID = 'taskid';

type
  TRequest = class
    private
      FKeyValueList: TList<TKeyValue>;
      FName: string;
    public
      property Name: string read FName write FName;
      function GetCountKeys: Integer;
      procedure AddKeyValue (Key: string; Value: string);
      property Count : Integer read GetCountKeys;
      function ConvertToText: string;
      function GetKeyValue(Index: Integer): TKeyValue;
      procedure ConvertToKeyValueList (Text: string);
      function GetValue(Key: string): string;
      constructor Create;

  end;
implementation

  /// <summary>
  /// Преобразует текстовое представление запроса в объектное. (парсер).
  /// </summary>
  /// <param name="Text">Тестовое представление запроса.</param>
  procedure TRequest.ConvertToKeyValueList(Text: string);
  var
    len: Integer;
    key: string;
  begin
    len := Pos(':', Text);
    if len > 0 then
    begin
      Name := Copy(Text, 1, len - 1);
      Delete(Text, 1, len);
      while True do
      begin
        if Length(Text) > 0 then
        begin
          len := Pos('=', Text);
          if len > 0 then
          begin
            key := Copy(Text, 1, len - 1);
            if Length(key) > 0 then
            begin
              Delete(Text, 1, len);
              len := Pos(',', Text);
              if len = 0 then
              begin
                AddKeyValue(key, Text);
                Break;
              end
              else
              begin
                AddKeyValue(key, Copy(Text, 1, len - 1));
                Delete(Text, 1, len);
                key := '';
                len := 0;
              end;
            end
            else
            begin
              Break;
            end;
          end;
        end
        else
        begin
          Break;
        end;
      end;
    end;
  end;

  /// <summary>
  /// Возвращает значение по ключу.
  /// </summary>
  /// <param name="Key">Имя ключа.</param>
  function TRequest.GetValue(Key: string): string;
  var
    i:Integer;
  begin
    for i := 0 to Count - 1 do
    begin
      if Key = GetKeyValue(i).Key then
        Exit(GetKeyValue(i).Value);
    end;
    Exit('');
  end;

  /// <summary>
  /// Возвращает количество ключей.
  /// </summary>
  function TRequest.GetCountKeys: Integer;
  begin
    Exit(FKeyValueList.Count);
  end;

  /// <summary>
  /// Возвращает обеъкт класса TKeyValue по индексу в списке.
  /// </summary>
  function TRequest.GetKeyValue(Index: Integer): TKeyValue;
  begin
    if (Index >= 0) and (Index < Count) then
    begin
      Exit(FKeyValueList.Items[Index]);
    end
    else
      Exit(nil);
  end;

  /// <summary>
  /// Преобразует объектное представление запроса в строку.
  /// </summary>
  /// <returns>Текстовое представление запроса.</returns>
  function TRequest.ConvertToText;
  var
    i: Integer;
    strResult: string;
  begin
    if Length(Name) > 0 then
    begin
      strResult := Name + ':';
      for i := 0 to Count - 1 do
      begin
        if i >= 1 then
        begin
          strResult := strResult + ',';
        end;
        strResult := strResult + FKeyValueList.Items[i].Key + '='
          + FKeyValueList.Items[i].Value;
      end;
      Exit(strResult);
    end;

  end;

  /// <summary>
  /// Конструктор класса.
  /// </summary>
  constructor TRequest.Create;
  begin
    FKeyValueList := TList<TKeyValue>.Create;
  end;

  /// <summary>
  /// Добавляет новую запись ключ=значение в список.
  /// </summary>
  /// <param name="Key">Ключ.</param>
  /// <param name="Value">Значение.</param>
  procedure TRequest.AddKeyValue(Key: string; Value: string);
  var
    bKeyValue : TKeyValue;
  begin
    bKeyValue := TKeyValue.Create;
    bKeyValue.Key := Key;
    bKeyValue.Value:= Value;
    FKeyValueList.Add(bKeyValue);
  end;

end.
