/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2

import org.kde.plasma.private.volume 0.1
import org.kde.kcoreaddons 1.0 as KCoreAddons


ScrollView {
    id: scrollView

    contentHeight: contentItem.height
    clip: true

    Item {
        id: contentItem
        width: scrollView.availableWidth
        height: contentLayout.implicitHeight

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent

            Header {
                Layout.fillWidth: true
                enabled: view.count > 0
                text: i18nd("kcm_pulseaudio", "Device Profiles")
                disabledText: i18ndc("kcm_pulseaudio", "@label", "No Device Profiles Available")
            }

            ListView {
                id: view
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.margins: units.gridUnit / 2
                interactive: false
                spacing: units.smallSpacing * 2
                model: CardModel {}
                delegate: CardListItem {}
            }

            Header {
                Layout.fillWidth: true
                text: i18nd("kcm_pulseaudio", "Advanced Output Configuration")
                visible: moduleManager.settingsSupported
            }

            ModuleManager {
                id: moduleManager
            }

            CheckBox {
                Layout.fillWidth: true
                Layout.topMargin: units.smallSpacing
                Layout.leftMargin: units.gridUnit / 2
                Layout.rightMargin: units.gridUnit / 2
                text: i18nd("kcm_pulseaudio", "Add virtual output device for simultaneous output on all local sound cards")
                checked: moduleManager.combineSinks
                onCheckedChanged: moduleManager.combineSinks = checked;
                enabled: moduleManager.configModuleLoaded
                visible: moduleManager.settingsSupported
            }

            CheckBox {
                Layout.fillWidth: true
                Layout.leftMargin: units.gridUnit / 2
                Layout.rightMargin: units.gridUnit / 2
                text: i18nd("kcm_pulseaudio", "Automatically switch all running streams when a new output becomes available")
                checked: moduleManager.switchOnConnect
                onCheckedChanged: moduleManager.switchOnConnect = checked;
                enabled: moduleManager.configModuleLoaded
                visible: moduleManager.settingsSupported
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                enabled: false
                font.italic: true
                text: i18nd("kcm_pulseaudio", "Requires %1 PulseAudio module", moduleManager.configModuleName)
                visible: moduleManager.settingsSupported && !moduleManager.configModuleLoaded
            }

            Header {
                Layout.fillWidth: true
                text: i18nd("kcm_pulseaudio", "Speaker Placement and Testing")
            }

            RowLayout {
                Layout.margins: units.gridUnit / 2
                visible: sinks.count > 1

                Label {
                    text: i18ndc("kcm_pulseaudio", "@label", "Output:")
                    font.bold: true
                }

                ComboBox {
                    id: sinks

                    property var pulseObject: null

                    Layout.fillWidth: true
                    textRole: "Description"
                    model: SinkModel {
                        onRowsInserted: sinks.updatePulseObject()
                        onRowsRemoved: sinks.updatePulseObject()
                        onDataChanged: sinks.updatePulseObject()
                    }
                    onCurrentIndexChanged: updatePulseObject()
                    onCurrentTextChanged: updatePulseObject()
                    Component.onCompleted: {
                        sinks.currentIndex = 0
                        updatePulseObject()
                    }

                    function updatePulseObject() {
                        Qt.callLater(function() {
                            // When the combobox isn't shown currentIndex is -1, so use 0 in that case
                            pulseObject = model.data(model.index(Math.max(sinks.currentIndex, 0), 0), model.role("PulseObject"));
                        });
                    }
                }
            }

            Grid {
                id: grid
                columns: 3
                spacing: 0
                Layout.fillWidth: true

                Item {
                    width: grid.width/3
                    height: 50

                    Button{
                        text: i18nd("kcm_pulseaudio", "Front Left")
                        anchors.centerIn: parent
                        visible: sinks.pulseObject ? sinks.pulseObject.rawChannels.indexOf("front-left") > -1 : false
                        onClicked: sinks.pulseObject.testChannel("front-left")
                    }
                }
                Item {
                    width: grid.width/3
                    height: 50

                    Button{
                        text: i18nd("kcm_pulseaudio", "Front Center")
                        anchors.centerIn: parent
                        visible: sinks.pulseObject ? sinks.pulseObject.rawChannels.indexOf("front-center") > -1 : false
                        onClicked: sinks.pulseObject.testChannel("front-center")
                    }
                }
                Item {
                    width: grid.width/3
                    height: 50

                    Button{
                        text: i18nd("kcm_pulseaudio", "Front Right")
                        anchors.centerIn: parent
                        visible: sinks.pulseObject ? sinks.pulseObject.rawChannels.indexOf("front-right") > -1 : false
                        onClicked: sinks.pulseObject.testChannel("front-right")
                    }
                }
                Item {
                    width: grid.width/3
                    height: 50

                    Button{
                        text: i18nd("kcm_pulseaudio", "Side Left")
                        anchors.centerIn: parent
                        visible: sinks.pulseObject ? sinks.pulseObject.rawChannels.indexOf("side-left") > -1 : false
                        onClicked: sinks.pulseObject.testChannel("side-left")

                    }
                }
                Item {
                    width: grid.width/3
                    height: 50

                    KCoreAddons.KUser {
                        id: kuser
                    }

                    Image {
                        source: kuser.faceIconUrl
                        anchors.centerIn: parent
                        sourceSize.width: 50
                        sourceSize.height: 50
                    }
                }
                Item {
                    width: grid.width/3
                    height: 50
                    Button{
                        text: i18nd("kcm_pulseaudio", "Side Right")
                        anchors.centerIn: parent
                        visible: sinks.pulseObject ? sinks.pulseObject.rawChannels.indexOf("side-right") > -1 : false
                        onClicked: sinks.pulseObject.testChannel("side-right")
                    }
                }
                Item {
                    width: grid.width/3
                    height: 50
                    Button{
                        text: i18nd("kcm_pulseaudio", "Rear Left")
                        anchors.centerIn: parent
                        visible: sinks.pulseObject ? sinks.pulseObject.rawChannels.indexOf("rear-left") > -1 : false
                        onClicked: sinks.pulseObject.testChannel("rear-left")
                    }
                }
                Item {
                    width: grid.width/3
                    height: 50
                    Button{
                        text: i18nd("kcm_pulseaudio", "Subwoofer")
                        anchors.centerIn: parent
                        visible: sinks.pulseObject ? sinks.pulseObject.rawChannels.indexOf("lfe") > -1 : false
                        onClicked: sinks.pulseObject.testChannel("subwoofer")
                    }
                }
                Item {
                    width: grid.width/3
                    height: 50
                    Button{
                        text: i18nd("kcm_pulseaudio", "Rear Right")
                        anchors.centerIn: parent
                        visible: sinks.pulseObject ? sinks.pulseObject.rawChannels.indexOf("rear-right") > -1 : false
                        onClicked: sinks.pulseObject.testChannel("rear-right")
                    }
                }
            }
        }
    }
}
