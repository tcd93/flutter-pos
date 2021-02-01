import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/common.dart';

const _width = 98.0;
const _height = 98.0;

/// Image of the dish, edittable
class Avatar extends StatelessWidget {
  /// path to image
  final String path;
  final void Function(String image) onNew;

  Avatar({this.path, this.onNew});

  @override
  Widget build(BuildContext context) {
    var imagePath = path ?? 'assets/coffee.png';

    return Center(
      child: Stack(
        children: [
          ClipOval(
            child: Container(
              width: _width,
              height: _height,
              child: StatefulBuilder(
                builder: (_, setNewAvatar) {
                  return RaisedButton(
                    onPressed: () async {
                      final img = await _getImage();
                      if (img != null && img != imagePath) {
                        setNewAvatar(() {
                          imagePath = img;
                        });
                        onNew?.call(img);
                      }
                    },
                    color: Colors.transparent,
                    padding: EdgeInsets.all(0.0),
                    shape: const CircleBorder(
                      side: BorderSide(width: 3.0, color: Colors.black38),
                    ),
                    // use SizedBox.expand here to stretch the image (boxfit.fill not work!)
                    child: SizedBox.expand(child: Common.convertImage(imagePath)),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: Icon(Icons.edit, size: 16.0),
          ),
        ],
      ),
    );
  }
}

Future<String> _getImage() async {
  final pickedFile = await ImagePicker().getImage(
    source: ImageSource.gallery,
    maxHeight: _height,
    maxWidth: _width,
  );
  if (pickedFile != null) {
    return pickedFile.path;
  }
  return null;
}
