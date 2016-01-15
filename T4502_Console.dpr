program T4502_Console;

{$APPTYPE CONSOLE}
{$O-}

uses
  SysUtils,
  Console, CONVUNIT,
  T4502 in 'T4502.pas',
  PCI1751 in 'PCI1751.pas';

var
  fIO: TT4502_IO;
  fPCI1751: TPCI1751;
  i: integer;

type
  DA_OCT = string[6];

function ReverseBits(b: Byte): Byte;{ inline;}
const
  Table: array [Byte] of Byte = (
    0,128,64,192,32,160,96,224,16,144,80,208,48,176,112,240,
    8,136,72,200,40,168,104,232,24,152,88,216,56,184,120,248,
    4,132,68,196,36,164,100,228,20,148,84,212,52,180,116,244,
    12,140,76,204,44,172,108,236,28,156,92,220,60,188,124,252,
    2,130,66,194,34,162,98,226,18,146,82,210,50,178,114,242,
    10,138,74,202,42,170,106,234,26,154,90,218,58,186,122,250,
    6,134,70,198,38,166,102,230,22,150,86,214,54,182,118,246,
    14,142,78,206,46,174,110,238,30,158,94,222,62,190,126,254,
    1,129,65,193,33,161,97,225,17,145,81,209,49,177,113,241,
    9,137,73,201,41,169,105,233,25,153,89,217,57,185,121,249,
    5,133,69,197,37,165,101,229,21,149,85,213,53,181,117,245,
    13,141,77,205,45,173,109,237,29,157,93,221,61,189,125,253,
    3,131,67,195,35,163,99,227,19,147,83,211,51,179,115,243,
    11,139,75,203,43,171,107,235,27,155,91,219,59,187,123,251,
    7,135,71,199,39,167,103,231,23,151,87,215,55,183,119,247,
    15,143,79,207,47,175,111,239,31,159,95,223,63,191,127,255
  );
begin
  Result := Table[b];
end;

//------------------------------------------------------------------------------
//                                 Цыкл "ВЫВОД"
//                           передача данных в тестер
//------------------------------------------------------------------------------
procedure OutputCycle(const ADDR_OCT, DATA_OCT: DA_OCT);
var
  ADDR_DEC: Word;
  DATA_DEC: Word;
  D0, D1: Byte;
begin
  ADDR_DEC := OCT2DEC(ADDR_OCT);
  DATA_DEC := OCT2DEC(DATA_OCT);

  // 1. К ДА = ADDR
    Out32(fPCI1751.BaseAddr + 1, Lo(not ADDR_DEC));  // PB0
    Out32(fPCI1751.BaseAddr + 5, Hi(not ADDR_DEC));  // PB1
  // 2. К ВУ = 0
    fPCI1751.PC1[5] := 0;
  // 3. К СИА = 0
    fPCI1751.PC1[3] := 0;
  // 4. К ДА = $FFFF
//    Out32(fPCI1751.BaseAddr + 1, $FF);  // PB0
//    Out32(fPCI1751.BaseAddr + 5, $FF);  // PB1
  // 5. К ВУ = 1
    fPCI1751.PC1[5] := 1;
  // 6. К ДА = DATA
    Out32(fPCI1751.BaseAddr + 1, Lo(not DATA_DEC));  // PB0
    Out32(fPCI1751.BaseAddr + 5, Hi(not DATA_DEC));  // PB1
  // 7. К ВЫВОД = 0
    fPCI1751.PC1[6] := 0;
  // 8. Ждем, пока К СИП не станет равен 0
//        while (fPCI1751.PC0[2] = 1) do ;
  // 9. К ВЫВОД = 1
    fPCI1751.PC1[6] := 1;
  // 10. К ДА = $FFFF
    Out32(fPCI1751.BaseAddr + 1, $FF);  // PB0
    Out32(fPCI1751.BaseAddr + 5, $FF);  // PB1
  // 11. Ждем, пока К СИП не станет равен 1
//        while (fPCI1751.PC0[2] = 0) do ;
  // 12. К СИА = 1
    fPCI1751.PC1[3] := 1;
end;


//------------------------------------------------------------------------------
//                                 Цыкл "ВВОД"                                  
//                          передача данных из тестера                          
//------------------------------------------------------------------------------
procedure InputCycle(const ADDR_OCT: DA_OCT; var DATA_OCT: DA_OCT);
var
  ADDR_DEC: Word;
  DATA_DEC: Word;
  D0, D1: Byte;
begin
  ADDR_DEC := OCT2DEC(ADDR_OCT);

  // 1. К ДА = ADDR
    Out32(fPCI1751.BaseAddr + 1, Lo(not ADDR_DEC));  // PB0
    Out32(fPCI1751.BaseAddr + 5, Hi(not ADDR_DEC));  // PB1
  // 2. К ВУ = 0
    fPCI1751.PC1[5] := 0;
  // 3. К СИА = 0
    fPCI1751.PC1[3] := 0;
  // 4. К ДА = $FFFF
//    Out32(fPCI1751.BaseAddr + 1, $FF);  // PB0
//    Out32(fPCI1751.BaseAddr + 5, $FF);  // PB1
  // 5. К ВУ = 1
    fPCI1751.PC1[5] := 1;
  // 6. К ДА = DATA
    Out32(fPCI1751.BaseAddr + 1, Lo(not DATA_DEC));  // PB0
    Out32(fPCI1751.BaseAddr + 5, Hi(not DATA_DEC));  // PB1
  // 7. К ВЫВОД = 0
    fPCI1751.PC1[6] := 0;
  // 8. Ждем, пока К СИП не станет равен 0
//        while (fPCI1751.PC0[2] = 1) do ;
  // 9. К ВЫВОД = 1
    fPCI1751.PC1[6] := 1;
  // 10. К ДА = $FFFF
    Out32(fPCI1751.BaseAddr + 1, $FF);  // PB0
    Out32(fPCI1751.BaseAddr + 5, $FF);  // PB1
  // 11. Ждем, пока К СИП не станет равен 1
//        while (fPCI1751.PC0[2] = 0) do ;
  // 12. К СИА = 1
    fPCI1751.PC1[3] := 1;
end;

begin
//  fIO := TT4502_IO.Create;
////  fIO.U11('123');
//  fIO.Free;

  fPCI1751 := TPCI1751.Create();
  try
    if fPCI1751.Emulation then
      Writeln('Emulation mode')
    else
    begin
      Writeln(fPCI1751.FriendlyName, ' (0x', IntToHex(fPCI1751.BaseAddr, 4), ')');
      Writeln(' P0 Mode = ', fPCI1751.P0_Mode);
      Writeln(' P1 Mode = ', fPCI1751.P1_Mode);

      Writeln('Configure ports (ALL IN)...');
      fPCI1751.P0_Mode := $1B;  // PA0 - in; PB0 - in; PC0 - in
      fPCI1751.P1_Mode := $1B;  // PA1 - in; PB1 - in; PC1 - in
      fPCI1751.PC1[2] := 1;  // К СБРОС
      fPCI1751.PC1[3] := 1;  // К СИА
//      fPCI1751.PC1[4] := 1;  // К БАЙТ
      fPCI1751.PC1[5] := 1;  // К ВУ
      fPCI1751.PC1[6] := 1;  // К ВЫВОД
      fPCI1751.PC1[7] := 1;  // К ВВОД


      Writeln('Configure ports (T4502)...');
      fPCI1751.P0_Mode := $19;  // PA0 - in; PB0 - out; PC0 - in
      fPCI1751.P1_Mode := $10;  // PA1 - in; PB1 - out; PC1 - out
      Writeln(' P0 Mode = ', fPCI1751.P0_Mode);
      Writeln(' P1 Mode = ', fPCI1751.P1_Mode);

      { Сигнал "К СБРОС" }
        fPCI1751.PC1[2] := 0;
        Sleep(100);
        fPCI1751.PC1[2] := 1;

      while (not KeyPressed) do
      begin
//        OutputCycle('164772', '7777');
//        OutputCycle('163002', '0000');

//        OutputCycle('163312', '0000');
        OutputCycle('163312', '7777');
      end;

//      Out32(fPCI1751.BaseAddr + 1, $00);  // PB0
//      Out32(fPCI1751.BaseAddr + 5, $00);  // PB1
//      Out32(fPCI1751.BaseAddr + 6, $00);  // PC1
//
//      for i := 0 to 7 do
//      begin
//        while(not KeyPressed) do
//        begin
//          fPCI1751.PB0[i] := 0;
//          Sleep(500);
//          fPCI1751.PB0[i] := 1;
//          Sleep(500);
//          Writeln('PB0', i, ' strobe');
//        end;
//        ReadKey;
//      end;
//
//      for i := 0 to 7 do
//      begin
//        while(not KeyPressed) do
//        begin
//          fPCI1751.PB1[i] := 0;
//          Sleep(500);
//          fPCI1751.PB1[i] := 1;
//          Sleep(500);
//          Writeln('PB1', i, ' strobe');
//        end;
//        ReadKey;
//      end;
//
//      for i := 2 to 7 do
//      begin
//        while(not KeyPressed) do
//        begin
//          fPCI1751.PC1[i] := 0;
//          Sleep(500);
//          fPCI1751.PC1[i] := 1;
//          Sleep(500);
//          Writeln('PC1', i, ' strobe');
//        end;
//        ReadKey;
//      end;

    end;
  finally
    fPCI1751.Free;
  end;   

  TextColor(LightRed);
  TextBackground(Yellow);
  Writeln('OK');
  ReadKey;
  { TODO -oUser -cConsole Main : Insert code here }
end.
