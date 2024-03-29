/*******************************************************************************

        @file UNumberFormat.d
        
        Copyright (c) 2004 Kris Bell
        
        This software is provided 'as-is', without any express or implied
        warranty. In no event will the authors be held liable for damages
        of any kind arising from the use of this software.
        
        Permission is hereby granted to anyone to use this software for any 
        purpose, including commercial applications, and to alter it and/or 
        redistribute it freely, subject to the following restrictions:
        
        1. The origin of this software must not be misrepresented; you must 
           not claim that you wrote the original software. If you use this 
           software in a product, an acknowledgment within documentation of 
           said product would be appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must 
           not be misrepresented as being the original software.

        3. This notice may not be removed or altered from any distribution
           of the source.

        4. Derivative works are permitted, but they must carry this notice
           in full and credit the original source.


                        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


        @version        Initial version, November 2004      
        @author         Kris

        Note that this package and documentation is built around the ICU 
        project (http://oss.software.ibm.com/icu/). Below is the license 
        statement as specified by that software:


                        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


        ICU License - ICU 1.8.1 and later

        COPYRIGHT AND PERMISSION NOTICE

        Copyright (c) 1995-2003 International Business Machines Corporation and 
        others.

        All rights reserved.

        Permission is hereby granted, free of charge, to any person obtaining a
        copy of this software and associated documentation files (the
        "Software"), to deal in the Software without restriction, including
        without limitation the rights to use, copy, modify, merge, publish,
        distribute, and/or sell copies of the Software, and to permit persons
        to whom the Software is furnished to do so, provided that the above
        copyright notice(s) and this permission notice appear in all copies of
        the Software and that both the above copyright notice(s) and this
        permission notice appear in supporting documentation.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
        OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
        OF THIRD PARTY RIGHTS. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
        HOLDERS INCLUDED IN THIS NOTICE BE LIABLE FOR ANY CLAIM, OR ANY SPECIAL
        INDIRECT OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING
        FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
        NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION
        WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

        Except as contained in this notice, the name of a copyright holder
        shall not be used in advertising or otherwise to promote the sale, use
        or other dealings in this Software without prior written authorization
        of the copyright holder.

        ----------------------------------------------------------------------

        All trademarks and registered trademarks mentioned herein are the 
        property of their respective owners.

*******************************************************************************/

module com.ibm.icu.mangoicu.UNumberFormat;

private import  com.ibm.icu.mangoicu.ICU,
                com.ibm.icu.mangoicu.UString;

public  import com.ibm.icu.mangoicu.ULocale;

/*******************************************************************************

*******************************************************************************/

class UDecimalFormat : UCommonFormat
{
        /***********************************************************************
        
        ***********************************************************************/

        this (ref ULocale locale)
        {
                super (Style.Decimal, null, locale);
        }

        /***********************************************************************
        
                Set the pattern for a UDecimalFormat

        ***********************************************************************/

        void setPattern (UStringView pattern, bool localized)
        {
                UErrorCode e;

                unum_applyPattern (handle, localized, pattern.get.ptr, pattern.length, null, e);        
                testError (e, "failed to set numeric pattern");
        }
}


/*******************************************************************************

*******************************************************************************/

class UCurrencyFormat : UCommonFormat
{
        /***********************************************************************
        
        ***********************************************************************/

        this (ref ULocale locale)
        {
                super (Style.Currency, null, locale);
        }
}


/*******************************************************************************

*******************************************************************************/

class UPercentFormat : UCommonFormat
{
        /***********************************************************************
        
        ***********************************************************************/

        this (ref ULocale locale)
        {
                super (Style.Percent, null, locale);
        }
}


/*******************************************************************************

*******************************************************************************/

class UScientificFormat : UCommonFormat
{
        /***********************************************************************
        
        ***********************************************************************/

        this (ref ULocale locale)
        {
                super (Style.Scientific, null, locale);
        }
}


/*******************************************************************************

*******************************************************************************/

class USpelloutFormat : UCommonFormat
{
        /***********************************************************************
        
        ***********************************************************************/

        this (ref ULocale locale)
        {
                super (Style.Spellout, null, locale);
        }
}


/*******************************************************************************

*******************************************************************************/

class UDurationFormat : UCommonFormat
{
        /***********************************************************************
        
        ***********************************************************************/

        this (ref ULocale locale)
        {
                super (Style.Duration, null, locale);
        }
}


/*******************************************************************************

*******************************************************************************/

class URuleBasedFormat : UNumberFormat
{
        /***********************************************************************
        
        ***********************************************************************/

        this (ref ULocale locale)
        {
                super (Style.RuleBased, null, locale);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void setLenientParse (bool yes)
        {
                unum_setAttribute (handle, Attribute.LenientParse, yes);
        }


        /***********************************************************************
        
        ***********************************************************************/

        bool isLenientParse ()
        {
                return unum_getAttribute (handle, Attribute.LenientParse) != 0;
        }
}


/*******************************************************************************

*******************************************************************************/

private class UCommonFormat : UNumberFormat
{
        /***********************************************************************
        
        ***********************************************************************/

        this (Style style, char[] pattern, ref ULocale locale)
        {
                super (style, pattern, locale);
        }

        /***********************************************************************
        
                Return true if this format will parse numbers as integers 
                only

        ***********************************************************************/

        bool isParseIntegerOnly ()
        {
                return unum_getAttribute (handle, Attribute.ParseIntOnly) != 0;
        } 

        /***********************************************************************
        
                Returns true if grouping is used in this format.

        ***********************************************************************/

        bool isGroupingUsed ()
        {
                return unum_getAttribute (handle, Attribute.GroupingUsed) != 0;
        } 

        /***********************************************************************
        
                Always show decimal point?

        ***********************************************************************/

        bool isDecimalSeparatorAlwaysShown ()
        {
                return unum_getAttribute (handle, Attribute.DecimalAlwaysShown) != 0;
        } 

        /***********************************************************************
        
                Sets whether or not numbers should be parsed as integers 
                only

        ***********************************************************************/

        void setParseIntegerOnly (bool yes)
        {
                unum_setAttribute (handle, Attribute.ParseIntOnly, yes);
        } 

        /***********************************************************************
               
               Set whether or not grouping will be used in this format.

        ***********************************************************************/

        void setGroupingUsed (bool yes)
        {
                unum_setAttribute (handle, Attribute.GroupingUsed, yes);
        } 

        /***********************************************************************

                Always show decimal point.

        ***********************************************************************/

        void setDecimalSeparatorAlwaysShown (bool yes)
        {
                unum_setAttribute (handle, Attribute.DecimalAlwaysShown, yes);
        } 

        /***********************************************************************
        
                Sets the maximum number of digits allowed in the integer 
                portion of a number.

        ***********************************************************************/

        void setMaxIntegerDigits (uint x)
        {
                unum_setAttribute (handle, Attribute.MaxIntegerDigits, x);
        }

        /***********************************************************************
        
                Sets the minimum number of digits allowed in the integer 
                portion of a number.

        ***********************************************************************/

        void setMinIntegerDigits (uint x)
        {
                unum_setAttribute (handle, Attribute.MinIntegerDigits, x);
        }

        /***********************************************************************
        
                Integer digits displayed

        ***********************************************************************/

        void setIntegerDigits (uint x)
        {
                unum_setAttribute (handle, Attribute.IntegerDigits, x);
        }

        /***********************************************************************
        
                Sets the maximum number of digits allowed in the fraction 
                portion of a number.

        ***********************************************************************/

        void setMaxFractionDigits (uint x)
        {
                unum_setAttribute (handle, Attribute.MaxFractionDigits, x);
        }

        /***********************************************************************
        
                Sets the minimum number of digits allowed in the fraction 
                portion of a number.

        ***********************************************************************/

        void setMinFractionDigits (uint x)
        {
                unum_setAttribute (handle, Attribute.MinFractionDigits, x);
        }

        /***********************************************************************
        
                Fraction digits.

        ***********************************************************************/

        void setFractionDigits (uint x)
        {
                unum_setAttribute (handle, Attribute.FractionDigits, x);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void setMultiplier (uint x)
        {
                unum_setAttribute (handle, Attribute.Multiplier, x);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void setGroupingSize (uint x)
        {
                unum_setAttribute (handle, Attribute.GroupingSize, x);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void setRoundingMode (Rounding x)
        {
                unum_setAttribute (handle, Attribute.RoundingMode, x);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void setRoundingIncrement (uint x)
        {
                unum_setAttribute (handle, Attribute.RoundingIncrement, x);
        }

        /***********************************************************************
        
                The width to which the output of format() is padded

        ***********************************************************************/

        void setFormatWidth (uint x)
        {
                unum_setAttribute (handle, Attribute.FormatWidth, x);
        }

        /***********************************************************************
        
                The position at which padding will take place.

        ***********************************************************************/

        void setPaddingPosition (Pad x)
        {
                unum_setAttribute (handle, Attribute.PaddingPosition, x);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void setSecondaryGroupingSize (uint x)
        {
                unum_setAttribute (handle, Attribute.SecondaryGroupingSize, x);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void setSignificantDigitsUsed (uint x)
        {
                unum_setAttribute (handle, Attribute.SignificantDigitsUsed, x);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void setMinSignificantDigits (uint x)
        {
                unum_setAttribute (handle, Attribute.MinSignificantDigits, x);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void setMaxSignificantDigits (uint x)
        {
                unum_setAttribute (handle, Attribute.MaxSignificantDigits, x);
        }


        /***********************************************************************

                Returns the maximum number of digits allowed in the integer 
                portion of a number.
        
        ***********************************************************************/

        uint getMaxIntegerDigits ()
        {
                return unum_getAttribute (handle, Attribute.MaxIntegerDigits);
        }

        /***********************************************************************
                
                Returns the minimum number of digits allowed in the integer 
                portion of a number.

        ***********************************************************************/

        uint getMinIntegerDigits ()
        {
                return unum_getAttribute (handle, Attribute.MinIntegerDigits);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getIntegerDigits ()
        {
                return unum_getAttribute (handle, Attribute.IntegerDigits);
        }

        /***********************************************************************
        
                Returns the maximum number of digits allowed in the fraction 
                portion of a number.

        ***********************************************************************/

        uint getMaxFractionDigits ()
        {
                return unum_getAttribute (handle, Attribute.MaxFractionDigits);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getMinFractionDigits ()
        {
                return unum_getAttribute (handle, Attribute.MinFractionDigits);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getFractionDigits ()
        {
                return unum_getAttribute (handle, Attribute.FractionDigits);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getMultiplier ()
        {
                return unum_getAttribute (handle, Attribute.Multiplier);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getGroupingSize ()
        {
                return unum_getAttribute (handle, Attribute.GroupingSize);
        }

        /***********************************************************************
        
        ***********************************************************************/

        Rounding getRoundingMode ()
        {
                return cast(Rounding) unum_getAttribute (handle, Attribute.RoundingMode);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getRoundingIncrement ()
        {
                return unum_getAttribute (handle, Attribute.RoundingIncrement);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getFormatWidth ()
        {
                return unum_getAttribute (handle, Attribute.FormatWidth);
        }

        /***********************************************************************
        
        ***********************************************************************/

        Pad getPaddingPosition ()
        {
                return cast(Pad) unum_getAttribute (handle, Attribute.PaddingPosition);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getSecondaryGroupingSize ()
        {
                return unum_getAttribute (handle, Attribute.SecondaryGroupingSize);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getSignificantDigitsUsed ()
        {
                return unum_getAttribute (handle, Attribute.SignificantDigitsUsed);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getMinSignificantDigits ()
        {
                return unum_getAttribute (handle, Attribute.MinSignificantDigits);
        }

        /***********************************************************************
        
        ***********************************************************************/

        uint getMaxSignificantDigits ()
        {
                return unum_getAttribute (handle, Attribute.MaxSignificantDigits);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void getPattern (UString dst, bool localize)
        {
                uint fmat (wchar* result, uint len, ref UErrorCode e)
                {
                        return unum_toPattern (handle, localize, result, len, e);
                }

                dst.format (&fmat, "failed to retrieve numeric format pattern");
        }
}


/*******************************************************************************

        UNumberFormat provides functions for formatting and parsing 
        a number. Also provides methods for determining which locales have 
        number formats, and what their names are.

        UNumberFormat helps you to format and parse numbers for any locale. 
        Your code can be completely independent of the locale conventions 
        for decimal points, thousands-separators, or even the particular 
        decimal digits used, or whether the number format is even decimal. 
        There are different number format styles like decimal, currency, 
        percent and spellout

        See <A HREF="http://oss.software.ibm.com/icu/apiref/unum_8h.html">
        this page</A> for full details.

*******************************************************************************/

class UNumberFormat : ICU
{       
        package Handle  handle;  

        typedef void*   UFieldPos;
        typedef void*   ParseError;


        public  enum    Rounding    
                        {  
                        Ceiling, 
                        Floor, 
                        Down,
                        Up,
                        HalfEven,
                        HalfDown,
                        HalfUp
                        };

        public  enum    Pad     
                        {
                        BeforePrefix,
                        AfterPrefix,
                        BeforeSuffix,
                        AfterSuffix
                        };
                        
        public  enum    Style     
                        {  
                        PatternDecimal, 
                        Decimal, 
                        Currency, 
                        Percent, 
                        Scientific,
                        Spellout, 
                        Ordinal, 
                        Duration, 
                        RuleBased, 
                        Default = Decimal,
                        Ignore = PatternDecimal
                        };

        private enum    Attribute 
                        {
                        ParseIntOnly, 
                        GroupingUsed, 
                        DecimalAlwaysShown, 
                        MaxIntegerDigits,
                        MinIntegerDigits, 
                        IntegerDigits, 
                        MaxFractionDigits, 
                        MinFractionDigits,
                        FractionDigits, 
                        Multiplier, 
                        GroupingSize, 
                        RoundingMode,
                        RoundingIncrement, 
                        FormatWidth, 
                        PaddingPosition, 
                        SecondaryGroupingSize,
                        SignificantDigitsUsed, 
                        MinSignificantDigits, 
                        MaxSignificantDigits, 
                        LenientParse
                        };

        private enum    Symbol 
                        {
                        DecimalSeparator, 
                        GroupingSeparator, 
                        PatternSeparator, 
                        Percent,
                        ZeroDigit, 
                        Digit, 
                        MinusSign, 
                        PlusSign,
                        Currency, 
                        IntlCurrency, 
                        MonetarySeparator, 
                        Exponential,
                        Permill, 
                        PadEscape, 
                        Infinity, 
                        Nan,
                        SignificantDigit, 
                        FormatSymbolCount
                        };

        /***********************************************************************
        
        ***********************************************************************/

        this (Style style, char[] pattern, ref ULocale locale)
        {
                UErrorCode e;

                handle = unum_open (style, pattern.ptr, pattern.length, toString(locale.name), null, e);
                testError (e, "failed to create NumberFormat");
        }

        /***********************************************************************
        
        ***********************************************************************/

        ~this ()
        {
                unum_close (handle);
        }

        /***********************************************************************
        
        ***********************************************************************/

        void format (UString dst, int number, UFieldPos p = null)
        {
                uint fmat (wchar* result, uint len, ref UErrorCode e)
                {
                        return unum_format (handle, number, result, len, p, e);
                }

                dst.format (&fmat, "int format failed");
        }

        /***********************************************************************
        
        ***********************************************************************/

        void format (UString dst, long number, UFieldPos p = null)
        {
                uint fmat (wchar* result, uint len, ref UErrorCode e)
                {
                        return unum_formatInt64 (handle, number, result, len, p, e);
                }

                dst.format (&fmat, "int64 format failed");
        }

        /***********************************************************************
        
        ***********************************************************************/

        void format (UString dst, double number, UFieldPos p = null)
        {
                uint fmat (wchar* result, uint len, ref UErrorCode e)
                {
                        return unum_formatDouble (handle, number, result, len, p, e);
                }

                dst.format (&fmat, "double format failed");
        }

        /***********************************************************************
        
        ***********************************************************************/

        int parseInteger (UStringView src, uint* index=null)
        {
                UErrorCode e;

                return unum_parse (handle, src.content.ptr, src.len, index, e); 
        }

        /***********************************************************************
        
        ***********************************************************************/

        long parseLong (UStringView src, uint* index=null)
        {
                UErrorCode e;

                return unum_parseInt64 (handle, src.content.ptr, src.len, index, e); 
        }

        /***********************************************************************
        
        ***********************************************************************/

        double parseDouble (UStringView src, uint* index=null)
        {
                UErrorCode e;

                return unum_parseDouble (handle, src.content.ptr, src.len, index, e); 
        }



        /***********************************************************************
        
                Bind the ICU functions from a shared library. This is
                complicated by the issues regarding D and DLLs on the
                Windows platform

        ***********************************************************************/

        mixin(genICUNative!("in"
                ,"Handle function (uint, char*, uint, char*, ParseError, ref UErrorCode)", "unum_open"
                ,"void   function (Handle)", "unum_close"
                ,"int    function (Handle, int,    wchar*, uint, UFieldPos, ref UErrorCode)", "unum_format"
                ,"int    function (Handle, long,   wchar*, uint, UFieldPos, ref UErrorCode)", "unum_formatInt64"
                ,"int    function (Handle, double, wchar*, uint, UFieldPos, ref UErrorCode)", "unum_formatDouble"
                ,"int    function (Handle, wchar*, uint, uint*, ref UErrorCode)", "unum_parse"
                ,"long   function (Handle, wchar*, uint, uint*, ref UErrorCode)", "unum_parseInt64"
                ,"double function (Handle, wchar*, uint, uint*, ref UErrorCode)", "unum_parseDouble"
                ,"int    function (Handle, uint)", "unum_getAttribute"
                ,"void   function (Handle, uint, uint)", "unum_setAttribute"
                ,"uint   function (Handle, byte, wchar*, uint, ref UErrorCode)", "unum_toPattern"
                ,"void   function (Handle, byte, wchar*, uint, ParseError, ref UErrorCode)", "unum_applyPattern"
        ));
}



