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
    final dataList = await DbUtil.getLastTenItems('places');
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

    // Verificar se snapshot.value é um Map
    if (snapshot.value is Map) {
      // Agora garantimos que é um Map<String, dynamic>
      final firebasePlaces = (snapshot.value as Map<dynamic, dynamic>)
          .map((key, value) {
            // Convertendo chave para String e o valor para Map<String, dynamic>
            return MapEntry(
                key.toString(), Map<String, dynamic>.from(value as Map));
          })
          .values
          .toList();

      final localPlaces = await DbUtil.getData('places');

      final firebasePlaceIds =
          firebasePlaces.map((place) => place['id']).toList();

      // Remover locais que não existem mais no Firebase
      for (final localPlace in localPlaces) {
        if (!firebasePlaceIds.contains(localPlace['id'])) {
          // Excluir do SQLite se o lugar não estiver no Firebase
          await DbUtil.delete('places', localPlace['id']);
        }
      }

      // Verificar quais lugares precisam ser sincronizados ou inseridos
      for (final place in firebasePlaces) {
        final localPlace = localPlaces.firstWhere(
          (local) => local['id'] == place['id'],
          orElse: () =>
              <String, dynamic>{}, // Retorna um Map vazio se não encontrar
        );

        if (localPlace.isEmpty) {
          // Adiciona ao SQLite se o lugar não existir localmente
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

      // Atualiza a lista local no aplicativo
      await loadPlaces();
    } else {
      // Se o snapshot não for um Map válido, pode-se adicionar um log de erro ou retornar um erro.
      print('Erro: snapshot.value não é um Map');
    }
  }

  void editPlace(String id, String newTitle, File newImage, double newLat,
      double newLng, String newPhoneNumber, String newEmail) async {
    final placeIndex = _items.indexWhere((place) => place.id == id);
    if (placeIndex >= 0) {
      final address = await LocationUtil.getAddressFromLatLng(newLat, newLng);

      // Atualiza o lugar na memória
      final updatedPlace = Place(
        id: id,
        title: newTitle,
        image: newImage,
        location: PlaceLocation(
            latitude: newLat, longitude: newLng, address: address),
        phoneNumber: newPhoneNumber,
        email: newEmail,
      );
      _items[placeIndex] = updatedPlace;

      // Atualiza no Firebase
      final placesRef = FirebaseDatabase.instance.ref('places');
      await placesRef.child(id).update({
        'title': newTitle,
        'image': newImage.path,
        'latitude': newLat,
        'longitude': newLng,
        'address': address,
        'phoneNumber': newPhoneNumber,
        'email': newEmail,
        'updatedAt': DateTime.now().toString(),
      });

      // Atualiza no SQLite
      DbUtil.insert('places', {
        'id': updatedPlace.id,
        'title': updatedPlace.title,
        'image': updatedPlace.image.path,
        'latitude': updatedPlace.location!.latitude,
        'longitude': updatedPlace.location!.longitude,
        'address': updatedPlace.location!.address,
        'phoneNumber': updatedPlace.phoneNumber,
        'email': updatedPlace.email,
        'createdAt': DateTime.now().toString(),
      });

      notifyListeners();
    }
  }

  Future<void> removePlace(String id) async {
    // Remove da memória
    _items.removeWhere((place) => place.id == id);

    // Remove do Firebase
    final placesRef = FirebaseDatabase.instance.ref('places');
    await placesRef.child(id).remove();

    // Remove do SQLite
    final db = await DbUtil.openDatabaseConnection();
    await db.delete('places', where: 'id = ?', whereArgs: [id]);

    notifyListeners();
  }
}
