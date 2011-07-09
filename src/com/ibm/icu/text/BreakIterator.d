
module com.ibm.icu.text.BreakIterator;

import com.ibm.icu.mangoicu.UBreakIterator;
version(Tango) import tango.core.Thread;

import java.lang.all;
import java.text.CharacterIterator;

public class BreakIterator {

    public static const int DONE = UBreakIterator.DONE;
    public static const int Done = UBreakIterator.DONE;

    private UBreakIterator it;
    version(Tango){
        private static tango.core.Thread.ThreadLocal!(BreakIterator) instLine, instWord;
    } else { // Phobos
        private static BreakIterator instLine, instWord; //in tls
    }

    private this( UBreakIterator it ){
        this.it = it;
    }
    public static BreakIterator getLineInstance() {
        version(Tango){
            auto res = instLine.val();
            if( res is null ){
                res = new BreakIterator(
                    UBreakIterator.openLineIterator( ULocale.Default ));
                instLine.val( res );
            }
            return res;
        } else { // Phobos
            if( instLine is null ){
                instLine = new BreakIterator(
                    UBreakIterator.openLineIterator( ULocale.Default ));
            }
            return instLine;
        }
    }

    public void setText(String line) {
        it.setText(Unqual(line));
    }

    public int following(int currOffset) {
        return it.following(currOffset);
    }

    public int next() {
        return it.next();
    }

    public static BreakIterator getWordInstance() {
        version(Tango){
            auto res = instWord.val();
            if( res is null ){
                res = new BreakIterator(
                    UBreakIterator.openWordIterator( ULocale.Default ));
                instWord.val( res );
            }
            return res;
        } else { // Phobos
            if( instWord is null ){
                instWord = new BreakIterator(
                    UBreakIterator.openLineIterator( ULocale.Default ));
            }
            return instWord;
        }
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


