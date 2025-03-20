import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:deprem_iletisim/screens/gonderen_ekrani.dart';
import 'package:deprem_iletisim/screens/alici_ekrani.dart';
import 'package:deprem_iletisim/services/bildirim_service.dart';

class AcilisEkrani extends StatefulWidget {
  @override
  _AcilisEkraniState createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani> {
  bool _konumIzni = false;
  bool _bluetoothIzni = false;
  bool _wifiIzni = false;
  bool _bildirimIzni = false;
  bool _tümIzinlerVerildi = false;
  BildirimService _bildirimService = BildirimService();

  @override
  void initState() {
    super.initState();
    _bildirimService.init(); // Bildirim servisini başlat
    _izinleriKontrolEt();
  }

  Future<void> _izinleriKontrolEt() async {
    _konumIzni = await Permission.location.isGranted;
    _bluetoothIzni = await Permission.bluetoothConnect.isGranted && await Permission.bluetoothScan.isGranted;  // Hem bağlantı hem de tarama izinleri
    _wifiIzni = true; // Wi-Fi için genellikle ayrı bir izin gerekmez.  Ancak, ağ durumunu kontrol etmek için izin gerekebilir.
    _bildirimIzni = await Permission.notification.isGranted;

    setState(() {
      _tümIzinlerVerildi = _konumIzni && _bluetoothIzni && _wifiIzni && _bildirimIzni;
    });
  }

  Future<void> _izinIste(Permission izin) async {
    final status = await izin.request();
    setState(() {
      if (izin == Permission.location) _konumIzni = status.isGranted;
      if (izin == Permission.bluetoothConnect || izin == Permission.bluetoothScan) _bluetoothIzni = status.isGranted;
      if (izin == Permission.notification) _bildirimIzni = status.isGranted;
      _tümIzinlerVerildi = _konumIzni && _bluetoothIzni && _wifiIzni && _bildirimIzni;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Deprem İletişim")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Uygulama Logosu (isteğe bağlı)
            Center(
              child: Icon(Icons.warning, size: 80, color: Colors.red), // Örnek bir logo
            ),
            SizedBox(height: 20),

            // İzin İstemeleri
            _izinBilgisi(
              izinAdi: "Konum İzni",
              izinDurumu: _konumIzni,
              izinIste: () => _izinIste(Permission.location),
            ),
            _izinBilgisi(
              izinAdi: "Bluetooth İzni",
              izinDurumu: _bluetoothIzni,
              izinIste: () => _izinIste(Permission.bluetoothConnect), // Sadece bağlantı izni yeterli olabilir
            ),
            _izinBilgisi(
              izinAdi: "Wi-Fi Erişimi",
              izinDurumu: _wifiIzni,
              izinIste: () => {}, // Wi-Fi için izin genellikle gerekmez
              izinAciklama: "Wi-Fi bağlantınızın olması yeterlidir."
            ),
            _izinBilgisi(
              izinAdi: "Bildirim İzni",
              izinDurumu: _bildirimIzni,
              izinIste: () => _izinIste(Permission.notification),
            ),
            SizedBox(height: 20),

            // Devam Et Butonu
            ElevatedButton(
              onPressed: _tümIzinlerVerildi
                  ? () {
                // Kullanıcı tercihlerine göre gönderen veya alıcı ekranına git
                // Örneğin, shared_preferences ile kullanıcının tercihi kaydedilebilir.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GonderenEkrani()), // Varsayılan olarak Gönderen ekranına git
                );
              }
                  : null, // İzinler verilmediyse butonu devre dışı bırak
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
    String? izinAciklama, // İzin için açıklama
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(izinAdi),
          Row(
            children: [
              if (izinAciklama != null) // İzin açıklaması varsa göster
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(izinAciklama, style: TextStyle(fontSize: 12)),
                ),
              if (izinDurumu)
                Icon(Icons.check_circle, color: Colors.green),
              ElevatedButton(
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