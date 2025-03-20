import 'package:flutter/material.dart';
import 'package:deprem/models/sinyal.dart';
import 'package:url_launcher/url_launcher.dart'; // Düzeltildi

class SinyalDetayEkrani extends StatelessWidget {
  final Sinyal sinyal;

  SinyalDetayEkrani({required this.sinyal});

  Future<void> _aramayiBaslat() async {
    final String tel = 'tel:+905551234567'; // Örnek bir numara
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: tel.substring(4), // "+90" kısmını atla
    );

    if (await canLaunchUrl(launchUri)) { // Düzeltildi
      await launchUrl(launchUri); // Düzeltildi
    } else {
      throw 'Telefonu arama başarısız: $tel';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sinyal Detayları"), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ad Soyad: ${sinyal.adSoyad ?? 'Bilinmiyor'}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Konum: ${sinyal.konum ?? 'Bilinmiyor'}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Mesaj: ${sinyal.mesaj ?? 'Mesaj Yok'}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Zaman: ${sinyal.zaman.toString()}", style: TextStyle(fontSize: 14)),
            SizedBox(height: 20),
            // Harita entegrasyonu (burada harita widget'ı eklenecek)
            // Harita üzerinde konumu gösterme (isteğe bağlı)

            // Telefonu Ara Butonu (isteğe bağlı)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _aramayiBaslat(),
              child: Text("Ara"),
            ),
          ],
        ),
      ),
    );
  }
}