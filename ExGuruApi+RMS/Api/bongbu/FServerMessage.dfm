object FrmServerMessage: TFrmServerMessage
  Left = 0
  Top = 0
  Caption = #49436#48260#47700#49464#51648
  ClientHeight = 182
  ClientWidth = 493
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lvLog: TListView
    Left = 0
    Top = 0
    Width = 493
    Height = 182
    Align = alClient
    Columns = <
      item
        Caption = #49884#44033
        Width = 70
      end
      item
        Caption = #47700#49464#51648#53076#46300
        Width = 80
      end
      item
        Caption = #45236#50857
        Width = 300
      end>
    TabOrder = 0
    ViewStyle = vsReport
    OnDrawItem = lvLogDrawItem
  end
end
