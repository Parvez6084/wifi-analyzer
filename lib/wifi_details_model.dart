
class WifiDetails{
  String router;
  String mac;
  bool isConnected;
  List<int> dbmValue;
  WifiDetails({
    required this.router,
    required this.mac,
    required this.dbmValue,
    required this.isConnected
  });

  @override
  String toString() {
    return '>>>>>router: $router, mac: $mac, dbmValue: $dbmValue<<<<\n';
  }
}
