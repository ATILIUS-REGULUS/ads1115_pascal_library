{ ####################################################################################### }
{ ##                                                                                   ## }
{ ## Main_Unit                                                                         ## }
{ ##                                                                                   ## }
{ ## Main form for ADS1115                                                             ## }
{ ##                                                                                   ## }
{ ## Copyright (C) 2018-2019  : Dr. Jürgen Abel                                        ## }
{ ## Email                    : juergen@mve.info                                       ## }
{ ## Internet                 : https://www.juergen-abel.info                          ## }
{ ##                                                                                   ## }
{ ## This program is free software: you can redistribute it and/or modify              ## }
{ ## it under the terms of the GNU Lesser General Public License as published by       ## }
{ ## the Free Software Foundation, either version 3 of the License, or                 ## }
{ ## (at your option) any later version with the following modification:               ## }
{ ##                                                                                   ## }
{ ## As a special exception, the copyright holders of this library give you            ## }
{ ## permission to link this library with independent modules to produce an            ## }
{ ## executable, regardless of the license terms of these independent modules, and     ## }
{ ## to copy and distribute the resulting executable under terms of your choice,       ## }
{ ## provided that you also meet, for each linked independent module, the terms        ## }
{ ## and conditions of the license of that module. An independent module is a          ## }
{ ## module which is not derived from or based on this library. If you modify          ## }
{ ## this library, you may extend this exception to your version of the library,       ## }
{ ## but you are not obligated to do so. If you do not wish to do so, delete this      ## }
{ ## exception statement from your version.                                            ## }
{ ##                                                                                   ## }
{ ## This program is distributed in the hope that it will be useful,                   ## }
{ ## but WITHOUT ANY WARRANTY; without even the implied warranty of                    ## }
{ ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                     ## }
{ ## GNU General Public License for more details.                                      ## }
{ ##                                                                                   ## }
{ ## You should have received a copy of the GNU Lesser General Public License          ## }
{ ## COPYING.LGPL.txt along with this program.                                         ## }
{ ## If not, see <https://www.gnu.org/licenses/>.                                      ## }
{ ##                                                                                   ## }
{ ####################################################################################### }


Unit Main_Unit;

{$mode objfpc}{$H+}

Interface

Uses
  CThreads, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  TAGraph, TASeries, ADS1115_Unit, TACustomSeries;

Const
  GPIO_INTERRUPT_PIN = 25;
  CHART_INTERVAL     = 1000;
  CHART_SIZE         = 4000;
  ARRAY_SIZE         = 100000;
  CHART_START_Y      = 32000;

Type
  { ####################################################################################### }
  { ## T_Timer_Thread                                                                    ## }
  { ####################################################################################### }
  T_Timer_Thread = Class (TThread)
  Protected
      Procedure Execute; Override;
  Public
      M_X_A :       Array [0 .. ARRAY_SIZE - 1] Of TDateTime;
      M_Y_A :       Array [0 .. ARRAY_SIZE - 1] Of Integer;
      M_A_Input_P : integer;
      M_ADS1115 :   T_ADS1115;
      M_X :         Integer;
      Constructor Create (F_Suspended : Boolean);
      Destructor Destroy; Override;
  End; { T_Timer_Thread }

  { ####################################################################################### }
  { ## TMain_F                                                                           ## }
  { ####################################################################################### }
  TMain_F = Class (TForm)
      ADC_C :           TChart;
      ConstantLine :    TConstantLine;
      Chart_S :         TLineSeries;
      Close_B :         TButton;
      Label3 :          TLabel;
      Output_NPS_E :    TEdit;
      Output_EPanel1 :  TPanel;
      Chart_T :         TTimer;
      Procedure Chart_TTimer (Sender : TObject);
      Procedure Close_BClick (Sender : TObject);
      Procedure FormCreate (Sender : TObject);
      Procedure FormShow (Sender : TObject);
  Protected
      M_Timer_Thread : T_Timer_Thread;
      M_A_Output_0_P : integer;
      M_A_Output_1_P : integer;
      M_Start_Time :   TDateTime;
      M_End_Time :     TDateTime;
  Public
  End; { TMain_F }

Var
  Main_F : TMain_F;

Implementation

{$R *.frm}

Uses
  DateUtils;

{ ####################################################################################### }
{ ## T_Timer_Thread                                                                    ## }
{ ####################################################################################### }

{ --------------------------------------------------------------------------------------- }
Constructor T_Timer_Thread.Create (F_Suspended : Boolean);
{ Create timer thread                                                                     }
{ --------------------------------------------------------------------------------------- }
Begin { T_Timer_Thread.Create }
  FreeOnTerminate := FALSE;

  M_ADS1115 := T_ADS1115.Create (ADS1115_ADDRESS, ADS1115_REGISTER_CONFIG_PGA_0_256V);
  M_ADS1115.Start_ADC_Differential_0_1_Continuous_Conversion ();

  M_X         := 0;
  M_A_Input_P := 0;

  Inherited Create (F_Suspended);
End; { T_Timer_Thread.Create }


{ --------------------------------------------------------------------------------------- }
Destructor T_Timer_Thread.Destroy ();
{ Free data                                                                               }
{ --------------------------------------------------------------------------------------- }
Begin { T_Timer_Thread.Destroy }
  M_ADS1115.Stop_ALERT_RDY ();
  M_ADS1115.Free;

  Inherited Destroy;
End; { T_Timer_Thread.Destroy }


{ --------------------------------------------------------------------------------------- }
Procedure T_Timer_Thread.Execute;
{ Execute thread                                                                          }
{ --------------------------------------------------------------------------------------- }
Begin { T_Timer_Thread.Execute }
  While (Terminated = FALSE) Do
    Begin { While }
      Sleep (2);

      M_X_A[M_A_Input_P] := M_X;
      M_Y_A[M_A_Input_P] := M_ADS1115.Get_Last_Conversion_Result ();

      Inc (M_X);
      Inc (M_A_Input_P);
      If M_A_Input_P >= ARRAY_SIZE Then
        Begin { then }
          M_A_Input_P := 0;
        End; { then }
    End; { While }
End; { T_Timer_Thread.Execute }


{ ####################################################################################### }
{ ## TMain_F                                                                           ## }
{ ####################################################################################### }

{ --------------------------------------------------------------------------------------- }
Procedure TMain_F.FormCreate (Sender : TObject);
{ Create main from                                                                        }
{ --------------------------------------------------------------------------------------- }
Begin { TMain_F.FormCreate }
  Chart_S.Clear;
  ADC_C.Extent.YMax := CHART_START_Y;
  ADC_C.Extent.YMin := -CHART_START_Y;

  M_Timer_Thread := T_Timer_Thread.Create (TRUE);
End; { TMain_F.FormCreate }


{ --------------------------------------------------------------------------------------- }
Procedure TMain_F.FormShow (Sender : TObject);
{ Show main form                                                                          }
{ --------------------------------------------------------------------------------------- }
Begin { TMain_F.FormShow }
  M_A_Output_0_P := 0;

  Chart_T.Interval := CHART_INTERVAL;
  Chart_T.Enabled  := TRUE;

  M_Timer_Thread.Start;

  M_Start_Time := Now;
  M_End_Time   := Now;
End; { TMain_F.FormShow }


{ --------------------------------------------------------------------------------------- }
Procedure TMain_F.Close_BClick (Sender : TObject);
{ Close button pressed                                                                    }
{ --------------------------------------------------------------------------------------- }
Begin { TMain_F.Close_BClick }
  Chart_T.Enabled := FALSE;

  M_Timer_Thread.Terminate;
  Sleep (100);
  M_Timer_Thread.Free;

  Close;
End; { TMain_F.Close_BClick }


{ --------------------------------------------------------------------------------------- }
Procedure TMain_F.Chart_TTimer (Sender : TObject);
{ Repaint chart                                                                           }
{ --------------------------------------------------------------------------------------- }
Var
  I : Integer;

Begin { TMain_F.Chart_TTimer }
  Chart_S.BeginUpdate;

  M_A_Output_1_P := M_Timer_Thread.M_A_Input_P - 1;
  For I          := M_A_Output_0_P To M_A_Output_1_P Do
    Begin { For }
      Chart_S.AddXY (M_Timer_Thread.M_X_A [I], M_Timer_Thread.M_Y_A [I]);
    End; { For }
  Chart_S.EndUpdate;

  ADC_C.Extent.XMin := M_Timer_Thread.M_X - CHART_SIZE;
  ADC_C.Extent.XMax := M_Timer_Thread.M_X;

  M_End_Time := Now;

  Output_NPS_E.Text    := FormatFloat ('#.##0.000', Double (M_A_Output_1_P - M_A_Output_0_P) / (Double (MilliSecondSpan (M_Start_Time, M_End_Time)) / 1000));
  Application.ProcessMessages;

  M_Start_Time   := M_End_Time;
  M_A_Output_0_P := M_A_Output_1_P;
End; { TMain_F.Chart_TTimer }


End.
