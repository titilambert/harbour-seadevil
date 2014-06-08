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
    id: computer_page
    property string name
    property string mac

    RemorsePopup {id: delete_popup}

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: computer_page.width
            spacing: Theme.paddingLarge


            PageHeader {
                id: title
                title: qsTr(name)
            }


            Row {
                id: row_label
                x: Theme.paddingLarge

                Label {
                    id: label
                    text: qsTr("Mac address:")
                }

                TextField {
                    id: macaddress_input
                    width: 300
                    placeholderText: "XXXXXXXXXXXX"
                    text: mac
                    validator: RegExpValidator { regExp: /^((([0-9A-Fa-f]{2}[:-]){5})|(([0-9A-Fa-f]{2}){5}))([0-9A-Fa-f]{2})$/ }
                    color: errorHighlight? "red" : Theme.primaryColor
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                    Component.onCompleted: py.call('seadevil.get_last_mac', [], function(result) {
                                                   computer_combo.reload(result[1])
                                                   macaddress_input.text = result[0]
                                                   })
                }
            }

            Row {
                id: right_cover_row

                TextSwitch {
                    width: column.width
                    id: right_cover_switch
                    text: "Right cover"
                    description: "Set this computer as right cover"
                    onClicked: py.call('seadevil.set_cover', [name, "right"])
                    Component.onCompleted: py.call('seadevil.get_cover', ["right"], function(result) {
                                                    if (result == mac) {
                                                        right_cover_switch.checked = true
                                                    }
                                                   })

                }
            }


            Row {
                id: left_cover_row

                TextSwitch {
                    width: column.width
                    id: left_cover_switch
                    text: "Left cover"
                    description: "Set this computer as left cover"
                    onClicked: py.call('seadevil.set_cover', [name, "left"])
                    Component.onCompleted: py.call('seadevil.get_cover', ["left"], function(result) {
                                                    if (result == mac) {
                                                        left_cover_switch.checked = true
                                                    }
                                                   })
                }
            }

            Row {
                id: delete_row
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    text: "Delete"
                    onClicked: {delete_popup.execute("Deleting", function () {
                                    py.call("seadevil.delete_computer", [name], function(result) {
                                        if (result == true) {
                                            pageStack.pop()
                                        }
                                    })
                                })
                    }
                }
            }
        }
    }
}
