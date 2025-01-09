import 'dart:io';

import 'package:f09_recursos_nativos/provider/places_model.dart';
import 'package:f09_recursos_nativos/screens/place_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_routes.dart';

class PlacesListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text('Meus Lugares', style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.PLACE_FORM);
              },
              icon: Icon(Icons.add, color: Colors.white),
            ),
            IconButton(
              onPressed: () async {
                // Aqui chamamos a sincronização de dados
                await Provider.of<PlacesModel>(context, listen: false)
                    .syncPlaces();
              },
              icon: Icon(Icons.sync, color: Colors.white),
            )
          ],
        ),
        body: FutureBuilder(
          future: Provider.of<PlacesModel>(context, listen: false).loadPlaces(),
          builder: (ctx, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : Consumer<PlacesModel>(
                  child: Center(
                    child: Text('Nenhum local disponível.'),
                  ),
                  builder: (context, places, child) => places.itemsCount == 0
                      ? child!
                      : ListView.builder(
                          itemCount: places.itemsCount,
                          itemBuilder: (context, index) {
                            final place = places.itemByIndex(index);
                            return ListTile(
                              title: Text(place.title),
                              leading: CircleAvatar(
                                backgroundImage: FileImage(place.image),
                              ),
                              onTap: () {
                                // Ao clicar no item, navegue para a tela de detalhes
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => PlaceDetailScreen(
                                      places.itemByIndex(index),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
        ));
  }
}
