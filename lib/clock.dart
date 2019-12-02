// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:digital_clock/digit.dart';
import 'package:digital_clock/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';

class Clock extends StatefulWidget {
  const Clock(this.model);

  final ClockModel model;

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  PMFont _font;
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    widget.model.addListener(_updateModel);
    _updateModel();

    _loadFont();
  }

  @override
  void didUpdateWidget(Clock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _loadFont() {
    rootBundle
        .load("third_party/PressStart2P/PressStart2P-Regular.ttf")
        .then((ByteData data) {
      // Create a font reader
      var reader = PMFontReader();

      // Parse the font
      _font = reader.parseTTFAsset(data);

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

  @override
  Widget build(BuildContext context) {
    final format =
        DateFormat(widget.model.is24HourFormat ? 'HHmmss' : 'hhmmsss');

    return Container(
      color: getColors(context)[ThemeOption.background],
      child: !_ready
          ? Center(child: Text("Loading"))
          : Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image(image: AssetImage('third_party/WeatherIcons/Cloud.svg'))
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClockDigit(_font, Digit.HOUR_ONE, format),
                    ClockDigit(_font, Digit.HOUR_TWO, format),
                    ClockDigit(_font, Digit.MINUTE_ONE, format),
                    ClockDigit(_font, Digit.MINUTE_TWO, format),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClockDigit(_font, Digit.SECOND_ONE, format),
                    ClockDigit(_font, Digit.SECOND_TWO, format),
                  ],
                )
              ],
            ),
    );
  }
}
