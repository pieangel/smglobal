object FrmA50Trend: TFrmA50Trend
  Left = 0
  Top = 0
  Caption = 'K3_1'
  ClientHeight = 260
  ClientWidth = 294
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
    294
    260)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 147
    Top = 56
    Width = 8
    Height = 13
    Caption = '~'
  end
  object Label2: TLabel
    Left = 18
    Top = 56
    Width = 24
    Height = 13
    Caption = #49884#44036
  end
  object Label3: TLabel
    Left = 19
    Top = 80
    Width = 24
    Height = 13
    Caption = #51652#51077
  end
  object Label4: TLabel
    Left = 147
    Top = 79
    Width = 8
    Height = 13
    Caption = '~'
  end
  object Label5: TLabel
    Left = 19
    Top = 103
    Width = 24
    Height = 13
    Caption = #52397#49328
  end
  object Label7: TLabel
    Left = 7
    Top = 36
    Width = 36
    Height = 13
    Caption = #51109#49884#51089
  end
  object plRun: TPanel
    Left = 0
    Top = 0
    Width = 294
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
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
    TabOrder = 1
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
    TabOrder = 2
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 241
    Width = 294
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 50
      end>
  end
  object edtE1: TLabeledEdit
    Left = 101
    Top = 123
    Width = 30
    Height = 21
    EditLabel.Width = 13
    EditLabel.Height = 13
    EditLabel.Caption = 'E :'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 4
    Text = '3.8'
    OnKeyPress = edtE1KeyPress
  end
  object edtL1: TLabeledEdit
    Left = 160
    Top = 123
    Width = 35
    Height = 21
    EditLabel.Width = 12
    EditLabel.Height = 13
    EditLabel.Caption = 'L :'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 5
    Text = '0.012'
    OnKeyPress = edtE1KeyPress
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
    TabOrder = 7
  end
  object dtLiqStart: TDateTimePicker
    Left = 48
    Top = 98
    Width = 97
    Height = 21
    Date = 42401.625000000000000000
    Time = 42401.625000000000000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 8
  end
  object edtPeriod: TLabeledEdit
    Left = 216
    Top = 123
    Width = 30
    Height = 21
    EditLabel.Width = 13
    EditLabel.Height = 13
    EditLabel.Caption = 'P :'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 9
    Text = '5'
    OnKeyPress = edtE1KeyPress
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
    TabOrder = 10
  end
  object edtATRPeriod: TLabeledEdit
    Left = 177
    Top = 98
    Width = 30
    Height = 21
    EditLabel.Width = 20
    EditLabel.Height = 13
    EditLabel.Caption = 'ATR'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 11
    Text = '30'
  end
  object edtATRMulti: TLabeledEdit
    Left = 218
    Top = 98
    Width = 30
    Height = 21
    EditLabel.Width = 6
    EditLabel.Height = 13
    EditLabel.Caption = '*'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 12
    Text = '5'
    OnKeyPress = edtE1KeyPress
  end
  object edtOrdQty: TLabeledEdit
    Left = 48
    Top = 122
    Width = 30
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #51452#47928
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 13
    Text = '1'
    OnKeyPress = edtE1KeyPress
  end
  object edtTrl1P: TLabeledEdit
    Left = 48
    Top = 146
    Width = 30
    Height = 21
    EditLabel.Width = 22
    EditLabel.Height = 13
    EditLabel.Caption = 'Stop'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 14
    Text = '300'
    OnKeyPress = edtE1KeyPress
  end
  object edtTrl2p: TLabeledEdit
    Left = 101
    Top = 146
    Width = 30
    Height = 21
    EditLabel.Width = 16
    EditLabel.Height = 13
    EditLabel.Caption = '-->'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 15
    Text = '100'
    OnKeyPress = edtE1KeyPress
  end
  object edtGoalP: TLabeledEdit
    Left = 165
    Top = 146
    Width = 30
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #51061#51208
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 16
    Text = '700'
    OnKeyPress = edtE1KeyPress
  end
  object Button2: TButton
    Left = 252
    Top = 146
    Width = 31
    Height = 21
    Caption = #51201#50857
    TabOrder = 17
    OnClick = Button2Click
  end
  object edtTermCnt: TLabeledEdit
    Left = 254
    Top = 98
    Width = 24
    Height = 21
    EditLabel.Width = 3
    EditLabel.Height = 13
    EditLabel.Caption = ' '
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 18
    Text = '12'
    OnKeyPress = edtE1KeyPress
  end
  object sgLog: TStringGrid
    Left = 18
    Top = 173
    Width = 263
    Height = 63
    ColCount = 4
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 3
    FixedRows = 0
    TabOrder = 19
  end
  object cbRun: TCheckBox
    Left = 160
    Top = 31
    Width = 42
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Run'
    TabOrder = 20
    OnClick = cbRunClick
  end
  object Button3: TButton
    Left = 136
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Button3'
    Enabled = False
    TabOrder = 21
    Visible = False
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 217
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Button4'
    Enabled = False
    TabOrder = 22
    Visible = False
    OnClick = Button4Click
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 256
    Top = 72
  end
end
