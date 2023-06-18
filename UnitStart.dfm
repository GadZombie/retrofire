object FormStart: TFormStart
  Left = 320
  Top = 156
  BorderIcons = []
  BorderStyle = bsNone
  ClientHeight = 61
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 386
    Height = 61
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 384
      Height = 36
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Retrofire: wczytywanie danych...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object progres: TProgressBar
      Left = 11
      Top = 38
      Width = 363
      Height = 11
      Min = 0
      Max = 69
      Step = 1
      TabOrder = 0
    end
  end
end
