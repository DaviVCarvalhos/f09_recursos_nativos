import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/map_screen.dart';
import '../utils/location_util.dart';

class LocationInput extends StatefulWidget {
  final Function(double, double)
      onSelectPlace; // Callback para enviar coordenadas
  final LatLng? initialLocation; // Localização inicial opcional
  final String? initialAddress; // Endereço inicial opcional

  LocationInput({
    required this.onSelectPlace,
    this.initialLocation,
    this.initialAddress,
  });

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gera o preview do mapa caso haja localização inicial ou endereço inicial
    if (widget.initialLocation != null) {
      _previewImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: widget.initialLocation!.latitude,
        longitude: widget.initialLocation!.longitude,
      );
    } else if (widget.initialAddress != null) {
      _addressController.text = widget.initialAddress!;
      _getCoordinatesFromAddress(widget.initialAddress!);
    }
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      final locData = await Location().getLocation();
      final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: locData.latitude!,
        longitude: locData.longitude!,
      );

      widget.onSelectPlace(locData.latitude!, locData.longitude!);

      setState(() {
        _previewImageUrl = staticMapImageUrl;
      });
    } catch (error) {
      print("Erro ao obter localização: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização atual.')),
      );
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

    widget.onSelectPlace(selectedPosition.latitude, selectedPosition.longitude);

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  Future<void> _getCoordinatesFromAddress(String address) async {
    try {
      final coordinates = await LocationUtil.getCoordinatesFromAddress(address);
      final latitude = coordinates['latitude']!;
      final longitude = coordinates['longitude']!;

      final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: latitude,
        longitude: longitude,
      );

      widget.onSelectPlace(latitude, longitude);

      setState(() {
        _previewImageUrl = staticMapImageUrl;
      });
    } catch (error) {
      print("Erro ao buscar coordenadas: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar localização: $error'),
        ),
      );
    }
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
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  _getCoordinatesFromAddress(value);
                },
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _getCoordinatesFromAddress(_addressController.text);
              },
            ),
          ],
        ),
        SizedBox(height: 10),
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
