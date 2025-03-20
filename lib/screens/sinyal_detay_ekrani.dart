import 'package:flutter/material.dart';
import 'package:deprem_iletisim/models/sinyal.dart';
import 'package:url_launcher/url_launcher.dart'; // Telefon arama için

class SinyalDetayEkrani extends StatelessWidget {
  final Sinyal sinyal;

  SinyalDetayEkrani({required this.sinyal});

  Future<void> _aramayiBaslat() async {
    final String tel = 'tel:+905551234567'; // Örnek bir numara
    if (await canLaunchUrl(Uri.parse(tel))) {
      await launchUrl(Uri.parse(tel));
    } else {
      throw 'Telefonu arama başarısız: $tel';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sinyal Detayları")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ad Soyad: ${sinyal.adSoyad ?? 'Bilinmiyor'}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              onPressed: () => _aramayiBaslat(),
              child: Text("Ara"),
            ),
          ],
        ),
      ),
    );
  }
}