/*
    SPDX-FileCopyrightText: 2026 AngelOS 11 Project
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation

    Plasma5Support.DataSource {
        id: execSource
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName) {
            disconnectSource(sourceName);
        }
        function runCmd(cmd) {
            connectSource(cmd);
        }
    }

    compactRepresentation: MouseArea {
        id: compactBtn
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        Layout.minimumWidth: row.implicitWidth + Kirigami.Units.largeSpacing * 1.4
        Layout.maximumWidth: Layout.minimumWidth
        Layout.fillHeight: true

        onClicked: root.expanded = !root.expanded

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: 5
            color: compactBtn.containsMouse || root.expanded
                   ? Qt.rgba(1, 1, 1, 0.10)
                   : "transparent"
            border.width: compactBtn.containsMouse || root.expanded ? 1 : 0
            border.color: Qt.rgba(1, 1, 1, 0.14)
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Kirigami.Icon {
                source: "weather-few-clouds"
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }

            ColumnLayout {
                spacing: 0
                PlasmaComponents.Label {
                    text: "Widgets"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
                PlasmaComponents.Label {
                    text: Qt.formatDate(new Date(), "ddd, MMM d")
                    font.pixelSize: 10
                    opacity: 0.75
                }
            }
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: 440
        Layout.preferredHeight: 500
        Layout.minimumWidth: 380
        Layout.minimumHeight: 420

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    spacing: 2
                    PlasmaComponents.Label {
                        text: Qt.formatTime(new Date(), "h:mm AP")
                        font.pixelSize: 22
                        font.weight: Font.Bold
                    }
                    PlasmaComponents.Label {
                        text: Qt.formatDate(new Date(), "dddd, MMMM d, yyyy")
                        font.pixelSize: 12
                        opacity: 0.72
                    }
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents.Button {
                    text: "Settings"
                    icon.name: "configure"
                    onClicked: {
                        execSource.runCmd("systemsettings &");
                        root.expanded = false;
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0.5, 0.5, 0.5, 0.22)
            }

            PlasmaComponents.Label {
                text: "Quick Actions"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                opacity: 0.85
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                Repeater {
                    model: [
                        { title: "File Explorer", sub: "Browse local & network files", icon: "system-file-manager", cmd: "dolphin &" },
                        { title: "Web Browser", sub: "Launch default browser", icon: "internet-web-browser", cmd: "xdg-open https://start.duckduckgo.com &" },
                        { title: "Software Store", sub: "Apps & Flatpak updates", icon: "plasmadiscover", cmd: "plasma-discover &" },
                        { title: "Task Manager", sub: "CPU, RAM & GPU activity", icon: "utilities-system-monitor", cmd: "plasma-systemmonitor &" },
                        { title: "Terminal", sub: "Konsole shell", icon: "utilities-terminal", cmd: "konsole &" },
                        { title: "Snipping Tool", sub: "Capture screen region", icon: "spectacle", cmd: "spectacle -r &" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        radius: 8
                        color: tileArea.containsMouse ? Qt.rgba(0.35, 0.65, 1.0, 0.16) : Qt.rgba(0.5, 0.5, 0.5, 0.10)
                        border.width: 1
                        border.color: tileArea.containsMouse ? Qt.rgba(0.38, 0.80, 1.0, 0.45) : Qt.rgba(0.5, 0.5, 0.5, 0.18)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10
                            Kirigami.Icon {
                                source: modelData.icon
                                Layout.preferredWidth: 26
                                Layout.preferredHeight: 26
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                PlasmaComponents.Label {
                                    text: modelData.title
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                PlasmaComponents.Label {
                                    text: modelData.sub
                                    font.pixelSize: 11
                                    opacity: 0.7
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        MouseArea {
                            id: tileArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                execSource.runCmd(modelData.cmd);
                                root.expanded = false;
                            }
                        }
                    }
                }
            }

            PlasmaComponents.Label {
                text: "Appearance Mode"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                opacity: 0.85
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: "Switch to Dark Mode"
                    icon.name: "weather-clear-night"
                    onClicked: {
                        execSource.runCmd("bash /usr/local/libexec/angelos-apply-layout dark &");
                        root.expanded = false;
                    }
                }
                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: "Switch to Light Mode"
                    icon.name: "weather-clear"
                    onClicked: {
                        execSource.runCmd("bash /usr/local/libexec/angelos-apply-layout light &");
                        root.expanded = false;
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
