// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:text_to_path_maker/text_to_path_maker.dart';
import 'package:intl/intl.dart';
import 'package:path_morph/path_morph.dart';
import 'dart:typed_data';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  PMFont _font;
  AnimationController _controller;
  SampledPathData _data;

  Path hourOne, hourOneOld;
  Path hourTwo, hourTwoOld;
  Path minuteOne, minuteOneOld;
  Path minuteTwo, minuteTwoOld;

  var _ready = false;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _loadFont();
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _loadFont() {
    rootBundle
        .load("third_party/PressStart2P-Regular.ttf")
        .then((ByteData data) {
      // Create a font reader
      var reader = PMFontReader();

      // Parse the font
      _font = reader.parseTTFAsset(data);

      // Warm up the "old" paths for animating
      _calculatePaths();

      setState(() {
        _ready = true;
      });
    });
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    if (_ready) {
      _calculatePaths();
//    _calculateAnimations();
    }

    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  void _calculatePaths() {
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    hourOneOld = hourOne;
    hourOne = _font.generatePathForCharacter(hour.codeUnitAt(0));
    hourOne = PMTransform.moveAndScale(hourOne, .0, .0, 0.1, 0.1);

    hourTwoOld = hourTwo;
    hourTwo = _font.generatePathForCharacter(hour.codeUnitAt(1));
    hourTwo = PMTransform.moveAndScale(hourTwo, 100.0, .0, 0.1, 0.1);

    minuteOneOld = minuteOne;
    minuteOne = _font.generatePathForCharacter(minute.codeUnitAt(0));
    minuteOne = PMTransform.moveAndScale(minuteOne, 200.0, .0, 0.1, 0.1);

    minuteTwoOld = minuteTwo;
    minuteTwo = _font.generatePathForCharacter(minute.codeUnitAt(1));
    minuteTwo = PMTransform.moveAndScale(minuteTwo, 300.0, .0, 0.1, 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    return Container(
        color: colors[_Element.background],
        child: Center(
          child: new Row(
            children: <Widget>[
              CustomPaint(
                painter: MyPainter(hourOne, colors[_Element.text]),
              ),
              CustomPaint(
                painter: MyPainter(hourTwo, colors[_Element.text]),
              ),
              CustomPaint(
                painter: MyPainter(minuteOne, colors[_Element.text]),
              ),
              CustomPaint(
                painter: MyPainter(minuteTwo, colors[_Element.text]),
              ),
            ],
          ),
        ));
  }
}

class MyPainter extends CustomPainter {
  Path path;
  var myPaint;

  MyPainter(this.path, textColor) {
    myPaint = Paint();
    myPaint.color = textColor;
    myPaint.style = PaintingStyle.stroke;
    myPaint.strokeWidth = 3.0;
  }

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(path, myPaint);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
