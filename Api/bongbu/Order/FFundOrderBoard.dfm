object FundBoardForm: TFundBoardForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  Caption = 'Fund Order'
  ClientHeight = 699
  ClientWidth = 803
  Color = 14214638
  Constraints.MinHeight = 450
  Constraints.MinWidth = 170
  DefaultMonitor = dmDesktop
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #44404#47548#52404
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 12
  object PanelLeft: TPanel
    Left = 0
    Top = 0
    Width = 154
    Height = 699
    Align = alLeft
    BevelInner = bvLowered
    TabOrder = 0
    object PanelTicks: TPanel
      Left = 2
      Top = 436
      Width = 150
      Height = 261
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
    end
    object Panel2: TPanel
      Left = 2
      Top = 2
      Width = 150
      Height = 168
      Align = alTop
      BevelOuter = bvNone
      Caption = 'PanelUnFilled'
      TabOrder = 1
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 150
        Height = 23
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label4: TLabel
          Left = 7
          Top = 7
          Width = 36
          Height = 12
          Caption = #48120#52404#44208
        end
        object Button3: TButton
          Left = 86
          Top = 2
          Width = 60
          Height = 19
          Caption = #51068#44292#52712#49548
          TabOrder = 0
          OnClick = Button3Click
        end
      end
      object sgUnFill: TStringGrid
        Left = 0
        Top = 23
        Width = 150
        Height = 145
        Align = alClient
        ColCount = 4
        Ctl3D = False
        DefaultColWidth = 40
        DefaultRowHeight = 17
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 8
        FixedRows = 0
        ParentCtl3D = False
        ScrollBars = ssVertical
        TabOrder = 1
        OnDblClick = sgUnFillDblClick
        OnDrawCell = sgUnFillDrawCell
        OnMouseDown = sgUnFillMouseDown
        ColWidths = (
          23
          37
          22
          63)
      end
      object cbUnFillAll: TCheckBox
        Left = 4
        Top = 25
        Width = 16
        Height = 16
        TabOrder = 2
        OnClick = cbUnFillAllClick
      end
    end
    object Panel6: TPanel
      Left = 2
      Top = 170
      Width = 150
      Height = 205
      Align = alTop
      BevelOuter = bvNone
      Caption = 'PanelUnFilled'
      TabOrder = 2
      object Panel7: TPanel
        Left = 0
        Top = 0
        Width = 150
        Height = 23
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label5: TLabel
          Left = 7
          Top = 5
          Width = 24
          Height = 12
          Caption = #51092#44256
        end
        object Button4: TButton
          Left = 86
          Top = 2
          Width = 60
          Height = 19
          Caption = #51068#44292#52397#49328
          TabOrder = 0
          OnClick = Button4Click
        end
      end
      object sgUnSettle: TStringGrid
        Tag = 1
        Left = 0
        Top = 23
        Width = 150
        Height = 127
        Align = alTop
        ColCount = 4
        Ctl3D = False
        DefaultColWidth = 40
        DefaultRowHeight = 17
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 7
        FixedRows = 0
        ParentCtl3D = False
        ScrollBars = ssVertical
        TabOrder = 1
        OnDblClick = sgUnFillDblClick
        OnDrawCell = sgUnFillDrawCell
        OnMouseDown = sgUnFillMouseDown
        ColWidths = (
          23
          34
          24
          64)
      end
      object Panel8: TPanel
        Left = 0
        Top = 149
        Width = 150
        Height = 56
        Align = alBottom
        BevelOuter = bvNone
        Caption = 'Panel4'
        TabOrder = 2
        object sgAcntPL: TStringGrid
          Left = 0
          Top = 0
          Width = 150
          Height = 56
          Align = alClient
          ColCount = 2
          Ctl3D = False
          DefaultColWidth = 60
          DefaultRowHeight = 17
          DefaultDrawing = False
          RowCount = 3
          FixedRows = 0
          ParentCtl3D = False
          ScrollBars = ssNone
          TabOrder = 0
          OnDrawCell = sgAcntPLDrawCell
          ColWidths = (
            60
            86)
          RowHeights = (
            17
            17
            17)
        end
      end
      object cbUnSettleAll: TCheckBox
        Left = 4
        Top = 25
        Width = 16
        Height = 16
        TabOrder = 3
        OnClick = cbUnSettleAllClick
      end
    end
    object Panel4: TPanel
      Left = 2
      Top = 375
      Width = 150
      Height = 61
      Align = alTop
      BevelOuter = bvNone
      Caption = '1'
      TabOrder = 3
      object sgQuote: TStringGrid
        Left = 0
        Top = 24
        Width = 150
        Height = 37
        Align = alBottom
        ColCount = 2
        Ctl3D = False
        DefaultColWidth = 74
        DefaultRowHeight = 17
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 2
        ParentCtl3D = False
        ScrollBars = ssNone
        TabOrder = 0
        OnDrawCell = sgQuoteDrawCell
        ColWidths = (
          73
          74)
        RowHeights = (
          17
          17)
      end
      object edtMin: TLabeledEdit
        Left = 4
        Top = 3
        Width = 26
        Height = 20
        EditLabel.Width = 24
        EditLabel.Height = 12
        EditLabel.Caption = #48516#51204
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpRight
        TabOrder = 1
        Text = '1'
        OnKeyPress = edtPrfTickKeyPress
      end
      object Button2: TButton
        Left = 109
        Top = 2
        Width = 37
        Height = 19
        Caption = #51201#50857
        TabOrder = 2
        OnClick = Button2Click
      end
    end
  end
  object PanelMain: TPanel
    Left = 154
    Top = 0
    Width = 495
    Height = 699
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object PanelTop: TPanel
      Left = 0
      Top = 0
      Width = 495
      Height = 140
      Align = alTop
      BevelInner = bvLowered
      TabOrder = 0
      DesignSize = (
        495
        140)
      object SpeedButtonPrefs: TSpeedButton
        Left = 185
        Top = 75
        Width = 37
        Height = 53
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          04000000000080000000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555777555
          5555555555000757755555575500005007555570058880000075570870088078
          007555787887087777755550880FF0800007708080888F7088077088F0708F78
          88077000F0778080005555508F0008800755557878FF88777075570870080088
          0755557075888070755555575500075555555555557775555555}
        Visible = False
      end
      object Label1: TLabel
        Left = 6
        Top = 9
        Width = 24
        Height = 12
        Caption = #51333#47785
      end
      object sbtnActOrdQry: TSpeedButton
        Left = 481
        Top = 9
        Width = 63
        Height = 21
        Caption = #51452#47928#51312#54924
        Visible = False
        OnClick = sbtnActOrdQryClick
      end
      object sbtnPosQry: TSpeedButton
        Left = 477
        Top = 27
        Width = 63
        Height = 21
        Caption = #51092#44256#51312#54924
        Visible = False
        OnClick = sbtnPosQryClick
      end
      object SpeedButton7: TSpeedButton
        Left = 369
        Top = 25
        Width = 35
        Height = 21
        Caption = #51200#51109
        Visible = False
      end
      object Label2: TLabel
        Left = 6
        Top = 29
        Width = 24
        Height = 12
        Caption = #54144#46300
      end
      object SpeedButton1: TSpeedButton
        Left = 102
        Top = 48
        Width = 31
        Height = 21
        Caption = '1'
        OnClick = SpeedButton1Click
        OnMouseDown = SpeedButton1MouseDown
      end
      object SpeedButton2: TSpeedButton
        Left = 134
        Top = 48
        Width = 31
        Height = 21
        Caption = '2'
        OnClick = SpeedButton1Click
        OnMouseDown = SpeedButton1MouseDown
      end
      object SpeedButton3: TSpeedButton
        Left = 166
        Top = 48
        Width = 31
        Height = 21
        Caption = '3'
        OnClick = SpeedButton1Click
        OnMouseDown = SpeedButton1MouseDown
      end
      object SpeedButton4: TSpeedButton
        Left = 198
        Top = 48
        Width = 31
        Height = 21
        Caption = '4'
        OnClick = SpeedButton1Click
        OnMouseDown = SpeedButton1MouseDown
      end
      object SpeedButton5: TSpeedButton
        Left = 229
        Top = 48
        Width = 31
        Height = 21
        Caption = '5'
        OnClick = SpeedButton1Click
        OnMouseDown = SpeedButton1MouseDown
      end
      object btnClearQty: TSpeedButton
        Left = 260
        Top = 48
        Width = 67
        Height = 21
        Caption = #51092#44256'(0)'
        Visible = False
      end
      object SpeedButtonLeftPanel: TSpeedButton
        Left = 4
        Top = 47
        Width = 29
        Height = 21
        AllowAllUp = True
        GroupIndex = 1
        Down = True
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000000000000000000000010000000100004A004A006200
          6200780178009F019F00BC01BC00D301D300E200E200EF00EF00F700F700FB00
          FB00FD00FD00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FD00FD00FC00FC00FA00FA00F701F700F202F200EC03
          EC00E305E300D708D700C60BC600AF11AF008F188F007E1D7E006C226C006125
          6100572857004C2C4C0040304000353535003636360037373700383838003939
          39003A3A3A003B3B3B003C3C3C003D3D3D003E3E3E003F3F3F00404040004141
          4100424242004343430044444400454545004646460047474700484848004949
          49004A4A4A004B4B4B004C4C4C004D4D4D004E4E4E004F4F4F00505050005151
          5100525252005353530054545400555555005656560057575700585858005959
          59005A5A5A005B5B5B005C5C5C005D5D5D005E5E5E005F5F5F00606060006161
          6100626262006363630064646400656565006666660067676700686868006969
          69006A6A6A006B6B6B006C6C6C006D6D6D006E6E6E006F6F6F00707070007171
          7100727272007373730074747400757575007676760077777700787878007979
          79007A7A7A007B7B7B007C7C7C007D7D7D007E7E7E007F7F7F00808080008181
          8100828282008383830084848400858585008686860087878700888888008989
          89008A8A8A008B8B8B008C8C8C008D8D8D008E8E8E008F8F8F00909090009191
          9100929292009393930094949400959595009696960097979700989898009999
          99009A9A9A009B9B9B009C9C9C009D9D9D009E9E9E009F9F9F00A0A0A000A1A1
          A100A2A2A200A3A3A300A4A4A400A5A5A500A6A6A600A7A7A700A8A8A800A9A9
          A900AAAAAA00ABABAB00ACACAC00ADADAD00AEAEAE00AFAFAF00B0B0B000B1B1
          B100B2B2B200B3B3B300B4B4B400B5B5B500B6B6B600B7B7B700BABEBC00BEC5
          C100C1CCC500C8D6CD00CDDED400D2E4D900D7EADF00DCEEE300E0F2E700E7F6
          EC00EEF9F100F2FBF500F5FBF700F7FCF800F9FDFA00FAFDFB00FBFDFB00FBFD
          FC00F9FDFA00F6FCF800F3FBF600ECFAF100E7F8ED00E4F7EB00DFF6E800DAF5
          E400D6F4E100D2F2DD00CEF1DA00CBF0D700C7EFD500C3EED100BEECCC00B9EA
          C900B1E8C400A9E6BE009FE3B70095E0B0008CDDA7007FD99F0073D596006BD3
          8F0063D089005DCE820058CD7F0051CB7B004AC9770044C872003DC66D0037C4
          68002FBF61002DBD5D002CBA59002AB9560028B7510026B74C0024B6480022B4
          410020B23B001DB2360017B22E0011B127000DB120000BB11C000AB01B0009AB
          190009A518000A8F1700097C1300086F100007680E00076A0E001515151515FE
          FEFFFFFEFE1515151515151515FEFEFBF8F8F8F8FBFEFE1515151515FFFCF7F8
          F8F8F8F8F8F8FCFE151515FFFBF4F5F7F8F8F8F8F8F8F8FCFE1515FFF0F1F4F7
          E3C2D1F3F8F8F8F8FE15FDF2EBF0F5E4C5C9DDF6F8F8F8F8FBFEFDEDEAEFE4CB
          C9DEF8F8F8F8F8F8F9FEFCE9E9DECCC9CAD6D8D8D8D8D8F8F8FEFBE4E6D5C9C9
          C9C9C9C9C9C9C9F8F8FFFBE1E2E6D9C9C9DCE4E3E4E4E4F5F8FEFBE3DCE8E9DB
          C9CEE1EFF0F0F1F5FAFE15F2D8DFEAE9DBC9C5E7F0F1F3F4FB1515F2E1D2DFE9
          E9DBD8E9EDEFF0F4FB151515F2DFD0DAE1E5E6E6E6E9F0FC1515151515F2F2DA
          D3D8DBDDE1EDED1515151515151515EEF2F2F2F2F11515151515}
        OnClick = SpeedButtonLeftPanelClick
      end
      object SpeedButtonRightPanel: TSpeedButton
        Left = 464
        Top = 47
        Width = 25
        Height = 20
        AllowAllUp = True
        GroupIndex = 3
        Down = True
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000000000000000000000010000000100004A004A006200
          6200780178009F019F00BC01BC00D301D300E200E200EF00EF00F700F700FB00
          FB00FD00FD00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FD00FD00FC00FC00FA00FA00F701F700F202F200EC03
          EC00E305E300D708D700C60BC600AF11AF008F188F007E1D7E006C226C006125
          6100572857004C2C4C0040304000353535003636360037373700383838003939
          39003A3A3A003B3B3B003C3C3C003D3D3D003E3E3E003F3F3F00404040004141
          4100424242004343430044444400454545004646460047474700484848004949
          49004A4A4A004B4B4B004C4C4C004D4D4D004E4E4E004F4F4F00505050005151
          5100525252005353530054545400555555005656560057575700585858005959
          59005A5A5A005B5B5B005C5C5C005D5D5D005E5E5E005F5F5F00606060006161
          6100626262006363630064646400656565006666660067676700686868006969
          69006A6A6A006B6B6B006C6C6C006D6D6D006E6E6E006F6F6F00707070007171
          7100727272007373730074747400757575007676760077777700787878007979
          79007A7A7A007B7B7B007C7C7C007D7D7D007E7E7E007F7F7F00808080008181
          8100828282008383830084848400858585008686860087878700888888008989
          89008A8A8A008B8B8B008C8C8C008D8D8D008E8E8E008F8F8F00909090009191
          9100929292009393930094949400959595009696960097979700989898009999
          99009A9A9A009B9B9B009C9C9C009D9D9D009E9E9E009F9F9F00A0A0A000A1A1
          A100A2A2A200A3A3A300A4A4A400A5A5A500A6A6A600A7A7A700A8A8A800A9A9
          A900AAAAAA00ABABAB00ACACAC00ADADAD00AEAEAE00B3B3B300BFC1BF00C8CC
          C900D0D5D200D7DDD900DEE6E100E6EDE800ECF3EE00F1F7F300F5FAF600F7FB
          F900F9FCFA00FBFDFB00FBFDFC00FBFDFC00F9FDFA00F6FCF800F4FBF600F0FA
          F300ECFAF100E9F9EF00E6F8ED00E2F7EA00DDF6E700D7F4E300D3F3E000D0F2
          DD00CEF1DB00CCF1D900C9EFD600C0EDCF00B9EBC900ADE7C000A3E4B80098E0
          AF008DDDA50085DAA0007DD89A0075D694006DD38F0067D18B0060CF84005BCE
          800055CC7B004DCA780047C8750042C672003DC46E0039C36B0036C2680033C0
          640030BE61002EBC5C002CBA590029B9550027B8510027B74E0025B5490023B5
          440023B3420022B13D0020B03B001EB1360019B2310016B32D0012B327000EB4
          21000BB41D000AB41B0009B31A0009B0190009AD19000AA318000A9717000A8C
          1700097D14000872120007680E0006640D0006650D0007690F001515151515FD
          FDFFFFFDFD1515151515151515FDFDF9F5F4F4F5F8FCFC1515151515FFFAF2F4
          F4F5F4F4F4F4FAFD151515FFF9EFF0F2F5F5F5F5F5F4F4FAFE1515FFE8E9EFF2
          EDC6C2D9F5F5F4F4FE15FBECE3E9F1F3F1D1BCBFDAF5F5F4F8FDFBE4E1E7F1F4
          F2F5D2BCBFDAF5F4F6FDFADFDFCACCCCCCCDCDBEBCC1D6F4F4FEF9D9DCBCBCBC
          BCBCBCBCBCBCCEF3F4FFF9D6D7D6D5D5D5D7D2BBBCD0E7F0F5FDF9D8D0DEE0DE
          DED5C4BCD1E8EBF0F7FD15ECCDD3E1E0DAB9BCD1E8E9EEEFF91515ECD6C8D3DF
          DECDCFE1E5E7E9EEF9151515ECD3C6CFD6DADCDBDBDFE8FA1515151515ECECCF
          C9CDCFD1D6E4E41515151515151515E7ECECECECEA1515151515}
        OnClick = SpeedButtonRightPanelClick
      end
      object Label11: TLabel
        Left = 35
        Top = 52
        Width = 24
        Height = 12
        Caption = #45800#50948
      end
      object btnAbleNet: TSpeedButton
        Left = 296
        Top = 48
        Width = 110
        Height = 21
        AllowAllUp = True
        GroupIndex = 2
        Caption = #52404#44208#46108#51092#44256'(100)'
        OnClick = btnAbleNetClick
      end
      object SpeedButton8: TSpeedButton
        Left = 349
        Top = 2
        Width = 63
        Height = 21
        Caption = #45796#44228#51340#44288#47532
        OnClick = SpeedButton8Click
      end
      object SpeedButton15: TSpeedButton
        Left = 412
        Top = 116
        Width = 77
        Height = 18
        AllowAllUp = True
        Caption = #51333#47785#49444#51221
        Flat = True
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          04000000000080000000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555777555
          5555555555000757755555575500005007555570058880000075570870088078
          007555787887087777755550880FF0800007708080888F7088077088F0708F78
          88077000F0778080005555508F0008800755557878FF88777075570870080088
          0755557075888070755555575500075555555555557775555555}
        OnClick = SpeedButton15Click
      end
      object SpeedButton14: TSpeedButton
        Tag = 7
        Left = 357
        Top = 116
        Width = 48
        Height = 19
        AllowAllUp = True
        GroupIndex = 2
        OnClick = SpeedButton17Click
      end
      object SpeedButton13: TSpeedButton
        Tag = 6
        Left = 306
        Top = 116
        Width = 48
        Height = 19
        AllowAllUp = True
        GroupIndex = 2
        OnClick = SpeedButton17Click
      end
      object SpeedButton12: TSpeedButton
        Tag = 5
        Left = 256
        Top = 116
        Width = 48
        Height = 19
        AllowAllUp = True
        GroupIndex = 2
        OnClick = SpeedButton17Click
      end
      object SpeedButton11: TSpeedButton
        Tag = 4
        Left = 206
        Top = 116
        Width = 48
        Height = 19
        AllowAllUp = True
        GroupIndex = 2
        OnClick = SpeedButton17Click
      end
      object SpeedButton10: TSpeedButton
        Tag = 3
        Left = 156
        Top = 116
        Width = 48
        Height = 19
        AllowAllUp = True
        GroupIndex = 2
        OnClick = SpeedButton17Click
      end
      object SpeedButton9: TSpeedButton
        Tag = 2
        Left = 106
        Top = 116
        Width = 48
        Height = 19
        AllowAllUp = True
        GroupIndex = 2
        OnClick = SpeedButton17Click
      end
      object SpeedButton16: TSpeedButton
        Tag = 1
        Left = 56
        Top = 116
        Width = 48
        Height = 19
        AllowAllUp = True
        GroupIndex = 2
        OnClick = SpeedButton17Click
      end
      object SpeedButton17: TSpeedButton
        Left = 6
        Top = 116
        Width = 48
        Height = 19
        AllowAllUp = True
        GroupIndex = 2
        OnClick = SpeedButton17Click
      end
      object SpeedMiddle: TSpeedButton
        Left = 410
        Top = 47
        Width = 50
        Height = 21
        AllowAllUp = True
        Anchors = [akTop, akRight]
        GroupIndex = 4
        Down = True
        Caption = #8595#51333#47785
        Flat = True
        OnClick = SpeedMiddleClick
      end
      object ComboBoAccount: TComboBox
        Left = 35
        Top = 26
        Width = 89
        Height = 20
        BevelInner = bvNone
        BevelOuter = bvNone
        Style = csDropDownList
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ItemHeight = 12
        ParentCtl3D = False
        TabOrder = 0
        OnChange = ComboBoAccountChange
      end
      object Button1: TButton
        Left = 108
        Top = 4
        Width = 20
        Height = 19
        Caption = '..'
        TabOrder = 1
        OnClick = Button1Click
      end
      object Edit1: TEdit
        Left = 130
        Top = 4
        Width = 214
        Height = 18
        Ctl3D = False
        ImeName = 'Microsoft Office IME 2007'
        ParentCtl3D = False
        TabOrder = 2
      end
      object cbSymbol: TComboBox
        Left = 35
        Top = 4
        Width = 72
        Height = 20
        BevelInner = bvNone
        BevelOuter = bvNone
        Style = csDropDownList
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ItemHeight = 12
        ParentCtl3D = False
        TabOrder = 3
        OnChange = cbSymbolChange
      end
      object edtOrderQty: TEdit
        Left = 60
        Top = 48
        Width = 27
        Height = 20
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 4
        Text = '1'
        OnChange = edtOrderQtyChange
      end
      object UpDown1: TUpDown
        Left = 87
        Top = 48
        Width = 15
        Height = 20
        Associate = edtOrderQty
        Min = 1
        Max = 1000
        Position = 1
        TabOrder = 5
      end
      object edtTmpQty: TEdit
        Left = 142
        Top = 22
        Width = 41
        Height = 20
        BorderStyle = bsNone
        Color = clYellow
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 6
        Visible = False
        OnExit = edtTmpQtyExit
        OnKeyPress = edtPrfTickKeyPress
        OnMouseDown = edtTmpQtyMouseDown
      end
      object edtPw: TEdit
        Left = 323
        Top = 25
        Width = 41
        Height = 18
        Ctl3D = False
        ImeName = 'Microsoft IME 2010'
        ParentCtl3D = False
        PasswordChar = '*'
        TabOrder = 7
        Visible = False
      end
      object sgSymbolPL: TStringGrid
        Left = 4
        Top = 72
        Width = 402
        Height = 41
        ColCount = 6
        Ctl3D = False
        DefaultRowHeight = 19
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
        ParentCtl3D = False
        TabOrder = 8
        OnDrawCell = sgSymbolPLDrawCell
        ColWidths = (
          76
          39
          39
          78
          83
          80)
      end
      object cbAcntLisk: TCheckBox
        Left = 412
        Top = 75
        Width = 77
        Height = 17
        Caption = #49552#51208'('#54217#44032')'
        TabOrder = 9
        OnClick = cbAcntLiskClick
      end
      object edtOpenLiskAmt: TAlignedEdit
        Left = 410
        Top = 93
        Width = 79
        Height = 20
        ImeName = 'Microsoft Office IME 2007'
        MaxLength = 21
        TabOrder = 10
        OnChange = edtOpenLiskAmtChange
        OnKeyPress = edtOpenLiskAmtKeyPress
        Alignment = clRight
        AlignType = atNumber
      end
    end
    object Panel1: TPanel
      Left = 0
      Top = 676
      Width = 495
      Height = 23
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object plAllLiq: TPanel
        Tag = 5
        Left = 2
        Top = 1
        Width = 95
        Height = 19
        Caption = #51204#51333#47785#52397#49328'(F5)'
        Color = clWhite
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = #44404#47548#52404
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        OnClick = plAllLiqClick
        OnMouseDown = plAllLiqMouseDown
        OnMouseUp = plAllLiqMouseUp
      end
      object plthisLiq: TPanel
        Tag = 8
        Left = 98
        Top = 1
        Width = 95
        Height = 19
        Caption = #54788#51333#47785#52397#49328'(F8)'
        Color = clWhite
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = #44404#47548#52404
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 1
        OnClick = plAllLiqClick
        OnMouseDown = plAllLiqMouseDown
        OnMouseUp = plAllLiqMouseUp
      end
      object plAllCnl: TPanel
        Tag = 6
        Left = 303
        Top = 1
        Width = 95
        Height = 19
        Caption = #51204#51333#47785#52712#49548'(F6)'
        Color = 11337686
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = #44404#47548#52404
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 2
        OnClick = plAllLiqClick
        OnMouseDown = plAllLiqMouseDown
        OnMouseUp = plAllLiqMouseUp
      end
      object plthisCnl: TPanel
        Tag = 7
        Left = 399
        Top = 1
        Width = 95
        Height = 19
        Caption = #54788#51333#47785#52712#49548'(F7)'
        Color = 11337686
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = #44404#47548#52404
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 3
        OnClick = plAllLiqClick
        OnMouseDown = plAllLiqMouseDown
        OnMouseUp = plAllLiqMouseUp
      end
    end
  end
  object PanelRight: TPanel
    Left = 649
    Top = 0
    Width = 154
    Height = 699
    Align = alRight
    BevelInner = bvLowered
    TabOrder = 2
    object PanelOrderList: TPanel
      Left = 2
      Top = 2
      Width = 150
      Height = 695
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 150
        Height = 329
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object sgInterest: TStringGrid
          Left = 1
          Top = 2
          Width = 148
          Height = 109
          ColCount = 3
          Ctl3D = False
          DefaultColWidth = 48
          DefaultRowHeight = 17
          DefaultDrawing = False
          RowCount = 6
          ParentCtl3D = False
          ScrollBars = ssVertical
          TabOrder = 0
          OnDrawCell = sgInterestDrawCell
          OnMouseDown = sgInterestMouseDown
          OnSelectCell = sgInterestSelectCell
          RowHeights = (
            17
            17
            17
            17
            17
            17)
        end
        object sgInfo: TStringGrid
          Left = 1
          Top = 140
          Width = 148
          Height = 181
          ColCount = 2
          Ctl3D = False
          DefaultColWidth = 72
          DefaultRowHeight = 17
          DefaultDrawing = False
          RowCount = 10
          FixedRows = 0
          ParentCtl3D = False
          ScrollBars = ssVertical
          TabOrder = 1
          OnDrawCell = sgInfoDrawCell
          ColWidths = (
            67
            79)
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
        object stSymbolName: TStaticText
          AlignWithMargins = True
          Left = 1
          Top = 114
          Width = 147
          Height = 27
          Alignment = taCenter
          AutoSize = False
          BevelInner = bvNone
          BevelKind = bkSoft
          BevelOuter = bvNone
          BorderStyle = sbsSingle
          Color = clBtnShadow
          ParentColor = False
          TabOrder = 2
        end
      end
      object Panel9: TPanel
        Left = 0
        Top = 329
        Width = 150
        Height = 366
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel9'
        TabOrder = 1
        object PageControl1: TPageControl
          Left = 0
          Top = 0
          Width = 150
          Height = 366
          ActivePage = TabSheet1
          Align = alClient
          TabOrder = 0
          object TabSheet1: TTabSheet
            Caption = #52397#49328
            object Panel11: TPanel
              Left = 0
              Top = 0
              Width = 142
              Height = 338
              Align = alClient
              BevelOuter = bvNone
              Color = 14214638
              ParentBackground = False
              TabOrder = 0
              object GroupBox1: TGroupBox
                Left = 0
                Top = 160
                Width = 142
                Height = 42
                Caption = 'STOP '#51452#47928
                TabOrder = 0
                object Label8: TLabel
                  Left = 32
                  Top = 20
                  Width = 42
                  Height = 12
                  Caption = #48276#50948' '#177
                end
                object UpDown2: TUpDown
                  Left = 120
                  Top = 14
                  Width = 16
                  Height = 20
                  Associate = edtStopTick
                  Min = -10
                  Max = 10
                  Position = 1
                  TabOrder = 0
                end
                object edtStopTick: TAlignedEdit
                  Tag = 3
                  Left = 80
                  Top = 14
                  Width = 40
                  Height = 20
                  ImeName = 'Microsoft Office IME 2007'
                  TabOrder = 1
                  Text = '1'
                  OnChange = edtLiqTickChange
                  OnKeyPress = edtPrfTickKeyPress
                  Alignment = clRight
                  AlignType = atNumber
                end
              end
              object GroupBox3: TGroupBox
                Left = 0
                Top = 3
                Width = 142
                Height = 153
                Caption = #52404#44208#49884' '#51060#51061'/'#49552#49892#49444#51221
                TabOrder = 1
                object cbPrfLiquid: TCheckBox
                  Tag = 1
                  Left = 7
                  Top = 21
                  Width = 71
                  Height = 17
                  Caption = #51060#51061#49892#54788
                  TabOrder = 0
                  OnClick = cbPrfLiquidClick
                end
                object cbLosLiquid: TCheckBox
                  Left = 7
                  Top = 42
                  Width = 71
                  Height = 17
                  Caption = #49552#49892#51228#54620
                  TabOrder = 2
                  OnClick = cbPrfLiquidClick
                end
                object udPrfTick: TUpDown
                  Left = 120
                  Top = 18
                  Width = 16
                  Height = 20
                  Associate = edtPrfTick
                  Max = 1000
                  Position = 5
                  TabOrder = 1
                end
                object udLosTick: TUpDown
                  Left = 120
                  Top = 39
                  Width = 16
                  Height = 20
                  Associate = edtLosTick
                  Max = 1000
                  Position = 5
                  TabOrder = 3
                end
                object edtPrfTick: TAlignedEdit
                  Left = 80
                  Top = 18
                  Width = 40
                  Height = 20
                  ImeName = 'Microsoft Office IME 2007'
                  TabOrder = 4
                  Text = '5'
                  OnChange = edtLiqTickChange
                  OnKeyPress = edtPrfTickKeyPress
                  Alignment = clRight
                  AlignType = atNumber
                end
                object edtLosTick: TAlignedEdit
                  Tag = 1
                  Left = 80
                  Top = 39
                  Width = 40
                  Height = 20
                  ImeName = 'Microsoft Office IME 2007'
                  TabOrder = 5
                  Text = '5'
                  OnChange = edtLiqTickChange
                  OnKeyPress = edtPrfTickKeyPress
                  Alignment = clRight
                  AlignType = atNumber
                end
                object GroupBox4: TGroupBox
                  Left = 4
                  Top = 87
                  Width = 134
                  Height = 62
                  Caption = #51452#47928#50976#54805
                  TabOrder = 6
                  object rbMarket: TRadioButton
                    Left = 3
                    Top = 15
                    Width = 58
                    Height = 17
                    Caption = #49884#51109#44032
                    Checked = True
                    TabOrder = 0
                    TabStop = True
                    OnClick = rbMarketClick
                  end
                  object rbHoga: TRadioButton
                    Left = 2
                    Top = 38
                    Width = 67
                    Height = 17
                    Caption = #49345#45824#54840#44032
                    TabOrder = 1
                    OnClick = rbMarketClick
                  end
                  object edtLiqTick: TAlignedEdit
                    Tag = 2
                    Left = 74
                    Top = 35
                    Width = 40
                    Height = 20
                    ImeName = 'Microsoft Office IME 2007'
                    TabOrder = 2
                    Text = '1'
                    OnChange = edtLiqTickChange
                    OnKeyPress = edtPrfTickKeyPress
                    Alignment = clRight
                    AlignType = atNumber
                  end
                  object udLiqTick: TUpDown
                    Left = 114
                    Top = 35
                    Width = 16
                    Height = 20
                    Associate = edtLiqTick
                    Max = 10
                    Position = 1
                    TabOrder = 3
                  end
                end
                object Button5: TButton
                  Left = 80
                  Top = 68
                  Width = 50
                  Height = 21
                  Caption = #51201#50857
                  TabOrder = 7
                  OnClick = Button5Click
                end
              end
            end
          end
          object TabSheet2: TTabSheet
            Caption = #49444#51221
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object Panel10: TPanel
              Left = 0
              Top = 0
              Width = 142
              Height = 338
              Align = alClient
              BevelOuter = bvNone
              Color = 14214638
              ParentBackground = False
              TabOrder = 0
              object GroupBox2: TGroupBox
                Left = 0
                Top = 0
                Width = 142
                Height = 329
                Align = alTop
                Caption = #49444#51221
                TabOrder = 0
                object Label3: TLabel
                  Left = 23
                  Top = 59
                  Width = 96
                  Height = 12
                  Caption = #51221#47148' : Space bar'
                end
                object cbKeyOrder: TCheckBox
                  Left = 5
                  Top = 39
                  Width = 106
                  Height = 17
                  Caption = 'Space Bar '#51452#47928
                  TabOrder = 0
                  OnClick = cbKeyOrderClick
                end
                object rbMouseSelect: TRadioGroup
                  Left = 24
                  Top = 72
                  Width = 105
                  Height = 55
                  Enabled = False
                  ItemIndex = 0
                  Items.Strings = (
                    #47560#50864#49828#49440#53469
                    #47560#50864#49828#50948#52824)
                  TabOrder = 1
                  OnClick = rbMouseSelectClick
                end
                object rbLastOrdCnl: TRadioGroup
                  Left = 3
                  Top = 180
                  Width = 135
                  Height = 57
                  Caption = #50724#47480#51901' '#47560#50864#49828' '#53364#47533
                  ItemIndex = 1
                  Items.Strings = (
                    #47560#51648#47561#51452#47928' '#52712#49548
                    #49440#53469#50948#52824#51452#47928' '#52712#49548)
                  TabOrder = 2
                  OnClick = rbLastOrdCnlClick
                end
                object TGroupBox
                  Left = 3
                  Top = 244
                  Width = 135
                  Height = 81
                  Caption = #51452#47928#50689#50669#49444#51221
                  TabOrder = 3
                  object Label29: TLabel
                    Left = 12
                    Top = 18
                    Width = 114
                    Height = 12
                    Caption = #44592#48376' H : 18  W : 58'
                  end
                  object SpeedButton6: TSpeedButton
                    Left = 94
                    Top = 56
                    Width = 35
                    Height = 19
                    Caption = #51201#50857
                    OnClick = SpeedButton6Click
                  end
                  object Label6: TLabel
                    Left = 23
                    Top = 39
                    Width = 12
                    Height = 12
                    Caption = 'H:'
                  end
                  object Label7: TLabel
                    Left = 23
                    Top = 58
                    Width = 12
                    Height = 12
                    Caption = 'W:'
                  end
                  object edtOrdH: TAlignedEdit
                    Left = 38
                    Top = 34
                    Width = 46
                    Height = 20
                    ImeName = 'Microsoft Office IME 2007'
                    TabOrder = 0
                    Alignment = clRight
                    AlignType = atNone
                    FirstSelect = False
                  end
                  object edtOrdW: TAlignedEdit
                    Left = 38
                    Top = 55
                    Width = 46
                    Height = 20
                    ImeName = 'Microsoft Office IME 2007'
                    TabOrder = 1
                    Alignment = clRight
                    AlignType = atNone
                    FirstSelect = False
                  end
                end
                object cbOneClick: TCheckBox
                  Left = 5
                  Top = 17
                  Width = 58
                  Height = 17
                  Caption = #50896#53364#47533
                  TabOrder = 4
                  OnClick = cbOneClickClick
                end
                object cbHogaFix: TCheckBox
                  Left = 67
                  Top = 17
                  Width = 70
                  Height = 17
                  Caption = #54840#44032#44256#51221
                  TabOrder = 5
                  OnClick = cbHogaFixClick
                end
                object cbShortCutOrd: TCheckBox
                  Left = 5
                  Top = 133
                  Width = 126
                  Height = 17
                  Caption = #45800#52629#53412#49324#50857'(F5~F8)'
                  TabOrder = 6
                  OnClick = cbShortCutOrdClick
                end
                object cbConfirmOrder: TCheckBox
                  Left = 5
                  Top = 155
                  Width = 116
                  Height = 17
                  Caption = #45800#52629#53412' '#51452#47928#54869#51064
                  Checked = True
                  State = cbChecked
                  TabOrder = 7
                  OnClick = cbConfirmOrderClick
                end
              end
            end
          end
        end
      end
    end
  end
  object PopupMenuOrders: TPopupMenu
    Left = 200
    Top = 136
    object N6000X11: TMenuItem
      Tag = 100
      Caption = #47588#49688' 60.00 X 1'
    end
    object N1: TMenuItem
      Tag = 200
      Caption = #47588#49688#51452#47928
    end
    object N2: TMenuItem
      Tag = 300
      Caption = #51221#51221
    end
    object N3: TMenuItem
      Tag = 400
      Caption = #51068#48512' '#52712#49548
    end
    object N4: TMenuItem
      Tag = 500
      Caption = #51204#48512#52712#49548
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object N6: TMenuItem
      Tag = 900
      Caption = #47588#49688#51452#47928' '#51204#48512#52712#49548
    end
    object N7: TMenuItem
      Tag = 1000
      Caption = #51452#47928#51204#48512#52712#49548
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object FlipDirection1: TMenuItem
      Caption = 'Flip Direction'
    end
    object FlipSide1: TMenuItem
      Caption = 'Flip Side'
    end
    object FlipSideDirection1: TMenuItem
      Caption = 'Flip Side && Direction'
    end
  end
  object PopQuote: TPopupMenu
    Left = 248
    Top = 203
    object N8: TMenuItem
      Tag = 110
      Caption = #54788#51116#44032'(&P)'
    end
    object C1: TMenuItem
      Tag = 120
      Caption = #52264#53944'(&C)'
    end
  end
  object tmPriceSort: TTimer
    Enabled = False
    Left = 144
    Top = 328
  end
  object reFresh: TTimer
    Interval = 500
    OnTimer = reFreshTimer
    Left = 192
    Top = 384
  end
  object PopupMenu1: TPopupMenu
    Left = 736
    Top = 56
    object N10: TMenuItem
      Tag = 1
      Caption = #52628#44032
      OnClick = N10Click
    end
    object N11: TMenuItem
      Tag = -1
      Caption = #49325#51228
      OnClick = N10Click
    end
  end
end
