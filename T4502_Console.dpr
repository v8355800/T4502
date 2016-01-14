program T4502_Console;

{$APPTYPE CONSOLE}
{$O-}

uses
  SysUtils,
  Console,
  T4502 in 'T4502.pas',
  PCI1751 in 'PCI1751.pas';

var
  fIO: TT4502_IO;
  fPCI1751: TPCI1751;
  i: integer;

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

      {      Цыкл "ВЫВОД"        }
      { передача данных в тестер }
          //16xxx0
          //16xxx2
          //16xxx4
        // 1. К ДА = 160004
          Out32(fPCI1751.BaseAddr + 1, $4C);  // PB0
          Out32(fPCI1751.BaseAddr + 5, $E2);  // PB1
        // 2. К ВУ = 0
          fPCI1751.PC1[5] := 0;
        // 3. К СИА = 0
          fPCI1751.PC1[3] := 0;
        // 4. К ДА = 0
          Out32(fPCI1751.BaseAddr + 1, $00);  // PB0
          Out32(fPCI1751.BaseAddr + 5, $00);  // PB1
        // 5. К ВУ = 1
          fPCI1751.PC1[5] := 1;
        // 6. К ДА = $FFFF
          Out32(fPCI1751.BaseAddr + 1, $FF);  // PB0
          Out32(fPCI1751.BaseAddr + 5, $FF);  // PB1
        // 7. К ВЫВОД = 0
          fPCI1751.PC1[6] := 0;
        // 8. Ждем, пока К СИП не станет равен 0
        while (fPCI1751.PC0[2] = 1) do ;
        // 9. К ВЫВОД = 1
          fPCI1751.PC1[6] := 1;
        // 10. К ДА = 0
          Out32(fPCI1751.BaseAddr + 1, $00);  // PB0
          Out32(fPCI1751.BaseAddr + 5, $00);  // PB1
        // 11. Ждем, пока К СИП не станет равен 1
        while (fPCI1751.PC0[2] = 0) do ;
        // 12. К СИА = 1
          fPCI1751.PC1[3] := 1;


//      {      Цыкл "ВВОД"         }
//      { чтение данных из тестера }
//

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
