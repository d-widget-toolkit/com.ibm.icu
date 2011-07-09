/*******************************************************************************

        @file UMessageFormat.d
        
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

module com.ibm.icu.mangoicu.UMessageFormat;

private import  com.ibm.icu.mangoicu.ICU,
                com.ibm.icu.mangoicu.UString;

public  import  com.ibm.icu.mangoicu.ULocale;
private import java.lang.util;

/*******************************************************************************

        Provides means to produce concatenated messages in language-neutral 
        way. Use this for all concatenations that show up to end users. Takes 
        a set of objects, formats them, then inserts the formatted strings into 
        the pattern at the appropriate places. 

        See <A HREF="http://oss.software.ibm.com/icu/apiref/umsg_8h.html">
        this page</A> for full details.

*******************************************************************************/

class UMessageFormat : ICU
{       
        private Handle handle;

        /***********************************************************************

                Open a message formatter with given wchar[] and for the 
                given locale.

        ***********************************************************************/

        this (wchar[] pattern, ref ULocale locale = ULocale.Default)
        {       
                UErrorCode e;

                handle = umsg_open (pattern.ptr, pattern.length, toString(locale.name), null, e);
                testError (e, "failed to open message formatter");
        }

        /***********************************************************************

                Open a message formatter with given pattern and for the 
                given locale.

        ***********************************************************************/

        this (UStringView pattern, ref ULocale locale = ULocale.Default)
        {
                this (pattern.get, locale);
        }

        /***********************************************************************
        
                Release message formatter

        ***********************************************************************/

        ~this ()
        {
                umsg_close (handle);
        }

        /***********************************************************************

                This locale is used for fetching default number or date 
                format information

        ***********************************************************************/

        UMessageFormat setLocale (ref ULocale locale)
        {
                umsg_setLocale (handle, toString(locale.name));
                return this;
        }

        /***********************************************************************

                This locale is used for fetching default number or date 
                format information

        ***********************************************************************/

        UMessageFormat getLocale (ref ULocale locale)
        {
                locale.name = cast(String) toArray (umsg_getLocale (handle));
                return this;
        }

        /***********************************************************************

                Sets the pattern

        ***********************************************************************/

        UMessageFormat setPattern (UStringView pattern)
        {
                UErrorCode e;

                umsg_applyPattern (handle, pattern.get.ptr, pattern.len, null, e);
                testError (e, "failed to set formatter pattern");
                return this;
        }

        /***********************************************************************

                Gets the pattern
                      
        ***********************************************************************/

        UMessageFormat getPattern (UString s)
        {
                uint fmt (wchar* dst, uint length, ref UErrorCode e)
                {
                        return umsg_toPattern (handle, dst, length, e);
                }

                s.format (&fmt, "failed to get formatter pattern");
                return this;
        }

        /***********************************************************************

                This function may perform re-ordering of the arguments 
                depending on the locale. For all numeric arguments, double 
                is assumed unless the type is explicitly integer. All choice 
                format arguments must be of type double.

        ***********************************************************************/

        UMessageFormat format (UString s, Args* list)
        {
                uint fmt (wchar* dst, uint length, ref UErrorCode e)
                {
                        return umsg_vformat (handle, dst, length, list.args.ptr, e);
                }

                s.format (&fmt, "failed to format pattern");
                return this;
        }
        

        /***********************************************************************

                A typesafe list of arguments for the UMessageFormat.format() 
                method. This should be used in the following manner:

                @code
                wchar[] format = "{0} {1, number, currency} {2, number, integer}";
                UMessageFormat msg = new UMessageFormat (format);

                msg.Args args;
                msg.format (output, args.add("abc").add(152.0).add(456));
                @endcode

                Note that the argument order must follow that of the format 
                string, although the format string may dictate the ultimate 
                position of each argument. 

                See http://oss.software.ibm.com/icu/apiref/umsg_8h.html for 
                details on the format string.

                @todo this will likely fail on certain CPU architectures.

        ***********************************************************************/

        struct Args
        {
                private uint[32] args;
                private uint     index;

                /***************************************************************

                ***************************************************************/

                version( D_Version2 ){
                    mixin( "invariant() { invariant_(); }");
                }
                else{
                    mixin( "invariant { invariant_(); }");
                }
                private void invariant_(){
                   assert (index < args.length);
                }

                /***************************************************************

                ***************************************************************/

                Args* reset ()
                {
                        index = 0;
                        version(D_Version2){
                            return &this;
                        } else {
                            return this;
                        }
                }

                /***************************************************************

                ***************************************************************/

                Args* add (UStringView x)
                {
                        args[index] = cast(uint) cast(wchar*) x.get();
                        ++index;
                        version(D_Version2){
                            return &this;
                        } else {
                            return this;
                        }
                }

                /***************************************************************

                ***************************************************************/

                Args* add (wchar[] x)
                {
                        args[index] = cast(uint) cast(wchar*) x;
                        ++index;
                        version(D_Version2){
                            return &this;
                        } else {
                            return this;
                        }
                }

                /***************************************************************

                ***************************************************************/

                Args* add (int x)
                {
                        args[index] = x;
                        ++index;
                        version(D_Version2){
                            return &this;
                        } else {
                            return this;
                        }
                }

                /***************************************************************

                ***************************************************************/

                Args* add (double x)
                {
                        *(cast(double*) &args[index]) = x;
                        index += 2;
                        version(D_Version2){
                            return &this;
                        } else {
                            return this;
                        }
                }
        }


        /***********************************************************************
        
                Bind the ICU functions from a shared library. This is
                complicated by the issues regarding D and DLLs on the
                Windows platform

        ***********************************************************************/

        mixin(genICUNative!("in"
                ,"Handle  function (wchar*, uint, char*, void*, ref UErrorCode)", "umsg_open"
                ,"void    function (Handle)", "umsg_close"
                ,"void    function (Handle, char*)", "umsg_setLocale"
                ,"char*   function (Handle)", "umsg_getLocale"
                ,"uint    function (Handle, wchar*, uint, ref UErrorCode)", "umsg_toPattern"
                ,"void    function (Handle, wchar*, uint, void*, ref UErrorCode)", "umsg_applyPattern"
                ,"uint    function (Handle, wchar*, uint, void*, ref UErrorCode)", "umsg_vformat"
        ));

        /***********************************************************************

        ***********************************************************************/

        //static void test()
        //{
        //        UString output = new UString(100);
        //        wchar[] format = "{0} {1, number, currency} {2, number, integer}";

        //        UMessageFormat msg = new UMessageFormat (format);

        //        msg.Args args;
        //        msg.format (output, args.add("abc").add(152.0).add(456));
        //}
}



