object OrpMainForm: TOrpMainForm
  Left = 0
  Top = 0
  Caption = 'KrGuru'#54644#50808'Api'
  ClientHeight = 96
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
    Top = 77
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
    ExplicitTop = 25
    ExplicitWidth = 250
  end
  object plInfo: TPanel
    Left = 0
    Top = 0
    Width = 256
    Height = 77
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 250
    ExplicitHeight = 25
    object pb: TPaintBox
      Left = 0
      Top = 0
      Width = 256
      Height = 77
      Align = alClient
      ExplicitLeft = 115
      ExplicitTop = 233
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
    object ExpertCtrl: TESApiExp
      Left = 253
      Top = 367
      Width = 49
      Height = 21
      TabOrder = 0
      ControlData = {00000100100500002C02000000000000}
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
  object Bitmap32: TBitmap32List
    Bitmaps = <
      item
        Bitmap.ResamplerClassName = 'TNearestResampler'
        Bitmap.Data = {
          6400000002000000000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
          000000FF000000FF}
      end
      item
        Bitmap.ResamplerClassName = 'TNearestResampler'
        Bitmap.Data = {
          3200000002000000CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCB473EFFCC483FFFCB473EFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCB473EFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF
          CC483FFFCC483FFFCC483FFFCC483FFFCC483FFFCC483FFF}
      end>
    Left = 192
    Top = 32
  end
end
