import 'package:flutter/material.dart';

class Utils {
  static ColorSwatch<int> dBmColors(int value) {
    if (value >= -30) {
      return Colors.green;
    } else if (value >= -50) {
      return Colors.lightGreen;
    } else if (value >= -60) {
      return Colors.amber;
    } else if (value >= -67) {
      return Colors.orangeAccent;
    } else if (value >= -70) {
      return Colors.orange;
    } else if (value >= -80) {
      return Colors.deepOrangeAccent;
    } else if (value >= -90) {
      return Colors.red;
    }
    return Colors.blueGrey;
  }

  static IconData dBmIcon(int value) {
    if (value >= -30) {
      return Icons.signal_wifi_4_bar_sharp;
    } else if (value >= -50) {
      return Icons.network_wifi;
    } else if (value >= -60) {
      return Icons.network_wifi;
    } else if (value >= -67) {
      return Icons.network_wifi_3_bar_sharp;
    } else if (value >= -70) {
      return Icons.network_wifi_2_bar_sharp;
    } else if (value >= -80) {
      return Icons.network_wifi_1_bar_sharp;
    } else if (value >= -90) {
      return Icons.signal_wifi_0_bar_sharp;
    }
    return Icons.signal_wifi_bad_sharp;
  }

  static String convertMHzToGHz(int frequencyMHz) {
    double ghz = frequencyMHz / 1000;
    return ghz.toStringAsFixed(1);

  }

}
