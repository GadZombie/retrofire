object FormEpizody: TFormEpizody
  Left = 257
  Top = 112
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Epizody'
  ClientHeight = 452
  ClientWidth = 548
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btndodaj: TSpeedButton
    Left = 254
    Top = 32
    Width = 30
    Height = 32
    Caption = #273
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'Wingdings'
    Font.Style = []
    ParentFont = False
    OnClick = btndodajClick
  end
  object btnusun: TSpeedButton
    Left = 254
    Top = 64
    Width = 30
    Height = 32
    Caption = #271
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'Wingdings'
    Font.Style = []
    ParentFont = False
    OnClick = btnusunClick
  end
  object btndol: TSpeedButton
    Left = 254
    Top = 136
    Width = 30
    Height = 28
    Caption = #226
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'Wingdings'
    Font.Style = []
    ParentFont = False
    OnClick = btndolClick
  end
  object btngora: TSpeedButton
    Left = 254
    Top = 104
    Width = 30
    Height = 28
    Caption = #225
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'Wingdings'
    Font.Style = []
    ParentFont = False
    OnClick = btngoraClick
  end
  object ListaMap: TListBox
    Left = 2
    Top = 31
    Width = 249
    Height = 391
    Hint = 'Dost'#281'pne mapy'
    DragMode = dmAutomatic
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnDblClick = btndodajClick
    OnDragDrop = ListaMapDragDrop
    OnDragOver = ListaMapDragOver
  end
  object MapyEpizodu: TListBox
    Tag = 1
    Left = 288
    Top = 30
    Width = 257
    Height = 391
    Hint = 'Mapy w epizodzie'
    DragMode = dmAutomatic
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnDblClick = btnusunClick
    OnDragDrop = MapyEpizoduDragDrop
    OnDragOver = MapyEpizoduDragOver
  end
  object PanelListaMap: TPanel
    Left = 0
    Top = 424
    Width = 257
    Height = 25
    TabOrder = 2
  end
  object PanelMapyEpizodu: TPanel
    Left = 282
    Top = 424
    Width = 266
    Height = 25
    TabOrder = 3
  end
  object Tytulepizodu: TLabeledEdit
    Left = 80
    Top = 6
    Width = 465
    Height = 21
    EditLabel.Width = 65
    EditLabel.Height = 13
    EditLabel.Caption = 'Tytu'#322' epizodu'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    LabelPosition = lpLeft
    LabelSpacing = 3
    MaxLength = 254
    ParentFont = False
    TabOrder = 4
  end
  object MainMenu1: TMainMenu
    Left = 296
    Top = 192
    object Epizod1: TMenuItem
      Caption = 'Epizod'
      object Nowy1: TMenuItem
        Caption = 'Nowy'
        ShortCut = 16462
        OnClick = Nowy1Click
      end
      object Zapisz1: TMenuItem
        Caption = 'Zapisz'
        ShortCut = 16467
        OnClick = Zapisz1Click
      end
      object Wczytaj1: TMenuItem
        Caption = 'Wczytaj'
        ShortCut = 16463
        OnClick = Wczytaj1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Zamknijokno1: TMenuItem
        Caption = 'Zamknij okno'
        OnClick = Zamknijokno1Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'RFepz'
    Filter = 'Pliki epizod'#243'w do gry|*.RFepz'
    InitialDir = '.\misje'
    Options = [ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Otw'#243'rz epizod'
    Left = 24
    Top = 104
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'RFepz'
    Filter = 'Pliki epizod'#243'w do gry|*.RFepz'
    InitialDir = '.\misje'
    Options = [ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofEnableSizing]
    Title = 'Zapisz epizod'
    Left = 80
    Top = 104
  end
end
