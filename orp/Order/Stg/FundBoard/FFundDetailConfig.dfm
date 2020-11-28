object FrmFund: TFrmFund
  Left = 0
  Top = 0
  Caption = #45796#44228#51340#49444#51221
  ClientHeight = 101
  ClientWidth = 274
  Color = clBtnFace
  DragKind = dkDock
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object sgFund: TStringGrid
    Left = 0
    Top = 21
    Width = 274
    Height = 80
    Align = alClient
    ColCount = 4
    Ctl3D = False
    DefaultRowHeight = 19
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    ParentCtl3D = False
    TabOrder = 0
    OnDrawCell = sgFundDrawCell
    OnMouseDown = sgFundMouseDown
    ExplicitWidth = 212
  end
  object plFund: TPanel
    Left = 0
    Top = 0
    Width = 274
    Height = 21
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 212
    object ComboBoAccount: TComboBox
      Left = 2
      Top = 0
      Width = 127
      Height = 21
      BevelInner = bvNone
      BevelOuter = bvNone
      Style = csDropDownList
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 0
      OnChange = ComboBoAccountChange
    end
  end
  object ApplicationEvents1: TApplicationEvents
    Left = 96
    Top = 8
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 128
    Top = 48
  end
end
