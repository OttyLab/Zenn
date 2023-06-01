import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  runApp(const MapboxSample());
}

class MapboxSample extends StatelessWidget {
  const MapboxSample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapbox Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  _onMapCreated(MapboxMap mapboxMap) async {
    await mapboxMap.style.addStyleImage("parrot0", 1.0, await _getImage("assets/frame0.png"), false, [], [], null);
    await mapboxMap.style.addStyleImage("parrot1", 1.0, await _getImage("assets/frame1.png"), false, [], [], null);
    await mapboxMap.style.addStyleImage("parrot2", 1.0, await _getImage("assets/frame2.png"), false, [], [], null);
    await mapboxMap.style.addStyleImage("parrot3", 1.0, await _getImage("assets/frame3.png"), false, [], [], null);
    await mapboxMap.style.addStyleImage("parrot4", 1.0, await _getImage("assets/frame4.png"), false, [], [], null);
    await mapboxMap.style.addStyleImage("parrot5", 1.0, await _getImage("assets/frame5.png"), false, [], [], null);
    await mapboxMap.style.addStyleImage("parrot6", 1.0, await _getImage("assets/frame6.png"), false, [], [], null);
    await mapboxMap.style.addStyleImage("parrot7", 1.0, await _getImage("assets/frame7.png"), false, [], [], null);
    await mapboxMap.style.addStyleImage("parrot8", 1.0, await _getImage("assets/frame8.png"), false, [], [], null);
    await mapboxMap.style.addStyleImage("parrot9", 1.0, await _getImage("assets/frame9.png"), false, [], [], null);

    var geojson = await rootBundle.loadString('assets/party.json');
    var source = GeoJsonSource(id: "party-source", data: geojson);
    await mapboxMap.style.addSource(source);

    var layer = SymbolLayer(
      id: "party-layer",
      sourceId: "party-source",
      iconImage: "parrot0",
      iconSize: 0.25,
    );
    await mapboxMap.style.addLayer(layer);

    var counter = 0;
    Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      layer.iconImage = "parrot${(++counter) % 10}";
      await mapboxMap.style.updateLayer(layer);
    });
  }

  Future<MbxImage> _getImage(String path) async {
    final ByteData bytes = await rootBundle.load(path);
    final Uint8List image = bytes.buffer.asUint8List();
    return new MbxImage(width: 128, height: 128, data: image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MapWidget(
          resourceOptions: ResourceOptions(accessToken: YOUR_MAPBOX_PUBLIC_TOKEN),
          cameraOptions: CameraOptions(
            center: Point(coordinates: Position(139.763906, 35.6811649)).toJson(),
            zoom: 14,
          ),
          styleUri: MapboxStyles.LIGHT,
          onMapCreated: _onMapCreated,
        )
    );
  }
}
