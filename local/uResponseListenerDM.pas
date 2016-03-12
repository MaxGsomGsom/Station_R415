unit uResponseListenerDM;

interface

uses
  Classes,
  SysUtils,
  IdTCPClient;

type
  TResponseEvent = procedure(strResponse: String) of object; // Ивент "Пришёл
                                                             // ответ сервера"

type
  TResponseListener = class(TThread)
  private
    TCPClient: TIdTCPClient;
    FResponseEvent: TResponseEvent;             // Ссылка на делегированную
                                                // функцию подписанного на событие
                                                // объекта
    FResponse: string;
    procedure DoResponseEvent;
    procedure Execute; override;

  public
    constructor Create(TCPClient: TIdTCPClient); reintroduce;
    destructor Destroy; override;
    property ResponseEvent: TResponseEvent read FResponseEvent
                                            write FResponseEvent;
end;

implementation

uses
  IdExceptionCore;

constructor TResponseListener.Create(TCPClient: TIdTCPClient);
begin
  Inherited Create(True);                   // Не запускать поток после создания
  Self.TCPClient := TCPClient;
  Self.Priority := tpLower;                 // Так было в примере
  Self.Resume;
  //Self.Start;                               // Запустить поток
end;

destructor TResponseListener.Destroy;
begin
  Self.Terminate;
  Inherited;
end;

/// <summary>
///   Прослушивает сокет для получения ответа сервера
///   и инициирует соответствующее событие
/// </summary>
procedure TResponseListener.Execute;
var
  strResponse: String;
begin
  while not Terminated do
    if (TCPClient <> nil) and TCPClient.Connected then
    begin
      try
        strResponse := TCPClient.Socket.ReadLn;  // Поток подвисает, пока на
                                                 // сокет не придёт строка
        if (strResponse <> '') then
        begin
          FResponse := strResponse;              // Сохраняем последний ответ
          Synchronize(DoResponseEvent);          // Вызываем в родительском потоке
        end;
      except
        on E: EidNotConnected do;                // TCPClient отконнектился
                                                 // от сервера, ничего не делаем
      end;
    end;
end;

/// <summary>
///   Вызывается в родительском потоке и генерирует событие
/// </summary>
procedure TResponseListener.DoResponseEvent;
begin
  ResponseEvent(FResponse);            // Оповещаем подписчика,
                                       // что пришёл ответ сервера
end;
end.
