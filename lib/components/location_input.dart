import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/map_screen.dart';
import '../utils/location_util.dart';

class LocationInput extends StatefulWidget {
  final Function(double, double)
      onSelectPlace; // Callback para enviar coordenadas
  final LatLng? initialLocation; // Localização inicial opcional

  LocationInput({required this.onSelectPlace, this.initialLocation});

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  @override
  void initState() {
    super.initState();
    // Se uma localização inicial foi fornecida, gera a imagem do mapa.
    if (widget.initialLocation != null) {
      _previewImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: widget.initialLocation!.latitude,
        longitude: widget.initialLocation!.longitude,
      );
    }
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      final locData =
          await Location().getLocation(); // Pega localização do usuário
      final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: locData.latitude!,
        longitude: locData.longitude!,
      );

      // Passando as coordenadas para o callback
      widget.onSelectPlace(locData.latitude!, locData.longitude!);

      setState(() {
        _previewImageUrl = staticMapImageUrl;
      });
    } catch (error) {
      print("Erro ao obter localização: $error");
    }
  }

  Future<void> _selectOnMap() async {
    final LatLng? selectedPosition = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => MapScreen(),
      ),
    );

    if (selectedPosition == null) return;

    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
      latitude: selectedPosition.latitude,
      longitude: selectedPosition.longitude,
    );

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
        ),
      ],
    );
  }
}
