
module com.ibm.icu.text.SimpleDateFormat;
import com.ibm.icu.text.DateFormat;

import com.ibm.icu.mangoicu.UDateFormat;
import com.ibm.icu.mangoicu.ULocale;
import com.ibm.icu.mangoicu.UTimeZone;

import java.lang.all;
public class SimpleDateFormat : DateFormat {

    public this(String string) {
        implMissing(__FILE__, __LINE__);
        super( new UDateFormat(
                    UDateFormat.Style.Default,
                    UDateFormat.Style.Default,
                    ULocale.Default,
                    UTimeZone.Default, null ));
    }

}


