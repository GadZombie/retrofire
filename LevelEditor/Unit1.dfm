object Form1: TForm1
  Left = 344
  Top = 224
  Width = 936
  Height = 713
  Caption = 'Retrofire: Edytor map'
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 658
    Top = 0
    Width = 5
    Height = 663
    Cursor = crHSplit
    Align = alRight
    AutoSnap = False
    Beveled = True
    ResizeStyle = rsUpdate
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 658
    Height = 663
    HorzScrollBar.ButtonSize = 13
    HorzScrollBar.Color = clBtnShadow
    HorzScrollBar.ParentColor = False
    HorzScrollBar.Size = 13
    HorzScrollBar.Style = ssFlat
    HorzScrollBar.ThumbSize = 8
    HorzScrollBar.Tracking = True
    VertScrollBar.ButtonSize = 13
    VertScrollBar.Color = clBtnShadow
    VertScrollBar.ParentColor = False
    VertScrollBar.Size = 13
    VertScrollBar.Style = ssFlat
    VertScrollBar.ThumbSize = 8
    VertScrollBar.Tracking = True
    Align = alClient
    BorderStyle = bsNone
    Color = 9336930
    ParentColor = False
    TabOrder = 0
    object rys: TPaintBox
      Left = 0
      Top = 0
      Width = 352
      Height = 255
      Cursor = crCross
      OnMouseDown = rysMouseDown
      OnMouseMove = rysMouseMove
      OnMouseUp = rysMouseUp
      OnPaint = rysPaint
    end
  end
  object PageControl1: TPageControl
    Left = 663
    Top = 0
    Width = 265
    Height = 663
    ActivePage = TabTworzenie
    Align = alRight
    Style = tsButtons
    TabIndex = 0
    TabOrder = 1
    object TabTworzenie: TTabSheet
      Caption = 'Tworzenie'
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 257
        Height = 632
        Align = alClient
        Color = 14008238
        TabOrder = 0
        DesignSize = (
          257
          632)
        object Kolor: TShape
          Left = 176
          Top = 40
          Width = 65
          Height = 65
          Cursor = crHandPoint
          OnMouseDown = KolorMouseDown
        end
        object LabJasnosc: TLabel
          Left = 32
          Top = 616
          Width = 74
          Height = 16
          Anchors = [akLeft, akBottom]
          Caption = 'LabJasnosc'
          Color = 13414813
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
        end
        object Label25: TLabel
          Left = 34
          Top = 448
          Width = 206
          Height = 52
          Caption = 
            'Lewy klawisz myszy: rysowanie/stawianie; Prawy klawisz: wymazywa' +
            'nie/usuwanie; '#347'rodkowy klawisz: pobieranie pr'#243'bnikiem z wskazane' +
            'go miejsca'
          Constraints.MaxWidth = 217
          WordWrap = True
        end
        object Label26: TLabel
          Left = 34
          Top = 504
          Width = 192
          Height = 65
          Caption = 
            'Pami'#281'taj, '#380'e je'#347'li ustawiasz dzia'#322'ko na '#347'cianie, '#347'ciana powinna ' +
            'by'#263' grubo'#347'ci co najmniej 2x2 i w tej kratce dzia'#322'ko powinno by'#263' ' +
            'w miejscu 1x1 (z prawej i poni'#380'ej musi by'#263' jeszcze '#347'ciana)'
          Constraints.MaxWidth = 217
          WordWrap = True
        end
        object trskala: TTrackBar
          Left = 1
          Top = 1
          Width = 180
          Height = 21
          Hint = 'Skala wysoko'#347'ci na mapce'
          Max = 100
          Min = 1
          Orientation = trHorizontal
          ParentShowHint = False
          Frequency = 1
          Position = 33
          SelEnd = 0
          SelStart = 0
          ShowHint = True
          TabOrder = 0
          ThumbLength = 14
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = trskalaChange
        end
        object trjasnosc: TTrackBar
          Left = 3
          Top = 28
          Width = 26
          Height = 607
          Hint = 'Wysoko'#347#263' rysowana'
          Anchors = [akLeft, akTop, akBottom]
          Max = 1400
          Orientation = trVertical
          ParentShowHint = False
          PageSize = 50
          Frequency = 1
          Position = 500
          SelEnd = 0
          SelStart = 0
          ShowHint = True
          TabOrder = 1
          ThumbLength = 14
          TickMarks = tmBottomRight
          TickStyle = tsManual
          OnChange = trjasnoscChange
        end
        object trrozmiar: TTrackBar
          Left = 177
          Top = 1
          Width = 78
          Height = 21
          Hint = 'Zoom'
          Min = 1
          Orientation = trHorizontal
          ParentShowHint = False
          Frequency = 1
          Position = 5
          SelEnd = 0
          SelStart = 0
          ShowHint = True
          TabOrder = 2
          ThumbLength = 14
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = trrozmiarChange
        end
        object narzedzie: TRadioGroup
          Left = 32
          Top = 32
          Width = 121
          Height = 113
          Caption = 'Narz'#281'dzia'
          ItemIndex = 0
          Items.Strings = (
            'wysoko'#347'ci'
            'kolorowanie'
            'dzia'#322'ka'
            'l'#261'dowiska'
            'sceneria')
          TabOrder = 3
          OnClick = narzedzieClick
        end
        object Pokazuj: TRadioGroup
          Left = 168
          Top = 112
          Width = 81
          Height = 81
          Caption = 'Pokazuj'
          ItemIndex = 2
          Items.Strings = (
            'wysoko'#347'ci'
            'kolory'
            'mieszane'
            'sceneri'#281)
          TabOrder = 4
          OnClick = PokazujClick
        end
        object ChPokLadowiska: TCheckBox
          Left = 168
          Top = 207
          Width = 81
          Height = 17
          Caption = 'L'#261'dowiska'
          Checked = True
          State = cbChecked
          TabOrder = 5
          OnClick = ChPokLadowiskaClick
        end
        object ChPokDziala: TCheckBox
          Left = 168
          Top = 223
          Width = 81
          Height = 17
          Caption = 'Dzia'#322'ka'
          Checked = True
          State = cbChecked
          TabOrder = 6
          OnClick = ChPokDzialaClick
        end
        object GroupBoxLadowiska: TGroupBox
          Left = 32
          Top = 146
          Width = 101
          Height = 153
          Caption = 'L'#261'dowisko'
          TabOrder = 7
          Visible = False
          object Label4: TLabel
            Left = 8
            Top = 19
            Width = 28
            Height = 13
            Caption = 'Roz.X'
          end
          object Label5: TLabel
            Left = 8
            Top = 41
            Width = 28
            Height = 13
            Caption = 'Roz.Z'
          end
          object Label6: TLabel
            Left = 8
            Top = 63
            Width = 34
            Height = 13
            Caption = 'pilot'#243'w'
          end
          object LadKolor: TShape
            Left = 32
            Top = 121
            Width = 63
            Height = 25
            Hint = 'Kolor pod l'#261'dowiskiem'
            ParentShowHint = False
            ShowHint = True
            OnMouseDown = KolorMouseDown
          end
          object EditLadRX: TEdit
            Left = 51
            Top = 16
            Width = 26
            Height = 21
            TabOrder = 0
            Text = '3'
          end
          object UpDownLadRX: TUpDown
            Left = 77
            Top = 16
            Width = 15
            Height = 21
            Associate = EditLadRX
            Min = 1
            Max = 30
            Position = 3
            TabOrder = 1
            Wrap = False
          end
          object UpDownLadRZ: TUpDown
            Left = 77
            Top = 38
            Width = 15
            Height = 21
            Associate = EditLadRZ
            Min = 1
            Max = 30
            Position = 3
            TabOrder = 2
            Wrap = False
          end
          object EditLadRZ: TEdit
            Left = 51
            Top = 38
            Width = 26
            Height = 21
            TabOrder = 3
            Text = '3'
          end
          object UpDownLadPilotow: TUpDown
            Left = 77
            Top = 60
            Width = 15
            Height = 21
            Associate = EditLadPilotow
            Min = 0
            Max = 99
            Position = 5
            TabOrder = 4
            Wrap = False
          end
          object EditLadPilotow: TEdit
            Left = 51
            Top = 60
            Width = 26
            Height = 21
            TabOrder = 5
            Text = '5'
          end
          object LadKoloruj: TCheckBox
            Left = 11
            Top = 124
            Width = 15
            Height = 17
            Hint = 'Kolorowanie pod l'#261'dowiskiem'
            Checked = True
            ParentShowHint = False
            ShowHint = True
            State = cbChecked
            TabOrder = 6
          end
          object ChLadDobre: TCheckBox
            Left = 9
            Top = 88
            Width = 75
            Height = 17
            Hint = 'Je'#347'li odznaczone, to b'#281'dzie l'#261'dowisko wroga'
            Caption = 'Dobre'
            Checked = True
            ParentShowHint = False
            ShowHint = True
            State = cbChecked
            TabOrder = 7
          end
        end
        object GroupBox3: TGroupBox
          Left = 168
          Top = 245
          Width = 75
          Height = 65
          Caption = 'Mysz'
          TabOrder = 8
          object myszx: TLabel
            Left = 8
            Top = 16
            Width = 28
            Height = 13
            Caption = 'Roz.X'
          end
          object myszz: TLabel
            Left = 8
            Top = 30
            Width = 28
            Height = 13
            Caption = 'Roz.Z'
          end
          object myszy: TLabel
            Left = 8
            Top = 44
            Width = 34
            Height = 13
            Caption = 'pilot'#243'w'
          end
        end
        object tr3d: TTrackBar
          Left = 230
          Top = 312
          Width = 21
          Height = 135
          Hint = 'Pseudo-3D'
          Max = 30
          Orientation = trVertical
          ParentShowHint = False
          Frequency = 1
          Position = 0
          SelEnd = 0
          SelStart = 0
          ShowHint = True
          TabOrder = 9
          ThumbLength = 14
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = tr3dChange
        end
        object GroupBoxDzialka: TGroupBox
          Left = 32
          Top = 146
          Width = 101
          Height = 65
          Caption = 'Dzia'#322'ko'
          TabOrder = 10
          Visible = False
          object RodzajDzialka: TRadioGroup
            Left = 2
            Top = 11
            Width = 97
            Height = 48
            ItemIndex = 0
            Items.Strings = (
              'rakietowe'
              'maszynowe')
            TabOrder = 0
            OnClick = PokazujClick
          end
        end
        object GroupBoxRysowanie: TGroupBox
          Left = 32
          Top = 146
          Width = 132
          Height = 151
          Caption = 'P'#281'dzel'
          TabOrder = 11
          object Label21: TLabel
            Left = 10
            Top = 60
            Width = 35
            Height = 13
            Caption = 'rozmiar'
          end
          object KsztaltPedzla: TRadioGroup
            Left = 2
            Top = 14
            Width = 128
            Height = 48
            Caption = 'kszta'#322't'
            ItemIndex = 0
            Items.Strings = (
              'ko'#322'o'
              'kwadrat')
            TabOrder = 0
            OnClick = PokazujClick
          end
          object trpedzel: TTrackBar
            Left = 1
            Top = 72
            Width = 127
            Height = 25
            Hint = 'Rozmiar p'#281'dzla'
            Max = 30
            Min = 1
            Orientation = trHorizontal
            ParentShowHint = False
            Frequency = 1
            Position = 5
            SelEnd = 0
            SelStart = 0
            ShowHint = True
            TabOrder = 1
            ThumbLength = 18
            TickMarks = tmBottomRight
            TickStyle = tsAuto
            OnChange = trpedzelChange
          end
          object ChRysWygladz: TCheckBox
            Left = 8
            Top = 104
            Width = 105
            Height = 17
            Caption = 'z wyg'#322'adzeniem'
            Checked = True
            State = cbChecked
            TabOrder = 2
          end
          object ChRysZmianaKoloru: TCheckBox
            Left = 8
            Top = 122
            Width = 105
            Height = 17
            Caption = 'zmieniaj kolor'
            Checked = True
            Enabled = False
            State = cbChecked
            TabOrder = 3
          end
        end
      end
    end
    object TabUstawienia: TTabSheet
      Caption = 'Ustawienia'
      ImageIndex = 1
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 257
        Height = 632
        Align = alClient
        Color = 14008238
        TabOrder = 0
        object GroupBox4: TGroupBox
          Left = 1
          Top = 1
          Width = 255
          Height = 223
          Align = alTop
          Caption = 'Zadanie i parametry misji'
          TabOrder = 0
          object BtnMisja1: TSpeedButton
            Left = 174
            Top = 15
            Width = 38
            Height = 18
            Caption = 'zlicz'
            OnClick = BtnMisja1Click
          end
          object BtnMisja2: TSpeedButton
            Left = 174
            Top = 37
            Width = 38
            Height = 18
            Caption = 'zlicz'
            OnClick = BtnMisja2Click
          end
          object MisjaPoziom: TLabel
            Left = 10
            Top = 64
            Width = 84
            Height = 13
            Caption = 'Poziom trudno'#347'ci:'
          end
          object Label7: TLabel
            Left = 10
            Top = 86
            Width = 51
            Height = 13
            Caption = 'Grawitacja'
          end
          object Label8: TLabel
            Left = 10
            Top = 108
            Width = 88
            Height = 13
            Caption = 'G'#281'sto'#347#263' powietrza'
          end
          object Label9: TLabel
            Left = 10
            Top = 130
            Width = 50
            Height = 13
            Caption = 'Si'#322'a wiatru'
          end
          object Label10: TLabel
            Left = 10
            Top = 152
            Width = 87
            Height = 13
            Caption = 'Wys. statku-matki'
          end
          object Label13: TLabel
            Left = 10
            Top = 200
            Width = 98
            Height = 13
            Caption = 'Czas na wype'#322'nienie'
          end
          object Label14: TLabel
            Left = 176
            Top = 200
            Width = 4
            Height = 13
            Caption = ':'
          end
          object Label15: TLabel
            Left = 175
            Top = 64
            Width = 12
            Height = 13
            Caption = 'do'
          end
          object Label16: TLabel
            Left = 175
            Top = 86
            Width = 12
            Height = 13
            Caption = 'do'
          end
          object Label17: TLabel
            Left = 175
            Top = 108
            Width = 12
            Height = 13
            Caption = 'do'
          end
          object Label18: TLabel
            Left = 175
            Top = 130
            Width = 12
            Height = 13
            Caption = 'do'
          end
          object Label19: TLabel
            Left = 10
            Top = 174
            Width = 106
            Height = 13
            Caption = 'Max my'#347'liwc'#243'w na raz'
          end
          object Label20: TLabel
            Left = 175
            Top = 174
            Width = 12
            Height = 13
            Caption = 'do'
          end
          object RadioMisja1: TRadioButton
            Left = 8
            Top = 16
            Width = 113
            Height = 17
            Caption = 'Uratuj pilot'#243'w'
            Checked = True
            TabOrder = 0
            TabStop = True
            OnClick = RadioMisja1Click
          end
          object RadioMisja2: TRadioButton
            Left = 8
            Top = 38
            Width = 113
            Height = 17
            Caption = 'Zniszcz dzia'#322'ka'
            TabOrder = 1
            OnClick = RadioMisja2Click
          end
          object EditMisja1: TEdit
            Left = 120
            Top = 13
            Width = 36
            Height = 21
            TabOrder = 2
            Text = '1'
          end
          object UpDownMisja1: TUpDown
            Left = 156
            Top = 13
            Width = 15
            Height = 21
            Associate = EditMisja1
            Min = 1
            Max = 9999
            Position = 1
            TabOrder = 3
            Wrap = False
          end
          object UpDownMisja2: TUpDown
            Left = 156
            Top = 35
            Width = 15
            Height = 21
            Associate = EditMisja2
            Enabled = False
            Min = 1
            Max = 9999
            Position = 1
            TabOrder = 4
            Wrap = False
          end
          object EditMisja2: TEdit
            Left = 120
            Top = 35
            Width = 36
            Height = 21
            Enabled = False
            TabOrder = 5
            Text = '1'
          end
          object EditMisjaPoziom: TEdit
            Left = 120
            Top = 60
            Width = 36
            Height = 21
            TabOrder = 6
            Text = '1'
          end
          object UpDownMisjaPoziom: TUpDown
            Left = 156
            Top = 60
            Width = 15
            Height = 21
            Associate = EditMisjaPoziom
            Min = 1
            Max = 99
            Position = 1
            TabOrder = 7
            Wrap = False
            OnClick = UpDownMisjaPoziomClick
          end
          object EditMisjaGrawitacja: TEdit
            Left = 120
            Top = 82
            Width = 36
            Height = 21
            TabOrder = 8
            Text = '25'
          end
          object UpDownMisjaGrawitacja: TUpDown
            Left = 156
            Top = 82
            Width = 15
            Height = 21
            Associate = EditMisjaGrawitacja
            Min = 1
            Max = 99
            Position = 25
            TabOrder = 9
            Wrap = False
            OnClick = UpDownMisjaGrawitacjaClick
          end
          object EditMisjaGestosc: TEdit
            Left = 120
            Top = 104
            Width = 36
            Height = 21
            TabOrder = 10
            Text = '25'
          end
          object UpDownMisjaGestosc: TUpDown
            Left = 156
            Top = 104
            Width = 15
            Height = 21
            Associate = EditMisjaGestosc
            Min = 1
            Max = 99
            Position = 25
            TabOrder = 11
            Wrap = False
            OnClick = UpDownMisjaGestoscClick
          end
          object EditMisjaWiatr: TEdit
            Left = 120
            Top = 126
            Width = 36
            Height = 21
            TabOrder = 12
            Text = '15'
          end
          object UpDownMisjaWiatr: TUpDown
            Left = 156
            Top = 126
            Width = 15
            Height = 21
            Associate = EditMisjaWiatr
            Min = 1
            Max = 99
            Position = 15
            TabOrder = 13
            Wrap = False
            OnClick = UpDownMisjaWiatrClick
          end
          object EditWysMatki: TEdit
            Left = 120
            Top = 148
            Width = 36
            Height = 21
            TabOrder = 14
            Text = '900'
          end
          object UpDownWysMatki: TUpDown
            Left = 156
            Top = 148
            Width = 15
            Height = 21
            Associate = EditWysMatki
            Min = 500
            Max = 1500
            Position = 900
            TabOrder = 15
            Wrap = False
          end
          object EditCzasMin: TEdit
            Left = 120
            Top = 196
            Width = 36
            Height = 21
            TabOrder = 16
            Text = '10'
          end
          object UpDownCzasMin: TUpDown
            Left = 156
            Top = 196
            Width = 15
            Height = 21
            Associate = EditCzasMin
            Min = 0
            Max = 99
            Position = 10
            TabOrder = 17
            Wrap = False
          end
          object EditCzasSek: TEdit
            Left = 184
            Top = 196
            Width = 29
            Height = 21
            TabOrder = 18
            Text = '0'
          end
          object UpDownCzasSek: TUpDown
            Left = 213
            Top = 196
            Width = 15
            Height = 21
            Associate = EditCzasSek
            Min = 0
            Max = 59
            Position = 0
            TabOrder = 19
            Wrap = False
          end
          object UpDownMisjaPoziomDo: TUpDown
            Left = 228
            Top = 60
            Width = 12
            Height = 21
            Associate = EditMisjaPoziomDo
            Min = 1
            Max = 99
            Position = 1
            TabOrder = 20
            Wrap = False
            OnClick = UpDownMisjaPoziomDoClick
          end
          object EditMisjaPoziomDo: TEdit
            Left = 192
            Top = 60
            Width = 36
            Height = 21
            TabOrder = 21
            Text = '1'
          end
          object EditMisjaGrawitacjaDo: TEdit
            Left = 192
            Top = 82
            Width = 36
            Height = 21
            TabOrder = 22
            Text = '25'
          end
          object UpDownMisjaGrawitacjaDo: TUpDown
            Left = 228
            Top = 82
            Width = 12
            Height = 21
            Associate = EditMisjaGrawitacjaDo
            Min = 1
            Max = 99
            Position = 25
            TabOrder = 23
            Wrap = False
            OnClick = UpDownMisjaGrawitacjaDoClick
          end
          object EditMisjaGestoscDo: TEdit
            Left = 192
            Top = 104
            Width = 36
            Height = 21
            TabOrder = 24
            Text = '25'
          end
          object UpDownMisjaGestoscDo: TUpDown
            Left = 228
            Top = 104
            Width = 12
            Height = 21
            Associate = EditMisjaGestoscDo
            Min = 1
            Max = 99
            Position = 25
            TabOrder = 25
            Wrap = False
            OnClick = UpDownMisjaGestoscDoClick
          end
          object EditMisjaWiatrDo: TEdit
            Left = 192
            Top = 126
            Width = 36
            Height = 21
            TabOrder = 26
            Text = '15'
          end
          object UpDownMisjaWiatrDo: TUpDown
            Left = 228
            Top = 126
            Width = 12
            Height = 21
            Associate = EditMisjaWiatrDo
            Min = 1
            Max = 99
            Position = 15
            TabOrder = 27
            Wrap = False
            OnClick = UpDownMisjaWiatrDoClick
          end
          object EditMaxMysliwcow: TEdit
            Left = 120
            Top = 170
            Width = 36
            Height = 21
            TabOrder = 28
            Text = '1'
          end
          object UpDownMaxMysliwcow: TUpDown
            Left = 156
            Top = 170
            Width = 15
            Height = 21
            Associate = EditMaxMysliwcow
            Min = 0
            Max = 30
            Position = 1
            TabOrder = 29
            Wrap = False
            OnClick = UpDownMaxMysliwcowClick
          end
          object EditMaxMysliwcowDo: TEdit
            Left = 192
            Top = 170
            Width = 36
            Height = 21
            TabOrder = 30
            Text = '1'
          end
          object UpDownMaxMysliwcowDo: TUpDown
            Left = 228
            Top = 170
            Width = 12
            Height = 21
            Associate = EditMaxMysliwcowDo
            Min = 0
            Max = 30
            Position = 1
            TabOrder = 31
            Wrap = False
            OnClick = UpDownMaxMysliwcowDoClick
          end
        end
        object GroupBox1: TGroupBox
          Left = 1
          Top = 224
          Width = 255
          Height = 37
          Align = alTop
          Caption = 'Kolor nieba'
          TabOrder = 1
          DesignSize = (
            255
            37)
          object Kolornieba: TShape
            Left = 3
            Top = 13
            Width = 150
            Height = 20
            Cursor = crHandPoint
            Brush.Color = 13543799
            OnMouseDown = KolorniebaMouseDown
          end
          object SpeedButton1: TSpeedButton
            Left = 157
            Top = 14
            Width = 93
            Height = 19
            Anchors = [akLeft, akTop, akRight]
            Caption = 'Losuj kolor'
            OnClick = SpeedButton1Click
          end
        end
        object Panel2: TPanel
          Left = 1
          Top = 261
          Width = 255
          Height = 46
          Align = alTop
          BevelOuter = bvLowered
          Color = 13348762
          TabOrder = 2
          object Label1: TLabel
            Left = 4
            Top = 4
            Width = 75
            Height = 13
            Caption = 'Wymiary mapy:'
          end
          object Label2: TLabel
            Left = 58
            Top = 24
            Width = 6
            Height = 13
            Caption = 'x'
          end
          object BtnZmienWymiar: TSpeedButton
            Left = 200
            Top = 6
            Width = 49
            Height = 35
            Caption = 'Zmie'#324' >>'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            OnClick = BtnZmienWymiarClick
          end
          object Label3: TLabel
            Left = 119
            Top = 26
            Width = 6
            Height = 13
            Caption = '*'
          end
          object EditWymX: TEdit
            Left = 5
            Top = 21
            Width = 36
            Height = 21
            Hint = 'wymiar X'
            ParentShowHint = False
            ReadOnly = True
            ShowHint = True
            TabOrder = 0
            Text = '154'
          end
          object UpDownWymX: TUpDown
            Left = 41
            Top = 21
            Width = 15
            Height = 21
            Associate = EditWymX
            Min = 49
            Max = 500
            Increment = 7
            Position = 154
            TabOrder = 1
            Wrap = False
          end
          object EditWymZ: TEdit
            Left = 66
            Top = 21
            Width = 34
            Height = 21
            Hint = 'wymiar Z'
            ParentShowHint = False
            ReadOnly = True
            ShowHint = True
            TabOrder = 2
            Text = '154'
          end
          object UpDownWymZ: TUpDown
            Left = 100
            Top = 21
            Width = 12
            Height = 21
            Associate = EditWymZ
            Min = 49
            Max = 500
            Increment = 7
            Position = 154
            TabOrder = 3
            Wrap = False
          end
          object UpDownWymWlk: TUpDown
            Left = 153
            Top = 21
            Width = 15
            Height = 21
            Associate = EditWymWlk
            Min = 10
            Position = 35
            TabOrder = 4
            Wrap = False
            OnClick = UpDownWymWlkClick
          end
          object EditWymWlk: TEdit
            Left = 126
            Top = 21
            Width = 27
            Height = 21
            Hint = 'skala (wielko'#347#263' jednej "kratki" mapy w grze)'
            ParentShowHint = False
            ReadOnly = True
            ShowHint = True
            TabOrder = 5
            Text = '35'
          end
        end
        object GroupBox6: TGroupBox
          Left = 1
          Top = 338
          Width = 255
          Height = 95
          Align = alTop
          Caption = 'Tekst na rozpocz'#281'cie misji'
          TabOrder = 3
          DesignSize = (
            255
            95)
          object MemoIntro: TMemo
            Left = 3
            Top = 13
            Width = 248
            Height = 78
            Hint = 
              'Symbole:'#13#10'%1 - ilo'#347#263' potrzebnych ludzi'#13#10'%2 - ilo'#347#263' wszystkich lu' +
              'dzi'#13#10'%3 - ilo'#347#263' dzia'#322'ek do zniszczenia'#13#10'%4 - ilo'#347#263' wszystkich dz' +
              'ia'#322'ek'#13#10'%5 - czas na wykonanie misji'
            Anchors = [akLeft, akTop, akRight, akBottom]
            BorderStyle = bsNone
            Color = 15195089
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            ParentShowHint = False
            ScrollBars = ssBoth
            ShowHint = True
            TabOrder = 0
            WordWrap = False
            OnExit = MemoIntroExit
          end
        end
        object GroupBox7: TGroupBox
          Left = 1
          Top = 307
          Width = 255
          Height = 31
          Align = alTop
          Caption = 'Nazwa miejsca (planety)'
          TabOrder = 4
          DesignSize = (
            255
            31)
          object MemoNazwa: TEdit
            Left = 4
            Top = 13
            Width = 246
            Height = 14
            Anchors = [akLeft, akTop, akRight, akBottom]
            BorderStyle = bsNone
            Color = 15195089
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            Text = 'PLANETA X'
          end
        end
        object GroupBox8: TGroupBox
          Left = 1
          Top = 433
          Width = 255
          Height = 89
          Align = alTop
          Caption = 'Tekst po wygraniu misji'
          TabOrder = 5
          DesignSize = (
            255
            89)
          object MemoOutroWin: TMemo
            Left = 3
            Top = 13
            Width = 248
            Height = 72
            Hint = 
              'Symbole:'#13#10'%1 - ilo'#347#263' potrzebnych ludzi'#13#10'%2 - ilo'#347#263' wszystkich lu' +
              'dzi'#13#10'%3 - ilo'#347#263' dzia'#322'ek do zniszczenia'#13#10'%4 - ilo'#347#263' wszystkich dz' +
              'ia'#322'ek'#13#10'%5 - czas na wykonanie misji'
            Anchors = [akLeft, akTop, akRight, akBottom]
            BorderStyle = bsNone
            Color = 15195089
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            ParentShowHint = False
            ScrollBars = ssBoth
            ShowHint = True
            TabOrder = 0
            WordWrap = False
            OnExit = MemoIntroExit
          end
        end
        object GroupBox9: TGroupBox
          Left = 1
          Top = 522
          Width = 255
          Height = 110
          Align = alTop
          Caption = 'Tekst po przegraniu misji'
          TabOrder = 6
          DesignSize = (
            255
            110)
          object BtnDomyslneTeksty: TSpeedButton
            Left = 123
            Top = 90
            Width = 129
            Height = 17
            Anchors = [akTop, akRight]
            Caption = 'ustaw domy'#347'lne teksty'
            OnClick = BtnDomyslneTekstyClick
          end
          object MemoOutroLost: TMemo
            Left = 3
            Top = 13
            Width = 248
            Height = 75
            Hint = 
              'Symbole:'#13#10'%1 - ilo'#347#263' potrzebnych ludzi'#13#10'%2 - ilo'#347#263' wszystkich lu' +
              'dzi'#13#10'%3 - ilo'#347#263' dzia'#322'ek do zniszczenia'#13#10'%4 - ilo'#347#263' wszystkich dz' +
              'ia'#322'ek'#13#10'%5 - czas na wykonanie misji'
            Anchors = [akLeft, akTop, akRight, akBottom]
            BorderStyle = bsNone
            Color = 15195089
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            ParentShowHint = False
            ScrollBars = ssBoth
            ShowHint = True
            TabOrder = 0
            WordWrap = False
            OnExit = MemoIntroExit
          end
        end
      end
    end
    object TabUstawienia2: TTabSheet
      Caption = 'Ustawienia2'
      ImageIndex = 3
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 257
        Height = 632
        Align = alClient
        Color = 14008238
        TabOrder = 0
        object GroupBoxMinUpgrade: TGroupBox
          Left = 3
          Top = 572
          Width = 251
          Height = 37
          Caption = 'Minimalne warunki pocz'#261'tkowe dla gracza'
          TabOrder = 0
          Visible = False
        end
        object GroupBox10: TGroupBox
          Left = 3
          Top = 8
          Width = 251
          Height = 95
          Caption = 'Muzyka w tle'
          TabOrder = 1
          object Label24: TLabel
            Left = 8
            Top = 16
            Width = 236
            Height = 47
            AutoSize = False
            Caption = 
              'Nazwa pliku mp3 w podkatalogu dane\ . Musi by'#263' bez rozszerzenia!' +
              ' Pozostaw puste w celu wybrania muzyki domy'#347'lnej'
            WordWrap = True
          end
          object EditMuzyka: TEdit
            Left = 5
            Top = 68
            Width = 241
            Height = 21
            TabOrder = 0
          end
        end
      end
    end
    object TabOperacje: TTabSheet
      Caption = 'Operacje'
      ImageIndex = 2
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 257
        Height = 632
        Align = alClient
        Color = 14008238
        TabOrder = 0
        object Bevel1: TBevel
          Left = 6
          Top = 423
          Width = 244
          Height = 47
        end
        object BtnBlur: TSpeedButton
          Left = 6
          Top = 327
          Width = 244
          Height = 22
          Caption = 'Wyg'#322'ad'#378' ca'#322#261' mapk'#281' (blur) (Ctrl+B)'
          OnClick = btnrozmyjClick
        end
        object BtnZnieksztalc: TSpeedButton
          Left = 6
          Top = 351
          Width = 244
          Height = 22
          Caption = 'Zniekszta'#322#263' ca'#322#261' mapk'#281' (Ctrl+H)'
          OnClick = Znieksztaca1Click
        end
        object BtnZmienWys: TSpeedButton
          Left = 6
          Top = 375
          Width = 190
          Height = 22
          Caption = 'Zmie'#324' wysoko'#347#263' ca'#322'ej mapy o...'
          OnClick = BtnZmienWysClick
        end
        object BtnSkalujWys: TSpeedButton
          Left = 6
          Top = 399
          Width = 190
          Height = 22
          Caption = 'Przeskaluj wysoko'#347#263' ca'#322'ej mapy w %'
          OnClick = BtnSkalujWysClick
        end
        object BtnSceneria: TSpeedButton
          Left = 6
          Top = 423
          Width = 244
          Height = 22
          Caption = 'Automatycznie wyznacz sceneri'#281' (Ctrl+K)'
          OnClick = BtnSceneriaClick
        end
        object Label22: TLabel
          Left = 8
          Top = 451
          Width = 28
          Height = 13
          Caption = 'ile %:'
        end
        object Label23: TLabel
          Left = 95
          Top = 451
          Width = 102
          Height = 13
          Caption = 'tolerancja krzywizny:'
        end
        object GroupBoxKolorowanie: TGroupBox
          Left = 3
          Top = 4
          Width = 251
          Height = 205
          Caption = 'Kolorowanie wed'#322'ug wysoko'#347'ci'
          TabOrder = 0
          DesignSize = (
            251
            205)
          object BtnLosujKol: TSpeedButton
            Left = 5
            Top = 178
            Width = 90
            Height = 20
            Anchors = [akLeft, akBottom]
            Caption = 'Losuj kolory'
            OnClick = BtnLosujKolClick
          end
          object BtnNalozKolory: TSpeedButton
            Left = 155
            Top = 178
            Width = 90
            Height = 20
            Anchors = [akLeft, akBottom]
            Caption = 'Wykonaj >>'
            OnClick = BtnNalozKoloryClick
          end
        end
        object GroupBox2: TGroupBox
          Left = 3
          Top = 212
          Width = 251
          Height = 53
          Caption = 'Dodawanie losowo dzia'#322'ek'
          TabOrder = 1
          object BtnLosDzial: TSpeedButton
            Left = 155
            Top = 21
            Width = 90
            Height = 20
            Caption = 'Wykonaj >>'
            OnClick = BtnLosDzialClick
          end
          object Label11: TLabel
            Left = 14
            Top = 22
            Width = 20
            Height = 13
            Caption = 'ilo'#347#263
          end
          object EditLosDzial: TEdit
            Left = 46
            Top = 19
            Width = 36
            Height = 21
            TabOrder = 0
            Text = '1'
          end
          object UpDownLosDzial: TUpDown
            Left = 82
            Top = 19
            Width = 15
            Height = 21
            Associate = EditLosDzial
            Min = 1
            Max = 50
            Position = 1
            TabOrder = 1
            Wrap = False
          end
        end
        object GroupBox5: TGroupBox
          Left = 3
          Top = 268
          Width = 251
          Height = 53
          Caption = 'Dodawanie losowo l'#261'dowisk'
          TabOrder = 2
          object BtnLosLad: TSpeedButton
            Left = 155
            Top = 21
            Width = 90
            Height = 20
            Caption = 'Wykonaj >>'
            OnClick = BtnLosLadClick
          end
          object Label12: TLabel
            Left = 14
            Top = 22
            Width = 20
            Height = 13
            Caption = 'ilo'#347#263
          end
          object EditLosLad: TEdit
            Left = 46
            Top = 19
            Width = 36
            Height = 21
            TabOrder = 0
            Text = '1'
          end
          object UpDownLosLad: TUpDown
            Left = 82
            Top = 19
            Width = 15
            Height = 21
            Associate = EditLosLad
            Min = 1
            Max = 50
            Position = 1
            TabOrder = 1
            Wrap = False
          end
          object ChLadLosJakie: TCheckBox
            Left = 101
            Top = 21
            Width = 52
            Height = 17
            Hint = 'L'#261'dowiska dobre (dla gracza) czy wroga'
            Caption = 'Dobre'
            Checked = True
            ParentShowHint = False
            ShowHint = True
            State = cbChecked
            TabOrder = 2
          end
        end
        object EditZmienWys: TEdit
          Left = 198
          Top = 375
          Width = 36
          Height = 21
          TabOrder = 3
          Text = '1'
        end
        object UpDownZmienWys: TUpDown
          Left = 234
          Top = 375
          Width = 15
          Height = 21
          Associate = EditZmienWys
          Min = -100
          Position = 1
          TabOrder = 4
          Wrap = False
        end
        object EditSkalujWys: TEdit
          Left = 198
          Top = 399
          Width = 36
          Height = 21
          TabOrder = 5
          Text = '100'
        end
        object UpDownSkalujWys: TUpDown
          Left = 234
          Top = 399
          Width = 15
          Height = 21
          Associate = EditSkalujWys
          Min = 1
          Max = 400
          Position = 100
          TabOrder = 6
          Wrap = False
        end
        object EditScenTolerancja: TEdit
          Left = 200
          Top = 447
          Width = 36
          Height = 21
          TabOrder = 7
          Text = '8'
        end
        object UpDownScenTolerancja: TUpDown
          Left = 236
          Top = 447
          Width = 12
          Height = 21
          Associate = EditScenTolerancja
          Min = 1
          Max = 300
          Position = 8
          TabOrder = 8
          Wrap = False
        end
        object EditScenIle: TEdit
          Left = 38
          Top = 447
          Width = 36
          Height = 21
          TabOrder = 9
          Text = '13'
        end
        object UpDownScenIle: TUpDown
          Left = 74
          Top = 447
          Width = 12
          Height = 21
          Associate = EditScenIle
          Min = 1
          Position = 13
          TabOrder = 10
          Wrap = False
        end
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 32
    Top = 32
    object Mapka1: TMenuItem
      Caption = 'Mapka'
      object Stwrzpust1: TMenuItem
        Caption = 'Stw'#243'rz pust'#261
        ShortCut = 16462
        OnClick = Stwrzpust1Click
      end
      object Wygenerujlosow1: TMenuItem
        Caption = 'Wygeneruj losow'#261
        ShortCut = 16455
        OnClick = btngenerujClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Wczytaj1: TMenuItem
        Caption = 'Wczytaj'
        ShortCut = 16463
        OnClick = Button3Click
      end
      object Zapisz1: TMenuItem
        Caption = 'Zapisz'
        ShortCut = 16467
        OnClick = Button2Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Wyjcie1: TMenuItem
        Caption = 'Wyj'#347'cie'
        OnClick = Wyjcie1Click
      end
    end
    object Operacjenamapce1: TMenuItem
      Caption = 'Operacje na mapce'
      object Wygadcablur1: TMenuItem
        Caption = 'Wyg'#322'ad'#380' ca'#322#261' (blur)'
        ShortCut = 16450
        OnClick = btnrozmyjClick
      end
      object Znieksztaca1: TMenuItem
        Caption = 'Zniekszta'#322#263' ca'#322#261
        ShortCut = 16456
        OnClick = Znieksztaca1Click
      end
      object Automatyczniewyznaczsceneri1: TMenuItem
        Caption = 'Automatycznie wyznacz sceneri'#281
        ShortCut = 16459
        OnClick = BtnSceneriaClick
      end
    end
    object Edytorepizodw1: TMenuItem
      Caption = 'Edytor epizod'#243'w'
      OnClick = Edytorepizodw1Click
    end
  end
  object ColorDialog1: TColorDialog
    Ctl3D = True
    Options = [cdFullOpen, cdAnyColor]
    Left = 600
    Top = 16
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'map'
    Filter = 'Pliki map do gry|*.map'
    InitialDir = '.\misje'
    Options = [ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Otw'#243'rz mapk'#281
    Left = 24
    Top = 104
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'map'
    Filter = 'Pliki map do gry|*.map'
    InitialDir = '.\misje'
    Options = [ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofEnableSizing]
    Title = 'Zapisz mapk'#281
    Left = 80
    Top = 104
  end
end
