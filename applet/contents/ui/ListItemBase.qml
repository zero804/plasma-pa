/*
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>
    Copyright 2019 Sefa Eyeoglu <contact@scrumplex.net>

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

import QtQuick 2.4
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents // for contextMenu and ListItem
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.draganddrop 2.0 as DragAndDrop
import org.kde.plasma.private.volume 0.1

import "../code/icon.js" as Icon

PlasmaComponents.ListItem {
    id: item

    property alias label: defaultButton.text
    property alias draggable: dragArea.enabled
    property alias icon: clientIcon.source
    property alias iconUsesPlasmaTheme: clientIcon.usesPlasmaTheme
    property string type

    checked: dropArea.containsDrag
    opacity: (draggedStream && draggedStream.deviceIndex == Index) ? 0.3 : 1.0
    separatorVisible: false

    ListView.delayRemove: dragArea.dragActive

    Item {
        width: parent.width
        height: column.height

        RowLayout {
            id: controlsRow
            spacing: PlasmaCore.Units.smallSpacing
            anchors.left: parent.left
            anchors.right: parent.right

            PlasmaCore.IconItem {
                id: clientIcon
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredHeight: column.height * 0.75
                Layout.preferredWidth: Layout.preferredHeight
                source: "unknown"
                visible: type === "sink-input" || type === "source-input"

                onSourceChanged: {
                    if (!valid && source != "unknown") {
                        source = "unknown";
                    }
                }

                DragAndDrop.DragArea {
                    id: dragArea
                    anchors.fill: parent
                    delegate: parent

                    mimeData {
                        source: item
                    }

                    onDragStarted: {
                        draggedStream = PulseObject;
                        beginMoveStream(type == "sink-input" ? "sink" : "source");
                    }

                    onDrop: {
                        draggedStream = null;
                        endMoveStream();
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: dragArea.enabled ? (pressed && pressedButtons === Qt.LeftButton ? Qt.ClosedHandCursor : Qt.OpenHandCursor) : undefined
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        onClicked: {
                            if (mouse.button === Qt.MiddleButton) {
                                Muted = !Muted;
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                id: column
                spacing: 0

                RowLayout {
                    Layout.minimumHeight: contextMenuButton.implicitHeight

                    PlasmaComponents3.RadioButton {
                        id: defaultButton
                        // Maximum width of the button need to match the text. Empty area must not change the default device.
                        Layout.maximumWidth: controlsRow.width - Layout.leftMargin - Layout.rightMargin
                                              - (contextMenuButton.visible ? contextMenuButton.implicitWidth + PlasmaCore.Units.smallSpacing * 2 : 0)
                        Layout.leftMargin: LayoutMirroring.enabled ? 0 : Math.round((muteButton.width - defaultButton.indicator.width) / 2)
                        Layout.rightMargin: LayoutMirroring.enabled ? Math.round((muteButton.width - defaultButton.indicator.width) / 2) : 0
                        spacing: PlasmaCore.Units.smallSpacing + Math.round((muteButton.width - defaultButton.indicator.width) / 2)
                        checked: PulseObject.default ? PulseObject.default : false
                        visible: (type == "sink" && sinkView.model.count > 1) || (type == "source" && sourceView.model.count > 1)
                        onClicked: PulseObject.default = true;
                    }

                    PlasmaComponents3.Label {
                        id: soloLabel
                        Layout.fillWidth: true
                        text: defaultButton.text
                        visible: !defaultButton.visible
                        elide: Text.ElideRight
                    }

                    Item {
                        Layout.fillWidth: true
                        visible: contextMenuButton.visible
                    }

                    SmallToolButton {
                        id: contextMenuButton
                        icon.name: "application-menu"
                        checkable: true
                        onClicked: {
                            contextMenu.visualParent = this;
                            contextMenu.showRelative();
                        }
                        visible: {
                            // if it is a sink type and there are at least two sink devices. Same for source type.
                            if (((type == "sink-input" || type == "sink") && sinkView.model.count > 1)
                                || ((type == "source-input" || type == "source") && sourceView.model.count > 1)) {
                                return true;
                            } else if (PulseObject.ports && PulseObject.ports.length > 1) {
                                // In case an unavailable port is active.
                                if (PulseObject.ports[PulseObject.activePortIndex].availability == Port.Unavailable) {
                                    return true;
                                }
                                // If there are at least two available ports.
                                var foundFirstAvailablePort = false;
                                for (var i = 0; i < PulseObject.ports.length; i++) {
                                    if (PulseObject.ports[i].availability != Port.Unavailable) {
                                        if (foundFirstAvailablePort) {
                                            return true;
                                        } else {
                                            foundFirstAvailablePort = true;
                                        }
                                    }
                                }
                            }
                            return false;
                        }
                        PlasmaComponents3.ToolTip {
                            text: i18n("Show additional options for %1", defaultButton.text)
                        }
                    }
                }

                RowLayout {
                    SmallToolButton {
                        id: muteButton
                        readonly property bool isPlayback: type.substring(0, 4) == "sink"
                        icon.name: Icon.name(Volume, Muted, isPlayback ? "audio-volume" : "microphone-sensitivity")
                        onClicked: Muted = !Muted
                        checked: Muted

                        PlasmaComponents3.ToolTip {
                            text: i18n("Mute %1", defaultButton.text)
                        }
                    }

                    PlasmaComponents3.Slider {
                        id: slider

                        // Helper properties to allow async slider updates.
                        // While we are sliding we must not react to value updates
                        // as otherwise we can easily end up in a loop where value
                        // changes trigger volume changes trigger value changes.
                        property int volume: Volume
                        property bool ignoreValueChange: true
                        readonly property bool forceRaiseMaxVolume: (raiseMaximumVolumeCheckbox.checked && (type === "sink" || type === "source"))
                                                                    || volume >= PulseAudio.NormalVolume * 1.01

                        Layout.fillWidth: true
                        from: PulseAudio.MinimalVolume
                        to: forceRaiseMaxVolume ? PulseAudio.MaximalVolume : PulseAudio.NormalVolume
                        stepSize: to / (to / PulseAudio.NormalVolume * 100.0)
                        visible: HasVolume
                        enabled: VolumeWritable
                        opacity: Muted ? 0.5 : 1

                        Accessible.name: i18nc("Accessibility data on volume slider", "Adjust volume for %1", defaultButton.text)

                        background:  PlasmaCore.FrameSvgItem {
                            imagePath: "widgets/slider"
                            prefix: "groove"
                            width: parent.availableWidth
                            height: margins.top + margins.bottom
                            anchors.centerIn: parent
                            scale: parent.mirrored ? -1 : 1

                            PlasmaCore.FrameSvgItem {
                                imagePath: "widgets/slider"
                                prefix: "groove-highlight"
                                anchors.left: parent.left
                                y: (parent.height - height) / 2
                                width: Math.max(margins.left + margins.right, slider.handle.x * meter.volume)
                                height: Math.max(margins.top + margins.bottom, parent.height)
                                opacity: meter.available && (meter.volume > 0 || animation.running)
                                VolumeMonitor {
                                    id: meter
                                    target: parent.visible ? PulseObject : null
                                }
                                Behavior on width {
                                    NumberAnimation  {
                                        id: animation
                                        duration: PlasmaCore.Units.shortDuration
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }
                        }

                        Component.onCompleted: {
                            ignoreValueChange = false;
                        }

                        onVolumeChanged: {
                            var oldIgnoreValueChange = ignoreValueChange;
                            ignoreValueChange = true;
                            value = Volume;
                            ignoreValueChange = oldIgnoreValueChange;
                        }

                        onValueChanged: {
                            if (!ignoreValueChange) {
                                Volume = value;
                                Muted = value == 0;

                                if (!pressed) {
                                    updateTimer.restart();
                                }
                            }
                        }

                        onPressedChanged: {
                            if (!pressed) {
                                // Make sure to sync the volume once the button was
                                // released.
                                // Otherwise it might be that the slider is at v10
                                // whereas PA rejected the volume change and is
                                // still at v15 (e.g.).
                                updateTimer.restart();

                                if (type == "sink") {
                                    playFeedback(Index);
                                }
                            }
                        }

                        Timer {
                            id: updateTimer
                            interval: 200
                            onTriggered: slider.value = Volume
                        }
                    }
                    PlasmaComponents3.Label {
                        id: percentText
                        readonly property real value: PulseObject.volume > slider.to ? PulseObject.volume : slider.value
                        readonly property real displayValue: Math.round(value / PulseAudio.NormalVolume * 100.0)
                        Layout.alignment: Qt.AlignHCenter
                        Layout.minimumWidth: percentMetrics.advanceWidth
                        horizontalAlignment: Qt.AlignRight
                        text: i18nc("volume percentage", "%1%", displayValue)
                        // Display a subtle visual indication that the volume
                        // might be dangerously high
                        // ------------------------------------------------
                        // Keep this in sync with the copies in VolumeSlider.qml
                        // and plasma-workspace:OSDItem.qml
                        color: {
                            if (displayValue <= 100) {
                                return theme.textColor
                            } else if (displayValue > 100 && displayValue <= 125) {
                                return theme.neutralTextColor
                            } else {
                                return theme.negativeTextColor
                            }
                        }
                    }

                    TextMetrics {
                        id: percentMetrics
                        font: percentText.font
                        text: i18nc("only used for sizing, should be widest possible string", "100%")
                    }
                }
            }
        }

        DragAndDrop.DropArea {
            id: dropArea
            anchors.fill: parent
            enabled: draggedStream

            onDragEnter: {
                if (draggedStream.deviceIndex == Index) {
                    event.ignore();
                }
            }

            onDrop: {
                draggedStream.deviceIndex = Index;
            }
        }

        MouseArea {
            anchors {
                fill: parent
                leftMargin: clientIcon.width
            }
            acceptedButtons: Qt.MiddleButton | Qt.RightButton
            onPressed: {
                if (mouse.button === Qt.RightButton) {
                    contextMenu.visualParent = this;
                    contextMenu.show(mouse.x, mouse.y);
                }
            }
            onClicked: {
                if (mouse.button === Qt.MiddleButton) {
                    Muted = !Muted;
                }
            }
        }
    }

    PlasmaComponents.ContextMenu {
        id: contextMenu

        placement: PlasmaCore.Types.BottomPosedLeftAlignedPopup

        onStatusChanged: {
            if (status == PlasmaComponents.DialogStatus.Closed) {
                contextMenuButton.checked = false;
            }
        }

        function newMenuItem() {
            return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem {}", contextMenu);
        }

        function loadDynamicActions() {
            contextMenu.clearMenuItems();

            // Switch all streams of the relevant kind to this device
            if (type == "source" && sourceView.model.count > 1) {
                menuItem = newMenuItem();
                menuItem.text = i18n("Record all audio via this device");
                menuItem.icon = "mic-on" // or "mic-ready" // or "audio-input-microphone-symbolic"
                menuItem.clicked.connect(function() {
                    PulseObject.switchStreams();
                });
                contextMenu.addMenuItem(menuItem);
            } else if (type == "sink" && sinkView.model.count > 1) {
                menuItem = newMenuItem();
                menuItem.text = i18n("Play all audio via this device");
                menuItem.icon = "audio-on" // or "audio-ready" // or "audio-speakers-symbolic"
                menuItem.clicked.connect(function() {
                    PulseObject.switchStreams();
                });
                contextMenu.addMenuItem(menuItem);
            }

            // Ports
            // Intentionally only shown when there are at least two ports.
            if (PulseObject.ports && PulseObject.ports.length > 1) {
                var menuItem = newMenuItem();
                menuItem.text = i18nc("Heading for a list of ports of a device (for example built-in laptop speakers or a plug for headphones)", "Ports");
                menuItem.section = true;
                contextMenu.addMenuItem(menuItem);

                var setActivePort = function(portIndex) {
                    return function() {
                        PulseObject.activePortIndex = portIndex;
                    };
                };

                // If an unavailable port is active, show all the ports.
                if (PulseObject.ports[PulseObject.activePortIndex].availability == Port.Unavailable) {
                    for (var i = 0; i < PulseObject.ports.length; i++) {
                        var port = PulseObject.ports[i];
                        var menuItem = newMenuItem();
                        if (port.availability == Port.Unavailable) {
                            if (port.name == "analog-output-speaker" || port.name == "analog-input-microphone-internal") {
                                menuItem.text = i18nc("Port is unavailable", "%1 (unavailable)", port.description);
                            } else {
                                menuItem.text = i18nc("Port is unplugged", "%1 (unplugged)", port.description);
                            }
                        } else {
                            menuItem.text = port.description;
                        }
                        menuItem.checkable = true;
                        menuItem.checked = i === PulseObject.activePortIndex;
                        menuItem.clicked.connect(setActivePort(i));
                        contextMenu.addMenuItem(menuItem);
                    }
                } else { // Hide ports that are unavailable and only show if there are at least two available
                    var menuItemsPorts = [];
                    var availablePorts = 0;
                    for (var i = 0; i < PulseObject.ports.length; i++) {
                        var port = PulseObject.ports[i];
                        if (port.availability != Port.Unavailable) {
                            menuItemsPorts[availablePorts] = newMenuItem();
                            menuItemsPorts[availablePorts].text = port.description;
                            menuItemsPorts[availablePorts].checkable = true;
                            menuItemsPorts[availablePorts].checked = i === PulseObject.activePortIndex;
                            menuItemsPorts[availablePorts].clicked.connect(setActivePort(i));
                            contextMenu.addMenuItem(menuItemsPorts[availablePorts]);
                            availablePorts++;
                        }
                    }

                    if (availablePorts <= 1){
                        menuItem.visible = false;
                        for (var i = 0; i < availablePorts; i++) {
                            menuItemsPorts[i].visible = false;
                        }
                    }
                }
            }

            // Choose output / input device
            // Intentionally only shown when there are at least two options
            if ((type == "sink-input" && sinkView.model.count > 1) || (type == "source-input" && sourceView.model.count > 1)) {
                var menuItem = newMenuItem();
                if (type == "sink-input") {
                    menuItem.text = i18nc("Heading for a list of possible output devices (speakers, headphones, ...) to choose", "Play audio using");
                } else {
                    menuItem.text = i18nc("Heading for a list of possible input devices (built-in microphone, headset, ...) to choose", "Record audio using");
                }
                menuItem.section = true;
                contextMenu.addMenuItem(menuItem);
                var sModel = type == "sink-input" ? sinkView.model : sourceView.model;
                for (var i = 0; i < sModel.count; ++i) {
                    const modelIndex = sModel.index(i, 0)
                    const index = sModel.data(modelIndex, sModel.role("Index"))
                    var menuItem = newMenuItem();
                    menuItem.text = sModel.data(modelIndex, sModel.role("Description"));
                    menuItem.enabled = true;
                    menuItem.checkable = true;
                    menuItem.checked = index === PulseObject.deviceIndex;
                    var setActiveSink = function(sinkIndex) {
                        return function() {
                            PulseObject.deviceIndex = sinkIndex;
                        };
                    };
                    menuItem.clicked.connect(setActiveSink(index));
                    contextMenu.addMenuItem(menuItem);
                }
            }
        }

        function show(x, y) {
            loadDynamicActions();
            open(x, y);
        }

        function showRelative(){
            loadDynamicActions();
            openRelative();
        }
    }
}
