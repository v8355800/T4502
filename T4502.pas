unit T4502;

interface

type
  TCommand = String[4];
  TT4502_IO = class(TObject)
  public
    procedure Command(const K: TCommand);
  end;

type
  TT4502_Commands = class(TObject)
  public
//    function GrKlas:word; stdcall; external 'pci1751t4502.dll';
//    function GetBaseAdr:integer; stdcall; external 'pci1751t4502.dll';
//    function GetEdiz:string; stdcall; external 'pci1751t4502.dll';
//    function GetsRez:string; stdcall; external 'pci1751t4502.dll';


//    procedure RsetT4502;  stdcall; external 'pci1751t4502.dll';
//    procedure U02(s:string);  stdcall; external 'pci1751t4502.dll';
//
//    procedure U11(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U12(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U21(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U22(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U31(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U32(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U41(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U42(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U51(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U52(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U61(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U62(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U71(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U72(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure U73(s:string);  stdcall; external 'pci1751t4502.dll';
//
//    procedure D01(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure D02(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure Y02(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure Y01(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure R(s:string);  stdcall; external 'pci1751t4502.dll';
//    procedure KM(n:byte; s:string);stdcall; external 'pci1751t4502.dll';
//    procedure PlanPultPrin(var Ntst,Npt,Npl,RgP:word);  stdcall; external 'pci1751t4502.dll';
//    function T4502Ready(flag:boolean):boolean; stdcall; external 'pci1751t4502.dll';
//    procedure EndTst; stdcall; external 'pci1751t4502.dll';
//    procedure EndProg(GrKlas:word);stdcall;external 'pci1751t4502.dll';
  end;

type
  TT4502 = class(TObject)
  private
    fIO: TT4502_IO;
    fCommands: TT4502_Commands;
  protected

  public
    property Commands: TT4502_Commands read fCommands;
    //    constructor Create; override;
    //    destructor Destroy; override;
  end;

implementation


//------------------------------------------------------------------------------
// TT4502_IO
//------------------------------------------------------------------------------
procedure TT4502_IO.Command(const K: TCommand);
begin

end;

{ TT4502_Commands }

//procedure TT4502_Commands.K01;
//begin
//
//end;

end.

