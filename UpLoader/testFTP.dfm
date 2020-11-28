object Form1: TForm1
  Left = 0
  Top = 0
  Caption = #47196#44536' '#50629#47196#46300
  ClientHeight = 171
  ClientWidth = 581
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 151
    Top = 8
    Width = 85
    Height = 13
    Caption = #49324#50857#51088' '#50500#51060#46356' : '
  end
  object edtIp: TEdit
    Left = 8
    Top = 7
    Width = 121
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 0
    Text = '222.112.181.200'
  end
  object edtUser: TEdit
    Left = 8
    Top = 34
    Width = 121
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 1
    Text = 'update_sauri'
  end
  object edtPass: TEdit
    Left = 8
    Top = 61
    Width = 121
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 2
    Text = 'djqepdlxm82#'
  end
  object edtLocalDir: TEdit
    Left = 8
    Top = 88
    Width = 121
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 3
    Text = 'C:\Guru\HanaApi'#54644#50808'\Log\'
  end
  object Button1: TButton
    Left = 151
    Top = 55
    Width = 75
    Height = 25
    Caption = #51217#49549
    TabOrder = 4
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 151
    Top = 86
    Width = 75
    Height = 25
    Caption = #50629#47196#46300
    Enabled = False
    TabOrder = 5
    OnClick = Button2Click
  end
  object edtRemoteDir: TEdit
    Left = 8
    Top = 115
    Width = 121
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 6
    Text = '/HanaEx/Log'
  end
  object m: TMemo
    Left = 241
    Top = 8
    Width = 328
    Height = 155
    ImeName = 'Microsoft Office IME 2007'
    Lines.Strings = (
      'm')
    ScrollBars = ssBoth
    TabOrder = 7
  end
  object edtDir: TEdit
    Left = 151
    Top = 28
    Width = 75
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 8
    Text = 'yjs1974'
  end
  object dlgOpen: TOpenDialog
    InitialDir = 'C:\Guru\HanaApi'#54644#50808'\Log'
    Options = [ofReadOnly, ofHideReadOnly, ofNoChangeDir, ofAllowMultiSelect, ofNoTestFileCreate, ofEnableSizing]
    Title = #50629#47196#46300
    Left = 152
    Top = 120
  end
end
