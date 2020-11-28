object FrmRiskManage: TFrmRiskManage
  Left = 0
  Top = 0
  Caption = #54620#46020' '#44288#47532
  ClientHeight = 624
  ClientWidth = 673
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
    Width = 673
    Height = 624
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 673
      Height = 35
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        673
        35)
      object Label1: TLabel
        Left = 64
        Top = 11
        Width = 241
        Height = 13
        Caption = '*'#47196#49828#52983' '#54217#44032#50696#53441' '#49472'(Cell)  '#45908#48660' '#53364#47533#51004#47196' '#49444#51221
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clPurple
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object SpeedButtonRightPanel: TSpeedButton
        Left = 623
        Top = 5
        Width = 19
        Height = 23
        AllowAllUp = True
        Anchors = [akRight]
        GroupIndex = 3
        Down = True
        Caption = #9660
        Flat = True
        OnClick = SpeedButtonRightPanelClick
        ExplicitLeft = 570
      end
      object SpeedButton1: TSpeedButton
        Left = 645
        Top = 5
        Width = 22
        Height = 23
        AllowAllUp = True
        Anchors = [akRight]
        GroupIndex = 1
        Down = True
        Caption = 'Log'
        Flat = True
        OnClick = SpeedButton1Click
        ExplicitLeft = 592
      end
      object btnAllExe: TButton
        Left = 501
        Top = 5
        Width = 56
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = #51204#52404#49892#54665
        TabOrder = 0
        OnClick = btnAllExeClick
      end
      object btnAllStop: TButton
        Tag = 1
        Left = 559
        Top = 5
        Width = 54
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = #51204#52404#54644#51228
        TabOrder = 1
        OnClick = btnAllExeClick
      end
      object cbDepType: TComboBox
        Left = 5
        Top = 8
        Width = 53
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ItemHeight = 13
        TabOrder = 2
        Text = #50896#54868
        OnChange = cbDepTypeChange
        Items.Strings = (
          #45804#47084
          #50896#54868)
      end
      object Button1: TButton
        Left = 391
        Top = 5
        Width = 54
        Height = 25
        Caption = #49440#53469#49892#54665
        TabOrder = 3
        OnClick = Button1Click
      end
    end
    object Panel4: TPanel
      Left = 0
      Top = 264
      Width = 673
      Height = 117
      Align = alBottom
      BevelOuter = bvNone
      Constraints.MinWidth = 620
      TabOrder = 1
      object Label2: TLabel
        Left = 65
        Top = 4
        Width = 54
        Height = 13
        Caption = #48372#50976' '#51092#44256' '
      end
      object Label3: TLabel
        Left = 246
        Top = 4
        Width = 63
        Height = 13
        Caption = #48120#52404#44208' '#51452#47928
      end
      object sgPos: TStringGrid
        Left = 7
        Top = 21
        Width = 174
        Height = 91
        ColCount = 3
        Ctl3D = False
        DefaultColWidth = 50
        DefaultRowHeight = 17
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 2
        ParentCtl3D = False
        ScrollBars = ssVertical
        TabOrder = 0
        OnDrawCell = sgPosDrawCell
      end
      object sgUnFill: TStringGrid
        Tag = 1
        Left = 191
        Top = 21
        Width = 174
        Height = 91
        ColCount = 3
        Ctl3D = False
        DefaultColWidth = 50
        DefaultRowHeight = 17
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 2
        ParentCtl3D = False
        ScrollBars = ssVertical
        TabOrder = 1
        OnDrawCell = sgPosDrawCell
      end
      object GroupBox1: TGroupBox
        Left = 371
        Top = 4
        Width = 296
        Height = 108
        Caption = #49892#54665#49444#51221
        TabOrder = 2
        object Label4: TLabel
          Left = 62
          Top = 83
          Width = 144
          Height = 13
          Caption = #47560#45796' '#51312#54924' ('#50696#53441#44552', '#49688#49688#47308' )'
        end
        object cbMarketLiq: TCheckBox
          Left = 8
          Top = 17
          Width = 153
          Height = 17
          Caption = #51204#52404#51092#44256' '#49884#51109#44032' '#52397#49328
          Checked = True
          State = cbChecked
          TabOrder = 0
          OnClick = cbMarketLiqClick
        end
        object cbNewOrdCnl: TCheckBox
          Tag = 1
          Left = 8
          Top = 37
          Width = 188
          Height = 17
          Caption = #50808#48512' '#49888#44508#51452#47928' '#48156#49373#49884' '#51088#46041#52712#49548
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = cbMarketLiqClick
        end
        object cbNewPosLiq: TCheckBox
          Tag = 2
          Left = 8
          Top = 58
          Width = 198
          Height = 17
          Caption = #50808#48512' '#49888#44508#54252#51648#49496' '#48156#49373#49884' '#51088#46041#52397#49328
          Checked = True
          State = cbChecked
          TabOrder = 2
          OnClick = cbMarketLiqClick
        end
        object cbInterval: TComboBox
          Left = 8
          Top = 80
          Width = 47
          Height = 21
          ImeName = 'Microsoft Office IME 2007'
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 3
          Text = '1'#52488
          OnChange = cbIntervalChange
          Items.Strings = (
            '1'#52488
            '3'#52488
            '5'#52488
            '10'#52488
            '15'#52488
            '30'#52488)
        end
        object cbPosQueryPer: TComboBox
          Left = 212
          Top = 80
          Width = 47
          Height = 21
          ImeName = 'Microsoft Office IME 2007'
          ItemHeight = 13
          ItemIndex = 2
          TabOrder = 4
          Text = '70%'
          Visible = False
          OnChange = cbPosQueryPerChange
          Items.Strings = (
            '50%'
            '60%'
            '70%'
            '80%'
            '90%')
        end
      end
    end
    object Panel5: TPanel
      Left = 0
      Top = 35
      Width = 673
      Height = 229
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel5'
      TabOrder = 2
      object sgRisk: TStringGrid
        Left = 0
        Top = 0
        Width = 673
        Height = 229
        Align = alClient
        ColCount = 9
        Ctl3D = False
        DefaultRowHeight = 19
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 2
        ParentCtl3D = False
        PopupMenu = PopupMenu1
        ScrollBars = ssVertical
        TabOrder = 0
        OnDblClick = sgRiskDblClick
        OnDrawCell = sgRiskDrawCell
        OnMouseDown = sgRiskMouseDown
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
    object Panel1: TPanel
      Left = 0
      Top = 381
      Width = 673
      Height = 243
      Align = alBottom
      BevelOuter = bvNone
      Caption = 'Panel1'
      TabOrder = 3
      object sgLog: TStringGrid
        Left = 0
        Top = 0
        Width = 673
        Height = 243
        Align = alClient
        ColCount = 2
        Ctl3D = False
        DefaultColWidth = 70
        DefaultRowHeight = 19
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
        ParentCtl3D = False
        TabOrder = 0
        ColWidths = (
          70
          567)
      end
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 416
    Top = 72
  end
  object tReq: TTimer
    Interval = 3000
    OnTimer = tReqTimer
    Left = 448
    Top = 72
  end
  object PopupMenu1: TPopupMenu
    Left = 304
    Top = 168
    object N1: TMenuItem
      Caption = #54620#46020#54644#51228
      OnClick = N1Click
    end
  end
end
