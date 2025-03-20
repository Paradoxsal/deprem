import 'package:flutter/foundation.dart';
import 'package:deprem_iletisim/models/sinyal.dart';

class SinyalProvider extends ChangeNotifier {
  List<Sinyal> _gelenSinyaller = [];
  List<Sinyal> get gelenSinyaller => _gelenSinyaller;

  void sinyalEkle(Sinyal sinyal) {
    _gelenSinyaller.add(sinyal);
    notifyListeners();
  }

  void sinyalleriTemizle() { // Yeni sinyaller için listeyi temizleme
    _gelenSinyaller.clear();
    notifyListeners();
  }
}