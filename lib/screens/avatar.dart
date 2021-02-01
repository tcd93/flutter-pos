import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

const _width = 98.0;
const _height = 98.0;

/// Image of the dish, edittable
class Avatar extends StatefulWidget {
  final Uint8List imageData;
  final void Function(Uint8List image) onNew;

  Avatar({this.imageData, this.onNew});

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  FutureOr<Uint8List> image;

  @override
  void initState() {
    image = widget.imageData ??
        rootBundle.load('assets/coffee.png').then(
              (data) => data.buffer.asUint8List(),
            );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: _width,
          height: _height,
          child: imageButton(),
        ),
        if (widget.onNew != null)
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: Icon(Icons.edit, size: 16.0),
          ),
      ],
    );
  }

  FutureBuilder<Uint8List> imageButton() {
    final _img = Future.sync(() => image);
    return FutureBuilder(
      future: _img,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final img = snapshot.data;

          return RaisedButton(
            onPressed: widget.onNew != null
                ? () async {
                    final selected = await _getImage();
                    if (selected != null && selected != img) {
                      setState(() {
                        image = selected;
                        widget.onNew(selected);
                      });
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

Future<Uint8List> _getImage() async {
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
