import 'package:f09_recursos_nativos/utils/location_util.dart';
import 'package:flutter/material.dart';
import '../models/place.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  PlaceDetailScreen(this.place);

  // Função para fazer chamadas telefônicas
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw Exception('Não foi possível realizar a chamada para $phoneNumber');
    }
  }

  // Função para enviar e-mails
  Future<void> sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw Exception('Não foi possível abrir o aplicativo de e-mail.');
    }
  }

  // Função para abrir o mapa
  Future<void> _openMap(double latitude, double longitude) async {
    final Uri mapUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps',
      queryParameters: {'q': '$latitude,$longitude'},
    );

    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Não foi possível abrir o mapa.');
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
              Image.file(
                place.image,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              Text(
                place.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Telefone:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(place.phoneNumber, style: TextStyle(fontSize: 18)),
              TextButton.icon(
                onPressed: () => makePhoneCall(place.phoneNumber),
                icon: Icon(Icons.phone, color: Colors.blue),
                label: Text('Ligar'),
              ),
              SizedBox(height: 10),
              Text(
                'E-mail:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(place.email, style: TextStyle(fontSize: 18)),
              TextButton.icon(
                onPressed: () => sendEmail(place.email),
                icon: Icon(Icons.email, color: Colors.blue),
                label: Text('Enviar e-mail'),
              ),
              SizedBox(height: 10),
              Text(
                'Endereço:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                place.location?.address ?? 'Endereço não disponível',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Localização no mapa:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => _openMap(
                  place.location!.latitude,
                  place.location!.longitude,
                ),
                child: Image.network(
                  LocationUtil.generateLocationPreviewImage(
                    latitude: place.location!.latitude,
                    longitude: place.location!.longitude,
                  ),
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
