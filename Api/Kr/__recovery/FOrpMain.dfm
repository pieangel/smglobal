object OrpMainForm: TOrpMainForm
  Left = 0
  Top = 0
  Caption = 'KrGuru'#54644#50808'Api'
  ClientHeight = 76
  ClientWidth = 256
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  Menu = DataModule1.MainMenu1
  OldCreateOrder = False
  Position = poMainFormCenter
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object MemoLog: TMemo
    Left = 0
    Top = 56
    Width = 337
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ImeName = 'Korean Input System (IME 2000)'
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 57
    Width = 256
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 150
      end
      item
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        Width = 50
      end>
  end
  object plInfo: TPanel
    Left = 0
    Top = 0
    Width = 256
    Height = 57
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object pb: TPaintBox
      Left = 0
      Top = 0
      Width = 256
      Height = 57
      Align = alClient
      ExplicitLeft = 115
      ExplicitTop = 233
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 280
    object Show1: TMenuItem
      Caption = 'Show'
      OnClick = Show1Click
    end
    object N26: TMenuItem
      Caption = '-'
    end
    object Exit2: TMenuItem
      Caption = 'Exit'
      OnClick = Exit2Click
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 160
    Top = 8
  end
end
