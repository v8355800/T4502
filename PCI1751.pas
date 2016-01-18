unit PCI1751;

interface

{ Функции для работы с портами ввода/вывода }
function Inp32(PortAdr: Word): Byte; stdcall; external 'inpout32.dll';
function Out32(wAddr: Word; bOut: Byte): Byte; stdcall; external 'inpout32.dll';

const
  PCI1751_VEN_DEV = 'VEN_13FE&DEV_1751';

type
//  TPort = (P0, P1);
//  TPortAll = (PA0, PA1, PB0, PB1, PC0_L, PC0_H, PC1_L, PC1_H);
  TPortIndex1 = 0..1;
  TPortIndex2 = 0..7;

//  TPortMode = (pmIN, pmOUT);

  TPCI1751 = class(TObject)
  private
    fFriendlyName: string;
    
    procedure Reset;

    function GetPA0(Index: TPortIndex2): Byte;
    function GetPA1(Index: TPortIndex2): Byte;
    function GetPB0(Index: TPortIndex2): Byte;
    function GetPB1(Index: TPortIndex2): Byte;
    function GetPC0(Index: TPortIndex2): Byte;
    function GetPC1(Index: TPortIndex2): Byte;
    procedure SetPA0(Index: TPortIndex2; const Value: Byte);
    procedure SetPA1(Index: TPortIndex2; const Value: Byte);
    procedure SetPB0(Index: TPortIndex2; const Value: Byte);
    procedure SetPB1(Index: TPortIndex2; const Value: Byte);
    procedure SetPC0(Index: TPortIndex2; const Value: Byte);
    procedure SetPC1(Index: TPortIndex2; const Value: Byte);
    function ReadP0_Mode: Byte;
    function ReadP1_Mode: Byte;
    procedure WriteP0_Mode(const Value: Byte);
    procedure WriteP1_Mode(const Value: Byte);
    function GetPA(Index1: TPortIndex1; Index2: TPortIndex2): Byte;
    function GetPB(Index1: TPortIndex1; Index2: TPortIndex2): Byte;
    function GetPC(Index1: TPortIndex1; Index2: TPortIndex2): Byte;
    procedure SetPA(Index1: TPortIndex1; Index2: TPortIndex2;
      const Value: Byte);
    procedure SetPB(Index1: TPortIndex1; Index2: TPortIndex2;
      const Value: Byte);
    procedure SetPC(Index1: TPortIndex1; Index2: TPortIndex2;
      const Value: Byte);
  protected
    fBaseAddr: Int64;
    fEmulation: Boolean;

  public
    constructor Create(const BaseAddr: Int64 = 0);
    destructor  Destroy; override;
//    procedure SetPortMode(Port: TPort; bMode: Byte); overload;
//    procedure SetPortMode(Port: TPortAll; Mode: TPortMode); overload;

    property BaseAddr: Int64 read fBaseAddr;
    property FriendlyName: string read fFriendlyName;
    property Emulation: Boolean read fEmulation;

    property PA0[Index: TPortIndex2]: Byte read GetPA0 write SetPA0;
    property PB0[Index: TPortIndex2]: Byte read GetPB0 write SetPB0;
    property PC0[Index: TPortIndex2]: Byte read GetPC0 write SetPC0;
    property PA1[Index: TPortIndex2]: Byte read GetPA1 write SetPA1;
    property PB1[Index: TPortIndex2]: Byte read GetPB1 write SetPB1;
    property PC1[Index: TPortIndex2]: Byte read GetPC1 write SetPC1;

    property PA[Index1: TPortIndex1; Index2: TPortIndex2]: Byte read GetPA write SetPA;
    property PB[Index1: TPortIndex1; Index2: TPortIndex2]: Byte read GetPB write SetPB;
    property PC[Index1: TPortIndex1; Index2: TPortIndex2]: Byte read GetPC write SetPC;

    property P0_Mode: Byte read ReadP0_Mode write WriteP0_Mode;
    property P1_Mode: Byte read ReadP1_Mode write WriteP1_Mode;
  end;

implementation

uses
  DeviceDetect;

{ TPCI1751 }

constructor TPCI1751.Create(const BaseAddr: Int64);
var
  List: TDetectedDeviceList;
begin
  inherited Create;

  if BaseAddr <> 0 then
    fBaseAddr := BaseAddr
  else
  begin
    List := TDetectedDeviceList.Create;
    getDevicesWDM(List, PCI1751_VEN_DEV, 'PCI');

    if List.Count > 0 then
    begin
      fFriendlyName := List[0].friendlyName;
      fBaseAddr := List[0].portStart;

      Reset;
    end
    else
    begin
      fBaseAddr := 0;
      fFriendlyName := '';
    end;

    List.Free;
  end;

  fEmulation := fBaseAddr <= 0;
end;

function TPCI1751.GetPA0(Index: TPortIndex2): Byte;
begin
  Result := GetPA(0, Index);
end;

function TPCI1751.GetPA1(Index: TPortIndex2): Byte;
begin
  Result := GetPA(1, Index);
end;

function TPCI1751.GetPB0(Index: TPortIndex2): Byte;
begin
  Result := GetPB(0, Index);
end;

function TPCI1751.GetPB1(Index: TPortIndex2): Byte;
begin
  Result := GetPB(1, Index);
end;

function TPCI1751.GetPC0(Index: TPortIndex2): Byte;
begin
  Result := GetPC(0, Index);
end;

function TPCI1751.GetPC1(Index: TPortIndex2): Byte;
begin
  Result := GetPC(1, Index);
end;

function TPCI1751.GetPA(Index1: TPortIndex1; Index2: TPortIndex2): Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;

  case Index1 of
    0: Result := (Inp32(fBaseAddr + 0) and (1 shl Index2));
    1: Result := (Inp32(fBaseAddr + 4) and (1 shl Index2));
  else
    Result := 0;
  end;
end;

function TPCI1751.GetPB(Index1: TPortIndex1; Index2: TPortIndex2): Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;

  case Index1 of
    0: Result := (Inp32(fBaseAddr + 1) and (1 shl Index2));
    1: Result := (Inp32(fBaseAddr + 5) and (1 shl Index2));
  else
    Result := 0;
  end;
end;

function TPCI1751.GetPC(Index1: TPortIndex1; Index2: TPortIndex2): Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;

  case Index1 of
    0: Result := Ord( (Inp32(fBaseAddr + 2) and (1 shl Index2)) <> 0);
    1: Result := Ord( (Inp32(fBaseAddr + 6) and (1 shl Index2)) <> 0);
  else
    Result := 0;
  end;
end;

procedure TPCI1751.SetPA0(Index: TPortIndex2; const Value: Byte);
begin
  SetPA(0, Index, Value);
end;

procedure TPCI1751.SetPA1(Index: TPortIndex2; const Value: Byte);
begin
  SetPA(1, Index, Value);
end;

procedure TPCI1751.SetPB0(Index: TPortIndex2; const Value: Byte);
begin
  SetPB(0, Index, Value);
end;

procedure TPCI1751.SetPB1(Index: TPortIndex2; const Value: Byte);
begin
  SetPB(1, Index, Value);
end;

procedure TPCI1751.SetPC0(Index: TPortIndex2; const Value: Byte);
begin
  SetPC(0, Index, Value);
end;

procedure TPCI1751.SetPC1(Index: TPortIndex2; const Value: Byte);
begin
  SetPC(1, Index, Value);
end;

procedure TPCI1751.SetPA(Index1: TPortIndex1; Index2: TPortIndex2;
  const Value: Byte);
begin
  if fEmulation then
    Exit;

  case Index1 of
    0:
      if Value = 0 then
        Out32(fBaseAddr + 0, Inp32(fBaseAddr + 0) and not (1 shl Index2) )   // clear bit
      else
        Out32(fBaseAddr + 0, Inp32(fBaseAddr + 0) or (1 shl Index2) );  // set bit

    1:
      if Value = 0 then
        Out32(fBaseAddr + 4, Inp32(fBaseAddr + 4) and not (1 shl Index2) )   // clear bit
      else
        Out32(fBaseAddr + 4, Inp32(fBaseAddr + 4) or (1 shl Index2) );  // set bit
  end;
end;

procedure TPCI1751.SetPB(Index1: TPortIndex1; Index2: TPortIndex2;
  const Value: Byte);
begin
  if fEmulation then
    Exit;

  case Index1 of
    0:
      if Value = 0 then
        Out32(fBaseAddr + 1, Inp32(fBaseAddr + 1) and not (1 shl Index2) )   // clear bit
      else
        Out32(fBaseAddr + 1, Inp32(fBaseAddr + 1) or (1 shl Index2) );  // set bit

    1:
      if Value = 0 then
        Out32(fBaseAddr + 5, Inp32(fBaseAddr + 5) and not (1 shl Index2) )   // clear bit
      else
        Out32(fBaseAddr + 5, Inp32(fBaseAddr + 5) or (1 shl Index2) );  // set bit
  end;
end;

procedure TPCI1751.SetPC(Index1: TPortIndex1; Index2: TPortIndex2;
  const Value: Byte);
begin
  if fEmulation then
    Exit;

  case Index1 of
    0:
      if Value = 0 then
        Out32(fBaseAddr + 2, Inp32(fBaseAddr + 2) and not (1 shl Index2) )   // clear bit
      else
        Out32(fBaseAddr + 2, Inp32(fBaseAddr + 2) or (1 shl Index2) );  // set bit

    1:
      if Value = 0 then
        Out32(fBaseAddr + 6, Inp32(fBaseAddr + 6) and not (1 shl Index2) )   // clear bit
      else
        Out32(fBaseAddr + 6, Inp32(fBaseAddr + 6) or (1 shl Index2) );  // set bit
  end;
end;


function TPCI1751.ReadP0_Mode: Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;
  Result := Inp32(fBaseAddr + 3);
end;

function TPCI1751.ReadP1_Mode: Byte;
begin
  if fEmulation then
  begin
    Result := 0;
    Exit;
  end;
  Result := Inp32(fBaseAddr + 7);
end;

procedure TPCI1751.WriteP0_Mode(const Value: Byte);
begin
  if fEmulation then
    Exit;

  Out32(fBaseAddr + 3, Value);
end;

procedure TPCI1751.WriteP1_Mode(const Value: Byte);
begin
  if fEmulation then
    Exit;
  Out32(fBaseAddr + 7, Value);
end;

//procedure TPCI1751.SetPortMode(Port: TPort; bMode: Byte);
//begin
//  if fEmulation then
//    Exit;
//
//  case Port of
//    P0: Out32(fBaseAddr + 3, bMode);
//    P1: Out32(fBaseAddr + 7, bMode);
//  end;
//end;
//
//procedure TPCI1751.SetPortMode(Port: TPortAll; Mode: TPortMode);
//var
//  RegVal: Byte;
//  NewRegVal: Byte;
//begin
//  if fEmulation then
//    Exit;
//
//  case Port of
//    PA0, PB0, PC0_L, PC0_H: RegVal := Inp32(fBaseAddr + 3);
//    PA1, PB1, PC1_L, PC1_H: RegVal := Inp32(fBaseAddr + 7);
//  end;
//
//  case Mode of
//    pmIN :  // set bit
//      case Port of
//        PA0, PA1     : NewRegVal := RegVal or (1 shl 4);
//        PB0, PB1     : NewRegVal := RegVal or (1 shl 1);
//        PC0_L, PC1_L : NewRegVal := RegVal or (1 shl 0);
//        PC0_H, PC1_H : NewRegVal := RegVal or (1 shl 3);
//      end;
//
//    pmOUT:  // clear bit
//      case Port of
//        PA0, PA1     : NewRegVal := RegVal and not (1 shl 4);
//        PB0, PB1     : NewRegVal := RegVal and not (1 shl 1);
//        PC0_L, PC1_L : NewRegVal := RegVal and not (1 shl 0);
//        PC0_H, PC1_H : NewRegVal := RegVal and not (1 shl 3);
//      end;
//  end;
//
//  case Port of
//    PA0, PB0, PC0_L, PC0_H: Out32(BaseAddr + 3, NewRegVal);
//    PA1, PB1, PC1_L, PC1_H: Out32(BaseAddr + 7, NewRegVal);
//  end;
//end;

destructor TPCI1751.Destroy;
begin
  Reset;
  
  inherited;
end;

procedure TPCI1751.Reset;
begin
  // Configure ports - ALL IN
  Out32(fBaseAddr + 3, $1B); // PA0 - in; PB0 - in; PC0 - in
  Out32(fBaseAddr + 7, $1B); // PA1 - in; PB1 - in; PC1 - in
end;

end.
