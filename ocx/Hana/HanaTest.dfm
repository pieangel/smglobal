object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 198
  ClientWidth = 493
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object m: TMemo
    Left = 8
    Top = 8
    Width = 393
    Height = 182
    ImeName = 'Microsoft Office IME 2007'
    Lines.Strings = (
      'm')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Button1: TButton
    Left = 407
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 407
    Top = 39
    Width = 75
    Height = 25
    Caption = #51217#49549
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 407
    Top = 70
    Width = 75
    Height = 25
    Caption = #47196#44536#50500#50883
    TabOrder = 3
    OnClick = Button3Click
  end
  object cbStockGame: TCheckBox
    Left = 407
    Top = 173
    Width = 45
    Height = 17
    Caption = #47784#51032
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object Button4: TButton
    Left = 407
    Top = 101
    Width = 75
    Height = 25
    Caption = #44228#51340#51312#54924
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 407
    Top = 132
    Width = 75
    Height = 25
    Caption = #51333#47785#47560#49828#53552
    TabOrder = 6
    OnClick = Button5Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Timer1Timer
    Left = 448
    Top = 160
  end
end
