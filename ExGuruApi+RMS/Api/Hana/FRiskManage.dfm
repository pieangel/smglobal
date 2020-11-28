object FrmRiskManage: TFrmRiskManage
  Left = 0
  Top = 0
  Caption = #54620#46020' '#44288#47532
  ClientHeight = 442
  ClientWidth = 592
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
  object plLeft: TPanel
    Left = 0
    Top = 0
    Width = 592
    Height = 442
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 596
    ExplicitHeight = 265
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 592
      Height = 35
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitWidth = 596
      DesignSize = (
        592
        35)
      object btnAllExe: TButton
        Left = 350
        Top = 5
        Width = 75
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = #51204#52404#49892#54665
        TabOrder = 0
        OnClick = btnAllExeClick
        ExplicitLeft = 354
      end
      object btnAllStop: TButton
        Left = 426
        Top = 5
        Width = 75
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = #51204#52404#54644#51228
        TabOrder = 1
        OnClick = btnAllStopClick
        ExplicitLeft = 430
      end
      object btnConfig: TButton
        Left = 505
        Top = 5
        Width = 54
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = #49444' '#51221
        TabOrder = 2
        ExplicitLeft = 509
      end
      object cb1Sec: TCheckBox
        Left = 7
        Top = 9
        Width = 84
        Height = 17
        Caption = '1'#52488#47560#45796#51312#54924
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object cbRealTime: TCheckBox
        Left = 106
        Top = 9
        Width = 60
        Height = 17
        Caption = #49892#49884#44036
        TabOrder = 4
      end
    end
    object Panel4: TPanel
      Left = 0
      Top = 311
      Width = 592
      Height = 131
      Align = alBottom
      BevelOuter = bvNone
      Constraints.MaxWidth = 592
      Constraints.MinWidth = 592
      TabOrder = 1
      object Label1: TLabel
        Left = 7
        Top = 6
        Width = 210
        Height = 13
        Caption = '*'#47196#49828#52983' '#54217#44032#50696#53441' '#45908#48660' '#53364#47533#49884' '#49444#51221#44032#45733
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clPurple
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
    end
    object Panel5: TPanel
      Left = 0
      Top = 35
      Width = 592
      Height = 276
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel5'
      TabOrder = 2
      ExplicitWidth = 596
      ExplicitHeight = 189
      object sgRisk: TStringGrid
        Left = 0
        Top = 0
        Width = 592
        Height = 276
        Align = alClient
        Ctl3D = False
        DefaultRowHeight = 19
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 2
        ParentCtl3D = False
        ScrollBars = ssVertical
        TabOrder = 0
        OnDblClick = sgRiskDblClick
        OnDrawCell = sgRiskDrawCell
        OnMouseDown = sgRiskMouseDown
        ExplicitHeight = 316
      end
      object cbAll: TCheckBox
        Left = 7
        Top = 1
        Width = 16
        Height = 17
        TabOrder = 1
        OnClick = cbAllClick
      end
    end
  end
  object Timer1: TTimer
    Enabled = False
    Left = 416
    Top = 72
  end
end
