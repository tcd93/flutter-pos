import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

const _width = 98.0;
const _height = 98.0;

/// Image of the dish, edittable
class Avatar extends StatelessWidget {
  final Uint8List? imageData;
  final String? asset;
  final void Function(Uint8List image)? onNew;

  late final _imgStream = StreamController<Uint8List>();

  Avatar({this.imageData, this.asset, this.onNew});

  void _initStream() async {
    if (imageData != null) {
      _imgStream.add(imageData!);
    } else if (asset != null) {
      _imgStream.add((await rootBundle.load(asset!)).buffer.asUint8List());
    } else {
      final defautImg = await rootBundle.load('assets/coffee.png');
      _imgStream.add(defautImg.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    _initStream();

    return Stack(
      children: [
        Container(
          width: _width,
          height: _height,
          child: imageButton(),
        ),
        Positioned(
          bottom: 0.0,
          right: 0.0,
          child: Icon(Icons.edit, size: 16.0),
        ),
      ],
    );
  }

  StreamBuilder<Uint8List> imageButton() {
    return StreamBuilder(
      stream: _imgStream.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final img = snapshot.data!;

          return MaterialButton(
            onPressed: onNew != null
                ? () async {
                    final newSelected = await _getImage();
                    if (newSelected != null && newSelected != img) {
                      _imgStream.add(newSelected);
                      onNew!.call(newSelected);
                    }
                  }
                : null,
            color: Colors.transparent,
            padding: EdgeInsets.all(0.0),
            shape: const CircleBorder(
              side: BorderSide(width: 3.0, color: Colors.black38),
            ),
            child: CircleAvatar(
              backgroundImage: MemoryImage(img),
              radius: _width,
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

Future<Uint8List?> _getImage() async {
  final pickedFile = await ImagePicker().getImage(
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
