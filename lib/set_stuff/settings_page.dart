import 'dart:developer';
import 'dart:math' as math;

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double scaleFactor = 1.0;
  var db = FirebaseFirestore.instance;
  bool run = true;

  void runner() async {
    while (run) {
      db
          .collection("nicknames")
          .doc(widget.data["Nickname"])
          .update({"ScaleFactor": scaleFactor});
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    setState(() {
      run = false;
    });
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    runner();
    scaleFactor = widget.data["ScaleFactor"] == null
        ? 1.0
        : 1.0 * widget.data["ScaleFactor"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 21),
        ),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Positioned(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(13, 4, 13, 13),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Theme",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Switch(
                          value: AdaptiveTheme.of(context).mode.isDark,
                          onChanged: (value) {
                            if (value) {
                              AdaptiveTheme.of(context).setDark();
                            } else {
                              AdaptiveTheme.of(context).setLight();
                            }
                          },
                        ),
                        isLightMode(context,
                            lWidget: const Text(""),
                            dWidget: const Text(
                              "Beta",
                              style:
                                  TextStyle(letterSpacing: 2.1, fontSize: 12),
                            ))
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "Text size",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        SliderFb1(
                            min: 0.5,
                            max: 2.0,
                            value: widget.data["ScaleFactor"] == null
                                ? 1.0
                                : 1.0 * widget.data["ScaleFactor"],
                            onChange: (v) {
                              scaleFactor = roundDouble(v, 2);
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
              child: Align(
            alignment: Alignment.bottomCenter,
            child: Text("App v1.7"),
          ))
        ],
      )),
    );
  }
}

//
// Simple Slider
// Choose min, max.
// State changes is inside the onChange method.
// _currentSliderValue is the slider value you will use.
//
class SliderFb1 extends StatefulWidget {
  final double min;
  final double max;
  final double value;
  final double initialValue;
  final bool showMinMaxText;
  final Color primaryColor;
  final TextStyle minMaxTextStyle;
  final Function(double) onChange;
  const SliderFb1(
      {required this.min,
      required this.max,
      required this.value,
      this.initialValue = 0.0,
      required this.onChange,
      this.primaryColor = Colors.indigo,
      this.showMinMaxText = true,
      this.minMaxTextStyle = const TextStyle(fontSize: 14),
      Key? key})
      : super(key: key);

  @override
  _SliderFb1State createState() => _SliderFb1State();
}

class _SliderFb1State extends State<SliderFb1> {
  late double _currentSliderValue;
  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: widget.primaryColor,
        inactiveTrackColor: widget.primaryColor.withAlpha(35),
        trackShape: const RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbShape: CustomSliderThumbCircle(
          thumbRadius: 20,
          min: widget.min,
          max: widget.max,
        ),
        thumbColor: widget.primaryColor,
        overlayColor: widget.primaryColor.withAlpha(35),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
        tickMarkShape: const RoundSliderTickMarkShape(),
        activeTickMarkColor: widget.primaryColor,
        inactiveTickMarkColor: widget.primaryColor.withAlpha(35),
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: widget.primaryColor.withAlpha(35),
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      child: Slider(
        min: widget.min,
        max: widget.max,
        value: _currentSliderValue,
        onChanged: (value) {
          setState(() {
            _currentSliderValue = value;
          });
          widget.onChange(value);
        },
      ),
    );
  }
}

// Credits to @Ankit Chowdhury
class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final double min;
  final double max;

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 0.0,
    this.max = 100.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = Colors.white //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: sliderTheme.thumbColor, //Text Color of Value on Thumb
      ),
      text: getValue(value),
    );

    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return roundDouble((min + (max - min) * value), 2).toString();
  }
}

double roundDouble(double value, int places) {
  double mod = math.pow(10.0, places).toDouble();
  return ((value * mod).round().toDouble() / mod);
}
