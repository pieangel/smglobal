object FrmPaveOrder: TFrmPaveOrder
  Left = 0
  Top = 0
  Caption = #51096#44628#50500#48372#49464
  ClientHeight = 205
  ClientWidth = 239
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
    Width = 239
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    object Button1: TButton
      Tag = 1
      Left = 6
      Top = 2
      Width = 24
      Height = 20
      Caption = '+'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Tag = -1
      Left = 34
      Top = 2
      Width = 24
      Height = 20
      Caption = #12641
      TabOrder = 1
      OnClick = Button1Click
    end
    object edtCount: TEdit
      Left = 61
      Top = 1
      Width = 22
      Height = 19
      ImeName = 'Microsoft IME 2010'
      ReadOnly = True
      TabOrder = 2
      Text = '1'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 25
    Width = 239
    Height = 160
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Caption = 'Panel1'
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
    inline PaveOrder1: TFramePaveOrder
      Tag = 1
      Left = 0
      Top = 0
      Width = 237
      Height = 158
      Align = alClient
      Color = clBtnFace
      Ctl3D = False
      ParentBackground = False
      ParentColor = False
      ParentCtl3D = False
      TabOrder = 0
      ExplicitWidth = 237
      ExplicitHeight = 158
      inherited plFloor: TPanel
        Width = 237
        Height = 158
        ExplicitWidth = 237
        ExplicitHeight = 158
        inherited plTop: TPanel
          Width = 237
          ExplicitWidth = 237
        end
        inherited Panel1: TPanel
          inherited edtLossVol: TLabeledEdit
            Text = '200'
          end
        end
        inherited Panel2: TPanel
          Width = 237
          ExplicitWidth = 237
        end
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 505
    Width = 239
    Height = 160
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Caption = 'Panel1'
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    inline PaveOrder4: TFramePaveOrder
      Tag = 4
      Left = 0
      Top = 0
      Width = 237
      Height = 158
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 237
      ExplicitHeight = 158
      inherited plFloor: TPanel
        Width = 237
        Height = 158
        ExplicitWidth = 237
        ExplicitHeight = 158
        inherited plTop: TPanel
          Width = 237
          ExplicitWidth = 237
        end
        inherited Panel2: TPanel
          Width = 237
          ExplicitWidth = 237
        end
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 345
    Width = 239
    Height = 160
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Caption = 'Panel1'
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 3
    inline PaveOrder3: TFramePaveOrder
      Tag = 3
      Left = 0
      Top = 0
      Width = 237
      Height = 158
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 237
      ExplicitHeight = 158
      inherited plFloor: TPanel
        Width = 237
        Height = 158
        ExplicitWidth = 237
        ExplicitHeight = 158
        inherited plTop: TPanel
          Width = 237
          ExplicitWidth = 237
        end
        inherited Panel2: TPanel
          Width = 237
          ExplicitWidth = 237
        end
      end
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 185
    Width = 239
    Height = 160
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Caption = 'Panel1'
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 4
    inline PaveOrder2: TFramePaveOrder
      Tag = 2
      Left = 0
      Top = 0
      Width = 237
      Height = 158
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 237
      ExplicitHeight = 158
      inherited plFloor: TPanel
        Width = 237
        Height = 158
        ExplicitWidth = 237
        ExplicitHeight = 158
        inherited plTop: TPanel
          Width = 237
          ExplicitWidth = 237
        end
        inherited Panel2: TPanel
          Width = 237
          ExplicitWidth = 237
        end
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 186
    Width = 239
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 50
      end>
  end
  object Timer1: TTimer
    Interval = 250
    OnTimer = Timer1Timer
    Left = 96
    Top = 56
  end
end
