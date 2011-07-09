/*******************************************************************************

        @file UResourceBundle.d
        
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

module com.ibm.icu.mangoicu.UResourceBundle;

private import  com.ibm.icu.mangoicu.ICU,
                com.ibm.icu.mangoicu.UString;

public  import  com.ibm.icu.mangoicu.ULocale;
private import java.lang.util;

/*******************************************************************************

        API representing a collection of resource information pertaining to 
        a given locale. A resource bundle provides a way of accessing locale- 
        specific information in a data file. You create a resource bundle that 
        manages the resources for a given locale and then ask it for individual 
        resources.

        Resource bundles in ICU4C are currently defined using text files which 
        conform to the following BNF definition. More on resource bundle concepts 
        and syntax can be found in the Users Guide. 

        See <A HREF="http://oss.software.ibm.com/icu/apiref/ures_8h.html">
        this page</A> for full details.

*******************************************************************************/

class UResourceBundle : ICU
{       
        private Handle handle;

        /***********************************************************************
        
                Internals opened up to the public 

        ***********************************************************************/

        // Numeric constants for types of resource items 
        public enum             ResType 
                                {
                                None      = -1,
                                String    = 0,
                                Binary    = 1,
                                Table     = 2,
                                Alias     = 3,
                                Int       = 7,
                                Array     = 8,
                                IntVector = 14
                                }

        /***********************************************************************
        
                private constructor for internal use only

        ***********************************************************************/

        private this (Handle handle)
        {
                this.handle = handle;
        }

        /***********************************************************************

                Constructs a resource bundle for the locale-specific bundle 
                in the specified path.         

                locale  This is the locale this resource bundle is for. To 
                        get resources for the French locale, for example, you 
                        would create a ResourceBundle passing ULocale::FRENCH 
                        for the "locale" parameter, and all subsequent calls 
                        to that resource bundle will return resources that 
                        pertain to the French locale. If the caller passes a 
                        Locale.Default parameter, the default locale for the 
                        system (as returned by ULocale.getDefault()) will be 
                        used. Passing Locale.Root will cause the root-locale
                        to be used.
        
                path    This is a full pathname in the platform-specific
                        format for the directory containing the resource 
                        data files we want to load resources from. We use 
                        locale IDs to generate filenames, and the filenames 
                        have this string prepended to them before being passed 
                        to the C++ I/O functions. Therefore, this string must 
                        always end with a directory delimiter (whatever that 
                        is for the target OS) for this class to work correctly.
                        A null value will open the default ICU data-files

        ***********************************************************************/

        this (ref ULocale locale, char[] path = null)
        {
                UErrorCode e;

                handle = ures_open (toString(path), toString(locale.name), e);
                testError (e, "failed to open resource bundle");
        }

        /***********************************************************************
        
        ***********************************************************************/

        ~this ()
        {
                ures_close (handle);
        }

        /***********************************************************************

                Returns the size of a resource. Size for scalar types is 
                always 1, and for vector/table types is the number of child 
                resources.         

        ***********************************************************************/

        uint getSize ()
        {
                return ures_getSize (handle);
        }

        /***********************************************************************

                Returns a signed integer from a resource. This integer is 
                originally 28 bit and the sign gets propagated.        

        ***********************************************************************/

        int getInt ()
        {
                UErrorCode e;

                int x = ures_getInt (handle, e);
                testError (e, "failed to get resource integer");
                return x;
        }
        
        /***********************************************************************
        
                Returns a string from a string resource type

        ***********************************************************************/

        UStringView getString ()
        {
                UErrorCode e;
                uint  len;

                wchar* x = ures_getString (handle, len, e);
                testError (e, "failed to get resource string");
                return new UStringView (x[0..len]);
        }

        /***********************************************************************

                Returns the string in a given resource at the specified 
                index        

        ***********************************************************************/

        UStringView getString (uint index)
        {
                UErrorCode e;
                uint  len;

                wchar* x = ures_getStringByIndex (handle, index, len, e);
                testError (e, "failed to get resource string");
                return new UStringView (x[0..len]);
        }

        /***********************************************************************
        
                Returns a string in a resource that has a given key. This 
                procedure works only with table resources.

        ***********************************************************************/

        UStringView getString (char[] key)
        {
                UErrorCode e;
                uint  len;

                wchar* x = ures_getStringByKey (handle, toString(key), len, e);
                testError (e, "failed to get resource string");
                return new UStringView (x[0..len]);
        }

        /***********************************************************************
        
                Returns the next string in a resource or NULL if there are 
                no more resources to iterate over

        ***********************************************************************/

        UStringView getNextString ()
        {
                UErrorCode   e;
                uint    len;
                char*   key; 

                wchar* x = ures_getNextString (handle, len, key, e);
                testError (e, "failed to get next resource string");
                return new UStringView (x[0..len]);
        }

        /***********************************************************************
        
                Returns a binary data from a resource. Can be used at most
                primitive resource types (binaries, strings, ints)

        ***********************************************************************/

        void[] getBinary ()
        {
                UErrorCode e;
                uint  len;

                void* x = ures_getBinary (handle, len, e);
                testError (e, "failed to get binary resource");
                return x[0..len];
        }

        /***********************************************************************

                Returns an integer vector from a resource        

        ***********************************************************************/

        int[] getIntVector ()
        {
                UErrorCode e;
                uint  len;

                int* x = ures_getIntVector (handle, len, e);
                testError (e, "failed to get vector resource");
                return x[0..len];
        }

        /***********************************************************************

                Checks whether the resource has another element to 
                iterate over        

        ***********************************************************************/

        bool hasNext ()
        {
                return ures_hasNext (handle) != 0;
        }

        /***********************************************************************

                Resets the internal context of a resource so that 
                iteration starts from the first element        

        ***********************************************************************/

        void resetIterator ()
        {
                ures_resetIterator (handle);
        }

        /***********************************************************************

                Returns the next resource in a given resource or NULL if 
                there are no more resources        

        ***********************************************************************/

        UResourceBundle getNextResource ()
        {
                UErrorCode e;

                return get (ures_getNextResource (handle, null, e), e);
        }

        /***********************************************************************

                Returns a resource that has a given key. This procedure 
                works only with table resources.        

        ***********************************************************************/

        UResourceBundle getResource (char[] key)
        {
                UErrorCode e;

                return get (ures_getByKey (handle, toString(key), null, e), e);
        }

        /***********************************************************************
        
                Returns the resource at the specified index

        ***********************************************************************/

        UResourceBundle getResource (uint index)
        {
                UErrorCode e;

                return get (ures_getByIndex (handle, index, null, e), e);
        }

        /***********************************************************************
        
                Return the version number associated with this ResourceBundle 
                as a UVersionInfo array

        ***********************************************************************/

        void getVersion (ref Version info)
        {
                ures_getVersion (handle, info);
        }

        /***********************************************************************
        
                Return the ULocale associated with this ResourceBundle

        ***********************************************************************/

        void getLocale (ref ULocale locale)
        {
                UErrorCode e;

                locale.name = cast(String) toArray (ures_getLocale (handle, e));
                testError (e, "failed to get resource locale");
        }

        /***********************************************************************

                Returns the key associated with this resource. Not all 
                the resources have a key - only those that are members 
                of a table.        

        ***********************************************************************/

        char[] getKey ()
        {
                return toArray (ures_getKey (handle));
        }

        /***********************************************************************

                Returns the type of a resource. Available types are 
                defined in enum UResType        

        ***********************************************************************/

        ResType getType ()
        {
                return cast(ResType) ures_getType (handle);
        }

        /***********************************************************************
        
                Worker function for constructing internal ResourceBundle
                instances. Returns null when the provided handle is null.

        ***********************************************************************/

        private static final UResourceBundle get (Handle handle, ref UErrorCode e)
        {
                testError (e, "failed to create resource bundle");
                if (handle)
                    return new UResourceBundle (handle);
                return null;
        }


        /***********************************************************************
        
                Bind the ICU functions from a shared library. This is
                complicated by the issues regarding D and DLLs on the
                Windows platform

        ***********************************************************************/

        mixin(genICUNative!("uc"
                ,"Handle  function (char*, char*, ref UErrorCode)", "ures_open"
                ,"void    function (Handle)", "ures_close"
                ,"char*   function (Handle, ref UErrorCode)", "ures_getLocale"
                ,"void    function (Handle, ref Version)", "ures_getVersion"
                ,"uint    function (Handle)", "ures_getSize"
                ,"int     function (Handle, ref UErrorCode)", "ures_getInt"
                ,"wchar*  function (Handle, ref uint, ref UErrorCode)", "ures_getString"
                ,"wchar*  function (Handle, uint, ref uint, ref UErrorCode)", "ures_getStringByIndex"
                ,"wchar*  function (Handle, char*, ref uint, ref UErrorCode)", "ures_getStringByKey"
                ,"void*   function (Handle, ref uint, ref UErrorCode)", "ures_getBinary"
                ,"int*    function (Handle, ref uint, ref UErrorCode)", "ures_getIntVector"
                ,"byte    function (Handle)", "ures_hasNext"
                ,"void    function (Handle)", "ures_resetIterator"
                ,"wchar*  function (Handle, ref uint, ref char*, ref UErrorCode)", "ures_getNextString"
                ,"char*   function (Handle)", "ures_getKey"
                ,"int     function (Handle)", "ures_getType"
                ,"Handle  function (Handle, Handle, ref UErrorCode)", "ures_getNextResource"
                ,"Handle  function (Handle, uint, Handle, ref UErrorCode)", "ures_getByIndex"
                ,"Handle  function (Handle, char*, Handle, ref UErrorCode)", "ures_getByKey"
        ));

        /***********************************************************************

        ***********************************************************************/

        /*static void test()
        {
                UResourceBundle b = new UResourceBundle (ULocale.Default);
                UStringView t = b.getNextString();
                UResourceBundle b1 = b.getNextResource ();
        }*/
}


