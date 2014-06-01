import QtQuick 2.0
import io.thp.pyotherside 1.2



Python {
    Component.onCompleted: {
        addImportPath(Qt.resolvedUrl(".."));
        importModule("seadevil", function() {
        });
    }
}
