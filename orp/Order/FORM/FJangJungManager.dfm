object FrmJangJungManager: TFrmJangJungManager
  Left = 0
  Top = 0
  Caption = #51109#51473' '#51452#47928' '#44288#47532
  ClientHeight = 224
  ClientWidth = 119
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
  object Label12: TLabel
    Left = 4
    Top = 96
    Width = 49
    Height = 13
    Alignment = taRightJustify
    Caption = #47588#46020' Shift'
  end
  object Label11: TLabel
    Left = 6
    Top = 123
    Width = 49
    Height = 13
    Alignment = taRightJustify
    Caption = #47588#49688' Shift'
  end
  object stBar: TStatusBar
    Left = 0
    Top = 205
    Width = 119
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 50
      end>
  end
  object CheckBox3: TCheckBox
    Left = 4
    Top = 67
    Width = 51
    Height = 17
    Caption = #49892#54665
    TabOrder = 1
    OnClick = CheckBox3Click
  end
  object edtBidShift: TEdit
    Left = 61
    Top = 120
    Width = 51
    Height = 21
    ImeName = 'Microsoft IME 2003'
    TabOrder = 2
    OnChange = edtBidShiftChange
    OnKeyPress = edtBidShiftKeyPress
  end
  object edtAskShift: TEdit
    Left = 61
    Top = 93
    Width = 51
    Height = 21
    ImeName = 'Microsoft IME 2003'
    TabOrder = 3
    OnChange = edtBidShiftChange
    OnKeyPress = edtBidShiftKeyPress
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 119
    Height = 56
    Align = alTop
    TabOrder = 4
    object BtnCohesionSymbol: TSpeedButton
      Left = 97
      Top = 30
      Width = 23
      Height = 19
      Caption = '...'
      OnClick = BtnCohesionSymbolClick
    end
    object cbSymbol: TComboBox
      Left = 4
      Top = 30
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
  object Button1: TButton
    Left = 8
    Top = 183
    Width = 39
    Height = 22
    Caption = 'Logs'
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 72
    Top = 183
    Width = 39
    Height = 22
    Caption = #45803#44592
    TabOrder = 6
    OnClick = Button2Click
  end
end
