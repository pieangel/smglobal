object FrmAccountDeposit: TFrmAccountDeposit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #50696#53441#51092#44256' '#48143' '#51613#44144#44552
  ClientHeight = 139
  ClientWidth = 329
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
    Width = 329
    Height = 27
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 0
    DesignSize = (
      329
      27)
    object cbAccount: TComboBox
      Left = 6
      Top = 3
      Width = 127
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object Button1: TButton
      Left = 212
      Top = 3
      Width = 52
      Height = 21
      Caption = '+'#51613#44144#44552
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 267
      Top = 3
      Width = 58
      Height = 21
      Anchors = [akTop, akRight]
      Caption = #51312#54924
      TabOrder = 2
      OnClick = Button2Click
    end
    object cbDepositType: TComboBox
      Left = 136
      Top = 3
      Width = 59
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 3
      Text = #45804#47084
      OnChange = cbDepositTypeChange
      Items.Strings = (
        #45804#47084
        #50896#54868)
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 27
    Width = 329
    Height = 65
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 1
    object sgPL: TStringGrid
      Left = 2
      Top = 2
      Width = 325
      Height = 61
      Align = alClient
      ColCount = 4
      Ctl3D = False
      DefaultColWidth = 80
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 3
      FixedRows = 0
      ParentCtl3D = False
      TabOrder = 0
      OnDrawCell = sgPLDrawCell
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 92
    Width = 329
    Height = 46
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 2
    Visible = False
    object sgMargin: TStringGrid
      Left = 2
      Top = 2
      Width = 325
      Height = 42
      Align = alClient
      ColCount = 4
      Ctl3D = False
      DefaultColWidth = 80
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      FixedRows = 0
      ParentCtl3D = False
      TabOrder = 0
      OnDrawCell = sgPLDrawCell
    end
  end
end
