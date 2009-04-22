
module com.ibm.icu.text.BreakIterator;

import com.ibm.icu.mangoicu.UBreakIterator;
import tango.core.Thread;

import java.lang.all;
import java.text.CharacterIterator;

public class BreakIterator {

    public static const int DONE = UBreakIterator.DONE;
    public static const int Done = UBreakIterator.DONE;

    private UBreakIterator it;
    private static tango.core.Thread.ThreadLocal!(BreakIterator) instLine;
    private static tango.core.Thread.ThreadLocal!(BreakIterator) instWord;

    private this( UBreakIterator it ){
        this.it = it;
    }
    public static BreakIterator getLineInstance() {
        auto res = instLine.val();
        if( res is null ){
            res = new BreakIterator(
                UBreakIterator.openLineIterator( ULocale.Default ));
            instLine.val( res );
        }
        return res;
    }

    public void setText(String line) {
        it.setText(line);
    }

    public int following(int currOffset) {
        return it.following(currOffset);
    }

    public int next() {
        return it.next();
    }

    public static BreakIterator getWordInstance() {
        auto res = instWord.val();
        if( res is null ){
            res = new BreakIterator(
                UBreakIterator.openWordIterator( ULocale.Default ));
            instWord.val( res );
        }
        return res;
    }

    public int preceding(int position) {
        return it.previous(position);
    }

    public void setText(CharacterIterator docIter) {
        implMissing(__FILE__, __LINE__);
    }

    public bool isBoundary(int position) {
        return it.isBoundary(position);
    }

    public int first() {
        return it.first();
    }

}


