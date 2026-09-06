import QtQuick

// A row of thin bars mirrored around the middle. `levels` holds 0..1 values,
// newest last; the bars show the most recent `bars` of them. With `idle` on
// (nothing to show yet, or transcribing) the bars breathe gently instead.
Item {
  id: root

  property var levels: []
  property int bars: 20
  property real barWidth: 2
  property real gap: 2
  property color color: "white"
  property bool idle: false     // gentle breathing (nothing to show yet, or transcribing)
  property bool sine: false     // a travelling sine wave (the microphone is still connecting)
  property real minHeight: 2

  implicitWidth: bars * (barWidth + gap) - gap
  implicitHeight: 16

  property real phase: 0
  Timer {
    interval: 40
    repeat: true
    running: (root.idle || root.sine) && root.visible
    onTriggered: root.phase += root.sine ? 0.35 : 0.2
  }

  function levelAt(i) {
    var lv = levels || []
    var offset = lv.length - bars
    var v = offset + i >= 0 ? Number(lv[offset + i]) : 0
    return isFinite(v) ? Math.max(0, Math.min(1, v)) : 0
  }

  function breath(i) {
    return 0.12 + 0.1 * (1 + Math.sin(phase + i * 0.45)) / 2
  }

  function wave(i) {
    return 0.15 + 0.75 * (1 + Math.sin(i * 0.7 - phase)) / 2
  }

  Row {
    anchors.centerIn: parent
    spacing: root.gap
    Repeater {
      model: root.bars
      Rectangle {
        required property int index
        readonly property real lv: root.sine ? root.wave(index) : root.idle ? root.breath(index) : root.levelAt(index)
        width: root.barWidth
        height: Math.max(root.minHeight, Math.round(lv * root.height))
        radius: root.barWidth / 2
        color: root.color
        anchors.verticalCenter: parent.verticalCenter
        Behavior on height { NumberAnimation { duration: 70 } }
      }
    }
  }
}
