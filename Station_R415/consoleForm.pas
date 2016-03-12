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
    Self.console.Items.Add('ƒобро пожаловать !!!');
    Self.console.Items.Add('¬ы вошли в тренажер редиорелейной станциии –-415.');
    Self.console.Items.Add('');
    Self.console.Items.Add('¬се органы управлени€ сейчас доступны, но питание не подано. »змен€€');
    Self.console.Items.Add(' что-либо, помните, эти параметры станут исходными в любом из');
    Self.console.Items.Add(' режимов работы.');
    Self.console.Items.Add('');
    Self.console.Items.Add(' ликните по пункту "–ежим работы", наход€щемс€ в верхнем меню, и начните с обучени€');
    Self.console.Items.Add(' выберите тот, который нужен вам.');
    Self.console.Items.Add('');
    Self.console.Items.Add('”дачи =)');
end;

end.
