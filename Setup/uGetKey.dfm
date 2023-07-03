object GetKeyWindow: TGetKeyWindow
  Left = 169
  Top = 742
  BorderStyle = bsDialog
  Caption = 'Control change'
  ClientHeight = 505
  ClientWidth = 749
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Microsoft Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poMainFormCenter
  OnHide = FormHide
  OnShow = FormShow
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 749
    Height = 449
    Align = alClient
    BevelInner = bvLowered
    Color = clBtnHighlight
    TabOrder = 0
    ExplicitWidth = 745
    ExplicitHeight = 448
    object lbInfo: TLabel
      Left = 2
      Top = 15
      Width = 745
      Height = 432
      Align = alClient
      Alignment = taCenter
      Caption = 'Press a key or ESC to cancel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -23
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
      ExplicitWidth = 337
      ExplicitHeight = 29
    end
    object lbJoyDebug: TLabel
      Left = 2
      Top = 2
      Width = 745
      Height = 13
      Align = alTop
      Caption = 'Joy'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      Visible = False
      ExplicitWidth = 16
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 449
    Width = 749
    Height = 56
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 448
    ExplicitWidth = 745
    object btnTest: TSpeedButton
      Left = 10
      Top = 14
      Width = 111
      Height = 25
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Controller test'
      Visible = False
      OnClick = btnTestClick
    end
    object btnNone: TButton
      Left = 145
      Top = 14
      Width = 105
      Height = 25
      Caption = 'None'
      TabOrder = 0
      TabStop = False
      OnClick = btnNoneClick
    end
    object btnCancel: TButton
      Left = 272
      Top = 14
      Width = 99
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      TabStop = False
      OnClick = btnCancelClick
    end
  end
  object chInverseControl: TCheckBox
    Left = 32
    Top = 400
    Width = 481
    Height = 17
    Caption = 'Inverse control for analog axis'
    TabOrder = 2
  end
  object PowerTimer1: TPowerTimer
    FPS = 60
    MayProcess = False
    MayRender = False
    MayRealTime = False
    OnRender = PowerTimer1Render
    OnProcess = PowerTimer1Process
    Left = 8
    Top = 280
  end
  object PowerInput1: TPowerInput
    DoJoystick = True
    Left = 16
    Top = 248
  end
end
