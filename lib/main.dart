import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deprem_iletisim/providers/sinyal_provider.dart';
import 'package:deprem_iletisim/screens/acilis_ekrani.dart'; // Açılış ekranı

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bildirim servisini başlat
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SinyalProvider()),
      ],
      child: MaterialApp(
        title: 'Deprem İletişim',
        theme: ThemeData(
          primarySwatch: Colors.red, // Temel renk kırmızı
        ),
        home: AcilisEkrani(), // Açılış ekranı ile başla
      ),
    );
  }
}