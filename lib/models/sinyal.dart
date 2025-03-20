import 'package:intl/intl.dart';

class Sinyal {
  final String? adSoyad;
  final String? konum; // "enlem, boylam" formatında
  final String? mesaj;
  final DateTime zaman;
  final String? cihazAdi; // Sinyalin geldiği cihazın adı
  // Diğer bilgiler...

  Sinyal({
    this.adSoyad,
    this.konum,
    this.mesaj,
    required this.zaman,
    this.cihazAdi,
  });

  // Sinyali formata çevirme
  String toFormattedString() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return "Ad Soyad: $adSoyad\nKonum: $konum\nMesaj: $mesaj\nTarih: ${formatter.format(zaman)}\nCihaz: $cihazAdi";
  }
}