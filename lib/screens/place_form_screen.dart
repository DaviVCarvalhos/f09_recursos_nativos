import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../components/image_input.dart';
import '../components/location_input.dart';
import '../provider/places_model.dart';

class PlaceFormScreen extends StatefulWidget {
  final String? id;
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

  @override
  void initState() {
    super.initState();
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

  void _selectPlace(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
  }

  void _selectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  void _submitForm() async {
    if (_titleController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _latitude == null ||
        _longitude == null ||
        (_pickedImage == null && widget.id == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos!')),
      );
      return;
    }

    if (widget.id == null) {
      // Adicionar novo lugar
      Provider.of<PlacesModel>(context, listen: false).addPlace(
        _titleController.text,
        _pickedImage!,
        _latitude!,
        _longitude!,
        _phoneController.text,
        _emailController.text,
      );
    } else {
      // Editar lugar existente
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
                    ImageInput(
                      _selectImage,
                      initialImage: _pickedImage,
                    ),
                    SizedBox(height: 10),
                    LocationInput(
                      onSelectPlace: _selectPlace,
                      initialLocation: widget.initialLocation,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.save),
              label:
                  Text(widget.id == null ? 'Adicionar' : 'Salvar Alterações'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 0,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _submitForm,
            ),
          ),
        ],
      ),
    );
  }
}
