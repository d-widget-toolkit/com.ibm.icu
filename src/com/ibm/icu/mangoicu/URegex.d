/*******************************************************************************

        @file URegex.d
        
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

module com.ibm.icu.mangoicu.URegex;

private import  com.ibm.icu.mangoicu.ICU;

public  import  com.ibm.icu.mangoicu.ULocale,
                com.ibm.icu.mangoicu.UString,
                com.ibm.icu.mangoicu.UCollator,
                com.ibm.icu.mangoicu.UBreakIterator;


/*******************************************************************************

        Set of slices to return for group matching. See URegex.groups()

*******************************************************************************/

class Groups : ICU
{
        public  wchar[] g0,
                        g1,
                        g2,
                        g3,
                        g4,
                        g5,
                        g6,
                        g7,
                        g8,
                        g9;
}

/*******************************************************************************

        Apis for an engine that provides regular-expression searching of
        UTF16 strings.

        See http://icu.sourceforge.net/apiref/icu4c/uregex_8h.html for full
        details.

*******************************************************************************/

class URegex : Groups
{       
        private Handle  handle;
        private UStringView   theText;

        // Regex modes 
        public enum     Flag 
                        {
                        None            = 0,

                        // Enable case insensitive matching
                        CaseInsensitive = 2, 

                        // Allow white space and comments within patterns
                        Comments        = 4,

                        // Control behavior of "$" and "^" If set, recognize 
                        // line terminators within string, otherwise, match
                        // only at start and end of input string.
                        MultiLine       = 8,

                        // If set, '.' matches line terminators, otherwise '.' 
                        // matching stops at line end
                        DotAll          = 32,
                        
                        // Forces normalization of pattern and strings
                        CanonEq         = 128,  

                        // If set, uses the Unicode TR 29 definition of word 
                        // boundaries. Warning: Unicode word boundaries are 
                        // quite different from traditional regular expression 
                        // word boundaries. See http://unicode.org/reports/tr29/#Word_Boundaries
                        UWord           = 256,
                        }

        /***********************************************************************

                Compiles the regular expression in string form into an 
                internal representation using the specified match mode 
                flags. The resulting regular expression handle can then 
                be used to perform various matching operations.

        ***********************************************************************/

        this (wchar[] pattern, Flag flags=Flag.None, ParseError* pe=null)
        {
                UErrorCode e;

                handle = uregex_open (pattern.ptr, pattern.length, flags, pe, e);
                testError (e, "failed to open regex");
                uregex_setText (handle, null, 0, e);
        }

        /***********************************************************************

                Compiles the regular expression in string form into an 
                internal representation using the specified match mode 
                flags. The resulting regular expression handle can then 
                be used to perform various matching operations.

        ***********************************************************************/

        this (UStringView pattern, Flag flags=Flag.None, ParseError* pe=null)
        {
                this (pattern.get, flags, pe);
        }

        /***********************************************************************

                Internal constructor; used for cloning

        ***********************************************************************/

        private this (Handle handle)
        {
                UErrorCode e;

                this.handle = handle;
                uregex_setText (handle, null, 0, e);
        }

        /***********************************************************************
        
                Close the regular expression, recovering all resources (memory) 
                it was holding

        ***********************************************************************/

        ~this ()
        {
                uregex_close (handle);
        }

        /***********************************************************************
        
                Cloning a regular expression is faster than opening a second 
                instance from the source form of the expression, and requires 
                less memory.

                Note that the current input string and the position of any 
                matched text within it are not cloned; only the pattern itself 
                and and the match mode flags are copied.

                Cloning can be particularly useful to threaded applications 
                that perform multiple match operations in parallel. Each 
                concurrent RE operation requires its own instance of a 
                URegularExpression.

        ***********************************************************************/

        URegex clone ()
        {       
                UErrorCode e;

                Handle h = uregex_clone (handle, e);
                testError (e, "failed to clone regex");
                return new URegex (h);
        }

        /***********************************************************************

                Return a copy of the source form of the pattern for this 
                regular expression

        ***********************************************************************/

        UString getPattern ()
        {       
                UErrorCode e;
                uint  len;

                wchar* x = uregex_pattern (handle, len, e);
                testError (e, "failed to extract regex pattern");
                return new UString (x[0..len]);
        }

        /***********************************************************************

                Get the match mode flags that were specified when compiling 
                this regular expression        

        ***********************************************************************/

        Flag getFlags ()
        {       
                UErrorCode e;

                Flag f = cast(Flag) uregex_flags (handle, e);
                testError (e, "failed to get regex flags");
                return f;        
        }

        /***********************************************************************
        
                Set the subject text string upon which the regular expression 
                will look for matches.

                This function may be called any number of times, allowing the 
                regular expression pattern to be applied to different strings.

                Regular expression matching operations work directly on the 
                application's string data. No copy is made. The subject string 
                data must not be altered after calling this function until after 
                all regular expression operations involving this string data are 
                completed.

                Zero length strings are permitted. In this case, no subsequent 
                match operation will dereference the text string pointer.

        ***********************************************************************/

        void setText (UStringView t)
        {       
                UErrorCode e;

                theText = t;
                uregex_setText (handle, t.get.ptr, t.length, e);
                testError (e, "failed to set regex text");
        }

        /***********************************************************************
                
                Get the subject text that is currently associated with this 
                regular expression object. This simply returns whatever was
                previously supplied via setText(). 

                Note that this returns a read-only reference to the text.

        ***********************************************************************/

        UStringView getText ()
        {      
                return theText;
        }

        /***********************************************************************

                Return a set of slices representing the parenthesised groups.
                This can be used in the following manner:               

                @code
                wchar msg;

                if (regex.next())
                    with (regex.groups())
                          msg ~= g1 ~ ":" ~ g2
                @endcode

                Note that g0 represents the entire match, whereas g1 through
                g9 represent the parenthesised expressions.
                
        ***********************************************************************/

        Groups groups ()
        {  
                wchar[]*        p = &g0;
                uint            count = groupCount();
                wchar[]         content = theText.get();

                if (count > 9)
                    count = 9;
                for (uint i=0; i <= count; ++p, ++i)
                     *p = content [start(i)..end(i)];
                return this;
        }

        /***********************************************************************

                Extract the string for the specified matching expression or 
                subexpression. UString 's' is the destination for the match.

                Group #0 is the complete string of matched text. Group #1 is 
                the text matched by the first set of capturing parentheses.
        
        ***********************************************************************/

        void group (UString s, uint index)
        {       
                uint fmt (wchar* dst, uint length, ref UErrorCode e)
                {
                        return uregex_group (handle, index, dst, length, e);
                }

                s.format (&fmt, "failed to extract regex group text");
        }

        /***********************************************************************
        
                Get the number of capturing groups in this regular 
                expression's pattern

        ***********************************************************************/

        uint groupCount ()
        {       
                UErrorCode e;

                uint i = uregex_groupCount (handle, e);
                testError (e, "failed to get regex group-count");
                return i;        
        }

        /***********************************************************************
                
                Returns the index in the input string of the start of the 
                text matched by the specified capture group during the 
                previous match operation.

                Return -1 if the capture group was not part of the last 
                match. Group #0 refers to the complete range of matched 
                text. Group #1 refers to the text matched by the first 
                set of capturing parentheses

        ***********************************************************************/

        uint start (uint index = 0)
        {       
                UErrorCode e;

                uint i = uregex_start (handle, index, e);
                testError (e, "failed to get regex start");
                return i;        
        }

        /***********************************************************************

                Returns the index in the input string of the position 
                following the end of the text matched by the specified 
                capture group.

                Return -1 if the capture group was not part of the last 
                match. Group #0 refers to the complete range of matched 
                text. Group #1 refers to the text matched by the first 
                set of capturing parentheses.
        
        ***********************************************************************/

        uint end (uint index = 0)
        {       
                UErrorCode e;

                uint i = uregex_end (handle, index, e);
                testError (e, "failed to get regex end");
                return i;        
        }

        /***********************************************************************

                Reset any saved state from the previous match.

                Has the effect of causing uregex_findNext to begin at the 
                specified index, and causing uregex_start(), uregex_end() 
                and uregex_group() to return an error indicating that there 
                is no match information available.
        
        ***********************************************************************/

        void reset (uint startIndex)
        {       
                UErrorCode e;

                uregex_reset (handle, startIndex, e);
                testError (e, "failed to set regex next-index");
        }

        /***********************************************************************
        
                Attempts to match the input string, beginning at startIndex, 
                against the pattern.

                To succeed, the match must extend to the end of the input 
                string

        ***********************************************************************/

        bool match (uint startIndex)
        {       
                UErrorCode e;

                bool b = uregex_matches (handle, startIndex, e);
                testError (e, "failed while matching regex");
                return b;
        }

        /***********************************************************************

                Attempts to match the input string, starting from the 
                specified index, against the pattern.

                The match may be of any length, and is not required to 
                extend to the end of the input string. Contrast with match()        

        ***********************************************************************/

        bool probe (uint startIndex)
        {       
                UErrorCode e;

                bool b = uregex_lookingAt (handle, startIndex, e);
                testError (e, "failed while looking at regex");
                return b;
        }

        /***********************************************************************
                
                Returns whether the text matches the search pattern, starting 
                from the current position.

                If startIndex is specified, the current position is moved to 
                the specified location before the seach is initiated.

        ***********************************************************************/

        bool next (uint startIndex = uint.max)
        {     
                UErrorCode e;
                bool  b;

                b = (startIndex == uint.max) ? uregex_findNext (handle, e) : 
                                               uregex_find     (handle, startIndex, e);

                testError (e, "failed on next regex");  
                return b;
        }

        /***********************************************************************
        
                Replaces every substring of the input that matches the pattern 
                with the given replacement string.

                This is a convenience function that provides a complete 
                find-and-replace-all operation.

                This method scans the input string looking for matches of 
                the pattern. Input that is not part of any match is copied 
                unchanged to the destination buffer. Matched regions are 
                replaced in the output buffer by the replacement string. 
                The replacement string may contain references to capture 
                groups; these take the form of $1, $2, etc.

                The provided 'result' will contain the results, and should
                be set with a length sufficient to house the entire result.
                Upon completion, the 'result' is shortened appropriately 
                and the total extent (length) of the operation is returned. 
                Set the initital length of 'result' using the UString method
                truncate().

                The returned extent should be checked to ensure it is not
                longer than the length of 'result'. If it is longer, then
                the result has been truncated.
                
        ***********************************************************************/

        uint replaceAll (UStringView replace, UString result)
        {
                UErrorCode e;

                uint len = uregex_replaceAll (handle, replace.get.ptr, replace.length, result.get.ptr, result.length, e);
                testError (e, "failed during regex replace");  
                result.truncate (len);
                return len;
        }

        /***********************************************************************
        
                Replaces the first substring of the input that matches the 
                pattern with the given replacement string.

                This is a convenience function that provides a complete 
                find-and-replace operation.

                This method scans the input string looking for a match of 
                the pattern. All input that is not part of the match is 
                copied unchanged to the destination buffer. The matched 
                region is replaced in the output buffer by the replacement 
                string. The replacement string may contain references to 
                capture groups; these take the form of $1, $2, etc

                The provided 'result' will contain the results, and should
                be set with a length sufficient to house the entire result.
                Upon completion, the 'result' is shortened appropriately 
                and the total extent (length) of the operation is returned. 
                Set the initital length of 'result' using the UString method
                truncate().

                The returned extent should be checked to ensure it is not
                longer than the length of 'result'. If it is longer, then
                the result has been truncated.
                
        ***********************************************************************/

        uint replaceFirst (UStringView replace, UString result)
        {
                UErrorCode e;

                uint len = uregex_replaceFirst (handle, replace.get.ptr, replace.length, result.get.ptr, result.length, e);
                testError (e, "failed during regex replace");  
                result.truncate (len);
                return len;
        }

        /***********************************************************************
        
                Split the text up into slices (fields), where each slice 
                represents the text situated between each pattern matched
                within the text. The pattern is expected to represent one
                or more slice delimiters.

        ***********************************************************************/

        uint split (wchar[][] fields)
        {     
                UErrorCode           e;
                uint            pos,
                                count;
                wchar[]         content = theText.get;

                while (count < fields.length)
                       if (uregex_findNext (handle, e) && e == e.OK)
                          {
                          uint i = start();
                          fields[count] = content[pos..i];
                          pos = end ();

                          // ignore leading delimiter
                          if (i)
                              ++count;
                          }
                       else
                          break;
                
                testError (e, "failed during split");  
                return count;
        }


        /***********************************************************************

                Bind the ICU functions from a shared library. This is
                complicated by the issues regarding D and DLLs on the
                Windows platform
        
        ***********************************************************************/
              
        mixin(genICUNative!("in"
                ,"Handle  function (wchar*, uint, uint, ParseError*, ref UErrorCode)", "uregex_open"
                ,"void    function (Handle)", "uregex_close"
                ,"Handle  function (Handle, ref UErrorCode)", "uregex_clone"
                ,"wchar*  function (Handle, ref uint, ref UErrorCode)", "uregex_pattern"
                ,"uint    function (Handle, ref UErrorCode)", "uregex_flags"
                ,"void    function (Handle, wchar*, uint, ref UErrorCode)", "uregex_setText"
                ,"wchar*  function (Handle, ref uint, ref UErrorCode)", "uregex_getText"
                ,"uint    function (Handle, uint, wchar*, uint, ref UErrorCode)", "uregex_group"
                ,"uint    function (Handle, ref UErrorCode)", "uregex_groupCount"
                ,"uint    function (Handle, uint, ref UErrorCode)", "uregex_start"
                ,"uint    function (Handle, uint, ref UErrorCode)", "uregex_end"
                ,"void    function (Handle, uint, ref UErrorCode)", "uregex_reset"
                ,"bool    function (Handle, uint, ref UErrorCode)", "uregex_matches"
                ,"bool    function (Handle, uint, ref UErrorCode)", "uregex_lookingAt"
                ,"bool    function (Handle, uint, ref UErrorCode)", "uregex_find"
                ,"bool    function (Handle, ref UErrorCode)", "uregex_findNext"
                ,"uint    function (Handle, wchar*, uint, wchar*, uint, ref UErrorCode)", "uregex_replaceAll"
                ,"uint    function (Handle, wchar*, uint, wchar*, uint, ref UErrorCode)", "uregex_replaceFirst"
        ));
}
