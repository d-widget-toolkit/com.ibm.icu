module com.ibm.icu.util.Calendar;

import java.lang.all;

import com.ibm.icu.mangoicu.UCalendar;

public class Calendar {

    public static const int YEAR = UCalendar.DateFields.Year;

    private UCalendar cal;

    private this(){
        cal = new UCalendar( UTimeZone.Default, ULocale.Default );
    }
    public static Calendar getInstance() {
        return new Calendar();
    }

    public int get(int fld) {
        return cal.get(cast(UCalendar.DateFields)fld);
    }

}
