object FrmStopOrderList: TFrmStopOrderList
  Left = 0
  Top = 0
  Caption = #49828#53457#51452#47928#45236#50669
  ClientHeight = 214
  ClientWidth = 425
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
    Width = 425
    Height = 26
    Align = alTop
    TabOrder = 0
    object cbAccount: TComboBox
      Left = 58
      Top = 2
      Width = 145
      Height = 21
      Style = csDropDownList
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object cbAcntType: TComboBox
      Left = 3
      Top = 2
      Width = 52
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = #44228#51340
      OnChange = cbAcntTypeChange
      Items.Strings = (
        #44228#51340
        #54144#46300)
    end
  end
  object sgStop: TStringGrid
    Left = 0
    Top = 26
    Width = 425
    Height = 188
    Align = alClient
    ColCount = 7
    Ctl3D = False
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    TabOrder = 1
    OnDrawCell = sgStopDrawCell
    OnMouseDown = sgStopMouseDown
    ColWidths = (
      87
      35
      64
      41
      66
      42
      64)
  end
  object sgStop2: TStringGrid
    Tag = 1
    Left = 0
    Top = 26
    Width = 425
    Height = 188
    Align = alClient
    ColCount = 8
    Ctl3D = False
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    TabOrder = 2
    Visible = False
    OnDrawCell = sgStopDrawCell
    OnMouseDown = sgStopMouseDown
    ExplicitLeft = 8
    ExplicitTop = 66
    ColWidths = (
      69
      52
      29
      57
      32
      52
      43
      64)
  end
end
