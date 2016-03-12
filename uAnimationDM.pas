unit uAnimationDM;

interface

uses
  Generics.Collections,
  ExtCtrls,SysUtils;

type
TAnimationsEnum = (NONE, LAMP, DISPLAY,LEVEL);
TAimationLampStateEnum = (LAMP_OFF,LAMP_ON);
TAnimationDisplayStateEnum = (d_0,d_1,d_2,d_3,d_4,d_5,d_6,d_7,d_8);

TAnimation = class
  private
    FImageListLamp: TList<TImage>;      //храним картинки для анимации лампочки
    FImageListDisplay: TList<TImage>;   //храним картинки для анимации индикатора
    FLinkedImage: TImage;               //сохраняем ссылку на нужную картинку
    FAnimationsType: TAnimationsEnum;   //сохраняем тип нашей анимации
    FDisplayState: TAnimationDisplayStateEnum; //состояние дисплея
    FLampState: TAimationLampStateEnum; //состояние лампочки

  public
    property LampState: TAimationLampStateEnum
          read FLampState write FLampState;

    constructor Create(LinkedImage: TImage;FileNameList: TList<System.string>;
                        AE: TAnimationsEnum);
    procedure LoadImages(FileNameList: TList<System.string>);

    procedure OnLamp();
    procedure StateToDefault();

    procedure DisplayChange(DS:TAnimationDisplayStateEnum);

end;

implementation

  constructor TAnimation.Create(LinkedImage: TImage; FileNameList: TList<System.string>;
    AE: TAnimationsEnum);
  begin
    FImageListLamp := TList<TImage>.Create;
    FImageListDisplay := TList<TImage>.Create;
    FLinkedImage := LinkedImage;
    FAnimationsType := AE;

    LoadImages(FileNameList);

    if(AE = LAMP) then
      FLinkedImage.Picture := FImageListLamp.Items[0].Picture;
    if(AE =DISPLAY) then
      FLinkedImage.Picture := FImageListDisplay.Items[0].Picture;

  end;

  //грузим картинки в память
  procedure TAnimation.LoadImages(FileNameList: TList<System.string>);
  var
    i: Integer;
    bufImage: TImage;
  begin
    for i := 0 to FileNameList.Count - 1 do
      begin
        bufImage := TImage.Create(nil);
        if(FAnimationsType = LAMP) then
        begin
          bufImage.Picture.LoadFromFile('data/images/switch/' + FileNameList.Items[i]);
          FImageListLamp.Add(bufImage);
        end;
        if(FAnimationsType = DISPLAY) then
        begin
          bufImage.Picture.LoadFromFile('data/images/switch/' + FileNameList.Items[i]);
          FImageListDisplay.Add(bufImage);
        end;
      end;
  end;

  //включаем лампочку
  procedure TAnimation.OnLamp();
  begin
    if(FAnimationsType = LAMP) then
    begin
      FLampState := LAMP_ON;
      FLinkedImage.Picture := FImageListLamp.Items[Integer(FLampState)].Picture;
    end;
  end;



  procedure TAnimation.DisplayChange(DS:TAnimationDisplayStateEnum);
  begin
    if(FAnimationsType = DISPLAY) then
    begin
      FDisplayState := DS;
      FLinkedImage.Picture := FImageListDisplay.Items[Integer(FDisplayState)].Picture;
    end;
  end;

  //выставляем все анимашки в исходное(выключенное) состояние
  procedure TAnimation.StateToDefault();
  begin
    if(FAnimationsType = LAMP) then
    begin
      FLampState := LAMP_OFF;
      FLinkedImage.Picture := FImageListLamp.Items[Integer(FLampState)].Picture;
    end;

    if(FAnimationsType = DISPLAY) then
    begin
      FDisplayState := d_0;
      FLinkedImage.Picture := FImageListDisplay.Items[Integer(FDisplayState)].Picture;
    end;

  end;
end.
