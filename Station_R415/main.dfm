object MainForm: TMainForm
  Left = 0
  Top = 0
  VertScrollBar.Tracking = True
  Align = alClient
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1056#1072#1076#1080#1086#1088#1077#1083#1077#1081#1085#1072#1103' '#1089#1090#1072#1085#1094#1080#1103' '#1056'-415'
  ClientHeight = 344
  ClientWidth = 1024
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mainMenu
  OldCreateOrder = False
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnClose = FormClose
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1024
    Height = 121
    Align = alTop
    Alignment = taLeftJustify
    TabOrder = 0
    Visible = False
    object Label1: TLabel
      Left = 8
      Top = 32
      Width = 3
      Height = 13
    end
    object grp1: TGroupBox
      Left = 1
      Top = 1
      Width = 1022
      Height = 48
      Align = alTop
      Caption = #1052#1099':'
      TabOrder = 0
      object lbl1: TLabel
        Left = 119
        Top = 21
        Width = 14
        Height = 13
        Caption = 'IP:'
      end
      object lbl2: TLabel
        Left = 239
        Top = 21
        Width = 31
        Height = 13
        Caption = 'PORT:'
      end
      object lbl3: TLabel
        Left = 324
        Top = 21
        Width = 54
        Height = 13
        Caption = #1055#1086#1079#1099#1074#1085#1086#1081':'
      end
      object lbl4: TLabel
        Left = 16
        Top = 21
        Width = 93
        Height = 13
        Caption = #1056#1072#1073#1086#1090#1072' '#1072#1074#1090#1086#1085#1086#1084#1085#1086
        Color = clBlack
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object lbl9: TLabel
        Left = 511
        Top = 21
        Width = 66
        Height = 13
        Caption = #1055#1086#1076#1095#1080#1085#1077#1085#1080#1077':'
      end
      object lbl10: TLabel
        Left = 583
        Top = 21
        Width = 61
        Height = 13
        Caption = #1053#1077#1090' '#1076#1072#1085#1085#1099#1093
      end
      object edt1: TEdit
        Left = 139
        Top = 18
        Width = 94
        Height = 21
        TabOrder = 0
        Text = '127.0.0.1'
      end
      object edt2: TEdit
        Left = 276
        Top = 18
        Width = 42
        Height = 21
        TabOrder = 1
        Text = '2106'
      end
      object edt3: TEdit
        Left = 384
        Top = 18
        Width = 121
        Height = 21
        TabOrder = 2
        Text = #1055#1077#1088#1074#1099#1081
      end
      object btn1: TButton
        Left = 666
        Top = 17
        Width = 97
        Height = 25
        Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100#1089#1103
        TabOrder = 3
        OnClick = btn1Click
      end
    end
    object grp2: TGroupBox
      Left = 1
      Top = 49
      Width = 1022
      Height = 64
      Align = alTop
      Caption = #1057#1086#1087#1088#1103#1078#1077#1085#1085#1072#1103' '#1089#1090#1072#1085#1094#1080#1103':'
      TabOrder = 1
      object lbl5: TLabel
        Left = 50
        Top = 24
        Width = 48
        Height = 13
        Caption = #1054#1092#1092#1083#1072#1081#1085
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lbl6: TLabel
        Left = 16
        Top = 24
        Width = 28
        Height = 13
        Caption = #1056'415:'
      end
      object lbl7: TLabel
        Left = 139
        Top = 24
        Width = 54
        Height = 13
        Caption = #1055#1086#1079#1099#1074#1085#1086#1081':'
      end
      object lbl8: TLabel
        Left = 199
        Top = 24
        Width = 61
        Height = 13
        Caption = #1053#1077#1090' '#1076#1072#1085#1085#1099#1093
      end
      object lbl11: TLabel
        Left = 139
        Top = 43
        Width = 25
        Height = 13
        Caption = #1055#1056#1044':'
      end
      object lbl12: TLabel
        Left = 170
        Top = 43
        Width = 4
        Height = 13
        Caption = '-'
      end
      object lbl13: TLabel
        Left = 208
        Top = 43
        Width = 25
        Height = 13
        Caption = #1055#1056#1052':'
      end
      object lbl14: TLabel
        Left = 239
        Top = 43
        Width = 4
        Height = 13
        Caption = '-'
      end
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 121
    Width = 1024
    Height = 136
    Align = alTop
    TabOrder = 1
    Visible = False
    object edt4: TEdit
      Left = 8
      Top = 101
      Width = 417
      Height = 21
      TabOrder = 0
      Text = '1460. '#1071' 1450. '#1050#1072#1082' '#1084#1077#1085#1103' '#1089#1083#1099#1096#1080#1090#1077' ?'
    end
    object mmo1: TMemo
      Left = 8
      Top = 6
      Width = 497
      Height = 89
      ScrollBars = ssVertical
      TabOrder = 1
    end
    object btn2: TButton
      Left = 431
      Top = 101
      Width = 75
      Height = 25
      Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100
      TabOrder = 2
      OnClick = btn2Click
    end
  end
  object mainMenu: TMainMenu
    Left = 64
    Top = 265
    object N1: TMenuItem
      Caption = #1056#1077#1078#1080#1084' '#1088#1072#1073#1086#1090#1099
      object N2: TMenuItem
        Caption = #1054#1073#1091#1095#1077#1085#1080#1077
        OnClick = N2Click
      end
      object N11: TMenuItem
        Caption = #1058#1088#1077#1085#1080#1088#1086#1074#1082#1072
        OnClick = N11Click
      end
      object N16: TMenuItem
        Caption = #1055#1088#1080#1089#1090#1091#1087#1080#1090#1100
        OnClick = N16Click
      end
    end
    object N3: TMenuItem
      Caption = #1054#1082#1085#1072
      object N12: TMenuItem
        AutoCheck = True
        Caption = #1057#1077#1088#1074#1077#1088
        OnClick = N12Click
      end
      object N13: TMenuItem
        AutoCheck = True
        Caption = #1052#1058
        OnClick = N13Click
      end
      object N14: TMenuItem
        AutoCheck = True
        Caption = #1050#1086#1085#1089#1086#1083#1100
        Checked = True
        OnClick = N14Click
      end
      object N15: TMenuItem
        AutoCheck = True
        Caption = #1053#1072#1074#1080#1075#1072#1094#1080#1103
        Checked = True
        OnClick = N15Click
      end
    end
  end
end
