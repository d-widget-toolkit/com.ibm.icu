
module com.ibm.icu.text.MessageFormat;

import java.lang.all;

import com.ibm.icu.mangoicu.UMessageFormat;

public class MessageFormat {

    private UMessageFormat frm;

    public this(String pattern ) {
        frm = new UMessageFormat( pattern.toWCharArray() );
    }

    public static String format(String format, Object[] args) {
        implMissing(__FILE__, __LINE__);
        return null;
    }

    public String format(Object[] objects) {
        implMissing(__FILE__, __LINE__);
        return null;
    }

}


