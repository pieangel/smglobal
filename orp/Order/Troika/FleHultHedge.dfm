object FrmHultHedge: TFrmHultHedge
  Left = 0
  Top = 0
  Caption = #54736#53944#54756#51648
  ClientHeight = 123
  ClientWidth = 318
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 318
    Height = 27
    Align = alTop
    TabOrder = 0
    DesignSize = (
      318
      27)
    object cbAccount: TComboBox
      Left = 4
      Top = 2
      Width = 108
      Height = 21
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object cbStart: TCheckBox
      Left = 270
      Top = 4
      Width = 43
      Height = 17
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Run'
      TabOrder = 1
      OnClick = cbStartClick
    end
    object Button1: TButton
      Tag = 1
      Left = 169
      Top = 3
      Width = 24
      Height = 20
      Caption = '+'
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Tag = -1
      Left = 198
      Top = 3
      Width = 24
      Height = 20
      Caption = #12641
      TabOrder = 3
      OnClick = Button1Click
    end
    object edtCount: TEdit
      Left = 226
      Top = 3
      Width = 22
      Height = 21
      ImeName = 'Microsoft IME 2010'
      ReadOnly = True
      TabOrder = 4
      Text = '1'
    end
  end
  object stBar: TStatusBar
    Left = 0
    Top = 104
    Width = 318
    Height = 19
    Panels = <
      item
        Width = 150
      end
      item
        Width = 100
      end
      item
        Width = 100
      end>
  end
  object Panel2: TPanel
    Left = 0
    Top = 27
    Width = 318
    Height = 77
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 2
    object plMain1: TPanel
      Left = 0
      Top = 0
      Width = 318
      Height = 78
      Align = alTop
      TabOrder = 0
      inline fmHhedge1: TfmHhedge
        Left = 1
        Top = 1
        Width = 316
        Height = 76
        Align = alClient
        Color = clBtnFace
        Ctl3D = True
        ParentBackground = False
        ParentColor = False
        ParentCtl3D = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 316
        ExplicitHeight = 76
        inherited cbStart: TCheckBox
          OnClick = fmHhedge1CheckBox1Click
        end
        inherited Button1: TButton
          OnClick = fmHhedge1Button1Click
        end
        inherited Panel1: TPanel
          inherited edtOptQty: TEdit
            Top = 0
            ExplicitTop = 0
          end
        end
      end
    end
    object plMain2: TPanel
      Left = 0
      Top = 78
      Width = 318
      Height = 78
      Align = alTop
      TabOrder = 1
      inline fmHhedge2: TfmHhedge
        Left = 1
        Top = 1
        Width = 316
        Height = 76
        Align = alClient
        Color = clBtnFace
        Ctl3D = True
        ParentBackground = False
        ParentColor = False
        ParentCtl3D = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 316
        ExplicitHeight = 76
        inherited cbStart: TCheckBox
          Tag = 1
          OnClick = fmHhedge1CheckBox1Click
        end
        inherited Button1: TButton
          Tag = 1
          OnClick = fmHhedge1Button1Click
        end
      end
    end
    object plMain3: TPanel
      Left = 0
      Top = 156
      Width = 318
      Height = 78
      Align = alTop
      TabOrder = 2
      inline fmHhedge3: TfmHhedge
        Left = 1
        Top = 1
        Width = 316
        Height = 76
        Align = alClient
        Color = clBtnFace
        Ctl3D = True
        ParentBackground = False
        ParentColor = False
        ParentCtl3D = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 316
        ExplicitHeight = 76
        inherited cbStart: TCheckBox
          Tag = 2
          OnClick = fmHhedge1CheckBox1Click
        end
        inherited Button1: TButton
          Tag = 2
          OnClick = fmHhedge1Button1Click
        end
      end
    end
    object plMain4: TPanel
      Left = 0
      Top = 234
      Width = 318
      Height = 78
      Align = alTop
      TabOrder = 3
      inline fmHhedge4: TfmHhedge
        Left = 1
        Top = 1
        Width = 316
        Height = 76
        Align = alClient
        Color = clBtnFace
        Ctl3D = True
        ParentBackground = False
        ParentColor = False
        ParentCtl3D = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 316
        ExplicitHeight = 76
        inherited cbStart: TCheckBox
          Tag = 3
          OnClick = fmHhedge1CheckBox1Click
        end
        inherited Button1: TButton
          Tag = 3
          OnClick = fmHhedge1Button1Click
        end
      end
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 128
  end
end
