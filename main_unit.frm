object Main_F: TMain_F
  Left = 879
  Height = 557
  Top = 218
  Width = 918
  Caption = 'Main_F'
  ClientHeight = 557
  ClientWidth = 918
  OnCreate = FormCreate
  OnShow = FormShow
  Position = poDesktopCenter
  LCLVersion = '6.7'
  WindowState = wsMaximized
  object Output_EPanel1: TPanel
    Left = 0
    Height = 40
    Top = 517
    Width = 918
    Align = alBottom
    ChildSizing.EnlargeHorizontal = crsHomogenousSpaceResize
    ChildSizing.EnlargeVertical = crsHomogenousSpaceResize
    ChildSizing.Layout = cclLeftToRightThenTopToBottom
    ChildSizing.ControlsPerLine = 7
    ClientHeight = 40
    ClientWidth = 918
    ParentFont = False
    TabOrder = 0
    object Close_B: TButton
      Left = 134
      Height = 28
      Top = 6
      Width = 38
      Cancel = True
      Caption = 'Close'
      OnClick = Close_BClick
      ParentFont = False
      TabOrder = 0
    end
    object Label3: TLabel
      Left = 306
      Height = 28
      Top = 6
      Width = 185
      Caption = 'Number of measurements/second'
      Layout = tlCenter
      ParentColor = False
    end
    object Output_NPS_E: TEdit
      Left = 625
      Height = 28
      Top = 6
      Width = 160
      Constraints.MinWidth = 160
      TabOrder = 1
    end
  end
  object ADC_C: TChart
    Left = 0
    Height = 517
    Top = 0
    Width = 918
    AxisList = <    
      item
        Marks.LabelBrush.Style = bsClear
        Minors = <>
        Title.LabelFont.Orientation = 900
        Title.LabelBrush.Style = bsClear
      end    
      item
        Alignment = calBottom
        AtDataOnly = True
        Marks.LabelBrush.Style = bsClear
        Minors = <>
        Title.LabelBrush.Style = bsClear
      end>
    Extent.UseXMax = True
    Extent.UseXMin = True
    Extent.UseYMax = True
    Extent.UseYMin = True
    Extent.XMax = 10
    Extent.YMax = 100
    Extent.YMin = -100
    Foot.Brush.Color = clBtnFace
    Foot.Font.Color = clBlue
    Title.Brush.Color = clBtnFace
    Title.Font.Color = clBlue
    Title.Text.Strings = (
      'TAChart'
    )
    Align = alClient
    DoubleBuffered = True
    Enabled = False
    object Chart_S: TLineSeries
      Marks.Visible = False
    end
    object ConstantLine: TConstantLine
      Pen.Color = clNavy
      Pen.Width = 3
    end
  end
  object Chart_T: TTimer
    Enabled = False
    OnTimer = Chart_TTimer
    Left = 64
    Top = 56
  end
end
