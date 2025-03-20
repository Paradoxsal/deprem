import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deprem/providers/sinyal_provider.dart';
import 'package:deprem/screens/acilis_ekrani.dart'; // Düzeltildi

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          primarySwatch: Colors.red,
        ),
        home: AcilisEkrani(),
      ),
    );
  }
}