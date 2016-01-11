program T4502_Console;

{$APPTYPE CONSOLE}
{$O-}

uses
  SysUtils,
  Console,
  T4502 in 'T4502.pas';

var
  fIO: TT4502_IO;

begin
  fIO := TT4502_IO.Create;
//  fIO.U11('123');
  fIO.Free;

  TextColor(LightRed);
  TextBackground(Yellow);
  Writeln('OK');
  ReadKey;
  { TODO -oUser -cConsole Main : Insert code here }
end.
