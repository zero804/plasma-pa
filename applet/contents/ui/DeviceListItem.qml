/*
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

import org.kde.plasma.private.volume 0.1

import "../code/icon.js" as Icon

ListItemBase {
    readonly property var currentPort: Ports[ActivePortIndex]
    readonly property var currentActivePortIndex: ActivePortIndex
    readonly property var currentMuted: Muted
    readonly property var activePortIndex: ActivePortIndex
    property bool onlyone: false

    draggable: false
    label: {
        if (currentPort && currentPort.description) {
            if (onlyone || !Description) {
                return currentPort.description;
            } else {
                return i18nc("label of device items", "%1 (%2)", currentPort.description, Description);
            }
        }
        if (Description) {
            return Description;
        }
        if (Name) {
            return Name;
        }
        return i18n("Device name not found");
    }

    onCurrentActivePortIndexChanged: {
        if (type === "sink" && globalMute && !Muted) {
            Muted = true;
        }
    }

    onCurrentMutedChanged: {
        if (type === "sink" && globalMute && !Muted) {
            plasmoid.configuration.globalMuteDevices = [];
            plasmoid.configuration.globalMute = false;
            globalMute = false;
        }
    }
}
