program T4502_Console;

{$APPTYPE CONSOLE}
{$O-}

uses
  SysUtils,
  Console, CONVUNIT,
  T4502 in 'T4502.pas';

var
  fTester: TT4502;
//  i: integer;
  InData: Word;

begin
  fTester := TT4502.Create();
  try
    if fTester.IO.Emulation then
      Writeln('Emulation mode')
    else
    begin
      Writeln(fTester.IO.FriendlyName, ' (0x', IntToHex(fTester.IO.BaseAddr, 4), ')');
      Writeln(' P0 Mode = ', fTester.IO.P0_Mode);
      Writeln(' P1 Mode = ', fTester.IO.P1_Mode);
      ReadKey;

      while (not KeyPressed) do
      begin
        Writeln(fTester.Propusk);
      end;
      ReadKey;
    end;
  finally
    fTester.Free;
  end;   

  TextColor(LightRed);
  TextBackground(Yellow);
  Write('OK');
  ReadKey;
end.
