// encrypt paketi kullanılarak basit bir şifreleme örneği
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class SifrelemeUtil {
  // Örnek bir anahtar (güvenli bir şekilde saklanmalıdır)
  final String _anahtar = "ÇokGüvenliAnahtar123"; // Bu anahtar gerçekte daha karmaşık olmalı

  // Şifreleme
  String sifrele(String veri) {
    final key = Key.fromUtf8(_anahtar);
    final iv = IV.fromLength(16);  // Initialization Vector (IV) - Şifreleme için rastgele bir vektör
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));  // CBC modu
    final encrypted = encrypter.encrypt(veri, iv: iv);
    return encrypted.base64;
  }

  // Şifre çözme
  String sifreCoz(String sifreliVeri) {
    final key = Key.fromUtf8(_anahtar);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    try {
      final decrypted = encrypter.decrypt64(sifreliVeri, iv: iv);
      return decrypted;
    } catch (e) {
      print("Şifre çözme hatası: $e");
      return "Şifre çözülemedi!"; // Hata durumunda bir mesaj döndür
    }
  }
}