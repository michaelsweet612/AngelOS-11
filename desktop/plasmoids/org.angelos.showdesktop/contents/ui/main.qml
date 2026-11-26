/*
    SPDX-FileCopyrightText: 2026 AngelOS 11 Project
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

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
        function toggleDesktop() {
            connectSource("qdbus6 org.kde.KWin /KWin org.kde.KWin.showDesktop $(qdbus6 org.kde.KWin /KWin org.kde.KWin.showingDesktop | grep -q true && echo false || echo true) || gdbus call --session --dest org.kde.plasmashell --object-path /PlasmaShell --method org.kde.PlasmaShell.evaluateScript 'desktops().forEach(function(){})'");
        }
    }

    fullRepresentation: MouseArea {
        id: sliver
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        Layout.minimumWidth: 8
        Layout.preferredWidth: 8
        Layout.maximumWidth: 10
        Layout.fillHeight: true

        onClicked: {
            execSource.connectSource("gdbus call --session --dest org.kde.kglobalaccel --object-path /component/kwin --method org.kde.kglobalaccel.Component.invokeShortcut 'Show Desktop' >/dev/null 2>&1");
        }

        Rectangle {
            width: 1
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            color: sliver.containsMouse ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(0.5, 0.5, 0.5, 0.25)
        }

        Rectangle {
            anchors.fill: parent
            color: sliver.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
        }
    }
}
