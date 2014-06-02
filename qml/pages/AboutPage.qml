/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Thibault Cohen
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.2


Page {
    id: aboutpage
    property string version: ''
    forwardNavigation: false

    SilicaFlickable {
        anchors.fill: parent


        Column {
            id: column

            width: aboutpage.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: title
                title: qsTr("About SeaDevil")
            }

            Row {
                id: row_logo
                x: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: image
                    source: "../../data/harbour-seadevil.png"
                }
            }

            Row {
                id: row_title
                x: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter

                Label {
                    text: qsTr("SeaDevil version: " + aboutpage.version)
                }
            }

            Row {
                x: Theme.paddingLarge

                Label {
                    font.pixelSize: 32
                    text: qsTr("Author:")
                }
            }

            Row {
                x: 50

                Label {
                    font.pixelSize: 24
                    text: qsTr("Thibault Cohen")
                }
            }

            Row {
                x: Theme.paddingLarge

                Label {
                    font.pixelSize: 32
                    text: qsTr("Sources:")
                }
            }

            Row {
                x: 50

                Label {
                    font.pixelSize: 24
                    text: qsTr("https://github.com/titilambert/harbour-seadevil")
                }
            }

            Row {
                x: Theme.paddingLarge

                Label {
                    font.pixelSize: 32
                    text: qsTr("Thanks:")
                }
            }

            Row {
                x: 50

                Label {
                    font.pixelSize: 24
                    text: qsTr("Doudounette")
                }
            }

        }
    }

    Python {
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl(".."));
            importModule('seadevil', function() {
                aboutpage.version = evaluate('seadevil.__version__');
            });
        }
    }

}
