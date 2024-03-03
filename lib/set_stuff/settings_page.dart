import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
