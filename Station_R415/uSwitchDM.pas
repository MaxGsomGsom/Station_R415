unit uSwitchDM;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Controls,
  Forms,
  Dialogs,
  Generics.Collections,
  ExtCtrls,
  pngimage,
  Graphics;

type
  TSwitchChangeStateEvent = procedure(State: Integer) of object;

  TEducationTypeEnum = (ETNone,ETEducation, ETTreaning, ETnormativ);

   TSwitchTypeEnum = (SwitchType_EnabledDisabled, SwitchType_Switch,
     SwitchType_DownUp, SwitchType_Phone, SwitchType_Lamp, SwitchType_Level,
     SwitchType_Antena);

  TSwitch = class
    private
      FOnSwitchChangeStateEvent: TSwitchChangeStateEvent;
      FImageList: TList<TImage>;
      FName: string;
      FState: Integer;
      FLinkedImage: TImage;
      FChangeProperties : boolean;
      FError: integer;
      FEducationType :TEducationTypeEnum;
      procedure ChangeState;
      procedure ChangeImage;

    public


      constructor Create(LinkedImage: TImage; FileNameList: TList<string>;
        SwitchType: TSwitchTypeEnum);
      property Name: string read FName write FName;
      property State: Integer read FState write FState;
      property changeProperties : boolean read FchangeProperties  write FchangeProperties;
      procedure LoadImageFiles(FileNameList: TList<string>);
      procedure DoOnClick(Sender: TObject);
      procedure DoOnMouseDown(Sender: TObject;
        Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure DoOnMouseUp(Sender: TObject;
        Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

      procedure ChangeDefault();

      property onSwitchChangeStateEvent: TSwitchChangeStateEvent
        read FOnSwitchChangeStateEvent write FOnSwitchChangeStateEvent;
      property Error:integer read FError write FError;
      property EducationType:TEducationTypeEnum read FEducationType write FEducationType;


  end;

implementation

  /// <summary>
  /// Конструктор.
  /// </summary>
  /// <param name = "LinkedImage">
  /// Объект класса TImage для отображения картинок и их обновления.
  /// </param>
  /// <param name="FileNameList">Список имен файлов для загрузки.</param>
  /// <param name="SwitchType">Список имен файлов для загрузки.</param>
  /// <param name=".">
  ///</param>

  constructor TSwitch.Create(LinkedImage: TImage;
    FileNameList: TList<System.string>; SwitchType: TSwitchTypeEnum);
  begin
    changeProperties := true;

    FImageList := TList<TImage>.Create;
    FLinkedImage := LinkedImage;

    if(SwitchType = SwitchType_DownUp) then
    begin
      FLinkedImage.OnMouseDown := DoOnMouseDown;
      FLinkedImage.OnMouseUp := DoOnMouseUp;
    end
    else
    begin
      if(SwitchType <> SwitchType_Lamp) then
        FLinkedImage.OnClick := DoOnClick;
    end;

    LoadImageFiles(FileNameList);
    FState := 0;
    FError := 0;
    ChangeImage;

    FEducationType := ETNONE;
  end;

  procedure TSwitch.ChangeDefault;
  begin
    FState := 0;
    ChangeImage;
  end;

  /// <summary>
  /// Обработчик события "OnMouseUp".
  /// </summary>
  procedure TSwitch.DoOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
  begin
    if changeProperties then
    begin
      ChangeState;
      if Assigned(FOnSwitchChangeStateEvent) then
        FOnSwitchChangeStateEvent(FState);
    end
    else
    begin
      if FEducationType = ETEducation  then
        ShowMessage('Следуйте указаниям консоли.');
      if (FEducationType = ETTreaning)or(EducationType = ETnormativ)  then
      begin
        ShowMessage('Норматив не сдан. Вам следует пройти обучение еще раз.');
        self.Error := self.Error + 1;
      end;
    end;

  end;

  /// <summary>
  /// Обработчик события "OnMouseDown".
  /// </summary>
  procedure TSwitch.DoOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
  begin
    if changeProperties then
    begin
      ChangeState;
      if Assigned(FOnSwitchChangeStateEvent) then
        FOnSwitchChangeStateEvent(FState);
    end;

  end;

  /// <summary>
  /// Обработчик события "onClick".
  /// </summary>
  procedure TSwitch.DoOnClick(Sender: TObject);
  begin
    if changeProperties then
    begin
      ChangeState;
      if Assigned(FOnSwitchChangeStateEvent) then
        FOnSwitchChangeStateEvent(FState);
    end
    else
    begin
      if FEducationType = ETEducation  then
        ShowMessage('Следуйте указаниям консоли.');
      if (FEducationType = ETTreaning) or(EducationType = ETnormativ) then
      begin
        ShowMessage('Норматив не сдан. Вам следует пройти обучение еще раз.');
        self.Error := self.Error + 1;
      end;
    end;

  end;

  /// <summary>
  /// Производит изменениекартинки по состоянию объекта (переключателя).
  /// </summary>
  procedure TSwitch.ChangeImage;
  begin
    FLinkedImage.Picture := FImageList.Items[FState].Picture;
  end;

  /// <summary>
  /// Производит изменение состояния объекта (переключателя)
  /// </summary>
  procedure TSwitch.ChangeState;
  begin
    FState := FState + 1;
    if FState >= FImageList.Count then
    begin
      FState := 0;
    end;
    ChangeImage;
  end;


  /// <summary>
  /// Производит загрузкку файлов для каждого состояния
  /// </summary>
  /// <param name="FileNameList">Список имен файлов</param>
  procedure TSwitch.LoadImageFiles(FileNameList: TList<System.string>);
  var
    i: Integer;
    bufImage: TImage;
  begin
    for i := 0 to FileNameList.Count - 1 do
    begin
      bufImage := TImage.Create(nil);
      bufImage.Picture.LoadFromFile('data/images/switch/' + FileNameList.Items[i]);
      FImageList.Add(bufImage);
    end;
  end;
end.
