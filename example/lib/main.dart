import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';

import 'face_detail.dart';


///
///
///
void main() => runApp(MyApp());

///
///
///
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

///
///
///
class _MyAppState extends State<MyApp> {


  int _cameraFace = FlutterMobileVision.CAMERA_FRONT;
  bool _autoFocusFace = true;
  bool _torchFace = false;
  bool _multipleFace = true;
  bool _showTextFace = true;
  Size _previewFace;
  List<Face> _faces = [];

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start().then((previewSizes) => setState(() {
          _previewFace = previewSizes[_cameraFace].first;
        }));
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonColor: Colors.blue,
      ),
      home: DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              indicatorColor: Colors.black54,
              tabs: [Tab(text: 'Detección de Rostros')],
            ),
            title: Text('TLSC'),
          ),
          body: TabBarView(children: [
            _getFaceScreen(context),
          ]),
        ),
      ),
    );
  }

  ///
  /// Scan formats
  ///
  List<DropdownMenuItem<int>> _getFormats() {
    List<DropdownMenuItem<int>> formatItems = [];

    Barcode.mapFormat.forEach((key, value) {
      formatItems.add(
        DropdownMenuItem(
          child: Text(value),
          value: key,
        ),
      );
    });

    return formatItems;
  }

  ///
  /// Camera list
  ///
  List<DropdownMenuItem<int>> _getCameras() {
    List<DropdownMenuItem<int>> cameraItems = [];

    cameraItems.add(DropdownMenuItem(
      child: Text('Trasera'),
      value: FlutterMobileVision.CAMERA_BACK,
    ));

    cameraItems.add(DropdownMenuItem(
      child: Text('Frontal'),
      value: FlutterMobileVision.CAMERA_FRONT,
    ));

    return cameraItems;
  }

  ///
  /// Preview sizes list
  ///
  List<DropdownMenuItem<Size>> _getPreviewSizes(int facing) {
    List<DropdownMenuItem<Size>> previewItems = [];

    List<Size> sizes = FlutterMobileVision.getPreviewSizes(facing);

    if (sizes != null) {
      sizes.forEach((size) {
        previewItems.add(
          DropdownMenuItem(
            child: Text(size.toString()),
            value: size,
          ),
        );
      });
    } else {
      previewItems.add(
        DropdownMenuItem(
          child: Text('Empty'),
          value: null,
        ),
      );
    }

    return previewItems;
  }



  ///
  /// Face Screen
  ///
  Widget _getFaceScreen(BuildContext context) {
    List<Widget> items = [];

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Camara:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton(
        items: _getCameras(),
        onChanged: (value) {
          _previewFace = null;
          setState(() => _cameraFace = value);
        },
        value: _cameraFace,
      ),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Tamaño de resolución:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton(
        items: _getPreviewSizes(_cameraFace),
        onChanged: (value) {
          setState(() => _previewFace = value);
        },
        value: _previewFace,
      ),
    ));

    items.add(SwitchListTile(
      title: const Text('Auto focus:'),
      value: _autoFocusFace,
      onChanged: (value) => setState(() => _autoFocusFace = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Flash:'),
      value: _torchFace,
      onChanged: (value) => setState(() => _torchFace = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Multiple:'),
      value: _multipleFace,
      onChanged: (value) => setState(() => _multipleFace = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Mostrar tecto:'),
      value: _showTextFace,
      onChanged: (value) => setState(() => _showTextFace = value),
    ));

    items.add(
      Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 12.0,
        ),
        child: RaisedButton(
          onPressed: _face,
          child: Text('Detectar!'),
        ),
      ),
    );

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _faces.map((face) => FaceWidget(face)).toList(),
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(top: 12.0),
      children: items,
    );
  }

  ///
  /// Face Method
  ///
  Future<Null> _face() async {
    List<Face> faces = [];
    try {
      faces = await FlutterMobileVision.face(
        flash: _torchFace,
        autoFocus: _autoFocusFace,
        multiple: _multipleFace,
        showText: _showTextFace,
        preview: _previewFace,
        camera: _cameraFace,
        fps: 15.0,
      );
    } on Exception {
      faces.add(Face(-1));
    }

    if (!mounted) return;

    setState(() => _faces = faces);
  }
}




///
/// FaceWidget
///
class FaceWidget extends StatelessWidget {
  final Face face;

  FaceWidget(this.face);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.face),
      title: Text(face.id.toString()),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FaceDetail(face),
        ),
      ),
    );
  }
}
