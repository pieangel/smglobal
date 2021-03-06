object FrmOrderMngr: TFrmOrderMngr
  Left = 0
  Top = 0
  Caption = #51452#47928#44288#47532
  ClientHeight = 280
  ClientWidth = 279
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
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 279
    Height = 31
    Align = alTop
    TabOrder = 0
    object BtnCohesionSymbol: TSpeedButton
      Left = 218
      Top = 5
      Width = 23
      Height = 19
      Caption = '...'
      OnClick = BtnCohesionSymbolClick
    end
    object cbSymbol: TComboBox
      Left = 125
      Top = 5
      Width = 87
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbSymbolChange
    end
    object ComboAccount: TComboBox
      Left = 4
      Top = 5
      Width = 115
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboAccountChange
    end
  end
  object gbPos: TGroupBox
    Tag = 1
    Left = 0
    Top = 100
    Width = 279
    Height = 86
    Align = alTop
    Caption = #48276#50948#45236' '#52404#44208#44032#45733' '#51452#47928#52712#49548' ( '#52572#45824#54252#51648#49496' '#44256#47140' )'
    Color = clBtnFace
    ParentBackground = False
    ParentColor = False
    TabOrder = 1
    object Label1: TLabel
      Left = 71
      Top = 42
      Width = 31
      Height = 13
      Caption = #47588#46020': '
    end
    object Label2: TLabel
      Left = 71
      Top = 64
      Width = 31
      Height = 13
      Caption = #47588#49688': '
    end
    object Label3: TLabel
      Left = 180
      Top = 42
      Width = 34
      Height = 13
      Caption = #47588#46020' : '
    end
    object Label6: TLabel
      Left = 180
      Top = 65
      Width = 34
      Height = 13
      Caption = #47588#49688' : '
    end
    object chSavePosRun: TCheckBox
      Left = 12
      Top = 19
      Width = 51
      Height = 17
      Caption = #49892#54665
      TabOrder = 0
      OnClick = chSavePosRunClick
    end
    object edtAsk: TEdit
      Left = 100
      Top = 37
      Width = 32
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 1
      Text = '1'
      OnChange = edtAskChange
      OnKeyPress = edtBidKeyPress
    end
    object edtBid: TEdit
      Left = 100
      Top = 60
      Width = 32
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 2
      Text = '1'
      OnChange = edtAskChange
      OnKeyPress = edtBidKeyPress
    end
    object edtAskPos: TEdit
      Left = 213
      Top = 37
      Width = 39
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 3
      Text = '1'
      OnChange = edtAskChange
      OnKeyPress = edtAskKeyPress
    end
    object Button1: TButton
      Tag = 1
      Left = 11
      Top = 59
      Width = 39
      Height = 22
      Caption = 'Logs'
      TabOrder = 4
      OnClick = Button1Click
    end
    object Panel1: TPanel
      Left = 69
      Top = 13
      Width = 80
      Height = 22
      Caption = #54840#44032' '#47112#48296
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
    end
    object Panel3: TPanel
      Left = 176
      Top = 14
      Width = 92
      Height = 22
      Caption = #52572#45824#54252#51648#49496#49688#47049
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
    end
    object edtBidPos: TEdit
      Left = 213
      Top = 60
      Width = 39
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 7
      Text = '1'
      OnChange = edtAskChange
      OnKeyPress = edtAskKeyPress
    end
    object udAsk: TUpDown
      Left = 132
      Top = 37
      Width = 16
      Height = 21
      Associate = edtAsk
      Min = 1
      Position = 1
      TabOrder = 8
    end
    object udBid: TUpDown
      Left = 132
      Top = 60
      Width = 16
      Height = 21
      Associate = edtBid
      Min = 1
      Position = 1
      TabOrder = 9
    end
    object udAskPos: TUpDown
      Left = 252
      Top = 37
      Width = 16
      Height = 21
      Associate = edtAskPos
      Min = 1
      Max = 9000
      Position = 1
      TabOrder = 10
    end
    object udBidPos: TUpDown
      Left = 252
      Top = 60
      Width = 16
      Height = 21
      Associate = edtBidPos
      Min = 1
      Max = 9000
      Position = 1
      TabOrder = 11
    end
  end
  object stBar: TStatusBar
    Left = 0
    Top = 261
    Width = 279
    Height = 19
    Panels = <
      item
        Width = 150
      end
      item
        Width = 50
      end>
  end
  object gbOrder: TGroupBox
    Left = 0
    Top = 31
    Width = 279
    Height = 69
    Align = alTop
    Caption = #48276#50948#45236' '#52404#44208#44032#45733' '#51452#47928' '#52712#49548
    Color = clBtnFace
    ParentBackground = False
    ParentColor = False
    TabOrder = 3
    object Label4: TLabel
      Left = 71
      Top = 42
      Width = 34
      Height = 13
      Caption = #47588#49688' : '
    end
    object Label5: TLabel
      Left = 71
      Top = 20
      Width = 34
      Height = 13
      Caption = #47588#46020' : '
    end
    object cbRun: TCheckBox
      Left = 12
      Top = 19
      Width = 51
      Height = 17
      Caption = #49892#54665
      TabOrder = 0
      OnClick = cbRunClick
    end
    object edtAsk2: TEdit
      Left = 108
      Top = 15
      Width = 37
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 1
      Text = '1'
      OnChange = edtAsk2Change
      OnKeyPress = edtBidKeyPress
    end
    object edtBid2: TEdit
      Left = 108
      Top = 38
      Width = 37
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 2
      Text = '1'
      OnChange = edtAsk2Change
      OnKeyPress = edtBidKeyPress
    end
    object Button2: TButton
      Left = 218
      Top = 39
      Width = 39
      Height = 22
      Caption = 'Logs'
      TabOrder = 3
      OnClick = Button1Click
    end
    object udAsk2: TUpDown
      Left = 145
      Top = 15
      Width = 16
      Height = 21
      Associate = edtAsk2
      Min = 1
      Position = 1
      TabOrder = 4
    end
    object udBid2: TUpDown
      Left = 145
      Top = 38
      Width = 16
      Height = 21
      Associate = edtBid2
      Min = 1
      Position = 1
      TabOrder = 5
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 186
    Width = 279
    Height = 72
    Align = alTop
    Caption = #51204#52404' '#52712#49548
    Color = clBtnFace
    ParentBackground = False
    ParentColor = False
    TabOrder = 4
    object Label7: TLabel
      Left = 68
      Top = 21
      Width = 34
      Height = 13
      Caption = #44148#49688' : '
    end
    object Label8: TLabel
      Left = 171
      Top = 20
      Width = 41
      Height = 13
      Caption = 'Inteval :'
    end
    object edtAllCnlQty: TEdit
      Left = 100
      Top = 16
      Width = 37
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 0
      Text = '10'
      OnKeyPress = edtAllCnlQtyKeyPress
    end
    object edtAllCnlInterval: TEdit
      Left = 213
      Top = 16
      Width = 37
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 1
      Text = '300'
      OnKeyPress = edtAllCnlQtyKeyPress
    end
    object Button3: TButton
      Tag = 1
      Left = 12
      Top = 40
      Width = 39
      Height = 22
      Caption = #49892' '#54665
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Tag = 2
      Left = 218
      Top = 43
      Width = 39
      Height = 22
      Caption = 'Logs'
      TabOrder = 3
      OnClick = Button1Click
    end
  end
  object CnlTimer: TTimer
    Enabled = False
    OnTimer = CnlTimerTimer
    Left = 168
    Top = 144
  end
end
