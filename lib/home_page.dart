import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifiss/home_controller.dart';
import 'utils.dart';
import 'wifi_details_model.dart';



class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
        length: controller.tabList.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.greenAccent,
            elevation: 0,
            toolbarHeight: 0,
            bottom: TabBar(tabs: controller.tabList),
          ),
          body: TabBarView(
            children: [
              wifiScanner(),
              wifiChart()
            ],
          ),
        )
    ));
  }

  Widget wifiScanner(){
    return Obx(() => RefreshIndicator(
      onRefresh: () async => controller.wifiScanListening(),
      child: Column(
        children: [
          Expanded(
            child: controller.wifiRouterList.isNotEmpty
                ? ListView.builder(
                itemCount: controller.wifiRouterList.length,
                itemBuilder: (context, index) => _wifiRouter(controller.wifiRouterList[index], index))
                : const Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_find,size: 48,color: Colors.pink)
                    ],
                  ),
                ),
          ),
        ],
      ),
    ));
  }

  Widget _wifiRouter(WiFiAccessPoint router, int index) {
    bool isConnected = router.bssid == controller.wifiMacAddress.value;
    return Container(
      margin: isConnected ? const EdgeInsets.all(8) : null,
      child: ListTile(
        shape: isConnected ? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.blueGrey),
        ) : null,
        tileColor: index % 2 == 0 ?  Colors.blueGrey.shade50 : Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(router.ssid, style: const TextStyle(fontSize: 13,color: Colors.black),overflow: TextOverflow.ellipsis,),
                Text( isConnected ? " | Connected":"",style: const TextStyle(fontSize: 13,color: Colors.green),textAlign: TextAlign.center,),
              ],
            ),
            Text(router.bssid, style: const TextStyle(fontSize: 12,color: Colors.blueGrey),overflow: TextOverflow.ellipsis,),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${router.frequency} MHz',style: const TextStyle(fontSize: 12,color: Colors.black45),),
            Text(router.capabilities,style: const TextStyle(fontSize: 10,color: Colors.black45),overflow: TextOverflow.ellipsis,),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Utils.dBmIcon(router.level),color: Utils.dBmColors(router.level)),
            Text('${router.level}  | dBm',style: TextStyle(fontSize: 12,color: Utils.dBmColors(router.level),),textAlign: TextAlign.center,),
          ],
        ),
        leading:  Text('${Utils.convertMHzToGHz(router.frequency)}\nGHz',style: const TextStyle(fontSize: 14,color: Colors.black),textAlign: TextAlign.center,),
      ),
    );
  }

  Widget wifiChart(){
    return Obx(() => SfCartesianChart(
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.auto,
        overflowMode: LegendItemOverflowMode.wrap,
        alignment: ChartAlignment.center,
        isResponsive: true,
      ),
      primaryXAxis: NumericAxis(),
      primaryYAxis: NumericAxis(
        desiredIntervals: 10,
        interval: 20,
        isInversed: true,
      ),
      series: controller.wifiRouterMap.entries.map((entry) {
        return LineSeries<WifiDetails, int>(
          name: entry.value[0].router,
          dataSource: entry.value,
          width: entry.value.any((e) => e.isConnected) ? 3 : 1,
          xValueMapper: (WifiDetails wifi, int index) => index,
          yValueMapper: (WifiDetails wifi, _) => wifi.dbmValue[0],
          onRendererCreated: (ChartSeriesController csController){controller.chartSeriesController = csController;},
        );
      }).toList(),
    ));
  }

}
