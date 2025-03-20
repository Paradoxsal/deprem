import 'package:geolocator/geolocator.dart';

class KonumService {
  Future<Position?> konumAl() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Konum servisleri kapalıysa kullanıcıya bilgi ver veya açmasını iste.
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Kullanıcı konum iznini reddetti.
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Kullanıcı konum iznini kalıcı olarak reddetti.
        return null;
      }

      Position konum = await Geolocator.getCurrentPosition();
      return konum;
    } catch (e) {
      print("Konum alınırken hata oluştu: $e");
      return null;
    }
  }
}