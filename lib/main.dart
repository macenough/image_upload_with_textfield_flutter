import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyImagePicker(title: 'Upload image'),
    );
  }
}

class MyImagePicker extends StatefulWidget {
  MyImagePicker({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyImagePickerState createState() => _MyImagePickerState();
}

class _MyImagePickerState extends State<MyImagePicker> {
  PickedFile _imageFile;
  final String uploadUrl = 'https://api.deonde.co/api/v1/owner_update_profile';
  final ImagePicker _picker = ImagePicker();

  Future<String> uploadImage(filepath, url) async {
    String token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvYXBpLmRlb25kZS5jb1wvYXBpXC92MVwvb3duZXJfbG9naW4iLCJpYXQiOjE2NTEyMTAyMDMsImV4cCI6MTY1ODk4NjIwMywibmJmIjoxNjUxMjEwMjAzLCJqdGkiOiJRdmNBTTJkUnhHVlIyTURjIiwic3ViIjoxMjQyLCJwcnYiOiI4N2UwYWYxZWY5ZmQxNTgxMmZkZWM5NzE1M2ExNGUwYjA0NzU0NmFhIn0.XBAYe0tl6L71VSOjyEHR6OMJnVp5LBZWVbD9eVcYfNI";

    Map<String, String> headers = {
      "Authorization":
      " Bearer $token"
    };
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['user_id'] = '1242';
    request.fields['user_email'] = 'pizzastore@yopmail.com';
    request.fields['restaurant_name'] = 'Pizza Store';
    request.fields['restaurant_phone'] = '989898956';
    request.fields['country_code'] = '+91';
    request.fields['customer_name'] = '';
    request.fields['customer_number'] = '989898980';
    request.fields['vendor_id'] = '40818';
    request.fields['is_langauge'] = 'en';
    request.headers.addAll(headers);
    request.fields.addAll(request.fields);
    request.files
        .add(await http.MultipartFile.fromPath('imageUpload', filepath));
    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);
    if (response.statusCode == 200) {
      print("SUCCESS");
      print(responseData);
    }
    else {
      print("ERROR");
    }
  }

  Future<void> retriveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      print('Retrieve error ' + response.exception.code);
    }
  }

  Widget _previewImage() {
    if (_imageFile != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.file(File(_imageFile.path)),
            SizedBox(
              height: 20,
            ),
            RaisedButton(
              onPressed: () async {
                var res = await uploadImage(_imageFile.path, uploadUrl);
                print(res);
              },
              child: const Text('Upload'),
            )
          ],
        ),
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  void _pickImage() async {
    try {
      final pickedFile = await _picker.getImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      print("Image picker error " + e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
            child: FutureBuilder<void>(
          future: retriveLostData(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Text('Picked an image');
              case ConnectionState.done:
                return _previewImage();
              default:
                return const Text('Picked an image');
            }
          },
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image from gallery',
        child: Icon(Icons.photo_library),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
