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
            MenuItem {
                text: qsTr("Computer list")
                onClicked: pageStack.push(Qt.resolvedUrl("ComputersPage.qml"))
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
                            id: repeater_combo
                            model: ListModel { id: computer_model }
                            MenuItem { text: model.name }
                        }
                    }

                    function reload(selected_name) {
                        computer_model.clear()
                        py.call('seadevil.load_computers', [selected_name], function(result) {
                                for (var i=0; i<result.length; i++) {
                                    computer_model.append(result[i])
                                }
                                
                        })
                    }

                    onCurrentIndexChanged: {
                        py.call('seadevil.get_mac', [computer_combo.currentItem.text], function(result) {
                            macaddress_input.text = result
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

                TextField {
                    id: macaddress_input
                    width: 300
                    placeholderText: "XXXXXXXXXXXX"
                    validator: RegExpValidator { regExp: /^((([0-9A-Fa-f]{2}[:-]){5})|(([0-9A-Fa-f]{2}){5}))([0-9A-Fa-f]{2})$/ }
                    color: errorHighlight? "red" : Theme.primaryColor
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                    Component.onCompleted: py.call('seadevil.get_last_mac', [], function(result) {
                                                   computer_combo.reload(result[1])
                                                   macaddress_input.text = result[0]
                                                   })
                }

                Button {
                    id: save_button
                    text: qsTr("Save")

                    onClicked: {
                                   var dialog = pageStack.push("SaveDialog.qml", {"name": macaddress_input.text})
                                   dialog.accepted.connect(function() {
                                        py.call("seadevil.save_computer", [dialog.name, macaddress_input.text], function() {
                                            computer_combo.reload(dialog.name)
                                        });
                                   })
                               }

                }
            }

            Row {
                id: row_wol
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    text: "Wake UP !"
                    onClicked: py.call("seadevil.wake_on_lan", [macaddress_input.text], function() {
                                    py.ready = true;
                               });
                }
            }
        }
    }
}
