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
const
  PCI1751_VEN = $13FE;
  PCI1751_DEV = 1751;

type
  TPort = (P0, P1);
  TPortAll = (PA0, PA1, PB0, PB1, PC0_L, PC0_H, PC1_L, PC1_H);
  TPortIndex = 0..7;

  TPortMode = (pmIN, pmOUT);

  TPCI1751 = class(TObject)
  private
    fBaseAddr: Int64;
    fEmulation: Boolean;
    function GetA0(Index: TPortIndex): Byte;
    function GetA1(Index: TPortIndex): Byte;
    function GetB0(Index: TPortIndex): Byte;
    function GetB1(Index: TPortIndex): Byte;
    function GetC0(Index: TPortIndex): Byte;
    function GetC1(Index: TPortIndex): Byte;
    procedure SetA0(Index: TPortIndex; const Value: Byte);
    procedure SetA1(Index: TPortIndex; const Value: Byte);
    procedure SetB0(Index: TPortIndex; const Value: Byte);
    procedure SetB1(Index: TPortIndex; const Value: Byte);
    procedure SetC0(Index: TPortIndex; const Value: Byte);
    procedure SetC1(Index: TPortIndex; const Value: Byte);
    function ReadConfigP0: Byte;
    function ReadConfigP1: Byte;
  protected

  public
    constructor Create(const BaseAddr: Int64 = 0);
    procedure SetPortMode(Port: TPort; bMode: Byte); overload;
    procedure SetPortMode(Port: TPortAll; Mode: TPortMode); overload;

    property BaseAddr: Int64 read fBaseAddr;
    property Emulation: Boolean read fEmulation;

    property A0[Index: TPortIndex]: Byte read GetA0 write SetA0;
    property B0[Index: TPortIndex]: Byte read GetB0 write SetB0;
    property C0[Index: TPortIndex]: Byte read GetC0 write SetC0;
    property A1[Index: TPortIndex]: Byte read GetA1 write SetA1;
    property B1[Index: TPortIndex]: Byte read GetB1 write SetB1;
    property C1[Index: TPortIndex]: Byte read GetC1 write SetC1;

    property ConfigP0: Byte read ReadConfigP0;
    property ConfigP1: Byte read ReadConfigP1;
  end;

//procedure PA0_Mode(Mode: TPortMode);
//procedure PA1_Mode(Mode: TPortMode);
//procedure PB0_Mode(Mode: TPortMode);
//procedure PB1_Mode(Mode: TPortMode);
//procedure PC0_H_Mode(Mode: TPortMode);
//procedure PC0_L_Mode(Mode: TPortMode);
//procedure PC1_H_Mode(Mode: TPortMode);
//procedure PC1_L_Mode(Mode: TPortMode);
//
//procedure PA_Mode(PA0, PA1: TPortMode);
//procedure PB_Mode(PB0, PB1: TPortMode);
//procedure PC_Mode(PC0_H, PC0_L, PC1_H, PC1_L: TPortMode);
//
//procedure Mode(PA0, PA1, PB0, PB1, PC0_H, PC0_L, PC1_H, PC1_L: TPortMode);
//procedure P0_Mode(ModeB: Byte);
//procedure P1_Mode(ModeB: Byte);
//procedure P_Mode(P0_ModeB, P1_Mode: Byte);

implementation

uses
//  SysUtils,
  DeviceDetect;

{ Функции для работы с портами ввода/вывода }
function Inp32(PortAdr: Word): Byte; stdcall; external 'inpout32.dll';
function Out32(wAddr: Word; bOut: Byte): Byte; stdcall; external 'inpout32.dll';

//initialization
//  ConfigPort0 := $1B;
//  ConfigPort1 := $1B;
//  P_Mode(ConfigPort0, ConfigPort1);

{ TPCI1751 }

constructor TPCI1751.Create(const BaseAddr: Int64);
var
  List: TDetectedDeviceList;
//  i: Integer;
begin
  inherited Create;

  if BaseAddr <> 0 then
    fBaseAddr := BaseAddr
  else
  begin
    List := TDetectedDeviceList.Create;
    getDevicesWDM(List, 'VEN_13FE&DEV_1751', 'PCI');
//    getPortsWDM(List, 'VEN_10EC&DEV_8168', 'PCI');
//    getPortsWDM(List, 'VEN_8086&DEV_', 'PCI');

    if List.Count > 0 then
      fBaseAddr := List[0].portStart
    else
      fBaseAddr := 0;
//    for i := 0 to List.Count - 1 do
//      Writeln(List[i].friendlyName, ' (IO = 0x',  IntToHex(List[i].portStart, 4), ')');

    List.Free;
  end;

  fEmulation := fBaseAddr <= 0;
end;

procedure TPCI1751.SetPortMode(Port: TPort; bMode: Byte);
begin
  if fEmulation then
    Exit;

  case Port of
    P0: Out32(fBaseAddr + 3, bMode);
    P1: Out32(fBaseAddr + 7, bMode);
  end;
end;

function TPCI1751.GetA0(Index: TPortIndex): Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;
  Result := Inp32(fBaseAddr + 0);
end;

function TPCI1751.GetA1(Index: TPortIndex): Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;
  Result := Inp32(fBaseAddr + 4);
end;

function TPCI1751.GetB0(Index: TPortIndex): Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;
  Result := Inp32(fBaseAddr + 1);
end;

function TPCI1751.GetB1(Index: TPortIndex): Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;
  Result := Inp32(fBaseAddr + 5);
end;

function TPCI1751.GetC0(Index: TPortIndex): Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;
  Result := Inp32(fBaseAddr + 2);
end;

function TPCI1751.GetC1(Index: TPortIndex): Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;
  Result := Inp32(fBaseAddr + 6);
end;

procedure TPCI1751.SetA0(Index: TPortIndex; const Value: Byte);
begin
  if fEmulation then
    Exit;

  Out32(fBaseAddr + 0, Value);
end;

procedure TPCI1751.SetA1(Index: TPortIndex; const Value: Byte);
begin
  if fEmulation then
    Exit;

  Out32(fBaseAddr + 4, Value);
end;

procedure TPCI1751.SetB0(Index: TPortIndex; const Value: Byte);
begin
  if fEmulation then
    Exit;

  Out32(fBaseAddr + 1, Value);
end;

procedure TPCI1751.SetB1(Index: TPortIndex; const Value: Byte);
begin
  if fEmulation then
    Exit;

  Out32(fBaseAddr + 5, Value);
end;

procedure TPCI1751.SetC0(Index: TPortIndex; const Value: Byte);
begin
  if fEmulation then
    Exit;

  Out32(fBaseAddr + 2, Value);
end;

procedure TPCI1751.SetC1(Index: TPortIndex; const Value: Byte);
begin
  if fEmulation then
    Exit;

  Out32(fBaseAddr + 6, Value);
end;

procedure TPCI1751.SetPortMode(Port: TPortAll; Mode: TPortMode);
var
  RegVal: Byte;
  NewRegVal: Byte;
begin
  if fEmulation then
    Exit;

  case Port of
    PA0, PB0, PC0_L, PC0_H: RegVal := Inp32(fBaseAddr + 3);
    PA1, PB1, PC1_L, PC1_H: RegVal := Inp32(fBaseAddr + 7);
  end;

  case Mode of
    pmIN :  // set bit
      case Port of
        PA0, PA1     : NewRegVal := RegVal or (1 shl 4);
        PB0, PB1     : NewRegVal := RegVal or (1 shl 1);
        PC0_L, PC1_L : NewRegVal := RegVal or (1 shl 0);
        PC0_H, PC1_H : NewRegVal := RegVal or (1 shl 3);
      end;

    pmOUT:  // clear bit
      case Port of
        PA0, PA1     : NewRegVal := RegVal and not (1 shl 4);
        PB0, PB1     : NewRegVal := RegVal and not (1 shl 1);
        PC0_L, PC1_L : NewRegVal := RegVal and not (1 shl 0);
        PC0_H, PC1_H : NewRegVal := RegVal and not (1 shl 3);
      end;
  end;

  case Port of
    PA0, PB0, PC0_L, PC0_H: Out32(BaseAddr + 3, NewRegVal);
    PA1, PB1, PC1_L, PC1_H: Out32(BaseAddr + 7, NewRegVal);
  end;
end;

function TPCI1751.ReadConfigP0: Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;
  Result := Inp32(fBaseAddr + 3);
end;

function TPCI1751.ReadConfigP1: Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;
  Result := Inp32(fBaseAddr + 7);
end;

end.
