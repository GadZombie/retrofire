object Main: TMain
  Left = 259
  Top = 135
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Retrofire: Configuration'
  ClientHeight = 476
  ClientWidth = 715
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Microsoft Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 437
    Width = 715
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    Color = clMenu
    Ctl3D = True
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 0
    ExplicitTop = 436
    ExplicitWidth = 711
    DesignSize = (
      715
      39)
    object btnanuluj: TButton
      Left = 461
      Top = 6
      Width = 106
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      TabOrder = 0
      OnClick = btnanulujClick
      ExplicitLeft = 457
    end
    object btnok: TButton
      Left = 573
      Top = 6
      Width = 134
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Save and exit'
      TabOrder = 1
      OnClick = btnokClick
      ExplicitLeft = 569
    end
  end
  object pgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 715
    Height = 437
    ActivePage = tabGraphics
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 711
    ExplicitHeight = 436
    object tabReadMe: TTabSheet
      Caption = 'Read Me First'
      ImageIndex = 3
      object memReadMe: TMemo
        AlignWithMargins = True
        Left = 5
        Top = 5
        Width = 697
        Height = 396
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Ctl3D = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Consolas'
        Font.Style = []
        ParentCtl3D = False
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        WantTabs = True
        ExplicitWidth = 693
        ExplicitHeight = 395
      end
    end
    object tabGraphics: TTabSheet
      Caption = 'Graphics'
      object Label3: TLabel
        Left = 16
        Top = 96
        Width = 87
        Height = 16
        Caption = 'Visibility range'
      end
      object Label4: TLabel
        Left = 16
        Top = 143
        Width = 108
        Height = 16
        Caption = 'Screen brightness'
      end
      object Label6: TLabel
        Left = 16
        Top = 18
        Width = 70
        Height = 16
        Caption = 'Screen size'
      end
      object cbGraphicsMode: TComboBox
        Left = 144
        Top = 15
        Width = 430
        Height = 24
        Style = csDropDownList
        DropDownCount = 16
        TabOrder = 0
      end
      object chfullscreen: TCheckBox
        Left = 144
        Top = 55
        Width = 89
        Height = 17
        Hint = 
          'w trybie okienkowym nie ma znaczenia g'#322#281'bia kolor'#243'w i cz'#281'stotliw' +
          'o'#347#263
        Caption = 'Full screen'
        Checked = True
        ParentShowHint = False
        ShowHint = True
        State = cbChecked
        TabOrder = 1
      end
      object TrJasnosc: TTrackBar
        Left = 144
        Top = 130
        Width = 430
        Height = 36
        Min = 2
        Position = 2
        TabOrder = 2
        TickMarks = tmBoth
      end
      object TrWidocznosc: TTrackBar
        Left = 144
        Top = 86
        Width = 430
        Height = 38
        Max = 13
        Min = 2
        Position = 6
        TabOrder = 3
        TickMarks = tmBoth
      end
      object chGrass: TCheckBox
        Left = 144
        Top = 179
        Width = 393
        Height = 17
        Caption = 'Show grass and bushes on the ground (slower)'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
    end
    object tabSound: TTabSheet
      Caption = 'Sound FX'
      ImageIndex = 1
      object Label1: TLabel
        Left = 16
        Top = 72
        Width = 86
        Height = 16
        Caption = 'Sound volume'
      end
      object Label2: TLabel
        Left = 16
        Top = 126
        Width = 82
        Height = 16
        Caption = 'Music volume'
      end
      object cbdzwiek: TComboBox
        Left = 16
        Top = 21
        Width = 313
        Height = 24
        Style = csDropDownList
        TabOrder = 0
        Items.Strings = (
          'No sound'
          'Directsound')
      end
      object TrVolDzw: TTrackBar
        Left = 136
        Top = 62
        Width = 375
        Height = 37
        Max = 25
        Position = 25
        TabOrder = 1
        TickMarks = tmBoth
      end
      object TrVolMuz: TTrackBar
        Left = 136
        Top = 117
        Width = 375
        Height = 38
        Max = 25
        Position = 10
        TabOrder = 2
        TickMarks = tmBoth
      end
    end
    object tabControls: TTabSheet
      Caption = 'Controls'
      ImageIndex = 2
      DesignSize = (
        707
        406)
      object ButPrzywrocDomyslne: TSpeedButton
        Left = 9
        Top = 10
        Width = 305
        Height = 24
        Caption = 'Set default controls'
        OnClick = ButPrzywrocDomyslneClick
      end
      object Label5: TLabel
        Left = 17
        Top = 48
        Width = 113
        Height = 16
        Caption = 'Joystick deadzone'
        Enabled = False
        Visible = False
      end
      object klawskrol: TScrollBox
        Left = 3
        Top = 88
        Width = 701
        Height = 315
        VertScrollBar.Smooth = True
        VertScrollBar.Tracking = True
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelInner = bvNone
        BevelKind = bkFlat
        BorderStyle = bsNone
        Ctl3D = True
        ParentCtl3D = False
        TabOrder = 0
        OnMouseWheel = klawskrolMouseWheel
        object ControlsHeader: THeaderControl
          Left = 0
          Top = 0
          Width = 699
          Height = 28
          FullDrag = False
          Sections = <
            item
              ImageIndex = -1
              Text = 'Control name'
              Width = 50
            end
            item
              Alignment = taCenter
              ImageIndex = -1
              Text = 'Joystick'
              Width = 50
            end
            item
              Alignment = taCenter
              ImageIndex = -1
              Text = 'Keyboard'
              Width = 50
            end>
          Style = hsFlat
          NoSizing = True
        end
      end
      object trDeadZone: TTrackBar
        Left = 136
        Top = 38
        Width = 513
        Height = 37
        Enabled = False
        Max = 100
        Position = 10
        TabOrder = 1
        TickMarks = tmBoth
        Visible = False
      end
    end
  end
end
