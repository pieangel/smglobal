object FrmOrderType: TFrmOrderType
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #51452#47928#50976#54805#49440#53469
  ClientHeight = 88
  ClientWidth = 145
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox4: TGroupBox
    Left = 5
    Top = 3
    Width = 134
    Height = 55
    TabOrder = 0
    object rbMarket: TRadioButton
      Left = 3
      Top = 10
      Width = 58
      Height = 17
      Caption = #49884#51109#44032
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbHoga: TRadioButton
      Left = 2
      Top = 31
      Width = 67
      Height = 17
      Caption = #49345#45824#54840#44032
      TabOrder = 1
    end
    object edtLiqTick: TAlignedEdit
      Tag = 2
      Left = 74
      Top = 28
      Width = 40
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 2
      Text = '1'
      Alignment = clRight
      AlignType = atNumber
    end
    object udLiqTick: TUpDown
      Left = 114
      Top = 28
      Width = 16
      Height = 21
      Associate = edtLiqTick
      Max = 10
      Position = 1
      TabOrder = 3
    end
  end
  object Button1: TButton
    Left = 5
    Top = 63
    Width = 41
    Height = 20
    Caption = #54869#51064
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 96
    Top = 62
    Width = 41
    Height = 20
    Caption = #52712#49548
    ModalResult = 2
    TabOrder = 2
  end
end
