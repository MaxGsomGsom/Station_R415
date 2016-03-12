unit uConstantsDM;
{******************************************************************************
    Предполагается, что в этот модуль будут выноситься константы,
  использующиеся в проекте.

    Глобальные константы нужно переписать в виде ГЛОБАЛЬНАЯ_КОНСТАНТА
  ибо таково соглашение Делфи об объявлении констант.
*******************************************************************************}
interface


uses Messages;


  type TWorkMode = (wmFree, wmLearning, wmTraining, wmExam);// Режимы, в которых можно
                                                    // выполнять 20 задачу


type TTaskType = (
  ttNull=-1,
  ttNone,                               // Не выбрано
  //ttExternalView,                     // Внешний осмотр
  //ttStartParametersSetup,             // Начальная настройка
  ttPowerOn,                            // Включение питания
  //ttReceiveAndTransmitTracksSetup,    // Настройка приёмо-передающего тракта
  //ttWorkWithLowFrequency,             // Работа с низкочастотным оборудованием
  ttCheckStationInStandaloneControlMode,// Проверка станции в режиме автономного
                                        // контроля
  ttSetConnectionWithCross,             // Установка служебной связи с кроссом
  ttTransferToTerminalMode);            // Перевод станции в оконечный режим



  const COUNT_WORK_MODES = 4;
  // wmLearning - тексты заданий расписаны
  // wmTraining - тексты заданий можно открыть пару-тройку раз
  // wmExam - подсказок нет вообще

  wtFree = 0;                          // Устаревшие константы для режима работы
  wtLearn = 1;
  wtTrening = 2;
  wtExam = 3;

  //Константы пользовательских событий windows:
  const MM_SETTEXT = WM_USER + 100;        //Для отправки текста инфо-форме
  const MM_CLICK_BUTTON = WM_USER + 101;   //My Message "click on button"
                                           //Клик по "Завершить упражнение"
  const MM_RACK_WAS_CLOSED = WM_USER + 102;//Событие "Закрытие окна стойки"

  //Строковые константы
  const StationR414FormminiClassName = 'TStationR414MinForm';
  const StationR414FormminiObjectName = 'StationR414MinForm';

  //Прочие константы
  const useSounds = False;                //Использовать ли звуки в приложении
  const useBackground = True;            //Использовать ли фон
  const stMainMenuModern = True;
  const  Debug = True;                    //Включен режим отладки и тестирования
  //const Debug = False;

  //Упражнения
  const mdExternalView = 1;                 //Внешний осмотр
  const mdStartParametersSetup = 2;         //Начальная настройка
  const mdPowerOn = 3;                      //Включение питания
  const mdReceiveAndTransmitTracksSetup = 4;//Настройка приёмо-передающего тракта
  const mdWorkWithLowFrequency = 5;         //Работа с низкочастотным оборудованием
  const mdTransferToTerminalMode = 6;       //Перевод станции в оконечный режим

  //id блоков
  {$REGION 'ID блоков'}
  const idMshuA = 0;
  const idGeneratorA = 1;
  const idDuplexerA = 2;
  const idRack1500A = 3;
  const idRack1920A = 4;
  const idRack1600A = 5;
  const idWaveMeterA = 6;
  const idRack1200A1 = 7;
  const idRack1200A2 = 8;
  const idP321A = 9;
  const idRack1710A = 10;
  const idPultA = 11;
  const idPultB = 12;
  const idP321C = 13;
  const idOscillographC = 14;
  const idPowerC = 15;
  const idRack1400B = 16;
  const idRack1200B1 = 17;
  const idRack1200B2 = 18;
  const idP321B = 19;
  const idRack1600B = 20;
  const idWaveMeterB = 21;
  const idRack1920B = 22;
  const idRack1500B = 23;
  const idDuplexerB = 24;
  const idMshuB = 26;
  const idGeneratorB = 25;
  const idShield = 27;
  const idRack1500Aback = 28;
  const idRack1500Bback = 29;
  const idRack1600Aback = 30;
  const idRack1600Bback = 31;
  {$ENDREGION}

  const TotalRacksCount = 31;               // Общее количество стоек

  const NotSelected = 255;              // Используется, когда стойка не выделена
  const NotHint = 254;                  // Используется, когда отсутствует подсказка

  InitialTimeString = '00:00:00';

  stPassed: Byte = 0;                       // Отметки заданий (пройдено / не пройдено)
  stNotPassed: Byte = 1;

  MAX_WAVE_VALUE = 46;                  // Макс значение выставляемых волн
  MIN_WAVE_VALUE = 1;                   // Мин значение выставляемых волн
  MIN_WAVE_DIFFERENCE = 6;              // Минимальная разница между значениями

  COUNT_CHANNELS = 21;                  // Количество каналов на пульте

  stPluggedOff = 0;                     // Колодки не установлены
  stPluggedIn = 1;                      // Колодки стоят каждая в своём гнезде
  stPluggedInCross = 2;                 // Колодки стоят в перекрестии 2-х гнёзд

  stDisconnected = 2;                   //
  stCableGenConnected = 3;
  stCableInputYYConnected = 4;

  stChannelTuned = 5;                   // Канал настроен
  stChannelNotTuned = 6;                // Канал не настроен

  butMain = 0;                          // Позиции переключателей (ОСН./РЕЗ.)
  butReserve = 1;

  {$REGION 'Стрёмные константы'}
  smdMain = 1;
  smdRetr = 2;

  sRetrMain = 1;
  sRetrReserv = 2;

  sUpchMain = 1;
  sUpchReserve = 2;

  sDmchMain = 1;
  sDmchReserve = 2;
  {$ENDREGION}

  {$REGION 'Константы, показывающие куда подключен конец кабеля'}
  csDisconected = 0;
  csConnected = 1;

  csConnectedAtDuplexeLeft = 2;
  csConnectedAtDuplexeRight = 3;

  csConnectedAtSync = 5;
  csConnectedAtPower = 6;
  csConnectedAtPRD = 7;
  csConnectedAtPRM = 8;

  csConnectedTo1200A1PRM = 9;
  csConnectedTo1200A1Sync = 10;

  csConnectedTo1200B1PRM = 11;
  csConnectedTo1200B1Sync = 12;

  csConnectedTo1200A2PRD = 13;
  csConnectedTo1200A2PRM = 14;
  csConnectedTo1200A2Sync = 15;

  csConnectedTo1200B2PRD = 16;
  csConnectedTo1200B2PRM = 17;
  csConnectedTo1200B2Sync = 18;

  csConnectedAtPultPVU_PRD = 19;
  csConnectedAtPultPVU_PRM = 20;
  csConnectedAtPultHighOhmInput1 = 21;
  csConnectedAtPultHighOhmInput2 = 22;
  csConnectedAtPultHighOhmInput3 = 23;
  csConnectedAtPultHighOhmInput4 = 24;
  csConnectedAtPultHighOhmInput5 = 25;
  csConnectedAtPultHighOhmInput6 = 26;
  csConnectedAtPultHighOhmInput7 = 27;
  csConnectedAtPultHighOhmInput8 = 28;

  csConnectedAtRezerveLine1 = 29;
  csConnectedAtRezerveLine2 = 30;
  csConnectedAtRezerveLine3 = 31;
  csConnectedAtRezerveLine4 = 32;
  csConnectedAtRezerveLine5 = 33;
  csConnectedAtRezerveLine6 = 34;
  csConnectedAtRezerveLine7 = 35;
  csConnectedAtRezerveLine8 = 36;
  csConnectedAtRezerveLine9 = 37;
  csConnectedAtRezerveLine10 = 38;
  csConnectedAtRezerveLine11 = 39;
  csConnectedAtRezerveLine12 = 40;
  csConnectedAtRezerveLine13 = 41;
  csConnectedAtRezerveLine14 = 42;

  csConnectedAtVihUKSH_NP = 43;
  csConnectedAtVihUKSH_UD = 44;
  csConnectedAtVihUKSH_UD2 = 45;

  csConnectedAtChannelUD = 46;
  csConnectedAtChannelUD_2 = 47;
  csConnectedAtChannelUD_3 = 48;
  csConnectedAtChannelUD_4 = 49;
  csConnectedAt1ChannelUD_4PRM_PRD2 = 51;
  csConnectedAt1ChannelUD_4PRM_PRD = 50;

  csConnectedAtVihUKSH2_NP = 52;
  csConnectedAtVihUKSH2_UD = 53;
  csConnectedAtVihUKSH2_UD2 = 54;

  csConnectedAtChannelUD2 = 55;
  csConnectedAtChannelUD2_2 = 56;
  csConnectedAtChannelUD2_3 = 57;
  csConnectedAtChannelUD2_4 = 58;
  csConnectedAt1ChannelUD2_4PRM_PRD2 = 60;
  csConnectedAt1ChannelUD2_4PRM_PRD = 59;

  csConnectedAtMashTehObesp1 = 61;
  csConnectedAtMashTehObesp2 = 62;

  csConnectedAtRack1500NoName = 63;
  csConnectedAtRack1500Sh1 = 64;

  cb1500Nagruzka = 65;
  cb1500Sa37 = 66;
  {$ENDREGION}

  function GetWorkModeTitle(WorkMode: TWorkMode): string;


    const
    GeterodinWaves: array [MIN_WAVE_VALUE..MAX_WAVE_VALUE] of array [0..1] of integer = (
     (3, 7),
  (3, 75),
  (4, 43),
  (5, 8),
  (5, 72),
  (6, 39),
  (7, 3),
  (7, 66),
  (8, 28),
  (8, 90),
  (9, 52),
  (10, 13),
  (10, 72),
  (11, 31),
  (11, 89),
  (12, 47),
  (13, 04),
  (13, 61),
  (14, 17),
  (14, 72),
  (15, 27),
  (15, 81),
  (16, 35),
  (16, 88),
  (17, 40),
  (17, 92),
  (18, 44),
  (18, 95),
  (19, 45),
  (19, 94),
  (20, 43),
  (20, 92),
  (21, 40),
  (21, 88),
  (22, 35),
  (22, 82),
  (23, 28),
  (23, 74),
  (24, 19),
  (24, 64),
  (25, 09),
  (25, 53),
  (25, 96),
  (26, 39),
  (26, 82),
  (27, 25));

implementation

const
  WorkModeTitleLearning = 'Обучение';
  WorkModeTitleTraining = 'Тренировка';
  WorkModeTitleExam = 'Сдача';
  WorkModeTitleMode = 'Свободный режим';

/// <summary>
///   Возвращает название режима работы
/// </summary>
function GetWorkModeTitle(WorkMode: TWorkMode): string;
begin
  case WorkMode of
    wmLearning: Result := WorkModeTitleLearning;
    wmTraining: Result := WorkModeTitleTraining;
    wmExam: Result     := WorkModeTitleExam;
    wmFree: Result := WorkModeTitleMode;
  else
    Result := 'Неизвестный режим обучения';
  end;
end;

function GetWorkModeByID(ID: Integer): TWorkMode;
begin
  Result := TWorkMode(ID);
end;

end.
