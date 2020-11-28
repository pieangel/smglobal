object SymbolDialog: TSymbolDialog
  Left = 430
  Top = 136
  BorderStyle = bsDialog
  Caption = #51333#47785#49440#53469
  ClientHeight = 301
  ClientWidth = 634
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
    Width = 634
    Height = 20
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
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
    Width = 634
    Height = 281
    ActivePage = tbFutures
    Align = alClient
    Style = tsFlatButtons
    TabOrder = 1
    OnChange = pcOptionsChange
    object tbFutures: TTabSheet
      Caption = #54644#50808#49440#47932
      object SymbolTab: TTabControl
        Left = 0
        Top = 0
        Width = 626
        Height = 249
        Align = alClient
        TabOrder = 0
        OnChange = SymbolTabChange
        object sgSymbol: TStringGrid
          Left = 4
          Top = 6
          Width = 618
          Height = 239
          Align = alClient
          ColCount = 9
          Ctl3D = False
          DefaultColWidth = 60
          DefaultRowHeight = 19
          FixedCols = 3
          RowCount = 2
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
          ParentCtl3D = False
          TabOrder = 0
          OnDblClick = sgSymbolDblClick
          OnDrawCell = sgSymbolDrawCell
          OnSelectCell = sgSymbolSelectCell
          ExplicitLeft = 5
          ExplicitTop = 7
          ColWidths = (
            41
            161
            46
            60
            60
            60
            60
            60
            60)
        end
      end
    end
    object tbOptions: TTabSheet
      Caption = #54644#50808#50741#49496
      ImageIndex = 1
      object OptTab: TTabControl
        Left = 0
        Top = 0
        Width = 626
        Height = 249
        Align = alClient
        TabOrder = 0
        OnChange = OptTabChange
        object Panel1: TPanel
          Left = 184
          Top = 6
          Width = 438
          Height = 239
          Align = alClient
          BevelOuter = bvSpace
          Caption = 'Panel1'
          TabOrder = 0
          object sgOpt: TStringGrid
            Tag = 2
            Left = 1
            Top = 1
            Width = 436
            Height = 237
            Align = alClient
            ColCount = 14
            Ctl3D = False
            DefaultColWidth = 30
            DefaultRowHeight = 19
            DefaultDrawing = False
            FixedCols = 0
            RowCount = 3
            FixedRows = 2
            ParentCtl3D = False
            TabOrder = 0
            OnDrawCell = sgOptDrawCell
            OnSelectCell = sgSymbolSelectCell
          end
        end
        object Panel2: TPanel
          Left = 4
          Top = 6
          Width = 180
          Height = 239
          Align = alLeft
          BevelOuter = bvSpace
          Caption = 'Panel1'
          TabOrder = 1
          object sgOptUnder: TStringGrid
            Tag = 1
            Left = 1
            Top = 1
            Width = 178
            Height = 237
            Align = alClient
            ColCount = 2
            Ctl3D = False
            DefaultRowHeight = 19
            DefaultDrawing = False
            FixedCols = 0
            RowCount = 2
            FixedRows = 0
            ParentCtl3D = False
            ScrollBars = ssVertical
            TabOrder = 0
            OnDblClick = sgOptUnderDblClick
            OnDrawCell = sgOptUnderDrawCell
            OnSelectCell = sgOptUnderSelectCell
            ColWidths = (
              132
              43)
          end
        end
      end
    end
  end
end
