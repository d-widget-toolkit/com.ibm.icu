/*******************************************************************************

        @file UBreakIterator.d

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

module com.ibm.icu.mangoicu.UBreakIterator;

private import  com.ibm.icu.mangoicu.ICU;

public  import  com.ibm.icu.mangoicu.ULocale,
                com.ibm.icu.mangoicu.UText,
                com.ibm.icu.mangoicu.UString;



// /*******************************************************************************
//
// *******************************************************************************/
//
// class UCharacterIterator : UBreakIterator
// {
//         /***********************************************************************
//
//         ***********************************************************************/
//
//         this (ref ULocale locale, UStringView text = null)
//         {
//                 super (Type.Character, locale, text);
//         }
// }
//
//
// /*******************************************************************************
//
// *******************************************************************************/
//
// class UWordIterator : UBreakIterator
// {
//         public enum     Break
//                         {
//                         None = 0,
//                         NoneLimit = 100,
//                         Number = 100,
//                         NumberLimit = 200,
//                         Letter = 200,
//                         LetterLimit = 300,
//                         Kana = 300,
//                         KanaLimit = 400,
//                         Ideo = 400,
//                         IdeoLimit = 500
//                         }
//
//         /***********************************************************************
//
//         ***********************************************************************/
//
//         this (ref ULocale locale, UStringView text = null)
//         {
//                 super (Type.Word, locale, text);
//         }
//
//         /***********************************************************************
//
//                 Return the status from the break rule that determined
//                 the most recently returned break position.
//
//         ***********************************************************************/
//
//         void getStatus (ref Break b)
//         {
//                 b = cast(Break) super.getStatus();
//         }
// }
//
//
// /*******************************************************************************
//
// *******************************************************************************/
//
// class ULineIterator : UBreakIterator
// {
//         public enum     Break
//                         {
//                         Soft = 0,
//                         SoftLimit = 100,
//                         Hard = 100,
//                         HardLimit = 200
//                         }
//
//         /***********************************************************************
//
//         ***********************************************************************/
//
//         this (ref ULocale locale, UStringView text = null)
//         {
//                 super (Type.Line, locale, text);
//         }
//
//         /***********************************************************************
//
//                 Return the status from the break rule that determined
//                 the most recently returned break position.
//
//         ***********************************************************************/
//
//         void getStatus (ref Break b)
//         {
//                 b = cast(Break) super.getStatus();
//         }
// }
//
//
// /*******************************************************************************
//
// *******************************************************************************/
//
// class USentenceIterator : UBreakIterator
// {
//         public enum     Break
//                         {
//                         Term = 0,
//                         TermLimit = 100,
//                         Sep = 100,
//                         Limit = 200
//                         }
//
//         /***********************************************************************
//
//         ***********************************************************************/
//
//         this (ref ULocale locale, UStringView text = null)
//         {
//                 super (Type.Sentence, locale, text);
//         }
//
//         /***********************************************************************
//
//                 Return the status from the break rule that determined
//                 the most recently returned break position.
//
//         ***********************************************************************/
//
//         void getStatus (ref Break b)
//         {
//                 b = cast(Break) super.getStatus();
//         }
// }
//
//
// /*******************************************************************************
//
// *******************************************************************************/
//
// class UTitleIterator : UBreakIterator
// {
//         /***********************************************************************
//
//         ***********************************************************************/
//
//         this (ref ULocale locale, UStringView text = null)
//         {
//                 super (Type.Title, locale, text);
//         }
// }
//
//
// /*******************************************************************************
//
// *******************************************************************************/
//
// class URuleIterator : UBreakIterator
// {
//         /***********************************************************************
//
//                 Open a new UBreakIterator for locating text boundaries
//                 using specified breaking rules
//
//         ***********************************************************************/
//
//         this (UStringView rules, UStringView text = null)
//         {
//                 UErrorCode e;
//
//                 handle = ubrk_openRules (rules.get.ptr, rules.length, text.get.ptr, text.length, null, e);
//                 testError (e, "failed to open rule iterator");
//         }
// }


/*******************************************************************************

        BreakIterator defines methods for finding the location of boundaries
        in text. Pointer to a UBreakIterator maintain a current position and
        scan over text returning the index of characters where boundaries occur.

        Line boundary analysis determines where a text string can be broken
        when line-wrapping. The mechanism correctly handles punctuation and
        hyphenated words.

        Sentence boundary analysis allows selection with correct interpretation
        of periods within numbers and abbreviations, and trailing punctuation
        marks such as quotation marks and parentheses.

        Word boundary analysis is used by search and replace functions, as well
        as within text editing applications that allow the user to select words
        with a double click. Word selection provides correct interpretation of
        punctuation marks within and following words. Characters that are not
        part of a word, such as symbols or punctuation marks, have word-breaks
        on both sides.

        Character boundary analysis allows users to interact with characters
        as they expect to, for example, when moving the cursor through a text
        string. Character boundary analysis provides correct navigation of
        through character strings, regardless of how the character is stored.
        For example, an accented character might be stored as a base character
        and a diacritical mark. What users consider to be a character can differ
        between languages.

        Title boundary analysis locates all positions, typically starts of
        words, that should be set to Title Case when title casing the text.

        See <A HREF="http://oss.software.ibm.com/icu/apiref/ubrk_8h.html">
        this page</A> for full details.

*******************************************************************************/

struct UBreakIterator
{
        typedef void _UBreakIterator;
        alias _UBreakIterator* Handle;
        Handle handle;
        UText ut;

        // this is returned by next(), previous() etc ...
        const uint Done = uint.max;
        alias Done DONE;

        /***********************************************************************

                internal types passed to C API

        ***********************************************************************/

        private  enum   Type
                        {
                        Character,
                        Word,
                        Line,
                        Sentence,
                        Title
                        }


        public enum     WordBreak
                        {
                        None = 0,
                        NoneLimit = 100,
                        Number = 100,
                        NumberLimit = 200,
                        Letter = 200,
                        LetterLimit = 300,
                        Kana = 300,
                        KanaLimit = 400,
                        Ideo = 400,
                        IdeoLimit = 500
                        }
        public enum     LineBreak
                        {
                        Soft = 0,
                        SoftLimit = 100,
                        Hard = 100,
                        HardLimit = 200
                        }
        public enum     SentenceBreak
                        {
                        Term = 0,
                        TermLimit = 100,
                        Sep = 100,
                        Limit = 200
                        }


        /***********************************************************************

                Open a new UBreakIterator for locating text boundaries for
                a specified locale. A UBreakIterator may be used for detecting
                character, line, word, and sentence breaks in text.

        ***********************************************************************/

        static UBreakIterator openWordIterator( ULocale locale, char[] str = null ){
            UBreakIterator res;
            auto e = ICU.UErrorCode.OK;
            res.handle = ubrk_open( Type.Word, cast(char*)locale.name.ptr, null, 0, e);
            ICU.testError (e, "failed to open word iterator");
            if( str ) {
                res.ut.openUTF8(str);
                ubrk_setUText( res.handle, & res.ut, e);
                ICU.testError (e, "failed to set text in iterator");
            }
            return res;
        }

        static UBreakIterator openLineIterator( ULocale locale, char[] str = null ){
            UBreakIterator res;
            auto e = ICU.UErrorCode.OK;
            res.handle = ubrk_open( Type.Line, cast(char*)locale.name.ptr, null, 0, e);
            ICU.testError (e, "failed to open line iterator");
            if( str ) {
                res.ut.openUTF8(str);
                ubrk_setUText( res.handle, & res.ut, e);
                ICU.testError (e, "failed to set text in iterator");
            }
            return res;
        }

        /***********************************************************************

                Close a UBreakIterator

        ***********************************************************************/

        void close ()
        {
                ut.close();
                ubrk_close (handle);
        }

        /***********************************************************************

                Sets an existing iterator to point to a new piece of text

        ***********************************************************************/

        void setText (UStringView text)
        {
                ICU.UErrorCode e;
                ubrk_setText (handle, text.get.ptr, text.length, e);
                ICU.testError (e, "failed to set iterator text");
        }

        void setText (char[] text)
        {
                auto e = ICU.UErrorCode.OK;
                ut.openUTF8(text);
                ubrk_setUText( handle, & ut, e);
                ICU.testError (e, "failed to set text in iterator");
        }

        /***********************************************************************

                Determine the most recently-returned text boundary

        ***********************************************************************/

        uint current ()
        {
                return ubrk_current (handle);
        }

        /***********************************************************************

                Determine the text boundary following the current text
                boundary, or UBRK_DONE if all text boundaries have been
                returned.

                If offset is specified, determines the text boundary
                following the current text boundary: The value returned
                is always greater than offset, or Done

        ***********************************************************************/

        uint next (uint offset = uint.max)
        {
                if (offset == uint.max)
                    return ubrk_next (handle);
                return ubrk_following (handle, offset);
        }
        alias next following;
        /***********************************************************************

                Determine the text boundary preceding the current text
                boundary, or Done if all text boundaries have been returned.

                If offset is specified, determines the text boundary preceding
                the specified offset. The value returned is always smaller than
                offset, or Done.

        ***********************************************************************/

        uint previous (uint offset = uint.max)
        {
                if (offset == uint.max)
                    return ubrk_previous (handle);
                return ubrk_preceding (handle, offset);
        }

        /***********************************************************************

                Determine the index of the first character in the text
                being scanned. This is not always the same as index 0
                of the text.

        ***********************************************************************/

        uint first ()
        {
                return ubrk_first (handle);
        }

        /***********************************************************************

                Determine the index immediately beyond the last character
                in the text being scanned. This is not the same as the last
                character

        ***********************************************************************/

        uint last ()
        {
                return ubrk_last (handle);
        }

        /***********************************************************************

                Returns true if the specfied position is a boundary position.
                As a side effect, leaves the iterator pointing to the first
                boundary position at or after "offset".

        ***********************************************************************/

        bool isBoundary (uint offset)
        {
                return ubrk_isBoundary (handle, offset) != 0;
        }

        /***********************************************************************

                Return the status from the break rule that determined
                the most recently returned break position.

        ***********************************************************************/

        void getStatus (ref uint s)
        {
                s = getStatus ();
        }

        /***********************************************************************

                Return the status from the break rule that determined
                the most recently returned break position.

                The values appear in the rule source within brackets,
                {123}, for example. For rules that do not specify a status,
                a default value of 0 is returned.

                For word break iterators, the possible values are defined
                in enum UWordBreak

        ***********************************************************************/

        private uint getStatus ()
        {
                return ubrk_getRuleStatus (handle);
        }


        /***********************************************************************

                Bind the ICU functions from a shared library. This is
                complicated by the issues regarding D and DLLs on the
                Windows platform

        ***********************************************************************/

        mixin(/*ICU.*/genICUNative!("uc"
                ,"Handle function (uint, char*, wchar*, uint, ref ICU.UErrorCode)", "ubrk_open"
                ,"Handle function (wchar*, uint, wchar*, uint, void*, ref ICU.UErrorCode)", "ubrk_openRules"
                ,"void   function (Handle)", "ubrk_close"
                ,"void   function (Handle, wchar*, uint, ref ICU.UErrorCode)", "ubrk_setText"
                ,"uint   function (Handle)", "ubrk_current"
                ,"uint   function (Handle)", "ubrk_next"
                ,"uint   function (Handle)", "ubrk_previous"
                ,"uint   function (Handle)", "ubrk_first"
                ,"uint   function (Handle)", "ubrk_last"
                ,"uint   function (Handle, uint)", "ubrk_preceding"
                ,"uint   function (Handle, uint)", "ubrk_following"
                ,"byte   function (Handle, uint)", "ubrk_isBoundary"
                ,"uint   function (Handle)", "ubrk_getRuleStatus"
                ,"Handle function (Handle, void *, int *, ref ICU.UErrorCode)", "ubrk_safeClone"
                ,"void   function (Handle, UText*, ref ICU.UErrorCode)", "ubrk_setUText"
        ));
}
