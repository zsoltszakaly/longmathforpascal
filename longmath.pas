unit longmath;

//**********************************************************************************************************************************
//
//  Pascal unit to declare and manipulate very large integer numbers with some limited floating support
//
//  Copyright: (C) 2021, Zsolt Szakaly
//
//  This source is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as
//  published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
//
//  This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
//
//  A copy of the GNU General Public License is available on the World Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can
//  also obtain it by writing to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.
//
//  Change log: 24/11/2021 Initial version
//
//**********************************************************************************************************************************
//
//  Description
//
//  Operators or functions
//    For most operations there are two approaches:
//      A function: Number1:= Multiply(Number2, Number3);
//      An operator overload: Number1 := Number2 * Number3;
//
//  Error reporting
//    If an error occurs then an Exception is raised (unless switched off)
//    The return code of the operation is always set in LongMathReturnCode
//      Warning : for multiple operations the error code is set to the last operation. If there is no exception used, this can be
//        misleading:
//        Number1 := Multiply(Number2, 'zzz'); is OK, because the Number := 'zzz' hidden typecast returns an error, but then it is
//          overwritten by the Multiply function, what works, hence the final setting is lmOK!
//      If in doubt, use two steps:
//        Number1 := 'zzz';
//        if LongMathReturnCode <> lmOK then
//          DoSomething
//        else
//          Number1 := Multiply(Number2, Number1);
//
//  Assigning values
//    There are many ways to assign value to a tLongNumber
//      The easiest is to use the := operator
//        NumberType := IntegerType; // any integer type from int8 to uint64
//        NumberType := StringType;
//          Number := '100';       // 100 in base 10 (if the LongMathDefaultDisplayBase is not something else)
//          Number := '%1100100';  // 100 in base 2 Pascal style
//          Number := '0b1100100'; // 100 in base 2 C style
//          Number := '&144';      // 100 in base 8 Pascal style
//          Number := '0144';      // 100 in base 8 C style
//          Number := 'o144';      // 100 in base 8 other version
//          Number := 'O144';      // 100 in base 8 other version
//          Number := '144o';      // 100 in base 8 other version
//          Number := '144O';      // 100 in base 8 other version
//          Number := '$64';       // 100 in base 16 Pascal style
//          Number := 'Ox64';      // 100 in base 16 C style
//          Number := '64h';       // 100 in base 16 other version
//          Number := '64H';       // 100 in base 16 other version
//          Number := '91~9';      // 100 in base 9  or other base 2..16 can be used after the '~'
//          Number := '79(13';     // 100 in base 13 or other base 2..16 can be used after the '('
//        Negative numbers can have the minus sign in the first position or after the leading base specifier
//          Number := '-$64';      // -100 in base 16 with minus before the base prefix (any other prefix can work the same)
//          Number := '0-144       // -100 in base 8 with minus after the base prefix (any other prefix can work the same)
//          Number := '-202(7'     // -100 in base 7 with minus at the first position with base postfix (any base, any postfix)
//        NumberType := FloatingType; // any floating type; might have rounding errors
//          Number := -123.45E6;   // -123450000 using an explicit number rather than a floating type variable
//      Or a conversion function
//        NumberType := ConvertIntegerToNumber(); // any integer type
//        Various string conversion functions
//          Number := ConvertStringToNumber('400',5);      // 100 in base 5
//          Number := ConvertStringToNumber('100');        // 100 in base 10 (if the LongMathDefaultDisplayBase is 10)
//          Number := ConvertStringToNumber('$-64');       // -100 in base 16 (any format used in := can also be used here)
//          Number := ConvertBinStringToNumber('1100100'); // 100 in base 2
//          Number := ConvertOctStringToNumber('144');     // 100 in base 8
//          Number := ConvertDecStringToNumber('100');     // 100 in base 10
//          Number := ConvertHexStringToNumber('64');      // 100 in base 16
//        NumberType := ConvertExtendedToNumber(); // any floating type
//  Returning values
//    The other direction is easier
//      Here also an operator can be used
//        IntegerType  := NumberType; // returns the value in the given integer type (if does not fit an error is reported)
//        StringType   := NumberType; // returns the string in the display base of MyNumber
//        ExtendedType := NumberType; // only "extended" is implemented, other floating types not!
//      Or an explicit function
//        IntegerType  := ConvertNumberToInteger(Number);     // all integer types are implemented
//        StringType   := ConvertNumberToString(Number,Base); // any base 2..16
//        StringType   := ConvertNumberToString(Number);      // in the display base of Number
//        StringType   := ConvertNumberToBinString(Number);   // base 2
//        StringType   := ConvertNumberToOctString;           // base 8
//        StringType   := ConvertNumberToDecString;           // base 10
//        StringType   := ConvertNumberToHexString;           // base 16
//        ExtendedType := ConvertNumberToExtended;            // only "extended" is implemented
//
//  Display base
//    For every internally stored tLongNumber variable has a "display base", i.e. the default base to use when converted to a string
//    The display base of a number can origin from three places:
//      If a NumberType := (IntegerType | FloatingType) assignment is made, it is the DefaultDisplayBase (10,
//        but can be overwritten for the whole program
//      If it is assigned from a string through an operator or function from a string, it is the base used in the string formatting
//      If it is assigned through a LongMath operator or function then it inherites it from the first operand. Be careful, it can
//        cause strange results:
//          L1 := '$64';  // 100 in base 16
//          L2 := '144o'; // 100 in base 8
//          L3 := L1 + L2;
//          L4 := L2 + L1;
//          S := L3;      // S = 'C8', i.e. 200 in base 16 (inherited from L1)
//          S := L4;      // S = '310', i.e. 200 in base 8 (inherited from L2)
//        hence it is not recommended to mix display bases within one program!
//
//  Number range
//    Theoretically there is no limit. It depends on the available memory, but typically speed is more limiting than space
//    Be especially careful when using Exponent (or **) as the number can be very large quick.
//    Most of the large number calculations can be simplified using a Modulus circle.
//
//  Modulo with negative numbers
//    It follows the same logic, what is used in Pascal, i.e.
//       5 div -3 = -1 and  5 mod -3 =  2
//      -5 div  3 = -1 and -5 mod  3 = -2
//      -5 div -3 =  1 and -5 mod -3 = -2
//    and NOT the way I would find more "logical", i.e. the modulo is always positive
//       5 div -3 = -1 and  5 mod -3 =  2
//      -5 div  3 = -2 and -5 mod  3 =  1
//      -5 div -3 =  2 and -5 mod -3 =  1
//    and NOT the other "logical" way where the sign of the modulo equals to the sign of the Divisor
//       5 div -3 = -2 and  5 mod -3 = -1
//      -5 div  3 = -1 and -5 mod  3 = -2
//      -5 div -3 =  1 and -5 mod -3 = -2
//
//  Usage
//    Read the interface section. Most functions and operators are self explanatory.
//    Check some examples in the program example.pas.
//
//**********************************************************************************************************************************

{$mode objfpc}                // so result can be used
{$H+}                         // use ansistring
{$OPTIMIZATION LEVEL3}        // to make it faster
{$define AVOIDHINTANDWARNING} // slows down the execution, but avoids compiler hints and warning. REMOVE IT IF YOU CAN!

interface

type // The LongMathReturnCode is set after every function, procedure or operation to one of the following values.
  tLongMathReturnCode = (
    lmOK,
    lmDivisionByZero,
    lmInvalidBase,
    lmNegativeNumber,
    lmTooLargeNumber
    );

type // Numbers can be entererd and displayed in any base between 2 and 16.
  tLongMathDisplayBase = 2..16;

type // The type for the number. Normally the user should not see it in details.
  tLongNumber = record
    IsPositive      : boolean;
    SignificantBits : uint32;
    DisplayBase     : tLongMathDisplayBase;
    Value           : array of uint32;
    end;

var // The LongMathReturnCode is set after every function, procedure or operation.
  LongMathReturnCode : tLongMathReturnCode = lmOK;

var // When the base is not specified conversion from and to a string is done using a default.
  LongMathDefaultDisplayBase : tLongMathDisplayBase = 10;

var // Errors can raise an exception, but can be suppresed by setting LongMathRaiseException to false.
  LongMathRaiseException : boolean = true;

// Conversion functions and operators from and to a standard integer type
function ConvertIntegerToNumber(aInput : uint64) : tLongNumber;
function ConvertIntegerToNumber(const aInput : int64)  : tLongNumber;
function ConvertNumberToUInt8  (const aInput : tLongNumber ) : uint8;
function ConvertNumberToUInt16 (const aInput : tLongNumber ) : uint16;
function ConvertNumberToUInt32 (const aInput : tLongNumber ) : uint32;
function ConvertNumberToUInt64 (const aInput : tLongNumber ) : uint64;
function ConvertNumberToInt8   (const aInput : tLongNumber ) : int8;
function ConvertNumberToInt16  (const aInput : tLongNumber ) : int16;
function ConvertNumberToInt32  (const aInput : tLongNumber ) : int32;
function ConvertNumberToInt64  (const aInput : tLongNumber ) : int64;
operator := (const aInput : uint64) : tLongNumber;
operator := (const aInput : int64) : tLongNumber;
operator := (const aInput : tLongNumber ) : uint8;
operator := (const aInput : tLongNumber ) : uint16;
operator := (const aInput : tLongNumber ) : uint32;
operator := (const aInput : tLongNumber ) : uint64;
operator := (const aInput : tLongNumber ) : int8;
operator := (const aInput : tLongNumber ) : int16;
operator := (const aInput : tLongNumber ) : int32;
operator := (const aInput : tLongNumber ) : int64;

// Conversion functions and operators from and to a string
function ConvertStringToNumber(aString : string; aBase : tLongMathDisplayBase) : tLongNumber;
function ConvertStringToNumber(aString : string) : tLongNumber;
function ConvertBinStringToNumber(aString : string ) : tLongNumber;
function ConvertOctStringToNumber(aString : string ) : tLongNumber;
function ConvertDecStringToNumber(aString : string ) : tLongNumber;
function ConvertHexStringToNumber(aString : string ) : tLongNumber;
function ConvertNumberToString(aNumber : tLongNumber; aBase : tLongMathDisplayBase) : string;
function ConvertNumberToString(const aNumber : tLongNumber) : string;
function ConvertNumberToBinString(const aNumber : tLongNumber) : string;
function ConvertNumberToOctString(const aNumber : tLongNumber) : string;
function ConvertNumberToDecString(const aNumber : tLongNumber) : string;
function ConvertNumberToHexString(const aNumber : tLongNumber) : string;
operator := (const aString : string ) : tLongNumber;
operator := (const aNumber : tLongNumber) : string;

// Conversion functions and operators from and to an extended (approximate values)
function ConvertExtendedToNumber(aNumber : extended) : tLongNumber;
function ConvertNumberToExtended(const aNumber : tLongNumber) : extended;
operator := (const aNumber : extended) : tLongNumber;
operator := (const aNumber : tLongNumber) : extended;

// Relation functions and operators
function Lesser(aNumber1, aNumber2 : tLongNumber) : boolean;
function Greater(const aNumber1, aNumber2 : tLongNumber) : boolean;
function LesserEqual(const aNumber1, aNumber2 : tLongNumber) : boolean;
function GreaterEqual(const aNumber1, aNumber2 : tLongNumber) : boolean;
function Equal(const aNumber1, aNumber2 : tLongNumber) : boolean;
operator <  (const aNumber1, aNumber2 : tLongNumber) : boolean;
operator >  (const aNumber1, aNumber2 : tLongNumber) : boolean;
operator <= (const aNumber1, aNumber2 : tLongNumber) : boolean;
operator >= (const aNumber1, aNumber2 : tLongNumber) : boolean;
operator =  (const aNumber1, aNumber2 : tLongNumber) : boolean;

// Sum functions and operator
function Sum(const aTerm1, aTerm2 : tLongNumber) : tLongNumber;
function Sum(const aTerm1, aTerm2, aModulus : tLongNumber) : tLongNumber;
operator +  (const aTerm1, aTerm2 : tLongNumber) : tLongNumber;
// Product functions and operator
function Product(const aFactor1, aFactor2 : tLongNumber) : tLongNumber;
function Product(const aFactor1, aFactor2, aModulus : tLongNumber) : tLongNumber;
operator *      (const aFactor1, aFactor2 : tLongNumber) : tLongNumber;
// Exponent functions and operator
function Exponent(const aBase, aExponent : tLongNumber) : tLongNumber;
function Exponent(const aBase, aExponent, aModulus : tLongNumber) : tLongNumber;
operator **      (const aBase, aExponent : tLongNumber) : tLongNumber;
// Difference function and operator
function Difference(aMinuend, aSubtrahend : tLongNumber) : tLongNumber;
operator -         (const aMinuend, aSubtrahend : tLongNumber) : tLongNumber;
// Division functions and operators
procedure Divide  (aDividend, aDivisor : tLongNumber; var aQuotient, aRemainder : tLongNumber);
function Quotient (const aDividend, aDivisor : tLongNumber) : tLongNumber;
function Remainder(const aDividend, aDivisor : tLongNumber) : tLongNumber;
function Fraction (const aDividend, aDivisor : tLongNumber) : Extended;
operator div      (const aDividend, aDivisor : tLongNumber) : tLongNumber;
operator mod      (const aDividend, aDivisor : tLongNumber) : tLongNumber;
operator /        (const aDividend, aDivisor : tLongNumber) : Extended;

// Parity checks
function Even(const aNumber : tLongNumber) : boolean;
function Odd (const aNumber : tLongNumber) : boolean;

// A quick test (2^p = 2 (mod p)) to filter out numbers that are surely not prime (not true the other way round)
// Also checks against the first nine primes (up to 23)
function Fermat2Test(const aNumber : tLongNumber) : boolean;
function NextFermat2Number(const aNumber : tLongNumber) : tLongNumber;

// Generate a pseudo random non-negative number with the given bit length (0 <= result < 2 ** aLength)
function RandomNumber(aLength : uint32) : tLongNumber;

implementation

uses
  Math, SysUtils;

const
  DigitBits = 32; // All calculations done on 32 bit "digits", to allow overflow up to 64 bits
  DigitBase = $100000000; // This is the base we calculate in

procedure Error(aErrorCode : tLongMathReturnCode);
  begin
  LongMathReturnCode := aErrorCode;
  if aErrorCode = lmOK then
    exit;
  if not LongMathRaiseException then
    exit;
  case aErrorCode of
    lmDivisionByZero: raise Exception.Create('Division by zero');
    lmInvalidBase   : raise Exception.Create('Invalid base specified');
    lmNegativeNumber: raise Exception.Create('Negative number');
    lmTooLargeNumber: raise Exception.Create('NumberTooLarge')
    else raise Exception.Create('Some other error');
    end;
  end;
function ValueDigit(const aNumber : tLongNumber; aPosition : uint32) : uint32;
  begin
  if length(aNumber.Value) <= aPosition then
    result := 0
  else
     result := aNumber.Value[aPosition];
  end;
function ValueBit(const aNumber : tLongNumber; aPosition : uint32) : boolean;
  var
    Position : uint32;
    Bit : uint32;
  begin
  Position := aPosition div DigitBits;
  Bit := aPosition mod DigitBits;
  Bit := 2 ** Bit;
  if length(aNumber.Value) <= Position then
    result := false
  else
     result := (aNumber.Value[Position] and Bit) > 0;
  end;
procedure Clean(var aNumber : tLongNumber);
  var
    HighDigit : uint64;
  begin
  while (length(aNumber.Value) > 0) and (aNumber.Value[pred(length(aNumber.Value))] = 0) do
    SetLength(aNumber.Value, pred(length(aNumber.Value)));
  if length(aNumber.Value) = 0 then
    begin
    aNumber.IsPositive := true;
    aNumber.SignificantBits := 0;
    exit;
    end;
  aNumber.SignificantBits := length(aNumber.Value) * DigitBits;
  HighDigit := 2 * aNumber.Value[pred(length(aNumber.Value))];
  while HighDigit < DigitBase do
    begin
    dec(aNumber.SignificantBits);
    HighDigit := 2 * HighDigit;
    end;
  end;

function ConvertIntegerToNumber(aInput : uint64) : tLongNumber;
  begin
  Error(lmOK);
  with result do
    begin
    IsPositive := true; // zero is handled as positive
    DisplayBase := LongMathDefaultDisplayBase;
    if aInput = 0 then
      begin
      SetLength(Value, 0);
      SignificantBits := 0;
      exit;
      end;
    SetLength(Value, 2);
    Value[0] := aInput mod DigitBase;
    Value[1] := aInput div DigitBase;
    SignificantBits := 1;
    while aInput > 1 do
      begin
      inc(SignificantBits);
      aInput := aInput div 2;
      end;
    if SignificantBits <= DigitBits then
      SetLength(Value,1);
    end;
  end;
function ConvertIntegerToNumber(const aInput : int64)  : tLongNumber;
  var
    Sign : boolean;
  begin
  Sign := aInput >= 0;
  result := uint64(abs(aInput));
  result.IsPositive := Sign;
  end;
function ConvertNumberToUInt8(const aInput : tLongNumber ) : uint8;
  begin
  Error(lmOK);
  with aInput do
    begin
    if SignificantBits = 0 then
      begin
      result := 0;
      exit;
      end;
    result := Value[0];
    if SignificantBits > 8 then // intentionally explicit 8, for uint8
      Error(lmTooLargeNumber);
    if not IsPositive then
      Error(lmNegativeNumber);
    end;
  end;
function ConvertNumberToUInt16(const aInput : tLongNumber ) : uint16;
  begin
  Error(lmOK);
  with aInput do
    begin
    if SignificantBits = 0 then
      begin
      result := 0;
      exit;
      end;
    result := Value[0];
    if SignificantBits > 16 then // intentionally explicit 16, for uint16
      Error(lmTooLargeNumber);
    if not IsPositive then
      Error(lmNegativeNumber);
    end;
  end;
function ConvertNumberToUInt32(const aInput : tLongNumber ) : uint32;
  begin
  Error(lmOK);
  with aInput do
    begin
    if SignificantBits = 0 then
      begin
      result := 0;
      exit;
      end;
    result := Value[0];
    if SignificantBits > 32 then // intentionally explicit 32, for uint32
      Error(lmTooLargeNumber);
    if not IsPositive then
      Error(lmNegativeNumber);
    end;
  end;
function ConvertNumberToUInt64(const aInput : tLongNumber ) : uint64;
  begin
  Error(lmOK);
  with aInput do
    begin
    if SignificantBits = 0 then
      begin
      result := 0;
      exit;
      end;
    result := Value[0];
    if SignificantBits > DigitBits then
      result := result + Value[1] * DigitBase;
    if SignificantBits > 64 then // intentionally explicit 64, for uint64
      Error(lmTooLargeNumber);
    if not IsPositive then
      Error(lmNegativeNumber);
    end;
  end;
function ConvertNumberToInt8(const aInput : tLongNumber ) : int8;
  begin
  Error(lmOK);
  with aInput do
    begin
    if SignificantBits = 0 then
      begin
      result := 0;
      exit;
      end;
    result := Value[0];
    if not IsPositive then
      result := -result;
    if SignificantBits > 7 then // intentionally explicit 7, for int8
      Error(lmTooLargeNumber);
    end;
  end;
function ConvertNumberToInt16(const aInput : tLongNumber ) : int16;
  begin
  Error(lmOK);
  with aInput do
    begin
    if SignificantBits = 0 then
      begin
      result := 0;
      exit;
      end;
    result := Value[0];
    if not IsPositive then
      result := -result;
    if SignificantBits > 15 then // intentionally explicit 15, for int16
      Error(lmTooLargeNumber);
    end;
  end;
function ConvertNumberToInt32(const aInput : tLongNumber ) : int32;
  begin
  Error(lmOK);
  with aInput do
    begin
    if SignificantBits = 0 then
      begin
      result := 0;
      exit;
      end;
    result := Value[0];
    if not IsPositive then
      result := -result;
    if SignificantBits > 31 then // intentionally explicit 31, for int32
      Error(lmTooLargeNumber);
    end;
  end;
function ConvertNumberToInt64(const aInput : tLongNumber ) : int64;
  begin
  Error(lmOK);
  with aInput do
    begin
    if SignificantBits = 0 then
      begin
      result := 0;
      exit;
      end;
    result := Value[0];
    if SignificantBits > DigitBits then
      result := result + Value[1] * DigitBase;
    if not IsPositive then
      result := -result;
    if SignificantBits > 64 then // intentionally explicit 63, for int64
      Error(lmTooLargeNumber);
    end;
  end;

operator := (const aInput : uint64) : tLongNumber;
  begin
  result := ConvertIntegerToNumber(aInput);
  end;
operator := (const aInput : int64) : tLongNumber;
  begin
  result := ConvertIntegerToNumber(aInput);
  end;
operator := (const aInput : tLongNumber) : uint8;
  begin
  result := ConvertNumberToUInt8(aInput);
  end;
operator := (const aInput : tLongNumber) : uint16;
  begin
  result := ConvertNumberToUInt16(aInput);
  end;
operator := (const aInput : tLongNumber) : uint32;
  begin
  result := ConvertNumberToUInt32(aInput);
  end;
operator := (const aInput : tLongNumber) : uint64;
  begin
  result := ConvertNumberToUInt64(aInput);
  end;
operator := (const aInput : tLongNumber) : int8;
  begin
  result := ConvertNumberToInt8(aInput);
  end;
operator := (const aInput : tLongNumber) : int16;
  begin
  result := ConvertNumberToInt16(aInput);
  end;
operator := (const aInput : tLongNumber) : int32;
  begin
  result := ConvertNumberToInt32(aInput);
  end;
operator := (const aInput : tLongNumber) : int64;
  begin
  result := ConvertNumberToInt64(aInput);
  end;

function ConvertStringToNumber(aString : string; aBase : tLongMathDisplayBase) : tLongNumber;
  var
    Multiplier, Base : tLongNumber;
    InputDigit : integer;
    ResultSign : boolean = true;
  begin
  Error(lmOK);
  result := ConvertIntegerToNumber(0);
  result.DisplayBase := aBase;
  if (length(aString)=0) then
    exit;
  if aString[1] = '-' then
    begin
    aString := Copy(aString,2);
    ResultSign := false;
    end;
  Base := ConvertIntegerToNumber(aBase);
  Multiplier := ConvertIntegerToNumber(1);
  repeat
    InputDigit := ord(upcase(aString[length(aString)]))-ord('0');
    if InputDigit > 9 then
      InputDigit := InputDigit - ord('A') + ord('0') + 10;
    if (InputDigit > aBase) or (InputDigit<0) then
      Error(lmInvalidBase);
    result := Sum(result, Product(Multiplier, InputDigit) );
    Multiplier := Product(Multiplier, Base);
    SetLength(aString, length(aString)-1);
    until length(aString) = 0;
  result.IsPositive := ResultSign;
  end;
function ConvertStringToNumber(aString : string) : tLongNumber;
  var
    SeparatorPosition : LongWord;
    Base : integer;
    NegativeSign : string = '';
  begin
  if Length(aString) = 0 then
    begin
    result := 0;
    exit;
    end;
  if aString[1] = '-' then
    begin
    aString := Copy(aString,2);
    NegativeSign := '-';
    end;
  if Pos('0b',aString) = 1 then // C style binary
    begin
    if Length(aString) = 2 then
      begin
      result := 0;
      result.DisplayBase := 2;
      end
    else
      result := ConvertStringToNumber(NegativeSign + Copy(aString,3), 2);
    exit;
    end;
  if Pos('0x',aString) = 1 then // C style hex
    begin
    if Length(aString) = 2 then
      begin
      result := 0;
      result.DisplayBase := 16;
      end
    else
      result := ConvertStringToNumber(NegativeSign + Copy(aString,3), 16);
    exit;
    end;
  if aString[1] = '0' then // C style octal
    begin
    if Length(aString) = 1 then
      begin
      result := 0;
      result.DisplayBase := 8;
      end
    else
      result := ConvertStringToNumber(NegativeSign + Copy(aString,2), 8);
    exit;
    end;
  if aString[1] = '$' then // Pascal style hex
    begin
    if Length(aString) = 1 then
      begin
      result := 0;
      result.DisplayBase := 16;
      end
    else
      result := ConvertStringToNumber(NegativeSign + Copy(aString,2), 16);
    exit;
    end;
  if aString[1] = '&' then // Pascal style octal
    begin
    if Length(aString) = 1 then
      begin
      result := 0;
      result.DisplayBase := 8;
      end
    else
      result := ConvertStringToNumber(NegativeSign + Copy(aString,2), 8);
    exit;
    end;
  if aString[1] = '%' then // Pascal style binary
    begin
    if Length(aString) = 1 then
      begin
      result := 0;
      result.DisplayBase := 2;
      end
    else
      result := ConvertStringToNumber(NegativeSign + Copy(aString,2), 2);
    exit;
    end;
  if lowercase(aString[length(aString)]) = 'h' then // Yet another hex
    begin
    if Length(aString) = 1 then
      begin
      result := 0;
      result.DisplayBase := 16;
      end
    else
      result := ConvertStringToNumber(NegativeSign + Copy(aString,1,length(aString)-1), 16);
    exit;
    end;
  if lowercase(aString[1]) = 'o' then // Yet another octal
    begin
    if Length(aString) = 1 then
      begin
      result := 0;
      result.DisplayBase := 8;
      end
    else
      result := ConvertStringToNumber(NegativeSign + Copy(aString,2), 8);
    exit;
    end;
  if lowercase(aString[length(aString)]) = 'o' then // Yet another octal
    begin
    if Length(aString) = 1 then
      begin
      result := 0;
      result.DisplayBase := 8;
      end
    else
      result := ConvertStringToNumber(NegativeSign + Copy(aString,1,length(aString)-1), 8);
    exit;
    end;
  SeparatorPosition := Pos('~',aString); // Any base
  if SeparatorPosition = 0 then
    SeparatorPosition := Pos('(',aString); // Another any base
  if SeparatorPosition > 0 then
    begin
    Base := StrToInt(Copy(aString,SeparatorPosition+1));
    if (Base>1) and (Base<=16) then
      result := ConvertStringToNumber(NegativeSign + copy(aString,1,SeparatorPosition-1), Base)
    else
      result := 0;
    exit;
    end;
  result :=  ConvertStringToNumber(NegativeSign + aString, LongMathDefaultDisplayBase);
  end;
function ConvertBinStringToNumber(aString : string ) : tLongNumber;
  begin
  result := ConvertStringToNumber(aString, 2);
  end;
function ConvertOctStringToNumber(aString : string ) : tLongNumber;
  begin
  result := ConvertStringToNumber(aString, 8);
  end;
function ConvertDecStringToNumber(aString : string ) : tLongNumber;
  begin
  result := ConvertStringToNumber(aString, 10);
  end;
function ConvertHexStringToNumber(aString : string ) : tLongNumber;
  begin
  result := ConvertStringToNumber(aString, 16);
  end;
function ConvertNumberToString(aNumber : tLongNumber; aBase : tLongMathDisplayBase) : string;
  var
    Base : tLongNumber;
    Modulo : tLongNumber;
    NegativeSign : string = '';
  begin
  {$ifdef AVOIDHINTANDWARNING}
    Modulo := 0;
  {$endif}
  Error(lmOK);
  if aNumber.SignificantBits = 0 then
    begin
    result:='0';
    exit;
    end;
  if not aNumber.IsPositive then
    begin
    NegativeSign := '-';
    aNumber.IsPositive := true;
    end;
  result := '';
  Base := aBase;
  while aNumber.SignificantBits > 0 do
    begin
    Divide(aNumber, Base, aNumber, Modulo);
    if Modulo.SignificantBits = 0 then
      result := '0' + result
    else if Modulo.Value[0] < 10 then
      result := chr(ord('0') + Modulo.Value[0]) + result
    else
      result := chr(ord('A') + Modulo.Value[0] - 10) + result;
    end;
  result := NegativeSign + result;
  end;
function ConvertNumberToString(const aNumber : tLongNumber) : string;
  begin
  result := ConvertNumberToString(aNumber, aNumber.DisplayBase);
  end;
function ConvertNumberToBinString(const aNumber : tLongNumber) : string;
  begin
  result := ConvertNumberToString(aNumber, 2);
  end;
function ConvertNumberToOctString(const aNumber : tLongNumber) : string;
  begin
  result := ConvertNumberToString(aNumber, 8);
  end;
function ConvertNumberToDecString(const aNumber : tLongNumber) : string;
  begin
  result := ConvertNumberToString(aNumber, 10);
  end;
function ConvertNumberToHexString(const aNumber : tLongNumber) : string;
  begin
  result := ConvertNumberToString(aNumber, 16);
  end;
operator := (const aString : string ) : tLongNumber;
  begin
  result := ConvertStringToNumber(aString);
  end;
operator := (const aNumber : tLongNumber) : string;
  begin
  result := ConvertNumberToString(aNumber);
  end;

function ConvertExtendedToNumber(aNumber : extended) : tLongNumber;
  var
    Sign : boolean = true;
    Exp : int32;
    Temp : int64;
    ExpNumber : tLongNumber;
  begin
  if aNumber = 0 then
    begin
    result := 0;
    exit;
    end;
  {$ifdef AVOIDHINTANDWARNING}
    Exp := 0;
  {$endif}
  Frexp(aNumber, aNumber, Exp);
  if aNumber < 0 then
    begin
    Sign := false;
    aNumber := -aNumber;
    end;
  aNumber := aNumber * $8000000000000000;
  Temp := round(aNumber);
  result := Temp;
  Exp := Exp - 63;
  if Exp > 0 then
    begin
    ExpNumber := Exponent(2, Exp);
    result := Product(result, ExpNumber);
    end
  else if Exp < 0 then
    begin
    Exp := -Exp;
    ExpNumber := Exponent(2, Exp);
    result := Quotient(result, ExpNumber);
    end;
  result.IsPositive := Sign;
  end;
function ConvertNumberToExtended(const aNumber : tLongNumber) : extended;
  var
    Temp : uint64;
    Index : int64;
  begin
  Error(lmOK);
  result := 0;
  if aNumber.SignificantBits = 0 then
    begin
    exit;
    end;
  Index := pred(length(aNumber.Value));
  Temp := aNumber.Value[Index];
  Temp := DigitBase * Temp;
  dec(Index);
  if Index >= 0 then
    Temp := Temp + aNumber.Value[Index];
  result := Temp;
  result := result * Power(DigitBase, Index);
  if not aNumber.IsPositive then
    result := -result;;
  end;
operator := (const aNumber : extended) : tLongNumber;
  begin
  result := ConvertExtendedToNumber(aNumber);
  end;
operator := (const aNumber : tLongNumber) : extended;
  begin
  result := ConvertNumberToExtended(aNumber);
  end;

function Lesser(aNumber1, aNumber2 : tLongNumber) : boolean;
  var
   i : int64;
  begin
  result:=false;
  if not aNumber1.IsPositive and aNumber2.IsPositive then
    begin
    result:=true;
    exit;
    end;
  if aNumber1.IsPositive and not aNumber2.IsPositive then
    exit;
  if not aNumber1.IsPositive and not aNumber2.IsPositive then
    begin
    aNumber1.IsPositive := true;
    aNumber2.IsPositive := true;
    result := Lesser(aNumber2, aNumber1);
    exit;
    end;
  if aNumber1.SignificantBits<aNumber2.SignificantBits then
    begin
    result:=true;
    exit;
    end;
  if aNumber1.SignificantBits>aNumber2.SignificantBits then
    exit;
  if aNumber1.SignificantBits = 0 then
    exit;
  i := pred(length(aNumber1.Value));
  repeat
    if aNumber1.Value[i] < aNumber2.Value[i] then
      begin
      result:=true;
      exit;
      end;
    if aNumber1.Value[i] > aNumber2.Value [i] then
      exit;
    dec(i);
    until i < 0;
  end;
function Greater(const aNumber1, aNumber2 : tLongNumber) : boolean;
  begin
  result := Lesser(aNumber2, aNumber1);
  end;
function LesserEqual(const aNumber1, aNumber2 : tLongNumber) : boolean;
  begin
  result := not Lesser(aNumber2, aNumber1);
  end;
function GreaterEqual(const aNumber1, aNumber2 : tLongNumber) : boolean;
  begin
  result := not Lesser(aNumber1, aNumber2);
  end;
function Equal(const aNumber1, aNumber2 : tLongNumber) : boolean;
  begin
  if (aNumber1.SignificantBits <> aNumber2.SignificantBits) or
     (aNumber1.IsPositive <> anumber2.IsPositive) then // a fast and easy check
    result := false
  else
    result := (not Lesser(aNumber1, aNumber2)) and
              (not Lesser(aNumber2, aNumber1));
  end;
operator < (const aNumber1, aNumber2 : tLongNumber) : boolean;
  begin
  result := Lesser(aNumber1, aNumber2);
  end;
operator > (const aNumber1, aNumber2 : tLongNumber) : boolean;
  begin
  result := Greater(aNumber1, aNumber2);
  end;
operator <= (const aNumber1, aNumber2 : tLongNumber) : boolean;
  begin
  result := LesserEqual(aNumber1, aNumber2);
  end;
operator >=    (const aNumber1, aNumber2 : tLongNumber) : boolean;
  begin
  result := GreaterEqual(aNumber1, aNumber2);
  end;
operator =     (const aNumber1, aNumber2 : tLongNumber) : boolean;
  begin
  result := Equal(aNumber1, aNumber2);
  end;

function SumGeneric(aTerm1, aTerm2 : tLongNumber; aUseModulus : boolean ; const aModulus : tLongNumber) : tLongNumber;
  var
    ResultMaxDigits, i : uint32;
    Carried : uint32;
    Temp : uint64;
  begin
  result := 0;
  result.DisplayBase := aTerm1.DisplayBase;
  if aUseModulus Then
    begin
    aTerm1 := Remainder(aTerm1, aModulus);
    aTerm2 := Remainder(aTerm2, aModulus);
    end;
  if (aTerm1.SignificantBits = 0) and
     (aTerm2.SignificantBits = 0) then
    exit;
  if aTerm1.SignificantBits = 0 then
    begin
    result := aTerm2;
    result.DisplayBase := aTerm1.DisplayBase;
    exit;
    end;
  if aTerm2.SignificantBits = 0 then
    begin
    result := aTerm1;
    exit;
    end;
  if not aTerm1.IsPositive and not aTerm2.IsPositive then
    begin
    aTerm1.IsPositive := true;
    aTerm2.IsPositive := true;
    result := SumGeneric(aTerm1, aTerm2, False, 0);
    result.IsPositive := false;
    if aUseModulus Then
      result := Remainder(result, aModulus);
    exit;
    end;
  if aTerm1.IsPositive and not aTerm2.IsPositive then
    begin
    aTerm2.IsPositive := true;
    result := Difference(aTerm1, aTerm2);
    if aUseModulus Then
      result := Remainder(result, aModulus);
    exit;
    end;
  if not aTerm1.IsPositive and aTerm2.IsPositive then
    begin
    aTerm1.IsPositive := true;
    result := Difference(aTerm2, aTerm1);
    result.DisplayBase := aTerm1.DisplayBase;
    if aUseModulus Then
      result := Remainder(result, aModulus);
    exit;
    end;
  // at this point, two positive numbers are added up always
  if aTerm1.SignificantBits > aTerm2.SignificantBits then
    ResultMaxDigits := aTerm1.SignificantBits div DigitBits // this is a zero based index
  else
    ResultMaxDigits := aTerm2.SignificantBits div DigitBits;
  with result do
    begin
    IsPositive := true;
    DisplayBase := aTerm1.DisplayBase;
    SetLength(Value, ResultMaxDigits + 1);
    // SignificantBits is set in Clean
    end;
  Carried := 0;
  for i := 0 to ResultMaxDigits do
    begin
    Temp := uint64(Carried) + ValueDigit(aTerm1,i) + ValueDigit(aTerm2,i);
    result.Value[i] := Temp mod DigitBase;
    Carried := Temp div DigitBase;
    end;
  Clean(result);
  if aUseModulus Then
    result := Remainder(result, aModulus);
  end;
function Sum(const aTerm1, aTerm2 : tLongNumber) : tLongNumber;
  begin
  Error(lmOK);
  result := SumGeneric(aTerm1, aTerm2, False, 0);
  end;
function Sum(const aTerm1, aTerm2, aModulus : tLongNumber) : tLongNumber;
  begin
  Error(lmOK);
  result := SumGeneric(aTerm1, aTerm2, True, aModulus);
  end;
operator + (const aTerm1, aTerm2 : tLongNumber) : tLongNumber;
  begin
  result := Sum(aTerm1, aTerm2);
  end;

function ProductGeneric(aFactor1, aFactor2 : tLongNumber; aUseModulus : boolean; const aModulus : tLongNumber) : tLongNumber;
  var
    ResultMaxDigits, i, j : uint32;
    Carried : uint32;
    Temp : uint64;
    TempNumber : tLongNumber;
  begin
  result := 0;
  result.DisplayBase := aFactor1.DisplayBase;
  if aUseModulus Then
    begin
    aFactor1 := Remainder(aFactor1, aModulus);
    aFactor2 := Remainder(aFactor2, aModulus);
    end;
  if (aFactor1.SignificantBits = 0) or
     (aFactor2.SignificantBits = 0) then
    exit;
  if aFactor1.SignificantBits = 1 then
    begin
    result := aFactor2;
    result.DisplayBase := aFactor1.DisplayBase;
    if not aFactor1.IsPositive then
      result.IsPositive := not result.IsPositive;
    exit;
    end;
  if aFactor2.SignificantBits = 1 then
    begin
    result := aFactor1;
    if not aFactor2.IsPositive then
      result.IsPositive := not result.IsPositive;
    exit;
    end;
  if aFactor1.IsPositive xor aFactor2.IsPositive then
    begin
    aFactor1.IsPositive := true;
    aFactor2.IsPositive := true;
    result := ProductGeneric(aFactor1, aFactor2, aUseModulus, aModulus);
    result.IsPositive := false;
    if aUseModulus Then
      result := Remainder(result, aModulus);
    exit;
    end;
  // at this point, two positive numbers are mulitplied always
  ResultMaxDigits := ((aFactor1.SignificantBits + DigitBits - 1) div DigitBits) +
                     ((aFactor2.SignificantBits + DigitBits - 1) div DigitBits) -1; // -1 makes it an index not a size
  for i := 0 to length(aFactor1.Value) - 1 do
    begin
    Carried := 0;
    TempNumber := 0;
    SetLength(TempNumber.Value, ResultMaxDigits + 1);
    for j := 0 to length(aFactor2.Value) do // intentionally longer to handle the carry
      begin
      Temp := uint64(ValueDigit(aFactor1,i)) * ValueDigit(aFactor2,j) + Carried;
      TempNumber.Value[i + j] := Temp mod DigitBase;
      Carried := Temp div DigitBase;
      end;
    Clean(TempNumber);
    result := SumGeneric(result, TempNumber, aUseModulus, aModulus);
    end;
  end;
function Product(const aFactor1, aFactor2 : tLongNumber) : tLongNumber;
  begin
  Error(lmOK);
  result := ProductGeneric(aFactor1, aFactor2, False, 0);
  end;
function Product(const aFactor1, aFactor2, aModulus : tLongNumber) : tLongNumber;
  begin
  Error(lmOK);
  result := ProductGeneric(aFactor1, aFactor2, True, aModulus);
  end;
operator * (const aFactor1, aFactor2 : tLongNumber) : tLongNumber;
  begin
  result := Product(aFactor1, aFactor2);
  end;

function ExponentGeneric(aBase, aExponent : tLongNumber; aUseModulus : boolean; const aModulus : tLongNumber) : tLongNumber;
  var
    i : uint32;
    ResultSign : boolean = true;
  begin
  if aUseModulus Then
    aBase := Remainder(aBase, aModulus);
  result := 0;
  result.DisplayBase := aBase.DisplayBase;
  if aBase.SignificantBits = 0 then
    exit;
  if not aExponent.IsPositive then
    exit; // on integers a negative exponent gives less than 1 (or more than -1)
  result := 1;
  result.DisplayBase := aBase.DisplayBase;
  if aExponent.SignificantBits = 0 then
    exit;
  if not aBase.IsPositive then // can happen only when not aUseModulus
    begin
    aBase.IsPositive := true;
    ResultSign := (aExponent.Value[0] mod 2 = 0);
    end;
  for i:= 0 to aExponent.SignificantBits - 1 do
    begin
    if ValueBit(aExponent,i) then
      result := ProductGeneric(result, aBase, aUseModulus, aModulus);
    if i < aExponent.SignificantBits - 1 then // to avoid the last unnecessary step
      aBase := ProductGeneric(aBase, aBase, aUseModulus, aModulus);
    end;
  result.IsPositive := ResultSign;
  end;
function Exponent(const aBase, aExponent : tLongNumber) : tLongNumber;
  begin
  Error(lmOK);
  result := ExponentGeneric(aBase, aExponent, false, 0);
  end;
function Exponent(const aBase, aExponent, aModulus : tLongNumber) : tLongNumber;
  begin
  Error(lmOK);
  result := ExponentGeneric(aBase, aExponent, true, aModulus);
  end;
operator ** (const aBase, aExponent : tLongNumber) : tLongNumber;
  begin
  result := Exponent(aBase, aExponent);
  end;

function Difference(aMinuend, aSubtrahend : tLongNumber) : tLongNumber;
  var
    i : uint32;
    Temp, Carried : uint64;
  begin
  Error(lmOK);
  result := 0;
  result.DisplayBase := aMinuend.DisplayBase;
  if (aMinuend.SignificantBits = 0) and
     (aSubtrahend.SignificantBits = 0) then
    exit;
  if aMinuend = aSubtrahend then
    exit;
  if aMinuend.SignificantBits = 0 then
    begin
    result := aSubtrahend;
    result.DisplayBase := aMinuend.DisplayBase;
    result.IsPositive := not result.IsPositive;
    exit;
    end;
  if aSubtrahend.SignificantBits = 0 then
    begin
    result := aMinuend;
    exit;
    end;
  if not aMinuend.IsPositive and not aSubtrahend.IsPositive then
    begin
    aMinuend.IsPositive := true;
    aSubtrahend.IsPositive := true;
    result := Difference(aSubtrahend, aMinuend);
    result.DisplayBase := aMinuend.DisplayBase;
    exit;
    end;
  if aMinuend.IsPositive and not aSubtrahend.IsPositive then
    begin
    aSubtrahend.IsPositive := true;
    result := Sum(aMinuend, aSubtrahend);
    exit;
    end;
  if not aMinuend.IsPositive and aSubtrahend.IsPositive then
    begin
    aMinuend.IsPositive := true;
    result := Sum(aMinuend, aSubtrahend);
    result.IsPositive := false;
    exit;
    end;
  if aMinuend < aSubtrahend then
    begin
    result := Difference(aSubtrahend, aMinuend);
    result.DisplayBase := aMinuend.DisplayBase;
    result.IsPositive := false;
    exit;
    end;
  Carried:=1;
  result := 0;
  result.DisplayBase := aMinuend.DisplayBase;
  SetLength(result.Value,length(aMinuend.Value));
  for i:= 0 to length(aMinuend.Value) - 1 do
    begin
    Temp := DigitBase + ValueDigit(aMinuend,i) - ValueDigit(aSubtrahend,i) + Carried -1;
    result.Value[i] := Temp mod DigitBase;
    Carried := Temp div DigitBase;
    end;
  Clean(result);
  end;
operator - (const aMinuend, aSubtrahend : tLongNumber) : tLongNumber;
  begin
  result := Difference(aMinuend, aSubtrahend);
  end;

procedure Divide  (aDividend, aDivisor : tLongNumber; var aQuotient, aRemainder : tLongNumber);
  var
    ResultSign, DividendSign : boolean;
    Temp : tLongNumber;
    Dividend, Divisor :uint64;
    Magnitude : int64;
  begin
  Error(lmOK);
  if aDividend.SignificantBits = 0 then
    begin
    aQuotient := 0;
    aQuotient.DisplayBase := aDividend.DisplayBase;
    aRemainder := 0;
    aRemainder.DisplayBase := aDividend.DisplayBase;
    exit;
    end;
  if aDivisor.SignificantBits = 0 then
    begin
    aQuotient := 0;
    aQuotient.DisplayBase := aDividend.DisplayBase;
    aRemainder := 0;
    aRemainder.DisplayBase := aDividend.DisplayBase;
    Error(lmDivisionByZero);
    exit;
    end;
  if aDivisor.SignificantBits = 1 then
    begin
    aQuotient := aDividend;
    if not aDivisor.IsPositive then
      aQuotient.IsPositive := not aQuotient.IsPositive;
    aRemainder := 0;
    aRemainder.DisplayBase := aDividend.DisplayBase;
    exit;
    end;
  if aDividend.SignificantBits < aDivisor.SignificantBits then
    begin
    aQuotient := 0;
    aQuotient.DisplayBase := aDividend.DisplayBase;
    aRemainder := aDividend;
    exit;
    end;
  if aDividend = aDivisor then
    begin
    aQuotient := 1;
    aQuotient.DisplayBase := aDividend.DisplayBase;
    aRemainder := 0;
    aRemainder.DisplayBase := aDividend.DisplayBase;
    exit;
    end;
  ResultSign := not (aDividend.IsPositive xor aDivisor.IsPositive);
  DividendSign := aDividend.IsPositive;
  aDividend.IsPositive := true;
  aDivisor.IsPositive := true;
  aQuotient := 0;
  aQuotient.DisplayBase := aDividend.DisplayBase;
  repeat
    Dividend := ValueDigit(aDividend, length(aDividend.Value) - 1);
    Divisor := ValueDigit(aDivisor,  length(aDivisor.Value ) - 1);
    Magnitude := length(aDividend.Value) - length(aDivisor.Value);
    Temp := 0;
    if (Dividend <= Divisor) and (Magnitude > 0) then
      begin
      Dividend := DigitBase * Dividend + ValueDigit(aDividend, length(aDividend.Value) - 2);
      Magnitude := Magnitude - 1;
      SetLength(Temp.Value, Magnitude + 1);
      Temp.Value[Magnitude] := Dividend div (Divisor + 1);
      end
    else if Dividend = Divisor then
      begin
      Temp := 1;
      end
    else
      begin
      SetLength(Temp.Value, Magnitude + 1);
      if length(aDividend.Value) = 1 then
        Temp.Value[Magnitude] := Dividend div Divisor
      else
        Temp.Value[Magnitude] := Dividend div (Divisor + 1);
      end;
    Clean(Temp);
    aQuotient := aQuotient + Temp;
    Temp := aDivisor * Temp;
    aDividend := aDividend - Temp;
    until aDividend < aDivisor;
  aQuotient.IsPositive := ResultSign;
  aRemainder := aDividend;
  aRemainder.IsPositive := DividendSign;
  end;
function Quotient (const aDividend, aDivisor : tLongNumber) : tLongNumber;
  var
    Dummy : tLongNumber;
  begin
  {$ifdef AVOIDHINTANDWARNING}
    result := 0;
    Dummy := 0;
  {$endif}
  Divide(aDividend, aDivisor, result, Dummy);
  end;
function Remainder(const aDividend, aDivisor : tLongNumber) : tLongNumber;
  var
    Dummy : tLongNumber;
  begin
  {$ifdef AVOIDHINTANDWARNING}
    result := 0;
    Dummy := 0;
  {$endif}
  Divide(aDividend, aDivisor, Dummy, result);
  end;
function Fraction (const aDividend, aDivisor : tLongNumber) : Extended;
  var
    Temp : uint64;
  begin
  Error(lmOK);
  result := 0;
  if aDividend.SignificantBits = 0 then
    begin
    exit;
    end;
  if aDivisor.SignificantBits = 0 then
    begin
    Error(lmDivisionByZero);
    exit;
    end;
  Temp := aDividend.Value[pred(length(aDividend.Value))];
  Temp := DigitBase * Temp;
  if length(aDividend.Value) > 1 then
    Temp := Temp + aDividend.Value[length(aDividend.Value) - 2];
  result := Temp;
  if aDivisor.SignificantBits = 1 then
    begin
    result := result * Power(DigitBase, (length(aDividend.Value) - 2));
    exit;
    end;
  Temp := aDivisor.Value[pred(length(aDivisor.Value))];
  Temp := DigitBase * Temp;
  if length(aDivisor.Value) > 1 then
    Temp := Temp + aDivisor.Value[length(aDivisor.Value) - 2];
  result := result / Temp;
  result := result * Power(DigitBase, (length(aDividend.Value) - length(aDivisor.Value)));
  if aDividend.IsPositive xor aDivisor.IsPositive then
    result := -result;
  end;
operator div (const aDividend, aDivisor : tLongNumber) : tLongNumber;
  begin
  result := Quotient(aDividend, aDivisor);
  end;
operator mod (const aDividend, aDivisor : tLongNumber) : tLongNumber;
  begin
  result := Remainder(aDividend, aDivisor);
  end;
operator / (const aDividend, aDivisor : tLongNumber) : Extended;
  begin
  result := Fraction(aDividend, aDivisor);
  end;

function Even(const aNumber : tLongNumber) : boolean;
  begin
  result := (aNumber.SignificantBits = 0) or
            (aNumber.Value[0] mod 2 = 0);
  end;
function Odd (const aNumber : tLongNumber) : boolean;
  begin
  result := not Even(aNumber);
  end;

function Fermat2Test(const aNumber : tLongNumber) : boolean;
  var
    Two : tLongNumber;
    Temp : uint32;
  begin
  result := false;
  if aNumber.SignificantBits = 0 then
    exit;
  if not aNumber.IsPositive then
    exit;
  if (aNumber.SignificantBits <= 5) and (aNumber < 24) then
    begin
    Temp := aNumber;
    result := // 1 is not considered
      (Temp = 2) or
      (Temp = 3) or
      (Temp = 5) or
      (Temp = 7) or
      (Temp = 11) or
      (Temp = 13) or
      (Temp = 17) or
      (Temp = 19) or
      (Temp = 23);
    exit;
    end;
  Temp := 223092870; // 2*3*5*7*11*13*17*19*23
  Temp := aNumber mod Temp;
  if ((Temp mod 2)=0) or
     ((Temp mod 3)=0) or
     ((Temp mod 5)=0) or
     ((Temp mod 7)=0) or
     ((Temp mod 11)=0) or
     ((Temp mod 13)=0) or
     ((Temp mod 17)=0) or
     ((Temp mod 19)=0) or
     ((Temp mod 23)=0) then
    exit;
  Two := 2;
  if Exponent(Two,aNumber,aNumber) = Two then
    result := true;
  end;
function NextFermat2Number(const aNumber : tLongNumber) : tLongNumber;
  var
    Two : tLongNumber;
  begin
  result := aNumber;
  Two := 2;
  if Odd(result) then
    result := result + Two
  else
    result := result + 1;
  while not Fermat2Test(result) do
    result := result + Two;
  end;

function RandomNumber(aLength : uint32) : tLongNumber;
  var
    i : int64;
  begin
  result := 0;
  if aLength = 0 then
    exit;
  SetLength(result.Value, (aLength + DigitBits -1) div DigitBits);
  for i := 0 to length(result.Value) - 2 do
    result.Value[i] := random(DigitBase);
  aLength := (aLength - 1) mod DigitBits + 1;
  i := 2 ** aLength;
  result.Value[pred(length(result.Value))] := random(i);
  Clean(result);
  end;

begin
Randomize;
end.






