import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationUtil {
  static const GOOGLE_API_KEY = 'AIzaSyBN57Q-EKBgCmB3frI6Jmuf_kSpztpfMig';

  static String generateLocationPreviewImage({
    required double latitude,
    required double longitude,
  }) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_API_KEY');
    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['results'].isEmpty) {
      return 'Endereço não encontrado';
    }
    return data['results'][0]['formatted_address'];
  }
}
