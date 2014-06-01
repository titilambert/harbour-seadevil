/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
                text: qsTr("Show Page 2")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
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
                    placeholderText: "XXXXXXXXXXXX"
                    validator: RegExpValidator { regExp: /^((([0-9A-Fa-f]{2}[:-]){5})|(([0-9A-Fa-f]{2}){5}))([0-9A-Fa-f]{2})$/ }
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


