import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import libretro.video 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0

ApplicationWindow {
    id: phoenixWindow
    title: qsTr("Phoenix");
    width: 1000 * ratio
    height: 1000
    visible: true

    property real ratio: 4/3

    function qstr(str)
    {
        return qsTr(str);
    }

    menuBar: MenuBar {
        Menu {
            title: "Game";
            enabled: phoenixWindow.visibility === Window.Windowed | Window.Maximized
            MouseArea {
                anchors.fill: parent;
            }


            MenuItem {
                text: "Load Game";
                onTriggered: {
                    fileDialog.type = "game";
                    fileDialog.open();
                }
            }
            MenuItem { text: "Close"; onTriggered: Qt.quit();}
        }

        Menu {
            title: "Cores";
            enabled: phoenixWindow.visibility === Window.Windowed | Window.Maximized

            Menu {
                id: coresAvailable;
                title: qstr("Available");

                Instantiator {
                    model: pathWatcherModel;
                    MenuItem {
                        text: name;
                        onTriggered: {
                            videoItem.libretroCore = path;
                        }
                    }

                    onObjectAdded: coresAvailable.insertItem(index, object);
                    onObjectRemoved: coresAvailable.removeItem(object);
                }

                MenuSeparator { }

                MenuItem {
                    text: "Clear";
                    visible: pathWatcherModel.count > 0;
                    onTriggered: {
                        pathWatcherModel.clear();
                        pathWatcherModel.append( { path: "None", name: "None" } )
                        pathWatcher.clear();
                    }
                }


            }

            MenuItem {
                text: "Change Path...";

                onTriggered: {

                    coreFolderDialog.open();
                }

            }

            MenuItem {
                text: "Load Core...";
                onTriggered: {
                    fileDialog.type = "core";
                    fileDialog.open();
                }
            }


        }

    }

    PathWatcher {
        id: pathWatcher;
        Component.onCompleted: pathWatcher.start();
    }

    Connections {
        target: pathWatcher;
        onFileAdded: {
            if ( pathWatcherModel.get( 0 ).path === "None" )
                pathWatcherModel.set( 0, { path: file, name: baseName } );
            else
                pathWatcherModel.append( { path: file , name: baseName } );
        }

    }

    ListModel {
        id: pathWatcherModel;
        ListElement {path: "None"; name: "None";}
    }

    FileDialog {
        id: coreFolderDialog;
        selectFolder: true;
        onAccepted: {
            pathWatcherModel.clear();
            pathWatcherModel.append( { path: "None", name: "None" } )
            pathWatcher.clear();
            pathWatcher.slotSetCorePath(fileUrl);
        }
    }

    FileDialog {
        id: fileDialog;
        property string type: "";
        selectFolder: false;
        selectMultiple: false;
        onAccepted: {
            if (type === "core")
                videoItem.libretroCore = fileUrl;
            else if (type === "game")
                videoItem.game = fileUrl;
        }
    }

    Rectangle {

        id: videoOutput
        anchors.fill: parent
        color: "black"

        FastBlur {
            height: parent.height
            width: parent.width
            source: videoItem
            radius: 64
            rotation: 180
        }

        MouseArea {

            id: mouseArea
            anchors.fill: parent
            z: 10
            hoverEnabled: true

            onDoubleClicked: {

                if (phoenixWindow.visibility === Window.FullScreen)
                    phoenixWindow.visibility = Window.Windowed
                else if (phoenixWindow.visibility === Window.Windowed | Window.Maximized)
                    phoenixWindow.visibility = Window.FullScreen

            }

        }

        VideoItem {

            id: videoItem
            rotation: 180
            anchors {
                top: parent.top
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            width: height * phoenixWindow.ratio

//            Column {
//                visible: false;
//                spacing: 24;
//                anchors.centerIn: parent;
//                Rectangle {
//                    color: "lightgray";
//                    opacity: 0.6;

//                    border {
//                        color: "white"
//                        width: 2;
//                    }

//                    height: 50;
//                    width: 175;

//                    Text {
//                        anchors.centerIn: parent;
//                        text: "Play | Pause";
//                        color: "white";
//                        font {
//                            pixelSize: 18;
//                            bold: true;
//                        }
//                    }
//                }

//                Rectangle {
//                    color: "lightgray";
//                    opacity: 0.6;
//                    border {
//                        color: "white"
//                        width: 2;
//                    }

//                    height: 50;
//                    width: 175;

//                    Text {
//                        anchors.centerIn: parent;
//                        text: "Load Game";
//                        color: "white";
//                        font {
//                            pixelSize: 18;
//                            bold: true;
//                        }
//                    }
//                }

//                Rectangle {
//                    color: "lightgray";
//                    opacity: 0.6;
//                    border {
//                        color: "white"
//                        width: 2;
//                    }

//                    height: 50;
//                    width: 175;

//                    Text {
//                        anchors.centerIn: parent;
//                        text: "Mute Audio";
//                        color: "white";
//                        font {
//                            pixelSize: 18;
//                            bold: true;
//                        }
//                    }
//                }
//            }

        }

    }

}
