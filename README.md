# longmathforpascal
Pascal unit to declare and manipulate very large integer numbers with some limited floating support
  Description

  Operators or functions
    For most operations there are two approaches:
      A function: Number1:= Multiply(Number2, Number3);      
      An operator overload: Number1 := Number2 * Number3;      

  Error reporting
    If an error occurs then an Exception is raised (unless switched off)
    The return code of the operation is always set in LongMathReturnCode
      Warning : for multiple operations the error code is set to the last operation. If there is no exception used, this can be
        misleading:
        Number1 := Multiply(Number2, 'zzz'); is OK, because the Number := 'zzz' hidden typecast returns an error, but then it is
          overwritten by the Multiply function, what works, hence the final setting is lmOK!
      If in doubt, use two steps:
        Number1 := 'zzz';
        if LongMathReturnCode <> lmOK then
          DoSomething
        else
          Number1 := Multiply(Number2, Number1);

  Assigning values
    There are many ways to assign value to a tLongNumber
      The easiest is to use the := operator
        NumberType := IntegerType; // any integer type from int8 to uint64
        NumberType := StringType;
          Number := '100';       // 100 in base 10 (if the LongMathDefaultDisplayBase is not something else)
          Number := '%1100100';  // 100 in base 2 Pascal style
          Number := '0b1100100'; // 100 in base 2 C style
          Number := '&144';      // 100 in base 8 Pascal style
          Number := '0144';      // 100 in base 8 C style
          Number := 'o144';      // 100 in base 8 other version
          Number := 'O144';      // 100 in base 8 other version
          Number := '144o';      // 100 in base 8 other version
          Number := '144O';      // 100 in base 8 other version
          Number := '$64';       // 100 in base 16 Pascal style
          Number := 'Ox64';      // 100 in base 16 C style
          Number := '64h';       // 100 in base 16 other version
          Number := '64H';       // 100 in base 16 other version
          Number := '91~9';      // 100 in base 9  or other base 2..16 can be used after the '~'
          Number := '79(13';     // 100 in base 13 or other base 2..16 can be used after the '('
        Negative numbers can have the minus sign in the first position or after the leading base specifier
          Number := '-$64';      // -100 in base 16 with minus before the base prefix (any other prefix can work the same)
          Number := '0-144       // -100 in base 8 with minus after the base prefix (any other prefix can work the same)
          Number := '-202(7'     // -100 in base 7 with minus at the first position with base postfix (any base, any postfix)
        NumberType := FloatingType; // any floating type; might have rounding errors
          Number := -123.45E6;   // -123450000 using an explicit number rather than a floating type variable
      Or a conversion function
        NumberType := ConvertIntegerToNumber(); // any integer type
        Various string conversion functions
          Number := ConvertStringToNumber('400',5);      // 100 in base 5
          Number := ConvertStringToNumber('100');        // 100 in base 10 (if the LongMathDefaultDisplayBase is 10)
          Number := ConvertStringToNumber('$-64');       // -100 in base 16 (any format used in := can also be used here)
          Number := ConvertBinStringToNumber('1100100'); // 100 in base 2
          Number := ConvertOctStringToNumber('144');     // 100 in base 8
          Number := ConvertDecStringToNumber('100');     // 100 in base 10
          Number := ConvertHexStringToNumber('64');      // 100 in base 16
        NumberType := ConvertExtendedToNumber(); // any floating type
  Returning values
    The other direction is easier
      Here also an operator can be used
        IntegerType  := NumberType; // returns the value in the given integer type (if does not fit an error is reported)
        StringType   := NumberType; // returns the string in the display base of MyNumber
        ExtendedType := NumberType; // only "extended" is implemented, other floating types not!
      Or an explicit function
        IntegerType  := ConvertNumberToInteger(Number);     // all integer types are implemented
        StringType   := ConvertNumberToString(Number,Base); // any base 2..16
        StringType   := ConvertNumberToString(Number);      // in the display base of Number
        StringType   := ConvertNumberToBinString(Number);   // base 2
        StringType   := ConvertNumberToOctString;           // base 8
        StringType   := ConvertNumberToDecString;           // base 10
        StringType   := ConvertNumberToHexString;           // base 16
        ExtendedType := ConvertNumberToExtended;            // only "extended" is implemented

  Display base
    For every internally stored tLongNumber variable has a "display base", i.e. the default base to use when converted to a string
    The display base of a number can origin from three places:
      If a NumberType := (IntegerType | FloatingType) assignment is made, it is the DefaultDisplayBase (10,
        but can be overwritten for the whole program
      If it is assigned from a string through an operator or function from a string, it is the base used in the string formatting
      If it is assigned through a LongMath operator or function then it inherites it from the first operand. Be careful, it can
        cause strange results:
          L1 := '$64';  // 100 in base 16
          L2 := '144o'; // 100 in base 8
          L3 := L1 + L2;
          L4 := L2 + L1;
          S := L3;      // S = 'C8', i.e. 200 in base 16 (inherited from L1)
          S := L4;      // S = '310', i.e. 200 in base 8 (inherited from L2)
        hence it is not recommended to mix display bases within one program!

  Number range
    Theoretically there is no limit. It depends on the available memory, but typically speed is more limiting than space
    Be especially careful when using Exponent or ** as the number can be very large quick.
    Most of the large number calculations can be simplified using a Modulus circle.

  Modulo with negative numbers
    It follows the same logic, what is used in Pascal, i.e.
       5 div -3 = -1 and  5 mod -3 =  2
      -5 div  3 = -1 and -5 mod  3 = -2
      -5 div -3 =  1 and -5 mod -3 = -2
    and NOT the way I would find more "logical", i.e. the modulo is always positive
       5 div -3 = -1 and  5 mod -3 =  2
      -5 div  3 = -2 and -5 mod  3 =  1
      -5 div -3 =  2 and -5 mod -3 =  1
    and NOT the other "logical" way where the sign of the modulo equals to the sign of the Divisor
       5 div -3 = -2 and  5 mod -3 = -1
      -5 div  3 = -1 and -5 mod  3 = -2
      -5 div -3 =  1 and -5 mod -3 = -2

  Usage
    Read the interface section. Most functions and operators are self explanatory.
    Check some examples in the program example.pas.

