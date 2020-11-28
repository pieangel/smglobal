object FrmLiqSet: TFrmLiqSet
  Left = 0
  Top = 0
  Width = 317
  Height = 116
  Color = clBtnFace
  ParentBackground = False
  ParentColor = False
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  object GroupBox3: TGroupBox
    Left = 2
    Top = 4
    Width = 132
    Height = 106
    Caption = #52404#44208#49884' '#51060#51061'/'#49552#49892#49444#51221' '
    TabOrder = 0
    object Label1: TLabel
      Left = 4
      Top = 64
      Width = 74
      Height = 13
      Caption = '( '#54217#44512#44032#44592#51456' )'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object cbPrfLiquid: TCheckBox
      Left = 7
      Top = 17
      Width = 71
      Height = 17
      Caption = #51060#51061#49892#54788
      TabOrder = 0
    end
    object cbLosLiquid: TCheckBox
      Left = 7
      Top = 39
      Width = 71
      Height = 17
      Caption = #49552#49892#51228#54620
      TabOrder = 1
    end
    object udPrfTick: TUpDown
      Left = 110
      Top = 14
      Width = 16
      Height = 21
      Associate = edtPrfTick
      Max = 1000
      Position = 5
      TabOrder = 2
    end
    object udLosTick: TUpDown
      Left = 110
      Top = 37
      Width = 16
      Height = 21
      Associate = edtLosTick
      Max = 1000
      Position = 5
      TabOrder = 3
    end
    object edtPrfTick: TAlignedEdit
      Left = 76
      Top = 14
      Width = 34
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 4
      Text = '5'
      Alignment = clRight
      AlignType = atNumber
    end
    object edtLosTick: TAlignedEdit
      Tag = 1
      Left = 76
      Top = 37
      Width = 34
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 5
      Text = '5'
      Alignment = clRight
      AlignType = atNumber
    end
    object Button5: TButton
      Left = 84
      Top = 60
      Width = 42
      Height = 21
      Caption = #51201#50857
      TabOrder = 6
    end
    object cbLiqType: TComboBox
      Left = 7
      Top = 82
      Width = 63
      Height = 21
      Hint = #51452#47928#50976#54805
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      ItemIndex = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      Text = #49884#51109#44032
      OnChange = cbLiqTypeChange
      Items.Strings = (
        #49884#51109#44032
        'STOP')
    end
    object edtLiqTick: TAlignedEdit
      Tag = 2
      Left = 81
      Top = 82
      Width = 29
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 8
      Text = '0'
      Visible = False
      Alignment = clRight
      AlignType = atNumber
    end
    object udLiqTick: TUpDown
      Left = 110
      Top = 82
      Width = 16
      Height = 21
      Associate = edtLiqTick
      Max = 10
      TabOrder = 9
      Visible = False
    end
  end
  object GroupBox1: TGroupBox
    Left = 142
    Top = 4
    Width = 144
    Height = 106
    Caption = '     '
    TabOrder = 1
    object Label10: TLabel
      Left = 16
      Top = 18
      Width = 63
      Height = 13
      Caption = #44592#51456' '#49552#51208#54001
    end
    object Label11: TLabel
      Left = 55
      Top = 40
      Width = 24
      Height = 13
      Caption = #51060#51061
    end
    object Label12: TLabel
      Left = 55
      Top = 63
      Width = 24
      Height = 13
      Caption = #52628#51201
    end
    object lbCalcTick: TLabel
      Left = 7
      Top = 63
      Width = 6
      Height = 12
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clPurple
      Font.Height = -12
      Font.Name = #44404#47548#52404
      Font.Style = []
      ParentFont = False
    end
    object lbMaxTick: TLabel
      Left = 7
      Top = 40
      Width = 6
      Height = 12
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clPurple
      Font.Height = -12
      Font.Name = #44404#47548#52404
      Font.Style = []
      ParentFont = False
    end
    object cbTrailingStop: TCheckBox
      Left = 7
      Top = 0
      Width = 95
      Height = 15
      Caption = #53944#47112#51068#47553#49828#53457
      TabOrder = 0
    end
    object edtBaseLCTick: TAlignedEdit
      Tag = 4
      Left = 82
      Top = 15
      Width = 38
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 1
      Text = '10'
      OnChange = edtBaseLCTickChange
      OnKeyPress = edtBaseLCTickKeyPress
      Alignment = clRight
      AlignType = atNumber
    end
    object edtPLTick: TAlignedEdit
      Tag = 5
      Left = 82
      Top = 37
      Width = 38
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 2
      Text = '1'
      OnChange = edtBaseLCTickChange
      OnKeyPress = edtBaseLCTickKeyPress
      Alignment = clRight
      AlignType = atNumber
    end
    object edtLCTick: TAlignedEdit
      Tag = 6
      Left = 82
      Top = 60
      Width = 38
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      Text = '1'
      OnChange = edtBaseLCTickChange
      OnKeyPress = edtBaseLCTickKeyPress
      Alignment = clRight
      AlignType = atNumber
    end
    object udLCTick: TUpDown
      Left = 120
      Top = 60
      Width = 16
      Height = 21
      Associate = edtLCTick
      Min = 1
      Max = 200
      Position = 1
      TabOrder = 4
    end
    object udPLTick: TUpDown
      Left = 120
      Top = 37
      Width = 16
      Height = 21
      Associate = edtPLTick
      Min = 1
      Max = 200
      Position = 1
      TabOrder = 5
    end
    object udBaseLCTick: TUpDown
      Left = 120
      Top = 15
      Width = 16
      Height = 21
      Associate = edtBaseLCTick
      Min = 1
      Max = 200
      Position = 10
      TabOrder = 6
    end
    object cbLiqType2: TComboBox
      Tag = 1
      Left = 7
      Top = 82
      Width = 63
      Height = 21
      Hint = #51452#47928#50976#54805
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      ItemIndex = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      Text = #49884#51109#44032
      OnChange = cbLiqTypeChange
      Items.Strings = (
        #49884#51109#44032
        'STOP')
    end
    object edtLiqTick2: TAlignedEdit
      Tag = 7
      Left = 91
      Top = 82
      Width = 29
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 8
      Text = '0'
      Visible = False
      OnChange = edtBaseLCTickChange
      OnKeyPress = edtBaseLCTickKeyPress
      Alignment = clRight
      AlignType = atNumber
    end
    object udLiqTick2: TUpDown
      Left = 120
      Top = 82
      Width = 16
      Height = 21
      Associate = edtLiqTick2
      Max = 10
      TabOrder = 9
      Visible = False
    end
    object btnApply: TButton
      Left = 108
      Top = 0
      Width = 43
      Height = 16
      Hint = #49828#53457' '#49892#54665#51473' '#49444#51221' '#51201#50857
      Caption = 'apply'
      TabOrder = 10
      Visible = False
    end
  end
end
