/*******************************************************************************

        @file USearch.d

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

module com.ibm.icu.mangoicu.USearch;

private import  com.ibm.icu.mangoicu.ICU;

public  import  com.ibm.icu.mangoicu.ULocale,
                com.ibm.icu.mangoicu.UString,
                com.ibm.icu.mangoicu.UCollator,
                com.ibm.icu.mangoicu.UBreakIterator;

/*******************************************************************************

        Apis for an engine that provides language-sensitive text
        searching based on the comparison rules defined in a UCollator
        data struct. This ensures that language eccentricity can be handled,
        e.g. for the German collator, characters &#x00DF; and SS will be matched
        if case is chosen to be ignored. See the "ICU Collation Design
        Document" for more information.

        The algorithm implemented is a modified form of the Boyer Moore's
        search. For more information see "Efficient Text Searching in Java",
        published in Java Report in February, 1999, for further information
        on the algorithm.

        There are 2 match options for selection: Let S' be the sub-string
        of a text string S between the offsets start and end <start, end>. A
        pattern string P matches a text string S at the offsets <start, end> if

        - option 1. Some canonical equivalent of P matches some canonical
                    equivalent of S'

        - option 2. P matches S' and if P starts or ends with a combining
                    mark, there exists no non-ignorable combining mark before
                    or after S' in S respectively.

        Option 2 will be the default

        This search has APIs similar to that of other text iteration
        mechanisms such as the break iterators in ubrk.h. Using these
        APIs, it is easy to scan through text looking for all occurances
        of a given pattern. This search iterator allows changing of
        direction by calling a reset followed by a next or previous.
        Though a direction change can occur without calling reset first,
        this operation comes with some speed penalty. Generally, match
        results in the forward direction will match the result matches
        in the backwards direction in the reverse order

        USearch provides APIs to specify the starting position within
        the text string to be searched, e.g. setOffset(), previous(x)
        and next(x). Since the starting position will be set as it
        is specified, please take note that there are some dangerous
        positions which the search may render incorrect results:

        - The midst of a substring that requires normalization.

        - If the following match is to be found, the position should
          not be the second character which requires to be swapped
          with the preceding character. Vice versa, if the preceding
          match is to be found, position to search from should not be
          the first character which requires to be swapped with the
          next character. E.g certain Thai and Lao characters require
          swapping.

        - If a following pattern match is to be found, any position
          within a contracting sequence except the first will fail.
          Vice versa if a preceding pattern match is to be found,
          a invalid starting point would be any character within a
          contracting sequence except the last.

        A breakiterator can be used if only matches at logical breaks are
        desired. Using a breakiterator will only give you results that
        exactly matches the boundaries given by the breakiterator. For
        instance the pattern "e" will not be found in the string "\u00e9"
        if a character break iterator is used.

        Options are provided to handle overlapping matches. E.g. In
        English, overlapping matches produces the result 0 and 2 for
        the pattern "abab" in the text "ababab", where else mutually
        exclusive matches only produce the result of 0.

        Though collator attributes will be taken into consideration while
        performing matches, there are no APIs here for setting and getting
        the attributes. These attributes can be set by getting the collator
        from getCollator() and using the APIs in UCollator. Lastly to update
        String Search to the new collator attributes, reset() has to be called.

        See http://oss.software.ibm.com/icu/apiref/usearch_8h.html for full
        details.

*******************************************************************************/

class USearch : ICU
{
        private Handle          handle;
        private UBreakIterator* iterator;

        // DONE is returned by previous() and next() after all valid
        // matches have been returned, and by first() and last() if
        // there are no matches at all.
        const uint      Done = uint.max;

        //Possible types of searches
        public enum     Attribute
                        {
                        Overlap,
                        CanonicalMatch,
                        Count
                        }

        public enum     AttributeValue
                        {
                        Default = -1,
                        Off,
                        On,
                        Count
                        }

        /***********************************************************************

                Creating a search iterator data struct using the argument
                locale language rule set

        ***********************************************************************/

        this (UStringView pattern, UStringView text, ref ULocale locale, UBreakIterator* iterator = null)
        {
                UErrorCode e;

                this.iterator = iterator;
                handle = usearch_open (pattern.get.ptr, pattern.length, text.get.ptr, text.length, toString(locale.name), ( iterator is null ) ? null : iterator.handle, e);
                testError (e, "failed to open search");
        }

        /***********************************************************************

                Creating a search iterator data struct using the argument
                locale language rule set

        ***********************************************************************/

        this (UStringView pattern, UStringView text, UCollator col, UBreakIterator* iterator = null)
        {
                UErrorCode e;

                this.iterator = iterator;
                handle = usearch_openFromCollator (pattern.get.ptr, pattern.length, text.get.ptr, text.length, col.handle, ( iterator is null ) ? null : iterator.handle, e);
                testError (e, "failed to open search from collator");
        }

        /***********************************************************************

                Close this USearch

        ***********************************************************************/

        ~this ()
        {
                usearch_close (handle);
        }

        /***********************************************************************

                Sets the current position in the text string which the
                next search will start from.

        ***********************************************************************/

        void setOffset (uint position)
        {
                UErrorCode e;

                usearch_setOffset (handle, position, e);
                testError (e, "failed to set search offset");
        }

        /***********************************************************************

                Return the current index in the string text being searched

        ***********************************************************************/

        uint getOffset ()
        {
                return usearch_getOffset (handle);
        }

        /***********************************************************************

                Returns the index to the match in the text string that was
                searched

        ***********************************************************************/

        uint getMatchedStart ()
        {
                return usearch_getMatchedStart (handle);
        }

        /***********************************************************************

                Returns the length of text in the string which matches the
                search pattern

        ***********************************************************************/

        uint getMatchedLength ()
        {
                return usearch_getMatchedLength (handle);
        }

        /***********************************************************************

                Returns the text that was matched by the most recent call to
                first(), next(), previous(), or last().

        ***********************************************************************/

        void getMatchedText (UString s)
        {
                uint fmt (wchar* dst, uint length, ref UErrorCode e)
                {
                        return usearch_getMatchedText (handle, dst, length, e);
                }

                s.format (&fmt, "failed to extract matched text");
        }

        /***********************************************************************

                Set the string text to be searched.

        ***********************************************************************/

        void setText (UStringView t)
        {
                UErrorCode e;

                usearch_setText (handle, t.get.ptr, t.length, e);
                testError (e, "failed to set search text");
        }

        /***********************************************************************

                Return the string text to be searched. Note that this
                returns a read-only reference to the search text.

        ***********************************************************************/

        UStringView getText ()
        {
                uint len;

                wchar *x = usearch_getText (handle, &len);
                return new UStringView (x[0..len]);
        }

        /***********************************************************************

                Sets the pattern used for matching

        ***********************************************************************/

        void setPattern (UStringView t)
        {
                UErrorCode e;

                usearch_setPattern (handle, t.get.ptr, t.length, e);
                testError (e, "failed to set search pattern");
        }

        /***********************************************************************

                Gets the search pattern. Note that this returns a
                read-only reference to the pattern.

        ***********************************************************************/

        UStringView getPattern ()
        {
                uint len;

                wchar *x = usearch_getPattern (handle, &len);
                return new UStringView (x[0..len]);
        }

        /***********************************************************************

                Set the BreakIterator that will be used to restrict the
                points at which matches are detected.

        ***********************************************************************/

        void setIterator (UBreakIterator* iterator)
        {
                UErrorCode e;

                this.iterator = iterator;
                usearch_setBreakIterator (handle, cast(Handle)iterator.handle, e);
                testError (e, "failed to set search iterator");
        }

        /***********************************************************************

                Get the BreakIterator that will be used to restrict the
                points at which matches are detected.

        ***********************************************************************/

        UBreakIterator* getIterator ()
        {
                return iterator;
        }

        /***********************************************************************

                Returns the first index at which the string text matches
                the search pattern

        ***********************************************************************/

        uint first ()
        {
                UErrorCode e;

                uint x = usearch_first (handle, e);
                testError (e, "failed on first search");
                return x;
        }

        /***********************************************************************

                Returns the last index in the target text at which it
                matches the search pattern

        ***********************************************************************/

        uint last ()
        {
                UErrorCode e;

                uint x = usearch_last (handle, e);
                testError (e, "failed on last search");
                return x;
        }

        /***********************************************************************

                Returns the index of the next point at which the string
                text matches the search pattern, starting from the current
                position.

                If pos is specified, returns the first index greater than
                pos at which the string text matches the search pattern

        ***********************************************************************/

        uint next (uint pos = uint.max)
        {
                UErrorCode e;
                uint  x;

                x = (pos == uint.max) ? usearch_next (handle, e) :
                                        usearch_following (handle, pos, e);

                testError (e, "failed on next search");
                return x;
        }

        /***********************************************************************

                Returns the index of the previous point at which the
                string text matches the search pattern, starting at
                the current position.

                If pos is specified, returns the first index less
                than pos at which the string text matches the search
                pattern.

        ***********************************************************************/

        uint previous (uint pos = uint.max)
        {
                UErrorCode e;
                uint  x;

                x = (pos == uint.max) ? usearch_previous  (handle, e) :
                                        usearch_preceding (handle, pos, e);

                testError (e, "failed on next search");
                return x;
        }

        /***********************************************************************

                Search will begin at the start of the text string if a
                forward iteration is initiated before a backwards iteration.
                Otherwise if a backwards iteration is initiated before a
                forwards iteration, the search will begin at the end of the
                text string

        ***********************************************************************/

        void reset ()
        {
                usearch_reset (handle);
        }

        /***********************************************************************

                Gets the collator used for the language rules.

        ***********************************************************************/

        UCollator getCollator ()
        {
                return new UCollator (usearch_getCollator (handle));
        }

        /***********************************************************************

                Sets the collator used for the language rules. This
                method causes internal data such as Boyer-Moore shift
                tables to be recalculated, but the iterator's position
                is unchanged

        ***********************************************************************/

        void setCollator (UCollator col)
        {
                UErrorCode e;

                usearch_setCollator (handle, col.handle, e);
                testError (e, "failed to set search collator");
        }


        /***********************************************************************

                Bind the ICU functions from a shared library. This is
                complicated by the issues regarding D and DLLs on the
                Windows platform

        ***********************************************************************/

        mixin(genICUNative!("in"
                ,"Handle  function (wchar*, uint, wchar*, uint, char*, void*, ref UErrorCode)", "usearch_open"
                ,"Handle  function (wchar*, uint, wchar*, uint, Handle, void*, ref UErrorCode)", "usearch_openFromCollator"
                ,"void    function (Handle)", "usearch_close"
                ,"void    function (Handle, uint, ref UErrorCode)", "usearch_setOffset"
                ,"uint    function (Handle)", "usearch_getOffset"
                ,"uint    function (Handle)", "usearch_getMatchedStart"
                ,"uint    function (Handle)", "usearch_getMatchedLength"
                ,"uint    function (Handle, wchar*, uint, ref UErrorCode)", "usearch_getMatchedText"
                ,"void    function (Handle, wchar*, uint, ref UErrorCode)", "usearch_setText"
                ,"wchar*  function (Handle, uint*)", "usearch_getText"
                ,"void    function (Handle, wchar*, uint, ref UErrorCode)", "usearch_setPattern"
                ,"wchar*  function (Handle, uint*)", "usearch_getPattern"
                ,"uint    function (Handle, ref UErrorCode)", "usearch_first"
                ,"uint    function (Handle, ref UErrorCode)", "usearch_last"
                ,"uint    function (Handle, ref UErrorCode)", "usearch_next"
                ,"uint    function (Handle, ref UErrorCode)", "usearch_previous"
                ,"uint    function (Handle, uint, ref UErrorCode)", "usearch_following"
                ,"uint    function (Handle, uint, ref UErrorCode)", "usearch_preceding"
                ,"void    function (Handle)", "usearch_reset"
                ,"void    function (Handle, Handle, ref UErrorCode)", "usearch_setBreakIterator"
                ,"Handle  function (Handle)", "usearch_getCollator"
                ,"void    function (Handle, Handle, ref UErrorCode)", "usearch_setCollator"
        ));
}
