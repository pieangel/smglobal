object Monitoring: TMonitoring
  Left = 0
  Top = 0
  Caption = 'Monitoring'
  ClientHeight = 264
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 188
    Top = 132
    Width = 8
    Height = 13
    Caption = '~'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 0
    Width = 299
    Height = 123
    TabOrder = 0
    object lbTitle: TLabel
      Left = 8
      Top = 11
      Width = 129
      Height = 13
      Caption = #50672#44208#49440#47932' '#48143' '#50808#44397#51064' '#49440#47932
    end
    object lbTime: TLabel
      Left = 226
      Top = 7
      Width = 66
      Height = 19
      Caption = '09:00:00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object sgFut: TStringGrid
      Left = 8
      Top = 32
      Width = 284
      Height = 82
      Ctl3D = False
      DefaultColWidth = 70
      DefaultRowHeight = 19
      DefaultDrawing = False
      RowCount = 4
      ParentCtl3D = False
      ScrollBars = ssNone
      TabOrder = 0
      OnDrawCell = sgFutDrawCell
      ColWidths = (
        70
        55
        52
        53
        48)
    end
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 129
    Width = 129
    Height = 17
    Caption = #50741#49496' 1'#48516#45936#51060#53440' '#49373#49457
    TabOrder = 1
    OnClick = CheckBox1Click
  end
  object edtAbove: TEdit
    Left = 143
    Top = 129
    Width = 39
    Height = 21
    ImeName = 'Microsoft IME 2010'
    TabOrder = 2
    Text = '0.2'
  end
  object edtBelow: TEdit
    Left = 204
    Top = 129
    Width = 37
    Height = 21
    ImeName = 'Microsoft IME 2010'
    TabOrder = 3
    Text = '2.0'
  end
  object sgCall: TStringGrid
    Left = 16
    Top = 156
    Width = 140
    Height = 99
    ColCount = 2
    Ctl3D = False
    DefaultColWidth = 60
    DefaultRowHeight = 17
    RowCount = 10
    FixedRows = 0
    ParentCtl3D = False
    TabOrder = 4
    RowHeights = (
      17
      17
      17
      17
      17
      17
      17
      17
      17
      17)
  end
  object sgPut: TStringGrid
    Left = 164
    Top = 156
    Width = 140
    Height = 99
    ColCount = 2
    Ctl3D = False
    DefaultColWidth = 60
    DefaultRowHeight = 17
    RowCount = 10
    FixedRows = 0
    ParentCtl3D = False
    TabOrder = 5
    RowHeights = (
      17
      17
      17
      17
      17
      17
      17
      17
      17
      17)
  end
  object Button1: TButton
    Left = 250
    Top = 129
    Width = 35
    Height = 21
    Caption = #51201#50857
    TabOrder = 6
    OnClick = Button1Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 384
    Top = 40
  end
end
