object FrmInterestConfig: TFrmInterestConfig
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #51333#47785#49444#51221
  ClientHeight = 342
  ClientWidth = 571
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonUpper: TSpeedButton
    Tag = 100
    Left = 535
    Top = 89
    Width = 28
    Height = 33
    Caption = #8593
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonUpperClick
  end
  object ButtonLower: TSpeedButton
    Tag = 200
    Left = 535
    Top = 128
    Width = 28
    Height = 33
    Caption = #8595
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonLowerClick
  end
  object ButtonToLeft: TSpeedButton
    Left = 248
    Top = 138
    Width = 34
    Height = 24
    Caption = #49325#51228
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ParentFont = False
    OnClick = ButtonToLeftClick
  end
  object ButtonToRight: TSpeedButton
    Left = 252
    Top = 89
    Width = 24
    Height = 24
    Caption = '>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonToRightClick
  end
  object Label5: TLabel
    Left = 8
    Top = 7
    Width = 81
    Height = 13
    AutoSize = False
    Caption = #51333#47785
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label6: TLabel
    Left = 290
    Top = 7
    Width = 65
    Height = 13
    AutoSize = False
    Caption = #49440#53469' '#51333#47785
    Color = clBtnFace
    ParentColor = False
  end
  object Label1: TLabel
    Left = 465
    Top = 224
    Width = 93
    Height = 13
    Caption = #8251' '#48324#52845' '#49688#51221' '#44032#45733
  end
  object Label2: TLabel
    Left = 257
    Top = 301
    Width = 105
    Height = 13
    Caption = #8251' '#47564#44592#44540#52376' '#51333#47785#51008' '
  end
  object Label3: TLabel
    Left = 476
    Top = 243
    Width = 83
    Height = 13
    Caption = '('#49464#44544#51088#44032' '#51201#45817')'
  end
  object Label4: TLabel
    Left = 257
    Top = 281
    Width = 297
    Height = 13
    Caption = #8251' '#51109#49884#44036' '#51217#49549' '#49345#53468' '#50976#51648#49884' '#50672#49549#50900#47932#51060' '#53952#47140#51656#49688#46020' '#51080#51020
  end
  object Label7: TLabel
    Left = 270
    Top = 319
    Width = 150
    Height = 13
    Caption = #50672#49549#50900#47932#51060' '#53952#47140#51656#49688#46020' '#51080#51020
  end
  object SymbolTab: TTabControl
    Left = 0
    Top = 23
    Width = 246
    Height = 312
    MultiLine = True
    TabOrder = 0
    TabPosition = tpLeft
    OnChange = SymbolTabChange
    object sgSymbol: TStringGrid
      Left = 4
      Top = 4
      Width = 238
      Height = 304
      Align = alClient
      ColCount = 3
      Ctl3D = False
      DefaultColWidth = 60
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
      ParentCtl3D = False
      TabOrder = 0
      OnDblClick = sgSymbolDblClick
      OnDrawCell = sgSymbol2DrawCell
      OnMouseDown = sgSymbolMouseDown
      ColWidths = (
        45
        146
        43)
    end
  end
  object sgSymbol2: TStringGrid
    Tag = 1
    Left = 287
    Top = 27
    Width = 238
    Height = 181
    ColCount = 3
    Ctl3D = False
    DefaultColWidth = 60
    DefaultRowHeight = 19
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 9
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
    ParentCtl3D = False
    TabOrder = 1
    OnDblClick = sgSymbol2DblClick
    OnDrawCell = sgSymbol2DrawCell
    OnMouseDown = sgSymbolMouseDown
    OnMouseUp = sgSymbol2MouseUp
    ColWidths = (
      45
      137
      52)
  end
  object ButtonCancel: TButton
    Left = 505
    Top = 309
    Width = 58
    Height = 25
    Caption = #52712#49548'(&C)'
    ModalResult = 2
    TabOrder = 2
    OnClick = ButtonCancelClick
  end
  object ButtonConfirm: TButton
    Left = 432
    Top = 309
    Width = 57
    Height = 25
    Caption = #54869#51064'(&O)'
    TabOrder = 3
    OnClick = ButtonConfirmClick
  end
  object RadioGroupMonth: TRadioGroup
    Left = 259
    Top = 218
    Width = 174
    Height = 57
    Caption = #50900#47932#49440#53469#44592#51456
    ItemIndex = 1
    Items.Strings = (
      #52572#44540#50900#47932
      #50672#49549#50900#47932'('#51204#51068#44144#47000#47049' '#44592#51456')')
    TabOrder = 4
  end
end
