package Utils;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by IntelliJ IDEA.
 * User: wliu
 * Date: 7/18/11
 * Time: 10:38 AM
 * To change this template use File | Settings | File Templates.
 */
public class DiagramGroup {

    private String _docString;

    public void set_docString(String _docString) {
        this._docString = _docString;
        parseDocString();
    }

    private void parseDocString() {
        if (_docString == null || _docString.length() == 0) return;
        parseTitleLabel();
    }

    private void parseTitleLabel() {
        Pattern p = Pattern.compile("<diagramGroups label=\"(.*)\">");
        Matcher m = p.matcher(_docString);
        if (m.find()) {
            _titleLabel = m.group(1);
        };
    }

    private String _titleLabel;

    public String get_titleLabel() {
        return _titleLabel;
    }

    public DiagramGroup(String doc_string) {
        set_docString(doc_string);
    }

}
