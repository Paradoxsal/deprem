import 'package:deprem_iletisim/models/sinyal.dart';
import 'package:deprem_iletisim/models/kullanici.dart';

class SinyalService {
  Sinyal sinyalOlustur(Kullanici kullanici, String konum, String mesaj, String cihazAdi) {
    return Sinyal(
      adSoyad: "${kullanici.ad} ${kullanici.soyad}",
      konum: konum,
      mesaj: mesaj,
      zaman: DateTime.now(),
      cihazAdi: cihazAdi,
    );
  }

  String sinyaliMetneDonustur(Sinyal sinyal) {
      return sinyal.toFormattedString();
  }
}