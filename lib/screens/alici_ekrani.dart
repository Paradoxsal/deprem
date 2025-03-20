import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deprem/providers/sinyal_provider.dart';
import 'package:deprem/services/bluetooth_service.dart'; // Düzeltildi
import 'package:deprem/services/sinyal_service.dart';
import 'package:deprem/models/sinyal.dart';
import 'package:deprem/screens/sinyal_detay_ekrani.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Düzeltildi
import 'package:deprem/services/bildirim_service.dart';

class AliciEkrani extends StatefulWidget {
  @override
  _AliciEkraniState createState() => _AliciEkraniState();
}

class _AliciEkraniState extends State<AliciEkrani> {
  BluetoothService _bluetoothService = BluetoothService(); // Düzeltildi
  SinyalService _sinyalService = SinyalService();
  BildirimService _bildirimService = BildirimService();
  bool _isScanning = false; // Tarama durumunu takip etmek için

  @override
  void initState() {
    super.initState();
    _bildirimService.init();
    _bluetoothDinle();
  }

  // Bluetooth dinleme fonksiyonu
  Future<void> _bluetoothDinle() async {
    try {
      if (!_isScanning) {
        setState(() {
          _isScanning = true;
        });
        await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

        FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
          for (ScanResult scanResult in results) {
            if (scanResult.advertisementData.serviceUuids.isNotEmpty) {
              // Sadece belirli servisleri dinlemek için kontrol ekleyebilirsiniz.
              scanResult.device.connectionState.listen((BluetoothDeviceState state) {
                if (state == BluetoothDeviceState.connected) {
                  print('Connected to ${scanResult.device.name}');
                  // Veri alma işlemleri burada yapılmalı
                  _veriAl(scanResult.device);
                } else if (state == BluetoothDeviceState.disconnected) {
                  print('Disconnected from ${scanResult.device.name}');
                }
              });
            }
          }
        });

        await Future.delayed(Duration(seconds: 5)); // Tarama süresi
        await FlutterBluePlus.stopScan();
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      print("Bluetooth dinleme hatası: $e");
    }
  }

  Future<void> _veriAl(BluetoothDevice device) async {
    try {
      if (device == null) return;
      // Bağlan
      await device.connect(timeout: Duration(seconds: 5));
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.read) { // Okuma özelliği kontrolü
            List<int> values = await characteristic.read();
            String gelenVeri = String.fromCharCodes(values);
            print("Gelen Veri: $gelenVeri"); // Veriyi yazdır
            if (gelenVeri.isNotEmpty) {
              // Gelen veriyi Sinyal'e çevir
              Sinyal yeniSinyal = _sinyalService.sinyalOlusturFromString(gelenVeri); // Bu metodu SinyalService'e ekleyeceğiz

              // Sinyali provider'a ekle
              Provider.of<SinyalProvider>(context, listen: false).sinyalEkle(yeniSinyal);

              // Bildirim göster
              _bildirimService.sinyalBildirimi("Yeni Sinyal", "Yeni bir sinyal alındı.");
            }
          }
        }
      }
    } catch (e) {
      print("Veri alma hatası: $e");
    } finally {
      device.disconnect(); // Bağlantıyı kes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alıcı Ekranı")),
      body: Consumer<SinyalProvider>(
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
      floatingActionButton: _isScanning ? CircularProgressIndicator() : FloatingActionButton(
        onPressed: _bluetoothDinle,
        child: Icon(Icons.refresh),
      ),
    );
  }
}