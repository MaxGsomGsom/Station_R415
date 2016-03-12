unit navigForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, pngimage,uStationR415Form, jpeg;

type
  TnavigationForm = class(TForm)
    background: TImage;
    border: TImage;

    procedure borderMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure borderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure borderMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
      mouseDown : Boolean;
      dH: byte;

  public
    procedure PaintBorder(X:Integer;Y:integer);
    { Public declarations }
  end;

var
  navigationForm: TnavigationForm;


implementation

{$R *.dfm}

procedure TnavigationForm.PaintBorder(X:Integer;Y:integer);
begin
    border.Repaint;
    Self.Canvas.Pen.Width := 2;
    Self.Canvas.Pen.Color := clRed;
    Self.Canvas.MoveTo(0,Y);
    Self.Canvas.LineTo(Self.ClientWidth-5,Y);
    Self.Canvas.LineTo(Self.ClientWidth-5,Y + Round(StationR415Form.ClientHeight/(StationR415Form.VertScrollBar.Range/self.ClientHeight)));
    Self.Canvas.LineTo(0,Y + Round(StationR415Form.ClientHeight/(StationR415Form.VertScrollBar.Range/self.ClientHeight)));
    Self.Canvas.LineTo(0,Y);
    StationR415Form.VertScrollBar.Position := Round(Y *   StationR415Form.VertScrollBar.Range/self.ClientHeight) ;

end;

procedure TnavigationForm.borderMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mouseDown := True;
  PaintBorder(X,Y);
end;

procedure TnavigationForm.borderMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if mouseDown = true then
  begin
    PaintBorder(X,Y);
  end;
end;

procedure TnavigationForm.borderMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mouseDown := false;
end;

procedure TnavigationForm.FormCreate(Sender: TObject);
begin
  dH := 20;
end;

end.
