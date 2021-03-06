object FrmVolTrading: TFrmVolTrading
  Left = 0
  Top = 0
  Caption = 'Vol. Trade'
  ClientHeight = 127
  ClientWidth = 265
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object plRun: TPanel
    Left = 0
    Top = 0
    Width = 265
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
    object Button1: TButton
      Left = 237
      Top = 4
      Width = 20
      Height = 21
      Caption = '..'
      TabOrder = 0
      OnClick = Button1Click
    end
    object cbInvest: TComboBox
      Left = 56
      Top = 4
      Width = 97
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbInvestChange
    end
    object cbInvestType: TComboBox
      Left = 5
      Top = 5
      Width = 48
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = #44228#51340
      OnChange = cbInvestTypeChange
      Items.Strings = (
        #44228#51340
        #54144#46300)
    end
    object edtSymbol: TLabeledEdit
      Left = 185
      Top = 4
      Width = 48
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #51333#47785
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 3
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 108
    Width = 265
    Height = 19
    Panels = <
      item
        Width = 40
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 29
    Width = 265
    Height = 51
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 2
    object Button2: TButton
      Left = 5
      Top = 26
      Width = 30
      Height = 21
      Caption = #51201#50857
      TabOrder = 0
      OnClick = Button2Click
    end
    object edtLimitDown: TLabeledEdit
      Left = 214
      Top = 26
      Width = 39
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #54616#54620
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 1
      OnKeyPress = edtBaseUpPriceKeyPress
    end
    object cbRun: TCheckBox
      Left = 5
      Top = 4
      Width = 42
      Height = 17
      Caption = 'Run'
      TabOrder = 2
      OnClick = cbRunClick
    end
    object edtBaseUpPrice: TLabeledEdit
      Left = 134
      Top = 2
      Width = 44
      Height = 21
      EditLabel.Width = 12
      EditLabel.Height = 13
      EditLabel.Caption = #49345
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 3
      OnKeyPress = edtBaseUpPriceKeyPress
    end
    object edtBaseDownPrice: TLabeledEdit
      Left = 134
      Top = 26
      Width = 44
      Height = 21
      EditLabel.Width = 12
      EditLabel.Height = 13
      EditLabel.Caption = #54616
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 4
      OnKeyPress = edtBaseUpPriceKeyPress
    end
    object udOrdQty: TUpDown
      Left = 98
      Top = 2
      Width = 16
      Height = 21
      Associate = edtOrdQty
      Min = 1
      Position = 1
      TabOrder = 5
    end
    object edtOrdQty: TLabeledEdit
      Left = 73
      Top = 2
      Width = 25
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #49688#47049
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 6
      Text = '1'
    end
    object edtOrdGap: TLabeledEdit
      Left = 73
      Top = 26
      Width = 25
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #44036#44201
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 7
    end
    object edtLimitUp: TLabeledEdit
      Left = 214
      Top = 2
      Width = 39
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #49345#54620
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 8
      OnKeyPress = edtBaseUpPriceKeyPress
    end
  end
  object sg: TStringGrid
    Left = 0
    Top = 80
    Width = 265
    Height = 28
    Align = alClient
    ColCount = 2
    Ctl3D = False
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    ParentCtl3D = False
    ScrollBars = ssVertical
    TabOrder = 3
    ColWidths = (
      64
      182)
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 184
    Top = 128
  end
end
