object FrmTrendTrade: TFrmTrendTrade
  Left = 0
  Top = 0
  Caption = 'Trend'
  ClientHeight = 373
  ClientWidth = 327
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 327
    Height = 27
    Align = alTop
    TabOrder = 0
    DesignSize = (
      327
      27)
    object cbAccount: TComboBox
      Left = 4
      Top = 2
      Width = 108
      Height = 21
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object cbStart: TCheckBox
      Left = 279
      Top = 4
      Width = 43
      Height = 17
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Run'
      TabOrder = 1
      OnClick = cbStartClick
    end
    object rbF: TRadioButton
      Left = 212
      Top = 4
      Width = 28
      Height = 17
      Caption = 'F'
      Checked = True
      TabOrder = 2
      TabStop = True
      OnClick = rbFClick
    end
    object rbO: TRadioButton
      Left = 238
      Top = 4
      Width = 28
      Height = 17
      Caption = 'O'
      TabOrder = 3
      OnClick = rbFClick
    end
    object dtStartTime: TDateTimePicker
      Left = 114
      Top = 2
      Width = 95
      Height = 21
      Date = 41717.376388888890000000
      Time = 41717.376388888890000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 4
    end
  end
  object stBar: TStatusBar
    Left = 0
    Top = 354
    Width = 327
    Height = 19
    Panels = <
      item
        Width = 150
      end
      item
        Width = 100
      end
      item
        Width = 100
      end>
    OnDrawPanel = stBarDrawPanel
  end
  object Panel2: TPanel
    Left = 0
    Top = 235
    Width = 323
    Height = 28
    TabOrder = 2
    object cbLiqSymbol: TComboBox
      Left = 3
      Top = 3
      Width = 104
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbLiqSymbolChange
    end
    object Button4: TButton
      Left = 112
      Top = 4
      Width = 36
      Height = 20
      Caption = #51312#54924
      TabOrder = 1
      OnClick = Button4Click
    end
    object edtLiqQty: TEdit
      Left = 154
      Top = 3
      Width = 27
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 2
      Text = '2'
    end
    object UpDown3: TUpDown
      Left = 181
      Top = 3
      Width = 15
      Height = 21
      Associate = edtLiqQty
      Min = 1
      Position = 2
      TabOrder = 3
    end
    object Button5: TButton
      Left = 282
      Top = 2
      Width = 36
      Height = 20
      Caption = #52397#49328
      TabOrder = 4
      OnClick = Button5Click
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 27
    Width = 327
    Height = 206
    Align = alTop
    TabOrder = 3
    object Label1: TLabel
      Left = 99
      Top = 185
      Width = 8
      Height = 13
      Caption = '~'
    end
    object cbTrend1: TCheckBox
      Left = 3
      Top = 6
      Width = 55
      Height = 17
      Caption = #52628#49464'1'
      TabOrder = 0
      OnClick = cbTrend1Click
    end
    object edtQty1: TEdit
      Left = 69
      Top = 3
      Width = 27
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 1
      Text = '2'
    end
    object UpDown1: TUpDown
      Left = 96
      Top = 3
      Width = 15
      Height = 21
      Associate = edtQty1
      Min = 1
      Position = 2
      TabOrder = 2
    end
    object dtEndTime: TDateTimePicker
      Left = 114
      Top = 3
      Width = 95
      Height = 21
      Date = 41717.617361111110000000
      Time = 41717.617361111110000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 3
    end
    object Button2: TButton
      Tag = 1
      Left = 237
      Top = 3
      Width = 41
      Height = 22
      Caption = 'default'
      TabOrder = 4
      OnClick = Button2Click
    end
    object btnApply1: TButton
      Tag = 1
      Left = 283
      Top = 3
      Width = 41
      Height = 22
      Caption = 'apply'
      TabOrder = 5
      OnClick = btnApply1Click
    end
    object sgTrend1: TStringGrid
      Left = 1
      Top = 27
      Width = 323
      Height = 61
      ColCount = 7
      Ctl3D = False
      DefaultColWidth = 45
      DefaultRowHeight = 19
      RowCount = 3
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
      ParentCtl3D = False
      ScrollBars = ssNone
      TabOrder = 6
    end
    object cbTrend2: TCheckBox
      Left = 3
      Top = 95
      Width = 102
      Height = 17
      Caption = #52628#49464'2 ('#53804#51088#51088' )'
      TabOrder = 7
      OnClick = cbTrend2Click
    end
    object edtQty2: TEdit
      Left = 111
      Top = 92
      Width = 27
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 8
      Text = '1'
    end
    object UpDown2: TUpDown
      Left = 138
      Top = 92
      Width = 15
      Height = 21
      Associate = edtQty2
      Min = 1
      Position = 1
      TabOrder = 9
    end
    object cbTrend2Stop: TCheckBox
      Left = 160
      Top = 95
      Width = 75
      Height = 17
      Caption = #52628#49464'2'#49828#53457
      TabOrder = 10
      OnClick = cbTrend2StopClick
    end
    object Button3: TButton
      Tag = 2
      Left = 237
      Top = 93
      Width = 41
      Height = 22
      Caption = 'default'
      TabOrder = 11
      OnClick = Button2Click
    end
    object Button1: TButton
      Tag = 2
      Left = 283
      Top = 93
      Width = 41
      Height = 22
      Caption = 'apply'
      TabOrder = 12
      OnClick = btnApply1Click
    end
    object dtStartTime2: TDateTimePicker
      Left = 1
      Top = 181
      Width = 95
      Height = 21
      Date = 41717.375694444450000000
      Time = 41717.375694444450000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 13
    end
    object dtEndTime2: TDateTimePicker
      Left = 111
      Top = 181
      Width = 91
      Height = 21
      Date = 41717.583333333340000000
      Time = 41717.583333333340000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 14
    end
    object cbInvest: TComboBox
      Left = 204
      Top = 181
      Width = 67
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 15
      Text = #44552#50997#53804#51088
      Items.Strings = (
        #44552#50997#53804#51088
        #50808#44397#51064
        #44592#44288#44228)
    end
    object sgTrend2: TStringGrid
      Left = 1
      Top = 118
      Width = 323
      Height = 61
      ColCount = 7
      Ctl3D = False
      DefaultColWidth = 45
      DefaultRowHeight = 19
      RowCount = 3
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
      ParentCtl3D = False
      ScrollBars = ssNone
      TabOrder = 16
    end
    object cbUseCnt: TCheckBox
      Left = 277
      Top = 183
      Width = 42
      Height = 17
      Caption = #44148#49688
      Checked = True
      State = cbChecked
      TabOrder = 17
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 233
    Width = 327
    Height = 121
    Align = alClient
    TabOrder = 4
    object sgOrd: TStringGrid
      Left = 1
      Top = 1
      Width = 325
      Height = 119
      Align = alClient
      ColCount = 7
      Ctl3D = False
      DefaultRowHeight = 17
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      ParentCtl3D = False
      TabOrder = 0
      OnDrawCell = sgOrdDrawCell
      ColWidths = (
        65
        59
        37
        31
        31
        49
        42)
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 176
    Top = 80
  end
end
