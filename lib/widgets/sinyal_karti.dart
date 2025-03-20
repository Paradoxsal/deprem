import 'package:flutter/material.dart';
import 'package:deprem_iletisim/models/sinyal.dart';

class SinyalKarti extends StatelessWidget {
  final Sinyal sinyal;
  final VoidCallback onTap;

  SinyalKarti({required this.sinyal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sinyal.adSoyad ?? "Bilinmeyen Kişi", style: TextStyle(fontWeight: FontWeight.bold)),
               SizedBox(height: 4),
              Text(sinyal.mesaj ?? "Mesaj Yok", maxLines: 2, overflow: TextOverflow.ellipsis), // Mesajı kısalt
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sinyal.zaman.toString()), // Zaman bilgisi
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}