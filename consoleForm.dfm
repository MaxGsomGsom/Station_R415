object formConsole: TformConsole
  Left = 100
  Top = 200
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  Caption = #1050#1086#1085#1089#1086#1083#1100
  ClientHeight = 182
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 8
    Top = 161
    Width = 345
    Height = 13
    Caption = #1050#1083#1072#1074#1080#1096#1080' '#1091#1087#1088#1072#1074#1083#1077#1085#1080#1103': '#1042#1099#1087#1086#1083#1085#1080#1083'\'#1042#1099#1079#1086#1074' - "'#1055#1088#1086#1073#1077#1083'" ; '#1055#1086#1076#1089#1082#1072#1079#1082#1072' - "Q"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object console: TListBox
    Left = 0
    Top = 0
    Width = 447
    Height = 153
    Style = lbOwnerDrawFixed
    AutoComplete = False
    Align = alTop
    ItemHeight = 13
    MultiSelect = True
    TabOrder = 0
  end
end
