
module com.ibm.icu.text.Collator;
import com.ibm.icu.text.CollationKey;

import java.lang.all;
import java.util.Comparator;
//import java.util.Locale;

public class Collator : Comparator {

    public static Collator getInstance() {
        implMissing(__FILE__, __LINE__);
        return null;
    }

    public int compare(Object label, Object label2) {
        implMissing(__FILE__, __LINE__);
        return 0;
    }

    //FIXME missing API
    //public static Collator getInstance(Locale default1) {
    //    implMissing(__FILE__, __LINE__);
    //    return null;
    //}

    public CollationKey getCollationKey(String attributeValue) {
        implMissing(__FILE__, __LINE__);
        return null;
    }

}


