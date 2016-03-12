unit consoleForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TformConsole = class(TForm)
    console: TListBox;
    lbl1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ShowStartMessage();
  end;

var
  formConsole: TformConsole;

implementation

{$R *.dfm}

procedure TformConsole.FormCreate(Sender: TObject);
begin
  ShowStartMessage();
end;

procedure TformConsole.ShowStartMessage();
begin
    Self.console.Clear;
    Self.console.Items.Add('����� ���������� !!!');
    Self.console.Items.Add('�� ����� � �������� ������������� �������� �-415.');
    Self.console.Items.Add('');
    Self.console.Items.Add('��� ������ ���������� ������ ��������, �� ������� �� ������. �������');
    Self.console.Items.Add(' ���-����, �������, ��� ��������� ������ ��������� � ����� ��');
    Self.console.Items.Add(' ������� ������.');
    Self.console.Items.Add('');
    Self.console.Items.Add('�������� �� ������ "����� ������", ����������� � ������� ����, � ������� � ��������');
    Self.console.Items.Add(' �������� ���, ������� ����� ���.');
    Self.console.Items.Add('');
    Self.console.Items.Add('����� =)');
end;

end.
