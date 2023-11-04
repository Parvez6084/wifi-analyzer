import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifiss/wifi_details_model.dart';

class HomeController extends GetxController{

  var tabList = [const Tab(text: "Wifi"), const Tab(text: "Chart")].obs;

  late Timer? _timer;
  var wifiMacAddress = "".obs;
  var wifiRouterList = <WiFiAccessPoint>[].obs;
  var wifiRouterMap = <String, List<WifiDetails>>{}.obs;

  final _wifiScan = WiFiScan.instance;
  final _networkInfo = NetworkInfo();
  StreamSubscription<List<WiFiAccessPoint>>? _subscription;
  ChartSeriesController? chartSeriesController;

  Future<void> wifiScanListening() async {
    if (await _wifiScan.canGetScannedResults(askPermissions: true) != CanGetScannedResults.yes) {
      wifiRouterList.clear();
      return;
    }

    String? wifiBSSID = await _networkInfo.getWifiBSSID();
    _subscription = _wifiScan.onScannedResultsAvailable.listen((result) {
      result.sort((a, b) => b.level.compareTo(a.level));
      wifiRouterList.value = result;
      if (wifiBSSID != null && wifiBSSID.isNotEmpty){wifiMacAddress.value = wifiBSSID;}
    });
  }

  Future<void> wifiScanManually() async {

    final result = await _wifiScan.canGetScannedResults(askPermissions: false);
    if (result == CanGetScannedResults.yes) {
      await _wifiScan.startScan();
      final wifiList = await _wifiScan.getScannedResults();
      String? wifiBSSID = await _networkInfo.getWifiBSSID();

      for(WiFiAccessPoint wifi in wifiList){
        bool isConnectedWifi = wifiBSSID != null && wifiBSSID.isNotEmpty && wifi.bssid == wifiBSSID;
        var wifiDetails = WifiDetails(router: wifi.ssid, mac: wifi.bssid, dbmValue: [wifi.level], isConnected: isConnectedWifi);

        if (!wifiRouterMap.containsKey(wifi.bssid)) { wifiRouterMap[wifi.bssid] = [];}
        else {
          if (wifiRouterMap[wifi.bssid]![0].dbmValue.length > 20) { wifiRouterMap[wifi.bssid]![0].dbmValue.removeAt(0);}
          wifiRouterMap[wifi.bssid]![0].dbmValue.add(wifi.level);
        }

        wifiRouterMap[wifi.bssid]!.add(wifiDetails);
        wifiRouterMap.removeWhere((key, value) => !wifiList.any((wifi) => wifi.bssid == key));

        if (wifiRouterMap.isNotEmpty && chartSeriesController != null) {
          chartSeriesController!.updateDataSource(addedDataIndex: wifiRouterMap.length -1, removedDataIndex: 0);
        }
      }
    }
  }

  @override
  void onInit() async{
    super.onInit();
    await wifiScanListening();
    _timer = Timer.periodic(
      const Duration(seconds:1), (Timer t) => {
        if(_timer?.isActive ?? false) {
          wifiScanManually()
        }
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
    chartSeriesController = null;
    _subscription?.cancel();
    _subscription = null;
    _timer?.cancel();
  }

}