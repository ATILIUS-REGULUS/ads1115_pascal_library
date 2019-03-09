{ ####################################################################################### }
{ ##                                                                                   ## }
{ ## ADS1115_Unit                                                                      ## }
{ ##                                                                                   ## }
{ ## Library for ADS1115                                                               ## }
{ ## Based on:                                                                         ## }
{ ## - Adafruit_ADS1015 library from K. Townsend (Adafruit Industries)                 ## }
{ ## - pascalio library: https://github.com/SAmeis/pascalio                            ## }
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

Unit ADS1115_Unit;

{$mode objfpc}{$H+}

Interface

Uses
  CThreads,
  BaseUnix,
  Classes;

Const
  { ####################################################################################### }
  { ## I2C general data                                                                  ## }
  { ####################################################################################### }
  ADS1115_ADDRESS             = $48;            // I2C adress
  ADS1115_CONVERSION_DELAY    = 8;              // Conversation delay in msec
  ADS1115_DEVICE_PATH         = '/dev/i2c-1';   // Path to device
  ADS1115_I2C_SLAVE           = $0703;          // I2C slave id
  ADS1115_I2C_SMBUS           = $0720;          // I2C SMBUS id
  ADS1115_I2C_BUFFER_MAX_SIZE = 32;             // I2C maximal buffer size


  { ####################################################################################### }
  { ## Pointer register                                                                  ## }
  { ####################################################################################### }
  ADS1115_REGISTER_POINTER_MASK             = $03;
  ADS1115_REGISTER_POINTER_CONVERT          = $00;
  ADS1115_REGISTER_POINTER_CONFIG           = $01;
  ADS1115_REGISTER_POINTER_LOW_THRESHOLD    = $02;
  ADS1115_REGISTER_POINTER_HIGH_THRESHOLD   = $03;

  { ####################################################################################### }
  { ## Config register                                                                   ## }
  { ####################################################################################### }
  ADS1115_REGISTER_CONFIG_OS_MASK           = $8000;
  ADS1115_REGISTER_CONFIG_OS_NOEFFECT       = $0000;  // When writing : No effect
  ADS1115_REGISTER_CONFIG_OS_SINGLE         = $8000;  // When writing : Set to start a single-conversion
  ADS1115_REGISTER_CONFIG_OS_BUSY           = $0000;  // When reading : Bit = 0 when conversion is in progress
  ADS1115_REGISTER_CONFIG_OS_NOTBUSY        = $8000;  // When reading : Bit = 1 when device is not performing a conversion

  ADS1115_REGISTER_CONFIG_MUX_MASK          = $7000;
  ADS1115_REGISTER_CONFIG_MUX_DIFF_0_1      = $0000;  // Differential P = AIN0, N = AIN1 (default)
  ADS1115_REGISTER_CONFIG_MUX_DIFF_0_3      = $1000;  // Differential P = AIN0, N = AIN3
  ADS1115_REGISTER_CONFIG_MUX_DIFF_1_3      = $2000;  // Differential P = AIN1, N = AIN3
  ADS1115_REGISTER_CONFIG_MUX_DIFF_2_3      = $3000;  // Differential P = AIN2, N = AIN3
  ADS1115_REGISTER_CONFIG_MUX_SINGLE_0      = $4000;  // Single-ended AIN0
  ADS1115_REGISTER_CONFIG_MUX_SINGLE_1      = $5000;  // Single-ended AIN1
  ADS1115_REGISTER_CONFIG_MUX_SINGLE_2      = $6000;  // Single-ended AIN2
  ADS1115_REGISTER_CONFIG_MUX_SINGLE_3      = $7000;  // Single-ended AIN3

  ADS1115_REGISTER_CONFIG_PGA_MASK          = $0E00;
  ADS1115_REGISTER_CONFIG_PGA_6_144V        = $0000;  // +/-6.144V range = Gain 2/3
  ADS1115_REGISTER_CONFIG_PGA_4_096V        = $0200;  // +/-4.096V range = Gain 1 (new constructor default)
  ADS1115_REGISTER_CONFIG_PGA_2_048V        = $0400;  // +/-2.048V range = Gain 2 (default)
  ADS1115_REGISTER_CONFIG_PGA_1_024V        = $0600;  // +/-1.024V range = Gain 4
  ADS1115_REGISTER_CONFIG_PGA_0_512V        = $0800;  // +/-0.512V range = Gain 8
  ADS1115_REGISTER_CONFIG_PGA_0_256V        = $0A00;  // +/-0.256V range = Gain 16

  ADS1115_REGISTER_CONFIG_MODE_MASK         = $0100;
  ADS1115_REGISTER_CONFIG_MODE_CONTINUOUS   = $0000;  // Continuous conversion mode
  ADS1115_REGISTER_CONFIG_MODE_SINGLE       = $0100;  // Power-down single-shot mode (default)

  ADS1115_REGISTER_CONFIG_DR_MASK           = $00E0;
  ADS1115_REGISTER_CONFIG_DR_8SPS           = $0000;  // 8 samples per second
  ADS1115_REGISTER_CONFIG_DR_16SPS          = $0020;  // 16 samples per second
  ADS1115_REGISTER_CONFIG_DR_32SPS          = $0040;  // 32 samples per second
  ADS1115_REGISTER_CONFIG_DR_64SPS          = $0060;  // 64 samples per second
  ADS1115_REGISTER_CONFIG_DR_128SPS         = $0080;  // 128 samples per second (default)
  ADS1115_REGISTER_CONFIG_DR_250SPS         = $00A0;  // 250 samples per second
  ADS1115_REGISTER_CONFIG_DR_475SPS         = $00C0;  // 475 samples per second
  ADS1115_REGISTER_CONFIG_DR_860SPS         = $00E0;  // 860 samples per second

  ADS1115_REGISTER_CONFIG_CMODE_MASK        = $0010;
  ADS1115_REGISTER_CONFIG_CMODE_TRADITIONAL = $0000;  // Traditional comparator with hysteresis (default)
  ADS1115_REGISTER_CONFIG_CMODE_WINDOW      = $0010;  // Window comparator

  ADS1115_REGISTER_CONFIG_CPOL_MASK         = $0008;
  ADS1115_REGISTER_CONFIG_CPOL_ACTVLOW      = $0000;  // ALERT/RDY pin is low when active (default)
  ADS1115_REGISTER_CONFIG_CPOL_ACTVHIGH     = $0008;  // ALERT/RDY pin is high when active

  ADS1115_REGISTER_CONFIG_CLAT_MASK         = $0004;  // Determines if ALERT/RDY pin latches once asserted
  ADS1115_REGISTER_CONFIG_CLAT_NONLATCH     = $0000;  // Non-latching comparator (default)
  ADS1115_REGISTER_CONFIG_CLAT_LATCH        = $0004;  // Latching comparator

  ADS1115_REGISTER_CONFIG_CQUE_MASK         = $0003;
  ADS1115_REGISTER_CONFIG_CQUE_1CONV        = $0000;  // Assert ALERT/RDY after one conversions
  ADS1115_REGISTER_CONFIG_CQUE_2CONV        = $0001;  // Assert ALERT/RDY after two conversions
  ADS1115_REGISTER_CONFIG_CQUE_4CONV        = $0002;  // Assert ALERT/RDY after four conversions
  ADS1115_REGISTER_CONFIG_CQUE_NONE         = $0003;  // Disable the comparator and put ALERT/RDY in high state (default)

Type
  { ####################################################################################### }
  { ## Number types                                                                      ## }
  { ####################################################################################### }
  Int_8     = Shortint;
  P_Int_8   = ^Int_8;
  U_Int_8   = Byte;
  P_U_Int_8 = ^U_Int_8;
  Char      = Int_8;
  P_Char    = ^Char;
  U_Char    = U_Int_8;
  P_U_Char  = ^U_Char;

  Int_16     = Smallint;
  P_Int_16   = ^Int_16;
  U_Int_16   = Word;
  P_U_Int_16 = ^U_Int_16;

  Int_32     = Longint;
  P_Int_32   = ^Int_32;
  U_Int_32   = Longword;
  P_U_Int_32 = ^U_Int_32;

  Int_64     = Int64;
  P_Int_64   = ^Int_64;
  U_Int_64   = QWord;
  P_U_Int_64 = ^U_Int_64;

  Bool   = Bytebool;
  P_Bool = ^Bool;

  T_I2C_Buffer_A = Packed Array [0 .. ADS1115_I2C_BUFFER_MAX_SIZE + 1] Of U_Int_8;

  {$PACKENUM 1}
  T_I2C_Read_Write_Mode         =
      (
      I2C_READ_WRITE_MODE_WRITE = 0,
      I2C_READ_WRITE_MODE_READ = 1
      );

  {$PACKENUM 4}
  T_I2C_Transaction         =
      (
      I2C_TRANSACTION_QUICK = 0,
      I2C_TRANSACTION_BYTE = 1,
      I2C_TRANSACTION_BYTE_DATA = 2,
      I2C_TRANSACTION_WORD_DATA = 3,
      I2C_TRANSACTION_PROC_CALL = 4,
      I2C_TRANSACTION_BLOCK_DATA = 5,
      I2C_TRANSACTION_I2C_BLOCK_BROKEN = 6,
      I2C_TRANSACTION_BLOCK_PROC_CALL = 7,
      I2C_TRANSACTION_I2C_BLOCK_DATA = 8
      );
  {$PACKENUM DEFAULT}

  T_I2C_IOCTL_Data = Record
      Read_Write_Mode : T_I2C_READ_WRITE_MODE;
      Command :         U_Int_8;
      Transaction :     T_I2C_TRANSACTION;
      P_Buffer :        ^T_I2C_Buffer_A;
  End;


  { ####################################################################################### }
  { ## T_ADS1115                                                                         ## }
  { ####################################################################################### }
  T_ADS1115 = Class (TObject)
  Protected
      M_I2C_Address : U_Int_8;
      M_Gain :        U_Int_16;
      M_I2C_Handle :  CInt;
  Public
      Constructor Create (F_I2C_Adress : U_Int_8 = ADS1115_ADDRESS; F_Gain : U_Int_16 = ADS1115_REGISTER_CONFIG_PGA_4_096V);
      Destructor Destroy; Override;
      Function I2C_Read_Buffer (F_Command : U_Int_8; F_Length : U_Int_8; F_P_Buffer : P_U_Int_8) : Integer;
      Function I2C_Write_Buffer (F_Command : U_Int_8; F_Length : U_Int_8; F_P_Buffer : P_U_Int_8) : Integer;
      Procedure Start_ALERT_RDY ();
      Procedure Stop_ALERT_RDY ();
      Procedure Start_ADC_Differential_0_1_Continuous_Conversion ();
      Function Get_Last_Conversion_Result () : Integer;
  Published
  End; { T_ADS1115 }

Implementation


Uses
  SysUtils,
  Dialogs,
  Math;


{ ####################################################################################### }
{ ## T_ADS1115                                                                         ## }
{ ####################################################################################### }

{ --------------------------------------------------------------------------------------- }
Constructor T_ADS1115.Create (F_I2C_Adress : U_Int_8 = ADS1115_ADDRESS; F_Gain : U_Int_16 = ADS1115_REGISTER_CONFIG_PGA_4_096V);
{ Initialization of the object                                                            }
{ --------------------------------------------------------------------------------------- }
Begin { T_ADS1115.Create }
  Inherited Create ();

  { Initialize data }
  M_I2C_Address := F_I2C_Adress;
  M_Gain        := F_Gain;

  M_I2C_Handle := FpOpen ('/dev/i2c-1', O_RDWR);
  Sleep (100);
  If M_I2C_Handle < 0 Then
    Begin { then }
      { Error }
      ShowMessage ('Can not open I²C bus, Error:' + IntToStr (M_I2C_Handle));
      Halt;
    End; { then }

  { Connect as I2C slave }
  FpioCTL (M_I2C_Handle, ADS1115_I2C_SLAVE, Pointer (ADS1115_ADDRESS));
  Sleep (100);
End; { T_ADS1115.Create }


{ --------------------------------------------------------------------------------------- }
Destructor T_ADS1115.Destroy ();
{ Free data                                                                               }
{ --------------------------------------------------------------------------------------- }
Begin { T_ADS1115.Destroy }
  FpClose (M_I2C_Handle);

  Inherited Destroy;
End; { T_ADS1115.Destroy }


{ --------------------------------------------------------------------------------------- }
Function T_ADS1115.I2C_Read_Buffer (F_Command : U_Int_8; F_Length : U_Int_8; F_P_Buffer : P_U_Int_8) : Integer; Inline;
{ Return last conversion result                                                           }
{ --------------------------------------------------------------------------------------- }
Var
  I2C_Buffer_A : T_I2C_Buffer_A;
  Transaction :  T_I2C_Transaction;
  IOCTL_Data :   T_I2C_IOCTL_Data;

Begin { T_ADS1115.I2C_Read_Buffer }
  F_Length := Min (F_Length, ADS1115_I2C_BUFFER_MAX_SIZE);

  I2C_Buffer_A[0] := F_Length;

  If F_Length = ADS1115_I2C_BUFFER_MAX_SIZE Then
    Begin { then }
      Transaction := I2C_TRANSACTION_I2C_BLOCK_BROKEN;
    End { then }
  Else
    Begin { else }
      Transaction := I2C_TRANSACTION_I2C_BLOCK_DATA;
    End; { else }

  IOCTL_Data.Read_Write_Mode := I2C_READ_WRITE_MODE_READ;
  IOCTL_Data.Command         := F_Command;
  IOCTL_Data.Transaction     := Transaction;
  IOCTL_Data.P_Buffer        := @I2C_Buffer_A;

  If FpIOCtl (M_I2C_Handle, ADS1115_I2C_SMBUS, @IOCTL_Data) <> 0 Then
    Begin { then }
      Result := -1;
    End { then }
  Else
    Begin { else }
      Move (I2C_Buffer_A [1], F_P_Buffer^, I2C_Buffer_A [0]);
      Result := I2C_Buffer_A [0];
    End; { else }
End; { T_ADS1115.I2C_Read_Buffer }


{ --------------------------------------------------------------------------------------- }
Function T_ADS1115.I2C_Write_Buffer (F_Command : U_Int_8; F_Length : U_Int_8; F_P_Buffer : P_U_Int_8) : Integer; Inline;
{ Return last conversion result                                                           }
{ --------------------------------------------------------------------------------------- }
Var
  I2C_Buffer_A : T_I2C_Buffer_A;
  IOCTL_Data :   T_I2C_IOCTL_Data;

Begin { T_ADS1115.I2C_Write_Buffer }
  F_Length := Min (F_Length, ADS1115_I2C_BUFFER_MAX_SIZE);

  Move (F_P_Buffer^, I2C_Buffer_A [1], F_Length);
  I2C_Buffer_A[0] := F_Length;

  IOCTL_Data.Read_Write_Mode := I2C_READ_WRITE_MODE_WRITE;
  IOCTL_Data.Command         := F_Command;
  IOCTL_Data.Transaction     := I2C_TRANSACTION_I2C_BLOCK_BROKEN;
  IOCTL_Data.P_Buffer        := @I2C_Buffer_A;

  Result := FpIOCtl (M_I2C_Handle, ADS1115_I2C_SMBUS, @IOCTL_Data);
End; { T_ADS1115.I2C_Write_Buffer }


{ --------------------------------------------------------------------------------------- }
Procedure T_ADS1115.Start_ALERT_RDY ();
{ Start ALERT/RDY interupt signal                                                         }
{ --------------------------------------------------------------------------------------- }
Var
  Buffer :       Packed Array [0 .. 9] Of U_Int_8;
  Result_Value : Integer;

Begin { T_ADS1115.Start_ALERT_RDY }
  { Turn on ALERT/RDY : Set MSB of Hi_thresh to 1 }
  Buffer[0]    := $8000 shr 8;
  Buffer[1]    := $8000 and $FF;
  Result_Value := I2C_Write_Buffer (ADS1115_REGISTER_POINTER_HIGH_THRESHOLD, 2, @Buffer [0]);

  If Result_Value < 0 Then
    Begin { then }
      ShowMessage ('Error writing to I²C (Set MSB of Hi_thresh to 1)');
      Halt;
    End; { then }

  { Turn on ALERT/RDY : Set MSB of Lo_thresh to 0 }
  Buffer[0]    := $0000 shr 8;
  Buffer[1]    := $0000 and $FF;
  Result_Value := I2C_Write_Buffer (ADS1115_REGISTER_POINTER_LOW_THRESHOLD, 2, @Buffer [0]);
  If Result_Value < 0 Then
    Begin { then }
      ShowMessage ('Error writing to I²C (Set MSB of Lo_thresh to 0)');
      Halt;
    End; { then }

  Sleep (100);
End; { T_ADS1115.Start_ALERT_RDY }


{ --------------------------------------------------------------------------------------- }
Procedure T_ADS1115.Stop_ALERT_RDY ();
{ Stop ALERT/RDY interupt signal                                                          }
{ --------------------------------------------------------------------------------------- }
Var
  Buffer :       Packed Array [0 .. 9] Of U_Int_8;
  Result_Value : Integer;

Begin { T_ADS1115.Stop_ALERT_RDY }
  { Turn off ALERT/RDY : Set MSB of Hi_thresh to 0 }
  Buffer[0]    := $0000 shr 8;
  Buffer[1]    := $0000 and $FF;
  Result_Value := I2C_Write_Buffer (ADS1115_REGISTER_POINTER_HIGH_THRESHOLD, 2, @Buffer [0]);
  If Result_Value < 0 Then
    Begin { then }
      ShowMessage ('Error writing to I²C (Set MSB of Hi_thresh to 0)');
      Halt;
    End; { then }

  { Turn off ALERT/RDY : Set MSB of Lo_thresh to 1 }
  Buffer[0]    := $FFFF shr 8;
  Buffer[1]    := $FFFF and $FF;
  Result_Value := I2C_Write_Buffer (ADS1115_REGISTER_POINTER_LOW_THRESHOLD, 2, @Buffer [0]);
  If Result_Value < 0 Then
    Begin { then }
      ShowMessage ('Error writing to I²C (Set MSB of Lo_thresh to 1)');
      Halt;
    End; { then }
End; { T_ADS1115.Stop_ALERT_RDY }


{ --------------------------------------------------------------------------------------- }
Procedure T_ADS1115.Start_ADC_Differential_0_1_Continuous_Conversion ();
{ Start continuous conversion mode                                                        }
{ --------------------------------------------------------------------------------------- }
Var
  Config :       U_Int_16;
  Buffer :       Packed Array [0 .. 9] Of U_Int_8;
  Result_Value : Integer;

Begin { T_ADS1115.Start_ADC_Differential_0_1_Continuous_Conversion }
  { Start ADC with continouos operation }
  Config :=
      ADS1115_REGISTER_CONFIG_OS_SINGLE or
      ADS1115_REGISTER_CONFIG_MUX_DIFF_0_1 or
      M_Gain or
      ADS1115_REGISTER_CONFIG_MODE_CONTINUOUS or
      ADS1115_REGISTER_CONFIG_DR_475SPS or
      ADS1115_REGISTER_CONFIG_CMODE_TRADITIONAL or
      ADS1115_REGISTER_CONFIG_CPOL_ACTVHIGH or
      ADS1115_REGISTER_CONFIG_CLAT_NONLATCH or
      ADS1115_REGISTER_CONFIG_CQUE_1CONV;

  Buffer[0]    := Config shr 8;
  Buffer[1]    := Config and $FF;
  Result_Value := I2C_Write_Buffer (ADS1115_REGISTER_POINTER_CONFIG, 2, @Buffer [0]);
  Sleep (100);
  Result_Value := I2C_Write_Buffer (ADS1115_REGISTER_POINTER_CONFIG, 2, @Buffer [0]);
  If Result_Value < 0 Then
    Begin { then }
      ShowMessage ('Error writing to I²C (Set config)');
      Halt;
    End; { then }

  { Turn on ALERT/RDY }
  Start_ALERT_RDY ();
End; { T_ADS1115.Start_ADC_Differential_0_1_Continuous_Conversion }


{ --------------------------------------------------------------------------------------- }
Function T_ADS1115.Get_Last_Conversion_Result () : Integer;
{ Return last conversion result                                                           }
{ --------------------------------------------------------------------------------------- }
Var
  Result_Value : Integer;
  Buffer :       Packed Array [0 .. 9] Of U_Int_8;

Begin { T_ADS1115.Get_Last_Conversion_Result }
  Result_Value := I2C_Read_Buffer (ADS1115_REGISTER_POINTER_CONVERT, 2, @Buffer);
  If Result_Value <> 2 Then
    Begin { then }
      Result_Value := I2C_Read_Buffer (ADS1115_REGISTER_POINTER_CONVERT, 2, @Buffer);
      If Result_Value <> 2 Then
        Begin { then }
          Buffer[0] := 0;
          Buffer[1] := 0;
        End; { then }
    End; { then }

  Result := Int_16 ((Buffer [0] shl 8) or (Buffer [1]));
End; { T_ADS1115.Get_Last_Conversion_Result }


End.
