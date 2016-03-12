unit uLabelDM;

interface
 uses
  SysUtils,
  StdCtrls,
  Windows;

type

TLabelPrdPrm = class
  private
    visible : bool;
    Flabel1:TLabel;
  public
    value, randvalue:integer;
    constructor Create(label1: TLabel; i:integer);
    procedure ChangeValue(i:integer);
    procedure show();
    procedure hide();
    procedure returnValue();
end;

implementation

constructor TLabelPrdPrm.Create(label1: TLabel; i: Integer);
begin
  visible := false;
  Flabel1 := label1;
  value := i;
  ChangeValue(value);
  hide();
end;

procedure TLabelPrdPrm.show();
begin
  Flabel1.Visible := true;
  visible := true;
end;

procedure TLabelPrdPrm.hide();
begin
  Flabel1.Visible := false;
  visible := false;

end;

procedure TLabelPrdPrm.ChangeValue(i:integer);
begin
  value := i;
  Flabel1.Caption := IntToStr(value);
end;

procedure TLabelPrdPrm.returnValue();
begin

end;

end.
