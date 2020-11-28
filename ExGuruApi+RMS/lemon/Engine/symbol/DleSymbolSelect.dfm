object SymbolDialog: TSymbolDialog
  Left = 430
  Top = 136
  BorderStyle = bsDialog
  Caption = #51333#47785#49440#53469
  ClientHeight = 301
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 14
  object Panel3: TPanel
    Left = 0
    Top = 281
    Width = 633
    Height = 20
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    object Label1: TLabel
      Left = 87
      Top = 3
      Width = 304
      Height = 14
      Caption = #8251' '#45432#47049#49353' : '#51204#51068#44144#47000#47049#51060' '#47566#51008' '#51333#47785'(  HTS '#50752' '#53952#47540#49688' '#51080#51020' )'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object cbStay: TCheckBox
      Left = 3
      Top = 3
      Width = 70
      Height = 17
      Caption = #54868#47732#50976#51648
      TabOrder = 0
      OnClick = cbStayClick
    end
  end
  object pcOptions: TPageControl
    Left = 0
    Top = 0
    Width = 633
    Height = 281
    ActivePage = tbFutures
    Align = alClient
    Style = tsFlatButtons
    TabOrder = 1
    object tbFutures: TTabSheet
      Caption = #54644#50808#49440#47932
      object SymbolTab: TTabControl
        Left = 0
        Top = 0
        Width = 625
        Height = 249
        Align = alClient
        TabOrder = 0
        OnChange = SymbolTabChange
        object sgSymbol: TStringGrid
          Left = 4
          Top = 6
          Width = 617
          Height = 239
          Align = alClient
          ColCount = 9
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
          OnDrawCell = sgSymbolDrawCell
          OnSelectCell = sgSymbolSelectCell
          ColWidths = (
            45
            146
            43
            60
            60
            60
            60
            60
            73)
        end
      end
    end
  end
end
