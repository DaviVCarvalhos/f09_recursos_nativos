import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationUtil {
  static const GOOGLE_API_KEY = 'AIzaSyBN57Q-EKBgCmB3frI6Jmuf_kSpztpfMig';

  // Gera a URL de uma imagem de mapa estático
  static String generateLocationPreviewImage({
    required double latitude,
    required double longitude,
  }) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  // Obtém o endereço formatado a partir de latitude e longitude
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_API_KEY');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
          'Falha ao buscar o endereço. Código de status: ${response.statusCode}');
    }

    final data = json.decode(response.body);

    if (data['results'].isEmpty) {
      return 'Endereço não encontrado';
    }

    return data['results'][0]['formatted_address'];
  }

  // Obtém as coordenadas (latitude e longitude) a partir de um endereço
  static Future<Map<String, double>> getCoordinatesFromAddress(
      String address) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$GOOGLE_API_KEY');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
          'Falha ao buscar as coordenadas. Código de status: ${response.statusCode}');
    }

    final data = json.decode(response.body);

    if (data['results'].isEmpty) {
      throw Exception('Coordenadas não encontradas para o endereço fornecido.');
    }

    final location = data['results'][0]['geometry']['location'];
    return {
      'latitude': location['lat'],
      'longitude': location['lng'],
    };
  }
}
