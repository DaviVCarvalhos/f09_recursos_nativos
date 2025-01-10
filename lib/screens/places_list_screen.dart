import 'dart:io';

import 'package:f09_recursos_nativos/provider/places_model.dart';
import 'package:f09_recursos_nativos/screens/place_details_screen.dart';
import 'package:f09_recursos_nativos/screens/place_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
              // Sincronizar lugares
              await Provider.of<PlacesModel>(context, listen: false)
                  .syncPlaces();
            },
            icon: Icon(Icons.sync, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<PlacesModel>(context, listen: false).loadPlaces(),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : Consumer<PlacesModel>(
                child: Center(child: Text('Nenhum local')),
                builder: (context, places, child) => places.itemsCount == 0
                    ? child!
                    : ListView.builder(
                        itemCount: places.itemsCount,
                        itemBuilder: (context, index) {
                          final place = places.itemByIndex(index);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: FileImage(place.image),
                            ),
                            title: Text(place.title),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    // Redireciona para a tela de edição, passando os dados individualmente
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => PlaceFormScreen(
                                          id: place.id,
                                          title: place.title,
                                          phoneNumber: place.phoneNumber,
                                          email: place.email,
                                          initialLocation: LatLng(
                                            place.location!.latitude,
                                            place.location!.longitude,
                                          ),
                                          imagePath: place.image.path,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text('Excluir lugar'),
                                        content: Text(
                                            'Tem certeza que deseja excluir este lugar?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await Provider.of<PlacesModel>(context,
                                              listen: false)
                                          .removePlace(place.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => PlaceDetailScreen(place),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
