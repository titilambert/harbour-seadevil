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
    id: page

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge


                PageHeader {
                    id: title
                    title: qsTr("SeaDevil")
                }


            Row {
                id: row_combo

                ComboBox {
                    id: computer_combo
                    width: 480
                    label: qsTr("Select a computer:")

                    menu: ContextMenu {
                        Repeater { 
                            model: ListModel { id: computer_model }
                            MenuItem { text: model.name }
                        }
                    }
                    Component.onCompleted: {
                            reload()
                    }
                    function reload() {
                        computer_model.clear()
                        py.call('seadevil.load_computers', [], function(result) {
                                for (var i=0; i<result.length; i++) {
                                    computer_model.append(result[i])
                                }
                        })
                    }
                    onCurrentIndexChanged: {
                        py.call('seadevil.get_mac', [computer_combo.currentItem.text], function(result) {
                            macaddress.text = result
                        })
                    }
                }

            }

            Row {
                id: row_label
                x: Theme.paddingLarge

                Label {
                    id: label
                    text: qsTr("Or type a mac address here:")
                }
            }

            Row {
                id: row_macaddress
                //width: page.width
                //anchors.top: row_label.bottom


                TextField {
                    id: macaddress
                    width: 300
                    //anchors.top: row_macaddress.top
                    //anchors.top: row_macaddress.top
                    placeholderText: "xx:xx:xx:xx:xx:xx"
                    validator: RegExpValidator { regExp: /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/ }
                    color: errorHighlight? "red" : Theme.primaryColor
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                }

                Button {
                    id: save_button
                    text: qsTr("Save")

                    onClicked: {
                                   var dialog = pageStack.push("SaveDialog.qml", {"name": macaddress.text})
                                   dialog.accepted.connect(function() {
                                        py.call("seadevil.save_computer", [dialog.name, macaddress.text], function() {
                                            computer_combo.reload()
                                        });
                                   })
                               }


                }
            }

            Row {
                id: row_wol
                //width: page.width
                //anchors.top: row_macaddress.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    /*anchors { horizontalCenter: row_wol.horizontalCenter
                              top: row_macaddress.bottom
                    }*/
                    //anchors.bottom: macaddress.bottom
                    //anchors.centerIn: row_wol
                    text: "Wake UP !"
                    onClicked: py.call("seadevil.wake_on_lan", [macaddress.text], function() {
                                    py.ready = true;
                               });
                }
            }

        }
    }
}


