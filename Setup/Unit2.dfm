object Form2: TForm2
  Left = 169
  Top = 742
  BorderStyle = bsNone
  Caption = 'Form2'
  ClientHeight = 68
  ClientWidth = 288
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 288
    Height = 68
    Align = alClient
    BevelInner = bvLowered
    Caption = 'Panel1'
    Color = clBtnHighlight
    TabOrder = 0
    object Label1: TLabel
      Left = 2
      Top = 2
      Width = 284
      Height = 64
      Align = alClient
      Alignment = taCenter
      Caption = 
        'Wci'#347'nij wybrany klawisz dla tego zdarzenia lub wci'#347'nij ESC by an' +
        'ulowa'#263'.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
    end
  end
  object PowerTimer1: TPowerTimer
    FPS = 60
    MayProcess = False
    MayRender = False
    MayRealTime = False
    OnProcess = PowerTimer1Process
    Left = 120
    Top = 16
  end
  object PowerInput1: TPowerInput
    Left = 112
    Top = 8
  end
end
