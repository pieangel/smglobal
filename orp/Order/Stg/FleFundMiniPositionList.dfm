object FrmFundMiniPosList: TFrmFundMiniPosList
  Left = 0
  Top = 0
  Caption = #54144#46300#48120#45768#51092#44256
  ClientHeight = 262
  ClientWidth = 200
  Color = clBtnFace
  Constraints.MaxWidth = 216
  Constraints.MinWidth = 200
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
  object p1: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object cbAccount: TComboBox
      Left = 1
      Top = 2
      Width = 103
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object Show0Net: TCheckBox
      Left = 163
      Top = 3
      Width = 30
      Height = 17
      Hint = #51092#44256' 0 '#51064' '#51333#47785' '#48372#51060#44592
      Caption = 'N'
      TabOrder = 1
      OnClick = Show0NetClick
    end
    object cbAcnt: TCheckBox
      Left = 111
      Top = 3
      Width = 43
      Height = 17
      Hint = #44228#51340#48324' '#51092#44256#48372#44592
      Caption = 'Acnt'
      TabOrder = 2
      OnClick = cbAcntClick
    end
  end
  object sgTop: TStringGrid
    Left = 0
    Top = 26
    Width = 200
    Height = 77
    Align = alTop
    ColCount = 2
    Ctl3D = False
    DefaultRowHeight = 18
    DefaultDrawing = False
    RowCount = 4
    FixedRows = 0
    ParentCtl3D = False
    TabOrder = 1
    OnDrawCell = sgTopDrawCell
    ColWidths = (
      64
      196)
  end
  object Panel1: TPanel
    Left = 0
    Top = 103
    Width = 200
    Height = 2
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
  end
  object sgBottom: TStringGrid
    Tag = 1
    Left = 0
    Top = 105
    Width = 200
    Height = 157
    Align = alClient
    ColCount = 3
    Ctl3D = False
    DefaultRowHeight = 18
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    ScrollBars = ssNone
    TabOrder = 3
    OnDrawCell = sgBottomDrawCell
    ColWidths = (
      52
      50
      92)
  end
  object RefreshTimer: TTimer
    OnTimer = RefreshTimerTimer
    Left = 80
    Top = 216
  end
end
