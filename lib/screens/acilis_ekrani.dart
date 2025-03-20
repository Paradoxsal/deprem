import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:deprem/screens/gonderen_ekrani.dart';
import  'package:deprem/screens/alici_ekrani.dart';
import 'package:deprem/services/bildirim_service.dart';
import 'package:flutter/services.dart'; // StatusBar ve NavigationBar için

class AcilisEkrani extends StatefulWidget {
  @override
  _AcilisEkraniState createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani> {
  bool _konumIzni = false;
  bool _bluetoothIzni = false;
  bool _wifiIzni = true; // Wi-Fi için genellikle izin gerekmez
  bool _bildirimIzni = false;
  bool _tumIzinlerVerildi = false;
  BildirimService _bildirimService = BildirimService();

  @override
  void initState() {
    super.initState();
    _bildirimService.init();
    _izinleriKontrolEt();
  }

  Future<void> _izinleriKontrolEt() async {
    _konumIzni = await Permission.location.isGranted;
    _bluetoothIzni = await Permission.bluetoothConnect.isGranted && await Permission.bluetoothScan.isGranted;
    _bildirimIzni = await Permission.notification.isGranted;

    setState(() {
      _tumIzinlerVerildi = _konumIzni && _bluetoothIzni && _wifiIzni && _bildirimIzni;
    });
  }

  Future<void> _izinIste(Permission izin) async {
    final status = await izin.request();
    setState(() {
      if (izin == Permission.location) _konumIzni = status.isGranted;
      if (izin == Permission.bluetoothConnect || izin == Permission.bluetoothScan) _bluetoothIzni = status.isGranted;
      if (izin == Permission.notification) _bildirimIzni = status.isGranted;
      _tumIzinlerVerildi = _konumIzni && _bluetoothIzni && _wifiIzni && _bildirimIzni;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Status bar'ı ve navigation bar'ı ayarlama
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.red, // Kırmızı status bar
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.red, // Kırmızı navigation bar
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text("Deprem İletişim"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Icon(Icons.warning, size: 80, color: Colors.red),
            ),
            SizedBox(height: 20),
            _izinBilgisi(
              izinAdi: "Konum İzni",
              izinDurumu: _konumIzni,
              izinIste: () => _izinIste(Permission.location),
            ),
            _izinBilgisi(
              izinAdi: "Bluetooth İzni",
              izinDurumu: _bluetoothIzni,
              izinIste: () => _izinIste(Permission.bluetoothConnect),
            ),
            _izinBilgisi(
              izinAdi: "Wi-Fi Erişimi",
              izinDurumu: _wifiIzni,
              izinIste: () => {}, // Wi-Fi için izin genellikle gerekmez
              izinAciklama: "Wi-Fi bağlantınızın olması yeterlidir.",
            ),
            _izinBilgisi(
              izinAdi: "Bildirim İzni",
              izinDurumu: _bildirimIzni,
              izinIste: () => _izinIste(Permission.notification),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _tumIzinlerVerildi
                  ? () {
                      Navigator.pushReplacement( // pushReplacement kullanıldı
                        context,
                        MaterialPageRoute(builder: (context) => GonderenEkrani()), // Gönderen ekranına yönlendir
                      );
                    }
                  : null,
              child: Text("Devam Et"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _izinBilgisi({
    required String izinAdi,
    required bool izinDurumu,
    required VoidCallback izinIste,
    String? izinAciklama,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(izinAdi),
          Row(
            children: [
              if (izinAciklama != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(izinAciklama, style: TextStyle(fontSize: 12)),
                ),
              if (izinDurumu) Icon(Icons.check_circle, color: Colors.green),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: izinIste,
                child: Text(izinDurumu ? "Tekrar İste" : "İzin Ver"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}