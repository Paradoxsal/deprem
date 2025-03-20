import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deprem_iletisim/providers/sinyal_provider.dart';
import 'package:deprem_iletisim/services/bluetooth_service.dart';
import 'package:deprem_iletisim/services/sinyal_service.dart';
import 'package:deprem_iletisim/models/sinyal.dart';
import 'package:deprem_iletisim/screens/sinyal_detay_ekrani.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:deprem_iletisim/services/bildirim_service.dart';

class AliciEkrani extends StatefulWidget {
  @override
  _AliciEkraniState createState() => _AliciEkraniState();
}

class _AliciEkraniState extends State<AliciEkrani> {
  BluetoothService _bluetoothService = BluetoothService();
  SinyalService _sinyalService = SinyalService();
  BildirimService _bildirimService = BildirimService();

  @override
  void initState() {
    super.initState();
    _bildirimService.init();
    _bluetoothDinle();
  }

  // Bluetooth dinleme fonksiyonu
  Future<void> _bluetoothDinle() async {
    // Basit bir döngü ile, gelen verileri dinleme
    await FlutterBluetoothSerial.instance.isAvailable.then((bool isAvailable) {
      if (isAvailable) {
        // Bağlantı kurmak ve verileri almak için
        FlutterBluetoothSerial.instance.onRead().listen((BluetoothMessage message) {
          // Gelen veriyi işle
          String gelenVeri = String.fromCharCodes(message.data);
          if (gelenVeri.isNotEmpty) {
            // Gelen veriyi Sinyal'e çevir
            Sinyal yeniSinyal = _sinyalService.sinyalOlusturFromString(gelenVeri);

            // Sinyali provider'a ekle
            Provider.of<SinyalProvider>(context, listen: false).sinyalEkle(yeniSinyal);

            // Bildirim göster
            _bildirimService.sinyalBildirimi("Yeni Sinyal", "Yeni bir sinyal alındı.");

            print("Gelen sinyal: ${yeniSinyal.toFormattedString()}");
          }
        });
      } else {
        print("Bluetooth mevcut değil!");
        // Kullanıcıya Bluetooth'un olmadığını bildir.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alıcı Ekranı")),
      body: Consumer<SinyalProvider>( // Provider ile güncellemeleri dinle
        builder: (context, sinyalProvider, child) {
          List<Sinyal> gelenSinyaller = sinyalProvider.gelenSinyaller;

          return gelenSinyaller.isEmpty
              ? Center(child: Text("Henüz sinyal yok."))
              : ListView.builder(
            itemCount: gelenSinyaller.length,
            itemBuilder: (context, index) {
              Sinyal sinyal = gelenSinyaller[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(sinyal.adSoyad ?? "Bilinmeyen Kişi"),
                  subtitle: Text(sinyal.mesaj ?? "Mesaj Yok"),
                  trailing: Text(
                      "${sinyal.zaman.hour.toString().padLeft(2, '0')}:${sinyal.zaman.minute.toString().padLeft(2, '0')}"
                  ),
                  onTap: () {
                    // Sinyal detay ekranına git
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SinyalDetayEkrani(sinyal: sinyal),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}