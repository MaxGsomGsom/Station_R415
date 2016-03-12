unit uStationR415ViewDM;

interface

uses
  uSwitchDM,
  uAnimationDM,
  uLabelDM,
  Generics.Collections,
  Forms,
  Graphics,
  pngimage,
  ExtCtrls,
  StdCtrls;

type
  TStationR415View = class
    private
      FSwitches:      TList<TSwitch>;
      FAnimations :   TList<TAnimation>;
      FLabelsPrdPrm : TList<TLabelPrdPrm>;
    public
      property Animations: TList<TAnimation>
        read FAnimations write FAnimations;
      property LabelsPrdPrm: TList<TLabelPrdPrm>
        read FLabelsPrdPrm write FLabelsPrdPrm;
      property Switches: TList<TSwitch>
        read FSwitches write FSwitches;

      constructor Create;
      procedure AddSwitch(var imgObj: TImage; Angles: string;
        SwitchType: TSwitchTypeEnum; var ChangeEvent: TSwitchChangeStateEvent);
      procedure AddAnimation(LinkedImage: TImage; Angles: string; AE: TAnimationsEnum);
      procedure AddLabel(label1: TLabel; i:integer);
      procedure StateToDefaultAnimations();
  end;
implementation

  constructor TStationR415View.Create;
  begin
    FSwitches := TList<TSwitch>.Create;
    FAnimations := TList<TAnimation>.Create;
    FLabelsPrdPrm := TList<TLabelPrdPrm>.Create;
  end;

  procedure TStationR415View.AddLabel(label1: TLabel; i:integer);
  begin
    FLabelsPrdPrm.Add(TLabelPrdPrm.Create(label1,i));
  end;


  procedure TStationR415View.AddAnimation(LinkedImage: TImage; Angles: string;
    AE: TAnimationsEnum);
  var
    files: TList<string>;
    posObj: Integer;
    angle: string;
  begin
    files := TList<string>.Create;
    while Length(Angles) > 0 do
    begin
      posObj := Pos(',', Angles);

      if posObj <> 0 then
      begin
        angle := Copy(Angles, 0, posObj - 1);
        Delete(Angles, 1, posObj);
      end
      else
      begin
        angle := Angles;
        Angles := '';
      end;

      if AE = LAMP then
        angle := 'LAMP' + angle;
      if AE = DISPLAY then
        angle := 'DISPLAY' + angle;
      if AE = LEVEL then
        angle := 'level' + angle;

      files.Add(angle + '.png');
    end;

   FAnimations.Add(TAnimation.Create(LinkedImage,files,AE));


  end;

  procedure TStationR415View.AddSwitch(var imgObj: TImage; Angles: string;
    SwitchType: TSwitchTypeEnum; var ChangeEvent: TSwitchChangeStateEvent);
  var
    switchObj: TSwitch;
    files: TList<string>;
    posObj: Integer;
    angle, par: string;
  begin
    files := TList<string>.Create;
    while Length(Angles) > 0 do
    begin
      posObj := Pos(',', Angles);

      if posObj <> 0 then
      begin
        angle := Copy(Angles, 0, posObj - 1);
        Delete(Angles, 1, posObj);
      end
      else
      begin
        angle := Angles;
        Angles := '';
      end;

      if SwitchType = SwitchType_Switch then
      begin
        angle := 'Switch' + angle;
        par := '0';
      end
      else if SwitchType = SwitchType_EnabledDisabled then
      begin
        angle := 'EnabledDisabled' + angle;
        par := '0';
      end
      else if SwitchType = SwitchType_DownUp then
      begin
        angle := 'DownUp' + angle;
        par := 'DownUp';
      end
      else if SwitchType = SwitchType_Phone then
      begin
        angle := 'Phone' + angle;
        par := 'Phone';
      end
      else if SwitchType = SwitchType_Lamp then
      begin
        angle := 'Lamp' + angle;
        par := 'Lamp';
      end
      else if SwitchType = SwitchType_Level then
      begin
        angle := 'Level' + angle;
        par := 'Level';
      end
      else if SwitchType = SwitchType_Antena then
      begin
        angle := 'Antena' + angle;
        par := 'Antena';
      end;
      files.Add(angle + '.png');

    end;
    switchObj := TSwitch.Create(imgObj, files, SwitchType);
    switchObj.onSwitchChangeStateEvent := ChangeEvent;
    FSwitches.Add(switchObj);
  end;

  procedure TStationR415View.StateToDefaultAnimations();
  var
    i: integer;
  begin
    for i := 0 to FAnimations.Count-1 do
    begin
      FAnimations[i].StateToDefault();
    end;

    for i := 0 to FLabelsPrdPrm.Count-1 do
    begin
      FLabelsPrdPrm[i].hide;
    end;


    FSwitches[FSwitches.Count-1].ChangeDefault;
    FSwitches[FSwitches.Count-2].ChangeDefault;


  end;
end.
