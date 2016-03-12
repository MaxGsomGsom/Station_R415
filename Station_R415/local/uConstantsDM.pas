unit uConstantsDM;
{******************************************************************************
    ��������������, ��� � ���� ������ ����� ���������� ���������,
  �������������� � �������.

    ���������� ��������� ����� ���������� � ���� ����������_���������
  ��� ������ ���������� ����� �� ���������� ��������.
*******************************************************************************}
interface


uses Messages;


  type TWorkMode = (wmFree, wmLearning, wmTraining, wmExam);// ������, � ������� �����
                                                    // ��������� 20 ������


type TTaskType = (
  ttNull=-1,
  ttNone,                               // �� �������
  //ttExternalView,                     // ������� ������
  //ttStartParametersSetup,             // ��������� ���������
  ttPowerOn,                            // ��������� �������
  //ttReceiveAndTransmitTracksSetup,    // ��������� �����-����������� ������
  //ttWorkWithLowFrequency,             // ������ � �������������� �������������
  ttCheckStationInStandaloneControlMode,// �������� ������� � ������ �����������
                                        // ��������
  ttSetConnectionWithCross,             // ��������� ��������� ����� � �������
  ttTransferToTerminalMode);            // ������� ������� � ��������� �����



  const COUNT_WORK_MODES = 4;
  // wmLearning - ������ ������� ���������
  // wmTraining - ������ ������� ����� ������� ����-������ ���
  // wmExam - ��������� ��� ������

  wtFree = 0;                          // ���������� ��������� ��� ������ ������
  wtLearn = 1;
  wtTrening = 2;
  wtExam = 3;

  //��������� ���������������� ������� windows:
  const MM_SETTEXT = WM_USER + 100;        //��� �������� ������ ����-�����
  const MM_CLICK_BUTTON = WM_USER + 101;   //My Message "click on button"
                                           //���� �� "��������� ����������"
  const MM_RACK_WAS_CLOSED = WM_USER + 102;//������� "�������� ���� ������"

  //��������� ���������
  const StationR414FormminiClassName = 'TStationR414MinForm';
  const StationR414FormminiObjectName = 'StationR414MinForm';

  //������ ���������
  const useSounds = False;                //������������ �� ����� � ����������
  const useBackground = True;            //������������ �� ���
  const stMainMenuModern = True;
  const  Debug = True;                    //������� ����� ������� � ������������
  //const Debug = False;

  //����������
  const mdExternalView = 1;                 //������� ������
  const mdStartParametersSetup = 2;         //��������� ���������
  const mdPowerOn = 3;                      //��������� �������
  const mdReceiveAndTransmitTracksSetup = 4;//��������� �����-����������� ������
  const mdWorkWithLowFrequency = 5;         //������ � �������������� �������������
  const mdTransferToTerminalMode = 6;       //������� ������� � ��������� �����

  //id ������
  {$REGION 'ID ������'}
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

  const TotalRacksCount = 31;               // ����� ���������� �����

  const NotSelected = 255;              // ������������, ����� ������ �� ��������
  const NotHint = 254;                  // ������������, ����� ����������� ���������

  InitialTimeString = '00:00:00';

  stPassed: Byte = 0;                       // ������� ������� (�������� / �� ��������)
  stNotPassed: Byte = 1;

  MAX_WAVE_VALUE = 46;                  // ���� �������� ������������ ����
  MIN_WAVE_VALUE = 1;                   // ��� �������� ������������ ����
  MIN_WAVE_DIFFERENCE = 6;              // ����������� ������� ����� ����������

  COUNT_CHANNELS = 21;                  // ���������� ������� �� ������

  stPluggedOff = 0;                     // ������� �� �����������
  stPluggedIn = 1;                      // ������� ����� ������ � ���� ������
  stPluggedInCross = 2;                 // ������� ����� � ����������� 2-� ����

  stDisconnected = 2;                   //
  stCableGenConnected = 3;
  stCableInputYYConnected = 4;

  stChannelTuned = 5;                   // ����� ��������
  stChannelNotTuned = 6;                // ����� �� ��������

  butMain = 0;                          // ������� �������������� (���./���.)
  butReserve = 1;

  {$REGION '������� ���������'}
  smdMain = 1;
  smdRetr = 2;

  sRetrMain = 1;
  sRetrReserv = 2;

  sUpchMain = 1;
  sUpchReserve = 2;

  sDmchMain = 1;
  sDmchReserve = 2;
  {$ENDREGION}

  {$REGION '���������, ������������ ���� ��������� ����� ������'}
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
  WorkModeTitleLearning = '��������';
  WorkModeTitleTraining = '����������';
  WorkModeTitleExam = '�����';
  WorkModeTitleMode = '��������� �����';

/// <summary>
///   ���������� �������� ������ ������
/// </summary>
function GetWorkModeTitle(WorkMode: TWorkMode): string;
begin
  case WorkMode of
    wmLearning: Result := WorkModeTitleLearning;
    wmTraining: Result := WorkModeTitleTraining;
    wmExam: Result     := WorkModeTitleExam;
    wmFree: Result := WorkModeTitleMode;
  else
    Result := '����������� ����� ��������';
  end;
end;

function GetWorkModeByID(ID: Integer): TWorkMode;
begin
  Result := TWorkMode(ID);
end;

end.
