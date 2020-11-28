object FrmA_P2: TFrmA_P2
  Left = 0
  Top = 0
  Caption = 'A_P2'
  ClientHeight = 258
  ClientWidth = 271
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
  DesignSize = (
    271
    258)
  PixelsPerInch = 96
  TextHeight = 13
  object Label7: TLabel
    Left = 7
    Top = 36
    Width = 36
    Height = 13
    Caption = #51109#49884#51089
  end
  object Label2: TLabel
    Left = 18
    Top = 56
    Width = 24
    Height = 13
    Caption = #49884#44036
  end
  object Label1: TLabel
    Left = 147
    Top = 56
    Width = 8
    Height = 13
    Caption = '~'
  end
  object Label4: TLabel
    Left = 147
    Top = 79
    Width = 8
    Height = 13
    Caption = '~'
  end
  object Label3: TLabel
    Left = 19
    Top = 80
    Width = 24
    Height = 13
    Caption = #51652#51077
  end
  object Label5: TLabel
    Left = 7
    Top = 102
    Width = 36
    Height = 13
    Caption = #51116#51652#51077
  end
  object Label6: TLabel
    Left = 147
    Top = 101
    Width = 8
    Height = 13
    Caption = '~'
  end
  object Label8: TLabel
    Left = 7
    Top = 122
    Width = 20
    Height = 13
    Caption = 'ATR'
  end
  object plRun: TPanel
    Left = 0
    Top = 0
    Width = 271
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 268
    object Button1: TButton
      Left = 240
      Top = 4
      Width = 20
      Height = 21
      Caption = '..'
      TabOrder = 0
      OnClick = Button1Click
    end
    object cbInvest: TComboBox
      Left = 59
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
      Left = 190
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
  object cbRun: TCheckBox
    Left = 159
    Top = 32
    Width = 42
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Run'
    TabOrder = 1
    OnClick = cbRunClick
    ExplicitLeft = 156
  end
  object mkStart: TDateTimePicker
    Left = 48
    Top = 31
    Width = 97
    Height = 21
    Date = 42401.416666666660000000
    Time = 42401.416666666660000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 2
  end
  object dtStart: TDateTimePicker
    Left = 48
    Top = 54
    Width = 97
    Height = 21
    Date = 42401.428472222220000000
    Time = 42401.428472222220000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 3
  end
  object dtEnd: TDateTimePicker
    Left = 159
    Top = 54
    Width = 97
    Height = 21
    Date = 42401.670138888890000000
    Time = 42401.670138888890000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 4
  end
  object dtEntend: TDateTimePicker
    Left = 159
    Top = 76
    Width = 97
    Height = 21
    Date = 42401.652777777780000000
    Time = 42401.652777777780000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 5
  end
  object dtEntStart: TDateTimePicker
    Left = 48
    Top = 76
    Width = 97
    Height = 21
    Date = 42401.437500000000000000
    Time = 42401.437500000000000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 6
  end
  object dtReEntStart: TDateTimePicker
    Left = 48
    Top = 98
    Width = 97
    Height = 21
    Date = 42401.479166666660000000
    Time = 42401.479166666660000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 7
  end
  object dtReEntEnd: TDateTimePicker
    Left = 159
    Top = 98
    Width = 97
    Height = 21
    Date = 42401.652777777780000000
    Time = 42401.652777777780000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 8
  end
  object edtATRPeriod: TLabeledEdit
    Left = 110
    Top = 120
    Width = 21
    Height = 21
    EditLabel.Width = 3
    EditLabel.Height = 13
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 9
    Text = '30'
    OnKeyPress = edtOrdQtyKeyPress
  end
  object edtATRMulti: TLabeledEdit
    Left = 142
    Top = 120
    Width = 19
    Height = 21
    EditLabel.Width = 6
    EditLabel.Height = 13
    EditLabel.Caption = '*'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 10
    Text = '4'
    OnKeyPress = edtOrdQtyKeyPress
  end
  object edtTermCnt: TLabeledEdit
    Left = 166
    Top = 120
    Width = 24
    Height = 21
    EditLabel.Width = 3
    EditLabel.Height = 13
    EditLabel.Caption = ' '
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 11
    Text = '36'
    OnKeyPress = edtOrdQtyKeyPress
  end
  object edtOrdQty: TLabeledEdit
    Left = 36
    Top = 145
    Width = 23
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #51452#47928
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 12
    Text = '1'
    OnKeyPress = edtOrdQtyKeyPress
  end
  object edtE1: TLabeledEdit
    Left = 77
    Top = 145
    Width = 30
    Height = 21
    EditLabel.Width = 9
    EditLabel.Height = 13
    EditLabel.Caption = 'E '
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 13
    Text = '3.0'
    OnKeyPress = edtE1KeyPress
  end
  object edtL1: TLabeledEdit
    Left = 124
    Top = 145
    Width = 35
    Height = 21
    EditLabel.Width = 11
    EditLabel.Height = 13
    EditLabel.Caption = 'L1'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 14
    Text = '0.013'
    OnKeyPress = edtE1KeyPress
  end
  object edtPeriod: TLabeledEdit
    Left = 234
    Top = 30
    Width = 23
    Height = 21
    EditLabel.Width = 10
    EditLabel.Height = 13
    EditLabel.Caption = 'P:'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 15
    Text = '5'
    OnKeyPress = edtOrdQtyKeyPress
  end
  object edtL2: TLabeledEdit
    Left = 179
    Top = 145
    Width = 35
    Height = 21
    EditLabel.Width = 11
    EditLabel.Height = 13
    EditLabel.Caption = 'L2'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 16
    Text = '0.018'
    OnKeyPress = edtE1KeyPress
  end
  object edtGoalP: TLabeledEdit
    Left = 227
    Top = 122
    Width = 30
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #51061#51208
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 17
    Text = '480'
    OnKeyPress = edtOrdQtyKeyPress
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 239
    Width = 271
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 50
      end>
    ExplicitTop = 241
    ExplicitWidth = 268
  end
  object sgLog: TStringGrid
    Left = 5
    Top = 172
    Width = 263
    Height = 63
    ColCount = 4
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 3
    FixedRows = 0
    TabOrder = 19
  end
  object Button2: TButton
    Left = 225
    Top = 145
    Width = 31
    Height = 21
    Caption = #51201#50857
    TabOrder = 20
    OnClick = Button2Click
  end
  object dtATRLiqStart: TDateTimePicker
    Left = 29
    Top = 120
    Width = 76
    Height = 21
    Date = 42401.635416666660000000
    Time = 42401.635416666660000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 21
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 256
    Top = 72
  end
end
