import 'dart:io';
import 'dart:convert';

class WifiService {
  Future<bool> veriGonder(String ipAdresi, int port, String veri) async {
    try {
      final socket = await Socket.connect(ipAdresi, port);
      socket.write(veri);
      await socket.flush();
      socket.close();
      return true; // Başarılı
    } catch (e) {
      print("Wi-Fi üzerinden veri gönderme hatası: $e");
      return false; // Hata
    }
  }
}