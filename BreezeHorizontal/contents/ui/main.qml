/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2022 Bitblaster <bitblasters@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // for Highlight
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kwin 2.0 as KWin

KWin.Switcher {
    id: tabBox

    readonly property real screenFactor: screenGeometry.width / screenGeometry.height

    currentIndex: thumbnailListView.currentIndex

    PlasmaCore.Dialog {
        id: dialog
        visible: tabBox.visible
        flags: Qt.X11BypassWindowManagerHint
        x: screenGeometry.x
        y: screenGeometry.y + screenGeometry.height - height

        mainItem: PlasmaExtras.ScrollArea {
            id: dialogMainItem
            focus: true
            width: tabBox.screenGeometry.width - dialog.margins.left - dialog.margins.right
            height: tabBox.screenGeometry.height * 0.2 + (__horizontalScrollBar.visible ? __horizontalScrollBar.height : 0)

            LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
            LayoutMirroring.childrenInherit: true

            ListView {
                id: thumbnailListView
                orientation: ListView.Horizontal
                model: tabBox.model
                spacing: PlasmaCore.Units.smallSpacing
                highlightMoveDuration: PlasmaCore.Units.longDuration
                highlightResizeDuration: 0

                Connections {
                    target: tabBox
                    function onCurrentIndexChanged() {
                        thumbnailListView.currentIndex = tabBox.currentIndex;
                        thumbnailListView.positionViewAtIndex(thumbnailListView.currentIndex, ListView.Contain)
                    }
                }

                delegate: MouseArea {
                    width: delegateLayout.width + 2 * delegateLayout.x
                    height: thumbnailListView.height

                    onClicked: {
                        if (tabBox.noModifierGrab) {
                            tabBox.model.activate(index);
                        } else {
                            thumbnailListView.currentIndex = index;
                        }
                    }

                    ColumnLayout {
                        id: delegateLayout
                        anchors.verticalCenter: parent.verticalCenter
                        // anchors.centerIn causes layouting glitches
                        y: parent.y + PlasmaCore.Units.smallSpacing
                        height: parent.height - 2 * PlasmaCore.Units.smallSpacing
                        width: height * tabBox.screenFactor
                        spacing: PlasmaCore.Units.smallSpacing

                        focus: index == thumbnailListView.currentIndex
                        Accessible.name: model.caption
                        Accessible.role: Accessible.Client

                        Item {
                            Layout.fillHeight: true
                            implicitWidth: Math.round(delegateLayout.height * tabBox.screenFactor)

                            KWin.ThumbnailItem {
                                anchors.fill: parent
                                wId: windowId
                            }
                        }

                        RowLayout {
                            spacing: PlasmaCore.Units.smallSpacing
                            Layout.fillHeight: true

                            PlasmaCore.IconItem {
                                Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
                                Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
                                source: model.icon
                                usesPlasmaTheme: false
                            }

                            PlasmaExtras.Heading {
                                Layout.fillWidth: true
                                height: undefined
                                level: 4
                                text: model.caption
                                elide: Text.ElideRight
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                maximumLineCount: 2
                                lineHeight: 0.95
                            }
                        }
                    }
                }

                highlight: PlasmaComponents.Highlight {}
            }

            /*
            * Key navigation on outer item for two reasons:
            * @li we have to Q_EMIT the change signal
            * @li on multiple invocation it does not work on the list view. Focus seems to be lost.
            **/
            Keys.onPressed: {
                if (event.key === Qt.Key_Up) {
                    icons.decrementCurrentIndex();
                } else if (event.key === Qt.Key_Down) {
                    icons.incrementCurrentIndex();
                }
            }
        }
    }
}

