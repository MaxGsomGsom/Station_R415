unit uClientStateDM;

interface

uses
  uConstantsDM;

type TClientState = class

  private
    FConnected: Boolean;
    FLinkedR415Connected: Boolean;
    FR415Connected: Boolean;
    FCrossConnected: Boolean;

    FUserName : string;
    FLinkedR415UserName: string;

    FMainStation: Boolean;

    FWorkMode: TWorkMode;
    FTaskID: TTaskType;

    FTransmitterWave: Integer;
    FReceiverWave: Integer;

  public
    constructor Create(); reintroduce;



    property MainStation: Boolean  write FMainStation;

    property Connected: Boolean read FConnected
                                write FConnected;

    property LinkedR415Connected: Boolean read FLinkedR415Connected
                                          write FLinkedR415Connected;
    property R415Connected: Boolean read FR415Connected
                                    write FR415Connected;
    property CrossConnected: Boolean  read FCrossConnected
                                      write FCrossConnected;
    property UserName: string read FUserName
                              write FUserName;
    property LinkedR415UserName: string read FLinkedR415UserName
                                        write FLinkedR415UserName;

    property WorkMode: TWorkMode  read FWorkMode
                                  write FWorkMode;


end;


implementation

uses
  SysUtils;

  constructor TClientState.Create;
  begin
    //TaskID := ttPowerOn;
  end;



end.

