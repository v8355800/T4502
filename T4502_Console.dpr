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

begin
//  fIO := TT4502_IO.Create;
////  fIO.U11('123');
//  fIO.Free;

  fPCI1751 := TPCI1751.Create;
  try
    fPCI1751.SetPortMode(PA0, pmIN);
    fPCI1751.SetPortMode(PB0, pmOUT);
    fPCI1751.SetPortMode(PC0_L, pmIN);
    fPCI1751.SetPortMode(PC0_H, pmIN);

    fPCI1751.SetPortMode(PA1, pmIN);
    fPCI1751.SetPortMode(PB1, pmOUT);
    fPCI1751.SetPortMode(PC1_L, pmOUT);
    fPCI1751.SetPortMode(PC1_H, pmOUT);
  finally
    fPCI1751.Free;
  end;   

  TextColor(LightRed);
  TextBackground(Yellow);
  Writeln('OK');
  ReadKey;
  { TODO -oUser -cConsole Main : Insert code here }
end.
