import 'dart:async';

import 'package:digital_clock/digitpainter.dart';
import 'package:digital_clock/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_morph/morph.dart';
import 'package:path_morph/path_morph.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';

enum Digit {
  HOUR_ONE,
  HOUR_TWO,
  MINUTE_ONE,
  MINUTE_TWO,
  SECOND_ONE,
  SECOND_TWO,
  SEPARATOR
}

class ClockDigit extends StatefulWidget {
  final PMFont font;
  final DateFormat format;
  final Digit digit;

  ClockDigit(this.font, this.digit, this.format);

  @override
  _ClockDigitState createState() => _ClockDigitState();
}

class _ClockDigitState extends State<ClockDigit>
    with SingleTickerProviderStateMixin {
  Timer _timer;

  String number;

  Path previousPath;
  Path path;

  SampledPathData data;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 750),
    );

    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _updatePaths() {
    previousPath = path;
    path = widget.font.generatePathForCharacter(number.codeUnitAt(0));

    if (previousPath == null) {
      // On first render, path = null
      if (widget.digit == Digit.SEPARATOR) {
        previousPath = path;
        return;
      }

      final oldNumber =
          number == "0" ? "9".codeUnitAt(0) : number.codeUnitAt(0) - 1;
      previousPath = widget.font.generatePathForCharacter(oldNumber);
    }

    var previousLength = previousPath.computeMetrics().length;
    var newLength = path.computeMetrics().length;

    if (newLength > previousLength) {
      for (var i = 0; i < newLength - previousLength; i++) {
        previousPath.relativeLineTo(1, 1);
        previousPath.close();
      }
    }

    if (previousLength > newLength) {
      for (var i = 0; i < previousLength - newLength; i++) {
        path.relativeLineTo(1, 1);
        path.close();
      }
    }

    data = PathMorph.samplePaths(previousPath, path);

//    if (data.points1.length > data.points2.length) {
//      // Make sure the first digit does not have more contour points than the next
//      data.points1 = List.from(data.points1.getRange(0, data.points2.length));
//      data.shiftedPoints =
//          List.from(data.shiftedPoints.getRange(0, data.points2.length));
//    } else if (data.points1.length != data.points2.length) {
//      data.points2 = List.from(data.points2.getRange(0, data.points1.length));
//    }
  }

  void _updateAnimations() {
    PathMorph.generateAnimations(_controller, data, (i, z) {
      setState(() {
        if (i >= data.shiftedPoints.length) {
          // The number of contours decrease, so do nothing
          return;
        }
        data.shiftedPoints[i] = z;
      });
    });

    _controller.forward(from: 0.0);
  }

  void _updateTime() {
    final dateTime = DateTime.now();

    if (number != getNumber(dateTime)) {
      print(
          "${widget.digit} number: $number, getnumber; ${getNumber(dateTime)}");

      setState(() {
        number = getNumber(dateTime);

        _updatePaths();
        _updateAnimations();
      });
    }

    // Update once per minute.
    // _timer = Timer(
    //   Duration(minutes: 1) -
    //       Duration(seconds: _dateTime.second) -
    //       Duration(milliseconds: _dateTime.millisecond),
    //   _updateTime,
    // );

    // Update once per second, but make sure to do it at the beginning of each
    // new second, so that the clock is accurate.
    _timer = Timer(
      Duration(seconds: 1) - Duration(milliseconds: dateTime.millisecond),
      _updateTime,
    );
  }

  getNumber(DateTime dateTime) {
    final time = widget.format.format(dateTime);

    switch (widget.digit) {
      case Digit.HOUR_ONE:
        return time[0];
      case Digit.HOUR_TWO:
        return time[1];
      case Digit.MINUTE_ONE:
        return time[2];
      case Digit.MINUTE_TWO:
        return time[3];
      case Digit.SECOND_ONE:
        return time[4];
      case Digit.SECOND_TWO:
        return time[5];
      case Digit.SEPARATOR:
        return ":";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 2.0,
        child: Container(
          margin: EdgeInsets.all(10.0),
//          decoration: BoxDecoration(border: Border.all()),
          child: CustomPaint(
            painter: DigitPainter(
              number,
              PathMorph.generatePath(data),
              getColors(context)[ThemeOption.text],
            ),
          ),
        ),
      ),
    );
  }
}
