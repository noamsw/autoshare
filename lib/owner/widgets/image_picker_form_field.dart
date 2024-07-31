import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:auto_share/database/storage_api.dart';

class ImagePickerFormField extends StatefulWidget {
  ImagePickerFormField({
    Key? key,
    this.networkImageUrl,
    required this.index,
    required this.carId,
    required this.imageAdded,
    required this.imageRemoved,
  }) : super(key: key);

  final String? networkImageUrl;
  final int index;
  final String carId;
  final void Function(File image, int index) imageAdded;
  final void Function(int index) imageRemoved;

  @override
  _ImagePickerFormFieldState createState() => _ImagePickerFormFieldState();
}

class _ImagePickerFormFieldState extends State<ImagePickerFormField> {
  final _imageUploadFormKey = GlobalKey<FormState>();
  final _imageFocusNode = FocusNode();
  final _imagePicker = ImagePicker();
  final _imageUploadNotifier = ValueNotifier<bool>(false);
  File? _image;
  String? _networkImageUrl;

  @override
  initState() {
    _networkImageUrl = widget.networkImageUrl;
    super.initState();
  }

  @override
  void dispose() {
    _imageFocusNode.dispose();
    _imageUploadNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _imageUploadFormKey,
      child: Column(
        children: [
          // tappable container to select image
          GestureDetector(
            onTap: () async {
              widget.imageRemoved(widget.index);
              if (_networkImageUrl != null) {
                // remove image from storage
                _networkImageUrl = null;
              }
              if (_image != null) {
                _image!.delete();
                _image = null;
              }
              _image = await _imagePicker.pickImage(
                imageQuality: 10,
                source: ImageSource.gallery,
              ).then((image) => image!=null?File(image.path):null);
              if (_image != null) {
                setState(() {
                  widget.imageAdded(_image!, widget.index);
                });
              }
            },
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: _image == null && _networkImageUrl == null
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo),
                            Text('Tap to select image')
                          ]),
                    )
                  : Stack(
                      children: [
                        _image != null ?
                        Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                          height: 200,
                          width: 200,
                        ) :
                        Image.network(
                          _networkImageUrl!,
                          fit: BoxFit.cover,
                          height: 200,
                          width: 200,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.5),
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline_outlined, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  widget.imageRemoved(widget.index);
                                  if(_networkImageUrl!= null) {
                                    _networkImageUrl = null;
                                  }
                                  else{
                                    _image?.delete();
                                    _image = null;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
