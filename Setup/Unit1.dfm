object Form1: TForm1
  Left = 405
  Top = 240
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Retrofire konfiguracja'
  ClientHeight = 543
  ClientWidth = 411
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    411
    543)
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 411
    Height = 131
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Grafika'
    TabOrder = 0
    ExplicitWidth = 407
    object Label3: TLabel
      Left = 8
      Top = 53
      Width = 90
      Height = 13
      Caption = 'Zasi'#281'g widoczno'#347'ci'
    end
    object Label4: TLabel
      Left = 8
      Top = 82
      Width = 96
      Height = 13
      Caption = 'Rozja'#347'nienie ekranu'
    end
    object cbtrybgraf: TComboBox
      Left = 8
      Top = 20
      Width = 105
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = '320x240'
      Items.Strings = (
        '320x240'
        '640x480'
        '800x600'
        '1024x768'
        '1280x1024'
        '1920x1080')
    end
    object cbbity: TComboBox
      Left = 120
      Top = 20
      Width = 89
      Height = 21
      Style = csDropDownList
      ItemIndex = 2
      TabOrder = 1
      Text = '32bit'
      Items.Strings = (
        '16bit'
        '24bit'
        '32bit')
    end
    object cbhz: TComboBox
      Left = 216
      Top = 20
      Width = 89
      Height = 21
      Style = csDropDownList
      ItemIndex = 2
      TabOrder = 2
      Text = '75Hz'
      Items.Strings = (
        '60Hz'
        '72Hz'
        '75Hz'
        '85Hz')
    end
    object chfullscreen: TCheckBox
      Left = 312
      Top = 23
      Width = 89
      Height = 17
      Hint = 
        'w trybie okienkowym nie ma znaczenia g'#322#281'bia kolor'#243'w i cz'#281'stotliw' +
        'o'#347#263
      Caption = 'Pe'#322'ny ekran'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 3
    end
    object TrWidocznosc: TTrackBar
      Left = 136
      Top = 42
      Width = 272
      Height = 29
      Max = 13
      Min = 2
      Position = 6
      TabOrder = 4
      ThumbLength = 14
      TickMarks = tmBoth
    end
    object TrJasnosc: TTrackBar
      Left = 136
      Top = 73
      Width = 272
      Height = 29
      Min = 2
      Position = 2
      TabOrder = 5
      ThumbLength = 14
      TickMarks = tmBoth
    end
    object ChKrzaki: TCheckBox
      Left = 8
      Top = 107
      Width = 393
      Height = 17
      Caption = 'Pokazuj krzaki i traw'#281' na powierzchni (wolniej)'
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 133
    Width = 411
    Height = 114
    Anchors = [akLeft, akTop, akRight]
    Caption = 'D'#378'wi'#281'k'
    TabOrder = 1
    ExplicitWidth = 407
    object Label1: TLabel
      Left = 8
      Top = 56
      Width = 92
      Height = 13
      Caption = 'G'#322'o'#347'no'#347#263' d'#378'wi'#281'k'#243'w'
    end
    object Label2: TLabel
      Left = 8
      Top = 85
      Width = 78
      Height = 13
      Caption = 'G'#322'o'#347'no'#347#263' muzyki'
    end
    object cbdzwiek: TComboBox
      Left = 8
      Top = 20
      Width = 395
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 0
      Text = 'Directsound'
      Items.Strings = (
        'Bez d'#378'wi'#281'ku'
        'Directsound')
    end
    object TrVolDzw: TTrackBar
      Left = 136
      Top = 46
      Width = 272
      Height = 29
      Max = 25
      Position = 25
      TabOrder = 1
      ThumbLength = 14
      TickMarks = tmBoth
    end
    object TrVolMuz: TTrackBar
      Left = 136
      Top = 76
      Width = 272
      Height = 29
      Max = 25
      Position = 10
      TabOrder = 2
      ThumbLength = 14
      TickMarks = tmBoth
    end
  end
  object btnok: TButton
    Left = 307
    Top = 516
    Width = 99
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Zapisz i zamknij'
    TabOrder = 2
    OnClick = btnokClick
    ExplicitLeft = 303
    ExplicitTop = 515
  end
  object btnanuluj: TButton
    Left = 211
    Top = 516
    Width = 83
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Anuluj'
    TabOrder = 3
    OnClick = btnanulujClick
    ExplicitLeft = 207
    ExplicitTop = 515
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 249
    Width = 411
    Height = 264
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Klawisze'
    TabOrder = 4
    ExplicitWidth = 407
    ExplicitHeight = 263
    DesignSize = (
      411
      264)
    object ButPrzywrocDomyslne: TSpeedButton
      Left = 30
      Top = 14
      Width = 351
      Height = 19
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Przywr'#243#263' domy'#347'lne ustawienia klawiszy'
      OnClick = ButPrzywrocDomyslneClick
    end
    object klawskrol: TScrollBox
      Left = 4
      Top = 36
      Width = 402
      Height = 223
      VertScrollBar.Smooth = True
      VertScrollBar.Style = ssFlat
      VertScrollBar.Tracking = True
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelInner = bvNone
      BevelKind = bkSoft
      BorderStyle = bsNone
      TabOrder = 0
      ExplicitWidth = 398
      ExplicitHeight = 222
    end
  end
  object PowerInput1: TPowerInput
    Left = 24
    Top = 384
  end
end
