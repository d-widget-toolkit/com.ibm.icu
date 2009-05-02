module com.ibm.icu.text.DateFormat;

import java.lang.all;
import java.text.ParsePosition;
import java.util.Date;

import com.ibm.icu.mangoicu.UDateFormat;
import com.ibm.icu.mangoicu.ULocale;
import com.ibm.icu.mangoicu.UTimeZone;

public class DateFormat {

    public static const int LONG   = UDateFormat.Style.Long;
    public static const int FULL   = UDateFormat.Style.Full;
    public static const int SHORT  = UDateFormat.Style.Short;
    public static const int MEDIUM = UDateFormat.Style.Medium;

    private UDateFormat ufmt;
    private this( UDateFormat.Style time ){
        ufmt = new UDateFormat( time, time, ULocale.Default, UTimeZone.Default, null );
    }
    private this( UDateFormat ufmt ){
        this.ufmt = ufmt;
    }

    public static DateFormat getTimeInstance() {
        // FIXME
        return new DateFormat( UDateFormat.Style.Long );
    }

    public static DateFormat getTimeInstance(int s) {
        // FIXME
        return new DateFormat( UDateFormat.Style.Long );
        implMissing(__FILE__, __LINE__);
        return null;
    }

    public static DateFormat getDateInstance() {
        // FIXME
        return new DateFormat( UDateFormat.Style.Long );
        implMissing(__FILE__, __LINE__);
        return null;
    }

    public static DateFormat getDateTimeInstance(int l, int m) {
        // FIXME
        return new DateFormat( UDateFormat.Style.Long );
        implMissing(__FILE__, __LINE__);
        return null;
    }

    public static DateFormat getDateInstance(int dateFormat) {
        // FIXME
        return new DateFormat( UDateFormat.Style.Long );
        implMissing(__FILE__, __LINE__);
        return null;
    }

    public String format(Date date) {
        implMissing(__FILE__, __LINE__);
        return null;
    }

    public String format(Long long2) {
        implMissing(__FILE__, __LINE__);
        return null;
    }

    public Date parse(String str, ParsePosition pos) {
        implMissing(__FILE__, __LINE__);
        return null;
    }

}


