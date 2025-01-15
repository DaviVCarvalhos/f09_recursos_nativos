import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class AddressInputScreen extends StatefulWidget {
  @override
  _AddressInputScreenState createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends State<AddressInputScreen> {
  final _addressController = TextEditingController();
  String? _error;

  Future<void> _submitAddress() async {
    final address = _addressController.text;

    if (address.isEmpty) {
      setState(() {
        _error = 'Por favor, informe um endereço válido.';
      });
      return;
    }

    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        Navigator.of(context).pop({
          'lat': location.latitude,
          'lng': location.longitude,
          'address': address,
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Endereço não encontrado. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informar Endereço'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Endereço',
                errorText: _error,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAddress,
              child: Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
