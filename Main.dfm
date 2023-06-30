object frmMain: TfrmMain
  Left = 632
  Top = 431
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Retrofire'
  ClientHeight = 470
  ClientWidth = 630
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnResize = FormResize
  TextHeight = 13
  object PowerTimer1: TPowerTimer
    FPS = 60
    MayProcess = False
    MayRender = False
    MayRealTime = False
    OnRender = PowerTimer1Render
    OnProcess = PowerTimer1Process
    Left = 16
    Top = 8
  end
  object PwrInp: TPowerInput
    Left = 32
    Top = 72
  end
  object TimerCzas: TTimer
    Enabled = False
    OnTimer = TimerCzasTimer
    Left = 128
    Top = 32
  end
end
