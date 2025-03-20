import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class BluetoothService {

  // Cihazları tara
  Future<List<BluetoothDevice>> cihazlariTara() async {
    List<BluetoothDevice> cihazlar = [];
    try {
      // Bluetooth'un açık olduğundan emin ol
      if (await FlutterBluePlus.adapter.isEnabled) {
        await FlutterBluePlus.startScan(timeout: Duration(seconds: 4)); // Tarama süresi
        // Tarama sonuçlarını dinle
        FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
          for (ScanResult result in results) {
            if (result.device.name.isNotEmpty && !cihazlar.contains(result.device)) {
              cihazlar.add(result.device);
            }
          }
        });
        await Future.delayed(Duration(seconds: 5)); // Tarama işleminin tamamlanması için bekleme
        await FlutterBluePlus.stopScan();  // Taramayı durdur
      }
    } catch (e) {
      print("Bluetooth taraması sırasında hata oluştu: $e");
    }
    return cihazlar;
  }

  // Bağlan ve veri gönder
  Future<bool> baglanVeGonder(BluetoothDevice cihaz, String veri) async {
    try {
      // Cihazla bağlantı kur
      await cihaz.connect(timeout: Duration(seconds: 5));
      // Servisleri ve karakteristiği bul
      List<BluetoothService> services = await cihaz.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Karakteristiklere yazma işlemi
          if (characteristic.properties.write) {
            await characteristic.write(utf8.encode(veri));
            return true; // Başarılı
          }
        }
      }
      return false;  // Yazılabilir karakteristik bulunamadı
    } catch (e) {
      print("Bluetooth veri gönderme hatası: $e");
      return false; // Hata oluştu
    } finally {
      // Bağlantıyı kes (bağlantıyı kesmek isteğe bağlıdır, daha sonra tekrar kullanmak için açık bırakılabilir)
      // cihaz.disconnect();  // Bağlantıyı kesmek gerekebilir, ancak bu satır çoğu durumda otomatik olarak yönetilir
    }
  }
}