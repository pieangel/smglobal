object FrmStrangle: TFrmStrangle
  Left = 0
  Top = 0
  Caption = #50577#47588#46020
  ClientHeight = 462
  ClientWidth = 313
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
    Width = 313
    Height = 169
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 11
      Top = 35
      Width = 24
      Height = 13
      Caption = #49688#47049
    end
    object Label2: TLabel
      Left = 87
      Top = 35
      Width = 31
      Height = 13
      Caption = 'Status'
    end
    object Label3: TLabel
      Left = 11
      Top = 62
      Width = 30
      Height = 13
      Caption = #49345#48169'1'
    end
    object Label4: TLabel
      Left = 11
      Top = 89
      Width = 30
      Height = 13
      Caption = #49345#48169'2'
    end
    object Label5: TLabel
      Left = 11
      Top = 116
      Width = 30
      Height = 13
      Caption = #49345#48169'3'
    end
    object Label6: TLabel
      Left = 137
      Top = 62
      Width = 30
      Height = 13
      Caption = #54616#48169'1'
    end
    object Label7: TLabel
      Left = 137
      Top = 89
      Width = 30
      Height = 13
      Caption = #54616#48169'2'
    end
    object Label8: TLabel
      Left = 137
      Top = 116
      Width = 30
      Height = 13
      Caption = #54616#48169'3'
    end
    object Label9: TLabel
      Left = 82
      Top = 143
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label10: TLabel
      Left = 14
      Top = 143
      Width = 24
      Height = 13
      Caption = #50741#49496
    end
    object Label12: TLabel
      Left = 142
      Top = 144
      Width = 24
      Height = 13
      Caption = #49552#51208
    end
    object Label11: TLabel
      Left = 210
      Top = 143
      Width = 36
      Height = 13
      Caption = ',000 \'
    end
    object cbStart: TCheckBox
      Left = 9
      Top = 3
      Width = 47
      Height = 17
      Caption = 'Start'
      TabOrder = 0
      OnClick = cbStartClick
    end
    object ComboAccount: TComboBox
      Left = 63
      Top = 2
      Width = 137
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboAccountChange
    end
    object btnSymbol: TButton
      Left = 203
      Top = 1
      Width = 52
      Height = 21
      Caption = #51333#47785
      TabOrder = 2
      OnClick = btnSymbolClick
    end
    object edtQty: TEdit
      Left = 46
      Top = 32
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      Text = '1'
    end
    object edtStatus: TEdit
      Left = 118
      Top = 32
      Width = 43
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 4
    end
    object edtUpBid1: TEdit
      Left = 46
      Top = 59
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 5
      Text = '0.7'
    end
    object edtUpBid2: TEdit
      Left = 46
      Top = 86
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 6
      Text = '0.65'
    end
    object edtUpBid3: TEdit
      Left = 46
      Top = 113
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 7
      Text = '0.6'
    end
    object edtUpAsk1: TEdit
      Left = 93
      Top = 59
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 8
      Text = '0.9'
    end
    object edtUpAsk2: TEdit
      Left = 93
      Top = 86
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 9
      Text = '1'
    end
    object edtUpAsk3: TEdit
      Left = 93
      Top = 113
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 10
      Text = '1.1'
    end
    object edtDownBid1: TEdit
      Left = 173
      Top = 59
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 11
      Text = '0.7'
    end
    object edtDownAsk1: TEdit
      Left = 220
      Top = 59
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 12
      Text = '0.9'
    end
    object edtDownBid2: TEdit
      Left = 173
      Top = 86
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 13
      Text = '0.65'
    end
    object edtDownAsk2: TEdit
      Left = 220
      Top = 86
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 14
      Text = '1'
    end
    object edtDownBid3: TEdit
      Left = 173
      Top = 113
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 15
      Text = '0.6'
    end
    object edtDownAsk3: TEdit
      Left = 220
      Top = 113
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 16
      Text = '1.1'
    end
    object cbLow: TCheckBox
      Left = 165
      Top = 34
      Width = 70
      Height = 17
      Caption = 'LowHedge'
      Checked = True
      State = cbChecked
      TabOrder = 17
      OnClick = cbStartClick
    end
    object edtLow: TEdit
      Left = 46
      Top = 140
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 18
      Text = '0.5'
    end
    object edtHigh: TEdit
      Left = 93
      Top = 140
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 19
      Text = '2.0'
    end
    object btnClear: TButton
      Left = 258
      Top = 1
      Width = 52
      Height = 21
      Caption = #52397#49328
      TabOrder = 20
      OnClick = btnClearClick
    end
    object cbUseHedge: TCheckBox
      Left = 241
      Top = 34
      Width = 67
      Height = 17
      Caption = 'UseHedge'
      TabOrder = 21
      OnClick = cbStartClick
    end
    object edtLoss: TEdit
      Left = 173
      Top = 140
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 22
      Text = '200'
    end
    object Button1: TButton
      Left = 254
      Top = 143
      Width = 36
      Height = 17
      Caption = #51201#50857
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 23
      OnClick = Button1Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 169
    Width = 313
    Height = 293
    Align = alClient
    TabOrder = 1
    object sgStatus: TStringGrid
      Tag = 1
      Left = 1
      Top = 230
      Width = 311
      Height = 43
      Align = alBottom
      ColCount = 6
      DefaultColWidth = 50
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      ScrollBars = ssNone
      TabOrder = 0
      OnDrawCell = sgFutDrawCell
    end
    object sgFut: TStringGrid
      Left = 1
      Top = 1
      Width = 311
      Height = 43
      Align = alTop
      ColCount = 4
      DefaultColWidth = 75
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      ScrollBars = ssNone
      TabOrder = 1
      OnDrawCell = sgFutDrawCell
    end
    object sgOpt: TStringGrid
      Left = 1
      Top = 44
      Width = 311
      Height = 186
      Align = alClient
      ColCount = 4
      DefaultColWidth = 75
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 8
      ScrollBars = ssNone
      TabOrder = 2
      OnDrawCell = sgFutDrawCell
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 273
      Width = 311
      Height = 19
      Panels = <
        item
          Alignment = taRightJustify
          Width = 100
        end
        item
          Alignment = taRightJustify
          Width = 50
        end>
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 96
  end
end
