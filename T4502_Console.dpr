program T4502_Console;

{$APPTYPE CONSOLE}
{$O-}

uses
  SysUtils, Windows,
  Console, CONVUNIT,
  T4502 in 'T4502.pas';

var
  fTester: TT4502;
//  i, j: integer;
//  InData: Word;

begin
  SetConsoleCP(1251);
  SetConsoleOutputCP(1251);

  Writeln('1. Поиск платы согласования "PCI-1751"...');
  fTester := TT4502.Create();
  try
    if fTester.IO.Emulation then
    begin
      Writeln(#9'Плата согласования "PCI-1751" не найдена.');
      ReadKey;
      Exit;
    end
    else
      Writeln(#9'Найдена плата согласования: ', fTester.IO.FriendlyName,
        ' (0x', Format('%x', [fTester.IO.BaseAddr]), ')');


    Writeln('2. Загрузка плана...');
    fTester.WP.Plans[1].LoadFromFile('..\PRG\KP3.TXT');
    Writeln(#9'План №1: "', fTester.WP.Plans[1].Caption, '" загружен');
    Writeln(#9'Всего тестов: ', fTester.WP.Plans[1].Count-1);

    
//    for i := 0 to fTester.WP.Plans[1].Count - 1 do
//    begin
//      Writeln('T', fTester.WP.Plans[1].Items[i].N);
//      for j := 0 to fTester.WP.Plans[1][i].Count-1 do
//            Write(fTester.WP.Plans[1][i][j].K, ' ', fTester.WP.Plans[1][i][j].V, '; ');
//      Writeln;
//    end;

//    ReadKey;

//    if fTester.IO.Emulation then
//      Writeln('Emulation mode')
//    else
//    begin
//      Writeln(fTester.IO.FriendlyName, ' (0x', IntToHex(fTester.IO.BaseAddr, 4), ')');
//      Writeln(' P0 Mode = ', fTester.IO.P0_Mode);
//      Writeln(' P1 Mode = ', fTester.IO.P1_Mode);
//      ReadKey;
//
//      while (not KeyPressed) do
//      begin
//        Writeln(fTester.PASS);
//      end;
//      ReadKey;
//    end;
  finally
    fTester.Free;
  end;

  TextColor(LightRed);
  TextBackground(Yellow);
  Writeln;
  Write('OK');
  ReadKey;
end.
