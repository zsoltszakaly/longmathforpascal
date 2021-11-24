program longmathdemo;

//**********************************************************************************************************************************
//
//  Pascal program to show some of the capabilities of the LongMath unit
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
//    Some of the functionality of LongMath is demonstrated through simple examples and a more complex Collatz run
//
//  Usage
//    Simply run the program and check the source code.
//
//**********************************************************************************************************************************

uses
  sysutils, // only need to ba able to use 'Now'
  longmath; // the LongMath unit

procedure Collatz;
  var
    One, Two, Three, N : tLongNumber;
    DT : tDateTime;
    Count : int32;
  begin
  One := 1;
  Two := '2';
  Three := ConvertBinStringToNumber('11');
  Count := 0;
  DT := Now;
  N := RandomNumber(500);
  while N > One do
    begin
    if Odd(N) then
      N := N * Three + One;
    N := N div Two;
    inc(Count);
    writeln(Count,' ',string(N));
     end;
  Dt := Now - Dt;
  writeln('Finished in ',Count,' steps in ',DT * 86400 : 4: 2,' seconds');
  writeln('Most of the time is the conversion back to string and showing it. Commenting line 52 would make it much faster!');
  writeln;
  end;

var
  Num1, Num2 ,Num3, Num4 : tLongNumber;
  Str1, Str2 : string;
  Dou1 : double;
  Ext1, Ext2 : extended;

begin
writeln('Some basic input and output:');
writeln;

writeln('Num1 and Num2 are both in base 10. Result Num3 is the sum of the two.');
Num1 := 12345; // base 10
Num2 := $ABCD; // Still recorded as base 10, as it is an integer assignment
writeln('Num1 ',string(Num1)); // typecase
writeln('Num2 ',ConvertNumberToString(Num2)); // same with conversion function
Num3 := Num1 + Num2; // Inherits base 10 from Num1
Str1 := Num3; // Number to String assignment
writeln('Num1 + Num2 ',Str1);
Num3 := Num2 + Num1; // Inherits base 10 from Num2
Str1 := Num3; // Number to String assignment
writeln('Num2 + Num1 ',Str1);
writeln;

writeln('Num1 in base 2, Num2 in base 8. Result Num3 is the product of the two.');
Num1 := '%1111'; // 15 in base 2
Num2 := ConvertOctStringToNumber('100'); // 64 in base 8
writeln('Num1 ',string(Num1)); // typecase
writeln('Num2 ',ConvertNumberToString(Num2)); // same with conversion function
Num3 := Num1 * Num2; // 960. Num3 inherits base 2 as display format from Num1
Str1 := Num3; // Number to String assignment
writeln('Num1 * Num2 ',Str1);
Num3 := Num2 * Num1; // Inherits base 8 from Num2
Str1 := Num3; // Number to String assignment
writeln('Num2 * Num1 ',Str1);
Str2 := ConvertNumberToDecString(Num3); // forced to base 10
writeln('Num1 in base 10 ',ConvertNumberToString(Num1,10)); // using the generic conversion function with a specified base
writeln('Num2 in base 10 ',ConvertNumberToDecString(Num2)); // using the decimal conversion function
writeln('Num3 in base 10 ',Str2);
writeln;

writeln('Num1 in base 7 small negative, Num2 in base 3 large negative. Result Num3 is the difference of the two.');
Num1 := '-1234~7'; // using the ~ as the postfix separator
Num2 := '-555555(6'; // using the ( as the postfix separator
writeln('Num1 (base 7)',string(Num1)); // typecase
writeln('Num2 (base 6)',ConvertNumberToString(Num2)); // same with conversion function
Num3 := Difference(Num1, Num2); // - operator could also be used like above the + and *
writeln('Num3 = Num1 - Num2 in its base (base 7 inherited from Num 1) ',string(Num3));
writeln('Num1 in base 10 ',ConvertNumberToString(Num1,10)); // using the generic conversion function with a specified base
writeln('Num2 in base 10 ',ConvertNumberToDecString(Num2)); // using the decimal conversion function
writeln('Num3 in base 10 ',ConvertNumberToDecString(Num3)); // using the decimal conversion function
writeln;

writeln('Divide and modulo');
writeln;

writeln('Two large hex numbers divided with remainder');
Num1 := '123456789ABCDEFh';
Num2 := '0x123456789ABCD';
Num4 := 0; // This is only for the compiler to avoid Hint (in the longmath unit there is a switch for this)
Divide(Num1, Num2, Num3, Num4);
writeln('Num1 ',string(Num1));
writeln('Num2 ',string(Num2));
writeln('Quotient  ',string(Num3));
writeln('Remainder ',string(Num4));
writeln;
writeln('And the same with simple operators');
writeln('Quotient  ',string(Num1 div Num2));
writeln('Remainder ',string(Num1 mod Num2));
writeln;

writeln('Some basic float support');
writeln;
writeln('Divide an extended number with a double number and the same through tLargeNumber');
Dou1 := -123.45E2;
Ext1 :=  12345.67E89;
writeln('Dou1 ',Dou1);
writeln('Ext1 ',Ext1);
Ext2 := Ext1 / Dou1;
writeln('Ext2 = Ext1 / Dou1 in normal float operations ',Ext2);
Num1 := ConvertExtendedToNumber(Dou1); // explicit conversion from any float variable
Num2 := Ext1; // assignment from any float variable
Num3 := Num2 div Num1; // integer division
Ext2 := Num2 / Num1; // extended division
writeln('Num1 = Dou1 (all in base 10) ', string(Num1));
writeln('Num2 = Ext1 ', string(Num2));
writeln('Num3 = Num2 div Num1 ', string(Num3));
writeln('Ext2 = Num2 / Num1 ', Ext2);
writeln;

writeln('Some power calculation');
writeln;

writeln('Without modulo');
writeln('3^99');
Num1 := 3; // integer assignment
Num2 := '99'; // string assignment
Num3 := Num1 ** Num2; // power operator
writeln('Num3 ',string(Num3));
writeln;

writeln('With modulo');
writeln('5^393050634124102232869567034555427371542904833 mod 393050634124102232869567034555427371542904833');
writeln('(the number is a Cullen prime)');
Num1 := 5;
Num2 := '393050634124102232869567034555427371542904833';
Num3 := Exponent(Num1,Num2,Num2);
writeln('Num3 ',string(Num3));
writeln;

writeln('The Fermat test for 2 using the same large prime number');
writeln('Fermat2Test result ',Fermat2Test(Num2));
writeln;

writeln('Deducting 10 from the same prime number');
Num1 := 'Ah'; // becomes base 16
Num2 := Num2 - Num1; // not a problem as the result inherits from Num2 (first operand)
writeln('Num2 ',string(Num2));
Num2 := NextFermat2Number(Num2);
writeln('Find next Fermat2Test number (find the prime) ',string(Num2));
writeln('Please note that this is NOT a full primary test and prime finding algoritm, only a potential element!');
writeln;

writeln('Press ENTER for a longer run of the Collatz conjecture');
writeln('Starting from a 500 bit long random number it gets (hopefully) back to 1');
writeln('/ if not, please share the success with me :-) /');
readln;
Collatz;

writeln('And finally press ENTER for an error and potential unhandled Exception with division by zero');
readln;
Num1 := '%1010010101010001010';
Num2 := 'o0'; // zero in base 8
LongMathRaiseException := false; // put it in comment if you want to get an exception
Num3 := Num1 div Num2;
writeln('This point is not reached if line 193 is in comment and an unhandled exception is raised!');
writeln('Return code: ',LongMathReturnCode);

end.

