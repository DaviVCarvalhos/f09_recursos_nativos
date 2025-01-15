import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImageInput extends StatefulWidget {
  final Function(File) onImagePicked;

  ImageInput(this.onImagePicked);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await showDialog<File>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Escolha a origem da imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                final image = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 600,
                );
                Navigator.of(ctx)
                    .pop(image?.path != null ? File(image!.path) : null);
              },
              child: Text('Tirar foto com a câmera'),
            ),
            TextButton(
              onPressed: () async {
                final image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 600,
                );
                Navigator.of(ctx)
                    .pop(image?.path != null ? File(image!.path) : null);
              },
              child: Text('Escolher imagem da galeria'),
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
      widget.onImagePicked(_pickedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _pickedImage == null
            ? Text('Nenhuma imagem selecionada!')
            : Image.file(
                _pickedImage!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Tirar Foto'),
              onPressed: _pickImage,
            ),
          ],
        ),
      ],
    );
  }
}
