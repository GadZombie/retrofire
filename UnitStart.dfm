object FormStart: TFormStart
  Left = 320
  Top = 156
  BorderIcons = []
  BorderStyle = bsNone
  ClientHeight = 101
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 25
  object pnlBack: TPanel
    Left = 0
    Top = 0
    Width = 433
    Height = 101
    Align = alClient
    BevelOuter = bvNone
    Color = clWindow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    object lbTitle: TLabel
      Left = 0
      Top = 0
      Width = 433
      Height = 36
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Retrofire'
      Layout = tlCenter
      ExplicitLeft = -15
      ExplicitTop = -20
    end
    object lbLoading: TLabel
      Left = 0
      Top = 36
      Width = 433
      Height = 36
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'loading'
      Layout = tlCenter
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 384
    end
    object progres: TProgressBar
      AlignWithMargins = True
      Left = 15
      Top = 80
      Width = 403
      Height = 14
      Margins.Left = 15
      Margins.Right = 15
      Margins.Bottom = 7
      Align = alBottom
      Max = 70
      Step = 1
      TabOrder = 0
      ExplicitTop = 78
    end
  end
end
