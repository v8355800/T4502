unit T4502;

interface

uses
  PCI1751;

type
  TS3 = string[3];
  TS6 = string[6];

  TT4502_IO = class(TPCI1751)
  private
  protected
    procedure OutputCycle(const ADDR_OCT, DATA_OCT: TS6);
    procedure InputCycle(const ADDR_OCT: TS6; var DATA_OCT: TS6);
  public
    constructor Create;

    function  RS(const ADDR: TS3): Word; overload;       // Регистр состояния 16xxx0
    function  RS: Word; overload;                      // Регистр состояния 16xxx0
    procedure  W(const ADDR: TS3; DATA: TS6);  // Выходной буфер    16xxx2
    function   R(const ADDR: TS3): Word;       // Входной буфер     16xxx4
  end;

type
  TT4502_Commands = class(TObject)
  public
  end;

type
  TS4 = string[4];

  TT4502 = class(TObject)
  private
    fIO: TT4502_IO;
//    fCommands: TT4502_Commands;
  protected

  public
//    property Commands: TT4502_Commands read fCommands;
    constructor Create;
    destructor Destroy; override;

    function Propusk: Boolean;
    procedure K(Command: TS4); overload;
    function  K(Command: TS4): Word; overload;


    property IO: TT4502_IO read fIO;
  end;

implementation

uses
  CONVUNIT;

{ TT4502_Commands }

//procedure TT4502_Commands.K01;
//begin
//
//end;

constructor TT4502_IO.Create;
begin
  inherited Create(0);

  if not fEmulation then
  begin
    { К ДА = $FFFF }
      Out32(fBaseAddr + 1, $FF);  // PB0 = $FF
      Out32(fBaseAddr + 5, $FF);  // PB1 = $FF
    { Управляющие сигналы }
      PC1[2] := 1;  // К СБРОС
      PC1[3] := 1;  // К СИА
      PC1[4] := 1;  // К БАЙТ
      PC1[5] := 1;  // К ВУ
      PC1[6] := 1;  // К ВЫВОД
      PC1[7] := 1;  // К ВВОД
    { Режим работы портов }
      P0_Mode := $19;  // PA0 - in; PB0 - out; PC0 - in
      P1_Mode := $10;  // PA1 - in; PB1 - out; PC1 - out

    { Сигнал "К СБРОС" }
      PC1[2] := 0;
      PC1[2] := 1;
  end;
end;

//------------------------------------------------------------------------------
//                                 Цыкл "ВЫВОД"
//                           передача данных в тестер
//------------------------------------------------------------------------------
procedure TT4502_IO.OutputCycle(const ADDR_OCT, DATA_OCT: TS6);
var
  ADDR_DEC: Word;
  DATA_DEC: Word;
  D0, D1: Byte;
begin
  ADDR_DEC := OCT2DEC(ADDR_OCT);
  DATA_DEC := OCT2DEC(DATA_OCT);

  // 1. К ДА = ADDR
    Out32(fBaseAddr + 1, Lo(not ADDR_DEC));  // PB0
    Out32(fBaseAddr + 5, Hi(not ADDR_DEC));  // PB1
  // 2. К ВУ = 0
    PC1[5] := 0;
  // 3. К СИА = 0
    PC1[3] := 0;
  // 4. К ДА = $FFFF
//    Out32(fPCI1751.BaseAddr + 1, $FF);  // PB0
//    Out32(fPCI1751.BaseAddr + 5, $FF);  // PB1
  // 5. К ВУ = 1
    PC1[5] := 1;
  // 6. К ДА = DATA
    Out32(fBaseAddr + 1, Lo(not DATA_DEC));  // PB0
    Out32(fBaseAddr + 5, Hi(not DATA_DEC));  // PB1
  // 7. К ВЫВОД = 0
    PC1[6] := 0;
  // 8. Ждем, пока К СИП не станет равен 0
//        while (PC0[2] = 1) do ;
  // 9. К ВЫВОД = 1
    PC1[6] := 1;
  // 10. К ДА = $FFFF
    Out32(fBaseAddr + 1, $FF);  // PB0
    Out32(fBaseAddr + 5, $FF);  // PB1
  // 11. Ждем, пока К СИП не станет равен 1
//        while (PC0[2] = 0) do ;
  // 12. К СИА = 1
    PC1[3] := 1;
end;


//------------------------------------------------------------------------------
//                                 Цыкл "ВВОД"                                  
//                          передача данных из тестера                          
//------------------------------------------------------------------------------
procedure TT4502_IO.InputCycle(const ADDR_OCT: TS6; var DATA_OCT: TS6);
var
  ADDR_DEC: Word;
  DATA_DEC_Array: array[0..1] of Byte;
  DATA_DEC: word absolute DATA_DEC_Array;
begin
  ADDR_DEC := OCT2DEC(ADDR_OCT);

  // 1. К ДА = ADDR
    Out32(fBaseAddr + 1, Lo(not ADDR_DEC));  // PB0
    Out32(fBaseAddr + 5, Hi(not ADDR_DEC));  // PB1
  // 2. К ВУ = 0
    PC1[5] := 0;
  // 3. К СИА = 0
    PC1[3] := 0;
  // 4. К ДА = $FFFF
    Out32(fBaseAddr + 1, $FF);  // PB0
    Out32(fBaseAddr + 5, $FF);  // PB1
  // 5. К ВУ = 1
    PC1[5] := 1;
  // 6. К ВВОД = 0
    PC1[7] := 0;
  // 7. Ждем, пока К СИП не станет равен 0
  //  while (PC0[2] = 1) do ;
  // 8. К ВВОД = 1
    PC1[7] := 1;
  // 9. Считываем данные
    DATA_DEC_Array[0] := not Inp32(fBaseAddr + 0);
    DATA_DEC_Array[1] := not Inp32(fBaseAddr + 4);
    DATA_OCT := DEC2OCT(DATA_DEC);
  // 10. Ждем, пока К СИП не станет равен 1
  //  while (PC0[2] = 0) do ;
  // 11. К СИА = 1
    PC1[3] := 1;
end;

function TT4502_IO.RS(const ADDR: TS3): Word;
var
  D: TS6;
begin
  InputCycle('16' + ADDR + '0', D);
  Result := OCT2DEC(D);
end;

procedure TT4502_IO.W(const ADDR: TS3; DATA: TS6);
begin
  OutputCycle('16' + ADDR + '2', DATA);
end;

function TT4502_IO.R(const ADDR: TS3): Word;
var
  D: TS6;
begin
  InputCycle('16' + ADDR + '4', D);
  Result := OCT2DEC(D);
end;

function TT4502_IO.RS: Word;
begin
  Result := RS('000');
end;

{ TT4502 }

constructor TT4502.Create;
begin
  inherited Create;

  fIO := TT4502_IO.Create;
end;

destructor TT4502.Destroy;
begin
  fIO.Free;
  
  inherited;
end;

procedure TT4502.K(Command: TS4);
begin
  inherited;

end;

function TT4502.K(Command: TS4): Word;
begin

end;

function TT4502.Propusk: Boolean;
begin
  Result := ((fIO.RS shr 7) and 1) = 1;
end;

end.

