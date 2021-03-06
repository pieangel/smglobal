object FramePaveOrder: TFramePaveOrder
  Left = 0
  Top = 0
  Width = 240
  Height = 157
  TabOrder = 0
  object plFloor: TPanel
    Left = 0
    Top = 0
    Width = 240
    Height = 157
    Align = alClient
    BevelOuter = bvNone
    Ctl3D = True
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 0
    object lbDeposit: TLabel
      Left = 6
      Top = 141
      Width = 192
      Height = 13
      AutoSize = False
    end
    object plTop: TPanel
      Left = 0
      Top = 5
      Width = 240
      Height = 26
      Align = alTop
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 0
      ExplicitLeft = 6
      ExplicitTop = 105
      object cbAccount: TComboBox
        Left = 30
        Top = 3
        Width = 97
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft IME 2010'
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbAccountChange
      end
      object cbStart: TCheckBox
        Left = 4
        Top = 4
        Width = 20
        Height = 17
        TabOrder = 1
        OnClick = cbStartClick
      end
      object edtSymbol: TEdit
        Left = 130
        Top = 3
        Width = 69
        Height = 21
        ImeName = 'Microsoft IME 2010'
        ReadOnly = True
        TabOrder = 2
      end
      object btnSymbol: TButton
        Left = 204
        Top = 4
        Width = 25
        Height = 20
        Caption = '...'
        TabOrder = 3
        OnClick = btnSymbolClick
      end
    end
    object cbL: TCheckBox
      Tag = 1
      Left = 4
      Top = 39
      Width = 26
      Height = 17
      Caption = 'L'
      TabOrder = 1
    end
    object edtLCon: TLabeledEdit
      Left = 32
      Top = 37
      Width = 29
      Height = 21
      EditLabel.Width = 48
      EditLabel.Height = 13
      EditLabel.Caption = #51060#54616#51452#47928
      ImeName = 'Microsoft IME 2010'
      LabelPosition = lpRight
      TabOrder = 2
      Text = '0.5'
      OnKeyPress = edtSConKeyPress
    end
    object edtLCnlCon: TLabeledEdit
      Left = 114
      Top = 36
      Width = 30
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #51060#49345
      ImeName = 'Microsoft IME 2010'
      LabelPosition = lpRight
      TabOrder = 3
      Text = '0.47'
      OnKeyPress = edtSConKeyPress
    end
    object btnLCnl: TButton
      Tag = 1
      Left = 173
      Top = 37
      Width = 29
      Height = 20
      Caption = #52712#49548
      TabOrder = 4
      OnClick = btnLCnlClick
    end
    object cbS: TCheckBox
      Tag = -1
      Left = 4
      Top = 60
      Width = 26
      Height = 17
      Caption = 'S'
      Enabled = False
      TabOrder = 5
    end
    object edtSCon: TLabeledEdit
      Left = 32
      Top = 59
      Width = 29
      Height = 21
      EditLabel.Width = 48
      EditLabel.Height = 13
      EditLabel.Caption = #51060#49345#51452#47928
      ImeName = 'Microsoft IME 2010'
      LabelPosition = lpRight
      TabOrder = 6
      OnKeyPress = edtSConKeyPress
    end
    object edtSCnlCon: TLabeledEdit
      Left = 114
      Top = 59
      Width = 30
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #51060#54616
      ImeName = 'Microsoft IME 2010'
      LabelPosition = lpRight
      TabOrder = 7
      OnKeyPress = edtSConKeyPress
    end
    object btnSCnl: TButton
      Tag = -1
      Left = 173
      Top = 60
      Width = 29
      Height = 20
      Caption = #52712#49548
      Enabled = False
      TabOrder = 8
      OnClick = btnSCnlClick
    end
    object GroupBox1: TGroupBox
      Left = 4
      Top = 58
      Width = 231
      Height = 32
      TabOrder = 9
      object edtOrdQty: TLabeledEdit
        Left = 30
        Top = 7
        Width = 28
        Height = 21
        EditLabel.Width = 24
        EditLabel.Height = 13
        EditLabel.Caption = #49688#47049
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 0
        Text = '5'
        OnKeyPress = edtOrdQtyKeyPress
      end
      object udOrdQty: TUpDown
        Left = 58
        Top = 7
        Width = 15
        Height = 21
        Associate = edtOrdQty
        Min = 1
        Max = 500
        Position = 5
        TabOrder = 1
      end
      object edtInterval: TLabeledEdit
        Left = 104
        Top = 7
        Width = 28
        Height = 21
        EditLabel.Width = 24
        EditLabel.Height = 13
        EditLabel.Caption = #44036#44201
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 2
        Text = '2'
        OnKeyPress = edtOrdQtyKeyPress
      end
      object udInterval: TUpDown
        Left = 132
        Top = 7
        Width = 15
        Height = 21
        Associate = edtInterval
        Min = 1
        Max = 10
        Position = 2
        TabOrder = 3
      end
      object edtCount: TLabeledEdit
        Left = 177
        Top = 8
        Width = 28
        Height = 21
        EditLabel.Width = 24
        EditLabel.Height = 13
        EditLabel.Caption = #44060#49688
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 4
        Text = '20'
        OnKeyPress = edtOrdQtyKeyPress
      end
      object udCount: TUpDown
        Left = 205
        Top = 8
        Width = 15
        Height = 21
        Associate = edtCount
        Min = 1
        Position = 20
        TabOrder = 5
      end
    end
    object Panel1: TPanel
      Left = 4
      Top = 94
      Width = 235
      Height = 48
      BevelOuter = bvNone
      TabOrder = 10
      object lblInfo: TLabel
        Left = 2
        Top = 25
        Width = 192
        Height = 13
        AutoSize = False
      end
      object edtLossVol: TLabeledEdit
        Left = 41
        Top = -1
        Width = 34
        Height = 21
        EditLabel.Width = 24
        EditLabel.Height = 13
        EditLabel.Caption = #51092#47049
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 0
        OnKeyPress = edtOrdQtyKeyPress
      end
      object Button4: TButton
        Left = 200
        Top = 23
        Width = 28
        Height = 18
        Caption = #51201#50857
        TabOrder = 1
        OnClick = Button4Click
      end
      object dtEndTime: TDateTimePicker
        Left = 105
        Top = -1
        Width = 78
        Height = 21
        Date = 41717.618055555550000000
        Time = 41717.618055555550000000
        ImeName = 'Microsoft IME 2010'
        Kind = dtkTime
        TabOrder = 2
      end
      object edtLossPer: TLabeledEdit
        Left = 0
        Top = -1
        Width = 26
        Height = 21
        EditLabel.Width = 11
        EditLabel.Height = 13
        EditLabel.Caption = '%'
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 3
        OnKeyPress = edtOrdQtyKeyPress
      end
      object edtCnlHour: TEdit
        Left = 184
        Top = 0
        Width = 22
        Height = 21
        ImeName = 'Microsoft IME 2010'
        TabOrder = 4
        Text = '8'
        OnKeyPress = edtOrdQtyKeyPress
      end
      object edtCnlTick: TEdit
        Left = 207
        Top = -1
        Width = 22
        Height = 21
        ImeName = 'Microsoft IME 2010'
        TabOrder = 5
        Text = '2'
        OnKeyPress = edtOrdQtyKeyPress
      end
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 240
      Height = 5
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 11
    end
    object btnLDepsit: TButton
      Tag = 1
      Left = 209
      Top = 37
      Width = 23
      Height = 20
      Caption = 'calc'
      TabOrder = 12
      OnClick = btnLDepsitClick
    end
    object btnSDeposit: TButton
      Tag = -1
      Left = 209
      Top = 60
      Width = 23
      Height = 20
      Caption = 'calc'
      Enabled = False
      TabOrder = 13
      Visible = False
      OnClick = btnSDepositClick
    end
  end
end
