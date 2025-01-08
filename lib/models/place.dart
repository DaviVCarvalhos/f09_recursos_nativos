import 'dart:io';

import 'package:f09_recursos_nativos/models/place_location.dart';

class Place {
  final String id;
  final String title;
  final PlaceLocation? location;
  final File image;
  final String phoneNumber;
  final String email;

  Place({
    required this.id,
    required this.title,
    this.location,
    required this.image,
    required this.phoneNumber,
    required this.email,
  });
}
