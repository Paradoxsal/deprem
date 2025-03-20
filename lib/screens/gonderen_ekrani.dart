import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deprem/services/bluetooth_service.dart';
import 'package:deprem/services/konum_service.dart';
import 'package:deprem/services/sinyal_service.dart';
import 'package:deprem/models/kullanici.dart';
import 'package:deprem/providers/sinyal_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class GonderenEkrani extends StatefulWidget {
  @override
  _GonderenEkraniState createState() => _GonderenEkraniState();
}

class _GonderenEkraniState extends State<GonderenEkrani> {
  final TextEditingController _mesajController = TextEditingController();
  String? _seciliCihazAdi;
  List<BluetoothDevice> _bluetoothCihazlari = [];
  KonumService _konumService = KonumService();
  BluetoothService _bluetoothService = BluetoothService();
  SinyalService _sinyalService = SinyalService();
  Position? _konum;
  String _kullaniciAdi = "";
  String _kullaniciSoyadi = "";

  @override
  void initState() {
    super.initState();
    _kullaniciBilgileriniYukle();
    _bluetoothCihazlariniTara();
    _konumAl();
  }

  Future<void> _kullaniciBilgileriniYukle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _kullaniciAdi = prefs.getString('kullaniciAdi') ?? "";
      _kullaniciSoyadi = prefs.getString('kullaniciSoyadi') ?? "";
    });
  }

  Future<void> _konumAl() async {
    try {
      final konum = await _konumService.konumAl();
      setState(() {
        _konum = konum;
      });
    } catch (e) {
      print("Konum alınırken hata: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Konum bilgisi alınamadı."),
      ));
    }
  }

  Future<void> _bluetoothCihazlariniTara() async {
    try {
      List<BluetoothDevice> cihazlar = await _bluetoothService.cihazlariTara();
      setState(() {
        _bluetoothCihazlari = cihazlar;
      });
    } catch (e) {
      print("Bluetooth cihazları taranırken hata: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Bluetooth cihazları taranamadı."),
      ));
    }
  }

  Future<void> _sinyalGonder(BuildContext context) async {
    // Kullanıcıdan gelen verileri al
    String mesaj = _mesajController.text.trim();
    if (mesaj.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lütfen mesajınızı girin.")));
      return;
    }

    // Kullanıcı bilgisini shared_preferences'dan al
    Kullanici kullanici = Kullanici(ad: _kullaniciAdi, soyad: _kullaniciSoyadi);

    // Konum bilgisi
    if (_konum == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Konum bilgisi alınamadı.")));
      return;
    }
    String konumBilgisi = "${_konum!.latitude}, ${_konum!.longitude}";

    // Sinyal oluştur
    Sinyal sinyal = _sinyalService.sinyalOlustur(kullanici, konumBilgisi, mesaj, _seciliCihazAdi ?? "Bilinmeyen Cihaz");

    if (_seciliCihazAdi != null) {
      // Bluetooth cihazını bul
      BluetoothDevice? hedefCihaz = _bluetoothCihazlari.firstWhere(
              (cihaz) => cihaz.name == _seciliCihazAdi,
          orElse: () => null);
      if (hedefCihaz != null) {
        // Sinyali gönder
        try {
          bool gonderimBasarili = await _bluetoothService.baglanVeGonder(
              hedefCihaz, _sinyalService.sinyaliMetneDonustur(sinyal));
          if (gonderimBasarili) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sinyal gönderildi!")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sinyal gönderilirken hata oluştu.")));
          }
        } catch (e) {
          print("Sinyal gönderilirken hata: $e");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sinyal gönderilirken bir hata oluştu.")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Seçilen cihaz bulunamadı.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lütfen bir cihaz seçin.")));
    }

    // Sinyali SinyalProvider'a ekle
    Provider.of<SinyalProvider>(context, listen: false).sinyalEkle(sinyal);

    // Mesaj kutusunu temizle
    _mesajController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Status bar'ı ve navigation bar'ı ayarlama
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.red,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.red,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text("Gönderen Ekranı"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kullanıcı Bilgisi (Shared Preferences'tan alınacak)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _kullaniciAdi,
                    decoration: InputDecoration(labelText: "Adınız"),
                    onChanged: (value) {
                      setState(() {
                        _kullaniciAdi = value;
                      });
                      _kullaniciBilgileriniKaydet();
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _kullaniciSoyadi,
                    decoration: InputDecoration(labelText: "Soyadınız"),
                    onChanged: (value) {
                      setState(() {
                        _kullaniciSoyadi = value;
                      });
                      _kullaniciBilgileriniKaydet();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Mesaj Alanı
            TextField(
              controller: _mesajController,
              decoration: InputDecoration(labelText: "Acil Durum Mesajı"),
            ),
            SizedBox(height: 16),

            // Bluetooth Cihazları Listesi
            Text("Bluetooth Cihazları:"),
            Expanded(
              child: _bluetoothCihazlari.isEmpty
                  ? Center(child: Text("Cihaz aranıyor..."))
                  : ListView.builder(
                itemCount: _bluetoothCihazlari.length,
                itemBuilder: (context, index) {
                  return RadioListTile<String>(
                    title: Text(_bluetoothCihazlari[index].name ?? "Bilinmeyen Cihaz"),
                    value: _bluetoothCihazlari[index].name,
                    groupValue: _seciliCihazAdi,
                    onChanged: (value) {
                      setState(() {
                        _seciliCihazAdi = value;
                      });
                    },
                  );
                },
              ),
            ),

            // Konum Bilgisi
            if (_konum != null)
              Text("Konum: ${_konum!.latitude}, ${_konum!.longitude}"),
            SizedBox(height: 16),

            // Sinyal Gönder Butonu
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _sinyalGonder(context),
              child: Text("Sinyal Gönder"),
            ),
          ],
        ),
      ),
    );
  }

  // Kullanıcı bilgilerini shared_preferences ile kaydetme
  Future<void> _kullaniciBilgileriniKaydet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('kullaniciAdi', _kullaniciAdi);
    await prefs.setString('kullaniciSoyadi', _kullaniciSoyadi);
  }
}