import 'package:flutter/foundation.dart';
import 'package:deprem/models/kullanici.dart';

class KullaniciProvider extends ChangeNotifier {
  Kullanici? _kullanici;

  Kullanici? get kullanici => _kullanici;

  void kullaniciyiAyarla(Kullanici yeniKullanici) {
    _kullanici = yeniKullanici;
    notifyListeners();
  }
}