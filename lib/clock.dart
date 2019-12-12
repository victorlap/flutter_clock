// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:digital_clock/digit.dart';
import 'package:digital_clock/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        .load("third_party/Bungee_Shade/BungeeShade-Regular.ttf")
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

  String _getWeatherPicture() {
    switch (widget.model.weatherCondition) {
      case WeatherCondition.cloudy:
        return 'third_party/WeatherIcons/Cloud.svg';
      case WeatherCondition.foggy:
        return 'third_party/WeatherIcons/Haze.svg';
      case WeatherCondition.rainy:
        return 'third_party/WeatherIcons/Rain.svg';
      case WeatherCondition.snowy:
        return 'third_party/WeatherIcons/Snow.svg';
      case WeatherCondition.sunny:
        return 'third_party/WeatherIcons/Sun.svg';
      case WeatherCondition.thunderstorm:
        return 'third_party/WeatherIcons/Storm.svg';
      case WeatherCondition.windy:
        return 'third_party/WeatherIcons/Tornado.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final format =
        DateFormat(widget.model.is24HourFormat ? 'HHmmss' : 'hhmmsss');

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        // Box decoration takes a gradient
        gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.1, 0.3, 0.7, 0.9],
          colors: [
            getColors(context)[ThemeOption.background],
            getColors(context)[ThemeOption.background2],
            getColors(context)[ThemeOption.background3],
            getColors(context)[ThemeOption.background4],
          ],
        ),
      ),
      child: !_ready
          ? Center(child: Text("Loading"))
          : Column(
              children: <Widget>[
                Flexible(
                  child: AspectRatio(
                    aspectRatio: 3,
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: SvgPicture.asset(
                            _getWeatherPicture(),
                            color: getColors(context)[ThemeOption.text],
                          ),
                        ),
                        AspectRatio(
                          aspectRatio: 2.0,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.model.temperatureString,
                              style: TextStyle(
                                fontSize: 200,
                                color: getColors(context)[ThemeOption.text],
                                fontFamily: "BungeeShade",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                    child: AspectRatio(
                        aspectRatio: 4,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ClockDigit(_font, Digit.HOUR_ONE, format),
                            ClockDigit(_font, Digit.HOUR_TWO, format),
                            ClockDigit(_font, Digit.MINUTE_ONE, format),
                            ClockDigit(_font, Digit.MINUTE_TWO, format),
                          ],
                        ))),
                Flexible(
                  child: AspectRatio(
                    aspectRatio: 2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ClockDigit(_font, Digit.SECOND_ONE, format),
                        ClockDigit(_font, Digit.SECOND_TWO, format),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
