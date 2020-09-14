/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2019 Sefa Eyeoglu <contact@scrumplex.net>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0

import org.kde.kcm 1.0
import org.kde.plasma.core 2.0 as PlasmaCore /* for units.gridUnit */
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.private.volume 0.1

Kirigami.Page {
    title: kcm.name
    property QtObject paSinkModel: SinkModel { }
    property QtObject paSourceModel: SourceModel { }
    property int maxVolumeValue: PulseAudio.NormalVolume // the applet supports changing this value. We will just assume 65536 (100%)
    ConfigModule.quickHelp: i18nd("kcm_pulseaudio", "This module allows configuring the Pulseaudio sound subsystem.")
    implicitHeight: Kirigami.Units.gridUnit * 28
    implicitWidth: Kirigami.Units.gridUnit * 28

    // TODO: replace this TabBar-plus-Frame-in-a-ColumnLayout with whatever shakes
    // out of https://bugs.kde.org/show_bug.cgi?id=394296
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: tabView

            // Tab styles generally assume that they're touching the inner layout,
            // not the frame, so we need to move the tab bar down a pixel and make
            // sure it's drawn on top of the frame
            Layout.bottomMargin: -1
            z: 1

            TabButton {
                text: i18ndc("kcm_pulseaudio", "@title:tab", "Devices")
            }
            TabButton {
                text: i18ndc("kcm_pulseaudio", "@title:tab", "Applications")
            }
            TabButton {
                text: i18ndc("kcm_pulseaudio", "@title:tab", "Advanced")
            }
        }
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackLayout {
                anchors.fill: parent
                anchors.margins: -Kirigami.Units.smallSpacing

                currentIndex: tabView.currentIndex

                Devices {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Applications {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Advanced {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
