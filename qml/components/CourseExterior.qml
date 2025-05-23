/*    This file is part of Memento.
 *
 *    Memento is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Memento is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Memento.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12

Item {
    property int marginBase: 10

    width: root.width
    height: courseExteriorDelegate.height + marginBase * 2

    function plantAction()
    {
        if (globalBackend.loadSeedbox(directory))
        {
            var levelVariables = globalBackend.getFirstIncompleteLevel(directory)
            if (Object.keys(levelVariables).length !== 0)
            {
                mainToolbarTitle.text = title
                rootStackView.push("qrc:/LearningLevelView.qml", levelVariables)
            }
            else
                showPassiveNotification("This course is already completed")
        }
        else
            showPassiveNotification("Error course corrupted")
    }

    function waterAction()
    {
        if (globalBackend.loadSeedbox(directory))
        {
            var wateringData = globalBackend.getCourseWideWateringItems(directory, userSettings["maxWateringItems"])
            if (Object.keys(wateringData).length !== 0)
                    rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": directory, "testingContentOriginal": wateringData["testingContentOriginal"],
                        "actionType": "water", "manualReview": wateringData["manualReview"], "totalWateringItems": wateringData["totalItems"]})
            else
                showPassiveNotification("This course has no planted items")
        }
        else
             showPassiveNotification("Error course corrupted")
    }

    RowLayout {
        id: courseExteriorDelegate
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: marginBase
        anchors.rightMargin: marginBase

        Image {
            id: courseImage
            source: "file:/" + icon
            Layout.maximumHeight: 120
            Layout.preferredWidth: height
            Layout.topMargin: marginBase
            onStatusChanged: {
                if (status === Image.Error)
                {
                    source = "assets/icons/icon.svg"
                }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: parent.width - courseImage.width
            spacing: 5

            Label {
                text: title
                font.pointSize: userSettings["defaultFontSize"]
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.topMargin: marginBase
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: planted + " / " + items + " " + plantIcon + " | " + water + " " + waterIcon + " " + difficult + " " + difficultIcon
                font.pointSize: userSettings["defaultFontSize"]
                font.family: "Icons"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            ProgressBar {
                id: courseProgressBar
                from: 0
                to: items
                value: planted + ignored
                indeterminate:  false
                Material.accent: completed ? globalBlue : globalGreen
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: parent.width / 1.1
            }

            Label {
                property int completedPercentage: Math.floor(courseProgressBar.value / courseProgressBar.to * 100)
                text: (completed ? "⭐ " : "") + completedPercentage + "%" + (completed ? " ⭐" : "")
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                Button {
                    text: "Plant"
                    icon.source: "assets/icons/plant.svg"
                    Material.background: globalGreen
                    onClicked: plantAction()
                }

                Button {
                    text: "Water"
                    icon.source: "assets/icons/water.svg"
                    Material.background: globalBlue
                    onClicked: waterAction()
                }

//                Button {
//                    text: "Refresh"
//                    Material.background: globalOrange
//                    icon.source: "assets/actions/refresh.svg"
//                    onClicked: globalBackend.refreshCourses([directory])
//                }
            }
        }
    }

    Rectangle {
        id: itemBackground
        height: parent.height - marginBase
        width: parent.width - marginBase
        x: marginBase / 2
        color: "transparent"
        border.width: 1
        border.color: "gray"
        radius: 10
        z: -1

        Ripple {
            id: ripple
            anchors.fill: parent
            clipRadius: 4
            active: courseExteriorMouseArea.containsMouse
            pressed: courseExteriorMouseArea.pressed
            color: "#20FFFFFF"
        }
    }

    MouseArea {
        id: courseExteriorMouseArea
        anchors.fill: parent
        z: -1
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked:
        {
            mainToolbarTitle.text = title
            rootStackView.push("qrc:/CourseInterior.qml", {
                        "directory": directory,
                        "courseTitle": title,
                        "author": author,
                        "description": description,
                        "category": category,
                        "icon": icon,
                        "items": items,
                        "planted": planted,
                        "water": water,
                        "difficult": difficult,
                        "ignored": ignored,
                        "completed": completed
                            })
        }
    }
}
