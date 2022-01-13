import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const _width = 98.0;
const _height = 98.0;

/// Image of the dish, edittable
class Avatar extends StatelessWidget {
  final ImageProvider? imgProvider;
  final void Function(Uint8List image)? onNew;

  const Avatar({this.imgProvider, this.onNew});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: _width,
          height: _height,
          child: imageButton(),
        ),
        const Positioned(
          bottom: 0.0,
          right: 0.0,
          child: Icon(Icons.edit, size: 16.0),
        ),
      ],
    );
  }

  Widget imageButton() {
    return MaterialButton(
      onPressed: () async {
        final newSelected = await _getImage();
        if (newSelected != null) {
          onNew?.call(newSelected);
        }
      },
      color: Colors.transparent,
      padding: const EdgeInsets.all(0.0),
      shape: const CircleBorder(
        side: BorderSide(width: 3.0, color: Colors.black38),
      ),
      child: CircleAvatar(
        backgroundImage: imgProvider ?? const AssetImage('assets/coffee.png'),
        radius: _width,
      ),
    );
  }
}

Future<Uint8List?> _getImage() async {
  final pickedFile = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxHeight: _height,
    maxWidth: _width,
    imageQuality: 1,
  );
  if (pickedFile != null) {
    return pickedFile.readAsBytes();
  }
  return null;
}
