import 'package:f09_recursos_nativos/utils/location_util.dart';
import 'package:flutter/material.dart';

import '../models/place.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  PlaceDetailScreen(this.place);

  // Função para abrir o telefone
  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível realizar a chamada para $phoneNumber';
    }
  }

  // Função para enviar um e-mail
  Future<void> _sendEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o aplicativo de e-mail';
    }
  }

  // Função para abrir o mapa
  Future<void> _openMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps?q=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o mapa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.file(place.image), // Exibe a imagem do lugar
              SizedBox(height: 10),
              Text(
                place.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Telefone: ${place.phoneNumber}',
                style: TextStyle(fontSize: 18),
              ),
              TextButton(
                onPressed: () => _makePhoneCall(place.phoneNumber),
                child: Text('Ligar para ${place.phoneNumber}'),
              ),
              SizedBox(height: 10),
              Text(
                'E-mail: ${place.email}',
                style: TextStyle(fontSize: 18),
              ),
              TextButton(
                onPressed: () => _sendEmail(place.email),
                child: Text('Enviar e-mail para ${place.email}'),
              ),
              SizedBox(height: 10),
              Text(
                'Endereço: ${place.location?.address}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Localização no mapa:',
                style: TextStyle(fontSize: 18),
              ),
              GestureDetector(
                onTap: () => _openMap(
                    place.location!.latitude, place.location!.longitude),
                child: Image.network(
                  LocationUtil.generateLocationPreviewImage(
                      latitude: place.location!.latitude,
                      longitude: place.location!.longitude),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
