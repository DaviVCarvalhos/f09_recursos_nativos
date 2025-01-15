import 'dart:io';

import 'package:f09_recursos_nativos/components/image_input.dart';
import 'package:f09_recursos_nativos/components/location_input.dart';
import 'package:f09_recursos_nativos/provider/places_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class PlaceFormScreen extends StatefulWidget {
  final String? id; // ID do local para edição
  final String? title;
  final String? phoneNumber;
  final String? email;
  final LatLng? initialLocation;
  final String? imagePath;

  PlaceFormScreen({
    this.id,
    this.title,
    this.phoneNumber,
    this.email,
    this.initialLocation,
    this.imagePath,
  });

  @override
  _PlaceFormScreenState createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _titleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  File? _pickedImage;
  double? _latitude;
  double? _longitude;
  String? _address;

  @override
  void initState() {
    super.initState();

    // Preenche os campos com valores iniciais se estiverem disponíveis
    if (widget.title != null) _titleController.text = widget.title!;
    if (widget.phoneNumber != null) _phoneController.text = widget.phoneNumber!;
    if (widget.email != null) _emailController.text = widget.email!;
    if (widget.initialLocation != null) {
      _latitude = widget.initialLocation!.latitude;
      _longitude = widget.initialLocation!.longitude;
    }
    if (widget.imagePath != null) {
      _pickedImage = File(widget.imagePath!);
    }
  }

  void _selectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  void _selectPlace(double lat, double lng, String address) {
    _latitude = lat;
    _longitude = lng;
    _address = address;

    setState(() {});
  }

  void _selectPlaceWithAddress(double lat, double lng) {
    _selectPlace(lat, lng, _address ?? ''); // Passa o endereço como parâmetro
  }

  void _submitForm() {
    if (_titleController.text.isEmpty ||
        _pickedImage == null ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _latitude == null ||
        _longitude == null) {
      return;
    }

    if (widget.id == null) {
      // Adicionar novo local
      Provider.of<PlacesModel>(context, listen: false).addPlace(
        _titleController.text,
        _pickedImage!,
        _latitude!,
        _longitude!,
        _phoneController.text,
        _emailController.text,
      );
    } else {
      // Editar local existente
      Provider.of<PlacesModel>(context, listen: false).editPlace(
        widget.id!,
        _titleController.text,
        _pickedImage!,
        _latitude!,
        _longitude!,
        _phoneController.text,
        _emailController.text,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Novo Lugar' : 'Editar Lugar'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Título'),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Telefone'),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'E-mail'),
                    ),
                    SizedBox(height: 10),
                    ImageInput(this._selectImage),
                    SizedBox(height: 10),
                    if (_pickedImage != null)
                      Image.file(
                        _pickedImage!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    SizedBox(height: 10),
                    LocationInput(
                      onSelectPlace: _selectPlaceWithAddress,
                      initialLocation: widget.initialLocation,
                      initialAddress: _address,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text(widget.id == null ? 'Adicionar' : 'Salvar'),
            onPressed: _submitForm,
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.amber)),
          ),
        ],
      ),
    );
  }
}
