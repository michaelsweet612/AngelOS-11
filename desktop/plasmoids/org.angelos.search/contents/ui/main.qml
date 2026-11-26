/*
    SPDX-FileCopyrightText: 2026 AngelOS 11 Project
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    Plasma5Support.DataSource {
        id: execSource
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName) {
            disconnectSource(sourceName);
        }
    }

    fullRepresentation: MouseArea {
        id: searchPill
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor

        Layout.minimumWidth: 165
        Layout.preferredWidth: 185
        Layout.maximumWidth: 210
        Layout.fillHeight: true

        onClicked: {
            execSource.connectSource("gdbus call --session --dest org.kde.PlasmaShell --object-path /PlasmaShell --method org.kde.PlasmaShell.activateLauncherMenu >/dev/null 2>&1 || gdbus call --session --dest org.kde.krunner --object-path /App --method org.kde.krunner.App.display >/dev/null 2>&1");
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 7
            anchors.bottomMargin: 7
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            radius: height / 2
            color: searchPill.containsMouse
                   ? Qt.rgba(0.55, 0.58, 0.65, 0.28)
                   : Qt.rgba(0.50, 0.53, 0.60, 0.18)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.14)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Kirigami.Icon {
                    source: "search"
                    Layout.preferredWidth: 15
                    Layout.preferredHeight: 15
                }

                PlasmaComponents.Label {
                    text: "Search"
                    font.pixelSize: 12
                    opacity: 0.85
                    Layout.fillWidth: true
                }
            }
        }
    }
}
