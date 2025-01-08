import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/map_screen.dart';
import '../utils/location_util.dart';

// Adicionamos o parâmetro onSelectPlace para passar as coordenadas de volta.
class LocationInput extends StatefulWidget {
  final Function(double, double)
      onSelectPlace; // Callback para enviar coordenadas

  LocationInput({required this.onSelectPlace});

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  Future<void> _getCurrentUserLocation() async {
    final locData =
        await Location().getLocation(); // Pega localização do usuário
    print(locData.latitude);
    print(locData.longitude);

    // Atualizando a visualização do mapa com a localização do usuário
    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: locData.latitude!, longitude: locData.longitude!);

    // Passando as coordenadas para o callback
    widget.onSelectPlace(locData.latitude!, locData.longitude!);

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  Future<void> _selectOnMap() async {
    final LatLng selectedPosition = await Navigator.of(context).push(
      MaterialPageRoute(
          fullscreenDialog: true, builder: ((context) => MapScreen())),
    );

    if (selectedPosition == null) return;

    print(selectedPosition.latitude);
    print(selectedPosition.longitude);

    // Atualizando a visualização do mapa com a localização selecionada
    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: selectedPosition.latitude,
        longitude: selectedPosition.longitude);

    // Passando as coordenadas para o callback
    widget.onSelectPlace(selectedPosition.latitude, selectedPosition.longitude);

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: _previewImageUrl == null
              ? Text('Localização não informada!')
              : Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Localização atual'),
              onPressed: _getCurrentUserLocation,
            ),
            TextButton.icon(
              icon: Icon(Icons.map),
              label: Text('Selecione no Mapa'),
              onPressed: _selectOnMap,
            ),
          ],
        )
      ],
    );
  }
}
