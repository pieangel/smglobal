object FrmHnVHultManager: TFrmHnVHultManager
  Left = 0
  Top = 0
  Caption = #54736#53944#47784#45768#53552#47553
  ClientHeight = 316
  ClientWidth = 606
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
    Width = 606
    Height = 48
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 0
    ExplicitWidth = 622
    object CheckBox1: TCheckBox
      Left = 6
      Top = 5
      Width = 83
      Height = 17
      Caption = 'Hult Re Start'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = CheckBox1Click
    end
    object CheckBox2: TCheckBox
      Left = 95
      Top = 4
      Width = 145
      Height = 17
      Caption = #48152#54736#49332#50500#51080#51012' '#54736#53944#49552#51208
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = CheckBox2Click
    end
    object CheckBox3: TCheckBox
      Left = 245
      Top = 4
      Width = 171
      Height = 17
      Caption = '('#54736#53944'+'#48152#54736#53944')> X '#51068#46412#52397#49328
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = CheckBox3Click
    end
    object CheckBox4: TCheckBox
      Left = 418
      Top = 4
      Width = 157
      Height = 17
      Caption = #48152#50741#49552#51208#49884' '#54736#53944#44057#51060#52397#49328
      TabOrder = 3
      OnClick = CheckBox4Click
    end
    object CheckBox5: TCheckBox
      Left = 6
      Top = 27
      Width = 97
      Height = 17
      Caption = #48152#54736#53944' '#48152#52397#49328
      TabOrder = 4
      OnClick = CheckBox5Click
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 297
    Width = 606
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 50
      end>
    ExplicitWidth = 622
  end
  object Panel2: TPanel
    Left = 0
    Top = 48
    Width = 606
    Height = 167
    Align = alTop
    BevelOuter = bvLowered
    Caption = 'Panel2'
    TabOrder = 2
    ExplicitWidth = 622
    object sgData: TStringGrid
      Left = 1
      Top = 1
      Width = 604
      Height = 165
      Align = alClient
      ColCount = 9
      Ctl3D = False
      DefaultRowHeight = 17
      FixedCols = 0
      RowCount = 13
      ParentCtl3D = False
      TabOrder = 0
      ExplicitWidth = 620
    end
  end
  object sgLog: TStringGrid
    Left = 0
    Top = 215
    Width = 606
    Height = 82
    Align = alClient
    ColCount = 2
    Ctl3D = False
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    TabOrder = 3
    ExplicitWidth = 622
    ColWidths = (
      70
      515)
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 456
    Top = 88
  end
end
