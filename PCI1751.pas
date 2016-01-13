unit PCI1751;

interface

const
  fBaseAddr = $000;
  A0  = fBaseAddr + 0;
  B0  = fBaseAddr + 1;
  C0  = fBaseAddr + 2;
  CP0 = fBaseAddr + 3;
  A1  = fBaseAddr + 4;
  B1  = fBaseAddr + 5;
  C1  = fBaseAddr + 6;
  CP1 = fBaseAddr + 7;

//var
//  ConfigPort0: Byte;
//  ConfigPort1: Byte;

type
  TPortMode = (pmRead, pmWrite);

{ Функции для работы с портами ввода/вывода }
function Inp32(PortAdr: Word): Byte; stdcall; external 'inpout32.dll';
function Out32(wAddr: Word; bOut: Byte): Byte; stdcall; external 'inpout32.dll';

procedure PA0_Mode(Mode: TPortMode);
procedure PA1_Mode(Mode: TPortMode);
procedure PB0_Mode(Mode: TPortMode);
procedure PB1_Mode(Mode: TPortMode);
procedure PC0_H_Mode(Mode: TPortMode);
procedure PC0_L_Mode(Mode: TPortMode);
procedure PC1_H_Mode(Mode: TPortMode);
procedure PC1_L_Mode(Mode: TPortMode);

procedure PA_Mode(PA0, PA1: TPortMode);
procedure PB_Mode(PB0, PB1: TPortMode);
procedure PC_Mode(PC0_H, PC0_L, PC1_H, PC1_L: TPortMode);

procedure Mode(PA0, PA1, PB0, PB1, PC0_H, PC0_L, PC1_H, PC1_L: TPortMode);
procedure P0_Mode(ModeB: Byte);
procedure P1_Mode(ModeB: Byte);
procedure P_Mode(P0_ModeB, P1_Mode: Byte);

implementation

initialization
  ConfigPort0 := $1B;
  ConfigPort1 := $1B;
  P_Mode(ConfigPort0, ConfigPort1);

end.
