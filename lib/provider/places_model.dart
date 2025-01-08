import 'dart:io';
import 'dart:math';

import 'package:f09_recursos_nativos/models/place_location.dart';
import 'package:f09_recursos_nativos/utils/location_util.dart';
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../utils/db_util.dart';

class PlacesModel with ChangeNotifier {
  List<Place> _items = [];

  List<Place> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Place itemByIndex(int index) {
    return _items[index];
  }

  void addPlace(String title, File image, double lat, double lng,
      String phoneNumber, String email) async {
    final address = await LocationUtil.getAddressFromLatLng(lat, lng);

    final newPlace = Place(
      id: DateTime.now().toString(),
      title: title,
      location: PlaceLocation(latitude: lat, longitude: lng, address: address),
      image: image,
      phoneNumber: phoneNumber,
      email: email,
    );

    // Log para verificar as informações antes de salvar
    print('Salvando novo lugar:');
    print('Título: ${newPlace.title}');
    print('Endereço: ${newPlace.location!.address}');
    print('Latitude: ${newPlace.location!.latitude}');
    print('Longitude: ${newPlace.location!.longitude}');
    print('Telefone: ${newPlace.phoneNumber}');
    print('Email: ${newPlace.email}');
    print('Caminho da Imagem: ${newPlace.image.path}');

    _items.add(newPlace);
    DbUtil.insert('places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'latitude': lat,
      'longitude': lng,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
    });
    notifyListeners();
  }

  Future<void> loadPlaces() async {
    final dataList = await DbUtil.getData('places');
    _items = dataList
        .map(
          (item) => Place(
            id: item['id'],
            title: item['title'],
            image: File(item['image']),
            location: PlaceLocation(
              latitude: item['latitude'],
              longitude: item['longitude'],
              address: item['address'],
            ),
            phoneNumber: item['phoneNumber'],
            email: item['email'],
          ),
        )
        .toList();
    notifyListeners();
  }
}
