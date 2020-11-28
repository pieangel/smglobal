object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 118
  ClientWidth = 408
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 408
    Height = 24
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object sbtnSend: TSpeedButton
      Left = 349
      Top = 1
      Width = 43
      Height = 22
      Caption = #48372#45236#44592
      OnClick = sbtnSendClick
    end
    object LabeledEdit1: TLabeledEdit
      Left = 31
      Top = 1
      Width = 121
      Height = 21
      EditLabel.Width = 20
      EditLabel.Height = 13
      EditLabel.Caption = 'IP : '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 0
      Text = '127.0.0.1'
    end
    object LabeledEdit2: TLabeledEdit
      Left = 206
      Top = 1
      Width = 56
      Height = 21
      EditLabel.Width = 37
      EditLabel.Height = 13
      EditLabel.Caption = 'PORT : '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 1
      Text = '82828'
    end
    object Button1: TButton
      Left = 274
      Top = 1
      Width = 39
      Height = 22
      Caption = #51333#47785
      TabOrder = 2
      OnClick = Button1Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 24
    Width = 408
    Height = 94
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object sgSymbol: TStringGrid
      Left = 0
      Top = 0
      Width = 408
      Height = 94
      Align = alClient
      ColCount = 6
      DefaultRowHeight = 19
      FixedCols = 0
      RowCount = 2
      TabOrder = 0
    end
  end
  object udpSend: TIdUDPClient
    Port = 0
    Left = 272
    Top = 48
  end
end
