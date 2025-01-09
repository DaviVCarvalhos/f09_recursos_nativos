import 'dart:io';

import 'package:f09_recursos_nativos/models/place_location.dart';
import 'package:f09_recursos_nativos/utils/location_util.dart';
import 'package:f09_recursos_nativos/utils/db_util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:f09_recursos_nativos/models/place.dart';

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

  Future<void> addPlace(String title, File image, double lat, double lng,
      String phoneNumber, String email) async {
    final address = await LocationUtil.getAddressFromLatLng(lat, lng);

    final placesRef = FirebaseDatabase.instance.ref('places');
    final newPlaceId = placesRef.push().key;

    final newPlace = Place(
      id: newPlaceId!,
      title: title,
      location: PlaceLocation(latitude: lat, longitude: lng, address: address),
      image: image,
      phoneNumber: phoneNumber,
      email: email,
    );

    // Adiciona ao Firebase Realtime Database
    await placesRef.child(newPlaceId).set({
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'latitude': lat,
      'longitude': lng,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Adiciona ao banco local SQLite
    await DbUtil.insert('places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'latitude': lat,
      'longitude': lng,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Atualiza a lista local
    _items.add(newPlace);
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

  Future<void> syncPlaces() async {
    final placesRef = FirebaseDatabase.instance.ref('places');
    final snapshot =
        await placesRef.orderByChild('createdAt').limitToLast(10).get();

    if (!snapshot.exists) return;

    final firebasePlaces =
        (snapshot.value as Map).values.cast<Map<String, dynamic>>().toList();
    final localPlaces = await DbUtil.getData('places');

    // Verifica e sincroniza os dados
    for (final place in firebasePlaces) {
      final localPlace = localPlaces.firstWhere(
        (local) => local['id'] == place['id'],
        orElse: () => <String, dynamic>{}, // Retorna um Map vazio
      );

      if (localPlace.isEmpty) {
        // Adiciona ao SQLite caso não exista
        await DbUtil.insert('places', {
          'id': place['id'],
          'title': place['title'],
          'image': place['image'],
          'latitude': place['latitude'],
          'longitude': place['longitude'],
          'address': place['address'],
          'phoneNumber': place['phoneNumber'],
          'email': place['email'],
          'createdAt': place['createdAt'],
        });
      }
    }

    // Atualiza os lugares carregados no aplicativo
    await loadPlaces();
  }
}
