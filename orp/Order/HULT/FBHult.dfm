object FrmBHult: TFrmBHult
  Left = 0
  Top = 0
  Caption = 'Jarvis'
  ClientHeight = 330
  ClientWidth = 251
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
    Width = 251
    Height = 54
    Align = alTop
    BevelOuter = bvLowered
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 252
    DesignSize = (
      251
      54)
    object Label1: TLabel
      Left = 4
      Top = 7
      Width = 24
      Height = 13
      Caption = #44228#51340
    end
    object Label3: TLabel
      Left = 4
      Top = 32
      Width = 24
      Height = 13
      Caption = #51333#47785
    end
    object cbAccount: TComboBox
      Left = 32
      Top = 4
      Width = 102
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object cbStart: TCheckBox
      Left = 199
      Top = 31
      Width = 46
      Height = 18
      Anchors = [akRight, akBottom]
      Caption = 'Start'
      TabOrder = 1
      OnClick = cbStartClick
      ExplicitLeft = 200
    end
    object cbSymbols: TComboBox
      Left = 32
      Top = 28
      Width = 102
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbSymbolsChange
    end
    object cbMarket: TComboBox
      Left = 140
      Top = 28
      Width = 52
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 3
      Text = #49440#47932
      OnChange = cbMarketChange
      Items.Strings = (
        #49440#47932
        #53084
        #54411)
    end
    object cbAutoStart: TCheckBox
      Left = 140
      Top = 5
      Width = 70
      Height = 17
      Caption = 'AutoStart'
      TabOrder = 4
      OnClick = cbAutoStartClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 54
    Width = 251
    Height = 257
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    ExplicitWidth = 252
    ExplicitHeight = 258
    object gbUseHul: TGroupBox
      Left = 4
      Top = 193
      Width = 244
      Height = 36
      TabOrder = 0
      object Label6: TLabel
        Left = 99
        Top = 12
        Width = 8
        Height = 13
        Caption = '~'
      end
      object dtEndTime: TDateTimePicker
        Left = 112
        Top = 8
        Width = 93
        Height = 21
        Date = 41547.625000000000000000
        Time = 41547.625000000000000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object dtStartTime: TDateTimePicker
        Left = 3
        Top = 8
        Width = 92
        Height = 21
        Date = 41547.378472222220000000
        Time = 41547.378472222220000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 1
      end
      object Button2: TButton
        Left = 211
        Top = 9
        Width = 30
        Height = 21
        Caption = #51201#50857
        TabOrder = 2
        OnClick = Button2Click
      end
    end
    object GroupBox3: TGroupBox
      Left = 4
      Top = 2
      Width = 81
      Height = 87
      Caption = #44592#48376
      TabOrder = 1
      object Label2: TLabel
        Left = 7
        Top = 20
        Width = 24
        Height = 13
        Caption = #49688#47049
      end
      object Label4: TLabel
        Left = 7
        Top = 42
        Width = 24
        Height = 13
        Caption = #44036#44201
      end
      object Label9: TLabel
        Left = 7
        Top = 64
        Width = 24
        Height = 13
        Caption = #54924#49688
      end
      object edtQty: TEdit
        Left = 36
        Top = 15
        Width = 25
        Height = 21
        Hint = #49688#47049
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = '1'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udQty: TUpDown
        Left = 61
        Top = 15
        Width = 15
        Height = 21
        Associate = edtQty
        Min = 1
        Max = 500
        Position = 1
        TabOrder = 1
      end
      object edtGap: TEdit
        Tag = 1
        Left = 36
        Top = 38
        Width = 24
        Height = 21
        Hint = 'Tick'
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Text = '5'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udGap: TUpDown
        Left = 60
        Top = 38
        Width = 15
        Height = 21
        Associate = edtGap
        Max = 1000
        Position = 5
        TabOrder = 3
      end
      object edtOrdCnt: TEdit
        Tag = 2
        Left = 36
        Top = 61
        Width = 25
        Height = 21
        Hint = #51452#47928#54924#49688
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        Text = '1'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udOrdCnt: TUpDown
        Left = 61
        Top = 61
        Width = 15
        Height = 21
        Associate = edtOrdCnt
        Min = 1
        Max = 1000
        Position = 1
        TabOrder = 5
      end
    end
    object GroupBox4: TGroupBox
      Left = 86
      Top = 1
      Width = 160
      Height = 106
      Caption = #51088#46041#52397#49328
      TabOrder = 2
      object cbAutoLiquid: TCheckBox
        Left = 11
        Top = 15
        Width = 82
        Height = 17
        Caption = #51088#46041#46041#52397#49328
        TabOrder = 0
        OnClick = cbAutoLiquidClick
      end
      object edtplTick1th: TLabeledEdit
        Left = 20
        Top = 33
        Width = 29
        Height = 21
        EditLabel.Width = 8
        EditLabel.Height = 13
        EditLabel.Caption = '+'
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 1
        Text = '5'
        OnChange = edtplTick1thChange
      end
      object udplTick1th: TUpDown
        Left = 49
        Top = 33
        Width = 15
        Height = 21
        Associate = edtplTick1th
        Position = 5
        TabOrder = 2
      end
      object edtLcTick1th: TLabeledEdit
        Left = 21
        Top = 57
        Width = 29
        Height = 21
        EditLabel.Width = 12
        EditLabel.Height = 13
        EditLabel.Caption = #12641
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 3
        Text = '5'
        OnChange = edtplTick1thChange
      end
      object udLcTick1th: TUpDown
        Left = 50
        Top = 57
        Width = 15
        Height = 21
        Associate = edtLcTick1th
        Position = 5
        TabOrder = 4
      end
      object edtplTick2th: TEdit
        Left = 69
        Top = 33
        Width = 25
        Height = 21
        Hint = #49688#47049
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        Text = '0'
        OnChange = edtplTick1thChange
        OnKeyPress = edtQtyKeyPress
      end
      object udplTick2th: TUpDown
        Left = 94
        Top = 33
        Width = 15
        Height = 21
        Associate = edtplTick2th
        Max = 500
        TabOrder = 6
      end
      object edtLcTick2th: TEdit
        Left = 69
        Top = 57
        Width = 25
        Height = 21
        Hint = #49688#47049
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
        Text = '0'
        OnChange = edtplTick1thChange
        OnKeyPress = edtQtyKeyPress
      end
      object udLcTick2th: TUpDown
        Left = 94
        Top = 57
        Width = 15
        Height = 21
        Associate = edtLcTick2th
        Max = 500
        TabOrder = 8
      end
      object cbParaLiquid: TCheckBox
        Left = 11
        Top = 83
        Width = 73
        Height = 17
        Caption = 'Para '#52397#49328
        TabOrder = 9
        OnClick = cbParaLiquidClick
      end
      object edtplTick3th: TEdit
        Left = 112
        Top = 34
        Width = 25
        Height = 21
        Hint = #49688#47049
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 10
        Text = '0'
        OnChange = edtplTick1thChange
        OnKeyPress = edtQtyKeyPress
      end
      object udplTick3th: TUpDown
        Left = 137
        Top = 34
        Width = 15
        Height = 21
        Associate = edtplTick3th
        Max = 500
        TabOrder = 11
      end
      object edtLcTick3th: TEdit
        Left = 112
        Top = 58
        Width = 25
        Height = 21
        Hint = #49688#47049
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 12
        Text = '0'
        OnChange = edtplTick1thChange
        OnKeyPress = edtQtyKeyPress
      end
      object udLcTick3th: TUpDown
        Left = 137
        Top = 58
        Width = 15
        Height = 21
        Associate = edtLcTick3th
        Max = 500
        TabOrder = 13
      end
      object stGap: TStaticText
        Left = 102
        Top = 11
        Width = 29
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        TabOrder = 14
      end
    end
    object GroupBox5: TGroupBox
      Left = 4
      Top = 107
      Width = 245
      Height = 89
      Caption = #51312#44148
      TabOrder = 3
      object Label5: TLabel
        Left = 93
        Top = 66
        Width = 17
        Height = 13
        Caption = 'Pos'
      end
      object cbPara: TCheckBox
        Left = 7
        Top = 18
        Width = 48
        Height = 17
        Caption = 'Para'
        TabOrder = 0
        OnClick = cbParaClick
      end
      object cbForeign: TCheckBox
        Tag = 1
        Left = 7
        Top = 42
        Width = 50
        Height = 17
        Caption = #50808#51064
        TabOrder = 1
        OnClick = cbParaClick
      end
      object cbHultPos: TCheckBox
        Tag = 2
        Left = 7
        Top = 65
        Width = 48
        Height = 17
        Caption = 'Hult'
        TabOrder = 2
        OnClick = cbParaClick
      end
      object cbParaSymbol: TComboBox
        Left = 51
        Top = 16
        Width = 61
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft IME 2010'
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 3
        Text = #49440#47932
        OnChange = cbParaSymbolChange
        Items.Strings = (
          #49440#47932
          #49440#53469#51333#47785)
      end
      object edtAfVal: TLabeledEdit
        Left = 128
        Top = 16
        Width = 33
        Height = 21
        EditLabel.Width = 10
        EditLabel.Height = 13
        EditLabel.Caption = 'af'
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 4
        Text = '0.01'
        OnChange = edtAfValChange
      end
      object edtForFutQty: TLabeledEdit
        Left = 51
        Top = 39
        Width = 38
        Height = 21
        EditLabel.Width = 24
        EditLabel.Height = 13
        EditLabel.Caption = #44228#50557
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 5
        Text = '0'
        OnChange = edtForFutQtyChange
      end
      object cbTarget: TComboBox
        Left = 51
        Top = 63
        Width = 38
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft IME 2010'
        ItemHeight = 13
        ItemIndex = 1
        TabOrder = 6
        Text = '5'
        OnChange = cbTargetChange
        Items.Strings = (
          '4'
          '5')
      end
      object edtTargetPos: TEdit
        Tag = 2
        Left = 114
        Top = 63
        Width = 20
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 7
        Text = '4'
        OnChange = edtTargetPosChange
        OnKeyPress = edtQtyKeyPress
      end
      object udTargetPos: TUpDown
        Left = 134
        Top = 63
        Width = 15
        Height = 21
        Associate = edtTargetPos
        Min = 1
        Max = 10
        Position = 4
        TabOrder = 8
      end
      object stHultPL: TStaticText
        Left = 198
        Top = 65
        Width = 43
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        TabOrder = 9
      end
      object stCur: TStaticText
        Left = 198
        Top = 18
        Width = 43
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        TabOrder = 10
      end
      object stForFutQty: TStaticText
        Left = 198
        Top = 42
        Width = 43
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        TabOrder = 11
      end
      object stHultPos: TStaticText
        Left = 166
        Top = 65
        Width = 29
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        TabOrder = 12
      end
    end
    object plInfo: TPanel
      Left = 4
      Top = 230
      Width = 245
      Height = 26
      TabOrder = 4
    end
    object sgLog: TStringGrid
      Left = 1
      Top = 259
      Width = 251
      Height = 142
      Align = alCustom
      ColCount = 2
      Ctl3D = False
      DefaultColWidth = 50
      DefaultRowHeight = 17
      FixedCols = 0
      RowCount = 2
      ParentCtl3D = False
      ScrollBars = ssNone
      TabOrder = 5
      ColWidths = (
        50
        183)
    end
    object cbAutoStop: TCheckBox
      Left = 4
      Top = 89
      Width = 80
      Height = 17
      Caption = #52397#49328#54980'STOP'
      TabOrder = 6
      OnClick = cbAutoStopClick
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 311
    Width = 251
    Height = 19
    Panels = <
      item
        Style = psOwnerDraw
        Width = 40
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
    OnDrawPanel = stTxtDrawPanel
    ExplicitTop = 312
    ExplicitWidth = 252
  end
end
