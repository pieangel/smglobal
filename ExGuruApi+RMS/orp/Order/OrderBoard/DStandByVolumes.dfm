object StandByVolumes: TStandByVolumes
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsSingle
  Caption = #51088#46041#49828#53457#51452#47928#49444#51221
  ClientHeight = 144
  ClientWidth = 387
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 14
    Top = 120
    Width = 156
    Height = 13
    Caption = '* '#44256#51221' = Min( '#44256#51221#49688#47049', '#51092#44256' )'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clPurple
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object ButtonOK: TButton
    Left = 324
    Top = 115
    Width = 57
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 0
    OnClick = ButtonOKClick
  end
  object GroupBox1: TGroupBox
    Left = 7
    Top = 4
    Width = 184
    Height = 109
    Caption = #51060#51061
    TabOrder = 1
    object edtProfitCount: TLabeledEdit
      Left = 8
      Top = 17
      Width = 25
      Height = 21
      EditLabel.Width = 12
      EditLabel.Height = 13
      EditLabel.Caption = #48264
      ImeName = 'Microsoft IME 2010'
      LabelPosition = lpRight
      TabOrder = 0
      Text = '3'
    end
    object udProfitCount: TUpDown
      Left = 33
      Top = 17
      Width = 15
      Height = 21
      Associate = edtProfitCount
      Max = 3
      Position = 3
      TabOrder = 1
    end
    object edtProfit1th: TEdit
      Left = 72
      Top = 17
      Width = 26
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 2
      Text = '3'
      OnKeyPress = edtProfitFixQtyKeyPress
    end
    object edtProfit2th: TEdit
      Left = 99
      Top = 17
      Width = 26
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 3
      Text = '5'
      OnKeyPress = edtProfitFixQtyKeyPress
    end
    object edtProfit3th: TLabeledEdit
      Left = 126
      Top = 17
      Width = 26
      Height = 21
      EditLabel.Width = 18
      EditLabel.Height = 13
      EditLabel.Caption = 'Tick'
      ImeName = 'Microsoft IME 2010'
      LabelPosition = lpRight
      TabOrder = 4
      Text = '7'
      OnKeyPress = edtProfitFixQtyKeyPress
    end
    object GroupBox2: TGroupBox
      Left = 4
      Top = 43
      Width = 109
      Height = 60
      Caption = #49688#47049
      TabOrder = 5
      object rdProfitDiv: TRadioButton
        Left = 6
        Top = 13
        Width = 44
        Height = 17
        Caption = #51092#44256
        TabOrder = 0
      end
      object edtProfitDivQty: TLabeledEdit
        Left = 57
        Top = 9
        Width = 25
        Height = 21
        EditLabel.Width = 4
        EditLabel.Height = 13
        EditLabel.Caption = '/'
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 1
        Text = '1'
        OnKeyPress = edtProfitFixQtyKeyPress
      end
      object udProfitDivQty: TUpDown
        Left = 82
        Top = 9
        Width = 15
        Height = 21
        Associate = edtProfitDivQty
        Min = 1
        Max = 3
        Position = 1
        TabOrder = 2
      end
      object rdProfitFix: TRadioButton
        Left = 6
        Top = 35
        Width = 44
        Height = 17
        Caption = #44256#51221
        TabOrder = 3
      end
      object edtProfitFixQty: TEdit
        Left = 56
        Top = 31
        Width = 26
        Height = 21
        ImeName = 'Microsoft IME 2010'
        TabOrder = 4
        Text = '1'
        OnKeyPress = edtProfitFixQtyKeyPress
      end
      object udProfitFixQty: TUpDown
        Left = 82
        Top = 31
        Width = 15
        Height = 21
        Associate = edtProfitFixQty
        Min = 1
        Position = 1
        TabOrder = 5
      end
    end
    object cbUseOneTimeProfit: TCheckBox
      Left = 119
      Top = 79
      Width = 56
      Height = 17
      Caption = #54620#48264#47564
      TabOrder = 6
    end
  end
  object GroupBox3: TGroupBox
    Left = 197
    Top = 3
    Width = 184
    Height = 110
    Caption = #49552#51208
    TabOrder = 2
    object edtLossCutCount: TLabeledEdit
      Left = 8
      Top = 17
      Width = 25
      Height = 21
      EditLabel.Width = 12
      EditLabel.Height = 13
      EditLabel.Caption = #48264
      ImeName = 'Microsoft IME 2010'
      LabelPosition = lpRight
      TabOrder = 0
      Text = '3'
    end
    object edtLossCut1th: TEdit
      Left = 72
      Top = 17
      Width = 26
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 1
      Text = '3'
      OnKeyPress = edtProfitFixQtyKeyPress
    end
    object edtLossCut2th: TEdit
      Left = 99
      Top = 17
      Width = 26
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 2
      Text = '5'
      OnKeyPress = edtProfitFixQtyKeyPress
    end
    object edtLossCut3th: TLabeledEdit
      Left = 126
      Top = 17
      Width = 26
      Height = 21
      EditLabel.Width = 18
      EditLabel.Height = 13
      EditLabel.Caption = 'Tick'
      ImeName = 'Microsoft IME 2010'
      LabelPosition = lpRight
      TabOrder = 3
      Text = '7'
      OnKeyPress = edtProfitFixQtyKeyPress
    end
    object GroupBox4: TGroupBox
      Left = 4
      Top = 44
      Width = 109
      Height = 60
      Caption = #49688#47049
      TabOrder = 4
      object rdLossCutDiv: TRadioButton
        Left = 6
        Top = 13
        Width = 44
        Height = 17
        Caption = #51092#44256
        TabOrder = 0
      end
      object edtLossCutDivQty: TLabeledEdit
        Left = 57
        Top = 9
        Width = 25
        Height = 21
        EditLabel.Width = 4
        EditLabel.Height = 13
        EditLabel.Caption = '/'
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 1
        Text = '1'
        OnKeyPress = edtProfitFixQtyKeyPress
      end
      object udLossCutDivQty: TUpDown
        Left = 82
        Top = 9
        Width = 15
        Height = 21
        Associate = edtLossCutDivQty
        Min = 1
        Max = 3
        Position = 1
        TabOrder = 2
      end
      object rdLossCutFix: TRadioButton
        Left = 6
        Top = 36
        Width = 44
        Height = 17
        Caption = #44256#51221
        TabOrder = 3
      end
      object edtLossCutFixQty: TEdit
        Left = 56
        Top = 32
        Width = 26
        Height = 21
        ImeName = 'Microsoft IME 2010'
        TabOrder = 4
        Text = '1'
        OnKeyPress = edtProfitFixQtyKeyPress
      end
      object udLossCutFixQty: TUpDown
        Left = 82
        Top = 32
        Width = 15
        Height = 21
        Associate = edtLossCutFixQty
        Min = 1
        Position = 1
        TabOrder = 5
      end
    end
    object udLossCutCount: TUpDown
      Left = 33
      Top = 17
      Width = 15
      Height = 21
      Associate = edtLossCutCount
      Max = 3
      Position = 3
      TabOrder = 5
    end
    object cbUseOneTimeLossCut: TCheckBox
      Left = 119
      Top = 80
      Width = 56
      Height = 17
      Caption = #54620#48264#47564
      TabOrder = 6
    end
  end
end
