object FrmZombiePDT: TFrmZombiePDT
  Left = 0
  Top = 0
  Caption = #48152#50741#53804
  ClientHeight = 238
  ClientWidth = 299
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
    Width = 299
    Height = 27
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      299
      27)
    object Label1: TLabel
      Left = 4
      Top = 5
      Width = 22
      Height = 13
      Caption = 'Acnt'
    end
    object cbAccount: TComboBox
      Left = 28
      Top = 2
      Width = 98
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object cbStart: TCheckBox
      Left = 248
      Top = 5
      Width = 47
      Height = 17
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Start'
      TabOrder = 1
      OnClick = cbStartClick
    end
    object cbBHAcnt: TComboBox
      Left = 135
      Top = 2
      Width = 102
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbBHAcntChange
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 27
    Width = 299
    Height = 135
    Align = alTop
    BevelOuter = bvLowered
    ParentShowHint = False
    ShowHint = False
    TabOrder = 1
    object Label2: TLabel
      Left = 4
      Top = 6
      Width = 20
      Height = 13
      Caption = 'Prdt'
    end
    object Label5: TLabel
      Left = 88
      Top = 33
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label4: TLabel
      Left = 3
      Top = 33
      Width = 24
      Height = 13
      Caption = #51652#51077
    end
    object Label6: TLabel
      Left = 118
      Top = 115
      Width = 24
      Height = 13
      Caption = 'Over'
    end
    object edtSymbol: TEdit
      Left = 28
      Top = 3
      Width = 98
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 0
    end
    object Button1: TButton
      Left = 135
      Top = 4
      Width = 29
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = Button1Click
    end
    object GroupBox4: TGroupBox
      Left = 1
      Top = 52
      Width = 296
      Height = 36
      TabOrder = 2
      object Label3: TLabel
        Left = 99
        Top = 28
        Width = 11
        Height = 13
        Caption = '%'
        Visible = False
      end
      object Label7: TLabel
        Left = 2
        Top = 13
        Width = 24
        Height = 13
        Caption = #52397#49328
      end
      object edtLiqPer: TEdit
        Left = 72
        Top = 24
        Width = 25
        Height = 21
        Hint = #47751'%'#54616#46973#49884' '#52397#49328
        ImeName = 'Microsoft IME 2010'
        TabOrder = 0
        Text = '30'
        Visible = False
      end
      object edtRiskAmt: TEdit
        Left = 65
        Top = 9
        Width = 35
        Height = 21
        Hint = #49552#51208#44552#50529
        ImeName = 'Microsoft IME 2010'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Text = '10000'
      end
      object dtFstLiquidTime: TDateTimePicker
        Left = 101
        Top = 10
        Width = 93
        Height = 21
        Date = 41547.625000000000000000
        Time = 41547.625000000000000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 2
      end
      object Button4: TButton
        Left = 264
        Top = 10
        Width = 30
        Height = 21
        Caption = #52397#49328
        TabOrder = 3
        OnClick = Button4Click
      end
      object edtAddQty: TEdit
        Left = 194
        Top = 10
        Width = 20
        Height = 21
        Hint = #52628#44032' '#51452#47928' '#49688#47049
        ImeName = 'Microsoft IME 2010'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        Text = '5'
      end
      object udAddQty: TUpDown
        Left = 214
        Top = 10
        Width = 15
        Height = 21
        Associate = edtAddQty
        Min = 1
        Max = 10
        Position = 5
        TabOrder = 5
      end
      object edtDecAmt: TEdit
        Left = 230
        Top = 10
        Width = 31
        Height = 21
        Hint = #48152#50741' '#49688#47049' '#44048#49548' '#45800#44228
        ImeName = 'Microsoft IME 2010'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        Text = '100'
      end
      object edtPLAmt: TEdit
        Left = 27
        Top = 9
        Width = 35
        Height = 21
        Hint = #51060#51061#52397#49328#44552#50529
        ImeName = 'Microsoft IME 2010'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
        Text = '10000'
      end
    end
    object edtAbove: TEdit
      Left = 55
      Top = 29
      Width = 31
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 3
      Text = '0.3'
      OnKeyPress = edtAFKeyPress
    end
    object edtBelow: TEdit
      Left = 98
      Top = 29
      Width = 29
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 4
      Text = '1.5'
      OnKeyPress = edtAFKeyPress
    end
    object cbDir: TComboBox
      Left = 128
      Top = 29
      Width = 45
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 5
      Text = #50724#47492
      Items.Strings = (
        #50724#47492
        #45236#47548)
    end
    object edtReOrdCnt: TEdit
      Left = 175
      Top = 29
      Width = 25
      Height = 21
      Hint = #52628#44032#51452#47928#54924#49688
      ImeName = 'Microsoft IME 2010'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      Text = '5'
    end
    object udReOrdCnt: TUpDown
      Left = 200
      Top = 29
      Width = 15
      Height = 21
      Associate = edtReOrdCnt
      Min = 1
      Max = 10
      Position = 5
      TabOrder = 7
    end
    object Button2: TButton
      Left = 265
      Top = 4
      Width = 31
      Height = 21
      Caption = 'Apply'
      TabOrder = 8
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 265
      Top = 29
      Width = 31
      Height = 21
      Caption = #54200#51665
      TabOrder = 9
      OnClick = Button3Click
    end
    object edtEntryAmt: TEdit
      Left = 28
      Top = 29
      Width = 26
      Height = 21
      Hint = #44256#51216#45824#48708' '#50620#47560
      ImeName = 'Microsoft IME 2010'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
      Text = '200'
    end
    object edtInitQty: TEdit
      Left = 220
      Top = 30
      Width = 36
      Height = 21
      Hint = #52395#51452#47928#49688#47049
      ImeName = 'Microsoft IME 2010'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
      Text = '40'
    end
    object cbTargetQty: TCheckBox
      Left = 4
      Top = 90
      Width = 42
      Height = 17
      Hint = #44256#51221#49688#47049
      Caption = #51092#44256
      TabOrder = 12
    end
    object cbTerm: TCheckBox
      Left = 48
      Top = 90
      Width = 42
      Height = 17
      Caption = #44396#44036
      TabOrder = 13
    end
    object cbFut: TCheckBox
      Left = 166
      Top = 90
      Width = 38
      Height = 17
      Caption = 'fut'
      TabOrder = 14
      OnClick = cbFutClick
    end
    object cbOptSell: TCheckBox
      Left = 97
      Top = 90
      Width = 69
      Height = 17
      Caption = #48152#50741#47588#46020
      TabOrder = 15
      OnClick = cbOptSellClick
    end
    object cbVer2: TCheckBox
      Left = 5
      Top = 113
      Width = 49
      Height = 17
      Caption = 'ver2'
      TabOrder = 16
      OnClick = cbVer2Click
    end
    object cbVer2R: TCheckBox
      Left = 48
      Top = 113
      Width = 31
      Height = 17
      Caption = 'R'
      TabOrder = 17
    end
    object edtPLAbove: TEdit
      Left = 78
      Top = 110
      Width = 36
      Height = 21
      Hint = #48152#50741#49552#51061#51060
      ImeName = 'Microsoft IME 2010'
      TabOrder = 18
      Text = '0'
    end
    object rgEntryMode: TRadioGroup
      Left = 204
      Top = 89
      Width = 91
      Height = 40
      Hint = '1:'#51204#51200#51216' 2:'#51204#44256#51216' 3: '#54844#54633
      Caption = #51652#51077#47784#46300
      Columns = 3
      ItemIndex = 0
      Items.Strings = (
        '1'
        '2'
        '3')
      ParentShowHint = False
      ShowHint = False
      TabOrder = 19
    end
    object cbFixPL: TCheckBox
      Left = 148
      Top = 113
      Width = 54
      Height = 17
      Caption = #44256#51221#51060#51061
      TabOrder = 20
    end
  end
  object stbar: TStatusBar
    Left = 0
    Top = 220
    Width = 299
    Height = 18
    Panels = <
      item
        Style = psOwnerDraw
        Width = 40
      end
      item
        Width = 120
      end
      item
        Width = 50
      end>
    OnDrawPanel = stbarDrawPanel
  end
  object Panel3: TPanel
    Left = 0
    Top = 162
    Width = 299
    Height = 58
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 3
    object sgOrd: TStringGrid
      Left = 1
      Top = 1
      Width = 297
      Height = 56
      Align = alClient
      ColCount = 6
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
        49)
    end
  end
end
