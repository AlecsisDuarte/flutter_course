import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/widgets/ui_elements/height_spacing.dart';
import 'package:flutter_course/widgets/ui_elements/width_spacing.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final Product product;

  ImageInput(this.setImage, this.product);
  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _imageFile;

  void _getImage(BuildContext context, ImageSource source) {
    Navigator.pop(context);
    ImagePicker.pickImage(
      source: source,
      maxWidth: 400.0,
    ).then((File image) {
      setState(() => _imageFile = image);
      widget.setImage(image);
    });
  }

  void _openImagePicker(BuildContext context, Color buttonsColor) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an Image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                FlatButton(
                  child: Text(
                    'Use Camera',
                    style: TextStyle(color: buttonsColor),
                  ),
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                ),
                FlatButton(
                  child: Text(
                    'Use Gallery',
                    style: TextStyle(color: buttonsColor),
                  ),
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).primaryColor;

    return Column(
      children: <Widget>[
        OutlineButton(
          borderSide: BorderSide(
            color: buttonColor,
            width: 2.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.photo_camera,
                color: buttonColor,
              ),
              WidthSpacing(),
              Text(
                'Add Image',
                style: TextStyle(
                  color: buttonColor,
                ),
              ),
            ],
          ),
          onPressed: () => _openImagePicker(context, buttonColor),
        ),
        HeightSpacing(),
        previewImageWidget(),
      ],
    );
  }

  Widget previewImageWidget() {
    final double imageWidth = MediaQuery.of(context).size.width;

    if (_imageFile != null) {
      return Image.file(
        _imageFile,
        fit: BoxFit.cover,
        width: imageWidth,
        height: 300.0,
        alignment: Alignment.topCenter,
      );
    } else if (widget.product != null) {
      return Image.network(
        widget.product.image,
        fit: BoxFit.cover,
        width: imageWidth,
        height: 300.0,
        alignment: Alignment.topCenter,
      );
    } else {
      return Text('Please Pick an Image');
    }
  }
}
