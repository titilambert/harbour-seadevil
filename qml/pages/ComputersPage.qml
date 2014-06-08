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
    id: computers_page

    onStatusChanged: {
                      if (status == 1) {
                        py.call('seadevil.load_computers', [], function(result) {
                                            computer_model.clear()
                                            for (var i=0; i<result.length; i++) {
                                                computer_model.append(result[i])
                                            }
                                       })
                        }
                    }
    PageHeader {
        id: title
        title: qsTr("Computer list")
    }

    SilicaListView {
        anchors.top: title.bottom
        id: computer_list
        width: 480; height: 800
        x: Theme.paddingLarge

        model: ListModel {
            id: computer_model
        }

        delegate: ListItem {
            width: ListView.view.width
            height: Theme.itemSizeSmall
            Label {
                text: name + " (" + value + ")"
            }
            onClicked: pageStack.push("ComputerPage.qml", {"name": name, "mac": value})
        }
    }
}
