object fmHhedge: TfmHhedge
  Left = 0
  Top = 0
  Width = 315
  Height = 80
  Color = clBtnFace
  Ctl3D = True
  ParentBackground = False
  ParentColor = False
  ParentCtl3D = False
  TabOrder = 0
  object Label1: TLabel
    Left = 218
    Top = 6
    Width = 8
    Height = 13
    Caption = '~'
  end
  object lbNo: TLabel
    Left = 5
    Top = 32
    Width = 12
    Height = 13
    Caption = '10'
  end
  object cbStart: TCheckBox
    Left = 3
    Top = 3
    Width = 46
    Height = 17
    Caption = #49884#51089
    TabOrder = 0
  end
  object edtQty: TEdit
    Left = 23
    Top = 29
    Width = 27
    Height = 21
    ImeName = 'Microsoft IME 2010'
    TabOrder = 1
    Text = '1'
  end
  object edtE: TLabeledEdit
    Left = 66
    Top = 30
    Width = 25
    Height = 21
    Hint = #51652#51077#51312#44148
    EditLabel.Width = 6
    EditLabel.Height = 13
    EditLabel.Caption = 'E'
    ImeName = 'Microsoft IME 2010'
    LabelPosition = lpLeft
    TabOrder = 2
    Text = '0.5'
  end
  object dtStartTime2: TDateTimePicker
    Left = 132
    Top = 3
    Width = 79
    Height = 21
    Date = 41717.375694444450000000
    Time = 41717.375694444450000000
    ImeName = 'Microsoft IME 2010'
    Kind = dtkTime
    TabOrder = 3
  end
  object edtL1: TLabeledEdit
    Left = 111
    Top = 30
    Width = 26
    Height = 21
    Hint = #44256#51200#45824#48708#52397#49328
    EditLabel.Width = 11
    EditLabel.Height = 13
    EditLabel.Caption = 'L1'
    ImeName = 'Microsoft IME 2010'
    LabelPosition = lpLeft
    TabOrder = 4
    Text = '0.7'
  end
  object edtL2: TLabeledEdit
    Left = 160
    Top = 30
    Width = 26
    Height = 21
    Hint = #51060#51061#52397#49328
    EditLabel.Width = 11
    EditLabel.Height = 13
    EditLabel.Caption = 'L2'
    ImeName = 'Microsoft IME 2010'
    LabelPosition = lpLeft
    TabOrder = 5
    Text = '1.8'
  end
  object edtLC: TLabeledEdit
    Left = 207
    Top = 30
    Width = 28
    Height = 21
    Hint = #49552#51208
    EditLabel.Width = 12
    EditLabel.Height = 13
    EditLabel.Caption = 'LC'
    ImeName = 'Microsoft IME 2010'
    LabelPosition = lpLeft
    TabOrder = 6
    Text = '0.8'
  end
  object dtEndTime: TDateTimePicker
    Left = 232
    Top = 3
    Width = 77
    Height = 21
    Date = 41717.625000000000000000
    Time = 41717.625000000000000000
    ImeName = 'Microsoft IME 2010'
    Kind = dtkTime
    TabOrder = 7
  end
  object Button1: TButton
    Left = 287
    Top = 30
    Width = 25
    Height = 21
    Caption = 'apply'
    TabOrder = 8
  end
  object dtStartTime1: TDateTimePicker
    Left = 48
    Top = 3
    Width = 79
    Height = 21
    Date = 41717.375694444450000000
    Time = 41717.375694444450000000
    ImeName = 'Microsoft IME 2010'
    Kind = dtkTime
    TabOrder = 9
  end
  object edtPlus: TLabeledEdit
    Left = 253
    Top = 30
    Width = 28
    Height = 21
    Hint = #49552#51208
    EditLabel.Width = 8
    EditLabel.Height = 13
    EditLabel.Caption = '+'
    ImeName = 'Microsoft IME 2010'
    LabelPosition = lpLeft
    TabOrder = 10
    Text = '0.3'
  end
  object cbOpt: TCheckBox
    Left = 54
    Top = 56
    Width = 46
    Height = 17
    Caption = #50741#49496
    TabOrder = 11
    OnClick = cbOptClick
  end
  object Panel1: TPanel
    Left = 97
    Top = 54
    Width = 214
    Height = 23
    BevelOuter = bvNone
    TabOrder = 12
    object Label2: TLabel
      Left = 72
      Top = 5
      Width = 8
      Height = 13
      Caption = '~'
    end
    object edtAbove: TEdit
      Left = 38
      Top = 1
      Width = 31
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 0
      Text = '0.3'
    end
    object edtBelow: TEdit
      Left = 80
      Top = 1
      Width = 29
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 1
      Text = '1.8'
    end
    object edtOptCnt: TEdit
      Left = 114
      Top = 1
      Width = 25
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 2
      Text = '1'
    end
    object udOptCnt: TUpDown
      Left = 139
      Top = 1
      Width = 15
      Height = 21
      Associate = edtOptCnt
      Min = 1
      Max = 10
      Position = 1
      TabOrder = 3
    end
    object cbDir: TComboBox
      Left = 160
      Top = 0
      Width = 51
      Height = 21
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = #50724#47492
      Items.Strings = (
        #50724#47492
        #45236#47548)
    end
    object edtOptQty: TEdit
      Left = 5
      Top = 1
      Width = 27
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 5
      Text = '1'
    end
  end
  object cbFut: TCheckBox
    Left = 3
    Top = 56
    Width = 46
    Height = 17
    Caption = #49440#47932
    Checked = True
    State = cbChecked
    TabOrder = 13
    OnClick = cbOptClick
  end
end
