object CPUForm: TCPUForm
  Left = 348
  Top = 346
  Caption = 'CPU Window'
  ClientHeight = 518
  ClientWidth = 731
  Color = clBtnFace
  Constraints.MinHeight = 449
  Constraints.MinWidth = 582
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PopupMenu = CPUPopup
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object VertSplit: TSplitter
    Left = 528
    Top = 0
    Height = 518
    Align = alRight
    ExplicitHeight = 519
  end
  object RegPanel: TPanel
    Left = 531
    Top = 0
    Width = 200
    Height = 518
    Align = alRight
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    DesignSize = (
      200
      518)
    object RegisterListbox: TListView
      Left = 4
      Top = 4
      Width = 192
      Height = 510
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'Register'
          Width = 70
        end
        item
          Caption = 'Hex'
          Width = 56
        end
        item
          Caption = 'Dec'
          Width = 60
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object LeftPanel: TPanel
    Left = 0
    Top = 0
    Width = 528
    Height = 518
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object HorzSplit: TSplitter
      Left = 0
      Top = 348
      Width = 528
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      ExplicitTop = 349
    end
    object DisasPanel: TPanel
      Left = 0
      Top = 0
      Width = 528
      Height = 348
      Align = alClient
      BevelOuter = bvNone
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 0
      DesignSize = (
        528
        348)
      object lblFunc: TLabel
        Left = 8
        Top = 11
        Width = 68
        Height = 15
        Caption = 'Disassemble:'
      end
      object edFunc: TComboBox
        Left = 84
        Top = 8
        Width = 322
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 0
        OnKeyPress = edFuncKeyPress
      end
      object CodeList: TSynEdit
        Left = 4
        Top = 35
        Width = 520
        Height = 309
        Anchors = [akLeft, akTop, akRight, akBottom]
        Ctl3D = False
        ParentCtl3D = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        Font.Quality = fqClearTypeNatural
        TabOrder = 1
        CodeFolding.ShowCollapsedLine = True
        UseCodeFolding = False
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Gutter.RightOffset = 21
        Gutter.Visible = False
        Gutter.Width = 0
        Options = [eoAutoIndent, eoNoCaret, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabsToSpaces, eoTrimTrailingSpaces]
        ReadOnly = True
        RightEdge = 0
        WantTabs = True
        RemovedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 112
          end>
        AddedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 16496
          end>
      end
      object RadioATT: TRadioButton
        Left = 414
        Top = 12
        Width = 57
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'AT&&T'
        Checked = True
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 2
        TabStop = True
        OnClick = gbSyntaxClick
      end
      object RadioIntel: TRadioButton
        Left = 475
        Top = 12
        Width = 50
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Intel'
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 3
        OnClick = gbSyntaxClick
      end
    end
    object TracePanel: TPanel
      Left = 0
      Top = 351
      Width = 528
      Height = 167
      Align = alBottom
      BevelOuter = bvNone
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 1
      DesignSize = (
        528
        167)
      object lblBacktrace: TLabel
        Left = 8
        Top = 0
        Width = 51
        Height = 15
        Align = alCustom
        Caption = 'Backtrace'
      end
      object StackTrace: TListView
        Left = 4
        Top = 20
        Width = 520
        Height = 143
        Cursor = crHandPoint
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            AutoSize = True
            Caption = 'Function'
            MinWidth = 80
          end
          item
            AutoSize = True
            Caption = 'File'
          end
          item
            Caption = 'Line'
            Width = 40
          end>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        ViewStyle = vsReport
        OnClick = StackTraceClick
      end
    end
  end
  object CPUPopup: TPopupMenu
    Left = 448
    Top = 352
    object CPUCut: TMenuItem
      Caption = 'Cut'
      ShortCut = 16472
      OnClick = CPUCutClick
    end
    object CPUCopy: TMenuItem
      Caption = 'Copy'
      ShortCut = 16451
      OnClick = CPUCopyClick
    end
    object CPUCopyAll: TMenuItem
      Caption = 'Copy All'
      ShortCut = 24643
      OnClick = CPUCopyAllClick
    end
    object CPUPaste: TMenuItem
      Caption = 'Paste'
      ShortCut = 16470
      OnClick = CPUPasteClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object CPUSelectAll: TMenuItem
      Caption = 'Select All'
      ShortCut = 16449
      OnClick = CPUSelectAllClick
    end
  end
end
