program T4502_Console;

{$APPTYPE CONSOLE}
{$O-}

uses
  SysUtils, Windows,
  Console, CONVUNIT,
  T4502 in 'T4502.pas';

var
  fTester: TT4502;
  i, j: integer;
  InData: Word;

begin
  SetConsoleCP(1251);
  SetConsoleOutputCP(1251);

  fTester := TT4502.Create();
  try
//    fTester.WP.Plans[1].LoadFromFile('..\PRG\KP3.TXT');
    fTester.WP.Plans[1].Add(TTest.Create);
    fTester.WP.Plans[1].Caption := 'План 1';
    fTester.WP.Plans[1][0].N := 4;
    fTester.WP.Plans[1][0].AddCommand('01', '0001');
    fTester.WP.Plans[1][0].AddCommand('02', '0002');

    Writeln(fTester.WP.Plans[1].Caption);
    for i := 0 to fTester.WP.Plans[1].Count - 1 do
    begin
      Writeln('T', fTester.WP.Plans[1].Items[i].N);
      for j := 0 to fTester.WP.Plans[1][i].Count-1 do
            Write(fTester.WP.Plans[1][i][j].K, ' ', fTester.WP.Plans[1][i][j].V, '; ');
    end;
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
