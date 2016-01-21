unit CONVUNIT;
{ CONVUNIT UNIT 1.1                 }
{ Copyright (C) 1997 H�kon Stordahl }

{ E-mail  : stordahl@usa.net             }
{ Homepage: http://stordahl.home.ml.org/ }

interface

function DEC2BIN(DEC: LONGINT): string;
function BIN2DEC(BIN: string): LONGINT;
function DEC2HEX(DEC: LONGINT): string;
function HEX2DEC(HEX: string): LONGINT;
function DEC2OCT(DEC: LONGINT): string;
function OCT2DEC(OCT: string): LONGINT;
function BIN2HEX(BIN: string): string;
function HEX2BIN(HEX: string): string;
function DEC2BASEN(BASE: INTEGER; DEC: LONGINT): string;
{ This function converts numbers from decimal (Base 10 notation) to
  different systems of notation. Valid systems are from Base 2 notation
  to Base 36 notation }
function BASEN2DEC(BASE: INTEGER; NUM: string): LONGINT;
{ This function converts numbers from different systems of notation
  to decimal (Base 10 notation). Valid systems are from Base 2 notation
  to Base 36 notation }

implementation

function DEC2BIN(DEC: LONGINT): string;

var
  BIN: string;
  I, J: LONGINT;

begin
  if DEC = 0 then
    BIN := '0'
  else
  begin
    BIN := '';
    I := 0;
    while (1 shl (I + 1)) <= DEC do
      I := I + 1;
    { (1 SHL (I + 1)) = 2^(I + 1) }
    for J := 0 to I do
    begin
      if (DEC shr (I - J)) = 1 then
        BIN := BIN + '1'
          { (DEC SHR (I - J)) = DEC DIV 2^(I - J) }
      else
        BIN := BIN + '0';
      DEC := DEC and ((1 shl (I - J)) - 1);
      { DEC AND ((1 SHL (I - J)) - 1) = DEC MOD 2^(I - J) }
    end;
  end;
  DEC2BIN := BIN;
end;

function BIN2DEC(BIN: string): LONGINT;

var
  J: LONGINT;
  Error: BOOLEAN;
  DEC: LONGINT;

begin
  DEC := 0;
  Error := False;
  for J := 1 to Length(BIN) do
  begin
    if (BIN[J] <> '0') and (BIN[J] <> '1') then
      Error := True;
    if BIN[J] = '1' then
      DEC := DEC + (1 shl (Length(BIN) - J));
    { (1 SHL (Length(BIN) - J)) = 2^(Length(BIN)- J) }
  end;
  if Error then
    BIN2DEC := 0
  else
    BIN2DEC := DEC;
end;

function DEC2HEX(DEC: LONGINT): string;

const
  HEXDigts: string[16] = '0123456789ABCDEF';

var
  HEX: string;
  I, J: LONGINT;

begin
  if DEC = 0 then
    HEX := '0'
  else
  begin
    HEX := '';
    I := 0;
    while (1 shl ((I + 1) * 4)) <= DEC do
      I := I + 1;
    { 16^N = 2^(N * 4) }
    { (1 SHL ((I + 1) * 4)) = 16^(I + 1) }
    for J := 0 to I do
    begin
      HEX := HEX + HEXDigts[(DEC shr ((I - J) * 4)) + 1];
      { (DEC SHR ((I - J) * 4)) = DEC DIV 16^(I - J) }
      DEC := DEC and ((1 shl ((I - J) * 4)) - 1);
      { DEC AND ((1 SHL ((I - J) * 4)) - 1) = DEC MOD 16^(I - J) }
    end;
  end;
  DEC2HEX := HEX;
end;

function HEX2DEC(HEX: string): LONGINT;

  function Digt(Ch: CHAR): BYTE;

  const
    HEXDigts: string[16] = '0123456789ABCDEF';

  var
    I: BYTE;
    N: BYTE;

  begin
    N := 0;
    for I := 1 to Length(HEXDigts) do
      if Ch = char(HEXDigts[I]) then
        N := I - 1;
    Digt := N;
  end;

const
  HEXSet: set of CHAR = ['0'..'9', 'A'..'F'];

var
  J: LONGINT;
  Error: BOOLEAN;
  DEC: LONGINT;

begin
  DEC := 0;
  Error := False;
  for J := 1 to Length(HEX) do
  begin
    if not (UpCase(HEX[J]) in HEXSet) then
      Error := True;
    DEC := DEC + Digt(UpCase(HEX[J])) shl ((Length(HEX) - J) * 4);
    { 16^N = 2^(N * 4) }
    { N SHL ((Length(HEX) - J) * 4) = N * 16^(Length(HEX) - J) }
  end;
  if Error then
    HEX2DEC := 0
  else
    HEX2DEC := DEC;
end;

function DEC2OCT(DEC: LONGINT): string;

const
  OCTDigts: string[8] = '01234567';

var
  OCT: string;
  I, J: LONGINT;

begin
  if DEC = 0 then
    OCT := '0'
  else
  begin
    OCT := '';
    I := 0;
    while (1 shl ((I + 1) * 3)) <= DEC do
      I := I + 1;
    { 8^N = 2^(N * 3) }
    { (1 SHL (I + 1)) = 8^(I + 1) }
    for J := 0 to I do
    begin
      OCT := OCT + OCTDigts[(DEC shr ((I - J) * 3)) + 1];
      { (DEC SHR ((I - J) * 3)) = DEC DIV 8^(I - J) }
      DEC := DEC and ((1 shl ((I - J) * 3)) - 1);
      { DEC AND ((1 SHL ((I - J) * 3)) - 1) = DEC MOD 8^(I - J) }
    end;
  end;
  DEC2OCT := OCT;
end;

function OCT2DEC(OCT: string): LONGINT;

const
  OCTSet: set of CHAR = ['0'..'7'];

var
  J: LONGINT;
  Error: BOOLEAN;
  DEC: LONGINT;

begin
  DEC := 0;
  Error := False;
  for J := 1 to Length(OCT) do
  begin
    if not (UpCase(OCT[J]) in OCTSet) then
      Error := True;
    DEC := DEC + (Ord(OCT[J]) - 48) shl ((Length(OCT) - J) * 3);
    { 8^N = 2^(N * 3) }
    { N SHL ((Length(OCT) - J) * 3) = N * 8^(Length(OCT) - J) }
  end;
  if Error then
    OCT2DEC := 0
  else
    OCT2DEC := DEC;
end;

function BIN2HEX(BIN: string): string;

  function SetHex(St: string; var Error: BOOLEAN): CHAR;

  var
    Ch: CHAR;

  begin
    if St = '0000' then
      Ch := '0'
    else if St = '0001' then
      Ch := '1'
    else if St = '0010' then
      Ch := '2'
    else if St = '0011' then
      Ch := '3'
    else if St = '0100' then
      Ch := '4'
    else if St = '0101' then
      Ch := '5'
    else if St = '0110' then
      Ch := '6'
    else if St = '0111' then
      Ch := '7'
    else if St = '1000' then
      Ch := '8'
    else if St = '1001' then
      Ch := '9'
    else if St = '1010' then
      Ch := 'A'
    else if St = '1011' then
      Ch := 'B'
    else if St = '1100' then
      Ch := 'C'
    else if St = '1101' then
      Ch := 'D'
    else if St = '1110' then
      Ch := 'E'
    else if St = '1111' then
      Ch := 'F'
    else
      Error := True;
    SetHex := Ch;
  end;

var
  HEX: string;
  I: INTEGER;
  Temp: string[4];
  Error: BOOLEAN;

begin
  Error := False;
  if BIN = '0' then
    HEX := '0'
  else
  begin
    Temp := '';
    HEX := '';
    if Length(BIN) mod 4 <> 0 then
      repeat
        BIN := '0' + BIN;
      until Length(BIN) mod 4 = 0;
    for I := 1 to Length(BIN) do
    begin
      Temp := Temp + BIN[I];
      if Length(Temp) = 4 then
      begin
        HEX := HEX + SetHex(Temp, Error);
        Temp := '';
      end;
    end;
  end;
  if Error then
    BIN2HEX := '0'
  else
    BIN2HEX := HEX;
end;

function HEX2BIN(HEX: string): string;

var
  BIN: string;
  I: INTEGER;
  Error: BOOLEAN;

begin
  Error := False;
  BIN := '';
  for I := 1 to Length(HEX) do
    case UpCase(HEX[I]) of
      '0': BIN := BIN + '0000';
      '1': BIN := BIN + '0001';
      '2': BIN := BIN + '0010';
      '3': BIN := BIN + '0011';
      '4': BIN := BIN + '0100';
      '5': BIN := BIN + '0101';
      '6': BIN := BIN + '0110';
      '7': BIN := BIN + '0111';
      '8': BIN := BIN + '1000';
      '9': BIN := BIN + '1001';
      'A': BIN := BIN + '1010';
      'B': BIN := BIN + '1011';
      'C': BIN := BIN + '1100';
      'D': BIN := BIN + '1101';
      'E': BIN := BIN + '1110';
      'F': BIN := BIN + '1111';
    else
      Error := True;
    end;
  if Error then
    HEX2BIN := '0'
  else
    HEX2BIN := BIN;
end;

function Potens(X, E: LONGINT): LONGINT;

var
  P, I: LONGINT;

begin
  P := 1;
  if E = 0 then
    P := 1
  else
    for I := 1 to E do
      P := P * X;
  Potens := P;
end;

function DEC2BASEN(BASE: INTEGER; DEC: LONGINT): string;
{ This function converts numbers from decimal (Base 10 notation) to
  different systems of notation. Valid systems are from Base 2 notation
  to Base 36 notation }

const
  NUMString: string = '0123456789ABCDEFGHAIJKLMNOPQRSTUVWXYZ';

var
  NUM: string;
  I, J: INTEGER;

begin
  if (DEC = 0) or (BASE < 2) or (BASE > 36) then
    NUM := '0'
  else
  begin
    NUM := '';
    I := 0;
    while Potens(BASE, I + 1) <= DEC do
      I := I + 1;
    for J := 0 to I do
    begin
      NUM := NUM + NUMString[(DEC div Potens(BASE, I - J)) + 1];
      DEC := DEC mod Potens(BASE, I - J);
    end;
  end;
  DEC2BASEN := NUM;
end;

function BASEN2DEC(BASE: INTEGER; NUM: string): LONGINT;
{ This function converts numbers from different systems of notation
  to decimal (Base 10 notation). Valid systems are from Base 2 notation
  to Base 36 notation }

  function Digt(Ch: CHAR): BYTE;

  const
    NUMString: string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  var
    I: BYTE;
    N: BYTE;

  begin
    N := 0;
    for I := 1 to Length(NUMString) do
      if Ch = NUMString[I] then
        N := I - 1;
    Digt := N;
  end;

const
  NUMSet: set of CHAR = ['0'..'9', 'A'..'Z'];

var
  J: INTEGER;
  Error: BOOLEAN;
  DEC: LONGINT;

begin
  DEC := 0;
  Error := False;
  if (BASE < 2) or (BASE > 36) then
    Error := True;
  for J := 1 to Length(NUM) do
  begin
    if (not (UpCase(NUM[J]) in NUMSet)) or (BASE < Digt(NUM[J]) + 1) then
      Error
        := True;
    DEC := DEC + Digt(UpCase(NUM[J])) * Potens(BASE, Length(NUM) - J);
  end;
  if Error then
    BASEN2DEC := 0
  else
    BASEN2DEC := DEC;
end;

end.
